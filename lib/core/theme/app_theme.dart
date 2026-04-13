import 'package:flutter/material.dart';
import 'package:wolfchat/core/theme/app_colors.dart';
import 'package:wolfchat/core/theme/app_typography.dart';

abstract final class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppTypography.primaryFontFamily,
    textTheme: AppTypography.textTheme.apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    ),
    scaffoldBackgroundColor: AppColors.surfaceMain,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.brand500,
      onPrimary: AppColors.textPrimary,
      primaryContainer: AppColors.brand900,
      onPrimaryContainer: AppColors.brand100,
      secondary: AppColors.brand400,
      onSecondary: AppColors.textPrimary,
      secondaryContainer: AppColors.accentLight,
      onSecondaryContainer: AppColors.brand100,
      tertiary: AppColors.brand300,
      onTertiary: AppColors.textPrimary,
      tertiaryContainer: AppColors.accentLight,
      onTertiaryContainer: AppColors.brand100,
      error: AppColors.brand600,
      onError: AppColors.textPrimary,
      surface: AppColors.surfaceMain,
      surfaceContainerHighest: AppColors.surfaceCard,
      onSurfaceVariant: AppColors.textSecondary,
      outline: AppColors.accentLight,
      outlineVariant: AppColors.accentDark,
      shadow: AppColors.accentDark,
      scrim: AppColors.accentDark,
      inverseSurface: AppColors.textPrimary,
      onInverseSurface: AppColors.surfaceMain,
      inversePrimary: AppColors.brand200,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surfaceMain,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontFamily: AppTypography.primaryFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surfaceCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceInput,
      hintStyle: const TextStyle(
        fontFamily: AppTypography.primaryFontFamily,
        color: AppColors.textSecondary,
        fontSize: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand500, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand600, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.brand600, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.brand500,
        foregroundColor: AppColors.textPrimary,
        textStyle: const TextStyle(
          fontFamily: AppTypography.primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: const BorderSide(color: AppColors.accentLight, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: AppTypography.primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brand400,
        textStyle: const TextStyle(
          fontFamily: AppTypography.primaryFontFamily,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.brand500,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.accentDark,
      selectedItemColor: AppColors.brand500,
      unselectedItemColor: AppColors.textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.accentLight,
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceCard,
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.primaryFontFamily,
        color: AppColors.textPrimary,
        fontSize: 14,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: const TextStyle(
        fontFamily: AppTypography.primaryFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: AppTypography.primaryFontFamily,
        fontSize: 14,
        color: AppColors.textSecondary,
      ),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.surfaceCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 0,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceCard,
      selectedColor: AppColors.brand500,
      labelStyle: const TextStyle(
        fontFamily: AppTypography.primaryFontFamily,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide.none,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),
    iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 24),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.brand500,
      linearTrackColor: AppColors.surfaceCard,
      circularTrackColor: AppColors.surfaceCard,
    ),
  );
}

// Pseudo-update for commit 20 at 2026-04-06 17:57:38

// Pseudo-update for commit 53 at 2026-04-13 17:57:38
