import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:taillorbook/core/constants/app_enums.dart';
import 'package:taillorbook/models/cart_item_model.dart';
import 'package:taillorbook/state/cart/cart_providers.dart';

CartItemModel _item(
  String id, {
  double price = 10,
  AppCurrency currency = AppCurrency.usd,
}) {
  return CartItemModel(
    productId: id,
    productName: 'Produit $id',
    imageUrl: 'https://i.ibb.co/demo/$id.jpg',
    sellerId: 'seller-1',
    sellerName: 'Boutique démo',
    sellerWhatsappNumber: '+25779000000',
    unitPrice: price,
    currency: currency,
  );
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() => container.dispose());

  test('le panier démarre vide', () {
    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartTotalItemsProvider), 0);
    expect(container.read(cartSubtotalProvider), 0.0);
    expect(container.read(cartCurrencyProvider), isNull);
  });

  test('ajouter deux fois le même produit augmente la quantité', () {
    container.read(cartProvider.notifier).addItem(_item('p1'));
    container.read(cartProvider.notifier).addItem(_item('p1'));

    final List<CartItemModel> items = container.read(cartProvider);
    expect(items.length, 1);
    expect(items.first.quantity, 2);
    expect(container.read(cartTotalItemsProvider), 2);
  });

  test('le sous-total calcule prix unitaire × quantité', () {
    container.read(cartProvider.notifier).addItem(_item('p1', price: 12.5));
    container.read(cartProvider.notifier).addItem(_item('p2', price: 5));

    expect(container.read(cartSubtotalProvider), 17.5);
    expect(container.read(cartCurrencyProvider), AppCurrency.usd);
  });

  test('augmenter puis diminuer la quantité', () {
    container.read(cartProvider.notifier).addItem(_item('p1'));
    container.read(cartProvider.notifier).increaseQuantity('p1');
    expect(container.read(cartProvider).first.quantity, 2);

    container.read(cartProvider.notifier).decreaseQuantity('p1');
    expect(container.read(cartProvider).first.quantity, 1);
  });

  test('diminuer à zéro retire la ligne', () {
    container.read(cartProvider.notifier).addItem(_item('p1'));
    container.read(cartProvider.notifier).decreaseQuantity('p1');

    expect(container.read(cartProvider), isEmpty);
  });

  test('setQuantity(0) retire la ligne', () {
    container.read(cartProvider.notifier).addItem(_item('p1'));
    container.read(cartProvider.notifier).setQuantity('p1', 0);

    expect(container.read(cartProvider), isEmpty);
  });

  test('removeItem supprime uniquement le produit ciblé', () {
    container.read(cartProvider.notifier).addItem(_item('p1'));
    container.read(cartProvider.notifier).addItem(_item('p2'));
    container.read(cartProvider.notifier).removeItem('p1');

    expect(
      container.read(cartProvider).map((CartItemModel e) => e.productId),
      <String>['p2'],
    );
  });

  test('clearCart vide tout le panier', () {
    container.read(cartProvider.notifier).addItem(_item('p1'));
    container.read(cartProvider.notifier).addItem(_item('p2'));
    container.read(cartProvider.notifier).clearCart();

    expect(container.read(cartProvider), isEmpty);
    expect(container.read(cartTotalItemsProvider), 0);
  });

  group('garde-fou de stock (maxQuantity)', () {
    test('refus d\'ajouter un produit en rupture (maxQuantity = 0)', () {
      container
          .read(cartProvider.notifier)
          .addItem(_item('p1'), maxQuantity: 0);

      expect(container.read(cartProvider), isEmpty);
    });

    test('l\'ajout est plafonné au stock disponible', () {
      container.read(cartProvider.notifier).addItem(
            _item('p1').copyWith(quantity: 99),
            maxQuantity: 5,
          );

      expect(container.read(cartProvider).first.quantity, 5);
    });

    test('l\'augmentation est plafonnée au stock disponible', () {
      container.read(cartProvider.notifier).addItem(_item('p1'), maxQuantity: 3);
      container.read(cartProvider.notifier).increaseQuantity('p1', maxQuantity: 3);
      container.read(cartProvider.notifier).increaseQuantity('p1', maxQuantity: 3);
      container.read(cartProvider.notifier).increaseQuantity('p1', maxQuantity: 3);

      expect(container.read(cartProvider).first.quantity, 3);
    });

    test('la baisse reste possible même au plafond', () {
      container.read(cartProvider.notifier).addItem(_item('p1'), maxQuantity: 2);
      container.read(cartProvider.notifier).decreaseQuantity('p1');

      expect(container.read(cartProvider).first.quantity, 1);
    });
  });
}
