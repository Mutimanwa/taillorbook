import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../extensions/context_extensions.dart';
import '../../models/cart_item_model.dart';
import '../../models/product_model.dart';
import '../utils/money_formatter.dart';
import '../../state/cart/cart_providers.dart';
import '../../state/products/products_providers.dart';
import 'app_button.dart';
import 'price_text.dart';

/// Aperçu rapide d'un produit (bottom sheet) : image, prix, stock, vendeur,
/// description et ajout au panier avec garde-fou de stock.
///
/// La fiche produit complète (galerie, WhatsApp vendeur, Buy Now) arrive à la
/// phase « Catalogue public » ; ce composant reste utilisé pour la
/// prévisualisation rapide depuis les cartes.
Future<void> showProductQuickView(BuildContext context, String productId) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext sheetContext) => _QuickViewSheet(productId: productId),
  );
}

class _QuickViewSheet extends ConsumerStatefulWidget {
  const _QuickViewSheet({required this.productId});

  final String productId;

  @override
  ConsumerState<_QuickViewSheet> createState() => _QuickViewSheetState();
}

class _QuickViewSheetState extends ConsumerState<_QuickViewSheet> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ProductModel?> productAsync =
        ref.watch(productByIdProvider(widget.productId));
    final ProductModel? product = productAsync.valueOrNull;

    if (product == null) {
      return Container(
        decoration: BoxDecoration(
          color: context.appColorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: productAsync.isLoading
            ? const _SheetLoading()
            : _SheetError(
                message: 'Produit introuvable.',
                onRetry: () =>
                    ref.invalidate(productByIdProvider(widget.productId)),
              ),
      );
    }

    final int effectiveQuantity =
        product.inStock ? _quantity.clamp(1, product.stock) : 1;

    return Container(
      decoration: BoxDecoration(
        color: context.appColorScheme.surface,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.appColorScheme.surfaceContainerHighest,
                    borderRadius: AppRadius.rFull,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius: AppRadius.rLg,
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: CachedNetworkImage(
                    imageUrl: product.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (BuildContext context, String url) =>
                        Container(
                      color: context.appColorScheme.surfaceContainerHighest,
                    ),
                    errorWidget:
                        (BuildContext context, String url, Object error) =>
                            Container(
                      color: context.appColorScheme.surfaceContainerHighest,
                      child: const Icon(Icons.image_outlined),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(product.name, style: AppTypography.headlineSmall()),
              const SizedBox(height: 4),
              Row(
                children: <Widget>[
                  const Icon(Icons.storefront_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Vendu par ${product.sellerName}',
                      style: AppTypography.bodySmall(),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StockChip(product: product),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              PriceText(
                amount: product.price,
                oldAmount: product.oldPrice,
                currency: product.currency,
                style: AppTypography.headlineSmall(color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(product.description, style: AppTypography.bodyMedium()),
              const SizedBox(height: AppSpacing.lg),
              if (product.inStock) ...<Widget>[
                Row(
                  children: <Widget>[
                    Text('Quantité', style: AppTypography.titleSmall()),
                    const Spacer(),
                    _QuantitySelector(
                      quantity: effectiveQuantity,
                      maxQuantity: product.stock,
                      onChanged: (int value) => setState(() => _quantity = value),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              AppButton(
                label: product.inStock
                    ? 'Ajouter au panier · ${MoneyFormatter.format(product.price * effectiveQuantity, product.currency)}'
                    : 'Produit en rupture de stock',
                icon: product.inStock
                    ? Icons.add_shopping_cart_rounded
                    : Icons.block_rounded,
                onPressed: product.inStock
                    ? () => _addToCart(context, product, effectiveQuantity)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, ProductModel product, int quantity) {
    final int existingQuantity = ref
        .read(cartProvider)
        .where((CartItemModel element) => element.productId == product.id)
        .fold<int>(0, (int total, CartItemModel element) => total + element.quantity);

    ref
        .read(cartProvider.notifier)
        .addItem(product.toCartItem(quantity: quantity), maxQuantity: product.stock);

    final bool capped = existingQuantity + quantity > product.stock;

    if (context.mounted) {
      Navigator.of(context).pop();
      Future<void>.delayed(const Duration(milliseconds: 250)).then((_) {
        if (!context.mounted) return;
        context.showAppSnack(
          capped
              ? 'Quantité limitée au stock disponible (${product.stock}).'
              : '« ${product.name} » ajouté au panier.',
          capped ? AppSnackType.warning : AppSnackType.success,
        );
      });
    }
  }
}

/// Pastille de disponibilité : « En stock », « Plus que X » ou « Rupture ».
class _StockChip extends StatelessWidget {
  const _StockChip({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return const _Chip(label: 'Rupture', color: AppColors.error);
    }
    if (product.isLowStock) {
      return _Chip(label: 'Plus que ${product.stock}', color: AppColors.warning);
    }
    return _Chip(label: 'En stock (${product.stock})', color: AppColors.success);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

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

/// Sélecteur de quantité borné au stock.
class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.maxQuantity,
    required this.onChanged,
  });

  final int quantity;
  final int maxQuantity;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.appColorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.rFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: 'Diminuer',
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          SizedBox(
            width: 30,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: AppTypography.titleSmall(),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            tooltip: 'Augmenter',
            onPressed:
                quantity < maxQuantity ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

/// Indicateur de chargement compact du sheet.
class _SheetLoading extends StatelessWidget {
  const _SheetLoading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
    );
  }
}

/// Erreur compacte du sheet avec bouton « Réessayer ».
class _SheetError extends StatelessWidget {
  const _SheetError({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 30),
        const SizedBox(height: 10),
        Text(message, style: AppTypography.bodyMedium()),
        if (onRetry != null) ...<Widget>[
          const SizedBox(height: 12),
          AppButton(
            label: 'Réessayer',
            variant: AppButtonVariant.outline,
            expanded: false,
            onPressed: onRetry,
          ),
        ],
      ],
    );
  }
}
