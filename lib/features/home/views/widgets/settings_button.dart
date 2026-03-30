import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
    super.key,
  });

  final HeroIcons icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceHover,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              HeroIcon(
                icon,
                size: 20,
                color: isDestructive
                    ? AppColors.brand500
                    : AppColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isDestructive
                        ? AppColors.brand500
                        : AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              HeroIcon(
                HeroIcons.chevronRight,
                size: 16,
                color: isDestructive
                    ? AppColors.brand500
                    : AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
