import 'package:flutter/material.dart';

import '../../../../core/widgets/app_empty.dart';

/// Onglet Catégories : les catégories publiées dans Firestore seront
/// affichées ici (phase « Modèles, catégories & produits »).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Catégories')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: AppEmpty(
            icon: Icons.category_outlined,
            title: 'Aucune catégorie',
            message:
                'Les catégories de la marketplace s\'afficheront ici dès leur publication.',
          ),
        ),
      ),
    );
  }
}
