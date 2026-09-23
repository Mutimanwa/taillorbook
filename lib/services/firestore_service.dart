import 'package:cloud_firestore/cloud_firestore.dart';

import '../config/firebase/firebase_bootstrap.dart';
import '../core/errors/app_exceptions.dart';

/// Enveloppe fine autour de Cloud Firestore — unique point d'accès à la base
/// pour les dépôts. Lève une [FirestoreException] claire si Firebase n'a pas
/// pu être initialisé (mode démonstration).
class FirestoreService {
  FirebaseFirestore get instance {
    if (!FirebaseBootstrap.isReady) {
      throw const FirestoreException(
        "Firebase n'est pas configuré sur cette installation. Exécutez "
        '« flutterfire configure » puis redémarrez l\'application.',
      );
    }
    return FirebaseFirestore.instance;
  }

  /// Référence typée vers une collection.
  CollectionReference<Map<String, dynamic>> collection(String path) =>
      instance.collection(path);

  /// Référence typée vers un document.
  DocumentReference<Map<String, dynamic>> document(String path) =>
      instance.doc(path);
}
