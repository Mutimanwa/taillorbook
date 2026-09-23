import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../state/auth/auth_providers.dart';

/// Onglet Commandes : réservé aux clients authentifiés. Un visiteur voit un
/// état d'accueil explicite avec redirection vers la connexion. La liste des
/// commandes Firestore est branchée à la phase « Commandes & historique ».
class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User?> authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: authState.isLoading
          ? const AppLoading()
          : authState.valueOrNull == null
              ? Center(
                  child: AppEmpty(
                    icon: Icons.lock_outline_rounded,
                    title: 'Connectez-vous',
                    message:
                        'Créez un compte ou connectez-vous pour consulter votre historique de commandes.',
                    actionLabel: 'Se connecter',
                    onAction: () =>
                        context.push('${AppRoutes.login}?from=${AppRoutes.orders}'),
                  ),
                )
              : const Center(
                  child: AppEmpty(
                    icon: Icons.receipt_long_outlined,
                    title: 'Aucune commande',
                    message:
                        "Vos commandes et leur suivi apparaîtront ici après votre premier achat.",
                  ),
                ),
    );
  }
}
