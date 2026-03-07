import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/widgets/main_scaffold.dart';
import 'package:taillorbook/features/auth/presentation/screens/login_screen.dart';
import 'package:taillorbook/features/auth/presentation/screens/signup_screen.dart';
import 'package:taillorbook/features/auth/presentation/screens/forget_password_screen.dart';
import 'package:taillorbook/features/home/presentation/screens/collections_view.dart';
import 'package:taillorbook/features/home/presentation/screens/home_view.dart';
import 'package:taillorbook/features/search/presentation/screens/search_view.dart';
import 'package:taillorbook/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:taillorbook/features/products/presentation/screens/product_detail_screen.dart';
import 'package:taillorbook/features/splash/presentation/screens/splash_screen.dart';
import 'package:taillorbook/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:taillorbook/features/admin/presentation/screens/admin_dashboard.dart';
import 'package:taillorbook/features/appointments/presentation/screens/appointment_booking_screen.dart';
import 'package:taillorbook/features/products/presentation/screens/product_gallery_screen.dart';
import 'package:taillorbook/features/favorites/presentation/screens/favorites_screen.dart';
import 'package:taillorbook/features/profile/presentation/screens/profile_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/forget-password',
      builder: (context, state) => const ForgetPasswordScreen(),
    ),

    // ShellRoute for authenticated/main app experience
    ShellRoute(
      builder: (context, state, child) => MainScaffold(child: child),
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeView()),
        GoRoute(
          path: '/collections',
          builder: (context, state) => const CollectionsView(),
        ),
        GoRoute(
          path: '/favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),

    GoRoute(path: '/search', builder: (context, state) => const SearchView()),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),
    GoRoute(
      path: '/product-detail',
      builder: (context, state) => const ProductDetailScreen(),
    ),
    GoRoute(
      path: '/product-gallery',
      builder: (context, state) => const ProductGalleryScreen(),
    ),
    GoRoute(
      path: '/book-appointment',
      builder: (context, state) => const AppointmentBookingScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);
