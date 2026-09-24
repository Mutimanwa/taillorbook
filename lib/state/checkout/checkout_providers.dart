import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_enums.dart';
import '../../core/errors/app_exceptions.dart';
import '../../core/utils/currency_converter.dart';
import '../../core/utils/validators.dart';
import '../../models/cart_item_model.dart';
import '../../models/delivery_model.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';
import '../../models/payment_model.dart';
import '../../services/payment_simulation_service.dart';
import '../auth/auth_providers.dart'
    show currentUserProvider, userProfileProvider;
import '../cart/cart_providers.dart';
import '../orders/orders_providers.dart' show orderRepositoryProvider;
import '../currency/currency_providers.dart' show displayCurrencyProvider;

/// Service de paiement simulé (une seule instance).
final Provider<PaymentSimulationService> paymentServiceProvider =
    Provider<PaymentSimulationService>((Ref ref) => PaymentSimulationService());

/// Adresse de livraison saisie à l'étape 3.
class CheckoutAddress {
  const CheckoutAddress({
    this.address = '',
    this.city = '',
    this.phone = '',
    this.additionalInfo = '',
  });

  final String address;
  final String city;
  final String phone;
  final String additionalInfo;

  bool get isComplete =>
      address.trim().isNotEmpty && city.trim().isNotEmpty && phone.trim().isNotEmpty;

  CheckoutAddress copyWith({
    String? address,
    String? city,
    String? phone,
    String? additionalInfo,
  }) {
    return CheckoutAddress(
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }
}

/// État du checkout multi-étapes.
class CheckoutState {
  const CheckoutState({
    this.step = 0,
    this.deliveryOption = DeliveryOption.delivery,
    this.address = const CheckoutAddress(),
    this.paymentMethod = PaymentMethod.mobileMoney,
    this.processingPayment = false,
    this.payment,
  });

  final int step; // 0 : panier · 1 : mode · 2 : infos · 3 : paiement · 4 : récap
  final DeliveryOption deliveryOption;
  final CheckoutAddress address;
  final PaymentMethod paymentMethod;
  final bool processingPayment;

  /// Résultat du paiement simulé (null tant que non tenté).
  final PaymentModel? payment;

  bool get isDelivery => deliveryOption == DeliveryOption.delivery;
  bool get hasPaidPayment => payment?.isPaid ?? false;

  CheckoutState copyWith({
    int? step,
    DeliveryOption? deliveryOption,
    CheckoutAddress? address,
    PaymentMethod? paymentMethod,
    bool? processingPayment,
    PaymentModel? payment,
    bool clearPayment = false,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      processingPayment: processingPayment ?? this.processingPayment,
      payment: clearPayment ? null : (payment ?? this.payment),
    );
  }
}

/// Contrôleur du checkout : navigation entre étapes, validations,
/// calculs (frais, total) et paiement simulé.
class CheckoutController extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void setDeliveryOption(DeliveryOption option) =>
      state = state.copyWith(deliveryOption: option);

  void updateAddress(CheckoutAddress address) =>
      state = state.copyWith(address: address);

  void setPaymentMethod(PaymentMethod method) =>
      state = state.copyWith(paymentMethod: method);

  void goToStep(int step) => state = state.copyWith(step: step);

  /// Valide l'étape courante avant de passer à la suivante.
  /// Renvoie un message d'erreur (null si tout est bon).
  String? validateCurrentStep() {
    switch (state.step) {
      case 0:
        final List<String> errors = _cartIssues();
        return errors.isEmpty ? null : errors.first;
      case 2:
        if (!state.isDelivery) return null;
        if (state.address.address.trim().isEmpty) return Validators.kRequiredField;
        if (state.address.city.trim().isEmpty) return Validators.kRequiredField;
        return Validators.phone(state.address.phone);
      case 3:
        if (!state.hasPaidPayment) {
          return 'Effectuez le paiement avant de confirmer la commande.';
        }
        return null;
      default:
        return null;
    }
  }

  /// Passe à l'étape suivante si la validation passe (sinon renvoie l'erreur).
  String? nextStep() {
    final String? error = validateCurrentStep();
    if (error != null) return error;
    if (state.step < 4) state = state.copyWith(step: state.step + 1);
    return null;
  }

  void previousStep() {
    if (state.step > 0) state = state.copyWith(step: state.step - 1);
  }

  void reset() => state = const CheckoutState();

  // ---------------------------------------------------------------- paiement

