import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_shadows.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/app_haptics.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/display_price.dart';
import '../../../../models/product_model.dart';
import '../../../../services/whatsapp_service.dart';
import '../../../../state/app/app_state.dart';
import '../../../../state/auth/auth_providers.dart';
import '../../../../state/cart/cart_providers.dart';
import '../../../../state/products/products_providers.dart';

/// Fiche produit professionnelle : grande image, nom, prix (+ ancien prix),
/// stock (« Plus que X en stock »), catégorie, vendeur avec contact WhatsApp,
/// description, quantité bornée au stock, « Ajouter au panier » et
/// « Acheter maintenant » (authentification requise).
class ProductDetailsScreen extends ConsumerStatefulWidget {
  const ProductDetailsScreen({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;

  void _addToCart(ProductModel product) {
    AppHaptics.tap();
    ref
        .read(cartProvider.notifier)
        .addItem(product.toCartItem(quantity: _quantity), maxQuantity: product.stock);
    context.showAppSnack(
      '« ${product.name} » × $_quantity ajouté au panier.',
      AppSnackType.success,
    );
  }

  /// « Acheter maintenant » : visiteur → connexion (retour auto sur la fiche) ;
  /// client → ajout au panier puis ouverture du panier (checkout en phase 8).
  Future<void> _buyNow(ProductModel product) async {
    final bool isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      final String returnRoute =
          Uri.encodeComponent(AppRoutes.productDetails(product.id));
      context.push('${AppRoutes.login}?from=$returnRoute');
      return;
    }
    _addToCart(product);
    context.go(AppRoutes.cart);
  }

  Future<void> _contactSellerOnWhatsApp(ProductModel product) async {
    final WhatsAppOpenResult result = await ref
        .read(whatsappServiceProvider)
        .openChat(
          phone: product.sellerWhatsappNumber,
          message: WhatsAppService.productInquiryMessage(product),
        );
    if (!mounted) return;
    if (result.success) return;
    _showWhatsAppFallback(product, result.error!);
  }

  /// Repli si WhatsApp est indisponible : message affiché + copie possible.
  void _showWhatsAppFallback(ProductModel product, String error) {
    final String message = WhatsAppService.productInquiryMessage(product);
    showDialog<void>(
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
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: context.appColorScheme.surfaceContainerHighest,
                  borderRadius: AppRadius.rMd,
                ),
                child: Text(message, style: AppTypography.bodySmall()),
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
                if (!mounted) return;
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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<ProductModel?> productAsync =
        ref.watch(productByIdProvider(widget.productId));

    return Scaffold(
      body: productAsync.when(
        loading: () => const AppLoading(message: 'Chargement du produit…'),
        error: (Object error, StackTrace stackTrace) => Scaffold(
          appBar: AppBar(),
          body: AppError(
            title: 'Produit indisponible',
            message: 'Impossible de charger ce produit. Vérifiez votre connexion.',
            onRetry: () => ref.invalidate(productByIdProvider(widget.productId)),
          ),
        ),
        data: (ProductModel? product) {
          if (product == null) {
            return Scaffold(
              appBar: AppBar(),
              body: AppError(
                title: 'Produit introuvable',
                message:
                    "Ce produit n'existe plus ou a été retiré par le vendeur.",
                onRetry: () => context.go(AppRoutes.home),
                retryLabel: "Retour à l'accueil",
              ),
            );
          }
          return _ProductDetailsView(
            product: product,
            quantity: _quantity,
            onQuantityChanged: (int value) =>
                setState(() => _quantity = value),
            onAddToCart: () => _addToCart(product),
            onBuyNow: () => _buyNow(product),
            onContactSeller: () => _contactSellerOnWhatsApp(product),
          );
        },
      ),
    );
  }
}

/// Vue de la fiche produit (image + informations + barre d'achat).
class _ProductDetailsView extends StatelessWidget {
  const _ProductDetailsView({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onContactSeller,
  });

