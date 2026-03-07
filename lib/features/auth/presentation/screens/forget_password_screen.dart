import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  bool _codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Image.asset(
                'assets/images/logo/logo.png',
                width: 200,
              ),
              const SizedBox(height: 32),
              Text(
                _codeSent
                    ? 'Vérifiez votre boîte mail'
                    : 'Mot de passe oublié ?',
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _codeSent
                    ? 'Nous avons envoyé un code de récupération à votre adresse email.'
                    : 'Pas de soucis, nous vous enverrons des instructions de réinitialisation.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              if (!_codeSent) ...[
                _buildLabel('Adresse Email'),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(hintText: 'example@gmail.com'),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _codeSent = true);
                  },
                  child: const Text('Réinitialiser le mot de passe'),
                ),
              ] else ...[
                _buildLabel('Code de vérification'),
                const SizedBox(height: 8),
                const TextField(
                  decoration: InputDecoration(hintText: '••••••'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                  },
                  child: const Text('Vérifier le code'),
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    setState(() => _codeSent = false);
                  },
                  child: Text(
                    'Renvoyer le code',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.black.withOpacity(0.7),
        ),
      ),
    );
  }
}
