import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          pinned: true,
          centerTitle: true,
          title: Text(
            'CHRIS COUTURE',
            style: AppTypography.titleMedium.copyWith(letterSpacing: 4),
          ),
          actions: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Container(
            height: 500,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.greySubtle,
              borderRadius: BorderRadius.circular(24),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/800x1200'),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  bottom: 30,
                  left: 30,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'NOUVELLE COLLECTION',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Élégance Intemporelle',
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nos Collections', style: AppTypography.titleMedium),
                TextButton(onPressed: () {}, child: const Text('Voir tout')),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.7,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return _buildCollectionCard(index);
            }, childCount: 4),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
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
                image: NetworkImage('https://via.placeholder.com/400x600'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text('Collection Été ${2024 - index}', style: AppTypography.labelLarge),
        Text('12 Pièces', style: AppTypography.bodyMedium),
      ],
    );
  }
}
