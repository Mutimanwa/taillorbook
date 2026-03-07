import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/features/home/presentation/screens/home_view.dart';
import 'package:taillorbook/features/home/presentation/screens/collections_view.dart';
import 'package:taillorbook/features/home/presentation/screens/favorites_view.dart';
import 'package:taillorbook/features/home/presentation/screens/profile_view.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _AdminHomeWrapper(),
    const _AdminCollectionsWrapper(),
    const FavoritesView(),
    const ProfileView(isGuest: false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'ADMIN MODE',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showQuickAddMenu,
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  void _showQuickAddMenu() {
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
            const Text(
              'AJOUTER DU CONTENU',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 32),
            _addOption(Icons.grid_view, 'Nouvelle Collection'),
            _addOption(Icons.inventory_2_outlined, 'Nouveau Produit'),
            _addOption(Icons.image_outlined, 'Nouveau Post Social'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _addOption(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon, color: AppColors.black),
      title: Text(label),
      onTap: () => Navigator.pop(context),
    );
  }

  Widget _buildBottomBar() {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      child: SizedBox(
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_outlined, 'Accueil'),
            _buildNavItem(1, Icons.grid_view, 'Collections'),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(2, Icons.favorite_border, 'Favoris'),
            _buildNavItem(3, Icons.person_outline, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? AppColors.black : Colors.grey,
            size: 26,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? AppColors.black : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminHomeWrapper extends StatelessWidget {
  const _AdminHomeWrapper();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const HomeView(),
        // Admin overlay button for the Hero section
        Positioned(
          top: 100,
          right: 20,
          child: FloatingActionButton.small(
            heroTag: 'edit_hero',
            onPressed: () {},
            backgroundColor: AppColors.gold,
            child: const Icon(Icons.edit, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _AdminCollectionsWrapper extends StatelessWidget {
  const _AdminCollectionsWrapper();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const CollectionsView(),
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton(
            heroTag: 'add_col',
            onPressed: () {},
            backgroundColor: AppColors.gold,
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
