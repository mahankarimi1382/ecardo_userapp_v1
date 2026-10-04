import 'package:flutter/material.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

import '../../../../app/constants/app_colors.dart';
import '../../../../app/constants/app_spacing.dart';
import 'exchange_design_tokens.dart';

/// Modern three-step progress indicator with labels.
///
/// Features:
/// - Active dot with glow halo in brand color (theme adaptive)
/// - Completed dots with animated filled state
/// - Animated connecting lines
/// - Full dark mode and RTL support
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

    final isDark = ExchangeDesignTokens.isDark(context);
    final active = activeColor ??
        (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary);
    final inactive = inactiveColor ??
        (isDark
            ? AppColors.darkDivider
            : AppColors.lightTextPrimary.withValues(alpha: 0.16));

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.md,
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
    final effectiveSize = isCurrent ? size * 1.35 : size;
    final isDark = ExchangeDesignTokens.isDark(context);

    final labelColor = isActive
        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
        : (isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Dot + halo
        AnimatedContainer(
          duration: AppSpacing.normal,
          curve: Curves.easeOutQuart,
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            color: isActive ? activeColor : inactiveColor,
            shape: BoxShape.circle,
            boxShadow: isCurrent
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 2),
        // Label
        AnimatedDefaultTextStyle(
          duration: AppSpacing.fast,
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
      duration: AppSpacing.normal,
      curve: Curves.easeOutQuart,
      width: length,
      height: 2.5,
      margin: const EdgeInsetsDirectional.only(
        start: 4,
        end: 4,
        bottom: 18,
      ),
      decoration: BoxDecoration(
        color: isFilled ? activeColor : inactiveColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXs),
      ),
    );
  }
}
