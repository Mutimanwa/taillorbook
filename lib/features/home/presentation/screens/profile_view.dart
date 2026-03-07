import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';
import 'package:go_router/go_router.dart';

class ProfileView extends StatelessWidget {
  final bool isGuest;

  const ProfileView({super.key, this.isGuest = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        title: const Text('PROFIL'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            // Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColors.greySubtle,
                    child: isGuest
                        ? const Icon(
                            Icons.person_outline,
                            size: 60,
                            color: AppColors.black,
                          )
                        : null,
                  ),
                  if (!isGuest)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.black,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isGuest ? 'Bienvenue Invité' : 'Chris Couture Client',
              style: AppTypography.titleMedium,
            ),
            const SizedBox(height: 40),

            if (isGuest)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    const Text(
                      'Créez un compte pour sauvegarder vos pièces préférées et gérer vos rendez-vous.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('CRÉER UN COMPTE'),
                    ),
                  ],
                ),
              )
            else
              _buildProfileSections(),

            const SizedBox(height: 40),
            _buildListTile(Icons.favorite_border, 'Mes favoris'),
            _buildListTile(Icons.calendar_today_outlined, 'Mes rendez-vous'),
            _buildListTile(Icons.notifications_none, 'Notifications'),
            _buildListTile(Icons.info_outline, 'À propos de Chris Couture'),

            const Divider(height: 40),
            _buildListTile(
              Icons.admin_panel_settings_outlined,
              'Portail Admin',
              onTap: () => context.push('/admin'),
            ),

            if (!isGuest)
              _buildListTile(Icons.logout, 'Déconnexion', isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSections() {
    return const Column(
      children: [
        // Real client sections would go here
      ],
    );
  }

  Widget _buildListTile(
    IconData icon,
    String title, {
    bool isDestructive = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : AppColors.black),
      title: Text(
        title,
        style: TextStyle(color: isDestructive ? Colors.red : AppColors.black),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap ?? () {},
    );
  }
}
