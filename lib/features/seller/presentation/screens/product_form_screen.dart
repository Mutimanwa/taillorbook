import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../features/seller/presentation/widgets/product_image_picker.dart';
import '../../../../models/category_model.dart';
import '../../../../models/product_model.dart';
import '../../../../state/products/products_providers.dart';
import '../../../../state/seller/seller_providers.dart';

/// Formulaire produit (création et édition).
///
/// - Création : tous les champs vides, image obligatoire (upload ImgBB) ;
/// - Édition : champs préremplis, image existante remplaçable.
///
/// La catégorie est choisie parmi les catégories actives de Firestore ;
/// le nom de catégorie est dénormalisé dans le produit (affichage sans
/// jointure).
class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key, this.productId});

  /// Produit à modifier ; `null` = mode création.
  final String? productId;

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _oldPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  AppCurrency _currency = AppCurrency.usd;
  String? _categoryId;
  String? _imageUrl;

  bool get _isEditMode => widget.productId != null;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _oldPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  /// Préremplit le formulaire à la première disponibilité du produit (édition).
  void _fillFromProduct(ProductModel product, List<CategoryModel> categories) {
    _nameController.text = product.name;
    _descriptionController.text = product.description;
    _priceController.text = _formatNumber(product.price);
    _oldPriceController.text =
        product.oldPrice == null ? '' : _formatNumber(product.oldPrice!);
    _stockController.text = '${product.stock}';
    _currency = product.currency;
    final List<String> categoryIds =
        categories.map((CategoryModel category) => category.id).toList();
    _categoryId =
        categoryIds.contains(product.categoryId) ? product.categoryId : null;
    _imageUrl = product.imageUrl;
    _initialized = true;
  }

  static String _formatNumber(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toString();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String? selectedCategoryId = _categoryId;
    if (selectedCategoryId == null) {
      context.showAppSnack('Veuillez choisir une catégorie.', AppSnackType.warning);
      return;
    }
    final String? imageUrl = _imageUrl;
    if (imageUrl == null || imageUrl.isEmpty) {
      context.showAppSnack(
        'Veuillez ajouter une photo du produit (obligatoire).',
        AppSnackType.warning,
      );
      return;
    }

    final CategoryModel? category = ref
        .read(categoriesProvider)
        .valueOrNull
        ?.where((CategoryModel category) => category.id == selectedCategoryId)
        .firstOrNull;
    final String categoryName = category?.name ?? '';

    final double price =
        double.parse(_priceController.text.trim().replaceAll(',', '.'));
    final String oldPriceRaw = _oldPriceController.text.trim();
    final double? oldPrice =
        oldPriceRaw.isEmpty ? null : double.parse(oldPriceRaw.replaceAll(',', '.'));
    final int stock = int.parse(_stockController.text.trim());

    final bool success;
    if (_isEditMode) {
      final ProductModel? existing =
          ref.read(productByIdProvider(widget.productId!)).valueOrNull;
      if (existing == null) {
        context.showAppSnack('Produit introuvable.', AppSnackType.error);
        return;
      }
      success = await ref
          .read(sellerProductControllerProvider.notifier)
          .updateProduct(
            existing.copyWith(
              name: _nameController.text.trim(),
              description: _descriptionController.text.trim(),
              price: price,
              oldPrice: oldPrice,
              removeOldPrice: oldPrice == null,
              currency: _currency,
              categoryId: selectedCategoryId,
              categoryName: categoryName,
              stock: stock,
              imageUrl: imageUrl,
            ),
          );
    } else {
      success = await ref
          .read(sellerProductControllerProvider.notifier)
          .createProduct(
            name: _nameController.text.trim(),
            description: _descriptionController.text.trim(),
            price: price,
            currency: _currency,
            categoryId: selectedCategoryId,
            categoryName: categoryName,
            stock: stock,
            imageUrl: imageUrl,
            oldPrice: oldPrice,
          );
    }

    if (!mounted) return;
    if (success) {
      context.showAppSnack(
        _isEditMode
            ? 'Produit mis à jour avec succès.'
            : 'Produit publié ! Il est désormais visible dans le catalogue.',
        AppSnackType.success,
      );
      context.pop();
    } else {
      final String? message = sellerProductErrorMessage(
          ref.read(sellerProductControllerProvider));
      context.showAppSnack(
        message ?? 'Enregistrement impossible.',
        AppSnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<CategoryModel>> categoriesAsync =
        ref.watch(categoriesProvider);
    final List<CategoryModel> categories =
        categoriesAsync.valueOrNull ?? const <CategoryModel>[];

    // Préremplissage (édition) une seule fois, quand le produit est chargé.
    final ProductModel? editingProduct =
        _isEditMode ? ref.watch(productByIdProvider(widget.productId!)).valueOrNull : null;
    if (_isEditMode && !_initialized && editingProduct != null) {
      _fillFromProduct(editingProduct, categories);
    }

    final bool saving = ref.watch(sellerProductControllerProvider).isLoading;
    final bool loadingProduct =
        _isEditMode && editingProduct == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Modifier le produit' : 'Nouveau produit'),
      ),
      body: loadingProduct
          ? const AppLoading(message: 'Chargement du produit…')
          : SafeArea(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  children: <Widget>[
                    ProductImagePicker(
                      initialUrl: _isEditMode ? _imageUrl : null,
                      onUploaded: (String url) => setState(() => _imageUrl = url),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    AppTextField(
                      controller: _nameController,
                      hintText: 'Nom du produit',
                      prefixIcon: Icons.shopping_bag_outlined,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      enabled: !saving,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _descriptionController,
                      hintText: 'Description détaillée',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                      textCapitalization: TextCapitalization.sentences,
                      enabled: !saving,
                      validator: Validators.required,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            controller: _priceController,
                            hintText: 'Prix',
                            prefixIcon: Icons.payments_outlined,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            enabled: !saving,
                            validator: Validators.price,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: DropdownButtonFormField<AppCurrency>(
                            initialValue: _currency,
                            decoration: const InputDecoration(labelText: 'Devise'),
                            items: AppCurrency.values
                                .map(
                                  (AppCurrency currency) =>
                                      DropdownMenuItem<AppCurrency>(
                                    value: currency,
                                    child: Text(
                                      '${currency.symbol} — ${currency.label}',
                                      style: AppTypography.bodySmall(),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: saving
                                ? null
                                : (AppCurrency? value) {
                                    if (value != null) {
                                      setState(() => _currency = value);
                                    }
                                  },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _oldPriceController,
                      hintText: 'Ancien prix (optionnel, pour les promos)',
                      prefixIcon: Icons.sell_outlined,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      enabled: !saving,
                      validator: (String? value) {
                        if (value == null || value.trim().isEmpty) return null;
                        return Validators.price(value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _categoryId,
                      decoration: const InputDecoration(labelText: 'Catégorie'),
                      items: categories
                          .map(
                            (CategoryModel category) => DropdownMenuItem<String>(
                              value: category.id,
                              child: Text(
                                category.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: saving
                          ? null
                          : (String? value) => setState(() => _categoryId = value),
                      validator: (String? value) =>
                          value == null ? 'Veuillez choisir une catégorie' : null,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    AppTextField(
                      controller: _stockController,
                      hintText: 'Stock disponible (0 = rupture)',
                      prefixIcon: Icons.inventory_outlined,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      enabled: !saving,
                      validator: Validators.stock,
                    ),
                    if (categories.isEmpty) ...<Widget>[
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: <Widget>[
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 15,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "Aucune catégorie n'a été chargée. Lancez l'application "
                              'avec Firebase configuré, puis réessayez.',
                              style: AppTypography.labelSmall(),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    AppButton(
                      label: _isEditMode
                          ? 'Enregistrer les modifications'
                          : 'Publier le produit',
                      icon:
                          _isEditMode ? Icons.save_outlined : Icons.publish_rounded,
                      loading: saving,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      "L'image est hébergée sur ImgBB ; seule l'URL publique est "
                      'enregistrée dans Firestore.',
                      style: AppTypography.labelSmall(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
    );
  }
}