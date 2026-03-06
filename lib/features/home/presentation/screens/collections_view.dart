import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Collections', style: AppTypography.titleMedium));
}
