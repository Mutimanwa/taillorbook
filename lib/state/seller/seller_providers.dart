import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/product_model.dart';
import '../../models/user_model.dart';
import '../../repositories/product_repository.dart';
import '../../services/imgbb_service.dart';
import '../auth/auth_providers.dart'
    show currentUserProvider, firestoreServiceProvider, userProfileProvider;

// ---------------------------------------------------------------------------
// Dépôts & services
// ---------------------------------------------------------------------------

/// Dépôt des produits (lecture + écritures vendeur).
final Provider<ProductRepository> productRepositoryProvider =
    Provider<ProductRepository>(
        (Ref ref) => ProductRepository(ref.watch(firestoreServiceProvider)));

/// Service d'upload d'images ImgBB (une seule instance).
final Provider<ImgbbService> imgbbServiceProvider =
    Provider<ImgbbService>((Ref ref) => ImgbbService());

// ---------------------------------------------------------------------------
// Vendeur courant & ses produits
// ---------------------------------------------------------------------------

/// Identifiant du vendeur connecté, ou `null` si visiteur/client.
final Provider<String?> currentSellerIdProvider = Provider<String?>((Ref ref) {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final String? role = ref.watch(userProfileProvider).valueOrNull?.role.name;
  if (role != UserRole.seller.name) return null;
  return user.uid;
});

/// `true` si l'utilisateur connecté possède le rôle vendeur.
final Provider<bool> isSellerProvider =
    Provider<bool>((Ref ref) => ref.watch(currentSellerIdProvider) != null);

/// Produits du vendeur courant (temps réel, actifs et désactivés).
/// Émet `null` hors contexte vendeur (visiteur ou rôle client).
final StreamProvider<List<ProductModel>?> sellerProductsProvider =
    StreamProvider<List<ProductModel>?>((Ref ref) {
  final String? sellerId = ref.watch(currentSellerIdProvider);
  if (sellerId == null) return Stream<List<ProductModel>?>.value(null);
  return ref.watch(productRepositoryProvider).watchSellerProducts(sellerId);
});

// ---------------------------------------------------------------------------
// Statistiques du dashboard vendeur
// ---------------------------------------------------------------------------

/// Statistiques dérivées des produits du vendeur.
///
/// Les ventes/commandes sont ajoutées à la phase « Commandes » ; le champ
/// [orders] reste à 0 en attendant.
class SellerStats {
  const SellerStats({
    required this.total,
    required this.active,
    required this.lowStock,
    required this.outOfStock,
    this.orders = 0,
  });

  const SellerStats.empty()
      : total = 0,
        active = 0,
        lowStock = 0,
        outOfStock = 0,
        orders = 0;

  final int total;
  final int active;
  final int lowStock;
  final int outOfStock;
  final int orders;

  factory SellerStats.fromProducts(List<ProductModel> products) {
    int active = 0;
    int lowStock = 0;
    int outOfStock = 0;
    for (final ProductModel product in products) {
      if (product.isActive) active++;
      if (!product.inStock) {
        outOfStock++;
      } else if (product.isLowStock) {
        lowStock++;
      }
    }
    return SellerStats(
      total: products.length,
      active: active,
      lowStock: lowStock,
      outOfStock: outOfStock,
    );
  }
}

/// Statistiques du vendeur courant (calcul pur, testé).
final Provider<SellerStats> sellerStatsProvider =
    Provider<SellerStats>((Ref ref) {
  final List<ProductModel>? products =
      ref.watch(sellerProductsProvider).valueOrNull;
  if (products == null) return const SellerStats.empty();
  return SellerStats.fromProducts(products);
});

// ---------------------------------------------------------------------------
// Garde de propriété (pur, testé — doublé par les règles Firestore)
// ---------------------------------------------------------------------------

/// `true` si l'utilisateur courant peut gérer (modifier/supprimer) ce produit :
/// il doit être vendeur connecté et propriétaire du produit.
bool canManageProduct({
  required User? user,
  required UserModel? profile,
  required ProductModel product,
}) {
  if (user == null || profile == null) return false;
  if (profile.role != UserRole.seller) return false;
  return product.sellerId == user.uid;
}

// ---------------------------------------------------------------------------
// Contrôleur des actions vendeur
// ---------------------------------------------------------------------------

