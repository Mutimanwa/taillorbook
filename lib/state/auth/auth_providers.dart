import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/user_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firestore_service.dart';

// ---------------------------------------------------------------------------
// Dépendances (services & dépôts)
// ---------------------------------------------------------------------------

/// Service d'authentification Firebase (une seule instance).
final Provider<FirebaseAuthService> firebaseAuthServiceProvider =
    Provider<FirebaseAuthService>((Ref ref) => FirebaseAuthService());

/// Service Firestore partagé.
final Provider<FirestoreService> firestoreServiceProvider =
    Provider<FirestoreService>((Ref ref) => FirestoreService());

/// Dépôt des profils utilisateurs.
final Provider<UserRepository> userRepositoryProvider = Provider<UserRepository>(
    (Ref ref) => UserRepository(ref.watch(firestoreServiceProvider)));

/// Dépôt d'authentification.
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
    (Ref ref) => AuthRepository(
          ref.watch(firebaseAuthServiceProvider),
          ref.watch(userRepositoryProvider),
        ));

// ---------------------------------------------------------------------------
// État de connexion
// ---------------------------------------------------------------------------

/// État de connexion Firebase Auth : émission à chaque changement
/// (connexion, déconnexion, restauration de session au démarrage).
final StreamProvider<User?> authStateProvider =
    StreamProvider<User?>((Ref ref) => ref.watch(firebaseAuthServiceProvider).authStateChanges);

/// Utilisateur courant (null si visiteur ou chargement en cours).
final Provider<User?> currentUserProvider =
    Provider<User?>((Ref ref) => ref.watch(authStateProvider).valueOrNull);

/// `true` si un utilisateur est connecté.
final Provider<bool> isAuthenticatedProvider =
    Provider<bool>((Ref ref) => ref.watch(currentUserProvider) != null);

/// Profil Firestore de l'utilisateur courant (rôle, WhatsApp...).
///
/// Si le document `users/{uid}` n'existe pas encore, un profil dérivé du
/// compte Firebase est fourni en repli (rôle client).
final StreamProvider<UserModel?> userProfileProvider =
    StreamProvider<UserModel?>((Ref ref) {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) return const Stream<UserModel?>.empty();
  return ref
      .watch(userRepositoryProvider)
      .watchUser(user.uid)
      .map<UserModel?>((UserModel? model) => model ?? _fallbackProfile(user));
});

/// Profil de repli dérivé du compte Firebase si le document Firestore
/// `users/{uid}` n'est pas encore disponible (rôle client par défaut).
UserModel _fallbackProfile(User user) {
  return UserModel(
    id: user.uid,
    name: user.displayName ?? '',
    email: user.email ?? '',
    phone: user.phoneNumber ?? '',
  );
}

// ---------------------------------------------------------------------------
// Actions d'authentification (contrôleur)
// ---------------------------------------------------------------------------

/// Contrôleur des formulaires d'authentification : expose les actions
/// (connexion, inscription, reset, déconnexion) avec un état [AsyncValue]
/// que les écrans écoutent pour afficher loading et erreurs.
class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue<void>.data(null);

  /// Connexion. Renvoie `true` en cas de succès.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue<void>.loading();
    final AsyncValue<void> result = await AsyncValue<void>.guard(() async {
      await ref
          .read(authRepositoryProvider)
          .signIn(email: email, password: password);
    });
    state = result.hasError ? result : const AsyncValue<void>.data(null);
    return !result.hasError;
  }

  /// Inscription avec choix du rôle. Renvoie `true` en cas de succès.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String phone,
    required UserRole role,
    String whatsappNumber = '',
  }) async {
    state = const AsyncValue<void>.loading();
    final AsyncValue<void> result = await AsyncValue<void>.guard(() async {
      await ref.read(authRepositoryProvider).register(
            name: name,
            email: email,
            password: password,
            phone: phone,
            role: role,
            whatsappNumber: whatsappNumber,
          );
    });
    state = result.hasError ? result : const AsyncValue<void>.data(null);
    return !result.hasError;
  }

  /// Envoie l'email de réinitialisation. Renvoie `true` en cas de succès.
  Future<bool> sendPasswordReset({required String email}) async {
    state = const AsyncValue<void>.loading();
    final AsyncValue<void> result = await AsyncValue<void>.guard(() async {
      await ref.read(authRepositoryProvider).sendPasswordReset(email: email);
    });
    state = result.hasError ? result : const AsyncValue<void>.data(null);
    return !result.hasError;
  }

  /// Déconnecte l'utilisateur courant (erreurs ignorées : la session locale
  /// est conservée en repli).
  Future<void> signOut() async {
    try {
      await ref.read(authRepositoryProvider).signOut();
    } on AppException {
      // Même en cas d'échec réseau, Firebase Auth conserve une session locale
      // invalide : l'interface repasse en mode visiteur.
    }
  }
}

final NotifierProvider<AuthController, AsyncValue<void>> authControllerProvider =
    NotifierProvider<AuthController, AsyncValue<void>>(AuthController.new);

/// Message d'erreur lisible associé à un état d'authentification en erreur
/// (null si l'état n'est pas en erreur).
String? authErrorMessage(AsyncValue<void> state) {
  if (!state.hasError) return null;
  final Object? error = state.error;
  if (error is AppException) return error.message;
  return 'Une erreur inattendue est survenue. Réessayez.';
}
