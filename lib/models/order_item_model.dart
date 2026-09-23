import '../core/constants/app_enums.dart';

/// Ligne de commande : instantané immuable du produit acheté (prix figé au
/// moment de la commande, même si le produit change ensuite).
class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.unitPrice,
    required this.currency,
    required this.quantity,
  });

  final String productId;
  final String productName;
  final String imageUrl;
  final double unitPrice;
  final AppCurrency currency;
  final int quantity;

  /// Total de la ligne (prix unitaire × quantité, devise d'origine).
  double get lineTotal => unitPrice * quantity;

  OrderItemModel copyWith({
    String? productId,
    String? productName,
    String? imageUrl,
    double? unitPrice,
    AppCurrency? currency,
    int? quantity,
  }) {
    return OrderItemModel(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
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
      'unitPrice': unitPrice,
      'currency': currency.name,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'] as String? ?? '',
      productName: map['productName'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0,
      currency: AppCurrency.fromName(map['currency'] as String?),
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
    );
  }

  /// Construit la ligne de commande depuis une ligne de panier.
  factory OrderItemModel.fromCart(CartItemLike item) {
    return OrderItemModel(
      productId: item.productId,
      productName: item.productName,
      imageUrl: item.imageUrl,
      unitPrice: item.unitPrice,
      currency: item.currency,
      quantity: item.quantity,
    );
  }
}

/// Structure minimale attendue d'une ligne de panier (découple le modèle
/// du provider Riverpod pour les tests).
abstract class CartItemLike {
  String get productId;
  String get productName;
  String get imageUrl;
  double get unitPrice;
  AppCurrency get currency;
  int get quantity;
}