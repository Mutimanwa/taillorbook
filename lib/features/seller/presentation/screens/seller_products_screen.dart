import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/app/theme/app_colors.dart';
import 'package:taillorbook/app/theme/app_typography.dart';
import 'package:taillorbook/core/widgets/app_error.dart' show AppError;

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';

import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/price_text.dart';
import '../../../../models/product_model.dart';
import '../../../../state/seller/seller_providers.dart';

/// « Mes produits » : liste des produits du vendeur avec activation,
/// modification et suppression (avec confirmation).
class SellerProductsScreen extends ConsumerWidget {
  const SellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProductModel>?> productsAsync =
        ref.watch(sellerProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes produits')),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'seller-add-product',
        onPressed: () => context.push(AppRoutes.sellerCreateProduct),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Produit'),
      ),
      body: productsAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          itemCount: 4,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: AppSpacing.md),
          itemBuilder: (BuildContext context, int index) => const SizedBox(
            height: 96,
            child: AppSkeleton(height: 96, radius: AppRadius.rLg),
          ),
        ),
        error: (Object error, StackTrace stackTrace) => AppError(
          message: 'Impossible de charger vos produits.',
          onRetry: () => ref.invalidate(sellerProductsProvider),
        ),
        data: (List<ProductModel>? products) {
          if (products == null) {
            return const Center(
              child: AppEmpty(
                icon: Icons.lock_outline_rounded,
                title: 'Compte vendeur requis',
                message: "Connectez-vous avec un compte vendeur pour gérer vos produits.",
              ),
            );
          }
          if (products.isEmpty) {
            return Center(
              child: AppEmpty(
                icon: Icons.inventory_2_outlined,
                title: 'Aucun produit',
                message:
                    "Publiez votre premier produit : il apparaîtra immédiatement dans le catalogue.",
                actionLabel: 'Publier un produit',
                onAction: () => context.push(AppRoutes.sellerCreateProduct),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sellerProductsProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePadding,
                AppSpacing.md,
                AppSpacing.pagePadding,
                AppSpacing.xxl,
              ),
              itemCount: products.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.md),
              itemBuilder: (BuildContext context, int index) => _SellerProductCard(
                product: products[index],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Carte produit du vendeur : image, infos, switch d'activation,
/// édition et suppression.
class _SellerProductCard extends ConsumerWidget {
  const _SellerProductCard({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ColorScheme colorScheme = context.appColorScheme;
    final AsyncValue<void> actionState = ref.watch(sellerProductControllerProvider);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.rMd,
            child: SizedBox(
              width: 64,
              height: 64,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    Container(color: colorScheme.surfaceContainerHighest),
                errorWidget: (BuildContext context, String url, Object error) =>
                    Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_outlined),
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
                  product.name,
                  style: context.appTextTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                PriceText(
                  amount: product.price,
                  oldAmount: product.oldPrice,
                  currency: product.currency,
                  style: context.appTextTheme.titleSmall
                      ?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(height: 2),
                Text(
                  product.inStock
                      ? 'Stock : ${product.stock}'
                      : 'Rupture de stock',
                  style: AppTypography.labelSmall(
                    color: product.inStock ? null : AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Switch(
                value: product.isActive,
                onChanged: actionState.isLoading
                    ? null
                    : (bool value) => _toggleActive(context, ref, value),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  IconButton(
                    tooltip: 'Modifier',
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => context.push(
                      AppRoutes.sellerEditProduct(product.id),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Supprimer',
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.delete_outline_rounded,
                      size: 20,
                      color: colorScheme.error,
                    ),
                    onPressed: actionState.isLoading
                        ? null
                        : () => _confirmDelete(context, ref),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _toggleActive(
    BuildContext context,
    WidgetRef ref,
    bool value,
  ) async {
    final bool success = await ref
        .read(sellerProductControllerProvider.notifier)
        .setProductActive(product, isActive: value);
    if (!context.mounted) return;
    context.showAppSnack(
      success
          ? (value
              ? '« ${product.name} » est de nouveau visible dans le catalogue.'
              : '« ${product.name} » est masqué du catalogue.')
          : (sellerProductErrorMessage(
                  ref.read(sellerProductControllerProvider)) ??
              'Action impossible.'),
      success ? AppSnackType.success : AppSnackType.error,
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await context.showConfirmDialog(
      title: 'Supprimer le produit',
      message:
          'Voulez-vous vraiment supprimer « ${product.name} » ? Cette action est définitive.',
      confirmLabel: 'Supprimer',
      destructive: true,
    );
    if (!confirmed || !context.mounted) return;

    final bool success = await ref
        .read(sellerProductControllerProvider.notifier)
        .deleteProduct(product);
    if (!context.mounted) return;
    context.showAppSnack(
      success
          ? '« ${product.name} » a été supprimé.'
          : (sellerProductErrorMessage(
                  ref.read(sellerProductControllerProvider)) ??
              'Suppression impossible.'),
      success ? AppSnackType.success : AppSnackType.error,
    );
  }
}