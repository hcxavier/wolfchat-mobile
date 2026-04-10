import 'package:flutter/material.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    super.key,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isExpanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    final child = FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textPrimary,
              ),
            )
          : icon != null
          ? Icon(icon)
          : const SizedBox.shrink(),
      label: Text(label),
    );

    if (isExpanded) {
      return SizedBox(width: double.infinity, child: child);
    }
    return child;
  }
}

// Pseudo-update for commit 37 at 2026-04-10 08:30:21
