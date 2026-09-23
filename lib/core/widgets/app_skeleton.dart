import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_radius.dart';
import '../../app/theme/app_spacing.dart';

/// Bloc gris animé (effet shimmer) affiché pendant les chargements :
/// donne une perception de rapidité avant l'arrivée des données.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width = double.infinity,
    this.height = 16,
    this.radius = AppRadius.rMd,
  });

  final double width;
  final double height;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.border,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: radius,
        ),
      ),
    );
  }
}

/// Squelette d'une carte produit (grilles « En vedette », « Nouveautés »...).
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppSkeleton(height: 130, radius: AppRadius.rLg),
          SizedBox(height: 10),
          FractionallySizedBox(
            widthFactor: 0.85,
            child: AppSkeleton(height: 13),
          ),
          SizedBox(height: 6),
          FractionallySizedBox(
            widthFactor: 0.5,
            child: AppSkeleton(height: 13),
          ),
          SizedBox(height: 8),
          FractionallySizedBox(
            widthFactor: 0.4,
            child: AppSkeleton(height: 15),
          ),
        ],
      ),
    );
  }
}
