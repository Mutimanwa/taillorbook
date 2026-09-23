import 'package:intl/intl.dart';

import '../constants/app_enums.dart';

/// Formatage des montants monétaires selon la devise active.
///
/// Exemples :
/// - `12 500 FBu` (BIF, sans décimales)
/// - `24,99 US$` (USD, deux décimales)
/// - `18,50 €` (EUR, deux décimales)
class MoneyFormatter {
  MoneyFormatter._();

  /// Formate [amount] avec le symbole de [currency].
  static String format(double amount, AppCurrency currency) {
    final NumberFormat numberFormat = NumberFormat.decimalPattern('fr');
    if (currency == AppCurrency.bif) {
      // Le franc burundais s'affiche sans décimales.
      numberFormat.maximumFractionDigits = 0;
    } else {
      numberFormat
        ..minimumFractionDigits = 2
        ..maximumFractionDigits = 2;
    }
    return '${numberFormat.format(amount)} ${currency.symbol}';
  }

  /// Version sans symbole (utile dans les résumés compacts).
  static String formatWithoutSymbol(double amount, AppCurrency currency) {
    return format(amount, currency).replaceAll(' ${currency.symbol}', '');
  }
}
