import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../repositories/category_repository.dart';
import '../../repositories/product_repository.dart';
import '../auth/auth_providers.dart' show firestoreServiceProvider;

// ---------------------------------------------------------------------------
// Dépôts
// ---------------------------------------------------------------------------

/// Dépôt des catégories.
final Provider<CategoryRepository> categoryRepositoryProvider =
    Provider<CategoryRepository>(
        (Ref ref) => CategoryRepository(ref.watch(firestoreServiceProvider)));

/// Dépôt des produits.
final Provider<ProductRepository> productRepositoryProvider =
    Provider<ProductRepository>(
        (Ref ref) => ProductRepository(ref.watch(firestoreServiceProvider)));

// ---------------------------------------------------------------------------
// Catalogue public
// ---------------------------------------------------------------------------

/// Catégories actives (temps réel, triées par [CategoryModel.sortOrder]).
final StreamProvider<List<CategoryModel>> categoriesProvider =
    StreamProvider<List<CategoryModel>>(
        (Ref ref) => ref.watch(categoryRepositoryProvider).watchActiveCategories());

/// Produits actifs (temps réel). Le filtrage/tri fin est appliqué par
/// [ProductFilter] dans les écrans.
final StreamProvider<List<ProductModel>> activeProductsProvider =
    StreamProvider<List<ProductModel>>(
        (Ref ref) => ref.watch(productRepositoryProvider).watchActiveProducts());

/// Produit par identifiant (temps réel, auto-disposé quand plus écouté).
final AutoDisposeStreamProviderFamily<ProductModel?, String> productByIdProvider =
    StreamProvider.autoDispose.family<ProductModel?, String>(
        (Ref ref, String productId) =>
            ref.watch(productRepositoryProvider).watchProduct(productId));

/// Nombre de produits actifs par catégorie (badge des cartes de catégories).
final Provider<Map<String, int>> productCountByCategoryProvider =
    Provider<Map<String, int>>((Ref ref) {
  final List<ProductModel> products = ref.watch(activeProductsProvider).valueOrNull ??
      const <ProductModel>[];
  final Map<String, int> counts = <String, int>{};
  for (final ProductModel product in products) {
    counts[product.categoryId] = (counts[product.categoryId] ?? 0) + 1;
  }
  return counts;
});
