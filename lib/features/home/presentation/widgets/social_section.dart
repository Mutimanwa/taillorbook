import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';
import 'package:taillorbook/core/widgets/skeleton_loader.dart';

class SocialSection extends StatelessWidget {
  final bool isLoading;
  const SocialSection({super.key, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Suivez-nous', style: AppTypography.titleMedium),
              const Row(
                children: [
                  Icon(Icons.camera_alt_outlined, size: 20),
                  SizedBox(width: 8),
                  Icon(Icons.facebook_outlined, size: 20),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 10,
            itemBuilder: (context, index) {
              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: SkeletonLoader(
                    width: 180,
                    height: 180,
                    borderRadius: 16,
                  ),
                );
              }
              return Container(
                width: 180,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.greySubtle,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.pexels.com/photos/6347549/pexels-photo-6347549.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Icon(
                        index % 2 == 0
                            ? Icons.play_circle_outline
                            : Icons.collections_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
