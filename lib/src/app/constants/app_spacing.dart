import 'package:flutter/material.dart';

/// Single source of truth for spacing / type scale (fintech consistency).
class AppSpacing {
  static const double page = 16;
  static const double cardGap = 12;
  static const double sectionGap = 20;
  static const double radius = 16;

  static EdgeInsets get pageInsets =>
      const EdgeInsets.symmetric(horizontal: page);
}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );
  static const subtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );
  static const caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.35,
  );
}
