import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

class LightTheme {
  ThemeData lightTheme(BuildContext context) {
    const scheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.white,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightPrimaryDark,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.white,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.lightPrimaryDark,
      surface: AppColors.lightBackground,
      onSurface: AppColors.deepBlack,
      surfaceContainerLowest: AppColors.lightBackground,
      surfaceContainerLow: Color(0xFFF4F4F6),
      surfaceContainer: AppColors.lightSurface,
      surfaceContainerHigh: AppColors.lightSurfaceVariant,
      surfaceContainerHighest: Color(0xFFE8E5E4),
      error: AppColors.error,
      onError: AppColors.warmWhite,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
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
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deepBlack,
        contentTextStyle: TextStyle(
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
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.deepBlack, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.deepBlack,
          foregroundColor: AppColors.warmWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.deepBlack,
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.deepBlack,
          side: const BorderSide(color: AppColors.lightBorder, width: 1.5),
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.deepBlack;
          }
          return AppColors.softGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.mainSoftBlue;
          }
          return AppColors.lightWarmGray.withValues(alpha: 0.5);
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.transparent;
          }
          return AppColors.lightWarmGray;
        }),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.deepBlack,
        unselectedLabelColor: AppColors.softGray,
        indicatorColor: AppColors.deepBlack,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.lightBorder,
        labelStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        indicatorColor: AppColors.deepBlack.withValues(alpha: 0.1),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.deepBlack,
            );
          }
          return const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.softGray,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.deepBlack, size: AppSpacing.iconMd);
          }
          return const IconThemeData(color: AppColors.softGray, size: AppSpacing.iconMd);
        }),
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
