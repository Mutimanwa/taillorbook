import 'package:firebase_auth/firebase_auth.dart';

import '../config/firebase/firebase_bootstrap.dart';

/// Enveloppe fine autour de FirebaseAuth — unique point d'accès à
/// l'authentification pour le reste de l'application.
///
/// Les méthodes métier complètes (inscription avec rôle, connexion, réinitialisation
/// de mot de passe, profil Firestore) seront ajoutées lors de la phase
/// « Authentification & rôles » ; l'API de base ci-dessous restera stable.
class FirebaseAuthService {
  FirebaseAuth get _firebaseAuth => FirebaseAuth.instance;

  /// Flux de l'état de connexion (émission à chaque connexion/déconnexion).
  ///
  /// En mode démonstration (Firebase non configuré), émet un utilisateur nul
  /// afin de permettre la navigation invitée sans erreur.
  Stream<User?> get authStateChanges {
    if (!FirebaseBootstrap.isReady) return Stream<User?>.value(null);
    return _firebaseAuth.authStateChanges();
  }

  /// Utilisateur actuellement connecté (null si visiteur).
  User? get currentUser {
    if (!FirebaseBootstrap.isReady) return null;
    return _firebaseAuth.currentUser;
  }

  /// Déconnecte l'utilisateur courant.
  Future<void> signOut() async {
    if (!FirebaseBootstrap.isReady) return;
    await _firebaseAuth.signOut();
  }
}
