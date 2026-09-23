import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/firebase_auth_service.dart';

/// Service d'authentification partagé (une seule instance).
final Provider<FirebaseAuthService> firebaseAuthServiceProvider =
    Provider<FirebaseAuthService>((Ref ref) => FirebaseAuthService());

/// État de connexion Firebase Auth : émission à chaque changement
/// (connexion, déconnexion, restauration de session).
final StreamProvider<User?> authStateProvider =
    StreamProvider<User?>((Ref ref) => ref.watch(firebaseAuthServiceProvider).authStateChanges);

/// Utilisateur courant (null si visiteur ou chargement en cours).
final Provider<User?> currentUserProvider =
    Provider<User?>((Ref ref) => ref.watch(authStateProvider).valueOrNull);

/// `true` si un utilisateur est connecté.
final Provider<bool> isAuthenticatedProvider =
    Provider<bool>((Ref ref) => ref.watch(currentUserProvider) != null);
