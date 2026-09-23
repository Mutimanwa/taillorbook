import '../core/constants/app_enums.dart';
import '../core/utils/timestamp_utils.dart';

/// Paiement d'une commande — STRICTEMENT simulé.
///
/// Aucune transaction financière réelle : le statut [PaymentStatus.paid] est
/// produit par le `PaymentSimulationService` (Mobile Money ou carte bancaire).
class PaymentModel {
  const PaymentModel({
    required this.method,
    required this.status,
    required this.transactionReference,
    this.processedAt,
    this.amount = 0,
  });

  final PaymentMethod method;
  final PaymentStatus status;

  /// Référence de transaction simulée (ex. TX-SOKO-XXXXXXXX).
  final String transactionReference;
  final DateTime? processedAt;

  /// Montant payé (devise de la commande).
  final double amount;

  bool get isPaid => status == PaymentStatus.paid;
  bool get isFailed => status == PaymentStatus.failed;

  PaymentModel copyWith({
    PaymentMethod? method,
    PaymentStatus? status,
    String? transactionReference,
    DateTime? processedAt,
    double? amount,
  }) {
    return PaymentModel(
      method: method ?? this.method,
      status: status ?? this.status,
      transactionReference: transactionReference ?? this.transactionReference,
      processedAt: processedAt ?? this.processedAt,
      amount: amount ?? this.amount,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'method': method.name,
      'status': status.name,
      'transactionReference': transactionReference,
      if (processedAt != null) 'processedAt': processedAt,
      'amount': amount,
    };
  }

  factory PaymentModel.fromMap(Map<String, dynamic> map) {
    return PaymentModel(
      method: PaymentMethod.fromName(map['method'] as String?),
      status: PaymentStatus.fromName(map['status'] as String?),
      transactionReference: map['transactionReference'] as String? ?? '',
      processedAt: TimestampUtils.toDateTime(map['processedAt']),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }
}