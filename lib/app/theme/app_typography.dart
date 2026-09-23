import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typographie de l'application (famille Poppins, embarquée dans les assets).
///
/// Toutes les tailles et graisses de texte passent par cette classe afin de
/// conserver une hiérarchie visuelle homogène sur tous les écrans.
class AppTypography {
  AppTypography._();

  static const String fontFamily = 'Poppins';

  static TextStyle _style({
    required double fontSize,
    FontWeight weight = FontWeight.w400,
    double height = 1.45,
    double letterSpacing = 0,
    Color? color,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
      color: color ?? AppColors.textPrimary,
    );
  }

  /// 30 / Bold — grand titre de marque (splash, bannières).
  static TextStyle displayLarge({Color? color}) => _style(
        fontSize: 30,
        weight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.5,
        color: color,
      );

  /// 24 / SemiBold — titres de section majeurs.
  static TextStyle headlineMedium({Color? color}) => _style(
        fontSize: 24,
        weight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.25,
        color: color,
      );

  /// 20 / SemiBold — titres d'écran.
  static TextStyle headlineSmall({Color? color}) =>
      _style(fontSize: 20, weight: FontWeight.w600, height: 1.3, color: color);

  /// 17 / SemiBold — titres de cartes, entrées de liste importantes.
  static TextStyle titleLarge({Color? color}) =>
      _style(fontSize: 17, weight: FontWeight.w600, height: 1.35, color: color);

  /// 15 / SemiBold — sous-titres, labels de champs.
  static TextStyle titleMedium({Color? color}) =>
      _style(fontSize: 15, weight: FontWeight.w600, height: 1.4, color: color);

  /// 13 / SemiBold — petits titres, lignes secondaires mises en valeur.
  static TextStyle titleSmall({Color? color}) =>
      _style(fontSize: 13, weight: FontWeight.w600, height: 1.4, color: color);

  /// 15 / Regular — corps de texte principal.
  static TextStyle bodyLarge({Color? color}) =>
      _style(fontSize: 15, height: 1.5, color: color);

  /// 14 / Regular — corps de texte standard.
  static TextStyle bodyMedium({Color? color}) =>
      _style(fontSize: 14, height: 1.5, color: color);

  /// 13 / Regular — corps de texte compact (couleur secondaire par défaut).
  static TextStyle bodySmall({Color? color}) => _style(
        fontSize: 13,
        height: 1.5,
        color: color ?? AppColors.textSecondary,
      );

  /// 14 / Medium — labels de puces et de métadonnées.
  static TextStyle labelLarge({Color? color}) =>
      _style(fontSize: 14, weight: FontWeight.w500, color: color);

  /// 12 / Medium — métadonnées compactes (couleur secondaire par défaut).
  static TextStyle labelMedium({Color? color}) => _style(
        fontSize: 12,
        weight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  /// 11 / Medium — légences très compactes, labels de navigation
  /// (couleur secondaire par défaut).
  static TextStyle labelSmall({Color? color}) => _style(
        fontSize: 11,
        weight: FontWeight.w500,
        color: color ?? AppColors.textSecondary,
      );

  /// 15 / SemiBold — texte des boutons (blanc par défaut).
  static TextStyle buttonText({Color? color}) =>
      _style(fontSize: 15, weight: FontWeight.w600, color: color ?? Colors.white);
}
