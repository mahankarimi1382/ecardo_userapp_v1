import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

class LightTheme {
  ThemeData lightTheme(BuildContext context) {
    const scheme = ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightTextOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: AppColors.lightPrimaryDark,
      secondary: AppColors.lightSecondary,
      onSecondary: AppColors.deepBlack,
      secondaryContainer: AppColors.lightSecondaryContainer,
      onSecondaryContainer: AppColors.deepBlack,
      surface: AppColors.lightBackground,
      onSurface: AppColors.deepBlack,
      surfaceContainerLowest: AppColors.lightBackground,
      surfaceContainerLow: Color(0xFFF1F3F8),
      surfaceContainer: AppColors.lightSurface,
      surfaceContainerHigh: AppColors.lightSurfaceVariant,
      surfaceContainerHighest: Color(0xFFE7EAEE),
      error: AppColors.error,
      onError: AppColors.warmWhite,
      errorContainer: AppColors.errorContainer,
      onErrorContainer: AppColors.error,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
    );

    final locale = Localizations.maybeLocaleOf(context)?.languageCode ?? 'en';
    final isRtlLanguage = locale == 'fa' || locale == 'ar';
    final primaryFont = isRtlLanguage ? 'Vazirmatn' : 'Plus Jakarta Sans';
    final fallbackFonts = isRtlLanguage
        ? const ['Plus Jakarta Sans', 'NotoSansRU']
        : const ['Vazirmatn', 'NotoSansRU'];

    final baseText = Typography.material2021().black.apply(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          bodyColor: AppColors.deepBlack,
          displayColor: AppColors.deepBlack,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      fontFamily: primaryFont,
      fontFamilyFallback: fallbackFonts,
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
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
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
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: AppColors.lightTextOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
          textStyle: TextStyle(
            fontFamily: primaryFont,
            fontFamilyFallback: fallbackFonts,
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
          textStyle: TextStyle(
            fontFamily: primaryFont,
            fontFamilyFallback: fallbackFonts,
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
            return AppColors.white;
          }
          return AppColors.softGray;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.lightPrimary;
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
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.lightPrimary,
        unselectedLabelColor: AppColors.softGray,
        indicatorColor: AppColors.lightPrimary,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: AppColors.lightBorder,
        labelStyle: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: primaryFont,
          fontFamilyFallback: fallbackFonts,
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        indicatorColor: AppColors.lightPrimary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontFamily: primaryFont,
              fontFamilyFallback: fallbackFonts,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.lightPrimary,
            );
          }
          return TextStyle(
            fontFamily: primaryFont,
            fontFamilyFallback: fallbackFonts,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.softGray,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.lightPrimary, size: AppSpacing.iconMd);
          }
          return const IconThemeData(color: AppColors.softGray, size: AppSpacing.iconMd);
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: AppColors.lightTextOnPrimary,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        selectedItemColor: AppColors.lightPrimary,
        unselectedItemColor: AppColors.softGray,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightPrimaryContainer.withValues(alpha: 0.55),
        selectedColor: AppColors.lightPrimary,
        labelStyle: const TextStyle(color: AppColors.deepBlack),
        side: const BorderSide(color: AppColors.lightWarmGray),
      ),
    );
  }
}
