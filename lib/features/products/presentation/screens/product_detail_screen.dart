import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.7,
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.greySubtle,
              image: DecorationImage(
                image: NetworkImage('https://via.placeholder.com/800x1200'),
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
              height: MediaQuery.of(context).size.height * 0.4,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
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
                        const Icon(
                          Icons.favorite_border,
                          size: 30,
                          color: AppColors.black,
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
                      ),
                      child: Text(
                        'PRENDRE RENDEZ-VOUS',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
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
}
