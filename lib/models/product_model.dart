import '../core/constants/app_constants.dart';
import '../core/constants/app_enums.dart';
import '../core/utils/currency_converter.dart';
import '../core/utils/timestamp_utils.dart';
import '../models/cart_item_model.dart';

/// Produit de la marketplace (`products/{productId}`).
///
/// L'image est hébergée sur ImgBB : Firestore ne stocke que l'URL publique
/// (`imageUrl`). Les informations du vendeur sont dénormalisées pour
/// l'affichage et la création de commandes sans jointure.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.categoryId,
    required this.categoryName,
    required this.stock,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerWhatsappNumber,
    this.oldPrice,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final double price;
  final AppCurrency currency;

  /// Ancien prix affiché barré en cas de promotion (bonus).
  final double? oldPrice;

  final String categoryId;
  final String categoryName;
  final int stock;

  /// URL ImgBB publique de l'image produit.
  final String imageUrl;

  final String sellerId;
  final String sellerName;

  /// WhatsApp du vendeur (récapitulatif de commande).
  final String sellerWhatsappNumber;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ------------------------------------------------------------------ statut

  bool get inStock => stock > 0;

  /// `true` si le stock est faible (affichage « Plus que X en stock »).
  bool get isLowStock => inStock && stock <= AppConstants.lowStockThreshold;

  bool get hasDiscount => oldPrice != null && oldPrice! > price;

  /// Pourcentage de remise arrondi (0 si pas de promotion).
  int get discountPercentage =>
      hasDiscount ? (((oldPrice! - price) / oldPrice!) * 100).round() : 0;

  // ---------------------------------------------------------------- devises

  /// Prix converti dans la devise [target] (taux fixes de démonstration).
  double priceIn(AppCurrency target) =>
      CurrencyConverter.convert(price, currency, target);

  // ------------------------------------------------------------------ panier

  /// Convertit le produit en ligne de panier (instantané au moment de l'ajout).
  CartItemModel toCartItem({int quantity = 1}) {
    return CartItemModel(
      productId: id,
      productName: name,
      imageUrl: imageUrl,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerWhatsappNumber: sellerWhatsappNumber,
      unitPrice: price,
      currency: currency,
      quantity: quantity,
    );
  }

  // ------------------------------------------------------------ sérialisation

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    AppCurrency? currency,
    double? oldPrice,
    bool removeOldPrice = false,
    String? categoryId,
    String? categoryName,
    int? stock,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    String? sellerWhatsappNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      oldPrice: removeOldPrice ? null : (oldPrice ?? this.oldPrice),
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      stock: stock ?? this.stock,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerWhatsappNumber: sellerWhatsappNumber ?? this.sellerWhatsappNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'price': price,
      if (oldPrice != null) 'oldPrice': oldPrice,
      'currency': currency.name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'stock': stock,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerWhatsappNumber': sellerWhatsappNumber,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return ProductModel(
      id: id,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0,
      oldPrice: (map['oldPrice'] as num?)?.toDouble(),
      currency: AppCurrency.fromName(map['currency'] as String?),
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      stock: (map['stock'] as num?)?.toInt() ?? 0,
      imageUrl: map['imageUrl'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? '',
      sellerWhatsappNumber: map['sellerWhatsappNumber'] as String? ?? '',
      isActive: map['isActive'] as bool? ?? true,
      createdAt: TimestampUtils.toDateTime(map['createdAt']),
      updatedAt: TimestampUtils.toDateTime(map['updatedAt']),
    );
  }
}
