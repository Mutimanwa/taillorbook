import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:taillorbook/core/theme/app_colors.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

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
              const SizedBox(height: 60),
              // Logo
              Semantics(
                label: 'Logo Chris Couture',
                image: true,
                child: Image.asset('assets/images/logo/logo.png', width: 200),
              ),
              const SizedBox(height: 32),
              Text(
                'Connectez-vous à votre compte',
                style: AppTypography.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Ravie de vous revoir, veuillez entrer vos coordonnées.',
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              _buildLabel('Adresse Email'),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: 'example@gmail.com'),
              ),
              const SizedBox(height: 24),
              _buildLabel('Mot de passe'),
              const SizedBox(height: 8),
              const TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '••••••••••••',
                  suffixIcon: Icon(Icons.visibility_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        onChanged: (v) {},
                        activeColor: AppColors.black,
                      ),
                      Text(
                        'Se souvenir de moi',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      context.push('/forget-password');
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/home');
                },
                child: const Text('Se connecter'),
              ),
              const SizedBox(height: 32),
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
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _socialIcon(Icons.g_mobiledata, AppColors.black),
                  _socialIcon(Icons.facebook, AppColors.black),
                  _socialIcon(Icons.apple, AppColors.black),
                ],
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous n\'avez pas de compte ? ',
                    style: AppTypography.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      context.push('/signup');
                    },
                    child: Semantics(
                      label: 'Bouton S\'inscrire',
                      button: true,
                      child: Text(
                        'S\'inscrire',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  context.go('/home');
                },
                child: Text(
                  'Continuer en tant qu\'invité',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.black.withOpacity(0.5),
                    decoration: TextDecoration.underline,
                  ),
                ),
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
