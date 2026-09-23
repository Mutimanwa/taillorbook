import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../models/product_model.dart';
import 'display_price.dart';

/// Carte produit du catalogue (grilles et carrousels horizontaux).
///
/// Affiche image, badges promo / rupture / stock faible, nom, vendeur,
/// prix (+ ancien prix) et bouton d'ajout rapide au panier.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.width,
  });

  final ProductModel product;

  /// Tap sur la carte (ouverture de la fiche produit).
  final VoidCallback? onTap;

  /// Tap sur le bouton d'ajout rapide (panier).
  final VoidCallback? onAddToCart;

  /// Largeur fixe (carrousels horizontaux) ; sinon largeur disponible.
  final double? width;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    final Widget card = Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Hero(
              tag: 'product-image-${product.id}',
              child: _ProductImage(product: product),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      product.name,
                      style: AppTypography.titleSmall(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.sellerName,
                      style: AppTypography.labelSmall(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: DisplayPrice(
                            amount: product.price,
                            oldAmount: product.oldPrice,
                            currency: product.currency,
                          ),
                        ),
                        const SizedBox(width: 6),
                        _QuickAddButton(
                          enabled: product.inStock && onAddToCart != null,
                          onPressed: onAddToCart,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (width == null) return card;
    return SizedBox(width: width, child: card);
  }
}

/// Image produit + badges (promo, rupture, stock faible).
class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AspectRatio(
      aspectRatio: 1.15,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            placeholder: (BuildContext context, String url) =>
                Container(color: colorScheme.surfaceContainerHighest),
            errorWidget: (BuildContext context, String url, Object error) =>
                Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.image_outlined,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
          ),
          if (product.hasDiscount)
            Positioned(
              top: 8,
              left: 8,
              child: _Badge(
                label: '-${product.discountPercentage} %',
                background: AppColors.secondary,
                foreground: Colors.white,
              ),
            ),
          if (product.isLowStock)
            Positioned(
              top: 8,
              right: 8,
              child: _Badge(
                label: 'Plus que ${product.stock}',
                background: AppColors.warningSoft,
                foreground: AppColors.warning,
              ),
            ),
          if (!product.inStock)
            Container(
              color: Colors.black38,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: AppRadius.rFull,
                ),
                child: Text(
                  'Rupture de stock',
                  style: AppTypography.labelSmall(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pastille d'information (promo, stock faible).
class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.background,
    required this.foreground,
  });

  final String label;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: AppRadius.rFull,
      ),
      child: Text(label, style: AppTypography.labelSmall(color: foreground)),
    );
  }
}

/// Bouton d'ajout rapide au panier.
class _QuickAddButton extends StatelessWidget {
  const _QuickAddButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: IconButton.filled(
        padding: EdgeInsets.zero,
        iconSize: 18,
        style: IconButton.styleFrom(
          backgroundColor: enabled
              ? AppColors.primary
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          foregroundColor: enabled
              ? Colors.white
              : Theme.of(context).colorScheme.onSurfaceVariant,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.rMd),
        ),
        tooltip: 'Ajouter au panier',
        onPressed: onPressed,
        icon: const Icon(Icons.add_shopping_cart_rounded),
      ),
    );
  }
}
