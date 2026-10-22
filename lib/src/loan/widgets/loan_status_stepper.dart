import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../models/loan_models.dart';

/// Five-stage milestone status stepper for Loan & Credit applications,
/// also supporting 4-stage application flow when currentStep is provided.
///
/// 5-stage milestones (by status):
/// 1. Apply (ثبت درخواست) -> DRAFT
/// 2. Credit Scoring (سنجش اعتبار) -> UNDER_ASSESSMENT, COMPLEMENT_REQUIRED
/// 3. Offer & Collateral (پیشنهاد و وثیقه) -> OFFERED, AWAITING_COLLATERAL
/// 4. Signing (امضای قرارداد) -> AWAITING_SIGNING, REVIEW
/// 5. Disbursed (واریز و اقساط) -> DISBURSED, ACTIVE, COMPLETED, OVERDUE, DEFAULTED
///
/// 4-stage workflow (when currentStep != null):
/// 1. Eligibility (احراز صلاحیت)
/// 2. Application & Collateral (درخواست و وثیقه)
/// 3. Review (بررسی و امضا)
/// 4. Disbursed (واریز به حساب)
class LoanStatusStepper extends StatelessWidget {
  final String? currentStatus;
  final int? currentStep;
  final bool isCompact;

  const LoanStatusStepper({
    super.key,
    this.currentStatus,
    this.currentStep,
    this.isCompact = false,
  });

