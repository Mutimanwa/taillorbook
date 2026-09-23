import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../config/firebase/demo_data_seeder.dart';
import '../../../../config/firebase/firebase_bootstrap.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../services/firestore_service.dart';

/// Écran de lancement : logo animé (fondu + zoom léger) puis redirection
/// automatique vers l'accueil. Firebase est déjà initialisé dans `main()` ;
/// la navigation reste possible en mode démonstration.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    final CurvedAnimation curve = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _fade = curve;
    _scale = Tween<double>(begin: 0.85, end: 1).animate(curve);
    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future<void>.delayed(AppConstants.splashDuration);
    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[Colors.white, AppColors.primarySoft],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      AppAssets.logo,
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                      errorBuilder: (
                        BuildContext context,
                        Object error,
                        StackTrace? stackTrace,
                      ) {
                        return const Icon(
                          Icons.storefront_rounded,
                          size: 96,
                          color: AppColors.primary,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    style: AppTypography.displayLarge(color: AppColors.primaryDark),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppConstants.appSlogan,
                    style: AppTypography.bodyMedium(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 28),
                  const SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
