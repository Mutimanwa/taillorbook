import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/utils/date_formater.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../core/widgets/whatsapp_fallback.dart';
import '../../../../models/order_model.dart';
import '../../../../services/whatsapp_service.dart';
import '../../../../state/app/app_state.dart';
import '../../../../state/currency/currency_providers.dart';
import '../../../../state/orders/orders_providers.dart';
import '../../../../core/utils/currency_converter.dart';

/// Fiche commande détaillée — partagée client (/[order/:id]) et vendeur
/// ([isSellerView] : bloc client mis en avant), design professionnel :
/// statut, articles, montants, livraison et envoi WhatsApp au vendeur.
class OrderDetailsScreen extends ConsumerWidget {
  const OrderDetailsScreen({
    super.key,
    required this.orderId,
    this.isSellerView = false,
  });

  final String orderId;

  /// Vue vendeur : informations client et téléphone en évidence.
  final bool isSellerView;

  Future<void> _sendWhatsApp(BuildContext context, WidgetRef ref, OrderModel order) async {
    final WhatsAppOpenResult result = await ref
        .read(whatsappServiceProvider)
        .sendOrderSummary(order);
    if (!context.mounted) return;
    if (result.success) {
      context.showAppSnack('WhatsApp ouvert : récapitulatif prêt à envoyer.',
          AppSnackType.success);
    } else {
      await showWhatsAppFallbackDialog(
        context,
        error: result.error!,
        message: WhatsAppOrderMessages.orderSummary(order),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<OrderModel?> orderAsync = ref.watch(orderByIdProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(isSellerView ? 'Commande vendeur' : 'Ma commande'),
      ),
      body: orderAsync.when(
        loading: () => const AppLoading(message: 'Chargement de la commande…'),
        error: (Object error, StackTrace stackTrace) => AppError(
          message: 'Impossible de charger la commande.',
          onRetry: () => ref.invalidate(orderByIdProvider(orderId)),
        ),
        data: (OrderModel? order) {
          if (order == null) {
            return AppError(
              title: 'Commande introuvable',
              message: "Cette commande n'existe pas ou n'est pas accessible.",
            );
          }
          return _OrderDetailsView(
            order: order,
            isSellerView: isSellerView,
            onSendWhatsApp: () => _sendWhatsApp(context, ref, order),
          );
        },
      ),
    );
  }
}

class _OrderDetailsView extends ConsumerWidget {
  const _OrderDetailsView({
    required this.order,
    required this.isSellerView,
    required this.onSendWhatsApp,
  });

