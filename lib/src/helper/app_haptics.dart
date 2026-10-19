import 'package:flutter/services.dart';

/// AppHaptics — standard haptic & auditory feedback for financial & interactive actions.
class AppHaptics {
  /// Light impact for regular button taps, tabs, and filters.
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for financial confirmations, biometric prompt, submit.
  static void medium() {
    HapticFeedback.mediumImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Heavy impact and sound for critical financial executions and celebrations.
  static void heavy() {
    HapticFeedback.heavyImpact();
    SystemSound.play(SystemSoundType.click);
  }

  /// Selection click for pickers, date selections, dropdowns.
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for validation errors and security warnings.
  static void error() {
    HapticFeedback.vibrate();
    SystemSound.play(SystemSoundType.alert);
  }

  /// Play financial success audio cue
  static void playSuccessSound() {
    SystemSound.play(SystemSoundType.click);
  }
}
