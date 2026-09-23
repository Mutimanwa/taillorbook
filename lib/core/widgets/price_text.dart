import 'package:flutter/material.dart';

import '../constants/app_enums.dart';
import '../utils/money_formatter.dart';
import '../../app/theme/app_typography.dart';

/// Affichage standardisé d'un prix (montant + devise), avec ancien prix
/// barré optionnel pour les promotions.
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.amount,
    required this.currency,
    this.oldAmount,
    this.style,
    this.oldStyle,
    this.showOldPrice = true,
  });

  final double amount;
  final AppCurrency currency;

  /// Ancien prix (affiché barré si supérieur au prix courant).
  final double? oldAmount;
  final TextStyle? style;
  final TextStyle? oldStyle;
  final bool showOldPrice;

  @override
  Widget build(BuildContext context) {
    final TextStyle effectiveStyle =
        style ?? Theme.of(context).textTheme.titleMedium ?? AppTypography.titleMedium();
    final String current = MoneyFormatter.format(amount, currency);

    final bool hasDiscount =
        oldAmount != null && showOldPrice && oldAmount! > amount;
    if (!hasDiscount) {
      return Text(current, style: effectiveStyle, maxLines: 1, overflow: TextOverflow.ellipsis);
    }

    final TextStyle effectiveOldStyle = oldStyle ??
        Theme.of(context).textTheme.bodySmall?.copyWith(
              decoration: TextDecoration.lineThrough,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ) ??
        AppTypography.bodySmall();

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 2,
      children: <Widget>[
        Text(current, style: effectiveStyle),
        Text(
          MoneyFormatter.format(oldAmount!, currency),
          style: effectiveOldStyle,
        ),
      ],
    );
  }
}
