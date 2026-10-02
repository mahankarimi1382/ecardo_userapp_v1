import 'package:flutter/material.dart';

class TravelTheme {
  static const background = Color(0xFFF8F9FA);
  static const ink = Color(0xFF191C1D);
  static const muted = Color(0xFF727785);
  static const border = Color(0xFFE1E3E4);
  static const purple = Color(0xFF9B51E0);
  static const blue = Color(0xFF2F80ED);
  static const yellow = Color(0xFFF2C94C);
  static const green = Color(0xFF27AE60);
  static const warning = Color(0xFFF2994A);
  static const red = Color(0xFFC62828);

  // Semantic aliases used by the service screens (CIP lounge et al.) so
  // they can stay on the shared theme instead of hard-coding colors.
  static const Color textPrimary = ink;
  static const Color textSecondary = muted;
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = purple;

  static BorderRadius get radius => BorderRadius.circular(24);

  static List<BoxShadow> get shadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 24,
      offset: const Offset(0, 10),
    ),
  ];
}
