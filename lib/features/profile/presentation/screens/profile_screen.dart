import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../../core/widgets/currency_picker.dart';
import '../../../../models/user_model.dart';
import '../../../../state/app/app_state.dart';
import '../../../../state/auth/auth_providers.dart';
import '../../../../state/currency/currency_providers.dart';

/// Onglet Profil : carte de compte (invité ou connecté, avec badge de rôle),
/// préférences (thème clair/sombre), accès aux commandes et à l'espace
/// vendeur pour les vendeurs.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<User?> authState = ref.watch(authStateProvider);
    final User? user = authState.valueOrNull;
    final UserModel? profile = ref.watch(userProfileProvider).valueOrNull;
    final ThemeMode themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: authState.isLoading
          ? const AppLoading(message: 'Chargement du profil…')
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              children: <Widget>[
                _ProfileHeaderCard(user: user, profile: profile),
                const SizedBox(height: AppSpacing.lg),
                if (user == null) ...<Widget>[
                  AppButton(
                    label: 'Se connecter',
                    icon: Icons.login_rounded,
                    onPressed: () => context.push(AppRoutes.login),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Créer un compte',
                    variant: AppButtonVariant.outline,
                    icon: Icons.person_add_alt_rounded,
                    onPressed: () => context.push(AppRoutes.register),
                  ),
                ] else ...<Widget>[
                  if (profile?.role == UserRole.seller)
                    AppButton(
                      label: 'Mon espace vendeur',
                      variant: AppButtonVariant.secondary,
                      icon: Icons.storefront_rounded,
                      onPressed: () => context.push(AppRoutes.sellerDashboard),
                    ),
                  if (profile?.role == UserRole.seller)
                    const SizedBox(height: 10),
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
                  style: context.appTextTheme.labelSmall
                      ?.copyWith(letterSpacing: 1.2),
                ),
                const SizedBox(height: 10),
                _SettingsCard(
                  children: <Widget>[
                    ListTile(
                      leading: const Icon(Icons.currency_exchange_rounded),
                      title: const Text("Devise d'affichage"),
                      subtitle: const Text(
                        'Taux fixes de démonstration (BIF / USD / EUR)',
                      ),
                      trailing: Text(
                        ref.watch(displayCurrencyProvider).symbol,
                        style: context.appTextTheme.titleMedium?.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                      onTap: () => showCurrencyPickerSheet(context),
                    ),
                    SwitchListTile(
                      value: themeMode == ThemeMode.dark,
                      onChanged: (bool value) {
                        ref.read(themeModeProvider.notifier).state =
                            value ? ThemeMode.dark : ThemeMode.light;
                      },
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Mode sombre'),
                      subtitle: const Text('Basculer entre thème clair et sombre'),
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
    await ref.read(authControllerProvider.notifier).signOut();
    if (!context.mounted) return;
    context.showAppSnack('Vous êtes déconnecté. À bientôt !');
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

/// Carte d'en-tête : avatar, nom, email et badge de rôle (client/vendeur).
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.user, required this.profile});

  final User? user;
  final UserModel? profile;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;
    final String? photoUrl = user?.photoURL ?? profile?.profileImageUrl;
    final String name = profile?.name.isNotEmpty == true
        ? profile!.name
        : (user?.displayName ?? 'Invité');
    final String email = user?.email ?? profile?.email ?? 'Connectez-vous pour acheter et vendre.';
    final UserRole role = profile?.role ?? UserRole.client;

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
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: AppTypography.headlineSmall(color: AppColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  name,
                  style: context.appTextTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: context.appTextTheme.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user != null) ...<Widget>[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: role == UserRole.seller
                          ? AppColors.secondarySoft
                          : AppColors.primarySoft,
                      borderRadius: AppRadius.rFull,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          role == UserRole.seller
                              ? Icons.storefront_rounded
                              : Icons.shopping_bag_rounded,
                          size: 13,
                          color: role == UserRole.seller
                              ? AppColors.secondary
                              : AppColors.primary,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          role.label,
                          style: AppTypography.labelSmall(
                            color: role == UserRole.seller
                                ? AppColors.secondary
                                : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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