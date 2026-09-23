import 'package:flutter_test/flutter_test.dart';

import 'package:taillorbook/core/constants/app_enums.dart';
import 'package:taillorbook/models/cart_item_model.dart';
import 'package:taillorbook/models/product_model.dart';

ProductModel _product({
  double price = 20,
  double? oldPrice,
  AppCurrency currency = AppCurrency.usd,
  int stock = 10,
}) {
  return ProductModel(
    id: 'p1',
    name: 'Produit test',
    description: 'Description',
    price: price,
    oldPrice: oldPrice,
    currency: currency,
    categoryId: 'cat',
    categoryName: 'Catégorie',
    stock: stock,
    imageUrl: 'https://i.ibb.co/demo.jpg',
    sellerId: 'seller-1',
    sellerName: 'Boutique',
    sellerWhatsappNumber: '+25779000000',
  );
}

void main() {
  group('ProductModel sérialisation', () {
    test('toMap → fromMap conserve toutes les données', () {
      final ProductModel product = _product(oldPrice: 30);

      final Map<String, dynamic> map = product.toMap();
      final ProductModel decoded = ProductModel.fromMap(map, id: 'p1');

      expect(decoded.id, 'p1');
      expect(decoded.name, 'Produit test');
      expect(decoded.price, 20);
      expect(decoded.oldPrice, 30);
      expect(decoded.currency, AppCurrency.usd);
      expect(decoded.stock, 10);
      expect(decoded.sellerWhatsappNumber, '+25779000000');
      expect(decoded.isActive, isTrue);
    });

    test('fromMap tolère les valeurs manquantes', () {
      final ProductModel decoded = ProductModel.fromMap(
        <String, dynamic>{'name': 'Minimal'},
        id: 'p2',
      );

      expect(decoded.price, 0);
      expect(decoded.currency, AppCurrency.usd);
      expect(decoded.stock, 0);
      expect(decoded.inStock, isFalse);
      expect(decoded.isActive, isTrue);
    });
  });

  group('Promotions & stock', () {
    test('a une réduction uniquement si oldPrice > price', () {
      expect(_product(price: 20, oldPrice: 30).hasDiscount, isTrue);
      expect(_product(price: 30, oldPrice: 30).hasDiscount, isFalse);
      expect(_product(price: 35, oldPrice: 30).hasDiscount, isFalse);
      expect(_product().hasDiscount, isFalse);
    });

    test('calcule le pourcentage de réduction', () {
      expect(_product(price: 45, oldPrice: 60).discountPercentage, 25);
      expect(_product().discountPercentage, 0);
    });

    test('détecte le stock faible', () {
      expect(_product(stock: 3).isLowStock, isTrue);
      expect(_product(stock: 50).isLowStock, isFalse);
      expect(_product(stock: 0).isLowStock, isFalse);
      expect(_product(stock: 0).inStock, isFalse);
    });
  });

  group('Conversion multi-devises', () {
    test('convertit via la devise de base (USD)', () {
      // 10 USD ≈ 29 411 FBu au taux de démonstration.
      final double bif = _product(price: 10).priceIn(AppCurrency.bif);
      expect(bif, closeTo(10 / 0.00034, 0.5));

      // 10 USD → EUR : 10 / 1.08.
      final double eur = _product(price: 10).priceIn(AppCurrency.eur);
      expect(eur, closeTo(10 / 1.08, 0.0001));
    });

    test('la conversion est symétrique (aller-retour)', () {
      const double original = 33.33;
      final double usd = CurrencyRoundtripHelper.toUsd(original);
      expect(usd, closeTo(original, 0.001));
    });
  });

  group('toCartItem', () {
    test('produit une ligne de panier fidèle', () {
      final CartItemModel item = _product().toCartItem(quantity: 2);

      expect(item.productId, 'p1');
      expect(item.productName, 'Produit test');
      expect(item.unitPrice, 20);
      expect(item.currency, AppCurrency.usd);
      expect(item.quantity, 2);
      expect(item.sellerId, 'seller-1');
      expect(item.lineTotal, 40);
    });
  });
}
