import 'package:flutter/foundation.dart';

import '../errors/app_exceptions.dart';

/// Traduit n'importe quelle erreur en message français affichable.
///
/// Utilisé partout où une erreur brute pourrait fuiter vers l'interface
/// (callbacks génériques, erreurs de plate-forme, exceptions non typées) :
/// - les [AppException] portent déjà un message utilisateur ;
/// - les erreurs réseau natives (SocketException, http…) sont reconnues ;
/// - en mode debug, le détail technique est ajouté pour faciliter la
///   soutenance/débogage — masqué en release.
String appErrorMessage(Object? error) {
  if (error == null) {
    return 'Une erreur inattendue est survenue. Réessayez.';
  }
  if (error is AppException) return error.message;

  final String raw = error.toString();
  if (raw.contains('SocketException') ||
      raw.contains('Failed host lookup') ||
      raw.contains('NetworkException')) {
    return const NetworkException().message;
  }
  if (raw.contains('TimeoutException')) {
    return 'Délai dépassé. Vérifiez votre connexion puis réessayez.';
  }

  final String base = 'Une erreur inattendue est survenue. Réessayez.';
  if (kDebugMode) return '$base\n[Détail : $raw]';
  return base;
}