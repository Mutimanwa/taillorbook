import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../models/cart_item_model.dart';

/// État global du panier (Riverpod Notifier, en mémoire).
///
/// La validation du stock et la persistance locale seront branchées lors de
/// la phase « Panier & devise » — l'API ci-dessous restera identique.
class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() => const <CartItemModel>[];

  /// Ajoute un article ; si le produit est déjà présent, augmente sa quantité.
  void addItem(CartItemModel item) {
    final int index =
        state.indexWhere((CartItemModel element) => element.productId == item.productId);

    if (index == -1) {
      state = <CartItemModel>[...state, item];
      return;
    }

    final CartItemModel existing = state[index];
    final List<CartItemModel> updated = <CartItemModel>[...state];
    updated[index] = existing.copyWith(quantity: existing.quantity + item.quantity);
    state = updated;
  }

  /// Retire complètement un produit du panier.
  void removeItem(String productId) {
    state = state
        .where((CartItemModel element) => element.productId != productId)
        .toList();
  }

  void increaseQuantity(String productId) => _adjustQuantity(productId, 1);

  void decreaseQuantity(String productId) => _adjustQuantity(productId, -1);

  /// Fixe une quantité précise (0 ⇒ retrait de la ligne).
  void setQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final int index =
        state.indexWhere((CartItemModel element) => element.productId == productId);
    if (index == -1) return;
    final List<CartItemModel> updated = <CartItemModel>[...state];
    updated[index] = state[index].copyWith(quantity: quantity);
    state = updated;
  }

  void clearCart() => state = const <CartItemModel>[];

  void _adjustQuantity(String productId, int delta) {
    final int index =
        state.indexWhere((CartItemModel element) => element.productId == productId);
    if (index == -1) return;

    final int newQuantity = state[index].quantity + delta;
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }

    final List<CartItemModel> updated = <CartItemModel>[...state];
    updated[index] = state[index].copyWith(quantity: newQuantity);
    state = updated;
  }
}

final NotifierProvider<CartNotifier, List<CartItemModel>> cartProvider =
    NotifierProvider<CartNotifier, List<CartItemModel>>(CartNotifier.new);

/// Nombre total d'articles (badge de la barre de navigation).
final Provider<int> cartTotalItemsProvider = Provider<int>((Ref ref) {
  return ref.watch(cartProvider).fold<int>(
        0,
        (int total, CartItemModel item) => total + item.quantity,
      );
});

/// Sous-total du panier, hors frais de livraison.
final Provider<double> cartSubtotalProvider = Provider<double>((Ref ref) {
  return ref.watch(cartProvider).fold<double>(
        0,
        (double total, CartItemModel item) => total + item.lineTotal,
      );
});

/// Devise d'affichage du panier : devise du premier article.
/// La conversion multi-devises sera gérée par le CurrencyService (phase 7).
final Provider<AppCurrency?> cartCurrencyProvider = Provider<AppCurrency?>((Ref ref) {
  final List<CartItemModel> items = ref.watch(cartProvider);
  if (items.isEmpty) return null;
  return items.first.currency;
});
