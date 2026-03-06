import 'package:flutter/material.dart';
import 'package:taillorbook/core/theme/app_typography.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});
  @override
  Widget build(BuildContext context) =>
      Center(child: Text('Profil', style: AppTypography.titleMedium));
}
