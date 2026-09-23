import '../core/constants/app_enums.dart';

/// Ligne du panier : un produit et sa quantité.
///
/// Le panier embarque toutes les informations nécessaires à l'affichage
/// (nom, image, vendeur...) afin de rester utilisable même si le produit
/// source devient temporairement indisponible sur Firestore.
class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.sellerId,
    required this.sellerName,
    required this.sellerWhatsappNumber,
    required this.unitPrice,
    required this.currency,
    this.quantity = 1,
  });

  final String productId;
  final String productName;
  final String imageUrl;

  final String sellerId;
  final String sellerName;

  /// Numéro WhatsApp du vendeur (utilisé pour le récapitulatif de commande).
  final String sellerWhatsappNumber;

  /// Prix unitaire dans la [currency] du produit.
  final double unitPrice;
  final AppCurrency currency;
  final int quantity;

  /// Total de la ligne (prix unitaire × quantité).
  double get lineTotal => unitPrice * quantity;

  /// `true` si le numéro WhatsApp du vendeur est renseigné.
  bool get hasSellerWhatsApp => sellerWhatsappNumber.trim().isNotEmpty;

  CartItemModel copyWith({
    String? productId,
    String? productName,
    String? imageUrl,
    String? sellerId,
    String? sellerName,
    String? sellerWhatsappNumber,
    double? unitPrice,
    AppCurrency? currency,
    int? quantity,
  }) {
    return CartItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerWhatsappNumber: sellerWhatsappNumber ?? this.sellerWhatsappNumber,
      unitPrice: unitPrice ?? this.unitPrice,
      currency: currency ?? this.currency,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'imageUrl': imageUrl,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerWhatsappNumber': sellerWhatsappNumber,
      'unitPrice': unitPrice,
      'currency': currency.name,
      'quantity': quantity,
    };
  }

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? '',
      sellerWhatsappNumber: map['sellerWhatsappNumber'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      currency: AppCurrency.fromName(map['currency'] as String?),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  /// Deux lignes pointant vers le même produit sont considérées égales :
  /// l'ajout d'un produit déjà présent augmente simplement sa quantité.
  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CartItemModel && other.productId == productId;

  @override
  int get hashCode => productId.hashCode;
}
