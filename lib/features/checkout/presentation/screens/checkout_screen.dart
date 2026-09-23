import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/state/cart/cart_providers.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../config/firebase/firebase_bootstrap.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/utils/currency_converter.dart';
import '../../../../core/utils/error_messages.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/display_price.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../models/cart_item_model.dart';
import '../../../../models/order_model.dart';
import '../../../../models/payment_model.dart';
import '../../../../services/payment_simulation_service.dart';
import '../../../../state/auth/auth_providers.dart';
import '../../../../state/checkout/checkout_providers.dart';
import '../../../../state/currency/currency_providers.dart';

/// Checkout multi-étapes :
/// 1) Revue du panier → 2) Mode de réception → 3) Informations de livraison
/// → 4) Paiement simulé → 5) Récapitulatif + confirmation.
///
/// Route protégée : les visiteurs sont invités à se connecter.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isAuthenticated = ref.watch(isAuthenticatedProvider);
    final List<dynamic> items = ref.watch(cartProvider);

    if (!isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Commande')),
        body: Center(
          child: AppEmpty(
            icon: Icons.lock_outline_rounded,
            title: 'Connectez-vous pour commander',
            message:
                'La finalisation d\'une commande nécessite un compte client.',
            actionLabel: 'Se connecter',
            onAction: () =>
                context.push('${AppRoutes.login}?from=${AppRoutes.checkout}'),
          ),
        ),
      );
    }

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Commande')),
        body: Center(
          child: AppEmpty(
            icon: Icons.shopping_cart_outlined,
            title: 'Votre panier est vide',
            message: 'Ajoutez des produits avant de passer commande.',
            actionLabel: 'Voir le catalogue',
            onAction: () => context.go(AppRoutes.home),
          ),
        ),
      );
    }

    return const _CheckoutFlow();
  }
}

/// Flux à 5 étapes (navigation interne + validations par étape).
class _CheckoutFlow extends ConsumerStatefulWidget {
  const _CheckoutFlow();

  @override
  ConsumerState<_CheckoutFlow> createState() => _CheckoutFlowState();
}

