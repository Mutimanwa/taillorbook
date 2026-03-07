import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taillorbook/core/theme/app_colors.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.offWhite,
      highlightColor: AppColors.beige.withOpacity(0.5),
      period: const Duration(milliseconds: 1500),
      direction: ShimmerDirection
          .ltr, // Left to right is standard, but diagonal is achieved via gradient in highlight. Wait. ltr is fine.
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
