import 'package:flutter/material.dart';

/// AppColors — central color palette for the eCardo app.
///
/// All screens should reference colors from this class only.
/// Never hardcode hex values in widgets.
class AppColors {
  // ------------------ LIGHT THEME ------------------

  // Background Colors
  static const Color lightBackground = Color(0xFFF8F8F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Primary Colors
  static const Color lightPrimary = Color(0xFF7445FF);
  static const Color lightPrimaryContainer = Color(0xFFEFEDFF);
  static const Color lightPrimaryDark = Color(0xFF5A35CC);

  // Accent / Secondary
  static const Color lightSecondary = Color(0xFF00BFA6);
  static const Color lightAccent = Color(0xFFFF7A00);

  // Text Colors
  static const Color lightTextPrimary = Color(0xFF2D2D2D);
  static Color lightTextTertiary = Color(0xFF2D2D2D).withValues(alpha: 0.60);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  static const Color lightTextHint = Color(0xFF9E9E9E);
  static const Color lightTextOnPrimary = Color(0xFFFFFFFF);

  // Border / Divider
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightDivider = Color(0xFFEEEEEE);
  static const Color lightShadow = Color(0x1A000000);

  // ------------------ UTILITY ------------------

  // Error/Warning/Success
  static const Color error = Color(0xFFDC3C22);
  static const Color errorContainer = Color(0xFFFDECEA);
  static const Color warning = Color(0xFFFFAA00);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color success = Color(0xFF14AE6F);
  static const Color successContainer = Color(0xFFE8F8F0);
  static const Color info = Color(0xFF2196F3);
  static const Color infoContainer = Color(0xFFE3F2FD);

  // Neutral
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFBDBDBD);
  static const Color greyDark = Color(0xFF616161);

  // ------------------ DARK THEME (future) ------------------
  // Placeholder — will be filled when dark theme is implemented
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkPrimary = Color(0xFF9D7AFF);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkBorder = Color(0xFF2A2A2A);
}
