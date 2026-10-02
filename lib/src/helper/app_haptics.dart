import 'package:flutter/services.dart';

/// AppHaptics — standard haptic feedback for financial & interactive actions.
class AppHaptics {
  /// Light impact for regular button taps, tabs, and filters.
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for financial confirmations, biometric prompt, submit.
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for critical financial executions.
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for pickers, date selections, dropdowns.
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for validation errors and security warnings.
  static void error() {
    HapticFeedback.vibrate();
  }
}
