import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

import 'equity_project_card.dart';

class InvestmentCalculatorSheet extends StatefulWidget {
  final EquityProjectItem project;
  final Function(double investedAmount)? onConfirmed;

  const InvestmentCalculatorSheet({
    super.key,
    required this.project,
    this.onConfirmed,
  });

  static Future<void> show(
    BuildContext context, {
    required EquityProjectItem project,
    Function(double investedAmount)? onConfirmed,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => InvestmentCalculatorSheet(
        project: project,
        onConfirmed: onConfirmed,
      ),
    );
  }

  @override
  State<InvestmentCalculatorSheet> createState() =>
      _InvestmentCalculatorSheetState();
}

class _InvestmentCalculatorSheetState extends State<InvestmentCalculatorSheet> {
  late double _investAmount;

  @override
  void initState() {
    super.initState();
    _investAmount = widget.project.minInvestment * 2;
  }

  double get _projectedAnnualReturn =>
      _investAmount * (widget.project.annualYieldPercent / 100);

  double get _projectedMonthlyReturn => _projectedAnnualReturn / 12;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currency = widget.project.currency;
    final minAmount = widget.project.minInvestment;
    // Illustrative slider ceiling. Not a regulatory per-investor cap — there is
    // no funding round behind this project, so it must not read as a rule.
    final maxAmount = widget.project.targetAmount * 0.2;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl.r)),
      ),
      padding: EdgeInsets.fromLTRB(AppSpacing.xl.w, AppSpacing.lg.h, AppSpacing.xl.w, MediaQuery.of(context).viewInsets.bottom + AppSpacing.xxl.h),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkDivider : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),

              // Title & Project
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        en: 'Investment Calculator',
                        fa: 'ماشین‌حساب سرمایه‌گذاری',
                        ar: 'حاسبة الاستثمار',
                        zh: '投资计算器',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      // Equity crowdfunding is not live: this is a sample
                      // figure, never a quoted or expected return.
                      '${l10nPick(context, en: 'Illustrative — ', fa: 'نمونه — ', ar: 'توضيحي — ', zh: '示例 — ')}${widget.project.annualYieldPercent}% Yield',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                widget.project.title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: AppSpacing.xl.h),

              // Amount Selector Card
              Container(
                padding: EdgeInsets.all(AppSpacing.lg.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightBackground.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            l10nPick(
                              context,
                              en: 'Sample amount',
                              fa: 'مبلغ نمونه',
                              ar: 'مبلغ نموذجي',
                              zh: '示例金额',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpacing.sm.w),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerEnd,
                            child: Text(
                              '$currency ${_formatNumber(_investAmount)}',
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.sm.h),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        inactiveTrackColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        thumbColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        trackHeight: 4.h,
                      ),
                      child: Slider(
                        value: _investAmount.clamp(minAmount, maxAmount),
                        min: minAmount,
                        max: maxAmount,
                        divisions: 40,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _investAmount = val;
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${l10nPick(context, en: 'Min', fa: 'حداقل', ar: 'الحد الأدنى', zh: '最小')}: $currency ${_formatNumber(minAmount)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                          Text(
                            '${l10nPick(context, en: 'Max', fa: 'حداکثر', ar: 'الحد الأقصى', zh: '最大')}: $currency ${_formatNumber(maxAmount)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),

              // Projected Returns Breakdown
              Container(
                padding: EdgeInsets.all(AppSpacing.lg.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radius.r),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Sample monthly dividend',
                              fa: 'سود ماهانه تخمینی (نمونه)',
                              ar: 'العائد الشهري المتوقع (نموذجي)',
                              zh: '示例月度分红',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              '+$currency ${_formatNumber(_projectedMonthlyReturn)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32.h,
                      color: isDark ? AppColors.darkDivider : AppColors.lightBorder,
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Sample annual return',
                              fa: 'سود سالانه کل (نمونه)',
                              ar: 'العائد السنوي المتوقع (نموذجي)',
                              zh: '示例年度总回报',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              '+$currency ${_formatNumber(_projectedAnnualReturn)}',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),

              // Pre-registration notice — equity crowdfunding is not live, so
              // this sheet may not read as an order screen.
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18.sp, color: AppColors.warning),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Coming soon — the figures below are an illustrative example only. No investment can be placed now; the button records your interest.',
                          fa: 'به‌زودی — اعداد زیر صرفاً یک نمونه است. در حال حاضر امکان سرمایه‌گذاری وجود ندارد و دکمهٔ زیر فقط تمایل شما را ثبت می‌کند.',
                          ar: 'قريباً — الأرقام أدناه نموذج توضيحي فقط. لا يمكن الاستثمار الآن؛ يسجّل الزر اهتمامك فقط.',
                          zh: '即将上线 — 以下数字仅为示例。目前无法投资，按钮仅记录您的意向。',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          height: 1.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.lg.h),

              // Interest Button
              CommonButton(
                width: double.infinity,
                backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                textColor: isDark ? AppColors.deepBlack : AppColors.white,
                text: l10nPick(
                  context,
                  en: 'Register My Interest',
                  fa: 'ثبت تمایل',
                  ar: 'تسجيل اهتمامي',
                  zh: '登记我的意向',
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  // Truthful message: this records interest in this device's
                  // session only. It is NOT an investment and NOT submitted
                  // to any server — there is no crowdfunding API to submit to.
                  ToastHelper().showSuccessToast(
                    l10nPick(
                      context,
                      en: 'Interest recorded on this device only — no investment was made',
                      fa: 'تمایل شما فقط روی همین دستگاه ثبت شد — هیچ سرمایه‌گذاری انجام نشد',
                      ar: 'تم تسجيل اهتمامك على هذا الجهاز فقط — لم يتم إجراء أي استثمار',
                      zh: '意向仅记录在本机 — 未进行任何投资',
                    ),
                  );
                  widget.onConfirmed?.call(_investAmount);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double amount) {
    if (amount >= 1000000000) {
      final b = amount / 1000000000;
      return '${b % 1 == 0 ? b.toInt() : b.toStringAsFixed(1)}B';
    }
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}