import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/shared/widgets/animated_clickable.dart';

class SidebarHeader extends StatelessWidget {
  const SidebarHeader({required this.onClose, super.key});
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SvgPicture.asset(
            'assets/images/logo.svg',
            width: 28,
            height: 28,
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
          AnimatedClickable(
            onTap: onClose,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: const HeroIcon(
                HeroIcons.chevronLeft,
                size: 24,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SidebarSearch extends StatelessWidget {
  const SidebarSearch({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedClickable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
