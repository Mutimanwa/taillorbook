import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';
import 'package:taillorbook/features/home/presentation/widgets/social_section.dart';
import 'package:taillorbook/features/home/presentation/widgets/masonry_creations.dart';
import 'package:taillorbook/core/widgets/skeleton_loader.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    const bool isLoading = false; // Mock loading state

    if (isLoading) {
      return _buildLoading();
    }

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
                image: NetworkImage('https://images.pexels.com/photos/265854/pexels-photo-265854.jpeg'),
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
        // Masonry Creations Section
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: MasonryCreations(),
          ),
        ),
        // Social Section
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: SocialSection(),
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
                image: NetworkImage('https://images.pexels.com/photos/6347546/pexels-photo-6347546.jpeg'),
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

  Widget _buildLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60),
          const SkeletonLoader(
            width: double.infinity,
            height: 400,
            borderRadius: 24,
          ),
          const SizedBox(height: 40),
          const SkeletonLoader(width: 200, height: 30),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: const SkeletonLoader(
                  width: double.infinity,
                  height: 250,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: const SkeletonLoader(
                  width: double.infinity,
                  height: 250,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
