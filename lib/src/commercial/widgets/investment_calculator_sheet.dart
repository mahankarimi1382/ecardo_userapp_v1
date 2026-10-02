import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
    final currency = widget.project.currency;
    final minAmount = widget.project.minInvestment;
    final maxAmount = widget.project.targetAmount * 0.2; // Max 20% per single investor

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 24.h),
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
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Title & Project
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Investment Calculator',
                  fa: 'ماشین‌حساب سرمایه‌گذاری',
                  ar: 'حاسبة الاستثمار',
                  zh: '投资计算器',
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '${widget.project.annualYieldPercent}% Yield',
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
              color: AppColors.lightTextTertiary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20.h),

          // Amount Selector Card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.lightBackground.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.lightBorder),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Investment Amount',
                        fa: 'مبلغ سرمایه‌گذاری',
                        ar: 'مبلغ الاستثمار',
                        zh: '投资金额',
                      ),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '$currency ${_formatNumber(_investAmount)}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.lightPrimary,
                    inactiveTrackColor: AppColors.lightBorder,
                    thumbColor: AppColors.lightPrimary,
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
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Projected Returns Breakdown
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
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
                          en: 'Est. Monthly Dividend',
                          fa: 'سود ماهانه تخمینی',
                          ar: 'العائد الشهري المتوقع',
                          zh: '预估月度分红',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '+$currency ${_formatNumber(_projectedMonthlyReturn)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 32.h, color: AppColors.lightBorder),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Est. Annual Return',
                          fa: 'سود سالانه کل',
                          ar: 'العائد السنوي المتوقع',
                          zh: '预估年度总回报',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.lightTextTertiary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '+$currency ${_formatNumber(_projectedAnnualReturn)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // Confirm Investment Button
          CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              en: 'Confirm & Invest with eCardo Wallet',
              fa: 'تأیید و پرداخت از کیف‌پول ایکاردو',
              ar: 'تأكيد والاستثمار عبر المحفظة',
              zh: '确认并使用电子钱包投资',
            ),
            onPressed: () {
              Navigator.pop(context);
              ToastHelper().showSuccessToast(
                l10nPick(
                  context,
                  en: 'Investment order registered successfully',
                  fa: 'سفارش سرمایه‌گذاری با موفقیت ثبت شد',
                  ar: 'تم تسجيل طلب الاستثمار بنجاح',
                  zh: '投资订单登记成功',
                ),
              );
              widget.onConfirmed?.call(_investAmount);
            },
          ),
        ],
      ),
    );
  }

  String _formatNumber(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
