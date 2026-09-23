import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';

/// Variantes visuelles du bouton principal.
enum AppButtonVariant { primary, secondary, outline, text, danger }

/// Bouton standard de l'application : CTA très visible, état de chargement
/// intégré, icône optionnelle et largeur pleine par défaut.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.expanded = true,
    this.icon,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// Affiche un indicateur de progression et désactive le bouton.
  final bool loading;

  /// Si `true` (défaut), le bouton occupe toute la largeur disponible.
  final bool expanded;

  /// Icône optionnelle affichée avant le libellé.
  final IconData? icon;

  /// Hauteur du bouton en mode pleine largeur.
  final double height;

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !loading;
    final ButtonStyle style = _styleFor(context);
    final Color foreground = _foregroundColor();

    final Widget content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 19, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.buttonText(color: foreground),
                ),
              ),
            ],
          );

    final VoidCallback? callback = enabled ? onPressed : null;

    final Widget button = switch (variant) {
      AppButtonVariant.outline => OutlinedButton(
          onPressed: callback,
          style: style,
          child: content,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: callback,
          style: style,
          child: content,
        ),
      _ => FilledButton(
          onPressed: callback,
          style: style,
          child: content,
        ),
    };

    if (!expanded) return button;
    return SizedBox(width: double.infinity, height: height, child: button);
  }

  ButtonStyle _styleFor(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    const EdgeInsetsGeometry padding =
        EdgeInsets.symmetric(horizontal: 24, vertical: 14);

    return switch (variant) {
      AppButtonVariant.primary => FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          minimumSize: const Size(0, 52),
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        ),
      AppButtonVariant.secondary => FilledButton.styleFrom(
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          minimumSize: const Size(0, 52),
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        ),
      AppButtonVariant.danger => FilledButton.styleFrom(
          backgroundColor: AppColors.error,
          foregroundColor: Colors.white,
          disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
          disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
          minimumSize: const Size(0, 52),
          elevation: 0,
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        ),
      AppButtonVariant.outline => OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 52),
          side: BorderSide(color: theme.colorScheme.outline, width: 1.2),
          padding: padding,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        ),
      AppButtonVariant.text => TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
    };
  }

  Color _foregroundColor() {
    return switch (variant) {
      AppButtonVariant.outline || AppButtonVariant.text => AppColors.primary,
      _ => Colors.white,
    };
  }
}
