import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../models/cart_item_model.dart';
import '../../../../state/cart/cart_providers.dart';

/// Onglet Panier : liste des articles, modification des quantités,
/// sous-total et accès au checkout (activé à la phase « Checkout »).
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<CartItemModel> items = ref.watch(cartProvider);

    if (items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mon panier')),
        body: Center(
          child: AppEmpty(
            icon: Icons.shopping_cart_outlined,
            title: 'Votre panier est vide',
            message: 'Parcourez le catalogue et ajoutez vos produits préférés.',
            actionLabel: 'Voir le catalogue',
            onAction: () => context.go(AppRoutes.home),
          ),
        ),
      );
    }

    final double subtotal = ref.watch(cartSubtotalProvider);
    final AppCurrency currency = items.first.currency;

    return Scaffold(
      appBar: AppBar(
        title: Text('Mon panier (${ref.watch(cartTotalItemsProvider)})'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Vider le panier',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmClearCart(context, ref),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              itemCount: items.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) =>
                  _CartItemCard(item: items[index]),
            ),
          ),
          _CartSummary(
            subtotal: subtotal,
            currency: currency,
            onCheckout: () => context.showAppSnack(
              'Le checkout et le paiement seront disponibles très bientôt.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await context.showConfirmDialog(
      title: 'Vider le panier',
      message: 'Voulez-vous retirer tous les articles de votre panier ?',
      confirmLabel: 'Vider',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;
    ref.read(cartProvider.notifier).clearCart();
    context.showAppSnack('Panier vidé.', AppSnackType.info);
  }
}

/// Carte d'un article du panier : image, nom, vendeur, prix, stepper.
class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.rMd,
            child: SizedBox(
              width: 72,
              height: 72,
              child: CachedNetworkImage(
                imageUrl: item.imageUrl,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    Container(color: colorScheme.surfaceContainerHighest),
                errorWidget:
                    (BuildContext context, String url, Object error) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.productName,
                  style: context.appTextTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Vendu par ${item.sellerName}',
                  style: context.appTextTheme.labelMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: PriceText(
                        amount: item.unitPrice,
                        currency: item.currency,
                        style: context.appTextTheme.titleSmall,
                      ),
                    ),
                    _QuantityStepper(item: item),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Contrôle + / − pour ajuster la quantité d'un article.
class _QuantityStepper extends ConsumerWidget {
  const _QuantityStepper({required this.item});

  final CartItemModel item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.rFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _StepperButton(
            icon: Icons.remove_rounded,
            tooltip: 'Diminuer la quantité',
            onTap: () =>
                ref.read(cartProvider.notifier).decreaseQuantity(item.productId),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: context.appTextTheme.titleSmall,
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            tooltip: 'Augmenter la quantité',
            onTap: () =>
                ref.read(cartProvider.notifier).increaseQuantity(item.productId),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      onPressed: onTap,
      icon: Icon(icon),
    );
  }
}

/// Résumé collant en bas du panier : sous-total + CTA checkout.
class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.subtotal,
    required this.currency,
    required this.onCheckout,
  });

  final double subtotal;
  final AppCurrency currency;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        boxShadow: AppShadows.floating,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text('Sous-total', style: context.appTextTheme.bodyMedium),
                ),
                PriceText(amount: subtotal, currency: currency),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              "Frais de livraison calculés à l'étape suivante.",
              style: context.appTextTheme.labelMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            AppButton(
              label: 'Passer la commande',
              icon: Icons.arrow_forward_rounded,
              onPressed: onCheckout,
            ),
          ],
        ),
      ),
    );
  }
}
