import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasFavorites = true; // Set to true to demonstrate grid

    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(title: const Text('MES FAVORIS'), centerTitle: true),
      body: hasFavorites ? _buildFavoritesGrid() : _buildEmptyState(context),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 80,
              color: AppColors.black.withOpacity(0.1),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun favori pour le moment',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 16),
            const Text(
              'Sauvegardez les pièces qui vous inspirent pour les retrouver facilement.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.go('/collections'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.black),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'DÉCOUVRIR LES COLLECTIONS',
                  style: TextStyle(color: AppColors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 24,
        crossAxisSpacing: 24,
        childAspectRatio: 0.7,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return _buildFavoriteCard(index);
      },
    );
  }

  Widget _buildFavoriteCard(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.greySubtle,
                  borderRadius: BorderRadius.circular(16),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.pexels.com/photos/6347548/pexels-photo-6347548.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.red,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text('Pièce Unique #${100 + index}', style: AppTypography.labelLarge),
        Text(
          'Chris Couture',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.black.withOpacity(0.5),
          ),
        ),
      ],
    );
  }
}
