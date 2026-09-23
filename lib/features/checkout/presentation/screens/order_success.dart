import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/constants/app_enums.dart';
import 'package:taillorbook/state/currency/currency_providers.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../models/order_model.dart';
import '../../../../core/widgets/whatsapp_fallback.dart';
import '../../../../services/whatsapp_service.dart';
import '../../../../state/app/app_state.dart';

/// Écran de confirmation : paiement réussi, commande construite et récap
/// complet. La persistance Firestore et l'envoi WhatsApp arrivent aux
/// phases « Commandes » puis « WhatsApp ».
class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency display = ref.watch(displayCurrencyProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          children: <Widget>[
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (BuildContext context, double scale, Widget? child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  width: 92,
                  height: 92,
                  decoration: const BoxDecoration(
                    color: AppColors.successSoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check_circle_rounded,
                    size: 52,
                    color: AppColors.success,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Commande confirmée !',
              style: AppTypography.headlineMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Merci ${order.clientName} — votre commande a été enregistrée.',
              style: AppTypography.bodyMedium(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: context.appColorScheme.surface,
                borderRadius: AppRadius.rLg,
                border: Border.all(color: context.appColorScheme.outline),
              ),
              child: Column(
                children: <Widget>[
                  _Row('Commande', order.orderId.substring(0, 8).toUpperCase()),
                  _Row('Vendeur', order.sellerName),
                  _Row(
                    'Paiement',
                    '${order.payment.method.label} · '
                    '${order.payment.transactionReference}',
                  ),
                  _Row(
                    'Réception',
                    order.delivery.isDelivery
                        ? 'Livraison · ${order.delivery.address}, ${order.delivery.city}'
                        : 'Retrait en boutique',
                  ),
                  const Divider(height: 22),
                  ...order.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              '${item.productName} × ${item.quantity}',
                              style: AppTypography.bodyMedium(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 22),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          'Total payé',
                          style: AppTypography.titleMedium(),
                        ),
                      ),
                      PriceText(
                        amount: order.total,
                        currency: display,
                        showOldPrice: false,
                        style: AppTypography.titleMedium(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SizedBox(height: AppSpacing.xl),
            AppButton(
              label: 'Envoyer la commande via WhatsApp',
              icon: Icons.chat_outlined,
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                final WhatsAppOpenResult result = await ref
                    .read(whatsappServiceProvider)
                    .sendOrderSummary(order);
                if (!context.mounted || result.success) return;
                await showWhatsAppFallbackDialog(
                  context,
                  error: result.error!,
                  message: WhatsAppOrderMessages.orderSummary(order),
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: 'Continuer mes achats',
              variant: AppButtonVariant.outline,
              onPressed: () => context.go(AppRoutes.home),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              '${AppConstants.appName} · ${AppConstants.currencyRatesDisclaimer}',
              style: AppTypography.labelSmall(),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            width: 96,
            child: Text(label, style: AppTypography.bodySmall()),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium(),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}