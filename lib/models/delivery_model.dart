import '../core/constants/app_enums.dart';

/// Mode de réception choisi par le client (livraison ou retrait boutique).
class DeliveryModel {
  const DeliveryModel({
    required this.option,
    this.address = '',
    this.city = '',
    this.phone = '',
    this.additionalInfo = '',
    this.fee = 0,
  });

  final DeliveryOption option;

  /// Adresse complète (remplie uniquement si [option] == delivery).
  final String address;
  final String city;
  final String phone;
  final String additionalInfo;

  /// Frais de livraison dans la devise de la commande (0 en retrait).
  final double fee;

  bool get isDelivery => option == DeliveryOption.delivery;

  /// Lieu de réception synthétique (adresse complète ou « Retrait boutique »).
  String get locationLabel =>
      isDelivery ? '$address, $city' : 'Retrait en boutique';

  DeliveryModel copyWith({
    DeliveryOption? option,
    String? address,
    String? city,
    String? phone,
    String? additionalInfo,
    double? fee,
  }) {
    return DeliveryModel(
      option: option ?? this.option,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      additionalInfo: additionalInfo ?? this.additionalInfo,
      fee: fee ?? this.fee,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'option': option.name,
      'address': address,
      'city': city,
      'phone': phone,
      'additionalInfo': additionalInfo,
      'fee': fee,
    };
  }

  factory DeliveryModel.fromMap(Map<String, dynamic> map) {
    return DeliveryModel(
      option: DeliveryOption.fromName(map['option'] as String?),
      address: map['address'] as String? ?? '',
      city: map['city'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      additionalInfo: map['additionalInfo'] as String? ?? '',
      fee: (map['fee'] as num?)?.toDouble() ?? 0,
    );
  }
}