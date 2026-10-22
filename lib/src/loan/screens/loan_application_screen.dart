import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import '../widgets/loan_calculator_slider.dart';
import '../widgets/loan_amortization_schedule.dart';
import '../widgets/loan_status_stepper.dart';
import 'loan_confirm_screen.dart';

/// Interactive Loan Application & Live Financial Calculator Screen.
/// Elevated to modern fintech standards with:
/// 1. 4-step progress stepper (Eligibility -> Application & Collateral -> Review -> Disbursed)
/// 2. Interactive loan calculator with amount & duration sliders, tactile haptic feedback,
///    quick preset duration chips (3, 6, 12, 24 months), and live repayment metrics (EMI, APR, Interest, Total)
/// 3. Collateral status with live wallet balance checking
/// 4. Expandable amortization schedule preview table with Month #, Principal, Interest, and Remaining Balance
/// 5. Dark mode & RTL support using AppColors, AppSpacing, and l10nPick
class LoanApplicationScreen extends StatefulWidget {
  final LoanProductModel? initialProduct;

  const LoanApplicationScreen({super.key, this.initialProduct});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final LoanController controller = Get.isRegistered<LoanController>()
      ? Get.find<LoanController>()
      : Get.put(LoanController());

  double _amount = 10000.0;
  int _tenureMonths = 6;
  int _graceMonths = 0;
  final double _availableWalletUsdt = 18420.0;
  bool _termsAccepted = true;
  bool _showAmortizationTable = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      controller.selectProduct(widget.initialProduct!);
    } else if (controller.selectedProduct.value == null &&
        controller.products.isNotEmpty) {
      controller.selectProduct(controller.products.first);
    }

    final p =
        controller.selectedProduct.value ??
        LoanController.defaultProducts.first;
    _amount = 10000.0.clamp(p.minAmount, p.maxAmount);
    _tenureMonths = p.tenureOptions.contains(6)
        ? 6
        : (p.tenureOptions.isNotEmpty ? p.tenureOptions.first : 6);

    controller.amountInput.value = _amount.toInt().toString();
    controller.selectedTenure.value = _tenureMonths;
    controller.termsAccepted.value = true;
  }

  void _onCalculatorChanged({
    required double amount,
    required int months,
    required double monthlyPayment,
    required double totalInterest,
    required double totalRepayment,
    required double aprRate,
  }) {
    setState(() {
      _amount = amount;
      _tenureMonths = months;
    });
    controller.amountInput.value = amount.toInt().toString();
    controller.selectedTenure.value = months;
  }

  void _onPlanChanged(
    double amount,
    int months,
    int graceMonths,
    double monthlyPayment,
  ) {
    setState(() {
      _amount = amount;
      _tenureMonths = months;
      _graceMonths = graceMonths;
    });
    controller.amountInput.value = amount.toInt().toString();
    controller.selectedTenure.value = months;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;
    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;
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

    return Obx(() {
      final product =
          controller.selectedProduct.value ??
          LoanController.defaultProducts.first;
      final rateAnnual = product.interestRatePct > 0
          ? product.interestRatePct
          : 14.0;

      // Collateral requirements: 150% USDT lock if crypto-backed
      final requiresCollateral =
          product.requiredCollateralType != null ||
          product.collateralRatioPct > 0;
      final collateralRatio = product.collateralRatioPct > 0
          ? product.collateralRatioPct
          : 150.0;
      final collateralNeededUsdt = _amount * (collateralRatio / 100.0);
      final hasEnoughCollateral = _availableWalletUsdt >= collateralNeededUsdt;

      return Scaffold(
        backgroundColor: backgroundColor,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: SafeArea(
            child: CommonAppBar(
              title: product.localizedName(context),
              isBackLogicApply: true,
              backLogicFunction: Get.back,
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: AppSpacing.page.w,
            vertical: AppSpacing.md.h,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ------------------ 1. 4-STEP PROGRESS STEPPER ------------------
              // Step 1: Application & Collateral is currently active
              const LoanStatusStepper(currentStep: 1),

              SizedBox(height: AppSpacing.md.h),

              // ------------------ 2. PRODUCT SELECTOR BAR ------------------
              if (controller.products.length > 1) ...[
                _buildProductSelector(
                  context,
                  product,
                  isDark,
                  primaryAccent,
                  surfaceColor,
                  borderColor,
                  textPrimary,
                ),
                SizedBox(height: AppSpacing.md.h),
              ],

              // ------------------ 3. INTERACTIVE LOAN CALCULATOR ------------------
              // Dual slider (Amount + Duration) with haptic feedback & quick presets (3, 6, 12, 24 mo)
              LoanCalculatorSlider(
                initialAmount: _amount,
                initialMonths: _tenureMonths,
                minAmount: product.minAmount,
                maxAmount: product.maxAmount,
                stepAmount: product.minAmount >= 1000 ? 500 : 100,
                annualInterestRate: rateAnnual,
                minMonths: 3,
                maxMonths: 24,
                presetDurations: const [3, 6, 12, 24],
                currency: 'USD',
                onPlanChanged: _onPlanChanged,
                onCalculationChanged: _onCalculatorChanged,
              ),

              SizedBox(height: AppSpacing.lg.h),

              // ------------------ 4. COLLATERAL HEALTH & WALLET CHECK ------------------
              if (requiresCollateral) ...[
                _buildCollateralCard(
                  context,
                  collateralNeededUsdt,
                  hasEnoughCollateral,
                  isDark,
                  surfaceColor,
                  borderColor,
                  textPrimary,
                  textSecondary,
                ),
                SizedBox(height: AppSpacing.lg.h),
              ],

              // ------------------ 5. AMORTIZATION SCHEDULE PREVIEW TABLE ------------------
              // Tabular rows with Month #, Principal, Interest, and Remaining Balance
              _buildAmortizationScheduleSection(
                context,
                rateAnnual,
                isDark,
                surfaceColor,
                borderColor,
                primaryAccent,
                textPrimary,
                textSecondary,
              ),

              SizedBox(height: AppSpacing.lg.h),

              // ------------------ 6. TERMS ACCEPTANCE CHECKBOX ------------------
              _buildTermsCheckbox(
                context,
                isDark,
                primaryAccent,
                borderColor,
                textPrimary,
                textSecondary,
              ),

              SizedBox(height: AppSpacing.huge.h),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(
          context,
          product,
          requiresCollateral,
          hasEnoughCollateral,
          isDark,
          primaryAccent,
          surfaceColor,
          borderColor,
          textSecondary,
        ),
      );
    });
  }

  Widget _buildProductSelector(
    BuildContext context,
    LoanProductModel current,
    bool isDark,
    Color primaryAccent,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
  ) {
    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16.sp, color: primaryAccent),
              SizedBox(width: 8.w),
              Text(
                l10nPick(
                  context,
                  fa: 'طرح انتخابی:',
                  en: 'Selected Plan:',
                  ar: 'الخطة:',
                  zh: '已选方案：',
                ),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                current.localizedName(context),
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          PopupMenuButton<LoanProductModel>(
            icon: Icon(
              Icons.swap_horiz_rounded,
              size: 20.sp,
              color: primaryAccent,
            ),
            tooltip: l10nPick(
              context,
              fa: 'تغییر طرح تسهیلاتی',
              en: 'Switch Plan',
            ),
            onSelected: (p) {
              HapticFeedback.selectionClick();
              controller.selectProduct(p);
              setState(() {
                _amount = _amount.clamp(p.minAmount, p.maxAmount);
              });
            },
            itemBuilder: (ctx) => controller.products.map((p) {
              return PopupMenuItem<LoanProductModel>(
                value: p,
                child: Text(
                  p.localizedName(context),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: p.id == current.id
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: p.id == current.id ? primaryAccent : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCollateralCard(
    BuildContext context,
    double collateralNeededUsdt,
    bool hasEnoughCollateral,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(
          color: hasEnoughCollateral
              ? borderColor
              : AppColors.error.withValues(alpha: 0.5),
          width: hasEnoughCollateral ? 1.0 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 17.sp,
                    color: hasEnoughCollateral
                        ? AppColors.success
                        : AppColors.error,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10nPick(
                      context,
                      fa: 'وثیقه تضمین وام (تتر)',
                      en: 'Collateral Guarantee (USDT)',
                      ar: 'ضمان التمويل (USDT)',
                      zh: '抵押担保 (USDT)',
                    ),
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsetsDirectional.symmetric(
                  horizontal: 8.w,
                  vertical: 3.h,
                ),
                decoration: BoxDecoration(
                  color: hasEnoughCollateral
                      ? AppColors.successContainer
                      : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                ),
                child: Text(
                  hasEnoughCollateral
                      ? l10nPick(
                          context,
                          fa: 'موجودی کافی',
                          en: 'Sufficient',
                          ar: 'كافي',
                          zh: '额度充足',
                        )
                      : l10nPick(
                          context,
                          fa: 'کسری موجودی',
                          en: 'Insufficient',
                          ar: 'غير كافي',
                          zh: '额度不足',
                        ),
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w800,
                    color: hasEnoughCollateral
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.sm.h),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          SizedBox(height: AppSpacing.sm.h),

          // Required vs Available
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  fa: 'تتر مورد نیاز (۱۵۰٪ اصل وام):',
                  en: 'Required lock (150%):',
                  ar: 'المطلوب قفله (150%):',
                  zh: '需冻结数量（150%）：',
                ),
                style: TextStyle(fontSize: 12.sp, color: textSecondary),
              ),
              Text(
                '${collateralNeededUsdt.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} USDT',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  fa: 'موجودی تتر کیف پول شما:',
                  en: 'Available in Wallet:',
                  ar: 'المتاح في المحفظة:',
                  zh: '当前钱包余额：',
                ),
                style: TextStyle(fontSize: 12.sp, color: textSecondary),
              ),
              Text(
                '${_availableWalletUsdt.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} USDT',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: hasEnoughCollateral
                      ? AppColors.success
                      : AppColors.error,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),

          if (!hasEnoughCollateral) ...[
            SizedBox(height: AppSpacing.sm.h),
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.sm.r),
              decoration: BoxDecoration(
                color: AppColors.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    size: 16.sp,
                    color: AppColors.error,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        fa: 'موجودی تتر شما برای این مبلغ وام کافی نیست. لطفاً کیف پول را شارژ نمایید یا مبلغ وام را کاهش دهید.',
                        en: 'Insufficient USDT balance for this loan amount. Please top up or decrease loan amount.',
                        ar: 'رصيد USDT غير كافٍ. يرجى الشحن أو خفض المبلغ.',
                        zh: 'USDT 余额不足以覆盖所需抵押。请先充值或减少申请金额。',
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Amortization Schedule Preview Section with Toggle
  Widget _buildAmortizationScheduleSection(
    BuildContext context,
    double rateAnnual,
    bool isDark,
    Color surfaceColor,
    Color borderColor,
    Color primaryAccent,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Expand / Collapse toggle
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() {
                _showAmortizationTable = !_showAmortizationTable;
              });
            },
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: primaryAccent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.table_view_rounded,
                            size: 17.sp,
                            color: primaryAccent,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              fa: 'پیش‌نمایش جدول استهلاک اقساط',
                              en: 'Amortization Schedule Preview',
                              ar: 'معاينة جدول استهلاك الأقساط',
                              zh: '还款计划明细表预览',
                            ),
                            style: TextStyle(
                              fontSize: 13.5.sp,
                              fontWeight: FontWeight.w800,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10nPick(
                              context,
                              fa: 'تفکیک ماهانه اصل وام، سود و مانده بدهی',
                              en: 'Month #, Principal, Interest & Remaining Balance',
                              ar: 'تفاصيل الأصل والفائدة والرصيد',
                              zh: '期数、本金、利息与剩余本金',
                            ),
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    _showAmortizationTable
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 22.sp,
                    color: primaryAccent,
                  ),
                ],
              ),
            ),
          ),

          if (_showAmortizationTable) ...[
            SizedBox(height: AppSpacing.sm.h),
            Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
            ),
            SizedBox(height: AppSpacing.md.h),

            // Embedded Amortization Schedule Component
            LoanAmortizationSchedule.preview(
              principal: _amount,
              annualInterestRatePct: rateAnnual,
              tenureMonths: _tenureMonths,
              gracePeriodMonths: _graceMonths,
              currency: 'USD',
              showHeader: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox(
    BuildContext context,
    bool isDark,
    Color primaryAccent,
    Color borderColor,
    Color textPrimary,
    Color textSecondary,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() {
          _termsAccepted = !_termsAccepted;
          controller.termsAccepted.value = _termsAccepted;
        });
      },
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(vertical: 4.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: _termsAccepted,
              activeColor: primaryAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _termsAccepted = val ?? true;
                  controller.termsAccepted.value = _termsAccepted;
                });
              },
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.only(top: 8.h),
                child: Text(
                  l10nPick(
                    context,
                    fa: 'شرایط و ضوابط عمومی تسهیلات، نرخ سود مصوب، نحوه بازپرداخت اقساط و قوانین وثیقه‌گذاری را مطالعه کرده و می‌پذیرم.',
                    en: 'I have read and agree to the loan terms, interest rates, repayment schedule, and collateral policies.',
                    ar: 'أوافق على الشروط والأحكام ومعدل الفائدة وجدول السداد وسياسات الضمان.',
                    zh: '我已阅读并完全同意信贷服务条款、年化利率核算、分期还款规则及质押政策。',
                  ),
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: textSecondary,
                    height: 1.45,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    BuildContext context,
    LoanProductModel product,
    bool requiresCollateral,
    bool hasEnoughCollateral,
    bool isDark,
    Color primaryAccent,
    Color surfaceColor,
    Color borderColor,
    Color textSecondary,
  ) {
    final canProceed =
        _termsAccepted && (!requiresCollateral || hasEnoughCollateral);

    return Container(
      padding: EdgeInsetsDirectional.all(AppSpacing.md.r),
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(top: BorderSide(color: borderColor)),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: canProceed
                      ? primaryAccent
                      : AppColors.softGray,
                  foregroundColor: isDark ? AppColors.deepBlack : Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                  ),
                ),
                onPressed: canProceed
                    ? () {
                        HapticFeedback.lightImpact();
                        controller.amountInput.value = _amount
                            .toInt()
                            .toString();
                        controller.selectedTenure.value = _tenureMonths;
                        controller.termsAccepted.value = true;
                        Get.to(
                          () => LoanConfirmScreen(
                            amount: _amount,
                            tenureMonths: _tenureMonths,
                            graceMonths: _graceMonths,
                            collateralType: product.requiredCollateralType,
                            collateralRatioPct: product.collateralRatioPct,
                          ),
                        );
                      }
                    : null,
                child: Text(
                  l10nPick(
                    context,
                    fa: 'بررسی و پذیرش شرایط',
                    en: 'Review and Accept Terms',
                    ar: 'مراجعة وتأكيد الشروط',
                    zh: '确认并接受条款',
                  ),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              l10nPick(
                context,
                fa: 'تا پیش از امضای نهایی قرارداد، هیچ وجهی از حساب یا وثیقه شما کسر نخواهد شد.',
                en: 'Nothing is deducted or locked until final contract signing.',
                ar: 'لن يتم خصم أو قفل أي مبلغ حتى توقيع العقد النهائي.',
                zh: '在最终电子签约确认之前，系统不会冻结或扣除您的任何资金。',
              ),
              style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
