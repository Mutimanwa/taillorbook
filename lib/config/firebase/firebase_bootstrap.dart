import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// Résultat de l'initialisation de Firebase.
enum FirebaseBootstrapStatus { ready, failed }

/// Initialisation robuste de Firebase.
///
/// En cas d'échec (options de démonstration non remplacées, absence de
/// réseau...), l'application démarre quand même en « mode démonstration » :
/// navigation invitée possible, bannière d'information sur l'accueil et
/// états d'erreur explicites sur les écrans connectés.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  static bool _isReady = false;
  static String? _error;

  /// `true` une fois Firebase initialisé avec succès.
  static bool get isReady => _isReady;

  /// Détail de l'erreur d'initialisation (null si succès).
  static String? get error => _error;

  static Future<FirebaseBootstrapStatus> initialize() async {
    if (_isReady) return FirebaseBootstrapStatus.ready;
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      _isReady = true;
      _error = null;
      return FirebaseBootstrapStatus.ready;
    } catch (exception, stackTrace) {
      _error = exception.toString();
      if (kDebugMode) {
        debugPrint('Firebase indisponible (mode démonstration) : $_error');
        debugPrint('$stackTrace');
      }
      return FirebaseBootstrapStatus.failed;
    }
  }
}
