import 'package:flutter/material.dart';

/// Palette de couleurs officielle de SokoMarket.
///
/// Toutes les couleurs de l'application proviennent de cette classe afin de
/// garantir une identité visuelle cohérente (thème clair et thème sombre).
class AppColors {
  AppColors._();

  // ------------------------------------------------------------------ marque
  /// Vert émeraude profond — couleur principale (CTA, accents de marque).
  static const Color primary = Color(0xFF0E7C66);

  /// Nuance foncée de la couleur principale (titres sur fond clair).
  static const Color primaryDark = Color(0xFF0A5D4D);

  /// Nuance douce de la couleur principale (fonds de badges, indicateurs).
  static const Color primarySoft = Color(0xFFD8F0E9);

  /// Ambre chaud — couleur secondaire (promotions, badges du panier).
  static const Color secondary = Color(0xFFF5A623);

  /// Nuance douce de la couleur secondaire.
  static const Color secondarySoft = Color(0xFFFFF3DC);

  /// Bleu informatif (liens, informations).
  static const Color accent = Color(0xFF2E6BE6);

  // -------------------------------------------------------- neutres (clair)
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEFF2F5);
  static const Color border = Color(0xFFE3E8EF);
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF667085);
  static const Color textDisabled = Color(0xFF98A2B3);

  // --------------------------------------------------------- neutres (sombre)
  static const Color darkBackground = Color(0xFF0C111D);
  static const Color darkSurface = Color(0xFF151B28);
  static const Color darkSurfaceAlt = Color(0xFF1F2634);
  static const Color darkBorder = Color(0xFF2C3444);
  static const Color darkTextPrimary = Color(0xFFF2F4F7);
  static const Color darkTextSecondary = Color(0xFF98A2B3);

  // ------------------------------------------------------------- sémantiques
  static const Color success = Color(0xFF12B76A);
  static const Color successSoft = Color(0xFFE6F7EF);
  static const Color warning = Color(0xFFF79009);
  static const Color warningSoft = Color(0xFFFFF5E6);
  static const Color error = Color(0xFFE5484D);
  static const Color errorSoft = Color(0xFFFDECEC);

  // ---------------------------------------------------------------- dégradés
  static const List<Color> heroGradient = <Color>[
    Color(0xFF0E7C66),
    Color(0xFF149B81),
  ];
  static const List<Color> promoGradient = <Color>[
    Color(0xFF1B2130),
    Color(0xFF3A4356),
  ];
}