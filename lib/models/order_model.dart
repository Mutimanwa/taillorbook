import '../core/constants/app_enums.dart';
import '../core/utils/timestamp_utils.dart';
import 'delivery_model.dart';
import 'order_item_model.dart';
import 'payment_model.dart';

/// Commande (`orders/{orderId}`).
///
/// v1 : une commande concerne UN SEUL vendeur (les informations vendeur sont
/// dénormalisées pour permettre au vendeur de lister « ses » commandes et
/// pour construire le récapitulatif WhatsApp sans jointure).
class OrderModel {
  const OrderModel({
    required this.orderId,
    required this.clientId,
    required this.clientName,
    required this.clientPhone,
    required this.sellerId,
    required this.sellerName,
    required this.sellerWhatsappNumber,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.currency,
    required this.delivery,
    required this.payment,
    this.orderStatus = OrderStatus.pending,
    this.createdAt,
    this.updatedAt,
  });

  final String orderId;
  final String clientId;
  final String clientName;
  final String clientPhone;

  final String sellerId;
  final String sellerName;

  /// WhatsApp du vendeur (récapitulatif de commande).
  final String sellerWhatsappNumber;

  final List<OrderItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final AppCurrency currency;
  final DeliveryModel delivery;
  final PaymentModel payment;
  final OrderStatus orderStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isStorePickup => !delivery.isDelivery;
  int get totalQuantity => items.fold<int>(
        0,
        (int total, OrderItemModel item) => total + item.quantity,
      );

  OrderModel copyWith({
    String? orderId,
    String? clientId,
    String? clientName,
    String? clientPhone,
    String? sellerId,
    String? sellerName,
    String? sellerWhatsappNumber,
    List<OrderItemModel>? items,
    double? subtotal,
    double? deliveryFee,
    double? total,
    AppCurrency? currency,
    DeliveryModel? delivery,
    PaymentModel? payment,
    OrderStatus? orderStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      clientId: clientId ?? this.clientId,
      clientName: clientName ?? this.clientName,
      clientPhone: clientPhone ?? this.clientPhone,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      sellerWhatsappNumber: sellerWhatsappNumber ?? this.sellerWhatsappNumber,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      total: total ?? this.total,
      currency: currency ?? this.currency,
      delivery: delivery ?? this.delivery,
      payment: payment ?? this.payment,
      orderStatus: orderStatus ?? this.orderStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderId': orderId,
      'clientId': clientId,
      'clientName': clientName,
      'clientPhone': clientPhone,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerWhatsappNumber': sellerWhatsappNumber,
      'items': items.map((OrderItemModel item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'total': total,
      'currency': currency.name,
      'delivery': delivery.toMap(),
      'payment': payment.toMap(),
      'orderStatus': orderStatus.name,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return OrderModel(
      orderId: map['orderId'] as String? ?? id,
      clientId: map['clientId'] as String? ?? '',
      clientName: map['clientName'] as String? ?? '',
      clientPhone: map['clientPhone'] as String? ?? '',
      sellerId: map['sellerId'] as String? ?? '',
      sellerName: map['sellerName'] as String? ?? '',
      sellerWhatsappNumber: map['sellerWhatsappNumber'] as String? ?? '',
      items: ((map['items'] as List<dynamic>?) ?? const <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromMap)
          .toList(),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (map['deliveryFee'] as num?)?.toDouble() ?? 0,
      total: (map['total'] as num?)?.toDouble() ?? 0,
      currency: AppCurrency.fromName(map['currency'] as String?),
      delivery: DeliveryModel.fromMap(
        ((map['delivery'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
      ),
      payment: PaymentModel.fromMap(
        ((map['payment'] as Map<String, dynamic>?) ?? const <String, dynamic>{}),
      ),
      orderStatus: OrderStatus.fromName(map['orderStatus'] as String?),
      createdAt: TimestampUtils.toDateTime(map['createdAt']),
      updatedAt: TimestampUtils.toDateTime(map['updatedAt']),
    );
  }
}