import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException, QuerySnapshot, QueryDocumentSnapshot;

import '../config/firebase/firebase_bootstrap.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';

/// Accès aux catégories (`categories`).
class CategoryRepository {
  CategoryRepository(this._service);

  final FirestoreService _service;

  /// Écoute en temps réel des catégories actives, triées par [CategoryModel.sortOrder].
  ///
  /// En mode démonstration (Firebase absent), émet une liste vide. Le tri et
  /// le filtre « actif » sont appliqués côté client : les collections sont
  /// petites et cela évite tout index composite à configurer.
  Stream<List<CategoryModel>> watchActiveCategories() {
    if (!FirebaseBootstrap.isReady) {
      return Stream<List<CategoryModel>>.value(const <CategoryModel>[]);
    }
    return _service
        .collection(FirestoreCollections.categories)
        .snapshots()
        .map<List<CategoryModel>>(
      (QuerySnapshot<Map<String, dynamic>> snapshot) {
        final List<CategoryModel> categories = snapshot.docs
            .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
                CategoryModel.fromMap(doc.data(), id: doc.id))
            .where((CategoryModel category) => category.isActive)
            .toList()
          ..sort((CategoryModel a, CategoryModel b) =>
              a.sortOrder.compareTo(b.sortOrder));
        return categories;
      },
    );
  }

  /// Lecture ponctuelle de toutes les catégories actives.
  Future<List<CategoryModel>> fetchActiveCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _service.collection(FirestoreCollections.categories).get();
      final List<CategoryModel> categories = snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              CategoryModel.fromMap(doc.data(), id: doc.id))
          .where((CategoryModel category) => category.isActive)
          .toList()
        ..sort((CategoryModel a, CategoryModel b) =>
            a.sortOrder.compareTo(b.sortOrder));
      return categories;
    } on FirebaseException catch (error) {
      throw FirestoreException(error.code);
    }
  }
}
