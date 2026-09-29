import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

class LightTheme {
  ThemeData lightTheme(BuildContext context) {
    const scheme = ColorScheme.light(
      primary: AppColors.deepBlack,
      onPrimary: AppColors.warmWhite,
      secondary: AppColors.mutedBlue,
      onSecondary: AppColors.warmWhite,
      error: AppColors.error,
      onError: AppColors.warmWhite,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      surface: AppColors.lightBackground,
      onSurface: AppColors.deepBlack,
    );

    final baseText = Typography.material2021().black.apply(
          fontFamily: 'Plus Jakarta Sans',
          bodyColor: AppColors.deepBlack,
          displayColor: AppColors.deepBlack,
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
        foregroundColor: AppColors.deepBlack,
        elevation: 0,
        centerTitle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deepBlack,
        contentTextStyle: const TextStyle(
          color: AppColors.warmWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.lightBackground,
        titleTextStyle: TextStyle(
          color: AppColors.deepBlack,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightWarmGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.lightWarmGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.deepBlack, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlack,
          foregroundColor: AppColors.warmWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.deepBlack,
        foregroundColor: AppColors.warmWhite,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.deepBlack,
        unselectedItemColor: AppColors.softGray,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.mainSoftBlue.withValues(alpha: 0.15),
        selectedColor: AppColors.deepBlack,
        labelStyle: const TextStyle(color: AppColors.deepBlack),
        side: const BorderSide(color: AppColors.lightWarmGray),
      ),
    );
  }
}
