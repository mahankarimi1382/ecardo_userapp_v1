import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

class DarkTheme {
  ThemeData darkTheme(BuildContext context) {
    const brand = AppColors.mainSoftBlue;
    const scheme = ColorScheme.dark(
      primary: brand,
      onPrimary: AppColors.deepBlack,
      secondary: AppColors.mutedBlue,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: AppColors.darkGray,
      onSurface: AppColors.warmWhite,
    );

    final baseText = Typography.material2021().white.apply(
      fontFamily: 'Plus Jakarta Sans',
      bodyColor: AppColors.warmWhite,
      displayColor: AppColors.warmWhite,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,

      scaffoldBackgroundColor: AppColors.deepBlack,
      fontFamily: 'Plus Jakarta Sans',
      fontFamilyFallback: const ['Vazirmatn', 'NotoSansRU'],
      textTheme: baseText,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepBlack,
        foregroundColor: AppColors.warmWhite,
        elevation: 0,
        centerTitle: true,
      ),
      cardColor: AppColors.darkGray,
      dividerColor: AppColors.lightWarmGray.withValues(alpha: 0.2),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.darkGray,
        contentTextStyle: TextStyle(
          color: AppColors.warmWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.darkGray,
        titleTextStyle: TextStyle(
          color: AppColors.warmWhite,
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: brand.withValues(alpha: 0.15),
        selectedColor: brand,
        labelStyle: const TextStyle(color: AppColors.warmWhite),
        side: BorderSide(color: AppColors.lightWarmGray.withValues(alpha: 0.3)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: AppColors.deepBlack,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: AppColors.deepBlack,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkGray,
        selectedItemColor: brand,
        unselectedItemColor: AppColors.softGray,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.lightWarmGray.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}
