import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';

/// Modern FinTech multi-step indicator with glowing active dots,
/// animated progress bars, and full dark/light theme support.
class TransferStepIndicator extends StatelessWidget {
  final int currentStep;
  final List<String> steps;
  final ValueChanged<int>? onStepTapped;

  const TransferStepIndicator({
    super.key,
    required this.currentStep,
    this.steps = const ['Amount', 'Review', 'Success'],
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.surfaceContainerLow.withValues(alpha: 0.5)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: isDark ? 0.25 : 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow)
                .withValues(alpha: isDark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < steps.length; i++) ...[
            Expanded(
              child: _StepNode(
                index: i,
                label: steps[i],
                isActive: i == currentStep,
                isCompleted: i < currentStep || (currentStep == steps.length - 1 && i == currentStep),
                isDark: isDark,
                colorScheme: colorScheme,
                onTap: (onStepTapped != null && i < currentStep)
                    ? () => onStepTapped!(i)
                    : null,
              ),
            ),
            if (i < steps.length - 1)
              _StepProgressConnector(
                isFilled: i < currentStep,
                colorScheme: colorScheme,
              ),
          ],
        ],
      ),
    );
  }
}

class _StepNode extends StatelessWidget {
  final int index;
  final String label;
  final bool isActive;
  final bool isCompleted;
  final bool isDark;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _StepNode({
    required this.index,
    required this.label,
    required this.isActive,
    required this.isCompleted,
    required this.isDark,
    required this.colorScheme,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = colorScheme.primary;

    Color badgeBg;
    Color badgeBorder;
    Color contentColor;
    List<BoxShadow> shadows = [];

    if (isCompleted && !isActive) {
      badgeBg = AppColors.success;
      badgeBorder = AppColors.success;
      contentColor = Colors.white;
      shadows = [
        BoxShadow(
          color: AppColors.success.withValues(alpha: 0.3),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else if (isActive) {
      badgeBg = activeColor;
      badgeBorder = activeColor;
      contentColor = colorScheme.onPrimary;
      shadows = [
        BoxShadow(
          color: activeColor.withValues(alpha: 0.45),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ];
    } else {
      badgeBg = isDark
          ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.4)
          : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
      badgeBorder = colorScheme.outlineVariant.withValues(alpha: 0.5);
      contentColor = colorScheme.onSurface.withValues(alpha: 0.4);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: AppDurations.normal,
            curve: Curves.easeOutCubic,
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: badgeBg,
              border: Border.all(color: badgeBorder, width: 1.5),
              boxShadow: shadows,
            ),
            child: Center(
              child: isCompleted && !isActive
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: contentColor,
                        letterSpacing: 0,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedDefaultTextStyle(
            duration: AppDurations.normal,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: isActive
                  ? FontWeight.w700
                  : isCompleted
                      ? FontWeight.w600
                      : FontWeight.w500,
              color: isActive
                  ? colorScheme.onSurface
                  : isCompleted
                      ? colorScheme.onSurface.withValues(alpha: 0.8)
                      : colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 0.1,
            ),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepProgressConnector extends StatelessWidget {
  final bool isFilled;
  final ColorScheme colorScheme;

  const _StepProgressConnector({
    required this.isFilled,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      margin: const EdgeInsets.only(bottom: 18),
      height: 3,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          AnimatedFractionallySizedBox(
            duration: AppDurations.normal,
            curve: Curves.easeInOutCubic,
            widthFactor: isFilled ? 1.0 : 0.0,
            alignment: AlignmentDirectional.centerStart,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success,
                    colorScheme.primary,
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                boxShadow: isFilled
                    ? [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.3),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
