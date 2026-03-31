import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class SidebarFooter extends StatelessWidget {
  const SidebarFooter({
    required this.userName,
    required this.onOpenSettings,
    super.key,
  });

  final String userName;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.surfaceHover)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.accentLight,
            ),
            child: Center(
              child: Text(
                userName.isNotEmpty
                    ? userName.trim().split('').take(2).join().toUpperCase()
                    : '',
                style: const TextStyle(
                  color: AppColors.brand300,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              userName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onOpenSettings,
              customBorder: const CircleBorder(),
              hoverColor: AppColors.surfaceHover,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: HeroIcon(
                  HeroIcons.cog6Tooth,
                  size: 20,
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
