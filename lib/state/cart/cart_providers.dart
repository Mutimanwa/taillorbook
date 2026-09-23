import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../models/cart_item_model.dart';

/// État global du panier (Riverpod Notifier, en mémoire).
///
/// Les quantités sont plafonnées par [maxQuantity] (stock disponible) :
/// l'ajout au-delà du stock est silencieusement borné.
class CartNotifier extends Notifier<List<CartItemModel>> {
  @override
  List<CartItemModel> build() => const <CartItemModel>[];

  /// Ajoute un article ; si le produit est déjà présent, augmente sa quantité
  /// sans dépasser [maxQuantity] (stock disponible).
  void addItem(CartItemModel item, {int? maxQuantity}) {
    if (maxQuantity != null && maxQuantity <= 0) return; // produit en rupture

    final int index = state
        .indexWhere((CartItemModel element) => element.productId == item.productId);

    if (index == -1) {
      final int quantity =
          maxQuantity == null ? item.quantity : math.min(item.quantity, maxQuantity);
      if (quantity <= 0) return;
      state = <CartItemModel>[...state, item.copyWith(quantity: quantity)];
      return;
    }

    final CartItemModel existing = state[index];
    int target = existing.quantity + item.quantity;
    if (maxQuantity != null) target = math.min(target, maxQuantity);
    if (target <= existing.quantity) return; // déjà au maximum du stock

    final List<CartItemModel> updated = <CartItemModel>[...state];
    updated[index] = existing.copyWith(quantity: target);
    state = updated;
  }

  /// Retire complètement un produit du panier.
  void removeItem(String productId) {
    state = state
        .where((CartItemModel element) => element.productId != productId)
        .toList();
  }

  void increaseQuantity(String productId, {int? maxQuantity}) =>
      _adjustQuantity(productId, 1, maxQuantity: maxQuantity);

  void decreaseQuantity(String productId) => _adjustQuantity(productId, -1);

  /// Fixe une quantité précise (0 ⇒ retrait de la ligne).
  void setQuantity(String productId, int quantity, {int? maxQuantity}) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final int index =
        state.indexWhere((CartItemModel element) => element.productId == productId);
    if (index == -1) return;
    int capped = quantity;
    if (maxQuantity != null) capped = math.min(capped, maxQuantity);
    final List<CartItemModel> updated = <CartItemModel>[...state];
    updated[index] = state[index].copyWith(quantity: capped);
    state = updated;
  }

  void clearCart() => state = const <CartItemModel>[];

  void _adjustQuantity(String productId, int delta, {int? maxQuantity}) {
    final int index =
        state.indexWhere((CartItemModel element) => element.productId == productId);
    if (index == -1) return;

    int newQuantity = state[index].quantity + delta;
    if (maxQuantity != null && delta > 0) {
      newQuantity = math.min(newQuantity, maxQuantity);
    }
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    if (newQuantity == state[index].quantity) return;

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
