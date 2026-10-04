import 'package:flutter/material.dart';
import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';

/// Design tokens specific to the Exchange module.
///
/// Unified with the design system:
///   - All surface / text / border colours delegate to [AppColors].
///   - Glassmorphic card styling is delegated to [EcardoGlassCard]:
///     - `_FromCard` uses the hero gradient as a [backgroundColor] override.
///     - `_ToCard` uses [EcardoGlassVariant.frosted] for frosted glassmorphism
///       with a hardware-accelerated [BackdropFilter] blur.
///   - Tokens remain as named helpers so callers don't hard-code raw colours.
///
/// Follows the Nuvo Palette and eCardo fintech design language:
/// - Light & Dark theme-adaptive surface and text colors
/// - Glassmorphic overlays with backdrop filters
/// - 8px grid tokens from [AppSpacing]
/// - Directional RTL/LTR layout helpers
class ExchangeDesignTokens {
  const ExchangeDesignTokens._();

  /// Helper to determine whether the current context is Dark Mode.
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ------------------ Brand gradients (Hero From Card) ------------------
  /// Primary -> dark-primary gradient used for the FROM card background in light theme.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.lightPrimary, AppColors.lightPrimaryDark],
  );

  /// Nuanced deep slate & metallic accent gradient for dark theme.
  static const LinearGradient darkBrandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E2430), Color(0xFF14171E)],
  );

  /// Dynamic gradient matching the current brightness.
  static LinearGradient gradientFor(Brightness brightness) {
    return brightness == Brightness.dark ? darkBrandGradient : brandGradient;
  }

  /// Radial highlight placed on top of the hero card to create depth.
  static RadialGradient softHighlightFor(Brightness brightness) {
    return RadialGradient(
      center: const Alignment(-0.8, -0.8),
      radius: 0.9,
      colors: [
        brightness == Brightness.dark
            ? AppColors.mainSoftBlue.withValues(alpha: 0.22)
            : Colors.white.withValues(alpha: 0.18),
        Colors.transparent,
      ],
    );
  }

  // ------------------ Glassmorphic Overlays ------------------
  static Color glassOverlay(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.08)
      : Colors.white.withValues(alpha: 0.12);

  static Color glassOverlayFocused(BuildContext context) => isDark(context)
      ? Colors.white.withValues(alpha: 0.18)
      : Colors.white.withValues(alpha: 0.35);

  static Color glassBorder(BuildContext context, {bool isFocused = false}) {
    if (isFocused) {
      return isDark(context)
          ? AppColors.mainSoftBlue.withValues(alpha: 0.60)
          : Colors.white.withValues(alpha: 0.65);
    }
    return isDark(context)
        ? Colors.white.withValues(alpha: 0.14)
        : Colors.white.withValues(alpha: 0.20);
  }

  // ------------------ Theme-Adaptive Surfaces ------------------
  static Color screenBackground(BuildContext context) =>
      isDark(context) ? AppColors.darkBackground : AppColors.lightBackground;

  static Color cardSurface(BuildContext context) =>
      isDark(context) ? AppColors.darkCard : AppColors.lightCard;

  static Color cardBorder(BuildContext context) => isDark(context)
      ? AppColors.darkBorder
      : AppColors.lightTextPrimary.withValues(alpha: 0.06);

  static Color elevatedSurface(BuildContext context) => isDark(context)
      ? AppColors.darkSurfaceVariant
      : AppColors.lightSurfaceVariant;

  static Color divider(BuildContext context) => isDark(context)
      ? AppColors.darkDivider
      : AppColors.lightTextPrimary.withValues(alpha: 0.06);

  // ------------------ Theme-Adaptive Typography ------------------
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color textSecondary(BuildContext context) => isDark(context)
      ? AppColors.darkTextSecondary
      : AppColors.lightTextSecondary;

  static Color textTertiary(BuildContext context) => isDark(context)
      ? AppColors.darkTextTertiary
      : AppColors.lightTextTertiary;

  // ------------------ Swap Button Affordance ------------------
  static Color swapButtonBg(BuildContext context) =>
      isDark(context) ? AppColors.darkCard : AppColors.white;

  static Color swapButtonBorder(BuildContext context) => isDark(context)
      ? AppColors.mainSoftBlue.withValues(alpha: 0.35)
      : AppColors.lightPrimary.withValues(alpha: 0.18);

  static Color swapIconColor(BuildContext context) =>
      isDark(context) ? AppColors.mainSoftBlue : AppColors.lightPrimary;

  static List<BoxShadow> swapButtonShadow(BuildContext context) => [
        BoxShadow(
          color: isDark(context)
              ? Colors.black.withValues(alpha: 0.45)
              : AppColors.lightPrimary.withValues(alpha: 0.18),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ];

  // ------------------ Quick Chip Tokens ------------------
  static Color chipBackground(BuildContext context, {bool isSelected = false}) {
    if (isSelected) {
      return isDark(context) ? AppColors.mainSoftBlue : AppColors.lightPrimary;
    }
    return isDark(context)
        ? AppColors.mainSoftBlue.withValues(alpha: 0.10)
        : AppColors.lightPrimary.withValues(alpha: 0.06);
  }

  static Color chipBorder(BuildContext context, {bool isSelected = false}) {
    if (isSelected) {
      return isDark(context) ? AppColors.mainSoftBlue : AppColors.lightPrimary;
    }
    return isDark(context)
        ? AppColors.mainSoftBlue.withValues(alpha: 0.25)
        : AppColors.lightPrimary.withValues(alpha: 0.15);
  }

  static Color chipText(BuildContext context, {bool isSelected = false}) {
    if (isSelected) {
      return isDark(context) ? AppColors.deepBlack : AppColors.white;
    }
    return isDark(context) ? AppColors.mainSoftBlue : AppColors.lightPrimary;
  }

  // ------------------ Live Feed / Status Accents ------------------
  static const Color successAccent = AppColors.success;
  static const Color warningAccent = AppColors.warning;
  static const Color errorAccent = AppColors.error;
  static const Color staleAccent = AppColors.warning;
  static const Color disconnectedAccent = AppColors.grey;

  // ------------------ Shadow Generators ------------------
  static List<BoxShadow> cardShadow(BuildContext context) => [
        BoxShadow(
          color: isDark(context)
              ? Colors.black.withValues(alpha: 0.30)
              : AppColors.lightTextPrimary.withValues(alpha: 0.04),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> heroCardShadow(BuildContext context) => [
        BoxShadow(
          color: isDark(context)
              ? Colors.black.withValues(alpha: 0.50)
              : AppColors.lightPrimary.withValues(alpha: 0.20),
          blurRadius: 24,
          offset: const Offset(0, 10),
        ),
      ];
}
