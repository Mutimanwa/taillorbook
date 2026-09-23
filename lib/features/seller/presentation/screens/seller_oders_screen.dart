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
import '../../../../state/orders/orders_providers.dart';

/// Commandes reçues par le vendeur : uniquement les commandes contenant
/// SES produits (filtrage Firestore par sellerId, doublé par les règles).
/// Client, téléphone, produits, montants, livraison, paiements et statuts.
class SellerOrdersScreen extends ConsumerWidget {
  const SellerOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<OrderModel>?> ordersAsync =
        ref.watch(sellerOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Commandes reçues')),
      body: ordersAsync.when(
        loading: () => const AppLoading(message: 'Chargement des commandes…'),
        error: (Object error, StackTrace stackTrace) => AppError(
          message: 'Impossible de charger vos commandes.',
          onRetry: () => ref.invalidate(sellerOrdersProvider),
        ),
        data: (List<OrderModel>? orders) {
          if (orders == null) {
            return const Center(
              child: AppEmpty(
                icon: Icons.lock_outline_rounded,
                title: 'Compte vendeur requis',
                message:
                    "Connectez-vous avec un compte vendeur pour consulter vos commandes.",
              ),
            );
          }
          if (orders.isEmpty) {
            return Center(
              child: AppEmpty(
                icon: Icons.receipt_long_outlined,
                title: 'Aucune commande pour le moment',
                message:
                    "Dès qu'un client commande un de vos produits, la commande "
                    "apparaît ici avec ses coordonnées et son statut de paiement.",
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(sellerOrdersProvider),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              itemCount: orders.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: 12),
              itemBuilder: (BuildContext context, int index) => OrderCard(
                order: orders[index],
                showClientInfo: true,
                onTap: () => context.push(
                  AppRoutes.sellerOrderDetails(orders[index].orderId),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Squelette compact conservé pour cohérence visuelle (listes vendeur).
class SellerOrderSkeleton extends StatelessWidget {
  const SellerOrderSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 132,
      child: AppSkeleton(height: 132, radius: AppRadius.rLg),
    );
  }
}