import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_routes.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../state/auth/auth_providers.dart';

/// Configuration centrale de la navigation (GoRouter).
///
/// - Shell 5 onglets (Accueil, Catégories, Panier, Commandes, Profil) ;
/// - routes d'authentification (login, register, mot de passe oublié) ;
/// - redirection automatique des utilisateurs connectés hors des pages
///   d'authentification. Les routes protégées (checkout, espace vendeur)
///   seront ajoutées au même mécanisme dans les phases suivantes.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (BuildContext context, GoRouterState state) {
      final bool isLoggedIn = ref.read(authStateProvider).valueOrNull != null;
      final String location = state.matchedLocation;

      final bool onAuthPage = location == AppRoutes.login ||
          location == AppRoutes.register ||
          location == AppRoutes.forgotPassword;

      // Un utilisateur déjà connecté n'a rien à faire sur les pages d'auth.
      if (isLoggedIn && onAuthPage) return AppRoutes.home;
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.splash,
        builder: (BuildContext context, GoRouterState state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (BuildContext context, GoRouterState state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (BuildContext context, GoRouterState state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (BuildContext context, GoRouterState state) =>
            const ForgotPasswordScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) =>
            MainScaffold(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                builder: (BuildContext context, GoRouterState state) =>
                    const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.categories,
                builder: (BuildContext context, GoRouterState state) =>
                    const CategoriesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.cart,
                builder: (BuildContext context, GoRouterState state) =>
                    const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.orders,
                builder: (BuildContext context, GoRouterState state) =>
                    const OrdersScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                builder: (BuildContext context, GoRouterState state) =>
                    const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );

  // Rafraîchit la navigation à chaque changement d'état de connexion
  // (déconnexion pendant la navigation, connexion réussie, etc.).
  ref.listen<AsyncValue<dynamic>>(authStateProvider, (_, __) => router.refresh());

  return router;
});