class _CheckoutFlowState extends ConsumerState<_CheckoutFlow> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _infoController = TextEditingController();
  final TextEditingController _mmPhoneController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final GlobalKey<FormState> _addressFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _paymentFormKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _infoController.dispose();
    _mmPhoneController.dispose();
    _cardController.dispose();
    super.dispose();
  }

  void _goNext() {
    final CheckoutController controller = ref.read(checkoutProvider.notifier);

    // Validation spécifique du formulaire d'adresse (étape 2 en livraison).
    if (controller.state.step == 2 && controller.state.isDelivery) {
      if (!(_addressFormKey.currentState?.validate() ?? false)) return;
      controller.updateAddress(CheckoutAddress(
        address: _addressController.text.trim(),
        city: _cityController.text.trim(),
        phone: _phoneController.text.trim(),
        additionalInfo: _infoController.text.trim(),
      ));
    }

    final String? error = controller.nextStep();
    if (error != null) context.showAppSnack(error, AppSnackType.warning);
  }

  Future<void> _pay(double total) async {
    context.hideKeyboard();
    if (!(_paymentFormKey.currentState?.validate() ?? false)) return;

    final CheckoutController controller = ref.read(checkoutProvider.notifier);
    final PaymentModel result = await controller.pay(
      amount: total,
      mobileMoneyPhone: _mmPhoneController.text,
      cardNumber: _cardController.text,
    );

    if (!mounted) return;
    if (result.isPaid) {
      AppHaptics.success();
      controller.goToStep(4);
      context.showAppSnack(
        'Paiement réussi · ${result.transactionReference}',
        AppSnackType.success,
      );
    } else {
      _showPaymentFailedDialog(result);
    }
  }

  void _showPaymentFailedDialog(PaymentModel payment) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
          icon: const Icon(Icons.error_outline_rounded, color: AppColors.error),
          title: const Text('Paiement échoué'),
          content: Text(
            'Le paiement n\'a pas abouti. La commande ne peut pas être '
            'confirmée.\n\nRéférence : ${payment.transactionReference}\n'
            'Vous pouvez réessayer ou changer de méthode de paiement.',
            style: AppTypography.bodyMedium(),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Réessayer plus tard'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Compris'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmOrder() async {
    final CheckoutController controller = ref.read(checkoutProvider.notifier);
    final OrderModel order;
    try {
      order = controller.buildConfirmedOrder();
    } catch (error) {
      if (!mounted) return;
      context.showAppSnack(appErrorMessage(error), AppSnackType.error);
      return;
    }

    // Enregistrement Firestore. En mode démonstration (Firebase non
    // configuré), la navigation est tolérée avec un avertissement explicite.
    final String? persistError =
        await controller.persistConfirmedOrder(order);
    if (!mounted) return;
    final bool demoMode = !FirebaseBootstrap.isReady;
    if (persistError != null && !demoMode) {
      context.showAppSnack(persistError, AppSnackType.error);
      return;
    }

    AppHaptics.success();
    ref.read(cartProvider.notifier).clearCart();
    controller.reset();
    context.pushReplacement(AppRoutes.orderSuccess, extra: order);
    if (persistError != null) {
      Future<void>.delayed(const Duration(milliseconds: 600)).then((_) {
        if (!mounted) return;
        context.showAppSnack(
          'Mode démonstration : la commande n\'a pas été enregistrée '
          '(Firebase non configuré).',
          AppSnackType.warning,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final CheckoutState state = ref.watch(checkoutProvider);
    final double subtotal = ref.watch(cartSubtotalProvider);
    final AppCurrency display = ref.watch(displayCurrencyProvider);
    final double deliveryFee = state.isDelivery
        ? CurrencyConverter.convert(
            AppConstants.defaultDeliveryFeeUsd, AppCurrency.usd, display)
        : 0;
    final double total = subtotal + deliveryFee;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (state.step == 0) {
              context.pop();
            } else {
              ref.read(checkoutProvider.notifier).previousStep();
            }
          },
        ),
        title: Text(_stepTitle(state.step)),
      ),
      body: Column(
        children: <Widget>[
          _StepIndicator(step: state.step),
          Expanded(
            child: switch (state.step) {
              0 => _CartReviewStep(),
              1 => _DeliveryMethodStep(
                  onSelected: (DeliveryOption option) {
                    ref.read(checkoutProvider.notifier).setDeliveryOption(option);
                    Future<void>.delayed(
                      const Duration(milliseconds: 250),
                      _goNext,
                    );
                  },
                ),
              2 => _DeliveryInfoStep(
                  addressFormKey: _addressFormKey,
                  addressController: _addressController,
                  cityController: _cityController,
                  phoneController: _phoneController,
                  infoController: _infoController,
                ),
              3 => _PaymentStep(
                  total: total,
                  formKey: _paymentFormKey,
                  mmPhoneController: _mmPhoneController,
                  cardController: _cardController,
                  processing: state.processingPayment,
                  payment: state.payment,
                  onPay: () => _pay(total),
                ),
              _ => _ReviewStep(
                  subtotal: subtotal,
                  deliveryFee: deliveryFee,
                  total: total,
                  currency: display,
                  onConfirm: _confirmOrder,
                ),
            },
          ),
        ],
      ),
      bottomNavigationBar:
          !state.processingPayment && state.step >= 1
              ? Container(
                  decoration: BoxDecoration(
                    color: context.appColorScheme.surface,
                    boxShadow: AppShadows.floating,
                  ),
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.sm + MediaQuery.paddingOf(context).bottom,
                  ),
                  child: switch (state.step) {
                    1 => AppButton(label: 'Continuer', onPressed: _goNext),
                    2 => AppButton(
                        label: state.isDelivery
                            ? 'Continuer vers le paiement'
                            : 'Continuer',
                        onPressed: _goNext,
                      ),
                    3 => state.hasPaidPayment
                        ? AppButton(
                            label: 'Voir le récapitulatif',
                            icon: Icons.arrow_forward_rounded,
                            onPressed: () =>
                                ref.read(checkoutProvider.notifier).goToStep(4),
                          )
                        : AppButton(
                            label: 'Payer ${MoneyFormatter.format(total, display)}',
                            icon: Icons.lock_outline_rounded,
                            onPressed: () => _pay(total),
                          ),
                    _ => AppButton(
                        label: 'Confirmer la commande',
                        icon: Icons.check_circle_outline_rounded,
                        onPressed: state.hasPaidPayment ? _confirmOrder : null,
                      ),
                  },
                )
              : null,
    );
  }

  static String _stepTitle(int step) => switch (step) {
        0 => 'Revue du panier',
        1 => 'Mode de réception',
        2 => 'Informations de livraison',
        3 => 'Paiement',
        _ => 'Récapitulatif',
      };
}

