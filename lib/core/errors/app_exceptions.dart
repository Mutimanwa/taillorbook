/// Hiérarchie d'exceptions métier de l'application.
///
/// Les dépôts et services traduisent les erreurs techniques (Firebase, réseau,
/// ImgBB...) en exceptions typées que la couche interface affiche proprement
/// (snackbar, dialog ou état d'erreur avec bouton « Réessayer »).
class AppException implements Exception {
  const AppException(this.message, {this.code});

  /// Message lisible par l'utilisateur, prêt à être affiché.
  final String message;

  /// Code technique optionnel (journalisation, tests).
  final String? code;

  @override
  String toString() => 'AppException($code): $message';
}

/// Pas de connexion internet / réseau indisponible.
class NetworkException extends AppException {
  const NetworkException({String? message})
      : super(
          message ?? 'Connexion internet indisponible. Vérifiez votre réseau puis réessayez.',
          code: 'network',
        );
}

/// Erreur d'authentification Firebase (identifiants invalides, compte existant...).
class AuthException extends AppException {
  const AuthException(super.message, {String? code}) : super(code: code ?? 'auth');
}

/// Action réservée aux utilisateurs authentifiés.
class UnauthorizedException extends AppException {
  const UnauthorizedException({String? message})
      : super(message ?? 'Veuillez vous connecter pour continuer.', code: 'unauthorized');
}

/// Erreur Firestore (lecture, écriture, droits, indisponibilité).
class FirestoreException extends AppException {
  const FirestoreException(String s, {String? message, String? code})
      : super(
          message ?? 'Une erreur est survenue lors de l\'accès aux données. Réessayez.',
          code: code ?? 'firestore',
        );
}

/// Échec d'upload d'image vers ImgBB (clé absente, timeout, réponse invalide).
class ImageUploadException extends AppException {
  const ImageUploadException({String? message, String? code})
      : super(
          message ?? 'Échec de l\'envoi de l\'image. Vérifiez votre connexion puis réessayez.',
          code: code ?? 'image-upload',
        );
}

/// Échec du paiement simulé (doit empêcher la confirmation de commande).
class PaymentException extends AppException {
  const PaymentException({String? message, String? code})
      : super(message ?? 'Le paiement a échoué. La commande n\'a pas été confirmée.', code: code ?? 'payment');
}

/// Données de formulaire invalides.
class ValidationException extends AppException {
  const ValidationException(super.message) : super(code: 'validation');
}

/// WhatsApp indisponible ou impossible à ouvrir (deep link refusé).
class WhatsAppException extends AppException {
  const WhatsAppException({String? message})
      : super(
          message ?? 'Impossible d\'ouvrir WhatsApp. Vérifiez qu\'il est installé sur cet appareil.',
          code: 'whatsapp',
        );
}
