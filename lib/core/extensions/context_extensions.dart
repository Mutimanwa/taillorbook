import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

/// Type de feedback affiché via un snackbar.
enum AppSnackType { info, success, warning, error }

/// Extensions pratiques de [BuildContext] : accès au thème et affichage
/// centralisé des feedbacks (snackbars, dialogs de confirmation).
extension AppContextExtensions on BuildContext {
  /// Thème courant de l'application.
  ThemeData get appTheme => Theme.of(this);

  /// Jeu de styles typographiques du thème courant.
  TextTheme get appTextTheme => Theme.of(this).textTheme;

  /// Palette sémantique du thème courant.
  ColorScheme get appColorScheme => Theme.of(this).colorScheme;

  /// Ferme le clavier virtuel s'il est ouvert.
  void hideKeyboard() => FocusScope.of(this).unfocus();

  /// Affiche un snackbar stylé selon le type de feedback.
  ///
  /// Exemple : `context.showAppSnack('Produit ajouté', AppSnackType.success);`
  void showAppSnack(String message, [AppSnackType type = AppSnackType.info]) {
    final Color backgroundColor = switch (type) {
      AppSnackType.info => AppColors.textPrimary,
      AppSnackType.success => AppColors.success,
      AppSnackType.warning => AppColors.warning,
      AppSnackType.error => AppColors.error,
    };
    final IconData icon = switch (type) {
      AppSnackType.info => Icons.info_outline_rounded,
      AppSnackType.success => Icons.check_circle_outline_rounded,
      AppSnackType.warning => Icons.warning_amber_rounded,
      AppSnackType.error => Icons.error_outline_rounded,
    };

    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: Duration(seconds: type == AppSnackType.error ? 4 : 3),
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
          content: Row(
            children: <Widget>[
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }

  /// Affiche un dialog de confirmation et renvoie `true` si l'utilisateur
  /// a confirmé. Utilisé avant toute action destructive.
  Future<bool> showConfirmDialog({
    required String title,
    required String message,
    String confirmLabel = 'Confirmer',
    String cancelLabel = 'Annuler',
    bool destructive = false,
  }) async {
    final bool? confirmed = await showDialog<bool>(
      context: this,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
          title: Text(title, style: AppTypography.titleLarge()),
          content: Text(
            message,
            style: AppTypography.bodyMedium(
              color: Theme.of(dialogContext).colorScheme.onSurfaceVariant,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(cancelLabel),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: Theme.of(dialogContext).colorScheme.error,
                    )
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    return confirmed ?? false;
  }
}
