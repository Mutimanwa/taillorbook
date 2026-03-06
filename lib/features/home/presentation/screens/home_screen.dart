import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/features/home/presentation/screens/home_view.dart';
import 'package:taillorbook/features/home/presentation/screens/collections_view.dart';
import 'package:taillorbook/features/home/presentation/screens/favorites_view.dart';
import 'package:taillorbook/features/home/presentation/screens/profile_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeView(),
    const CollectionsView(),
    const FavoritesView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomBar(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: AppColors.gold),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
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
