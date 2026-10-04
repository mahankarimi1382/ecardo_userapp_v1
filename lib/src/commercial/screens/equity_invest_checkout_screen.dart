import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/commercial_controller.dart';
import '../widgets/equity_project_card.dart';

class EquityInvestCheckoutScreen extends StatefulWidget {
  final EquityProjectItem project;

  const EquityInvestCheckoutScreen({
    super.key,
    required this.project,
  });

  @override
  State<EquityInvestCheckoutScreen> createState() =>
      _EquityInvestCheckoutScreenState();
}

class _EquityInvestCheckoutScreenState
    extends State<EquityInvestCheckoutScreen> {
  late final CommercialController controller;
  late final TextEditingController _amountController;

  double _amount = 0.0;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<CommercialController>()
        ? Get.find<CommercialController>()
        : Get.put(CommercialController());

    _amount = widget.project.minInvestment;
    _amountController =
        TextEditingController(text: _amount.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final parsed = double.tryParse(val) ?? 0.0;
    setState(() {
      _amount = parsed;
    });
  }

  void _setPreset(double multiplier) {
    HapticFeedback.selectionClick();
    final newAmount = widget.project.minInvestment * multiplier;
    setState(() {
      _amount = newAmount;
      _amountController.text = newAmount.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final estimatedAnnualDividend =
        (_amount * widget.project.annualYieldPercent) / 100.0;
    final estimatedShares = (_amount / 50.0).clamp(1.0, 100000.0).round();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor:
            isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(
            context,
            fa: 'بررسی نهایی سرمایه‌گذاری',
            en: 'Investment Checkout',
            ar: 'تأكيد الاستثمار',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(AppSpacing.lg.r),
                children: [
                  // Project Summary Card
                  _buildProjectSummary(context, isDark),
                  SizedBox(height: AppSpacing.lg.h),

                  // Investment Amount Input
                  _buildAmountInputSection(context, isDark, primaryAccent),
                  SizedBox(height: AppSpacing.lg.h),

                  // Return & Shares Breakdown
                  _buildYieldBreakdownCard(
                    context,
                    isDark,
                    primaryAccent,
                    estimatedAnnualDividend,
                    estimatedShares,
                  ),
                  SizedBox(height: AppSpacing.lg.h),

                  // Source of Funds & Wallet Guard
                  _buildWalletPaymentMethod(context, isDark, primaryAccent),
                  SizedBox(height: AppSpacing.lg.h),

                  // Legal Agreement Checkbox
                  _buildTermsAgreement(context, isDark, primaryAccent),
                ],
              ),
            ),
            // Bottom Submit Button
            _buildBottomBar(context, isDark, primaryAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectSummary(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
            ),
            child: Icon(
              Icons.corporate_fare_rounded,
              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              size: 24.sp,
            ),
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.project.title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  '${widget.project.sector} • بازده ${widget.project.annualYieldPercent}%',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInputSection(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(
              context,
              fa: 'مبلغ مورد نظر برای سرمایه‌گذاری',
              en: 'Investment Amount',
            ),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onAmountChanged,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              suffixText: widget.project.currency,
              suffixStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: primaryAccent,
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md.w,
                vertical: 12.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                borderSide: BorderSide(color: primaryAccent, width: 2),
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          // Quick presets
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildPresetChip('پایه (حداقل)', 1.0, isDark, primaryAccent),
              _buildPresetChip('۲ برابر', 2.0, isDark, primaryAccent),
              _buildPresetChip('۵ برابر', 5.0, isDark, primaryAccent),
              _buildPresetChip('۱۰ برابر', 10.0, isDark, primaryAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip(
    String label,
    double multiplier,
    bool isDark,
    Color primaryAccent,
  ) {
    final target = widget.project.minInvestment * multiplier;
    final isSelected = (_amount - target).abs() < 1.0;

    return InkWell(
      onTap: () => _setPreset(multiplier),
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryAccent
              : (isDark
                  ? AppColors.darkSurface
                  : AppColors.lightSurface),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
          border: Border.all(
            color: isSelected
                ? primaryAccent
                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? AppColors.white
                : (isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildYieldBreakdownCard(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
    double annualDividend,
    int shares,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, fa: 'محاسبه عایدی و مالکیت سهم', en: 'Projected Returns'),
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          _buildRowDetail(
            'تعداد سهام تخصیص‌یافته:',
            '$shares سهم دیجیتال',
            isDark,
          ),
          SizedBox(height: 6.h),
          _buildRowDetail(
            'سود سهام پیش‌بینی سالانه:',
            '${annualDividend.toStringAsFixed(0)} ${widget.project.currency} (${widget.project.annualYieldPercent}%)',
            isDark,
            highlightValue: true,
          ),
          SizedBox(height: 6.h),
          _buildRowDetail(
            'دوره واریز سود:',
            'سه‌ماهه (Quarterly Distribution)',
            isDark,
          ),
          SizedBox(height: 6.h),
          _buildRowDetail(
            'مدت زمان قرارداد طرح:',
            '۲۴ ماهه با قابلیت بازخرید',
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildRowDetail(
    String label,
    String value,
    bool isDark, {
    bool highlightValue = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: highlightValue
                ? AppColors.success
                : (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildWalletPaymentMethod(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_rounded,
            color: primaryAccent,
            size: 26.sp,
          ),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'کیف پول اختصاصی اکاردو (تجاری)',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'کسر مستقیم از مانده نقدی • تسویه آنی',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAgreement(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _agreedToTerms,
          activeColor: primaryAccent,
          onChanged: (val) {
            setState(() {
              _agreedToTerms = val ?? false;
            });
          },
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              'طرح توجیهی، بیانیه ریسک سرمایه‌گذاری و شرایط عمومی مشارکت را مطالعه کرده و می‌پذیرم.',
              style: TextStyle(
                fontSize: 11.sp,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
  ) {
    final isValid =
        _amount >= widget.project.minInvestment && _agreedToTerms;

    return Container(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Obx(() {
        final isSubmitting = controller.isSubmittingInvestment.value;

        return SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isValid ? primaryAccent : AppColors.greyLight,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
              ),
            ),
            onPressed: (!isValid || isSubmitting)
                ? null
                : () async {
                    HapticFeedback.heavyImpact();
                    final success = await controller.executeInvestment(
                      projectId: widget.project.id,
                      amount: _amount,
                      currency: widget.project.currency,
                    );
                    if (mounted && success) {
                      _showSuccessDialog(isDark);
                    }
                  },
            child: isSubmitting
                ? SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                      color: AppColors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'تأیید و پرداخت ${_amount.toStringAsFixed(0)} ${widget.project.currency}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.white,
                    ),
                  ),
          ),
        );
      }),
    );
  }

  void _showSuccessDialog(bool isDark) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
        ),
        title: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.verified_rounded,
                color: AppColors.success,
                size: 40.sp,
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              'سرمایه‌گذاری موفق',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'سرمایه‌گذاری شما در طرح "${widget.project.title}" ثبت و گواهی الکترونیک سهام در پورتفوی شما ذخیره شد.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.sp,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
              ),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close dialog
                Get.back(); // Back to project detail
              },
              child: const Text('مشاهده در پورتفوی من'),
            ),
          ),
        ],
      ),
    );
  }
}
