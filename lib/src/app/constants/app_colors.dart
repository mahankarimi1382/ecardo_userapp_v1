import 'package:flutter/material.dart';

/// AppColors — central color palette for the eCardo app.
/// Based on NUVO Palette (Dark / Neutral / Soft Blue / Warm Metallic).
class AppColors {
  const AppColors._();

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
  static const Color lightSurfaceVariant = Color(0xFFF0EDEC);
  static const Color lightCard = Color(0xFFFFFFFF);

  // Primary Colors (Monochrome & Black/White with Deep Black primary)
  static const Color lightPrimary = deepBlack;
  static const Color lightPrimaryContainer = mainSoftBlue;
  static const Color lightPrimaryDark = darkGray;

  // Accent / Secondary
  static const Color lightSecondary = mutedBlue;
  static const Color lightSecondaryContainer = Color(0xFFEBF1FA);
  static const Color lightAccent = mainSoftBlue;

  // Text Colors
  static const Color lightTextPrimary = deepBlack;
  static const Color lightTextSecondary = softGray;
  static const Color lightTextTertiary = Color(0x99161614); // deepBlack with alpha 0.60
  static const Color lightTextHint = softGray;
  static const Color lightTextOnPrimary = Color(0xFFFFFFFF);

  // Border / Divider
  static const Color lightBorder = lightWarmGray;
  static const Color lightOutline = lightWarmGray;
  static const Color lightOutlineVariant = Color(0xFFE8E2E0);
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
  static const Color darkSurfaceVariant = Color(0xFF323230);
  static const Color darkCard = darkGray;
  static const Color darkPrimary = mainSoftBlue;
  static const Color darkPrimaryContainer = Color(0xFF1E2E42);
  static const Color darkPrimaryDark = deepBlack;
  static const Color darkSecondary = mutedBlue;
  static const Color darkSecondaryContainer = Color(0xFF263345);
  static const Color darkAccent = mainSoftBlue;
  static const Color darkTextPrimary = warmWhite;
  static const Color darkTextSecondary = softGray;
  static const Color darkTextTertiary = Color(0x8CE7E0DE); // warmWhite with alpha 0.55
  static const Color darkTextHint = softGray;
  static const Color darkTextOnPrimary = deepBlack;
  static const Color darkBorder = Color(0x33D5CBC8); // lightWarmGray with alpha 0.20
  static const Color darkOutline = Color(0x4DD5CBC8); // lightWarmGray with alpha 0.30
  static const Color darkOutlineVariant = Color(0x26D5CBC8); // lightWarmGray with alpha 0.15
  static const Color darkDivider = Color(0x33D5CBC8);
  static const Color darkShadow = Color(0x33000000);
}
