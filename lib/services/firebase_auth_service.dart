import 'package:firebase_auth/firebase_auth.dart';

import '../config/firebase/firebase_bootstrap.dart';
import '../core/errors/app_exceptions.dart';

/// Enveloppe fine autour de FirebaseAuth — unique point d'accès à
/// l'authentification pour le reste de l'application.
///
/// Cette couche ne traduit pas les erreurs : les exceptions Firebase
/// brutes remontent au dépôt ([AuthRepository]) qui les convertit en
/// exceptions métier affichables.
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

  /// Connexion email + mot de passe.
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _requireFirebase().signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Création d'un compte email + mot de passe.
  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _requireFirebase().createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Met à jour le nom affiché du compte courant.
  Future<void> updateDisplayName(String displayName) async {
    final User? user = _requireFirebase().currentUser;
    if (user == null) {
      throw const AuthException('Aucun utilisateur connecté.');
    }
    await user.updateDisplayName(displayName);
    await user.reload();
  }

  /// Envoie l'email de réinitialisation du mot de passe.
  Future<void> sendPasswordResetEmail(String email) {
    return _requireFirebase().sendPasswordResetEmail(email: email);
  }

  /// Déconnecte l'utilisateur courant.
  Future<void> signOut() async {
    if (!FirebaseBootstrap.isReady) return;
    await _firebaseAuth.signOut();
  }

  FirebaseAuth _requireFirebase() {
    if (!FirebaseBootstrap.isReady) {
      throw const AuthException(
        "Firebase n'est pas configuré sur cette installation. Exécutez "
        '« flutterfire configure » puis redémarrez l\'application.',
      );
    }
    return _firebaseAuth;
  }
}
