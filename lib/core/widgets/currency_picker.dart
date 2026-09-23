import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taillorbook/core/extensions/context_extensions.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_enums.dart';
import '../../state/currency/currency_providers.dart';

/// Ouvre le sélecteur de devise d'affichage (bottom sheet réutilisable) :
/// BIF / USD / EUR avec mention explicite des taux fixes de démonstration.
Future<void> showCurrencyPickerSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => const _CurrencyPickerSheet(),
  );
}

class _CurrencyPickerSheet extends ConsumerWidget {
  const _CurrencyPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppCurrency selected = ref.watch(displayCurrencyProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Text("Devise d'affichage", style: AppTypography.headlineSmall()),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...AppCurrency.values.map(
              (AppCurrency currency) => RadioListTile<AppCurrency>(
                value: currency,
                groupValue: selected,
                onChanged: (AppCurrency? value) async {
                  if (value == null) return;
                  await ref
                      .read(displayCurrencyProvider.notifier)
                      .setCurrency(value);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                  context.showAppSnack(
                    'Prix affichés en ${value.label} (${value.symbol}).',
                    AppSnackType.success,
                  );
                },
                secondary: Text(
                  currency.symbol,
                  style: AppTypography.titleLarge(color: AppColors.primary),
                ),
                title: Text(currency.label, style: AppTypography.titleMedium()),
                subtitle: Text(
                  currency == AppCurrency.usd
                      ? 'Devise de base (taux 1:1)'
                      : 'Taux fixe de démonstration',
                  style: AppTypography.bodySmall(),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: AppRadius.rMd,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppConstants.currencyRatesDisclaimer,
                      style: AppTypography.labelSmall(
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}