import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty.dart';

/// Onglet Commandes : historique des commandes du client connecté
/// (phase « Commandes & historique »).
class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mes commandes')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: AppEmpty(
            icon: Icons.receipt_long_outlined,
            title: 'Aucune commande',
            message:
                'Vos commandes et leur suivi apparaîtront ici après votre premier achat.',
          ),
        ),
      ),
    );
  }
}
