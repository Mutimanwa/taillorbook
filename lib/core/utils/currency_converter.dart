import '../constants/app_enums.dart';

/// Conversion entre les devises supportées (taux fixes de démonstration).
///
/// L'USD est la devise de base : toute conversion passe par elle
/// (`montant × taux source → USD → devise cible`).
///
/// ⚠️ Les taux sont figés dans [AppCurrency] et ne reflètent pas le marché —
/// mention légale affichée dans l'application ([AppConstants]).
class CurrencyConverter {
  CurrencyConverter._();

  /// Convertit [amount] de la devise [from] vers la devise [to].
  static double convert(double amount, AppCurrency from, AppCurrency to) {
    if (from == to) return amount;
    final double amountInUsd = amount * from.rateToUsd;
    return amountInUsd / to.rateToUsd;
  }
}
