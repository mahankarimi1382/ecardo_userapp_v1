import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

/// Five-step milestone status stepper for Bank Guarantee & LC cases.
class GuaranteeStatusStepper extends StatelessWidget {
  final String currentStatus;

  const GuaranteeStatusStepper({
    super.key,
    required this.currentStatus,
  });

  int _currentStepIndex() {
    switch (currentStatus) {
      case 'DRAFT':
        return 0;
      case 'UNDER_REVIEW':
      case 'COMPLEMENT_REQUIRED':
        return 1;
      case 'MARGIN_PENDING':
        return 2;
      case 'IN_ISSUANCE':
        return 3;
      case 'ISSUED':
      case 'CLAIMED':
        return 4;
      case 'RELEASED':
        return 5;
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeStep = _currentStepIndex();

    final steps = [
      {'title': l10nPick(context, fa: 'ثبت پرونده', en: 'Draft'), 'icon': Icons.edit_note_rounded},
      {'title': l10nPick(context, fa: 'اعتبارسنجی', en: 'Assessment'), 'icon': Icons.fact_check_outlined},
      {'title': l10nPick(context, fa: 'تودیع وثیقه', en: 'Margin Deposit'), 'icon': Icons.lock_clock_outlined},
      {'title': l10nPick(context, fa: 'صدور سپام', en: 'Bank / SEPAM'), 'icon': Icons.account_balance_outlined},
      {'title': l10nPick(context, fa: 'صدور قطعی', en: 'Issued & Active'), 'icon': Icons.verified_rounded},
    ];

    final primaryAccent = isDark ? const Color(0xFF2DD4BF) : const Color(0xFF0D9488);
    final inactiveColor = isDark ? AppColors.darkOutline : AppColors.lightOutlineVariant;

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10nPick(context, fa: 'مراحل صدور ضمانت‌نامه بانکی', en: 'Guarantee Issuance Progress'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${activeStep.clamp(0, steps.length - 1) + 1} / ${steps.length}',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w900,
                    color: primaryAccent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md.h),
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;
                final isPassed = lineIndex < activeStep;
                return Expanded(
                  child: Container(
                    height: 2.5.h,
                    color: isPassed ? primaryAccent : inactiveColor,
                  ),
                );
              }

              final stepIndex = index ~/ 2;
              final isCompleted = stepIndex < activeStep;
              final isCurrent = stepIndex == activeStep;

              Color circleBg;
              Color circleBorder;
              Color iconColor;

              if (isCompleted) {
                circleBg = primaryAccent;
                circleBorder = primaryAccent;
                iconColor = isDark ? AppColors.deepBlack : AppColors.white;
              } else if (isCurrent) {
                circleBg = primaryAccent.withValues(alpha: 0.15);
                circleBorder = primaryAccent;
                iconColor = primaryAccent;
              } else {
                circleBg = isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC);
                circleBorder = inactiveColor;
                iconColor = isDark ? AppColors.darkTextTertiary : const Color(0xFF94A3B8);
              }

              return Container(
                width: 28.w,
                height: 28.w,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: circleBorder, width: isCurrent ? 2 : 1),
                ),
                child: Center(
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : (steps[stepIndex]['icon'] as IconData),
                    size: 14.sp,
                    color: iconColor,
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: AppSpacing.sm.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  steps[activeStep.clamp(0, steps.length - 1)]['title'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: primaryAccent,
                  ),
                ),
              ),
              if (activeStep < steps.length - 1)
                Expanded(
                  child: Text(
                    '${l10nPick(context, fa: 'مرحله بعد: ', en: 'Next: ')}${steps[activeStep + 1]['title']}',
                    maxLines: 1,
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shimmer skeleton loader for Guarantee cases and catalog list.
class GuaranteeSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const GuaranteeSkeletonLoader({
    super.key,
    this.itemCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF2B2B29) : const Color(0xFFE2E8F0);
    final highlightColor = isDark ? const Color(0xFF383835) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.md.h),
        itemBuilder: (_, _) => Container(
          padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 140.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Container(
                          width: 90.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 60.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
