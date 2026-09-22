import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

class DarkTheme {
  ThemeData darkTheme(BuildContext context) {
    const brand = AppColors.lightPrimary; // #7445FF
    const brandDeep = Color(0xFF3D248F);
    const scheme = ColorScheme.dark(
      primary: brand,
      onPrimary: Colors.white,
      secondary: AppColors.lightSecondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: Colors.white,
      surface: Color(0xFF1A1A1E),
      onSurface: Color(0xFFF2F2F5),
    );

    final baseText = Typography.material2021().white.apply(
      fontFamily: 'Plus Jakarta Sans',
      bodyColor: const Color(0xFFF2F2F5),
      displayColor: const Color(0xFFF2F2F5),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFF121214),
      fontFamily: 'Plus Jakarta Sans',
      fontFamilyFallback: const ['Vazirmatn', 'NotoSansRU'],
      textTheme: baseText,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF121214),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardColor: const Color(0xFF1E1E24),
      dividerColor: Colors.white12,
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Color(0xFF2A2A32),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: brand,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1E),
        selectedItemColor: brand,
        unselectedItemColor: Colors.white54,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1E1E24),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: brandDeep.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
