import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../models/category_model.dart';
import '../../../../state/products/products_providers.dart';

/// Onglet Catégories : grille des catégories actives de Firestore avec
/// nombre de produits, skeletons pendant le chargement et états vides/erreur.
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CategoryModel>> categoriesAsync =
        ref.watch(categoriesProvider);
    final Map<String, int> productCounts =
        ref.watch(productCountByCategoryProvider);

    Widget body;

    if (categoriesAsync.isLoading) {
      body = GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.25,
        ),
        itemCount: 4,
        itemBuilder: (BuildContext context, int index) => const _CategoryCardSkeleton(),
      );
    } else if (categoriesAsync.hasError) {
      body = AppError(
        message: 'Impossible de charger les catégories.',
        onRetry: () => ref.invalidate(categoriesProvider),
      );
    } else if (categoriesAsync.valueOrNull?.isEmpty ?? true) {
      body = const Center(
        child: AppEmpty(
          icon: Icons.category_outlined,
          title: 'Aucune catégorie',
          message:
              "Les catégories de la marketplace s'afficheront ici dès leur publication.",
        ),
      );
    } else {
      final List<CategoryModel> categories = categoriesAsync.valueOrNull!;
      body = GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.25,
        ),
        itemCount: categories.length,
        itemBuilder: (BuildContext context, int index) => _CategoryCard(
          category: categories[index],
          productCount: productCounts[categories[index].id] ?? 0,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: body,
    );
  }
}

/// Carte d'une catégorie : image, nom et nombre de produits.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.productCount});

  final CategoryModel category;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.push(
        '${AppRoutes.productList}?categoryId=${Uri.encodeComponent(category.id)}',
      ),
      borderRadius: AppRadius.rLg,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.rLg,
          border: Border.all(color: colorScheme.outline),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            CachedNetworkImage(
              imageUrl: category.imageUrl,
              fit: BoxFit.cover,
              placeholder: (BuildContext context, String url) =>
                  Container(color: colorScheme.surfaceContainerHighest),
              errorWidget: (BuildContext context, String url, Object error) =>
                  Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.category_outlined),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[Colors.transparent, Colors.black54],
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    category.name,
                    style: AppTypography.titleSmall(color: Colors.white),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '$productCount produit${productCount > 1 ? 's' : ''}',
                    style: AppTypography.labelSmall(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Squelette d'une carte de catégorie.
class _CategoryCardSkeleton extends StatelessWidget {
  const _CategoryCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: const AppSkeleton(height: double.infinity),
    );
  }
}
