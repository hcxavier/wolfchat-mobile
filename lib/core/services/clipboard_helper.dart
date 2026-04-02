import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:heroicons/heroicons.dart';
import 'package:wolfchat/core/theme/app_colors.dart';

/// Shared clipboard helper that handles copy + alert notification.
/// Centralizes the copy alert pattern used across the app.
class ClipboardHelper {
  /// Copies text to clipboard and shows a SnackBar alert.
  ///
  /// [context] - BuildContext for showing the SnackBar.
  /// [text] - The text to copy to clipboard.
  /// [message] - Optional custom message (defaults to 'Copiado!').
  /// [icon] - Optional custom icon (defaults to clipboardDocument).
  static Future<void> copyToClipboard(
    BuildContext context, {
    required String text,
    String? message,
    HeroIcons? icon,
  }) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            HeroIcon(
              icon ?? HeroIcons.clipboardDocument,
              size: 18,
              color: AppColors.textPrimary,
            ),
            const SizedBox(width: 12),
            Text(
              message ?? 'Copiado!',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surfaceCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
