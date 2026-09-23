import '../constants/app_enums.dart';
import '../../models/product_model.dart';
import 'currency_converter.dart';

/// Options de tri du catalogue.
enum ProductSortOption {
  newest('Plus récents'),
  priceAsc('Prix croissant'),
  priceDesc('Prix décroissant'),
  nameAsc('Nom (A → Z)'),
  discount('Meilleures promos');

  const ProductSortOption(this.label);

  final String label;
}

/// Filtres applicables au catalogue produits (recherche, catégorie,
/// vendeur, disponibilité, prix, tri).
///
/// Le filtrage est effectué côté client sur la liste des produits actifs :
/// simple, sans configuration d'index composite Firestore, et largement
/// suffisant pour le volume d'une marketplace de démonstration.
class ProductFilter {
  const ProductFilter({
    this.query = '',
    this.categoryId,
    this.sellerId,
    this.inStockOnly = false,
    this.minPriceUsd,
    this.maxPriceUsd,
    this.sort = ProductSortOption.newest,
  });

  /// Recherche plein texte insensible à la casse (nom, catégorie, vendeur).
  final String query;
  final String? categoryId;
  final String? sellerId;
  final bool inStockOnly;

  /// Bornes de prix exprimées en USD (devise de base) pour comparer les
  /// produits quelle que soit leur devise d'origine.
  final double? minPriceUsd;
  final double? maxPriceUsd;
  final ProductSortOption sort;

  ProductFilter copyWith({
    String? query,
    String? categoryId,
    String? sellerId,
    bool? inStockOnly,
    double? minPriceUsd,
    double? maxPriceUsd,
    ProductSortOption? sort,
  }) {
    return ProductFilter(
      query: query ?? this.query,
      categoryId: categoryId ?? this.categoryId,
      sellerId: sellerId ?? this.sellerId,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      minPriceUsd: minPriceUsd ?? this.minPriceUsd,
      maxPriceUsd: maxPriceUsd ?? this.maxPriceUsd,
      sort: sort ?? this.sort,
    );
  }

  double _priceInUsd(ProductModel product) =>
      CurrencyConverter.convert(product.price, product.currency, AppCurrency.usd);

  /// Applique l'ensemble des filtres et le tri à [products].
  List<ProductModel> apply(List<ProductModel> products) {
    final String normalizedQuery = query.trim().toLowerCase();

    final List<ProductModel> results = products.where((ProductModel product) {
      if (!product.isActive) return false;
      if (categoryId != null && product.categoryId != categoryId) return false;
      if (sellerId != null && product.sellerId != sellerId) return false;
      if (inStockOnly && !product.inStock) return false;

      if (normalizedQuery.isNotEmpty) {
        final String haystack =
            '${product.name} ${product.categoryName} ${product.sellerName}'
                .toLowerCase();
        if (!haystack.contains(normalizedQuery)) return false;
      }

      final double priceUsd = _priceInUsd(product);
      if (minPriceUsd != null && priceUsd < minPriceUsd!) return false;
      if (maxPriceUsd != null && priceUsd > maxPriceUsd!) return false;

      return true;
    }).toList();

    switch (sort) {
      case ProductSortOption.newest:
        results.sort((ProductModel a, ProductModel b) =>
            (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
        break;
      case ProductSortOption.priceAsc:
        results.sort(
            (ProductModel a, ProductModel b) => _priceInUsd(a).compareTo(_priceInUsd(b)));
        break;
      case ProductSortOption.priceDesc:
        results.sort(
            (ProductModel a, ProductModel b) => _priceInUsd(b).compareTo(_priceInUsd(a)));
        break;
      case ProductSortOption.nameAsc:
        results.sort((ProductModel a, ProductModel b) =>
            a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case ProductSortOption.discount:
        results.sort((ProductModel a, ProductModel b) {
          final int byDiscount = b.discountPercentage.compareTo(a.discountPercentage);
          if (byDiscount != 0) return byDiscount;
          return (b.createdAt ?? DateTime(1970))
              .compareTo(a.createdAt ?? DateTime(1970));
        });
        break;
    }

    return results;
  }
}
