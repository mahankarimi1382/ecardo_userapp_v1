import 'package:flutter/material.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

import '../../../../app/constants/app_colors.dart';

/// Modern three-step progress indicator with labels.
///
/// Layout (Bauhaus / German minimalist):
///
///   ───●────●────●───
///   Amount Review Done
///
/// - Active dot is the brand purple with a soft halo
/// - Completed dots are filled
/// - Future dots are hairline grey
/// - Connecting line is animated with a gradient sweep as the user progresses
/// - Labels are 11px uppercase Plus Jakarta Sans, tracking 0.4
///
/// Reusable — the widget has no exchange-specific dependency beyond the
/// three label strings.
class ExchangeStepIndicator extends StatelessWidget {
  const ExchangeStepIndicator({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
    this.activeColor,
    this.inactiveColor,
    this.dotSize = 10.0,
    this.lineLength = 36.0,
  });

  /// Zero-indexed current step.
  final int currentStep;

  final int totalSteps;

  final Color? activeColor;
  final Color? inactiveColor;

  final double dotSize;
  final double lineLength;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final labels = [
      loc.exchangeAmount,
      loc.exchangeReviewTitle,
      loc.exchangeSuccessTitle,
    ];

    final active = activeColor ?? AppColors.lightPrimary;
    final inactive =
        inactiveColor ?? AppColors.lightTextPrimary.withValues(alpha: 0.18);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < totalSteps; i++) ...[
            _StepDot(
              label: i < labels.length ? labels[i] : '',
              isActive: i <= currentStep,
              isCurrent: i == currentStep,
              activeColor: active,
              inactiveColor: inactive,
              size: dotSize,
            ),
            if (i < totalSteps - 1)
              _ConnectorLine(
                isFilled: i < currentStep,
                activeColor: active,
                inactiveColor: inactive,
                length: lineLength,
              ),
          ],
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.label,
    required this.isActive,
    required this.isCurrent,
    required this.activeColor,
    required this.inactiveColor,
    required this.size,
  });

  final String label;
  final bool isActive;
  final bool isCurrent;
  final Color activeColor;
  final Color inactiveColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final effectiveSize = isCurrent ? size * 1.4 : size;
    final labelColor = isActive
        ? AppColors.lightTextPrimary
        : AppColors.lightTextPrimary.withValues(alpha: 0.50);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot + halo
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
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
                      blurRadius: 10,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: 6),
        // Label
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 220),
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
            color: labelColor,
            letterSpacing: 0.4,
            fontFamily: 'Plus Jakarta Sans',
          ),
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ConnectorLine extends StatelessWidget {
  const _ConnectorLine({
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
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutQuart,
      width: length,
      height: 2,
      margin: const EdgeInsetsDirectional.only(
        start: 4,
        end: 4,
        // Pull the line up so it visually aligns with the dot center,
        // not with the dot+label baseline.
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: isFilled ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
