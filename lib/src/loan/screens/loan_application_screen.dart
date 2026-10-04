import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import '../widgets/loan_calculator_slider.dart';
import '../widgets/loan_amortization_schedule.dart';
import 'loan_confirm_screen.dart';

/// Form screen to configure loan parameters, input applicant financial details,
/// and review estimated amortization schedule before confirmation.
class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final LoanController controller = Get.isRegistered<LoanController>()
      ? Get.find<LoanController>()
      : Get.put(LoanController());

  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _incomeController = TextEditingController();
  final _guarantorController = TextEditingController();

  String _collateralType = 'CASH';

  double _calculatedAmount = 50000000.0;
  int _calculatedTenure = 12;
  int _calculatedGraceMonths = 0;
  double _calculatedMonthlyPayment = 0.0;
  bool _isSchedulePreviewExpanded = true;

  @override
  void initState() {
    super.initState();
    final parsed = double.tryParse(controller.amountInput.value);
    if (parsed != null && parsed > 0) {
      _calculatedAmount = parsed;
      _amountController.text = parsed.toInt().toString();
    } else {
      _calculatedAmount = 50000000.0;
      _amountController.text = '50000000';
      controller.amountInput.value = '50000000';
    }

    if (controller.selectedTenure.value > 0) {
      _calculatedTenure = controller.selectedTenure.value;
    } else {
      _calculatedTenure = 12;
      controller.selectedTenure.value = 12;
    }
  }

  void _onSliderPlanChanged(double amount, int months, int graceMonths, double monthlyPayment) {
    setState(() {
      _calculatedAmount = amount;
      _calculatedTenure = months;
      _calculatedGraceMonths = graceMonths;
      _calculatedMonthlyPayment = monthlyPayment;
      _amountController.text = amount.toInt().toString();
      controller.amountInput.value = amount.toInt().toString();
      controller.selectedTenure.value = months;
    });
  }

  void _onAmountFieldChanged(String val) {
    final parsed = double.tryParse(val.replaceAll(',', '').trim());
    if (parsed != null && parsed > 0) {
      final p = controller.selectedProduct.value;
      final minA = p?.minAmount ?? 5000000.0;
      final maxA = p?.maxAmount ?? 500000000.0;
      final clamped = parsed.clamp(minA, maxA);
      if (clamped != _calculatedAmount) {
        setState(() {
          _calculatedAmount = clamped;
          controller.amountInput.value = parsed.toInt().toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _purposeController.dispose();
    _incomeController.dispose();
    _guarantorController.dispose();
    super.dispose();
  }

  void _onProceed() {
    if (_formKey.currentState?.validate() != true) return;

    controller.amountInput.value = _amountController.text.trim();
    controller.purposeInput.value = _purposeController.text.trim();
    controller.documentedIncomeInput.value = _incomeController.text.trim();
    controller.collateralTypeInput.value = _collateralType;
    controller.guarantorNationalIdInput.value = _guarantorController.text.trim();
    controller.graceMonthsInput.value = _calculatedGraceMonths;

    HapticFeedback.lightImpact();
    Get.to(() => const LoanConfirmScreen());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'فرم ثبت درخواست تسهیلات',
              en: 'Loan Application Form',
              ar: 'نموذج طلب التسهيلات',
              zh: '贷款申请表单',
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.page.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_calculatedMonthlyPayment > 0)
                Container(
                  margin: EdgeInsetsDirectional.only(bottom: AppSpacing.sm.h),
                  padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, fa: 'قسط ماهانه تخمینی:', en: 'Estimated Monthly Installment:'),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '${_calculatedMonthlyPayment.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${l10nPick(context, fa: 'ریال', en: 'IRR')}',
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w900,
                          color: primaryAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              CommonButton(
                width: double.infinity,
                text: l10nPick(
                  context,
                  fa: 'بررسی نهایی و تأیید شرایط',
                  en: 'Review & Confirm',
                  ar: 'مراجعة وتأكيد الشروط',
                  zh: '审核并确认条件',
                ),
                backgroundColor: primaryAccent,
                onPressed: _onProceed,
              ),
            ],
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page.w, vertical: AppSpacing.md.h),
          children: [
            // Product selection
            Text(
              l10nPick(
                context,
                fa: 'انتخاب طرح تسهیلاتی',
                en: 'Select Loan Scheme',
                ar: 'اختر خطة التسهيل',
                zh: '选择贷款方案',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(() {
              if (controller.products.isEmpty) {
                return Container(
                  padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars_rounded, color: primaryAccent, size: 24.sp),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'طرح اعتباری هوشمند زرین (پیش‌فرض سیستم)',
                            en: 'Zarrin Smart Credit Scheme (Default)',
                            ar: 'خطة زرين الائتمانية الذكية (افتراضي)',
                            zh: 'Zarrin 智能信贷方案（默认）',
                          ),
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return DropdownButtonFormField<LoanProductModel>(
                initialValue: controller.selectedProduct.value ?? controller.products.first,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                  contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: controller.products.map((p) {
                  return DropdownMenuItem<LoanProductModel>(
                    value: p,
                    child: Text('${p.name} (${p.baseRateAnnual}% سالانه)'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    HapticFeedback.selectionClick();
                    controller.selectProduct(val);
                  }
                },
              );
            }),

            SizedBox(height: AppSpacing.lg.h),

            // Interactive Loan Calculator Slider
            Obx(() {
              final p = controller.selectedProduct.value;
              final minAmt = p != null && p.minAmount > 0 ? p.minAmount : 5000000.0;
              final maxAmt = p != null && p.maxAmount > 0 ? p.maxAmount : 500000000.0;
              final rate = p?.baseRateAnnual ?? 18.0;
              final termOpts = p != null && p.tenureOptions.isNotEmpty ? p.tenureOptions : [3, 6, 12, 18, 24, 36];

              return LoanCalculatorSlider(
                initialAmount: _calculatedAmount,
                initialMonths: _calculatedTenure,
                initialGraceMonths: _calculatedGraceMonths,
                minAmount: minAmt,
                maxAmount: maxAmt,
                annualInterestRate: rate,
                termOptions: termOpts,
                currency: 'IRR',
                onPlanChanged: _onSliderPlanChanged,
              );
            }),

            SizedBox(height: AppSpacing.md.h),

            // Quick Amortization Schedule Preview
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() => _isSchedulePreviewExpanded = !_isSchedulePreviewExpanded);
                    },
                    child: Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 12.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_month_outlined, size: 18.sp, color: primaryAccent),
                              SizedBox(width: AppSpacing.sm.w),
                              Text(
                                l10nPick(
                                  context,
                                  fa: 'پیش‌نمایش جدول استهلاک اقساط',
                                  en: 'Amortization Schedule Preview',
                                  ar: 'معاينة جدول استهلاك الأقساط',
                                  zh: '还款与摊销计划表预览',
                                ),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
                          ),
                          Icon(
                            _isSchedulePreviewExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            size: 20.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_isSchedulePreviewExpanded) ...[
                    Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    Padding(
                      padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
                      child: LoanAmortizationSchedule(
                        installments: InstallmentItem.generateSchedule(
                          principal: _calculatedAmount,
                          annualInterestRatePct: controller.selectedProduct.value?.baseRateAnnual ?? 18.0,
                          tenureMonths: _calculatedTenure,
                          gracePeriodMonths: _calculatedGraceMonths,
                        ),
                        totalPrincipal: _calculatedAmount,
                        currency: 'IRR',
                        showHeader: true,
                        isCompactInitially: true,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Exact Amount Input Field
            Text(
              l10nPick(
                context,
                fa: 'مبلغ دقیق درخواستی (ریال)',
                en: 'Exact Requested Amount (IRR)',
                ar: 'المبلغ المطلوب بدقة',
                zh: '精确申请金额（里亚尔）',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: _onAmountFieldChanged,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                prefixIcon: const Icon(Icons.monetization_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10nPick(
                    context,
                    fa: 'مبلغ درخواستی الزامی است',
                    en: 'Requested amount is required',
                  );
                }
                final numVal = double.tryParse(val.replaceAll(',', '').trim());
                if (numVal == null || numVal <= 0) {
                  return l10nPick(
                    context,
                    fa: 'مبلغ نامعتبر است',
                    en: 'Invalid amount',
                  );
                }
                final p = controller.selectedProduct.value;
                if (p != null) {
                  if (numVal < p.minAmount) {
                    return l10nPick(
                      context,
                      fa: 'حداقل مبلغ این طرح ${p.minAmount.toInt()} است',
                      en: 'Minimum for this scheme is ${p.minAmount.toInt()}',
                    );
                  }
                  if (numVal > p.maxAmount) {
                    return l10nPick(
                      context,
                      fa: 'حداکثر مبلغ این طرح ${p.maxAmount.toInt()} است',
                      en: 'Maximum for this scheme is ${p.maxAmount.toInt()}',
                    );
                  }
                }
                return null;
              },
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Loan purpose
            Text(
              l10nPick(
                context,
                fa: 'موضوع یا هدف تسهیلات',
                en: 'Loan Purpose',
                ar: 'الغرض من التسهيل',
                zh: '贷款用途',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextFormField(
              controller: _purposeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                hintText: l10nPick(
                  context,
                  fa: 'مثال: خرید تجهیزات، سرمایه در گردش، هزینه‌های بازرگانی',
                  en: 'e.g. Working capital, purchase, trade financing',
                  ar: 'مثال: تمويل رأس المال العامل، مشتريات تجارية',
                  zh: '例：流动资金周转、设备采购、贸易融资',
                ),
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().length < 3) {
                  return l10nPick(
                    context,
                    fa: 'حداقل ۳ حرف برای موضوع الزامی است',
                    en: 'Minimum 3 characters required',
                  );
                }
                return null;
              },
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Monthly Documented Income
            Text(
              l10nPick(
                context,
                fa: 'درآمد ماهیانه مستند / اظهارشده (جهت اعتبارسنجی)',
                en: 'Documented Monthly Income',
                ar: 'الدخل الشهري الموثق',
                zh: '月收入凭证金额',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextFormField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                hintText: 'مثال: ۳۰,۰۰۰,۰۰۰',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10nPick(
                    context,
                    fa: 'وارد کردن درآمد تقریبی الزامی است',
                    en: 'Estimated income is required',
                  );
                }
                return null;
              },
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Collateral type
            Text(
              l10nPick(
                context,
                fa: 'نوع وثیقه پیشنهادی',
                en: 'Collateral Type',
                ar: 'نوع الضمان المقترح',
                zh: '抵押物担保类型',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            DropdownButtonFormField<String>(
              initialValue: _collateralType,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                contentPadding: EdgeInsetsDirectional.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
              items: [
                DropdownMenuItem(
                  value: 'CASH',
                  child: Text(l10nPick(context, fa: 'سپرده نقدی مسدودشده (LTV 90%)', en: 'Cash Deposit (90% LTV)')),
                ),
                DropdownMenuItem(
                  value: 'CRYPTO',
                  child: Text(l10nPick(context, fa: 'توثیق دارایی رمزارز (BTC/USDT)', en: 'Crypto Collateral (BTC/USDT)')),
                ),
                DropdownMenuItem(
                  value: 'GOLD',
                  child: Text(l10nPick(context, fa: 'گواهی سپرده طلا / سکه', en: 'Gold Certificate / Coins')),
                ),
                DropdownMenuItem(
                  value: 'PROMISSORY_NOTE',
                  child: Text(l10nPick(context, fa: 'سفته الکترونیک بانکی', en: 'Digital Promissory Note')),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  HapticFeedback.selectionClick();
                  setState(() => _collateralType = val);
                }
              },
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Guarantor National ID (if applicable)
            Text(
              l10nPick(
                context,
                fa: 'کد ملی یا شناسه ضامن (اختیاری)',
                en: 'Guarantor National ID (Optional)',
                ar: 'الرقم القومي للضامن (اختياري)',
                zh: '担保人身份证号（选填）',
              ),
              style: AppTextStyles.titleSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextFormField(
              controller: _guarantorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurface,
                hintText: 'کد ملی ۱۰ رقمی ضامن',
                prefixIcon: const Icon(Icons.person_add_alt_1_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xxl.h),
          ],
        ),
      ),
    );
  }
}
