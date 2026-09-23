import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_typography.dart';
import '../constants/app_enums.dart';
import '../extensions/context_extensions.dart';
import '../../app/theme/app_colors.dart';

/// Affiche le dialog de repli quand WhatsApp est indisponible : message
/// explicite + contenu copiable dans le presse-papiers.
///
/// Utilisé par la fiche produit (contact vendeur), la fiche commande et
/// l'écran de succès (récapitulatif WhatsApp).
Future<void> showWhatsAppFallbackDialog(
  BuildContext context, {
  required String error,
  required String message,
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
        icon: const Icon(Icons.chat, color: AppColors.warning),
        title: const Text('WhatsApp indisponible'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(error, style: AppTypography.bodyMedium()),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                color: Theme.of(dialogContext).colorScheme.surfaceContainerHighest,
                borderRadius: AppRadius.rMd,
              ),
              child: SingleChildScrollView(
                child: Text(message, style: AppTypography.bodySmall()),
              ),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Fermer'),
          ),
          FilledButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: message));
              if (!dialogContext.mounted) return;
              Navigator.of(dialogContext).pop();
              if (!context.mounted) return;
              context.showAppSnack(
                'Message copié. Collez-le dans WhatsApp.',
                AppSnackType.success,
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 17),
            label: const Text('Copier le message'),
          ),
        ],
      );
    },
  );
}

/// Couleur associée à un statut de commande (chips des listes et détails).
Color orderStatusColor(OrderStatus status) {
  return switch (status) {
    OrderStatus.pending => AppColors.warning,
    OrderStatus.confirmed => AppColors.accent,
    OrderStatus.processing => AppColors.primary,
    OrderStatus.readyForPickup => AppColors.primary,
    OrderStatus.shipped => AppColors.accent,
    OrderStatus.delivered => AppColors.success,
    OrderStatus.cancelled => AppColors.error,
  };
}

/// Couleur associée à un statut de paiement.
Color paymentStatusColor(PaymentStatus status) {
  return switch (status) {
    PaymentStatus.pending => AppColors.warning,
    PaymentStatus.processing => AppColors.accent,
    PaymentStatus.paid => AppColors.success,
    PaymentStatus.failed => AppColors.error,
  };
}