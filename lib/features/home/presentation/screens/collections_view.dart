import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';
import 'package:taillorbook/core/widgets/skeleton_loader.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLoading = false; // Mock loading state

    if (isLoading) {
      return _buildLoading();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('COLLECTIONS'), centerTitle: true),
      body: GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.7,
        ),
        itemCount: 8,
        itemBuilder: (context, index) {
          return _buildCollectionCard(index);
        },
      ),
    );
  }

  Widget _buildCollectionCard(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.greySubtle,
              borderRadius: BorderRadius.circular(16),
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.pexels.com/photos/6347546/pexels-photo-6347546.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Collection ${2024 - (index ~/ 2)}',
          style: AppTypography.labelLarge,
        ),
        Text(
          'Hiver / Été',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLoading() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.7,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SkeletonLoader(
                width: double.infinity,
                height: double.infinity,
                borderRadius: 16,
              ),
            ),
            SizedBox(height: 12),
            SkeletonLoader(width: 120, height: 20),
            SizedBox(height: 8),
            SkeletonLoader(width: 80, height: 16),
          ],
        );
      },
    );
  }
}
