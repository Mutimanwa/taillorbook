import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException, QueryDocumentSnapshot, QuerySnapshot, DocumentSnapshot, DocumentReference;

import '../config/firebase/firebase_bootstrap.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

/// Accès aux produits (`products`).
///
/// Lecture : catalogue public (temps réel) + produits d'un vendeur.
/// Écriture : réservée aux vendeurs (création, mise à jour, suppression,
/// activation) — la propriété est vérifiée par le contrôleur côté
/// application ET par les règles Firestore côté base (phase Sécurité).
class ProductRepository {
  ProductRepository(this._service);

  final FirestoreService _service;

  // ---------------------------------------------------------------- lecture

  /// Écoute en temps réel de tous les produits actifs (catalogue public).
  ///
  /// En mode démonstration (Firebase absent), émet une liste vide.
  ///
  /// ⚠️ La requête explicite `where('isActive', '==', true)` n'est pas une
  /// optimisation : les règles Firestore (`firestore.rules`) n'autorisent la
  /// lecture publique que des produits actifs, et les règles ne sont PAS des
  /// filtres — sans cette clause, la requête serait rejetée (permission-
  /// denied) dès qu'un produit désactivé existerait. Index d'égalité simple :
  /// créé automatiquement par Firestore.
  Stream<List<ProductModel>> watchActiveProducts() {
    if (!FirebaseBootstrap.isReady) {
      return Stream<List<ProductModel>>.value(const <ProductModel>[]);
    }
    return _service
        .collection(FirestoreCollections.products)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map<List<ProductModel>>(_mapActiveProducts);
  }

  /// Écoute en temps réel des produits d'un vendeur (tous, actifs ou non).
  ///
  /// Filtre d'égalité simple : aucun index composite requis.
  Stream<List<ProductModel>> watchSellerProducts(String sellerId) {
    if (!FirebaseBootstrap.isReady) {
      return Stream<List<ProductModel>>.value(const <ProductModel>[]);
    }
    return _service
        .collection(FirestoreCollections.products)
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map<List<ProductModel>>(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final List<ProductModel> products = snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                ProductModel.fromMap(doc.data(), id: doc.id))
            .toList();
        // Tri client : plus récents d'abord.
        products.sort((ProductModel a, ProductModel b) =>
            (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
        return products;
      },
    );
  }

  /// Écoute en temps réel d'un produit précis (fiche produit).
  /// Émet `null` si le document n'existe pas.
  Stream<ProductModel?> watchProduct(String productId) {
    if (!FirebaseBootstrap.isReady) {
      return Stream<ProductModel?>.value(null);
    }
    return _service
        .document('${FirestoreCollections.products}/$productId')
        .snapshots()
        .map<ProductModel?>(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) =>
          snapshot.exists && snapshot.data() != null
              ? ProductModel.fromMap(snapshot.data()!, id: snapshot.id)
              : null,
    );
  }

  /// Lecture ponctuelle d'un produit (null si absent).
  Future<ProductModel?> fetchProduct(String productId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _service
          .document('${FirestoreCollections.products}/$productId')
          .get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return ProductModel.fromMap(snapshot.data()!, id: snapshot.id);
    } on FirebaseException catch (error) {
      throw FirestoreException( error.code);
    }
  }

  // --------------------------------------------------------------- écriture

  /// Crée un produit (l'identifiant est généré par Firestore) et renvoie
  /// l'identifiant créé. Réservé aux vendeurs (vérifié aussi par les règles).
  Future<String> createProduct(ProductModel product) async {
    try {
      final DocumentReference<Map<String, dynamic>> reference =
          _service.collection(FirestoreCollections.products).doc();
      await reference.set(product.toMap());
      return reference.id;
    } on FirebaseException catch (error) {
      throw FirestoreException( error.code);
    }
  }

  /// Remplace intégralement un produit existant.
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _service
          .document('${FirestoreCollections.products}/${product.id}')
          .set(product.toMap());
    } on FirebaseException catch (error) {
      throw FirestoreException( error.code);
    }
  }

  /// Active ou désactive un produit sans le réécrire entièrement.
  Future<void> setProductActive(
    String productId, {
    required bool isActive,
  }) async {
    try {
      await _service
          .document('${FirestoreCollections.products}/$productId')
          .update(<String, dynamic>{
        'isActive': isActive,
        'updatedAt': DateTime.now(),
      });
    } on FirebaseException catch (error) {
      throw FirestoreException( error.code);
    }
  }

  /// Supprime définitivement un produit.
  Future<void> deleteProduct(String productId) async {
    try {
      await _service
          .document('${FirestoreCollections.products}/$productId')
          .delete();
    } on FirebaseException catch (error) {
      throw FirestoreException( error.code);
    }
  }

  // ----------------------------------------------------------------- privé

  List<ProductModel> _mapActiveProducts(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
            ProductModel.fromMap(doc.data(), id: doc.id))
        .where((ProductModel product) => product.isActive)
        .toList();
  }
}