import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../state/app/app_state.dart';

/// Onglet Accueil : en-tête de marque, recherche, bannière promotionnelle
/// et sections du catalogue (alimentées par Firestore dans les phases
/// « Modèles, catégories & produits » puis « Catalogue public »).
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _firebaseNoticeVisible = true;

  @override
  Widget build(BuildContext context) {
    final bool firebaseReady = ref.watch(firebaseReadyProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (!firebaseReady && _firebaseNoticeVisible)
                _FirebaseNoticeBanner(
                  onDismiss: () => setState(() => _firebaseNoticeVisible = false),
                ),
              const SizedBox(height: AppSpacing.sm),
              const _HomeHeader(),
              const SizedBox(height: AppSpacing.lg),
              const _SearchField(),
              const SizedBox(height: AppSpacing.lg),
              const _PromoBanner(),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Catégories'),
              _HomeEmptySection(
                icon: Icons.category_outlined,
                message:
                    'Aucune catégorie pour le moment.\nElles apparaîtront ici dès leur publication.',
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Produits en vedette'),
              _HomeEmptySection(
                icon: Icons.shopping_bag_outlined,
                message: 'Le catalogue produits sera bientôt disponible.',
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Pourquoi SokoMarket ?'),
              const SizedBox(height: AppSpacing.md),
              const _WhySection(),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bannière d'information affichée uniquement si Firebase est indisponible.
class _FirebaseNoticeBanner extends StatelessWidget {
  const _FirebaseNoticeBanner({required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pagePadding,
        AppSpacing.md,
        AppSpacing.pagePadding,
        0,
      ),
      padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: AppRadius.rMd,
        border: Border.all(color: AppColors.warning),
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Mode démonstration : Firebase n'est pas configuré sur cette "
              'installation. Exécutez « flutterfire configure » pour activer '
              'les données en direct.',
              style: AppTypography.labelMedium(color: AppColors.textPrimary),
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDismiss,
            icon: const Icon(
              Icons.close_rounded,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// En-tête : logo, nom de marque, accueil personnalisé et notifications.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: AppRadius.rMd,
            child: Image.asset(
              AppAssets.logo,
              width: 42,
              height: 42,
              fit: BoxFit.cover,
              errorBuilder: (
                BuildContext context,
                Object error,
                StackTrace? stackTrace,
              ) {
                return const Icon(
                  Icons.storefront_rounded,
                  size: 38,
                  color: AppColors.primary,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(AppConstants.appName, style: AppTypography.titleLarge()),
                Text(
                  'Bienvenue sur votre marketplace',
                  style: AppTypography.bodySmall(),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () =>
                context.showAppSnack('Aucune notification pour le moment.'),
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
    );
  }
}

/// Barre de recherche (pleinement fonctionnelle à la phase « Catalogue »).
class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: TextField(
        readOnly: true,
        onTap: () => context
            .showAppSnack('La recherche sera disponible avec le catalogue produits.'),
        decoration: const InputDecoration(
          hintText: 'Rechercher un produit…',
          prefixIcon: Icon(Icons.search_rounded),
          suffixIcon: Icon(Icons.tune_rounded, size: 22),
        ),
      ),
    );
  }
}

/// Bannière promotionnelle avec dégradé de marque.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: AppColors.promoGradient,
          ),
          borderRadius: AppRadius.rXl,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: AppRadius.rFull,
                    ),
                    child: Text(
                      'OFFRE SPÉCIALE',
                      style: AppTypography.labelSmall(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Jusqu'à -40 %\nsur une sélection",
                    style: AppTypography.headlineMedium(color: Colors.white)
                        .copyWith(height: 1.25),
                  ),
                  const SizedBox(height: 14),
                  AppButton(
                    label: 'Découvrir',
                    variant: AppButtonVariant.secondary,
                    expanded: false,
                    height: 40,
                    onPressed: () =>
                        context.showAppSnack('Le catalogue arrive très bientôt.'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.shopping_bag_rounded, size: 76, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

/// Bloc vide compact d'une section de l'accueil (pas encore de données).
class _HomeEmptySection extends StatelessWidget {
  const _HomeEmptySection({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.appColorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 26, color: AppColors.textDisabled),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.bodySmall(),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rangée d'arguments de confiance de la marketplace.
class _WhySection extends StatelessWidget {
  const _WhySection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: _WhyCard(
              icon: Icons.verified_user_outlined,
              title: 'Achats sécurisés',
              description: 'Paiement vérifié avant confirmation de commande.',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _WhyCard(
              icon: Icons.local_shipping_outlined,
              title: 'Livraison ou retrait',
              description: 'Choisissez votre mode de réception préféré.',
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyCard extends StatelessWidget {
  const _WhyCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

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
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppTypography.titleSmall(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTypography.labelMedium(),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
