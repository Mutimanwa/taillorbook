import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/product_filters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/product_quick_view.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../models/category_model.dart';
import '../../../../models/product_model.dart';
import '../../../../state/app/app_state.dart';
import '../../../../state/cart/cart_providers.dart';
import '../../../../state/products/products_providers.dart';

/// Onglet Accueil : en-tête de marque, recherche, bannière promotionnelle,
/// catégories et produits (en vedette / nouveautés) chargés depuis Firestore
/// avec skeletons de chargement et états de repli soignés.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _firebaseNoticeVisible = true;

  @override
  Widget build(BuildContext context) {
    final bool firebaseReady = ref.watch(firebaseReadyProvider);
    final AsyncValue<List<CategoryModel>> categoriesAsync =
        ref.watch(categoriesProvider);
    final AsyncValue<List<ProductModel>> productsAsync =
        ref.watch(activeProductsProvider);
    final List<ProductModel> products = productsAsync.valueOrNull ?? const <ProductModel>[];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!firebaseReady && _firebaseNoticeVisible)
                _FirebaseNoticeBanner(
                  onDismiss: () => setState(() => _firebaseNoticeVisible = false),
                ),
              const SizedBox(height: AppSpacing.sm),
              const _HomeHeader(),
              const SizedBox(height: AppSpacing.lg),
              _SearchField(
                onTap: () => context.push(AppRoutes.productList),
              ),
              const SizedBox(height: AppSpacing.lg),
              const _PromoBanner(),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Catégories',
                actionLabel: 'Voir tout',
                onAction: () => context.go(AppRoutes.categories),
              ),
              const SizedBox(height: AppSpacing.md),
              _CategoryRail(asyncCategories: categoriesAsync),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Produits en vedette',
                actionLabel: 'Tout voir',
                onAction: () => context.push(AppRoutes.productList),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProductRail(
                asyncProducts: productsAsync,
                products: _featuredProducts(products),
                emptyMessage: 'Le catalogue sera bientôt disponible.',
                onRetry: () => ref.invalidate(activeProductsProvider),
              ),
              const SizedBox(height: AppSpacing.xl),
              SectionHeader(
                title: 'Nouveautés',
                actionLabel: 'Tout voir',
                onAction: () => context.push(AppRoutes.productList),
              ),
              const SizedBox(height: AppSpacing.md),
              _ProductRail(
                asyncProducts: productsAsync,
                products: _newestProducts(products),
                emptyMessage: 'Les nouveautés apparaîtront ici.',
                onRetry: () => ref.invalidate(activeProductsProvider),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Pourquoi SokoMarket ?'),
              const SizedBox(height: AppSpacing.md),
              const _WhySection(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  /// En vedette : meilleures promotions d'abord, puis les plus récents.
  List<ProductModel> _featuredProducts(List<ProductModel> products) {
    final List<ProductModel> featured = ProductFilter(sort: ProductSortOption.discount)
        .apply(products);
    if (featured.where((ProductModel p) => p.hasDiscount).length >= 3) {
      return featured.take(6).toList();
    }
    return products.take(6).toList();
  }

  /// Nouveautés : tri par date de création décroissante.
  List<ProductModel> _newestProducts(List<ProductModel> products) {
    return ProductFilter(sort: ProductSortOption.newest).apply(products).take(6).toList();
  }
}

/// Bannière d'information affichée uniquement si Firebase est indisponible.
class _FirebaseNoticeBanner extends StatelessWidget {
  const _FirebaseNoticeBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        0,
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Mode démonstration : Firebase n'est pas configuré sur cette "
              'installation. Exécutez « flutterfire configure » pour activer '
              'les données en direct.',
              style: AppTypography.labelMedium(color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// En-tête : logo, nom de marque et notifications.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.rMd,
            child: Image.asset(
              AppAssets.logo,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return const Icon(
                  Icons.storefront_rounded,
                  size: 38,
                  color: AppColors.primary,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(AppConstants.appName, style: AppTypography.titleLarge()),
                Text(
                  'Bienvenue sur votre marketplace',
                  style: AppTypography.bodySmall(),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                context.showAppSnack('Aucune notification pour le moment.'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

/// Barre de recherche redirigeant vers le catalogue filtrable.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: TextField(
        readOnly: true,
        onTap: onTap,
        decoration: const InputDecoration(
          hintText: 'Rechercher un produit…',
          prefixIcon: Icon(Icons.search_rounded),
          suffixIcon: Icon(Icons.tune_rounded, size: 22),
        ),
      ),
    );
  }
}

/// Bannière promotionnelle avec dégradé de marque.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.promoGradient,
          ),
          borderRadius: AppRadius.rXl,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: AppRadius.rFull,
                    ),
                    child: Text(
                      'OFFRE SPÉCIALE',
                      style: AppTypography.labelSmall(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Jusqu'à -40 %\nsur une sélection",
                    style: AppTypography.headlineMedium(color: Colors.white)
                        .copyWith(height: 1.25),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'Découvrir',
                    variant: AppButtonVariant.secondary,
                    expanded: false,
                    height: 40,
                    onPressed: () => context.push(AppRoutes.productList),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.shopping_bag_rounded, size: 76, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

/// Carrousel horizontal des catégories actives.
class _CategoryRail extends ConsumerWidget {
  const _CategoryRail({required this.asyncCategories});

  final AsyncValue<List<CategoryModel>> asyncCategories;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return asyncCategories.when(
      loading: () => SizedBox(
        height: 108,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          itemCount: 5,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(width: AppSpacing.md),
          itemBuilder: (BuildContext context, int index) => const AppSkeleton(
            width: 96,
            height: 96,
            radius: AppRadius.rLg,
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (List<CategoryModel> categories) {
        if (categories.isEmpty) {
          return const _RailEmptyMessage(
            message: 'Aucune catégorie pour le moment.',
          );
        }
        return SizedBox(
          height: 108,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            itemCount: categories.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(width: AppSpacing.md),
            itemBuilder: (BuildContext context, int index) => _CategoryCard(
              category: categories[index],
            ),
          ),
        );
      },
    );
  }
}

/// Puce circulaire d'une catégorie du carrousel.
class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(
        '${AppRoutes.productList}?categoryId=${Uri.encodeComponent(category.id)}',
      ),
      borderRadius: AppRadius.rLg,
      child: SizedBox(
        width: 96,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ClipRRect(
              borderRadius: AppRadius.rLg,
              child: CachedNetworkImage(
                imageUrl: category.imageUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) => Container(
                  width: 72,
                  height: 72,
                  color: context.appColorScheme.surfaceContainerHighest,
                ),
                errorWidget: (BuildContext context, String url, Object error) =>
                    Container(
                  width: 72,
                  height: 72,
                  color: context.appColorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.category_outlined, size: 24),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              style: AppTypography.labelSmall(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Carrousel horizontal de cartes produits, avec états de chargement et vide.
class _ProductRail extends ConsumerWidget {
  const _ProductRail({
    required this.asyncProducts,
    required this.products,
    required this.emptyMessage,
    required this.onRetry,
  });

  final AsyncValue<List<ProductModel>> asyncProducts;
  final List<ProductModel> products;
  final String emptyMessage;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (asyncProducts.isLoading && products.isEmpty) {
      return SizedBox(
        height: 288,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
          itemCount: 3,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(width: AppSpacing.md),
          itemBuilder: (BuildContext context, int index) =>
              const SizedBox(width: 172, child: ProductCardSkeleton()),
        ),
      );
    }

    if (asyncProducts.hasError && products.isEmpty) {
      return _RailError(onRetry: onRetry);
    }

    if (products.isEmpty) {
      return _RailEmptyMessage(message: emptyMessage);
    }

    return SizedBox(
      height: 288,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        itemCount: products.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: AppSpacing.md),
        itemBuilder: (BuildContext context, int index) {
          final ProductModel product = products[index];
          return ProductCard(
            product: product,
            width: 172,
            onTap: () => showProductQuickView(context, product.id),
            onAddToCart: () => _addToCart(context, ref, product),
          );
        },
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, ProductModel product) {
    if (!product.inStock) {
      context.showAppSnack('Ce produit est en rupture de stock.', AppSnackType.error);
      return;
    }
    ref
        .read(cartProvider.notifier)
        .addItem(product.toCartItem(), maxQuantity: product.stock);
    context.showAppSnack(
      '« ${product.name} » ajouté au panier.',
      AppSnackType.success,
    );
  }
}

/// Message compact d'un carrousel vide.
class _RailEmptyMessage extends StatelessWidget {
  const _RailEmptyMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePadding,
        vertical: AppSpacing.lg,
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.inbox_outlined, size: 20, color: AppColors.textDisabled),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTypography.bodySmall())),
        ],
      ),
    );
  }
}

/// Erreur compacte d'un carrousel avec réessayer.
class _RailError extends StatelessWidget {
  const _RailError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: <Widget>[
          const Icon(Icons.wifi_off_rounded, size: 20, color: AppColors.error),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Chargement impossible. Vérifiez votre connexion.',
              style: AppTypography.bodySmall(),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              'Réessayer',
              style: AppTypography.titleSmall(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rangée d'arguments de confiance de la marketplace.
class _WhySection extends StatelessWidget {
  const _WhySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _WhyCard(
              icon: Icons.verified_user_outlined,
              title: 'Achats sécurisés',
              description: 'Paiement vérifié avant confirmation de commande.',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _WhyCard(
              icon: Icons.local_shipping_outlined,
              title: 'Livraison ou retrait',
              description: 'Choisissez votre mode de réception préféré.',
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  const _WhyCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.titleSmall(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTypography.labelMedium(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
