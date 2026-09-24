import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/app/theme/app_radius.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_error.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/app_skeleton.dart';
import '../../../../core/widgets/order_card.dart';
import '../../../../models/order_model.dart';
import '../../../../state/auth/auth_providers.dart';
import '../../../../state/orders/orders_providers.dart';

/// Historique des commandes du client (temps réel Firestore) : liste des
/// commandes avec statuts, clic → fiche détaillée. Visiteur → connexion.
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User?> authState = ref.watch(authStateProvider);

    if (authState.isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes commandes')),
        body: const AppLoading(message: 'Chargement…'),
      );
    }

    if (authState.valueOrNull == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes commandes')),
        body: Center(
          child: AppEmpty(
            icon: Icons.lock_outline_rounded,
            title: 'Connectez-vous',
            message:
                'Créez un compte ou connectez-vous pour consulter votre historique de commandes.',
            actionLabel: 'Se connecter',
            onAction: () =>
                context.push('${AppRoutes.login}?from=${AppRoutes.orders}'),
          ),
        ),
      );
    }

    final AsyncValue<List<OrderModel>?> ordersAsync =
        ref.watch(clientOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: ordersAsync.when(
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: 3,
          separatorBuilder: (BuildContext context, int index) =>
              const SizedBox(height: 12),
          itemBuilder: (BuildContext context, int index) => const SizedBox(
            height: 120,
            child: AppSkeleton(height: 120, radius: AppRadius.rLg),
          ),
        ),
        error: (Object error, StackTrace stackTrace) => AppError(
          message: 'Impossible de charger vos commandes.',
          onRetry: () => ref.invalidate(clientOrdersProvider),
        ),
        data: (List<OrderModel>? orders) {
          if (orders == null || orders.isEmpty) {
            return Center(
              child: AppEmpty(
                icon: Icons.receipt_long_outlined,
                title: 'Aucune commande',
                message:
                    "Vos commandes et leur suivi apparaîtront ici après votre premier achat.",
                actionLabel: 'Découvrir le catalogue',
                onAction: () => context.go(AppRoutes.home),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(clientOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: orders.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) => OrderCard(
                order: orders[index],
                onTap: () => context.push(
                  AppRoutes.orderDetails(orders[index].orderId),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}