/// Contrôleur des écritures produit (créer, modifier, supprimer, activer).
///
/// Chaque action vérifie : utilisateur connecté + rôle vendeur + propriété
/// du produit (pour les actions sur un produit existant), puis délègue au
/// dépôt. L'état [AsyncValue] expose loading et erreurs aux écrans.
class SellerProductController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  /// Crée un produit à partir du formulaire. Renvoie `true` en cas de succès.
  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    required AppCurrency currency,
    required String categoryId,
    required String categoryName,
    required int stock,
    required String imageUrl,
    double? oldPrice,
  }) async {
    final AppException? guardError = _guardSeller();
    if (guardError != null) {
      state = AsyncValue<void>.error(guardError, StackTrace.empty);
      return false;
    }

    state = const AsyncValue<void>.loading();
    final AsyncValue<void> result = await AsyncValue.guard<void>(() async {
      final User user = ref.read(currentUserProvider)!;
      final UserModel profile = ref.read(userProfileProvider).valueOrNull ??
          _fallbackSellerProfile(user);
      final DateTime now = DateTime.now();

      await ref.read(productRepositoryProvider).createProduct(
            ProductModel(
              id: '',
              name: name,
              description: description,
              price: price,
              oldPrice: oldPrice,
              currency: currency,
              categoryId: categoryId,
              categoryName: categoryName,
              stock: stock,
              imageUrl: imageUrl,
              sellerId: user.uid,
              sellerName:
                  profile.name.isNotEmpty ? profile.name : user.displayName ?? '',
              sellerWhatsappNumber: profile.whatsappNumber,
              isActive: true,
              createdAt: now,
              updatedAt: now,
            ),
          );
    });
    state = result.hasError ? result : const AsyncValue<void>.data(null);
    return !result.hasError;
  }

  /// Met à jour un produit existant après vérification de propriété.
  Future<bool> updateProduct(ProductModel product) async {
    final AppException? guardError = _guardSeller();
    if (guardError != null) {
      state = AsyncValue<void>.error(guardError, StackTrace.empty);
      return false;
    }
    if (!_owns(ref, product)) {
      state = AsyncValue<void>.error(
        const UnauthorizedException(
          message: 'Vous ne pouvez modifier que vos propres produits.',
        ),
        StackTrace.empty,
      );
      return false;
    }

    state = const AsyncValue<void>.loading();
    final AsyncValue<void> result = await AsyncValue.guard<void>(() async {
      await ref
          .read(productRepositoryProvider)
          .updateProduct(product.copyWith(updatedAt: DateTime.now()));
    });
    state = result.hasError ? result : const AsyncValue<void>.data(null);
    return !result.hasError;
  }

  /// Active/désactive un produit (après vérification de propriété).
  Future<bool> setProductActive(ProductModel product,
      {required bool isActive}) async {
    if (!_owns(ref, product)) {
      state = AsyncValue<void>.error(
        const UnauthorizedException(
          message: 'Vous ne pouvez gérer que vos propres produits.',
        ),
        StackTrace.empty,
      );
      return false;
    }
    state = const AsyncValue<void>.loading();
    final AsyncValue<void> result = await AsyncValue.guard<void>(() async {
      await ref
          .read(productRepositoryProvider)
          .setProductActive(product.id, isActive: isActive);
    });
    state = result.hasError ? result : const AsyncValue<void>.data(null);
    return !result.hasError;
  }

  /// Supprime un produit (après vérification de propriété).
  Future<bool> deleteProduct(ProductModel product) async {
    if (!_owns(ref, product)) {
      state = AsyncValue<void>.error(
        const UnauthorizedException(
          message: 'Vous ne pouvez supprimer que vos propres produits.',
        ),
        StackTrace.empty,
      );
      return false;
    }
    state = const AsyncValue<void>.loading();
    final AsyncValue<void> result = await AsyncValue.guard<void>(() async {
      await ref.read(productRepositoryProvider).deleteProduct(product.id);
    });
    state = result.hasError ? result : const AsyncValue<void>.data(null);
    return !result.hasError;
  }

  // ----------------------------------------------------------------- privé

  /// Vérifie connexion + rôle vendeur. Renvoie l'erreur le cas échéant.
  AppException? _guardSeller() {
    final User? user = ref.read(currentUserProvider);
    if (user == null) {
      return const UnauthorizedException();
    }
    final UserModel? profile = ref.read(userProfileProvider).valueOrNull;
    if (profile == null || profile.role != UserRole.seller) {
      return const UnauthorizedException(
        message: 'Espace réservé aux comptes vendeurs.',
      );
    }
    return null;
  }

  /// Profil de repli si le document Firestore n'est pas encore chargé.
  static UserModel _fallbackSellerProfile(User user) {
    return UserModel(
      id: user.uid,
      name: user.displayName ?? '',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      role: UserRole.seller,
    );
  }
}

/// Vérification de propriété basée sur l'état courant des providers.
bool _owns(Ref ref, ProductModel product) {
  return canManageProduct(
    user: ref.read(currentUserProvider),
    profile: ref.read(userProfileProvider).valueOrNull,
    product: product,
  );
}

final NotifierProvider<SellerProductController, AsyncValue<void>>
    sellerProductControllerProvider =
    NotifierProvider<SellerProductController, AsyncValue<void>>(
        SellerProductController.new);

/// Message d'erreur lisible d'un état d'écriture produit en erreur.
String? sellerProductErrorMessage(AsyncValue<void> state) {
  if (!state.hasError) return null;
  final Object? error = state.error;
  if (error is AppException) return error.message;
  return 'Une erreur inattendue est survenue. Réessayez.';
}