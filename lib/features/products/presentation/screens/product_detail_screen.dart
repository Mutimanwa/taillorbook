import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';
import 'package:taillorbook/core/widgets/skeleton_loader.dart';

class ProductDetailScreen extends StatelessWidget {
  final bool isLoading;
  final bool isGuest;

  const ProductDetailScreen({
    super.key,
    this.isLoading = false,
    this.isGuest = true,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoading(context);
    }

    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.greySubtle,
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.pexels.com/photos/6347547/pexels-photo-6347547.jpeg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back, color: AppColors.black),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Robe de Soirée Étoilée',
                                style: AppTypography.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Collection Été 2024',
                                style: AppTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _handleFavorite(context),
                          icon: const Icon(
                            Icons.favorite_border,
                            size: 30,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Une création exclusive réalisée dans notre atelier parisien. '
                      'Matières nobles et finitions à la main pour une élégance sans compromis.',
                      style: AppTypography.bodyLarge,
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        minimumSize: const Size(double.infinity, 64),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'PRENDRE RENDEZ-VOUS',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleFavorite(BuildContext context) {
    if (isGuest) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.favorite_border,
                size: 48,
                color: AppColors.gold,
              ),
              const SizedBox(height: 24),
              Text(
                'ENREGISTRER EN FAVORIS',
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Créez un compte pour sauvegarder vos pièces préférées et les retrouver à tout moment.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CRÉER UN COMPTE'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Pas maintenant'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildLoading(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SkeletonLoader(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.6,
            borderRadius: 0,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SkeletonLoader(width: 250, height: 30),
                  const SizedBox(height: 12),
                  const SkeletonLoader(width: 150, height: 20),
                  const SizedBox(height: 32),
                  const SkeletonLoader(width: double.infinity, height: 100),
                  const Spacer(),
                  const SkeletonLoader(
                    width: double.infinity,
                    height: 60,
                    borderRadius: 16,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
