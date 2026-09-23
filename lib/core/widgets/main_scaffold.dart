import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../state/cart/cart_providers.dart';

/// Coquille de navigation principale : barre inférieure à 5 sections
/// (Accueil, Catégories, Panier, Commandes, Profil) avec badge du panier.
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Consumer(
        builder: (BuildContext context, WidgetRef ref, _) {
          final int cartCount = ref.watch(cartTotalItemsProvider);
          return NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: (int index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
            destinations: <Widget>[
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Accueil',
              ),
              const NavigationDestination(
                icon: Icon(Icons.category_outlined),
                selectedIcon: Icon(Icons.category_rounded),
                label: 'Catégories',
              ),
              NavigationDestination(
                icon: _cartIcon(Icons.shopping_cart_outlined, cartCount),
                selectedIcon: _cartIcon(Icons.shopping_cart_rounded, cartCount),
                label: 'Panier',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'Commandes',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline_rounded),
                selectedIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          );
        },
      ),
    );
  }

  /// Icône du panier avec badge de quantité (affiché si > 0).
  Widget _cartIcon(IconData icon, int count) {
    if (count <= 0) return Icon(icon);
    return Badge(
      backgroundColor: AppColors.secondary,
      label: Text(
        '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
      child: Icon(icon),
    );
  }
}