  /// Lance le paiement simulé pour le total courant.
  ///
  /// Renvoie le [PaymentModel] résultat (paid ou failed) — la confirmation
  /// de commande est bloquée tant que le paiement n'est pas `paid`.
  Future<PaymentModel> pay({
    required double amount,
    String mobileMoneyPhone = '',
    String cardNumber = '',
  }) async {
    state = state.copyWith(processingPayment: true, clearPayment: true);
    final PaymentModel result = await ref.read(paymentServiceProvider).processPayment(
          method: state.paymentMethod,
          amount: amount,
          mobileMoneyPhone: mobileMoneyPhone,
          cardNumber: cardNumber,
        );
    state = state.copyWith(processingPayment: false, payment: result);
    return result;
  }

  /// Construit la commande finale (après paiement réussi).
  ///
  /// Renvoie une erreur [AppException] si le panier est invalide (vide,
  /// multi-vendeurs) ou si le paiement n'est pas confirmé.
  OrderModel buildConfirmedOrder() {
    final List<String> errors = _cartIssues();
    if (errors.isNotEmpty) {
      throw ValidationException(errors.first);
    }
    if (!state.hasPaidPayment) {
      throw const ValidationException(
        'Le paiement doit être réussi avant de confirmer la commande.',
      );
    }

    final User? user = ref.read(currentUserProvider);
    if (user == null) throw const UnauthorizedException();

    final List<CartItemModel> items = ref.read(cartProvider);
    final AppCurrency display = ref.read(displayCurrencyProvider);
    final String clientName = ref.read(userProfileProvider).valueOrNull?.name ??
        user.displayName ??
        'Client SokoMarket';

    final double deliveryFee = state.isDelivery
        ? CurrencyConverter.convert(
            AppConstants.defaultDeliveryFeeUsd, AppCurrency.usd, display)
        : 0;

    final DeliveryModel delivery = DeliveryModel(
      option: state.deliveryOption,
      address: state.address.address.trim(),
      city: state.address.city.trim(),
      phone: state.address.phone.trim(),
      additionalInfo: state.address.additionalInfo.trim(),
      fee: deliveryFee,
    );

    final CartItemModel first = items.first;

    return OrderModel(
      orderId: const Uuid().v4(),
      clientId: user.uid,
      clientName: clientName,
      clientPhone:
          state.isDelivery ? state.address.phone.trim() : (user.phoneNumber ?? ''),
      sellerId: first.sellerId,
      sellerName: first.sellerName,
      sellerWhatsappNumber: first.sellerWhatsappNumber,
      items: items
          .map(
            (CartItemModel item) => OrderItemModel.fromCart(
              productId: item.productId,
              productName: item.productName,
              imageUrl: item.imageUrl,
              unitPrice: item.unitPrice,
              currency: item.currency,
              quantity: item.quantity,
            ),
          )
          .toList(),
      subtotal: ref.read(cartSubtotalProvider),
      deliveryFee: deliveryFee,
      total: ref.read(cartSubtotalProvider) + deliveryFee,
      currency: display,
      delivery: delivery,
      payment: state.payment!,
      orderStatus: OrderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Persiste la commande confirmée dans Firestore.
  ///
  /// Renvoie `null` en cas de succès, sinon un message d'erreur lisible.
  Future<String?> persistConfirmedOrder(OrderModel order) async {
    try {
      await ref.read(orderRepositoryProvider).createOrder(order);
      return null;
    } on AppException catch (error) {
      return error.message;
    } catch (_) {
      // Erreur Firebase brute (ex. permission-denied) : message guidé.
      return "Impossible d'enregistrer la commande (base de données).";
    }
  }

  // ----------------------------------------------------------------- privé

  /// Problèmes bloquants du panier (vide, multi-vendeurs).
  List<String> _cartIssues() {
    final List<CartItemModel> items = ref.read(cartProvider);
    if (items.isEmpty) {
      return <String>['Votre panier est vide.'];
    }
    final Set<String> sellers = items.map((CartItemModel e) => e.sellerId).toSet();
    if (sellers.length > 1) {
      return <String>[
        'Une commande ne peut concerner qu\'un seul vendeur pour le moment. '
            'Videz votre panier et commandez boutique par boutique.',
      ];
    }
    return <String>[];
  }
}


final NotifierProvider<CheckoutController, CheckoutState> checkoutProvider =
    NotifierProvider<CheckoutController, CheckoutState>(CheckoutController.new);