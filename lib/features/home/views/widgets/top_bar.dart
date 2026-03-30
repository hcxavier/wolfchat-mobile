import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class TopBar extends StatelessWidget {
  const TopBar({required this.onToggleSidebar});

  final VoidCallback onToggleSidebar;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onToggleSidebar,
          icon: const HeroIcon(
            HeroIcons.bars3,
            size: 24,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceHover,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'KIMI K2 INSTRUCT',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 8),
              HeroIcon(
                HeroIcons.chevronDown,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
