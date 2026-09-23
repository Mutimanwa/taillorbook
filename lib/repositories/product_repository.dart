import 'package:cloud_firestore/cloud_firestore.dart'
    show FirebaseException, QueryDocumentSnapshot, QuerySnapshot;

import '../config/firebase/firebase_bootstrap.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

/// Accès aux produits (`products`).
///
/// Phase 3 : méthodes de lecture (catalogue public). Les méthodes d'écriture
/// (création, modification, suppression par le vendeur) sont ajoutées à la
/// phase « Espace vendeur » sur ce même dépôt.
class ProductRepository {
  ProductRepository(this._service);

  final FirestoreService _service;

  /// Écoute en temps réel de tous les produits actifs.
  ///
  /// En mode démonstration (Firebase absent), émet une liste vide. Le filtre
  /// « actif » est appliqué côté client pour éviter un index composite
  /// (where + orderBy) à créer manuellement dans la console Firebase.
  Stream<List<ProductModel>> watchActiveProducts() {
    if (!FirebaseBootstrap.isReady) {
      return Stream<List<ProductModel>>.value(const <ProductModel>[]);
    }
    return _service
        .collection(FirestoreCollections.products)
        .snapshots()
        .map<List<ProductModel>>(_mapActiveProducts);
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
      throw FirestoreException(code: error.code);
    }
  }

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
