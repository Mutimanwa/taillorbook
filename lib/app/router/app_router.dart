import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/features/checkout/presentation/screens/order_success.dart';
import 'package:taillorbook/features/seller/presentation/screens/seller_oders_screen.dart';
import 'package:taillorbook/models/order_model.dart';

import '../../core/constants/app_routes.dart';
import '../../core/widgets/main_scaffold.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/cart/presentation/screens/cart_screen.dart';
import '../../features/checkout/presentation/screens/checkout_screen.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/orders/presentation/screens/order_details_screen.dart';
import '../../features/orders/presentation/screens/orders_screen.dart';
import '../../features/products/presentation/screens/product_details_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/seller/presentation/screens/product_form_screen.dart';
import '../../features/seller/presentation/screens/seller_dashboard_screen.dart';
import '../../features/seller/presentation/screens/seller_products_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../state/auth/auth_providers.dart';
import 'app_transitions.dart';

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
        pageBuilder: (BuildContext context, GoRouterState state) =>
              fadeSlidePage(state: state, child: const LoginScreen()),
      ),
      GoRoute(
        path: AppRoutes.register,
        pageBuilder: (BuildContext context, GoRouterState state) =>
              fadeSlidePage(state: state, child: const RegisterScreen()),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (BuildContext context, GoRouterState state) => fadeSlidePage(
            state: state,
            child: const ForgotPasswordScreen(),
          ),
      ),
      GoRoute(
        path: AppRoutes.productList,
        pageBuilder: (BuildContext context, GoRouterState state) {
          final Map<String, String> query = state.uri.queryParameters;
          return fadeSlidePage(
            state: state,
            child: ProductListScreen(
              initialCategoryId: query['categoryId'],
              initialSellerId: query['sellerId'],
              initialQuery: query['q'] ?? '',
            ),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.productDetailsPath,
        pageBuilder: (BuildContext context, GoRouterState state) => fadeSlidePage(
          state: state,
          child: ProductDetailsScreen(
            productId: state.pathParameters['productId'] ?? '',
          ),
        ),
      ),

      // -------------------------------------------------------------------
      // Espace vendeur (accès contrôlé par les écrans : rôle + propriété)
      // -------------------------------------------------------------------
      GoRoute(
        path: AppRoutes.orderDetailsPath,
        pageBuilder: (BuildContext context, GoRouterState state) => fadeSlidePage(
          state: state,
          child: OrderDetailsScreen(
            orderId: state.pathParameters['orderId'] ?? '',
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.sellerOrderDetailsPath,
        pageBuilder: (BuildContext context, GoRouterState state) => fadeSlidePage(
          state: state,
          child: OrderDetailsScreen(
            orderId: state.pathParameters['orderId'] ?? '',
            isSellerView: true,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        pageBuilder: (BuildContext context, GoRouterState state) =>
              fadeSlidePage(state: state, child: const CheckoutScreen()),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        pageBuilder: (BuildContext context, GoRouterState state) => fadeSlidePage(
          state: state,
          child: OrderSuccessScreen(order: state.extra! as OrderModel),
        ),
      ),
      GoRoute(
        path: AppRoutes.sellerDashboard,
        pageBuilder: (BuildContext context, GoRouterState state) =>
              fadeSlidePage(state: state, child: const SellerDashboardScreen()),
      ),
      GoRoute(
        path: AppRoutes.sellerProducts,
        pageBuilder: (BuildContext context, GoRouterState state) =>
              fadeSlidePage(state: state, child: const SellerProductsScreen()),
      ),
      GoRoute(
        path: AppRoutes.sellerCreateProduct,
        pageBuilder: (BuildContext context, GoRouterState state) =>
              fadeSlidePage(state: state, child: const ProductFormScreen()),
      ),
      GoRoute(
        path: AppRoutes.sellerOrders,
        pageBuilder: (BuildContext context, GoRouterState state) =>
              fadeSlidePage(state: state, child: const SellerOrdersScreen()),
      ),
      GoRoute(
        path: AppRoutes.sellerEditProductPath,
        pageBuilder: (BuildContext context, GoRouterState state) => fadeSlidePage(
          state: state,
          child: ProductFormScreen(
            productId: state.pathParameters['productId'],
          ),
        ),
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