import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/product_filters.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../core/widgets/product_quick_view.dart';
import '../../../../models/category_model.dart';
import '../../../../models/product_model.dart';
import '../../../../state/cart/cart_providers.dart';
import '../../../../state/products/products_providers.dart';

/// Catalogue produits : recherche, tri et filtres par catégorie.
///
/// Version de la phase « Modèles & catalogue » ; enrichie à la phase
/// « Catalogue public » (filtres de prix, disponibilité, vue liste).
class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({
    super.key,
    this.initialCategoryId,
    this.initialQuery = '',
  });

  final String? initialCategoryId;
  final String initialQuery;

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  late ProductFilter _filter = ProductFilter(
    query: widget.initialQuery,
    categoryId: widget.initialCategoryId,
  );

  final TextEditingController _searchController =
      TextEditingController(text: widget.initialQuery);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilter(ProductFilter Function(ProductFilter current) updater) {
    setState(() => _filter = updater(_filter));
  }

  void _addToCart(ProductModel product) {
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

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductModel>> productsAsync =
        ref.watch(activeProductsProvider);
    final List<ProductModel> allProducts =
        productsAsync.valueOrNull ?? const <ProductModel>[];
    final List<ProductModel> products = _filter.apply(allProducts);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _filter.categoryId == null ? 'Tous les produits' : 'Catalogue',
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.md,
              AppSpacing.pagePadding,
              0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (String value) =>
                  _updateFilter((ProductFilter f) => f.copyWith(query: value)),
              decoration: const InputDecoration(
                hintText: 'Rechercher un produit…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _CategoryChips(
            selectedCategoryId: _filter.categoryId,
            onSelected: (String? categoryId) => _updateFilter(
              (ProductFilter f) => f.copyWith(categoryId: categoryId),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    '${products.length} produit${products.length > 1 ? 's' : ''}',
                    style: context.appTextTheme.bodySmall,
                  ),
                ),
                _SortMenu(
                  current: _filter.sort,
                  onSelected: (ProductSortOption sort) =>
                      _updateFilter((ProductFilter f) => f.copyWith(sort: sort)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(child: _buildBody(context, productsAsync, products, allProducts)),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    AsyncValue<List<ProductModel>> productsAsync,
    List<ProductModel> products,
    List<ProductModel> allProducts,
  ) {
    if (productsAsync.isLoading && allProducts.isEmpty) {
      return GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.md,
          crossAxisSpacing: AppSpacing.md,
          childAspectRatio: 0.72,
        ),
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) => const ProductCardSkeleton(),
      );
    }

    if (productsAsync.hasError && allProducts.isEmpty) {
      return AppError(
        message: 'Impossible de charger les produits. Vérifiez votre connexion.',
        onRetry: () => ref.invalidate(activeProductsProvider),
      );
    }

    if (allProducts.isEmpty) {
      return const AppEmpty(
        icon: Icons.storefront_outlined,
        title: 'Catalogue vide',
        message:
            "Aucun produit n'a encore été publié. Revenez bientôt ou devenez vendeur !",
      );
    }

    if (products.isEmpty) {
      return AppEmpty(
        icon: Icons.search_off_rounded,
        title: 'Aucun résultat',
        message: 'Aucun produit ne correspond à votre recherche ou à vos filtres.',
        actionLabel: 'Réinitialiser les filtres',
        onAction: () {
          _searchController.clear();
          setState(
            () => _filter = ProductFilter(categoryId: _filter.categoryId),
          );
        },
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.sm,
        AppSpacing.pagePadding,
        AppSpacing.xl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.md,
        crossAxisSpacing: AppSpacing.md,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (BuildContext context, int index) {
        final ProductModel product = products[index];
        return ProductCard(
          product: product,
          onTap: () => showProductQuickView(context, product.id),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }
}

/// Menu de tri du catalogue.
class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.current, required this.onSelected});

  final ProductSortOption current;
  final ValueChanged<ProductSortOption> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<ProductSortOption>(
      initialValue: current,
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
      itemBuilder: (BuildContext context) => ProductSortOption.values
          .map(
            (ProductSortOption option) => PopupMenuItem<ProductSortOption>(
              value: option,
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 18,
                    child: option == current
                        ? const Icon(Icons.check_rounded, size: 18)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  Text(option.label),
                ],
              ),
            ),
          )
          .toList(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.sort_rounded, size: 18),
            const SizedBox(width: 6),
            Text(current.label, style: context.appTextTheme.titleSmall),
            const Icon(Icons.expand_more_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Chips de filtrage par catégorie (« Tout » + catégories actives).
class _CategoryChips extends ConsumerWidget {
  const _CategoryChips({
    required this.selectedCategoryId,
    required this.onSelected,
  });

  final String? selectedCategoryId;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<CategoryModel>> categoriesAsync =
        ref.watch(categoriesProvider);
    final List<CategoryModel> categories =
        categoriesAsync.valueOrNull ?? const <CategoryModel>[];

    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: const Text('Tout'),
              selected: selectedCategoryId == null,
              onSelected: (_) => onSelected(null),
              shape: RoundedRectangleBorder(borderRadius: AppRadius.rFull),
            ),
          ),
          ...categories.map(
            (CategoryModel category) => Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ChoiceChip(
                label: Text(category.name),
                selected: selectedCategoryId == category.id,
                onSelected: (_) => onSelected(category.id),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.rFull),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
