import 'package:flutter/services.dart';

/// Retours haptiques discrets de l'application.
///
/// Utilisés avec parcimonie : ajout au panier, succès de paiement et
/// confirmation de commande uniquement.
class AppHaptics {
  AppHaptics._();

  /// Micro-retour d'action (ajout au panier, changement de devise…).
  static void tap() => HapticFeedback.lightImpact();

  /// Retour de réussite (paiement accepté, commande confirmée).
  static void success() => HapticFeedback.mediumImpact();
}