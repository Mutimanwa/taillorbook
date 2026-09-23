import 'package:flutter/material.dart';
import 'package:taillorbook/app/theme/app_colors.dart';
import 'package:taillorbook/core/utils/date_formater.dart';
import 'package:taillorbook/core/widgets/whatsapp_fallback.dart';

import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../constants/app_enums.dart';
import '../utils/money_formatter.dart';
import '../../models/order_model.dart';
import '../../state/currency/currency_providers.dart';
import '../utils/currency_converter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Carte de commande (historique client et commandes vendeur) : identifiant,
/// date, articles, total converti, statut de paiement et statut de commande.
class OrderCard extends ConsumerWidget {
  const OrderCard({
    super.key,
    required this.order,
    this.showClientInfo = false,
    this.onTap,
  });

  final OrderModel order;

  /// Affiche le bloc client (mode vendeur).
  final bool showClientInfo;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final AppCurrency display = ref.watch(displayCurrencyProvider);
    final Color statusColor = orderStatusColor(order.orderStatus);
    final Color payColor = paymentStatusColor(order.payment.status);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rLg,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: order.isStorePickup
                        ? AppColors.secondarySoft
                        : AppColors.primarySoft,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    order.isStorePickup
                        ? Icons.store_rounded
                        : Icons.local_shipping_outlined,
                    size: 19,
                    color:
                        order.isStorePickup ? AppColors.secondary : AppColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '#${order.orderId.substring(0, 8).toUpperCase()}',
                        style: AppTypography.titleSmall(),
                      ),
                      Text(
                        AppDateFormatter.formatDateTime(order.createdAt),
                        style: AppTypography.labelSmall(),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      MoneyFormatter.format(
                        CurrencyConverter.convert(
                            order.total, order.currency, display),
                        display,
                      ),
                      style: AppTypography.titleMedium(color: AppColors.primary),
                    ),
                    Text(
                      '${order.totalQuantity} article${order.totalQuantity > 1 ? 's' : ''}',
                      style: AppTypography.labelSmall(),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (showClientInfo) ...<Widget>[
              Row(
                children: <Widget>[
                  const Icon(Icons.person_outline_rounded,
                      size: 15, color: AppColors.textSecondary),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      '${order.clientName} · ${order.clientPhone}',
                      style: AppTypography.bodySmall(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                _StatusChip(
                  label: order.orderStatus.label,
                  color: statusColor,
                ),
                _StatusChip(
                  label: 'Paiement : ${order.payment.status.label}',
                  color: payColor,
                ),
                _StatusChip(
                  label: order.isStorePickup
                      ? 'Retrait boutique'
                      : 'Livraison',
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pastille de statut colorée à fond doux.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.rFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(color: color),
      ),
    );
  }
}