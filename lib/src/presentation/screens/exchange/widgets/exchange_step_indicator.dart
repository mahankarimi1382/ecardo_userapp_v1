import 'package:flutter/material.dart';

import '../../../../app/constants/app_colors.dart';

/// A minimal three-step progress indicator: ● — ● — ●.
///
/// Following the Bauhaus / German minimalist convention requested in the
/// redesign brief: thin connecting lines, small dots, no labels. The active
/// step fills smoothly via an [AnimatedContainer].
///
/// Reusable — the widget has no exchange-specific dependency. Could be lifted
/// into `lib/src/common/widgets/` if other multi-step flows (KYC, Add Money,
/// Withdraw) adopt the same pattern.
class ExchangeStepIndicator extends StatelessWidget {
  const ExchangeStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.activeColor,
    this.inactiveColor,
    this.lineColor,
    this.dotSize = 8.0,
    this.lineLength = 24.0,
  });

  /// Zero-indexed current step.
  final int currentStep;

  final int totalSteps;

  final Color? activeColor;
  final Color? inactiveColor;
  final Color? lineColor;

  final double dotSize;
  final double lineLength;

  @override
  Widget build(BuildContext context) {
    final active = activeColor ?? AppColors.lightPrimary;
    final inactive =
        inactiveColor ?? AppColors.lightTextPrimary.withValues(alpha: 0.15);
    final line = lineColor ?? inactive;

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < totalSteps; i++) ...[
            _Dot(
              isActive: i <= currentStep,
              isCurrent: i == currentStep,
              activeColor: active,
              inactiveColor: inactive,
              size: dotSize,
            ),
            if (i < totalSteps - 1)
              _Line(
                isFilled: i < currentStep,
                activeColor: active,
                inactiveColor: line,
                length: lineLength,
              ),
          ],
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.isActive,
    required this.isCurrent,
    required this.activeColor,
    required this.inactiveColor,
    required this.size,
  });

  final bool isActive;
  final bool isCurrent;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Current step gets a slightly larger dot with a soft halo — adds
    // motion without breaking the minimalism rule.
    final effectiveSize = isCurrent ? size * 1.5 : size;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutQuart,
      width: effectiveSize,
      height: effectiveSize,
      decoration: BoxDecoration(
        color: isActive ? activeColor : inactiveColor,
        shape: BoxShape.circle,
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: activeColor.withValues(alpha: 0.30),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({
    required this.isFilled,
    required this.activeColor,
    required this.inactiveColor,
    required this.length,
  });

  final bool isFilled;
  final Color activeColor;
  final Color inactiveColor;
  final double length;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutQuart,
      width: length,
      height: 2,
      margin: const EdgeInsetsDirectional.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isFilled ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
