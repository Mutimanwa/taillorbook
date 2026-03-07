import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/theme/app_colors.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.transparent,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -10),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.black,
              borderRadius: BorderRadius.circular(32),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context,
                  Icons.home_outlined,
                  Icons.home,
                  '/home',
                  location,
                ),
                _buildNavItem(
                  context,
                  Icons.grid_view_outlined,
                  Icons.grid_view,
                  '/collections',
                  location,
                ),
                _buildNavItem(
                  context,
                  Icons.favorite_outline,
                  Icons.favorite,
                  '/favorites',
                  location,
                ),
                _buildNavItem(
                  context,
                  Icons.person_outline,
                  Icons.person,
                  '/profile',
                  location,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    IconData activeIcon,
    String path,
    String currentPath,
  ) {
    final isActive = currentPath == path;

    return Semantics(
      label: 'Accéder à ${path.replaceAll('/', '')}',
      button: true,
      child: IconButton(
        onPressed: () => context.go(path),
        icon: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? AppColors.gold : Colors.white.withOpacity(0.6),
          size: 26,
        ),
        tooltip: path.replaceAll('/', '').toUpperCase(),
      ),
    );
  }
}
