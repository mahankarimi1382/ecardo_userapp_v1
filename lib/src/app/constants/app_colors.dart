import 'package:flutter/material.dart';

/// AppColors — central color palette for the bank of al barkat app.
/// Based on NUVO Palette (Dark / Neutral / Soft Blue / Warm Metallic).
class AppColors {
  // ------------------ NUVO PALETTE SPEC ------------------
  static const Color deepBlack = Color(0xFF161614); /* Primary Background */
  static const Color darkGray = Color(0xFF262625); /* Secondary Background */
  static const Color softGray = Color(0xFF656262); /* Secondary Text / Icons */
  static const Color warmWhite = Color(0xFFE7E0DE); /* Primary Text / Light Surface */
  static const Color lightWarmGray = Color(0xFFD5CBC8); /* Borders / Dividers */
  static const Color mainSoftBlue = Color(0xFFABC3EA); /* Primary Accent / Main Surface */
  static const Color mutedBlue = Color(0xFF849ACD); /* Secondary Accent / Cards */
  static const Color warmBrown = Color(0xFF87624C); /* Financial / Card Elements */
  static const Color taupeBronze = Color(0xFFB3A9A5); /* Warm Neutral / Metallic */

  // ------------------ LIGHT THEME ------------------

  // Background Colors
  static const Color lightBackground = Color(0xFFF9F9FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Primary Colors (Monochrome & Black/White with Deep Black primary)
  static const Color lightPrimary = deepBlack;
  static const Color lightPrimaryContainer = mainSoftBlue;
  static const Color lightPrimaryDark = darkGray;

  // Accent / Secondary
  static const Color lightSecondary = mutedBlue;
  static const Color lightAccent = mainSoftBlue;

  // Text Colors
  static const Color lightTextPrimary = deepBlack;
  static Color lightTextTertiary = deepBlack.withValues(alpha: 0.60);
  static const Color lightTextSecondary = softGray;
  static const Color lightTextHint = softGray;
  static const Color lightTextOnPrimary = Color(0xFFFFFFFF);

  // Border / Divider
  static const Color lightBorder = lightWarmGray;
  static const Color lightDivider = lightWarmGray;
  static const Color lightShadow = Color(0x1A000000);

  // ------------------ UTILITY ------------------

  // Error/Warning/Success
  static const Color error = Color(0xFFDC3C22);
  static const Color errorContainer = Color(0xFFFDECEA);
  static const Color warning = Color(0xFFFFAA00);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color success = Color(0xFF14AE6F);
  static const Color successContainer = Color(0xFFE8F8F0);
  static const Color info = mutedBlue;
  static const Color infoContainer = Color(0xFFEBF1FA);

  // Neutral
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;
  static const Color grey = softGray;
  static const Color greyLight = lightWarmGray;
  static const Color greyDark = darkGray;

  // ------------------ DARK THEME ------------------
  static const Color darkBackground = deepBlack;
  static const Color darkSurface = darkGray;
  static const Color darkPrimary = mainSoftBlue;
  static const Color darkTextPrimary = warmWhite;
  static const Color darkTextSecondary = softGray;
  static const Color darkBorder = darkGray;
}
