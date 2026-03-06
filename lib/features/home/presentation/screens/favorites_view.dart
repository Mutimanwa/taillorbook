import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Favoris', style: AppTypography.titleMedium));
}