/// Indicateur de progression (5 points).
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step});

  final int step;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List<Widget>.generate(5, (int index) {
          final bool active = index <= step;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.border,
                borderRadius: AppRadius.rFull,
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Étape 1 — revue compacte du panier.
class _CartReviewStep extends ConsumerWidget {
  const _CartReviewStep();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CartItemModel> items = ref.watch(cartProvider);
    final double subtotal = ref.watch(cartSubtotalProvider);
    final AppCurrency display = ref.watch(displayCurrencyProvider);

    final Set<String> sellers =
        items.map((CartItemModel item) => item.sellerId).toSet();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: <Widget>[
        if (sellers.length > 1)
          Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.warningSoft,
              borderRadius: AppRadius.rMd,
            ),
            child: Row(
              children: <Widget>[
                const Icon(Icons.warning_amber_rounded,
                    color: AppColors.warning, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Une commande ne concerne qu\'un seul vendeur : retirez '
                    'les articles d\'une des boutiques pour continuer.',
                    style: AppTypography.labelMedium(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ...items.map(
          (CartItemModel item) {
            return Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: context.appColorScheme.surface,
                borderRadius: AppRadius.rLg,
                border: Border.all(color: context.appColorScheme.outline),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          item.productName,
                          style: AppTypography.titleSmall(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quantité : ${item.quantity}',
                          style: AppTypography.bodySmall(),
                        ),
                      ],
                    ),
                  ),
                  DisplayPrice(
                    amount: item.unitPrice * item.quantity,
                    currency: item.currency,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: Text('Sous-total', style: AppTypography.titleMedium()),
            ),
            PriceText(amount: subtotal, currency: display),
          ],
        ),
      ],
    );
  }
}

/// Étape 2 — choix du mode de réception.
class _DeliveryMethodStep extends StatelessWidget {
  const _DeliveryMethodStep({required this.onSelected});

  final ValueChanged<DeliveryOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: <Widget>[
        _MethodCard(
          icon: Icons.local_shipping_outlined,
          title: 'Livraison à domicile',
          subtitle:
              'Recevez votre commande à l\'adresse de votre choix. Frais : '
              '${MoneyFormatter.format(AppConstants.defaultDeliveryFeeUsd, AppCurrency.usd)} '
              '(converti selon votre devise).',
          onTap: () => onSelected(DeliveryOption.delivery),
        ),
        const SizedBox(height: AppSpacing.md),
        _MethodCard(
          icon: Icons.store_outlined,
          title: 'Retrait en boutique',
          subtitle:
              'Récupérez votre commande chez le vendeur. Aucun frais de '
              'livraison — vous réglez uniquement les produits.',
          badge: 'Gratuit',
          onTap: () => onSelected(DeliveryOption.storePickup),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: context.appColorScheme.surface,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: context.appColorScheme.outline),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: AppColors.primarySoft,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(title, style: AppTypography.titleMedium()),
                      ),
                      if (badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.successSoft,
                            borderRadius: AppRadius.rFull,
                          ),
                          child: Text(
                            badge!,
                            style: AppTypography.labelSmall(
                              color: AppColors.success,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTypography.bodySmall()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Étape 3 — informations de livraison (aucune adresse en retrait).
class _DeliveryInfoStep extends StatelessWidget {
  const _DeliveryInfoStep({
    required this.addressFormKey,
    required this.addressController,
    required this.cityController,
    required this.phoneController,
    required this.infoController,
  });

  final GlobalKey<FormState> addressFormKey;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController phoneController;
  final TextEditingController infoController;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, _) {
        final CheckoutState state = ref.watch(checkoutProvider);
        if (!state.isDelivery) {
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: AppRadius.rLg,
                ),
                child: Column(
                  children: <Widget>[
                    const Icon(
                      Icons.store_rounded,
                      size: 40,
                      color: AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Retrait en boutique',
                      style: AppTypography.headlineSmall(
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Aucune adresse n'est requise. Vous récupérerez votre "
                      'commande directement chez le vendeur, qui vous '
                      'contactera dès qu\'elle sera prête.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(),
                    ),
                  ],
                ),
              ),
            ],
          );
        }

