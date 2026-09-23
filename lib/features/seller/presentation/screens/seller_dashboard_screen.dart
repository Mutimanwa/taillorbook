import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/constants/app_enums.dart';
import 'package:taillorbook/models/user_model.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_empty.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../state/auth/auth_providers.dart';
import '../../../../state/seller/seller_providers.dart';

/// Tableau de bord du vendeur : statistiques de ses produits, actions
/// rapides et accès aux commandes (phase « Commandes »).
///
/// Accès réservé : visiteur → invitation à se connecter ; client →
/// explication du rôle vendeur.
class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User?> authState = ref.watch(authStateProvider);
    final User? user = authState.valueOrNull;
    final UserModel? profile = ref.watch(userProfileProvider).valueOrNull;

    if (authState.isLoading) {
      return const Scaffold(body: AppLoading(message: 'Chargement…'));
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Espace vendeur')),
        body: Center(
          child: AppEmpty(
            icon: Icons.lock_outline_rounded,
            title: 'Connectez-vous',
            message:
                "L'espace vendeur est réservé aux comptes authentifiés avec le rôle vendeur.",
            actionLabel: 'Se connecter',
            onAction: () => context.push('${AppRoutes.login}?from=${AppRoutes.sellerDashboard}'),
          ),
        ),
      );
    }

    if (profile == null) {
      return const Scaffold(body: AppLoading(message: 'Chargement du profil…'));
    }

    if (profile.role != UserRole.seller) {
      return Scaffold(
        appBar: AppBar(title: const Text('Espace vendeur')),
        body: Center(
          child: AppEmpty(
            icon: Icons.storefront_outlined,
            title: 'Compte client',
            message:
                "Votre compte est un compte client. Les vendeurs publient et gèrent "
                "leurs propres produits depuis cet espace.",
          ),
        ),
      );
    }

    final SellerStats stats = ref.watch(sellerStatsProvider);
    final String shopName = profile.name.isNotEmpty ? profile.name : 'Vendeur';

    return Scaffold(
      appBar: AppBar(title: const Text('Espace vendeur')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.storefront_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Bonjour, $shopName 👋',
                        style: AppTypography.titleLarge()),
                    Text(
                      'Voici l\'activité de votre boutique.',
                      style: AppTypography.bodySmall(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('STATISTIQUES', style: context.appTextTheme.labelSmall?.copyWith(letterSpacing: 1.2)),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.md,
            crossAxisSpacing: AppSpacing.md,
            childAspectRatio: 1.45,
            children: <Widget>[
              _StatCard(
                icon: Icons.inventory_2_outlined,
                value: '${stats.total}',
                label: 'Produits',
              ),
              _StatCard(
                icon: Icons.check_circle_outline_rounded,
                value: '${stats.active}',
                label: 'Produits actifs',
                color: AppColors.success,
              ),
              _StatCard(
                icon: Icons.warning_amber_rounded,
                value: '${stats.lowStock}',
                label: 'Stock faible',
                color: AppColors.warning,
              ),
              _StatCard(
                icon: Icons.block_rounded,
                value: '${stats.outOfStock}',
                label: 'Ruptures',
                color: AppColors.error,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: 'Publier un nouveau produit',
            icon: Icons.add_rounded,
            onPressed: () => context.push(AppRoutes.sellerCreateProduct),
          ),
          const SizedBox(height: AppSpacing.md),
          _SellerActionTile(
            icon: Icons.inventory_outlined,
            title: 'Mes produits',
            subtitle: '${stats.total} produit${stats.total > 1 ? 's' : ''} publié${stats.total > 1 ? 's' : ''}',
            onTap: () => context.push(AppRoutes.sellerProducts),
          ),
          _SellerActionTile(
            icon: Icons.receipt_long_outlined,
            title: 'Commandes reçues',
            subtitle: 'Clients, paiements et statuts en temps réel',
            onTap: () => context.push(AppRoutes.sellerOrders),
          ),
          _SellerActionTile(
            icon: Icons.person_outline_rounded,
            title: 'Mon profil',
            subtitle: 'Informations de la boutique',
            onTap: () => context.go(AppRoutes.profile),
          ),
        ],
      ),
    );
  }
}

/// Carte de statistique (valeur + libellé + icône).
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.color = AppColors.primary,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(icon, size: 20, color: color),
              const Spacer(),
              Text(
                value,
                style: AppTypography.headlineMedium(),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelMedium(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Ligne d'action de l'espace vendeur.
class _SellerActionTile extends StatelessWidget {
  const _SellerActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTypography.titleMedium()),
        subtitle: Text(subtitle, style: AppTypography.bodySmall()),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
      ),
    );
  }
}