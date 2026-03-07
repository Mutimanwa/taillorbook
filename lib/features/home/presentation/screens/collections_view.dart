import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class CollectionsView extends StatelessWidget {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context) {
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
          child: Semantics(
            label: 'Aperçu de la collection ${2024 - (index ~/ 2)}',
            image: true,
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
}