        return Form(
          key: addressFormKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: <Widget>[
              Text('Où livrer votre commande ?', style: AppTypography.titleLarge()),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: addressController,
                hintText: 'Adresse complète (quartier, avenue, n°)',
                prefixIcon: Icons.home_outlined,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: cityController,
                hintText: 'Ville',
                prefixIcon: Icons.location_city_outlined,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: Validators.required,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: phoneController,
                hintText: 'Téléphone du destinataire',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: Validators.phone,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                controller: infoController,
                hintText: 'Informations complémentaires (optionnel)',
                prefixIcon: Icons.notes_outlined,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Étape 4 — paiement simulé (Mobile Money ou carte bancaire).
class _PaymentStep extends StatelessWidget {
  const _PaymentStep({
    required this.total,
    required this.formKey,
    required this.mmPhoneController,
    required this.cardController,
    required this.processing,
    required this.payment,
    required this.onPay,
  });

  final double total;
  final GlobalKey<FormState> formKey;
  final TextEditingController mmPhoneController;
  final TextEditingController cardController;
  final bool processing;
  final PaymentModel? payment;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, _) {
        final CheckoutState state = ref.watch(checkoutProvider);
        final AppCurrency display = ref.watch(displayCurrencyProvider);

        return Stack(
          children: <Widget>[
            Form(
              key: formKey,
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.primarySoft,
                      borderRadius: AppRadius.rMd,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.verified_user_outlined,
                            size: 19, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'PAIEMENT SIMULÉ — aucune transaction réelle. '
                            'SokoMarket est un projet de démonstration.',
                            style: AppTypography.labelSmall(
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PaymentMethodCard(
                    method: PaymentMethod.mobileMoney,
                    selected: state.paymentMethod == PaymentMethod.mobileMoney,
                    onSelect: () => ref
                        .read(checkoutProvider.notifier)
                        .setPaymentMethod(PaymentMethod.mobileMoney),
                    child: state.paymentMethod == PaymentMethod.mobileMoney
                        ? Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            child: AppTextField(
                              controller: mmPhoneController,
                              hintText: 'Numéro Mobile Money (+257…)',
                              prefixIcon: Icons.phone_iphone_rounded,
                              keyboardType: TextInputType.phone,
                              enabled: !processing && !state.hasPaidPayment,
                              validator: (String? value) =>
                                  PaymentSimulationService
                                      .validateMobileMoneyPhone(value ?? ''),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PaymentMethodCard(
                    method: PaymentMethod.bankCard,
                    selected: state.paymentMethod == PaymentMethod.bankCard,
                    onSelect: () => ref
                        .read(checkoutProvider.notifier)
                        .setPaymentMethod(PaymentMethod.bankCard),
                    child: state.paymentMethod == PaymentMethod.bankCard
                        ? Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.md),
                            child: AppTextField(
                              controller: cardController,
                              hintText: 'Numéro de carte (16 chiffres)',
                              prefixIcon: Icons.credit_card_rounded,
                              keyboardType: TextInputType.number,
                              enabled: !processing && !state.hasPaidPayment,
                              validator: (String? value) =>
                                  PaymentSimulationService
                                      .validateBankCardNumber(value ?? ''),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  if (state.hasPaidPayment && payment != null) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        color: AppColors.successSoft,
                        borderRadius: AppRadius.rLg,
                      ),
                      child: Column(
                        children: <Widget>[
                          const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 34),
                          const SizedBox(height: 8),
                          Text(
                            'Paiement réussi',
                            style: AppTypography.titleMedium(
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${payment!.transactionReference} · '
                            '${MoneyFormatter.format(payment!.amount, display)}',
                            style: AppTypography.bodySmall(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (processing)
              Container(
                color: Colors.black38,
                alignment: Alignment.center,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: context.appColorScheme.surface,
                    borderRadius: AppRadius.rLg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const CircularProgressIndicator(),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Traitement du paiement…',
                        style: AppTypography.titleMedium(),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Simulation en cours, ne fermez pas l\'application.',
                        style: AppTypography.bodySmall(),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

}

/// Étape 5 — récapitulatif complet avant confirmation.
/// Carte de sélection d'un moyen de paiement (simulation uniquement).
class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.method,
    required this.selected,
    required this.onSelect,
    this.child,
  });

  final PaymentMethod method;
  final bool selected;
  final VoidCallback onSelect;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final bool isMobileMoney = method == PaymentMethod.mobileMoney;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: selected ? AppColors.primarySoft : colorScheme.surface,
        borderRadius: AppRadius.rMd,
        border: Border.all(
          color: selected ? AppColors.primary : colorScheme.outline,
          width: selected ? 1.6 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.rMd,
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      isMobileMoney
                          ? Icons.phone_iphone_rounded
                          : Icons.credit_card_rounded,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        isMobileMoney ? 'Mobile Money' : 'Carte bancaire',
                        style: AppTypography.titleSmall(),
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ],
                ),
                if (child != null) child!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  const _ReviewStep({
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.currency,
    required this.onConfirm,
  });

  final double subtotal;
  final double deliveryFee;
  final double total;
  final AppCurrency currency;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, _) {
        final CheckoutState state = ref.watch(checkoutProvider);
        final PaymentModel? payment = state.payment;

        return ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: <Widget>[
            _ReviewSection(
              title: 'Réception',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    state.isDelivery
                        ? 'Livraison à domicile'
                        : 'Retrait en boutique (sans frais)',
                    style: AppTypography.bodyMedium(),
                  ),
                  if (state.isDelivery) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      '${state.address.address}, ${state.address.city} · '
                      '${state.address.phone}',
                      style: AppTypography.bodySmall(),
                    ),
                    if (state.address.additionalInfo.isNotEmpty)
                      Text(
                        state.address.additionalInfo,
                        style: AppTypography.bodySmall(),
                      ),
                  ],
                ],
              ),
            ),
            _ReviewSection(
              title: 'Paiement',
              child: payment == null
                  ? Text(
                      'Aucun paiement effectué',
                      style: AppTypography.bodyMedium(color: AppColors.error),
                    )
                  : Text(
                      '${payment.method.label} · ${payment.status.label}\n'
                      '${payment.transactionReference}',
                      style: AppTypography.bodyMedium(),
                    ),
            ),
            _ReviewSection(
              title: 'Montants',
              child: Column(
                children: <Widget>[
                  _AmountRow('Sous-total', subtotal, currency),
                  _AmountRow(
                    state.isDelivery ? 'Frais de livraison' : 'Retrait (gratuit)',
                    deliveryFee,
                    currency,
                  ),
                  const Divider(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text('Total', style: AppTypography.titleMedium()),
                      ),
                      PriceText(
                        amount: total,
                        currency: currency,
                        style: AppTypography.headlineSmall(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!state.hasPaidPayment)
              Text(
                'Le paiement doit être réussi pour confirmer la commande.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySmall(color: AppColors.error),
              ),
          ],
        );
      },
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.appColorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: context.appColorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTypography.titleSmall(color: AppColors.primary)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow(this.label, this.amount, this.currency);

  final String label;
  final double amount;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: AppTypography.bodyMedium())),
          PriceText(amount: amount, currency: currency, showOldPrice: false),
        ],
      ),
    );
  }
}