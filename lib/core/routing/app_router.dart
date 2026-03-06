import 'package:go_router/go_router.dart';
import 'package:taillorbook/features/auth/presentation/screens/login_screen.dart';
import 'package:taillorbook/features/home/presentation/screens/home_screen.dart';
import 'package:taillorbook/features/products/presentation/screens/product_detail_screen.dart';

final goRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/product-detail',
      builder: (context, state) => const ProductDetailScreen(),
    ),
  ],
);
