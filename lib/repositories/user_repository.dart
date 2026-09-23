import 'package:cloud_firestore/cloud_firestore.dart' show FieldValue;

import '../config/firebase/firebase_bootstrap.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

/// Accès aux profils utilisateurs (`users/{uid}`).
class UserRepository {
  UserRepository(this._service);

  final FirestoreService _service;

  CollectionReference<Map<String, dynamic>> get _users =>
      _service.collection(FirestoreCollections.users);

  /// Écrit (ou met à jour) le profil de l'utilisateur.
  ///
  /// Si `createdAt` est absent du modèle, un timestamp serveur est utilisé.
  Future<void> createOrUpdateUser(UserModel user) async {
    try {
      final Map<String, dynamic> data = user.toMap();
      if (user.createdAt == null) data['createdAt'] = FieldValue.serverTimestamp();
      await _users.doc(user.id).set(data, SetOptions(merge: true));
    } on FirebaseException catch (error) {
      throw FirestoreException(code: error.code);
    }
  }

  /// Écoute en temps réel du profil. Émet `null` si le document n'existe pas.
  Stream<UserModel?> watchUser(String uid) {
    if (!FirebaseBootstrap.isReady) return Stream<UserModel?>.value(null);
    return _users.doc(uid).snapshots().map<UserModel?>(
          (DocumentSnapshot<Map<String, dynamic>> snapshot) =>
              snapshot.exists && snapshot.data() != null
                  ? UserModel.fromMap(snapshot.data()!, id: uid)
                  : null,
        );
  }

  /// Lecture ponctuelle du profil (null si absent).
  Future<UserModel?> fetchUser(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await _users.doc(uid).get();
      if (!snapshot.exists || snapshot.data() == null) return null;
      return UserModel.fromMap(snapshot.data()!, id: uid);
    } on FirebaseException catch (error) {
      throw FirestoreException(code: error.code);
    }
  }
}
