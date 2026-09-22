import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

class Responsive {
  /// Horizontal page padding — fixed brand standard (16).
  static double pagePadding(BuildContext context) => AppSpacing.page;

  static double cardRadius(BuildContext context) => AppSpacing.radius;

  static double sectionGap(BuildContext context) => AppSpacing.sectionGap;
}