  /// Map loan status string to 5-step milestone index (0..4)
  int _stepFromStatus() {
    switch (currentStatus) {
      case 'DRAFT':
        return 0; // 1. Apply (ثبت درخواست)
      case 'UNDER_ASSESSMENT':
      case 'COMPLEMENT_REQUIRED':
        return 1; // 2. Credit Scoring (سنجش اعتبار)
      case 'OFFERED':
      case 'AWAITING_COLLATERAL':
        return 2; // 3. Offer & Collateral (پیشنهاد و وثیقه)
      case 'AWAITING_SIGNING':
      case 'REVIEW':
        return 3; // 4. Signing (امضای قرارداد)
      case 'DISBURSED':
      case 'ACTIVE':
      case 'COMPLETED':
      case 'OVERDUE':
      case 'DEFAULTED':
        return 4; // 5. Disbursed (واریز و اقساط)
      default:
        return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFourStep = currentStep != null;

    final List<Map<String, dynamic>> steps;
    final int activeStep;

    if (isFourStep) {
      activeStep = currentStep!.clamp(0, 3);
      steps = [
        {
          'title': l10nPick(
            context,
            fa: 'احراز صلاحیت',
            en: 'Eligibility',
            ar: 'الأهلية',
            zh: '资质审核',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'اعتبارسنجی',
            en: 'Scoring',
            ar: 'التقييم',
            zh: '信用评估',
          ),
          'icon': Icons.verified_user_outlined,
        },
        {
          'title': l10nPick(
            context,
            fa: 'درخواست و وثیقه',
            en: 'Application & Collateral',
            ar: 'الطلب والضمان',
            zh: '申请与质押',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'انتخاب طرح',
            en: 'Terms & Collateral',
            ar: 'تحديد الضمان',
            zh: '确定额度',
          ),
          'icon': Icons.account_balance_wallet_outlined,
        },
        {
          'title': l10nPick(
            context,
            fa: 'بررسی و امضا',
            en: 'Review',
            ar: 'المراجعة والتوقيع',
            zh: '审核与签约',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'امضای قرارداد',
            en: 'Contract sign',
            ar: 'العقد الإلكتروني',
            zh: '电子签署',
          ),
          'icon': Icons.draw_outlined,
        },
        {
          'title': l10nPick(
            context,
            fa: 'واریز به حساب',
            en: 'Disbursed',
            ar: 'الصرف إلى الحساب',
            zh: '放款入账',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'دریافت وجه',
            en: 'Fund released',
            ar: 'تحويل الأموال',
            zh: '资金到账',
          ),
          'icon': Icons.payments_outlined,
        },
      ];
    } else {
      activeStep = _stepFromStatus();
      steps = [
        {
          'title': l10nPick(
            context,
            fa: 'ثبت درخواست',
            en: 'Apply',
            ar: 'تقديم الطلب',
            zh: '提交申请',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'تکمیل فرم',
            en: 'Application form',
            ar: 'تعبئة النموذج',
            zh: '填写资料',
          ),
          'icon': Icons.post_add_rounded,
        },
        {
          'title': l10nPick(
            context,
            fa: 'سنجش اعتبار',
            en: 'Credit Scoring',
            ar: 'التقييم الائتماني',
            zh: '信用评估',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'اعتبارسنجی',
            en: 'Scoring',
            ar: 'التقييم',
            zh: '额度测算',
          ),
          'icon': Icons.fact_check_outlined,
        },
        {
          'title': l10nPick(
            context,
            fa: 'پیشنهاد و وثیقه',
            en: 'Offer & Collateral',
            ar: 'العرض والضمان',
            zh: '方案与质押',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'انتخاب طرح',
            en: 'Terms & Collateral',
            ar: 'تحديد الضمان',
            zh: '确认抵押',
          ),
          'icon': Icons.lock_clock_outlined,
        },
        {
          'title': l10nPick(
            context,
            fa: 'امضای قرارداد',
            en: 'Signing',
            ar: 'توقيع العقد',
            zh: '签署合同',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'امضای الکترونیک',
            en: 'Contract sign',
            ar: 'التوقيع الإلكتروني',
            zh: '电子签约',
          ),
          'icon': Icons.draw_outlined,
        },
        {
          'title': l10nPick(
            context,
            fa: 'واریز و اقساط',
            en: 'Disbursed',
            ar: 'الصرف والأقساط',
            zh: '放款与还款',
          ),
          'subtitle': l10nPick(
            context,
            fa: 'دریافت وجه',
            en: 'Fund released',
            ar: 'تحويل الأموال',
            zh: '到账还款',
          ),
          'icon': Icons.payments_outlined,
        },
      ];
    }

    final primaryAccent = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final inactiveBorder = isDark
        ? AppColors.darkOutline
        : AppColors.lightOutlineVariant;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    final circleSize = (steps.length > 4 || isCompact) ? 28.w : 32.w;
    final iconSize = (steps.length > 4 || isCompact) ? 13.sp : 15.sp;

    return Container(
      padding: EdgeInsetsDirectional.all(
        isCompact ? AppSpacing.sm.r : AppSpacing.md.r,
      ),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'مراحل دریافت تسهیلات',
                    en: 'Loan Application Progress',
                    ar: 'مراحل التسهيل',
                    zh: '贷款办理进度',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: isCompact ? 12.sp : 13.5.sp,
                    color: textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: primaryAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${activeStep.clamp(0, steps.length - 1) + 1} / ${steps.length}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: primaryAccent,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isCompact ? AppSpacing.sm.h : AppSpacing.md.h),

          // Stepper Node Indicators with Connectors
          Row(
            children: List.generate(steps.length * 2 - 1, (index) {
              if (index.isOdd) {
                final lineIndex = index ~/ 2;
                final isPassed = lineIndex < activeStep;
                return Expanded(
                  child: Container(
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: isPassed ? primaryAccent : inactiveBorder,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
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
                iconColor = isDark ? AppColors.deepBlack : Colors.white;
              } else if (isCurrent) {
                circleBg = primaryAccent.withValues(alpha: 0.16);
                circleBorder = primaryAccent;
                iconColor = primaryAccent;
              } else {
                circleBg = isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightBackground;
                circleBorder = inactiveBorder;
                iconColor = textSecondary.withValues(alpha: 0.7);
              }

              return Container(
                width: circleSize,
                height: circleSize,
                decoration: BoxDecoration(
                  color: circleBg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: circleBorder,
                    width: isCurrent ? 2.0 : 1.2,
                  ),
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color: primaryAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    isCompleted
                        ? Icons.check_rounded
                        : (steps[stepIndex]['icon'] as IconData),
                    size: iconSize,
                    color: iconColor,
                  ),
                ),
              );
            }),
          ),

          SizedBox(height: AppSpacing.sm.h),

          // Titles below steps
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(steps.length, (i) {
              final isCurrent = i == activeStep;
              final isCompleted = i < activeStep;

              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 2.w),
                  child: Column(
                    children: [
                      Text(
                        steps[i]['title'] as String,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isCompact ? 9.5.sp : 10.5.sp,
                          fontWeight: (isCurrent || isCompleted)
                              ? FontWeight.w800
                              : FontWeight.w500,
                          color: isCurrent
                              ? primaryAccent
                              : (isCompleted ? textPrimary : textSecondary),
                        ),
                      ),
                      if (!isCompact && isCurrent) ...[
                        SizedBox(height: 2.h),
                        Text(
                          steps[i]['subtitle'] as String,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.5.sp,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

/// Real-time loan status tracking card for active loans.
/// Displays case number, pulsing status badge, 4-step milestone progress,
/// outstanding balance, next payment due date, collateral coverage health,
/// and quick installment payment action.
class LoanStatusTrackingCard extends StatelessWidget {
  final LoanCaseModel loanCase;
  final VoidCallback? onTap;
  final VoidCallback? onPayNextInstallment;
  final VoidCallback? onTopUpCollateral;

  const LoanStatusTrackingCard({
    super.key,
    required this.loanCase,
    this.onTap,
    this.onPayNextInstallment,
    this.onTopUpCollateral,
  });

  String _statusLabel(BuildContext context, String status) {
    switch (status) {
      case 'DRAFT':
        return l10nPick(
          context,
          fa: 'پیش‌نویس پرونده',
          en: 'Draft',
          ar: 'مسودة',
          zh: '草稿',
        );
      case 'UNDER_ASSESSMENT':
        return l10nPick(
          context,
          fa: 'در حال ارزیابی اعتباری',
          en: 'Under Review',
          ar: 'قيد التقييم',
          zh: '审核中',
        );
      case 'OFFERED':
        return l10nPick(
          context,
          fa: 'پیشنهاد صادر شد',
          en: 'Offer Issued',
          ar: 'عرض متاح',
          zh: '方案已出',
        );
      case 'AWAITING_COLLATERAL':
        return l10nPick(
          context,
          fa: 'در انتظار وثیقه‌گذاری',
          en: 'Awaiting Collateral',
          ar: 'بانتظار الضمان',
          zh: '待交抵押',
        );
      case 'AWAITING_SIGNING':
        return l10nPick(
          context,
          fa: 'در انتظار امضا',
          en: 'Awaiting Signing',
          ar: 'بانتظار التوقيع',
          zh: '待签约',
        );
      case 'DISBURSED':
        return l10nPick(
          context,
          fa: 'واریز شده به حساب',
          en: 'Disbursed',
          ar: 'تم الصرف',
          zh: '已放款',
        );
      case 'ACTIVE':
        return l10nPick(
          context,
          fa: 'در حال بازپرداخت',
          en: 'Active Repayment',
          ar: 'سداد جاري',
          zh: '还款中',
        );
      case 'COMPLETED':
        return l10nPick(
          context,
          fa: 'تسویه کامل',
          en: 'Completed',
          ar: 'تم السداد',
          zh: '已结清',
        );
      case 'OVERDUE':
        return l10nPick(
          context,
          fa: 'دارای قسط معوق',
          en: 'Overdue',
          ar: 'متأخر',
          zh: '已逾期',
        );
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'COMPLETED':
        return AppColors.success;
      case 'ACTIVE':
      case 'DISBURSED':
        return AppColors.lightPrimary;
      case 'OFFERED':
      case 'AWAITING_COLLATERAL':
      case 'AWAITING_SIGNING':
      case 'UNDER_ASSESSMENT':
        return AppColors.warning;
      case 'OVERDUE':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _formatAmount(double val) {
    final rounded = val.round();
    return rounded.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final sunkenColor = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightBackground;

    final c = loanCase;
    final isWarning = c.isCollateralWarning;
    final isDanger = c.isCollateralDanger;
    final status = c.status;
    final statusColor = (isWarning || isDanger)
        ? AppColors.error
        : _statusColor(status);
    final statusText = _statusLabel(context, status);

    final nextInst = c.nextInstallment;
    final nextAmount = nextInst?.amount ?? 1140.0;
    final totalInstallments = c.totalInstallmentsCount;
    final paidCount = c.paidInstallmentsCount;
    final progressPct = totalInstallments > 0
        ? (paidCount / totalInstallments)
        : 0.0;

    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: EdgeInsetsDirectional.all(AppSpacing.lg.r),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          border: Border.all(
            color: (isWarning || isDanger)
                ? AppColors.error.withValues(alpha: 0.6)
                : borderColor,
            width: (isWarning || isDanger) ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Bar: Case ID & Pulsing Live Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  flex: 3,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 7.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          color: sunkenColor,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm.r,
                          ),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          c.caseNo.isNotEmpty ? c.caseNo : 'LN-2208',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'monospace',
                            color: textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Flexible(
                        child: Text(
                          c.product?.localizedName(context) ??
                              l10nPick(
                                context,
                                fa: 'وام با پشتوانه رمزارز',
                                en: 'Crypto-backed loan',
                                ar: 'قرض مدعوم بالعملات المشفرة',
                                zh: '加密资产抵押贷款',
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 6.w),
                Flexible(
                  flex: 2,
                  child: Container(
                    padding: EdgeInsetsDirectional.symmetric(
                      horizontal: 7.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusFull,
                      ),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          child: Text(
                            statusText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.md.h),

            // Embedded 4-Step Progress Stepper
            LoanStatusStepper(currentStatus: c.status, isCompact: true),

            SizedBox(height: AppSpacing.md.h),

            // Financial Metrics: Outstanding Balance & Next Due Installment
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          fa: 'مانده بدهی اصل تسهیلات',
                          en: 'Outstanding Balance',
                          ar: 'المبلغ المتبقي',
                          zh: '未还本金',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: textSecondary),
                      ),
                      SizedBox(height: 2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: AlignmentDirectional.centerStart,
                        child: Text(
                          '${_formatAmount(c.outstandingAmount)} USD',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: textPrimary,
                            letterSpacing: -0.5,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        fa: 'مبلغ قسط بعدی',
                        en: 'Next Payment',
                        ar: 'القسط التالي',
                        zh: '下期供款',
                      ),
                      style: TextStyle(fontSize: 11.sp, color: textSecondary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${_formatAmount(nextAmount)} USD',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: primaryAccent,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: AppSpacing.sm.h),

            // Repayment Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${l10nPick(context, fa: 'پیشرفت بازپرداخت اقساط', en: 'Repayment Progress', ar: 'تقدم السداد', zh: '还款进度')}: $paidCount / $totalInstallments',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w700,
                          color: textSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${(progressPct * 100).toInt()}٪',
                      style: TextStyle(
                        fontSize: 10.5.sp,
                        fontWeight: FontWeight.w800,
                        color: primaryAccent,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: progressPct,
                    backgroundColor: sunkenColor,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      paidCount == totalInstallments
                          ? AppColors.success
                          : primaryAccent,
                    ),
                    minHeight: 5.h,
                  ),
                ),
              ],
            ),

            // Collateral Coverage Health Row
            if (c.lockedCollateralUsdt > 0) ...[
              SizedBox(height: AppSpacing.sm.h),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 10.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  color: (isWarning || isDanger)
                      ? AppColors.errorContainer
                      : AppColors.successContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      (isWarning || isDanger)
                          ? Icons.warning_amber_rounded
                          : Icons.shield_outlined,
                      size: 15.sp,
                      color: (isWarning || isDanger)
                          ? AppColors.error
                          : AppColors.success,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        '${l10nPick(context, fa: 'نسبت پوشش وثیقه تتر', en: 'Collateral coverage', ar: 'نسبة التغطية', zh: '质押率')}: ${c.coverageNowPct.toStringAsFixed(0)}٪ · ${c.lockedCollateralUsdt.toInt()} USDT',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          color: (isWarning || isDanger)
                              ? AppColors.error
                              : AppColors.success,
                        ),
                      ),
                    ),
                    if (isWarning || isDanger)
                      InkWell(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          onTopUpCollateral?.call();
                        },
                        child: Container(
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            l10nPick(
                              context,
                              fa: 'شارژ وثیقه',
                              en: 'Top Up',
                              ar: 'تعزيز',
                              zh: '补仓',
                            ),
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],

            SizedBox(height: AppSpacing.md.h),

            // Action Buttons: Pay Next Installment & Details
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryAccent,
                      foregroundColor: isDark
                          ? AppColors.deepBlack
                          : Colors.white,
                      elevation: 0,
                      minimumSize: Size(0, 40.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd.r,
                        ),
                      ),
                    ),
                    icon: Icon(Icons.payment_rounded, size: 15.sp),
                    label: Text(
                      l10nPick(
                        context,
                        fa: 'پرداخت قسط بعدی',
                        en: 'Pay Next Installment',
                        ar: 'سداد القسط القادم',
                        zh: '支付本期账单',
                      ),
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      onPayNextInstallment?.call();
                    },
                  ),
                ),
                SizedBox(width: AppSpacing.sm.w),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(color: borderColor),
                    minimumSize: Size(0, 40.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd.r,
                      ),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onTap?.call();
                  },
                  child: Text(
                    l10nPick(
                      context,
                      fa: 'جزئیات',
                      en: 'Details',
                      ar: 'التفاصيل',
                      zh: '详情',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer skeleton loader for Loan cases and products list.
class LoanSkeletonLoader extends StatelessWidget {
  final int itemCount;

  const LoanSkeletonLoader({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? const Color(0xFF2B2B29)
        : const Color(0xFFE2E8F0);
    final highlightColor = isDark
        ? const Color(0xFF383835)
        : const Color(0xFFF1F5F9);

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
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusMd.r,
                      ),
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
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Container(
                          width: 90.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: baseColor,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: baseColor,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm.r,
                      ),
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
