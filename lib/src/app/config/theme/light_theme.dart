import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// phase2-fix: a real ThemeData. Previously this file held 3 properties, so
/// every Material 3 widget fell back to the framework default purple seed
/// and theming evolution (incl. dark mode) was impossible (audit A8-P0-1).
/// LemiFont left the global fallback chain — it is a decorative CJK font
/// never referenced as a UI family (audit A8-P1-3).
class LightTheme {
  ThemeData lightTheme(BuildContext context) {
    const scheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightTextOnPrimary,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.lightTextOnPrimary,
      error: AppColors.error,
      onError: AppColors.lightTextOnPrimary,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
    );

    final baseText = Typography.material2021().black.apply(
          fontFamily: 'Plus Jakarta Sans',
          bodyColor: AppColors.lightTextPrimary,
          displayColor: AppColors.lightTextPrimary,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: 'Plus Jakarta Sans',
      fontFamilyFallback: const ['Vazirmatn', 'NotoSansRU'],
      textTheme: baseText,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBackground,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.lightTextPrimary,
        contentTextStyle: const TextStyle(
          color: AppColors.lightTextOnPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightBackground,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightPrimary),
        ),
      ),
    );
  }
}
