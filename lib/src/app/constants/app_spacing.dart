import 'package:flutter/material.dart';

/// Single source of truth for spacing / type scale (fintech consistency).
class AppSpacing {
  static const double page = 16;
  static const double cardGap = 12;
  static const double sectionGap = 20;
  static const double radius = 16;

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
