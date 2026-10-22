// Template only: adapt names to existing eCardo tokens; do not create a parallel theme.
import 'package:flutter/material.dart';

@immutable
class ECardoDesignTokens extends ThemeExtension<ECardoDesignTokens> {
  const ECardoDesignTokens({
    required this.success, required this.warning, required this.danger,
    required this.surfaceElevated, required this.focusRing,
  });

  final Color success;
  final Color warning;
  final Color danger;
  final Color surfaceElevated;
  final Color focusRing;

  @override
  ECardoDesignTokens copyWith({Color? success, Color? warning, Color? danger, Color? surfaceElevated, Color? focusRing}) =>
      ECardoDesignTokens(success: success ?? this.success, warning: warning ?? this.warning, danger: danger ?? this.danger, surfaceElevated: surfaceElevated ?? this.surfaceElevated, focusRing: focusRing ?? this.focusRing);

  @override
  ECardoDesignTokens lerp(ThemeExtension<ECardoDesignTokens>? other, double t) {
    if (other is! ECardoDesignTokens) return this;
    return ECardoDesignTokens(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      focusRing: Color.lerp(focusRing, other.focusRing, t)!,
    );
  }
}
