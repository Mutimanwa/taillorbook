import 'dart:math' as math;

import 'package:uuid/uuid.dart';

import '../core/constants/app_enums.dart';
import '../core/errors/app_exceptions.dart';
import '../models/payment_model.dart';

/// Service de PAIEMENT SIMULÉ — aucune transaction financière réelle.
///
/// Simule le cycle Processing → Success ou Processing → Failure :
/// - délai de traitement configurable (réel : ~2,2 s ; tests : nul) ;
/// - issue déterministe en production (réussite ~90 %) ou injectable en test ;
/// - référence de transaction unique (`TX-SOKO-XXXXXXXX`) ;
/// - validations locales : numéro Mobile Money, numéro de carte 16 chiffres.
class PaymentSimulationService {
  PaymentSimulationService({
    math.Random? random,
    Duration processingDelay = const Duration(milliseconds: 2200),
    bool? forcedOutcome,
  })  : _random = random ?? math.Random(),
        _processingDelay = processingDelay,
        _forcedOutcome = forcedOutcome;

  static const double _successRate = 0.9;

  final math.Random _random;
  final Duration _processingDelay;
  final bool? _forcedOutcome;

  /// Numéro Mobile Money requis (8 chiffres minimum après normalisation).
  static String? validateMobileMoneyPhone(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 8) {
      return 'Saisissez un numéro Mobile Money valide (indicatif inclus).';
    }
    return null;
  }

  /// Numéro de carte : exactement 16 chiffres (algorithme de Luhn appliqué).
  static String? validateBankCardNumber(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[\s-]'), '');
    if (digits.length != 16 || int.tryParse(digits) == null) {
      return 'Le numéro de carte doit contenir 16 chiffres.';
    }
    if (!_luhnValid(digits)) {
      return 'Numéro de carte invalide.';
    }
    return null;
  }

  static bool _luhnValid(String digits) {
    int sum = 0;
    bool doubleDigit = false;
    for (int i = digits.length - 1; i >= 0; i--) {
      int digit = int.parse(digits[i]);
      if (doubleDigit) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      doubleDigit = !doubleDigit;
    }
    return sum % 10 == 0;
  }

  /// Génère une référence de transaction simulée unique.
  static String generateTransactionReference() {
    final String suffix = const Uuid().v4().replaceAll('-', '').substring(0, 8).toUpperCase();
    return 'TX-SOKO-$suffix';
  }

  /// Traite le paiement simulé et renvoie le [PaymentModel] résultant.
  ///
  /// Ne lève jamais d'exception : un échec est un [PaymentModel] avec le
  /// statut `failed` (l'interface empêche alors la confirmation).
  Future<PaymentModel> processPayment({
    required PaymentMethod method,
    required double amount,
    String mobileMoneyPhone = '',
    String cardNumber = '',
  }) async {
    // Phase « Processing » : laisse l'interface afficher l'animation.
    await Future<void>.delayed(_processingDelay);

    // Validations locales (échec immédiat sans hasard).
    if (method == PaymentMethod.mobileMoney) {
      final String? phoneError = validateMobileMoneyPhone(mobileMoneyPhone);
      if (phoneError != null) {
        return PaymentModel(
          method: method,
          status: PaymentStatus.failed,
          transactionReference: generateTransactionReference(),
          processedAt: DateTime.now(),
          amount: amount,
        );
      }
    } else {
      final String? cardError = validateBankCardNumber(cardNumber);
      if (cardError != null) {
        return PaymentModel(
          method: method,
          status: PaymentStatus.failed,
          transactionReference: generateTransactionReference(),
          processedAt: DateTime.now(),
          amount: amount,
        );
      }
    }

    final bool success = _forcedOutcome ?? (_random.nextDouble() < _successRate);

    return PaymentModel(
      method: method,
      status: success ? PaymentStatus.paid : PaymentStatus.failed,
      transactionReference: generateTransactionReference(),
      processedAt: DateTime.now(),
      amount: amount,
    );
  }
}