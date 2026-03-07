import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: AppColors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      const CircleAvatar(
                        radius: 40,
                        backgroundColor: AppColors.gold,
                        child: Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Invité Chris Couture',
                        style: AppTypography.labelLarge.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildProfileItem(
                    context,
                    Icons.notifications_none,
                    'Notifications',
                    () => context.push('/notifications'),
                  ),
                  _buildProfileItem(
                    context,
                    Icons.calendar_today_outlined,
                    'Mes Rendez-vous',
                    () {},
                  ),
                  _buildProfileItem(
                    context,
                    Icons.favorite_border,
                    'Liste de souhaits',
                    () => context.go('/favorites'),
                  ),
                  _buildProfileItem(
                    context,
                    Icons.settings_outlined,
                    'Paramètres',
                    () {},
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.black,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('SE CONNECTER / S\'INSCRIRE'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.greySubtle),
          ),
          child: Row(
            children: [
              Icon(icon, size: 22, color: AppColors.black),
              const SizedBox(width: 16),
              Text(title, style: AppTypography.bodyLarge),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.greySubtle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
