import 'package:flutter/material.dart';

/// Single source of truth for spacing, radius, icons, durations and type scale (fintech consistency).
class AppSpacing {
  const AppSpacing._();

  // ------------------ 8PX GRID SCALE ------------------
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 48.0;

  // Semantic aliases (backward compatibility)
  static const double page = lg;
  static const double cardGap = md;
  static const double sectionGap = xl;
  static const double radius = radiusLg;

  // ------------------ RADIUS TOKENS ------------------
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 999.0;

  // ------------------ ICON SIZE TOKENS ------------------
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ------------------ ANIMATION DURATIONS ------------------
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // ------------------ INSETS & SAFE AREA ------------------
  static EdgeInsets get pageInsets =>
      const EdgeInsets.symmetric(horizontal: page);

  /// Platform-adaptive bottom spacing that respects system navigation bars / Home Indicator.
  /// If the platform reports a bottom inset (Android gesture/nav bar, iOS home bar),
  /// it is added to [extra]. If on web or devices with 0 bottom inset, only [extra] is used.
  static double bottomSafe(BuildContext context, [double extra = 16]) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return bottomInset > 0 ? bottomInset + extra : extra;
  }

  /// An EdgeInsets with safe bottom padding.
  static EdgeInsets bottomSafeInsets(BuildContext context, [double extra = 16]) {
    return EdgeInsets.only(bottom: bottomSafe(context, extra));
  }
}

/// Standalone duration tokens for animations and transitions.
class AppDurations {
  const AppDurations._();
  static const Duration fast = AppSpacing.fast;
  static const Duration normal = AppSpacing.normal;
  static const Duration slow = AppSpacing.slow;
}

/// Complete Material 3 typography scale with backward compatibility getters.
class AppTextStyles {
  const AppTextStyles._();

  // ------------------ MATERIAL 3 TYPE SCALE ------------------

  // Display
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  // Headline
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    height: 1.25,
  );
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  // Title
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
  );
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
    height: 1.50,
  );
  static const TextStyle titleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );

  // Body
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.50,
  );
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  // Label
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    height: 1.43,
  );
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.33,
  );
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );

  // ------------------ BACKWARD COMPATIBILITY ------------------
  static const TextStyle title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const TextStyle subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
}
