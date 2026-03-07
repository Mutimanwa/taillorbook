import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';
import 'package:go_router/go_router.dart';

class MasonryCreations extends StatelessWidget {
  final bool isAdmin;
  const MasonryCreations({super.key, this.isAdmin = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Créations Récentes', style: AppTypography.titleMedium),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Column 1
              Expanded(
                child: Column(
                  children: [
                    _buildItem(context, 300, 'Robe Longue Silk'),
                    const SizedBox(height: 16),
                    _buildItem(context, 200, 'Veste de Smoking'),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Column 2
              Expanded(
                child: Column(
                  children: [
                    _buildItem(context, 200, 'Top Satin'),
                    const SizedBox(height: 16),
                    _buildItem(context, 300, 'Pantalon Palazzo'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, double height, String title) {
    return GestureDetector(
      onTap: () => context.push('/product-detail'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: height,
                decoration: BoxDecoration(
                  color: AppColors.greySubtle,
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.pexels.com/photos/6347547/pexels-photo-6347547.jpeg',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (isAdmin)
                Positioned(
                  top: 10,
                  right: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.9),
                    radius: 16,
                    child: const Icon(
                      Icons.edit,
                      size: 14,
                      color: AppColors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: AppTypography.labelLarge),
        ],
      ),
    );
  }
}
