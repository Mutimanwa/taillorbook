import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../state/app/app_state.dart';
import '../../../../state/auth/auth_providers.dart';

/// Onglet Profil : carte de compte (invité ou connecté), préférences
/// (thème clair/sombre), accès aux commandes et à l'espace vendeur.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User?> authState = ref.watch(authStateProvider);
    final User? user = authState.valueOrNull;
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: <Widget>[
          _ProfileHeaderCard(user: user),
          const SizedBox(height: AppSpacing.lg),
          if (user == null)
            ...<Widget>[
              AppButton(
                label: 'Se connecter',
                icon: Icons.login_rounded,
                onPressed: () => context
                    .showAppSnack("L'authentification sera disponible très bientôt."),
              ),
              const SizedBox(height: 10),
              AppButton(
                label: 'Créer un compte',
                variant: AppButtonVariant.outline,
                icon: Icons.person_add_alt_rounded,
                onPressed: () => context
                    .showAppSnack("L'authentification sera disponible très bientôt."),
              ),
            ]
          else
            ...<Widget>[
              AppButton(
                label: 'Se déconnecter',
                variant: AppButtonVariant.danger,
                icon: Icons.logout_rounded,
                onPressed: () => _confirmSignOut(context, ref),
              ),
            ],
          const SizedBox(height: AppSpacing.xl),
          Text(
            'PRÉFÉRENCES',
            style: context.appTextTheme.labelSmall?.copyWith(letterSpacing: 1.2),
          ),
          const SizedBox(height: 10),
          _SettingsCard(
            children: <Widget>[
              SwitchListTile(
                value: themeMode == ThemeMode.dark,
                onChanged: (bool value) {
                  ref.read(themeModeProvider.notifier).state =
                      value ? ThemeMode.dark : ThemeMode.light;
                },
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Mode sombre'),
                subtitle: const Text("Basculer entre thème clair et sombre"),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SettingsCard(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Mes commandes'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.go(AppRoutes.orders),
              ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('Devenir vendeur'),
                subtitle: const Text('Publiez et gérez vos propres produits'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context
                    .showAppSnack("L'espace vendeur sera disponible très bientôt."),
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: const Text('À propos'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showAbout(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final bool confirmed = await context.showConfirmDialog(
      title: 'Se déconnecter',
      message: 'Voulez-vous vraiment vous déconnecter de votre compte ?',
      confirmLabel: 'Se déconnecter',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(firebaseAuthServiceProvider).signOut();
  }

  void _showAbout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: AppRadius.rLg),
          title: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: AppRadius.rSm,
                child: Image.asset(
                  AppAssets.logo,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                  errorBuilder: (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) {
                    return const Icon(Icons.storefront_rounded, size: 30);
                  },
                ),
              ),
              const SizedBox(width: 10),
              const Text(AppConstants.appName),
            ],
          ),
          content: const Text(
            'Version ${AppConstants.appVersion}\n\n'
            'Marketplace de démonstration : paiement simulé, taux de change '
            'fixes de démonstration, images produits hébergées via ImgBB, '
            'récapitulatif de commande envoyé au vendeur via WhatsApp.\n\n'
            "Projet académique — aucune transaction réelle n'est effectuée.",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
}

/// Carte d'en-tête : avatar, nom, email ou message invité.
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.user});

  final User? user;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;
    final String? photoUrl = user?.photoURL;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 30,
            backgroundColor: AppColors.primarySoft,
            backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
            child: photoUrl == null
                ? const Icon(Icons.person_rounded, size: 30, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  user?.displayName ?? 'Invité',
                  style: context.appTextTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.email ?? 'Connectez-vous pour acheter et vendre.',
                  style: context.appTextTheme.bodySmall,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Conteneur arrondi pour groupes de réglages.
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.rLg,
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(children: children),
    );
  }
}
