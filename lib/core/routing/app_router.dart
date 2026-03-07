import 'package:go_router/go_router.dart';
import 'package:taillorbook/features/auth/presentation/screens/login_screen.dart';
import 'package:taillorbook/features/home/presentation/screens/home_screen.dart';
import 'package:taillorbook/features/products/presentation/screens/product_detail_screen.dart';
import 'package:taillorbook/features/splash/presentation/screens/splash_screen.dart';
import 'package:taillorbook/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:taillorbook/features/admin/presentation/screens/admin_dashboard.dart';

final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/product-detail',
      builder: (context, state) => const ProductDetailScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboard(),
    ),
  ],
);
