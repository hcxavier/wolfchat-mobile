import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class HeaderSection extends StatelessWidget {
  const HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brand500,
          ),
          child: const HeroIcon(
            HeroIcons.sparkles,
            style: HeroIconStyle.solid,
            size: 40,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'WolfChat',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Seu assistente de IA avançado.',
          style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        const Text(
          'O que vamos criar juntos?',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