  final OrderModel order;
  final bool isSellerView;
  final VoidCallback onSendWhatsApp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency display = ref.watch(displayCurrencyProvider);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        _StatusHeader(order: order),
        const SizedBox(height: 12),
        if (isSellerView) ...<Widget>[
          _SellerStatusCard(order: order),
          const SizedBox(height: 12),
        ],
        if (isSellerView) ...<Widget>[
          _Section(
            title: 'Client',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(order.clientName, style: AppTypography.titleMedium()),
                const SizedBox(height: 2),
                Text(order.clientPhone, style: AppTypography.bodyMedium()),
                Text(
                  'Commande #${order.orderId.substring(0, 8).toUpperCase()} · '
                  '${AppDateFormatter.formatDateTime(order.createdAt)}',
                  style: AppTypography.labelSmall(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        _Section(
          title: 'Produits',
          child: Column(
            children: <Widget>[
              ...order.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: AppRadius.rMd,
                        child: SizedBox(
                          width: 52,
                          height: 52,
                          child: CachedNetworkImage(
                            imageUrl: item.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (BuildContext context, String url) =>
                                Container(
                              color: context.appColorScheme.surfaceContainerHighest,
                            ),
                            errorWidget:
                                (BuildContext context, String url, Object error) =>
                                    Container(
                              color:
                                  context.appColorScheme.surfaceContainerHighest,
                              child: const Icon(Icons.image_outlined, size: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              item.productName,
                              style: AppTypography.titleSmall(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${item.quantity} × '
                              '${MoneyFormatter.format(item.unitPrice, item.currency)}',
                              style: AppTypography.bodySmall(),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        MoneyFormatter.format(item.lineTotal, item.currency),
                        style: AppTypography.titleSmall(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Réception',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Icon(
                    order.isStorePickup
                        ? Icons.store_rounded
                        : Icons.local_shipping_outlined,
                    size: 17,
                    color: order.isStorePickup
                        ? AppColors.secondary
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      order.isStorePickup
                          ? 'Retrait en boutique (sans frais)'
                          : 'Livraison à domicile',
                      style: AppTypography.titleMedium(),
                    ),
                  ),
                ],
              ),
              if (order.delivery.isDelivery) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  '${order.delivery.address}, ${order.delivery.city}',
                  style: AppTypography.bodyMedium(),
                ),
                Text(
                  'Téléphone : ${order.delivery.phone}',
                  style: AppTypography.bodySmall(),
                ),
                if (order.delivery.additionalInfo.isNotEmpty)
                  Text(
                    order.delivery.additionalInfo,
                    style: AppTypography.bodySmall(),
                  ),
              ],
              if (!isSellerView) ...<Widget>[
                const SizedBox(height: 4),
                Text(
                  'Vendeur : ${order.sellerName}',
                  style: AppTypography.bodySmall(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Paiement',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                '${order.payment.method.label} · ${order.payment.status.label}',
                style: AppTypography.bodyMedium(),
              ),
              const SizedBox(height: 2),
              Text(
                'Référence : ${order.payment.transactionReference}',
                style: AppTypography.bodySmall(),
              ),
              if (order.payment.processedAt != null)
                Text(
                  'Traité le ${AppDateFormatter.formatDateTime(order.payment.processedAt)}',
                  style: AppTypography.bodySmall(),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        _Section(
          title: 'Montants',
          child: Column(
            children: <Widget>[
              _AmountRow('Sous-total', order.subtotal, order.currency),
              _AmountRow(
                order.isStorePickup ? 'Retrait boutique' : 'Frais de livraison',
                order.deliveryFee,
                order.currency,
              ),
              const Divider(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text('Total', style: AppTypography.titleMedium()),
                  ),
                  PriceText(
                    amount: CurrencyConverter.convert(
                        order.total, order.currency, display),
                    currency: display,
                    showOldPrice: false,
                    style: AppTypography.titleMedium(color: AppColors.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (!isSellerView)
          AppButton(
            label: 'Envoyer la commande via WhatsApp',
            icon: Icons.chat_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: onSendWhatsApp,
          ),
        if (!isSellerView) const SizedBox(height: 8),
        if (!isSellerView)
          Text(
            "Le récapitulatif complet (produits, montants, livraison et "
            'paiement) sera prérempli dans la conversation WhatsApp.',
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall(),
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}


class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final Color statusColor = orderStatusColor(order.orderStatus);
    final Color payColor = paymentStatusColor(order.payment.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: AppRadius.rLg,
        border: Border.all(color: statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.receipt_long_rounded, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '#${order.orderId.substring(0, 8).toUpperCase()}',
                  style: AppTypography.titleLarge(),
                ),
              ),
              _ChipPill(label: order.orderStatus.label, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Text(
                AppDateFormatter.formatDateTime(order.createdAt),
                style: AppTypography.bodySmall(),
              ),
              const Spacer(),
              _ChipPill(label: 'Paiement : ${order.payment.status.label}', color: payColor),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipPill extends StatelessWidget {
  const _ChipPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadius.rFull,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(color: color),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.appColorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: context.appColorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: AppTypography.titleSmall(color: AppColors.primary)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _AmountRow extends ConsumerWidget {
  const _AmountRow(this.label, this.amount, this.currency);

  final String label;
  final double amount;
  final AppCurrency currency;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency display = ref.watch(displayCurrencyProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: AppTypography.bodyMedium())),
          PriceText(
            amount: CurrencyConverter.convert(amount, currency, display),
            currency: display,
            showOldPrice: false,
          ),
        ],
      ),
    );
  }
}


/// Carte de gestion vendeur : statut actuel + ouverture du sélecteur.
/// L'écriture Firestore est limitée aux champs orderStatus + updatedAt
/// (règles de sécurité) ; la lecture temps réel propage le changement au
/// client et aux listes vendeur sans rechargement manuel.
class _SellerStatusCard extends ConsumerWidget {
  const _SellerStatusCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Color statusColor = orderStatusColor(order.orderStatus);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.appColorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: context.appColorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Gestion de la commande',
            style: AppTypography.titleSmall(color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: AppRadius.rFull,
                ),
                child: Text(
                  order.orderStatus.label,
                  style: AppTypography.labelSmall(color: Colors.white),
                ),
              ),
              const Spacer(),
              Text(
                'Statut actuel',
                style: AppTypography.labelSmall(
                  color: context.appColorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AppButton(
            label: 'Changer le statut',
            variant: AppButtonVariant.secondary,
            icon: Icons.edit_rounded,
            onPressed: () => showOrderStatusPicker(context, ref, order),
          ),
        ],
      ),
    );
  }
}

/// Sélecteur de statut (bottom sheet) : cycle de vie complet avec
/// description de chaque étape. Le tap déclenche l'écriture Firestore.
Future<void> showOrderStatusPicker(
  BuildContext context,
  WidgetRef ref,
  OrderModel order,
) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Statut de la commande',
                        style: AppTypography.headlineSmall(),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Le client voit ce statut en temps réel.',
                    style: AppTypography.bodySmall(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
              ...OrderStatus.values.map(
                (OrderStatus status) => RadioListTile<OrderStatus>(
                  value: status,
                  groupValue: order.orderStatus,
                  activeColor: AppColors.primary,
                  title: Text(status.label, style: AppTypography.titleMedium()),
                  subtitle: Text(_statusHint(status)),
                  onChanged: (OrderStatus? value) async {
                    Navigator.of(sheetContext).pop();
                    if (value == null || value == order.orderStatus) return;
                    final OrderActionResult result = await updateOrderStatus(
                      ref,
                      orderId: order.orderId,
                      status: value,
                    );
                    if (!context.mounted) return;
                    context.showAppSnack(
                      result.success
                          ? 'Statut mis à jour : ${value.label}.'
                          : (result.error ?? 'Action impossible.'),
                      result.success ? AppSnackType.success : AppSnackType.error,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      );
    },
  );
}

/// Description courte de chaque étape du cycle de vie (affichée sous le
/// libellé dans le sélecteur).
String _statusHint(OrderStatus status) => switch (status) {
      OrderStatus.pending => 'Nouvelle commande, en attente de confirmation.',
      OrderStatus.confirmed => 'Commande confirmée par la boutique.',
      OrderStatus.processing => 'Préparation / emballage en cours.',
      OrderStatus.readyForPickup => 'Prête : retrait possible en boutique.',
      OrderStatus.shipped => 'Remise au livreur, en cours de livraison.',
      OrderStatus.delivered => 'Livrée au client.',
      OrderStatus.cancelled => 'Commande annulée.',
    };