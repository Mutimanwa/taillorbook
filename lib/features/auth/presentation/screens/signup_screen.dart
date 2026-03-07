import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // Logo Placeholder
              Image.asset(
                'assets/images/logo/logo.png',
                width: 200,
              ),
              const SizedBox(height: 32),
              Text(
                'Créez votre compte',
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Rejoignez l\'univers Chris Couture.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildLabel('Nom complet'),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'Calvin Dev'),
              ),
              const SizedBox(height: 20),
              _buildLabel('Adresse Email'),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'example@gmail.com'),
              ),
              const SizedBox(height: 20),
              _buildLabel('Mot de passe'),
              const SizedBox(height: 8),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  suffixIcon: Icon(Icons.visibility_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/home');
                },
                child: const Text('S\'inscrire'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.greySubtle)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text('OU', style: AppTypography.bodyMedium),
                  ),
                  const Expanded(child: Divider(color: AppColors.greySubtle)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialIcon(Icons.g_mobiledata, AppColors.black),
                  _socialIcon(Icons.facebook, AppColors.black),
                  _socialIcon(Icons.apple, AppColors.black),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous avez déjà un compte ? ',
                    style: AppTypography.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.pop();
                    },
                    child: Text(
                      'Se connecter',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
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

  Widget _socialIcon(IconData icon, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.greySubtle),
      ),
      child: Icon(icon, color: color, size: 30),
    );
  }
}
