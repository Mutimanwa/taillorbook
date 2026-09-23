import 'package:flutter_test/flutter_test.dart';

import 'package:taillorbook/core/constants/app_enums.dart';
import 'package:taillorbook/core/utils/product_filters.dart';
import 'package:taillorbook/models/product_model.dart';

ProductModel _product(
  String id, {
  String name = 'Produit',
  double price = 10,
  AppCurrency currency = AppCurrency.usd,
  String categoryId = 'cat-1',
  String categoryName = 'Catégorie 1',
  String sellerName = 'Vendeur A',
  int stock = 5,
  DateTime? createdAt,
  double? oldPrice,
}) {
  return ProductModel(
    id: id,
    name: name,
    description: 'Description $id',
    price: price,
    oldPrice: oldPrice,
    currency: currency,
    categoryId: categoryId,
    categoryName: categoryName,
    stock: stock,
    imageUrl: 'https://i.ibb.co/$id.jpg',
    sellerId: 'seller-$sellerName',
    sellerName: sellerName,
    sellerWhatsappNumber: '+25779000000',
    createdAt: createdAt ?? DateTime(2026, 1, 1),
  );
}

void main() {
  final List<ProductModel> catalogue = <ProductModel>[
    _product('p1', name: 'Robe kitenge', price: 45, createdAt: DateTime(2026, 1, 5)),
    _product('p2', name: 'T-shirt coton', price: 12, stock: 0,
        createdAt: DateTime(2026, 1, 8)),
    _product('p3', name: 'Café arabica', price: 9500, currency: AppCurrency.bif,
        categoryId: 'cat-2', categoryName: 'Alimentation',
        sellerName: 'Vendeur B', createdAt: DateTime(2026, 1, 10)),
    _product('p4', name: 'Lampe solaire', price: 18,
        createdAt: DateTime(2026, 1, 3), oldPrice: 30),
  ];

  group('ProductFilter.recherche', () {
    test('insensible à la casse sur le nom', () {
      final List<ProductModel> results = const ProductFilter(query: 'ROBE').apply(catalogue);
      expect(results.map((ProductModel p) => p.id), <String>['p1']);
    });

    test('inclut le nom de catégorie et le vendeur', () {
      expect(
        const ProductFilter(query: 'alimentation').apply(catalogue).map((ProductModel p) => p.id),
        <String>['p3'],
      );
      expect(
        const ProductFilter(query: 'vendeur b').apply(catalogue).map((ProductModel p) => p.id),
        <String>['p3'],
      );
    });
  });

  group('ProductFilter.catégorie, vendeur et stock', () {
    test('filtre par catégorie', () {
      final List<ProductModel> results = const ProductFilter(categoryId: 'cat-2').apply(catalogue);
      expect(results.map((ProductModel p) => p.id), <String>['p3']);
    });

    test('inStockOnly exclut les ruptures', () {
      final List<ProductModel> results =
          const ProductFilter(inStockOnly: true).apply(catalogue);
      expect(results, isNot(contains('p2'.asProductMatcher())));
      expect(results.length, 3);
    });
  });

  group('ProductFilter.tri', () {
    test('nouveautés : plus récent d\'abord', () {
      final List<ProductModel> results =
          const ProductFilter(sort: ProductSortOption.newest).apply(catalogue);
      expect(results.first.id, 'p3');
    });

    test('prix croissant compare toutes les devises (BIF inclus)', () {
      final List<ProductModel> results =
          const ProductFilter(sort: ProductSortOption.priceAsc).apply(catalogue);
      // p3 (9 500 FBu ≈ 3,2 USD) est moins cher que p2 (12 USD).
      expect(results.first.id, 'p3');
      expect(results.last.id, 'p1');
    });

    test('prix décroissant : inverse du croissant', () {
      final List<ProductModel> results =
          const ProductFilter(sort: ProductSortOption.priceDesc).apply(catalogue);
      expect(results.first.id, 'p1');
    });

    test('meilleures promos : p4 (-40 %) en premier', () {
      final List<ProductModel> results =
          const ProductFilter(sort: ProductSortOption.discount).apply(catalogue);
      expect(results.first.id, 'p4');
    });
  });
}
