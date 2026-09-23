import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../state/auth/auth_providers.dart';

/// Écran de connexion : email + mot de passe, lien « mot de passe oublié »
/// et redirection vers l'inscription. Les visiteurs peuvent aussi revenir à
/// l'accueil sans compte.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  /// Destination d'origine (route protégée tentée avant redirection).
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
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool success = await ref.read(authControllerProvider.notifier).signIn(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (!mounted) return;

    if (success) {
      context.showAppSnack('Connexion réussie. Bon retour !', AppSnackType.success);
      context.go(_from ?? AppRoutes.home);
    } else {
      final String? message =
          authErrorMessage(ref.read(authControllerProvider));
      context.showAppSnack(message ?? 'Connexion impossible.', AppSnackType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
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
                    Center(
                      child: ClipRRect(
                        borderRadius: AppRadius.rXl,
                        child: Image.asset(
                          AppAssets.logo,
                          width: 84,
                          height: 84,
                          fit: BoxFit.cover,
                          errorBuilder: (
                            BuildContext context,
                            Object error,
                            StackTrace? stackTrace,
                          ) {
                            return const Icon(
                              Icons.storefront_rounded,
                              size: 80,
                              color: AppColors.primary,
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Bon retour !',
                      style: AppTypography.headlineMedium(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Connectez-vous pour acheter et suivre vos commandes.',
                      style: AppTypography.bodyMedium(),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
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
                      controller: _passwordController,
                      hintText: 'Mot de passe',
                      prefixIcon: Icons.lock_outline_rounded,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: Validators.password,
                      enabled: !authState.isLoading,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => context.push(AppRoutes.forgotPassword),
                        child: const Text('Mot de passe oublié ?'),
                      ),
                    ),
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Se connecter',
                      loading: authState.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          "Pas encore de compte ?",
                          style: AppTypography.bodyMedium(),
                        ),
                        TextButton(
                          onPressed: authState.isLoading
                              ? null
                              : () => context.push(AppRoutes.register),
                          child: const Text('Créer un compte'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text(
                        'Continuer en visiteur',
                        style: AppTypography.bodyMedium(
                          color: AppColors.textSecondary,
                        ),
                      ),
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
