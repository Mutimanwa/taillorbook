import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_radius.dart';
import '../../../../app/theme/app_typography.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../state/auth/auth_providers.dart';

/// Écran « Mot de passe oublié » : envoi d'un email de réinitialisation via
/// Firebase Auth, avec confirmation visuelle et retour à la connexion.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    context.hideKeyboard();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final bool success = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(email: _emailController.text.trim());
    if (!mounted) return;

    if (success) {
      setState(() => _emailSent = true);
    } else {
      final String? message =
          authErrorMessage(ref.read(authControllerProvider));
      context.showAppSnack(
        message ?? 'Envoi impossible. Réessayez.',
        AppSnackType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _emailSent
                  ? _SuccessPanel(
                      email: _emailController.text.trim(),
                      onBackToLogin: () => context.go(AppRoutes.login),
                    )
                  : Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySoft,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.lock_reset_rounded,
                              size: 30,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Réinitialiser le mot de passe',
                            style: AppTypography.headlineSmall(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Saisissez votre adresse email : vous recevrez un '
                            'lien sécurisé pour créer un nouveau mot de passe.',
                            style: AppTypography.bodyMedium(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 26),
                          AppTextField(
                            controller: _emailController,
                            hintText: 'Adresse email',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _submit(),
                            validator: Validators.email,
                            enabled: !authState.isLoading,
                          ),
                          const SizedBox(height: 18),
                          AppButton(
                            label: 'Envoyer le lien',
                            icon: Icons.send_outlined,
                            loading: authState.isLoading,
                            onPressed: _submit,
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => context.go(AppRoutes.login),
                            child: const Text('Retour à la connexion'),
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

/// Panneau de confirmation affiché après l'envoi de l'email.
class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.email, required this.onBackToLogin});

  final String email;
  final VoidCallback onBackToLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: AppColors.successSoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 34,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Email envoyé !',
          style: AppTypography.headlineSmall(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Un lien de réinitialisation a été envoyé à :\n$email\n\n'
          'Pensez à vérifier votre dossier spam.',
          style: AppTypography.bodyMedium(),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: AppRadius.rMd,
          ),
          child: Text(
            "Vous n'avez rien reçu ? Vérifiez l'adresse saisie puis réessayez.",
            style: AppTypography.bodySmall(color: AppColors.primaryDark),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        AppButton(label: 'Retour à la connexion', onPressed: onBackToLogin),
      ],
    );
  }
}
