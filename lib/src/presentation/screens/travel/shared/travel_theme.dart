import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';

/// TravelTheme — unified travel design tokens aligned with the global
/// eCardo Design System (NUVO palette) and supporting dynamic theme awareness.
class TravelTheme {
  // ------------------ NUVO PALETTE ALIGNMENT ------------------
  /// Screen background mapped to AppColors.lightBackground (0xFFF9F9FB)
  static const Color background = AppColors.lightBackground;

  /// Primary high-contrast text mapped to AppColors.deepBlack (0xFF161614)
  static const Color ink = AppColors.deepBlack;

  /// Secondary/muted text mapped to AppColors.softGray (0xFF656262)
  static const Color muted = AppColors.softGray;

  /// Border/divider line color mapped to AppColors.lightWarmGray (0xFFD5CBC8)
  static const Color border = AppColors.lightWarmGray;

  /// Travel brand accent harmonized with eCardo brand palette (AppColors.mainSoftBlue: 0xFFABC3EA)
  static const Color purple = AppColors.mainSoftBlue;

  /// Brand accent alias mapped to AppColors.mainSoftBlue
  static const Color accent = AppColors.mainSoftBlue;

  /// Travel product colors
  static const Color blue = Color(0xFF2F80ED);
  static const Color yellow = Color(0xFFF2C94C);
  static const Color green = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color red = AppColors.error;

  // ------------------ SEMANTIC & BACKWARD-COMPAT ALIASES ------------------
  /// Primary text token (alias to ink)
  static const Color textPrimary = ink;

  /// Secondary text token (alias to muted)
  static const Color textSecondary = muted;

  /// Surface card background
  static const Color surface = AppColors.lightSurface;

  /// Card background token preserved for backward compatibility
  static const Color cardBg = AppColors.lightCard;

  /// Card surface alias
  static const Color cardSurface = AppColors.lightCard;

  /// Primary action color (alias to purple / brand accent)
  static const Color primary = purple;

  // ------------------ SHAPE & ELEVATION ------------------
  static BorderRadius get radius => BorderRadius.circular(24);
  static BorderRadius get radiusMd => BorderRadius.circular(16);
  static BorderRadius get radiusSm => BorderRadius.circular(12);

  static List<BoxShadow> get shadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];

  // ------------------ THEME AWARENESS & DARK MODE ------------------
  /// Whether the active theme is dark mode.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  /// Theme-aware screen background color.
  static Color backgroundFor(BuildContext context) =>
      isDark(context) ? AppColors.darkBackground : AppColors.lightBackground;

  /// Theme-aware card/surface background color.
  static Color cardSurfaceFor(BuildContext context) =>
      isDark(context) ? AppColors.darkSurface : AppColors.lightCard;

  /// Theme-aware generic surface color.
  static Color surfaceFor(BuildContext context) => cardSurfaceFor(context);

  /// Theme-aware primary text color.
  static Color textPrimaryFor(BuildContext context) =>
      isDark(context) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  /// Theme-aware secondary text color.
  static Color textSecondaryFor(BuildContext context) =>
      isDark(context) ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

  /// Theme-aware muted text alias.
  static Color textMutedFor(BuildContext context) =>
      textSecondaryFor(context);

  /// Theme-aware border/divider color.
  static Color borderFor(BuildContext context) =>
      isDark(context)
          ? AppColors.lightWarmGray.withValues(alpha: 0.2)
          : AppColors.lightBorder;

  /// Theme-aware primary brand color.
  static Color primaryFor(BuildContext context) =>
      isDark(context)
          ? AppColors.darkPrimary
          : Theme.of(context).colorScheme.primary;

  /// Theme-aware accent color.
  static Color accentFor(BuildContext context) => AppColors.mainSoftBlue;

  /// Theme-aware card elevation shadow.
  static List<BoxShadow> shadowFor(BuildContext context) {
    if (isDark(context)) {
      return [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.35),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
    }
    return shadow;
  }
}
