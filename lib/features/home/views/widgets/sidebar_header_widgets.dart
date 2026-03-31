import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({required this.onClose, super.key});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brand500,
            ),
            child: const HeroIcon(
              HeroIcons.sparkles,
              style: HeroIconStyle.solid,
              size: 16,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'WolfChat',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onClose,
              customBorder: const CircleBorder(),
              hoverColor: AppColors.surfaceHover,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: HeroIcon(
                  HeroIcons.chevronLeft,
                  size: 24,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarSearch extends StatelessWidget {
  const SidebarSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceHover,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            HeroIcon(
              HeroIcons.magnifyingGlass,
              size: 16,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Buscar nas conversas...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
