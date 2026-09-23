import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_enums.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../state/auth/auth_providers.dart';

/// Écran d'inscription : choix du rôle (client ou vendeur) avec numéro
/// WhatsApp obligatoire pour les vendeurs, puis création du compte.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  UserRole _selectedRole = UserRole.client;

  String? _from;
  bool _fromResolved = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_fromResolved) {
      _from = GoRouterState.of(context).uri.queryParameters['from'];
      _fromResolved = true;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool isSeller = _selectedRole == UserRole.seller;
    final bool success = await ref.read(authControllerProvider.notifier).register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          phone: _phoneController.text.trim(),
          role: _selectedRole,
          whatsappNumber:
              isSeller ? _whatsappController.text.trim() : '',
        );
    if (!mounted) return;

    if (success) {
      context.showAppSnack(
        isSeller
            ? 'Compte vendeur créé. Publiez votre premier produit !'
            : 'Compte créé. Bienvenue sur SokoMarket !',
        AppSnackType.success,
      );
      context.go(_from ?? AppRoutes.home);
    } else {
      final String? message =
          authErrorMessage(ref.read(authControllerProvider));
      context.showAppSnack(message ?? 'Inscription impossible.', AppSnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> authState = ref.watch(authControllerProvider);
    final bool isSeller = _selectedRole == UserRole.seller;

    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      'Rejoignez SokoMarket',
                      style: AppTypography.headlineMedium(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Choisissez votre profil pour personnaliser votre expérience.',
                      style: AppTypography.bodyMedium(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.shopping_bag_outlined,
                            title: 'Client',
                            subtitle: 'Acheter des produits',
                            selected: _selectedRole == UserRole.client,
                            onTap: () =>
                                setState(() => _selectedRole = UserRole.client),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _RoleCard(
                            icon: Icons.storefront_outlined,
                            title: 'Vendeur',
                            subtitle: 'Vendre mes produits',
                            selected: isSeller,
                            onTap: () =>
                                setState(() => _selectedRole = UserRole.seller),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      controller: _nameController,
                      hintText: 'Nom complet',
                      prefixIcon: Icons.person_outline_rounded,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      validator: Validators.required,
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _emailController,
                      hintText: 'Adresse email',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: Validators.email,
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _phoneController,
                      hintText: 'Téléphone (ex. +257 79 00 00 00)',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      validator: Validators.phone,
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 14),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.topCenter,
                      child: isSeller
                          ? Column(
                              children: <Widget>[
                                AppTextField(
                                  controller: _whatsappController,
                                  hintText: 'Numéro WhatsApp de la boutique',
                                  prefixIcon: Icons.chat_outlined,
                                  keyboardType: TextInputType.phone,
                                  textInputAction: TextInputAction.next,
                                  validator: Validators.phone,
                                  enabled: !authState.isLoading,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: <Widget>[
                                    const Icon(
                                      Icons.info_outline_rounded,
                                      size: 15,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Vos clients recevront les récapitulatifs de commande sur ce numéro.',
                                        style: AppTypography.labelSmall(),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                    AppTextField(
                      controller: _passwordController,
                      hintText: 'Mot de passe (6 caractères minimum)',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      controller: _confirmController,
                      hintText: 'Confirmer le mot de passe',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: (String? value) =>
                          value == _passwordController.text
                              ? null
                              : 'Les mots de passe ne correspondent pas',
                      enabled: !authState.isLoading,
                    ),
                    const SizedBox(height: 20),
                    AppButton(
                      label: isSeller
                          ? 'Créer mon compte vendeur'
                          : 'Créer mon compte client',
                      loading: authState.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Déjà inscrit ?',
                          style: AppTypography.bodyMedium(),
                        ),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.push(AppRoutes.login),
                          child: const Text('Se connecter'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Carte de sélection du rôle (client / vendeur).
class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = context.appColorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.rLg,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : colorScheme.surface,
          borderRadius: AppRadius.rLg,
          border: Border.all(
            color: selected ? AppColors.primary : colorScheme.outline,
            width: selected ? 1.6 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  icon,
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                const Spacer(),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: AppTypography.titleSmall(
                color: selected ? AppColors.primaryDark : null,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: AppTypography.labelSmall(),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
