import 'package:firebase_auth/firebase_auth.dart'
    show FirebaseAuthException, User;

import '../core/constants/app_enums.dart';
import '../core/errors/app_exceptions.dart';
import '../models/user_model.dart';
import '../services/firebase_auth_service.dart';
import 'user_repository.dart';

/// Logique d'authentification : inscription avec rôle, connexion,
/// réinitialisation de mot de passe, déconnexion.
///
/// Toutes les erreurs techniques (Firebase, réseau) sont traduites en
/// [AppException] avec un message français prêt à afficher.
class AuthRepository {
  AuthRepository(this._authService, this._userRepository);

  final FirebaseAuthService _authService;
  final UserRepository _userRepository;

  /// Connexion email + mot de passe.
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _authService
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = credential.user;
      if (user == null) {
        throw const AuthException('Connexion impossible. Réessayez.');
      }
      return user;
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    }
  }

  /// Inscription complète :
  /// 1. création du compte Firebase Auth ;
  /// 2. enregistrement du nom affiché ;
  /// 3. création du document `users/{uid}` (rôle + WhatsApp si vendeur).
  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String whatsappNumber = '',
  }) async {
    try {
      final UserCredential credential = await _authService
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = credential.user;
      if (user == null) {
        throw const AuthException('Inscription impossible. Réessayez.');
      }

      await _authService.updateDisplayName(name);

      // Le profil Firestore ne doit jamais bloquer la création du compte :
      // en cas d'échec, le profil dérivé de l'utilisateur Firebase sert de
      // repli (rôle client par défaut).
      final UserModel profile = UserModel(
        id: user.uid,
        name: name,
        email: email,
        phone: phone,
        role: role,
        whatsappNumber: whatsappNumber,
        createdAt: DateTime.now(),
      );
      try {
        await _userRepository.createOrUpdateUser(profile);
      } on AppException catch (error) {
        assert(() {
          // ignore: avoid_print
          print('Profil non persisté (mode démonstration ?) : ${error.message}');
          return true;
        }());
      }

      return user;
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    }
  }

  /// Envoie l'email de réinitialisation du mot de passe.
  Future<void> sendPasswordReset({required String email}) async {
    try {
      await _authService.sendPasswordResetEmail(email);
    } on FirebaseAuthException catch (error) {
      throw _mapAuthError(error);
    }
  }

  /// Déconnecte l'utilisateur courant.
  Future<void> signOut() => _authService.signOut();

  /// Traduction des codes d'erreur Firebase Auth en messages lisibles.
  AuthException _mapAuthError(FirebaseAuthException error) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-login-credentials' =>
        const AuthException('Email ou mot de passe incorrect.'),
      'email-already-in-use' =>
        const AuthException('Un compte existe déjà avec cette adresse email.'),
      'weak-password' =>
        const AuthException('Le mot de passe est trop faible (6 caractères minimum).'),
      'invalid-email' =>
        const AuthException('Adresse email invalide.'),
      'user-disabled' =>
        const AuthException('Ce compte a été désactivé.'),
      'too-many-requests' =>
        const AuthException('Trop de tentatives. Réessayez dans quelques minutes.'),
      'network-request-failed' =>
        const NetworkException(),
      _ => AuthException('Authentification impossible. Réessayez.'),
    };
  }
}
