import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/theme/app_typography.dart';
import 'package:taillorbook/features/home/presentation/widgets/social_section.dart';
import 'package:taillorbook/features/home/presentation/widgets/masonry_creations.dart';
import 'package:taillorbook/core/widgets/skeleton_loader.dart';
import 'package:taillorbook/features/home/presentation/widgets/hero_carousel.dart';
import 'package:taillorbook/core/widgets/product_card.dart';

class HomeView extends StatelessWidget {
  final bool isAdmin;
  const HomeView({super.key, this.isAdmin = false});

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
            IconButton(
              onPressed: () => context.push('/search'),
              tooltip: 'Rechercher',
              icon: const Icon(Icons.search),
            ),
            IconButton(
              onPressed: () => context.push('/notifications'),
              tooltip: 'Notifications',
              icon: const Icon(Icons.notifications_none),
            ),
          ],
        ),
        const SliverPadding(
          padding: EdgeInsets.only(top: 16),
          sliver: SliverToBoxAdapter(child: HeroCarousel()),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Nos Collections', style: AppTypography.titleMedium),
                TextButton(
                  onPressed: () {
                    context.push('/collections');
                  },
                  child: const Text('Voir tout'),
                ),
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
              return _buildCollectionCard(context, index);
            }, childCount: 4),
          ),
        ),
        // Masonry Creations Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: MasonryCreations(isAdmin: isAdmin),
          ),
        ),
        // Social Section
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: SocialSection(isLoading: isLoading),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildCollectionCard(BuildContext context, int index) {
    return ProductCard(
      imageUrl:
          'https://images.pexels.com/photos/6347546/pexels-photo-6347546.jpeg',
      title: 'Collection Été ${2024 - index}',
      subtitle: '12 Pièces',
      onTap: () => context.push('/product-gallery'),
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
