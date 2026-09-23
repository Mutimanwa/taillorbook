import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_enums.dart';
import '../../core/utils/currency_converter.dart';
import '../../state/currency/currency_providers.dart';
import 'price_text.dart';

/// Prix affiché dans la **devise sélectionnée** par l'utilisateur.
///
/// Enveloppe [PriceText] en convertissant automatiquement le montant
/// (et l'ancien prix) depuis la devise du produit vers la devise
/// d'affichage ([displayCurrencyProvider], taux fixes de démonstration).
class DisplayPrice extends ConsumerWidget {
  const DisplayPrice({
    super.key,
    required this.amount,
    required this.currency,
    this.oldAmount,
    this.style,
    this.oldStyle,
    this.showOldPrice = true,
  });

  /// Montant dans sa devise d'origine ([currency]).
  final double amount;

  /// Devise d'origine du montant.
  final AppCurrency currency;

  /// Ancien prix (même devise d'origine), affiché barré si > [amount].
  final double? oldAmount;
  final TextStyle? style;
  final TextStyle? oldStyle;
  final bool showOldPrice;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency display = ref.watch(displayCurrencyProvider);

    return PriceText(
      amount: CurrencyConverter.convert(amount, currency, display),
      oldAmount: oldAmount == null
          ? null
          : CurrencyConverter.convert(oldAmount!, currency, display),
      currency: display,
      style: style,
      oldStyle: oldStyle,
      showOldPrice: showOldPrice,
    );
  }
}