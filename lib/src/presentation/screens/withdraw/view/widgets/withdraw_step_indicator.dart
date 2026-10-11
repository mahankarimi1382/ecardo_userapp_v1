import 'package:flutter/material.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Modern FinTech step indicator for the withdrawal flow with glowing active dots,
/// animated progress bars, localized labels, and dark/light theme support.
class WithdrawStepIndicator extends StatelessWidget {
  final int currentStep;
  final ValueChanged<int>? onStepTapped;

  const WithdrawStepIndicator({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final steps = [
      l10nPick(context, en: 'Amount', fa: 'مبلغ', ar: 'المبلغ', tr: 'Miktar', ru: 'Сумма'),
      l10nPick(context, en: 'Review', fa: 'بررسی', ar: 'مراجعة', tr: 'İnceleme', ru: 'Проверка'),
      l10nPick(context, en: 'Success', fa: 'رسید', ar: 'الإيصال', tr: 'Makbuz', ru: 'Квитанция'),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.page,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
            : AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.lightShadow)
                .withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
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
                isCompleted: i < currentStep ||
                    (currentStep == steps.length - 1 && i == currentStep),
                isDark: isDark,
                colorScheme: colorScheme,
                onTap: (onStepTapped != null && i < currentStep)
                    ? () => onStepTapped!(i)
                    : null,
              ),
            ),
            if (i < steps.length - 1)
              _StepConnector(
                isFilled: i < currentStep,
                isDark: isDark,
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
    final activeColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
    final completedColor = AppColors.success;
    final inactiveColor = isDark
        ? AppColors.darkTextSecondary.withValues(alpha: 0.35)
        : AppColors.lightTextTertiary.withValues(alpha: 0.35);

    Color nodeColor;
    if (isCompleted && !isActive) {
      nodeColor = completedColor;
    } else if (isActive) {
      nodeColor = activeColor;
    } else {
      nodeColor = inactiveColor;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            width: isActive ? 28 : 22,
            height: isActive ? 28 : 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? nodeColor
                  : (isCompleted
                      ? nodeColor.withValues(alpha: 0.15)
                      : Colors.transparent),
              border: Border.all(
                color: nodeColor,
                width: isActive ? 2.5 : 1.5,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: nodeColor.withValues(alpha: 0.45),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: isCompleted && !isActive
                  ? Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: completedColor,
                    )
                  : Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: isActive ? 12 : 10,
                        fontWeight: FontWeight.w800,
                        color: isActive
                            ? (isDark ? AppColors.deepBlack : AppColors.white)
                            : nodeColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isActive
                  ? FontWeight.w800
                  : (isCompleted ? FontWeight.w600 : FontWeight.w500),
              color: isActive
                  ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                  : (isCompleted
                      ? (isDark
                          ? AppColors.darkTextPrimary.withValues(alpha: 0.8)
                          : AppColors.lightTextPrimary.withValues(alpha: 0.8))
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextTertiary)),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _StepConnector extends StatelessWidget {
  final bool isFilled;
  final bool isDark;

  const _StepConnector({
    required this.isFilled,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1),
          color: isFilled
              ? AppColors.success
              : (isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder),
        ),
      ),
    );
  }
}