  final ProductModel product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onContactSeller;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _ImageHeader(product: product),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          product.name,
                          style: AppTypography.headlineSmall(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      _StockChip(product: product),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DisplayPrice(
                    amount: product.price,
                    oldAmount: product.oldPrice,
                    currency: product.currency,
                    style: AppTypography.headlineMedium(color: AppColors.primary),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: <Widget>[
                      const Icon(
                        Icons.storefront_outlined,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Vendu par ${product.sellerName}',
                          style: AppTypography.bodyMedium(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: onContactSeller,
                        icon: const Icon(Icons.chat_rounded, size: 17),
                        label: const Text('WhatsApp'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  _CategoryChip(product: product),
                  const SizedBox(height: AppSpacing.lg),
                  if (product.isLowStock) ...<Widget>[
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warningSoft,
                        borderRadius: AppRadius.rMd,
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(
                            Icons.local_fire_department_rounded,
                            size: 19,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Plus que ${product.stock} en stock — commandez vite !',
                              style: AppTypography.titleSmall(
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                  Text('Description', style: AppTypography.titleMedium()),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    product.description.isEmpty
                        ? 'Aucune description fournie par le vendeur.'
                        : product.description,
                    style: AppTypography.bodyMedium(),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _AssuranceTile(
                          icon: Icons.verified_user_outlined,
                          label: 'Paiement sécurisé',
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _AssuranceTile(
                          icon: Icons.local_shipping_outlined,
                          label: 'Livraison ou retrait',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _PurchaseBar(
        product: product,
        quantity: quantity,
        onQuantityChanged: onQuantityChanged,
        onAddToCart: onAddToCart,
        onBuyNow: onBuyNow,
      ),
    );
  }
}

/// Grande image produit avec retour flottant et badge promotion.
class _ImageHeader extends StatelessWidget {
  const _ImageHeader({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Stack(
      children: <Widget>[
        Hero(
          tag: 'product-image-${product.id}',
          child: AspectRatio(
            aspectRatio: 1.25,
            child: CachedNetworkImage(
              imageUrl: product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (BuildContext context, String url) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: const AppLoading(),
              ),
              errorWidget: (BuildContext context, String url, Object error) =>
                  Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_outlined, size: 56),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
          left: AppSpacing.sm,
          child: _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            tooltip: 'Retour',
            onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
          ),
        ),
        if (product.hasDiscount)
          Positioned(
            top: MediaQuery.paddingOf(context).top + AppSpacing.xs,
            right: AppSpacing.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: AppRadius.rFull,
              ),
              child: Text(
                '-${product.discountPercentage} %',
                style: AppTypography.titleSmall(color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}

/// Bouton circulaire flottant (retour sur l'image).
class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, size: 22, color: AppColors.textPrimary),
          ),
        ),
      ),
    );
  }
}

/// Pastille de disponibilité (en stock / stock faible / rupture).
class _StockChip extends StatelessWidget {
  const _StockChip({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    if (!product.inStock) {
      return const _ColoredChip(label: 'Rupture de stock', color: AppColors.error);
    }
    if (product.isLowStock) {
      return _ColoredChip(label: 'Plus que ${product.stock}', color: AppColors.warning);
    }
    return _ColoredChip(label: 'En stock (${product.stock})', color: AppColors.success);
  }
}

class _ColoredChip extends StatelessWidget {
  const _ColoredChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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

/// Puce catégorie : ouvre le catalogue filtré sur la catégorie.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: const Icon(Icons.category_outlined, size: 16),
      label: Text(product.categoryName.isEmpty ? 'Catégorie' : product.categoryName),
      onPressed: () => context.push(
        '${AppRoutes.productList}?categoryId=${Uri.encodeComponent(product.categoryId)}',
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rFull),
    );
  }
}

/// Tuile d'assurance (paiement sécurisé, livraison ou retrait).
class _AssuranceTile extends StatelessWidget {
  const _AssuranceTile({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.rMd,
      ),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: AppTypography.labelMedium(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// Barre d'achat collante : quantité (bornée au stock) + CTA.
class _PurchaseBar extends StatelessWidget {
  const _PurchaseBar({
    required this.product,
    required this.quantity,
    required this.onQuantityChanged,
    required this.onAddToCart,
    required this.onBuyNow,
  });

  final ProductModel product;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;

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
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: SafeArea(
        top: false,
        child: product.inStock
            ? Row(
                children: <Widget>[
                  _QuantityStepper(
                    quantity: quantity,
                    maxQuantity: product.stock,
                    onChanged: onQuantityChanged,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppButton(
                      label: 'Ajouter',
                      variant: AppButtonVariant.outline,
                      expanded: false,
                      height: 48,
                      onPressed: onAddToCart,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      label: 'Acheter maintenant',
                      expanded: false,
                      height: 48,
                      onPressed: onBuyNow,
                    ),
                  ),
                ],
              )
            : const AppButton(
                label: 'Produit en rupture de stock',
                onPressed: null,
              ),
      ),
    );
  }
}

/// Sélecteur de quantité : jamais supérieur au stock disponible.
class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
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
            tooltip: 'Diminuer la quantité',
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            icon: const Icon(Icons.remove_rounded, size: 18),
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
            tooltip: 'Augmenter la quantité',
            onPressed: quantity < maxQuantity ? () => onChanged(quantity + 1) : null,
            icon: const Icon(Icons.add_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}