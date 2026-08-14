import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';

/// Design tokens specific to the Exchange module.
///
/// Why a separate file instead of editing [AppColors]?
///   - The acceptance criteria say: don't touch files outside the
///     exchange module except where explicitly required (pubspec, common
///     widgets). AppColors is a shared file used by every screen.
///   - We need a few extra tokens: gradient stops, glassmorphism overlay,
///     dark-mode placeholders. Keeping them local lets the Exchange
///     redesign ship without ripple effects.
///   - When the app later rolls out full dark mode, these tokens can be
///     promoted into AppColors with no API change for callers.
class ExchangeDesignTokens {
  // ------------------ Brand gradient (from-card) ------------------
  /// Primary → dark-primary, used for the FROM card background.
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.lightPrimary, AppColors.lightPrimaryDark],
  );

  /// Soft radial highlight placed on top of [brandGradient] in the
  /// top-left corner — gives depth without an image asset.
  static const RadialGradient softHighlight = RadialGradient(
    center: Alignment(-0.8, -0.8),
    radius: 0.9,
    colors: [
      Color(0x33FFFFFF), // 20% white
      Color(0x00FFFFFF),
    ],
  );

  // ------------------ Glass overlay (hero amount field) ------------------
  /// Subtle frosted-glass surface used only on the hero amount input on
  /// the FROM card. ~12% white with an 8-sigma blur applied by the
  /// caller via [BackdropFilter].
  static const Color glassOverlay = Color(0x1FFFFFFF); // 12% white
  static const Color glassOverlayFocused = Color(0x73FFFFFF); // 45% white

  // ------------------ Surfaces (cards on light background) ------------------
  static const Color cardSurface = AppColors.white;
  static const Color cardBorder = Color(0x0FD9D9D9); // 6% grey
  static const Color divider = Color(0x0F000000); // 6% black

  // ------------------ Quick chip ------------------
  static const Color chipBackground = Color(0x0F7445FF); // 6% primary
  static const Color chipBorder = Color(0x267445FF); // 15% primary
  static const Color chipText = AppColors.lightPrimary;

  // ------------------ Stale / disconnected states ------------------
  static const Color staleAccent = AppColors.warning;
  static const Color disconnectedAccent = AppColors.grey;

  // ------------------ Dark mode placeholders ------------------
  // These are NOT yet wired to a Theme.of(context).ofbrightness check —
  // the app is light-only today. Defining them now costs nothing and
  // means dark mode becomes a 1-line flip per call site later.
  static const Color darkBrandGradientStart = AppColors.darkPrimary;
  static const Color darkBrandGradientEnd =
      Color(0xFF3A22A0); // darker than lightPrimaryDark
  static const Color darkCardSurface = AppColors.darkSurface;
  static const Color darkCardBorder = Color(0x1AFFFFFF);
  static const Color darkDivider = Color(0x14FFFFFF);

  static const LinearGradient darkBrandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBrandGradientStart, darkBrandGradientEnd],
  );

  /// Returns the appropriate gradient based on [brightness].
  static LinearGradient gradientFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkBrandGradient
        : brandGradient;
  }

  /// Returns the appropriate card surface color.
  static Color cardSurfaceFor(Brightness brightness) {
    return brightness == Brightness.dark
        ? darkCardSurface
        : cardSurface;
  }
}
