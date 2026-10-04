import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import 'loan_confirm_screen.dart';

/// Loan Application & Real-time Calculator Screen — matches `apply_for_a_loan.html`
/// Features:
/// 1. Dynamic Loan Amount in USD (e.g. 500 – 100,000 USD)
/// 2. Tenure Selector Chips (3 mo, 6 mo, 12 mo, 24 mo)
/// 3. Real-time Cost Breakdown:
///    - Monthly EMI payment
///    - Annual Interest Rate (e.g. 14.0% a year)
///    - Total interest
///    - Origination fee (1%)
///    - Total repayment
/// 4. Collateral calculation (150% USDT locked) vs Available Wallet USDT
/// 5. Review and accept terms CTA
class LoanApplicationScreen extends StatefulWidget {
  const LoanApplicationScreen({super.key});

  @override
  State<LoanApplicationScreen> createState() => _LoanApplicationScreenState();
}

class _LoanApplicationScreenState extends State<LoanApplicationScreen> {
  final LoanController controller = Get.isRegistered<LoanController>()
      ? Get.find<LoanController>()
      : Get.put(LoanController());

  final _amountController = TextEditingController();

  double _amount = 10000.0;
  int _tenureMonths = 6;
  final double _availableWalletUsdt = 18420.0;

  @override
  void initState() {
    super.initState();
    if (controller.selectedProduct.value == null && controller.products.isNotEmpty) {
      controller.selectProduct(controller.products.first);
    }
    _amountController.text = '10000';
    _amount = 10000.0;
    _tenureMonths = 6;
    controller.amountInput.value = '10000';
    controller.selectedTenure.value = 6;
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll(',', '').trim();
    final parsed = double.tryParse(clean);
    if (parsed != null && parsed >= 0) {
      setState(() {
        _amount = parsed;
        controller.amountInput.value = clean;
      });
    }
  }

  void _onTenureSelected(int months) {
    HapticFeedback.lightImpact();
    setState(() {
      _tenureMonths = months;
      controller.selectedTenure.value = months;
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = controller.selectedProduct.value ?? LoanController.defaultProducts.first;

    final rateAnnual = product.interestRatePct > 0 ? product.interestRatePct : 14.0;
    final monthlyPayment = controller.calculateMonthlyInstallment(
      principal: _amount,
      annualInterestRatePct: rateAnnual,
      tenureMonths: _tenureMonths,
    );
    final totalRepayment = monthlyPayment * _tenureMonths;
    final totalInterest = totalRepayment > _amount ? totalRepayment - _amount : 0.0;
    final originationFee = _amount * (product.feePct / 100.0);
    final finalTotal = totalRepayment + originationFee;

    // Collateral calculation: 150% of loan amount in USDT
    final collateralNeededUsdt = _amount * 1.5;
    final hasEnoughCollateral = _availableWalletUsdt >= collateralNeededUsdt;

    final tenureOptions = product.tenureOptions.isNotEmpty ? product.tenureOptions : [3, 6, 12, 24];

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: product.name,
            isBackLogicApply: true,
            backLogicFunction: Get.back,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal: ECardoTokens.space4.w,
          vertical: ECardoTokens.space3.h,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ------------------ Amount Input Card ------------------
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(
                      context,
                      fa: 'چقدر وام نیاز دارید؟',
                      en: 'How much do you need',
                      ar: 'كم تحتاج من التمويل؟',
                      zh: '您需要多少贷款',
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space2.h),

                  // Amount TextField with Currency suffix
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd.r),
                      border: Border.all(color: ECardoTokens.borderStrong(context)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.ink(context),
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: _onAmountChanged,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand100(context),
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                          ),
                          child: Text(
                            'USD',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.brand700(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space2.h),

                  Text(
                    '${product.minAmount.toInt()} – ${product.maxAmount.toInt()} USD',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),

                  SizedBox(height: ECardoTokens.space4.h),

                  // Repay over chips
                  Text(
                    l10nPick(
                      context,
                      fa: 'مدت بازپرداخت',
                      en: 'Repay over',
                      ar: 'مدة السداد',
                      zh: '还款期限',
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: ECardoTokens.space2.h),

                  Wrap(
                    spacing: 8.w,
                    children: tenureOptions.map((m) {
                      final isSelected = _tenureMonths == m;
                      return ChoiceChip(
                        label: Text('$m mo'),
                        selected: isSelected,
                        selectedColor: ECardoTokens.brand900(context),
                        backgroundColor: ECardoTokens.surfaceSunken(context),
                        labelStyle: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : ECardoTokens.ink(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm.r),
                          side: BorderSide(
                            color: isSelected ? ECardoTokens.brand900(context) : ECardoTokens.border(context),
                          ),
                        ),
                        onSelected: (_) => _onTenureSelected(m),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Cost Breakdown Card ------------------
            Text(
              l10nPick(
                context,
                fa: 'هزینه‌ها و محاسبات',
                en: 'What it costs',
                ar: 'تفاصيل التكلفة',
                zh: '费用明细',
              ),
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: ECardoTokens.ink(context),
              ),
            ),
            SizedBox(height: ECardoTokens.space2.h),

            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                children: [
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'قسط ماهانه', en: 'Monthly payment'),
                    value: '${monthlyPayment.toStringAsFixed(2)} USD',
                    isPrimary: true,
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'نرخ سود سالانه', en: 'Interest rate'),
                    value: '${rateAnnual.toStringAsFixed(1)}% a year',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کل سود دوره', en: 'Total interest'),
                    value: '${totalInterest.toStringAsFixed(2)} USD',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'کارمزد صدور ۱٪', en: 'Origination fee 1%'),
                    value: '${originationFee.toStringAsFixed(2)} USD',
                  ),
                  Divider(color: ECardoTokens.border(context), height: 16.h),
                  _buildCostRow(
                    context,
                    label: l10nPick(context, fa: 'مجموع بازپرداخت', en: 'You repay in total'),
                    value: '${finalTotal.toStringAsFixed(2)} USD',
                    isStrong: true,
                  ),
                ],
              ),
            ),

            SizedBox(height: ECardoTokens.space4.h),

            // ------------------ Collateral Card ------------------
            if (product.requiredCollateralType != null || product.collateralRatioPct > 0) ...[
              Text(
                l10nPick(
                  context,
                  fa: 'وثیقه تضمین وام',
                  en: 'Collateral you lock',
                  ar: 'الضمان المرهون',
                  zh: '锁仓抵押品',
                ),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: ECardoTokens.ink(context),
                ),
              ),
              SizedBox(height: ECardoTokens.space2.h),

              Container(
                padding: EdgeInsets.all(ECardoTokens.space4.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl.r),
                  border: Border.all(
                    color: hasEnoughCollateral
                        ? ECardoTokens.border(context)
                        : ECardoTokens.danger(context).withValues(alpha: 0.5),
                  ),
                  boxShadow: ECardoTokens.shadowCard(context),
                ),
                child: Column(
                  children: [
                    _buildCostRow(
                      context,
                      label: l10nPick(
                        context,
                        fa: 'تتر قفل‌شده (۱۵۰٪ اصل وام)',
                        en: 'USDT locked · 150% of the loan',
                      ),
                      value: '${collateralNeededUsdt.toStringAsFixed(0)} USDT',
                      isPrimary: true,
                    ),
                    Divider(color: ECardoTokens.border(context), height: 16.h),
                    _buildCostRow(
                      context,
                      label: l10nPick(
                        context,
                        fa: 'موجودی تتر در کیف پول شما',
                        en: 'Your available USDT',
                      ),
                      value: '${_availableWalletUsdt.toStringAsFixed(0)} USDT',
                      valueColor: hasEnoughCollateral
                          ? ECardoTokens.success(context)
                          : ECardoTokens.danger(context),
                    ),
                    if (!hasEnoughCollateral) ...[
                      SizedBox(height: 8.h),
                      Text(
                        l10nPick(
                          context,
                          fa: 'موجودی تتر شما برای این مبلغ وام کافی نیست.',
                          en: 'Insufficient USDT balance for this loan amount.',
                        ),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ECardoTokens.danger(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(height: ECardoTokens.space4.h),
            ],

            SizedBox(height: ECardoTokens.space6.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ECardoTokens.space4.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          border: Border(top: BorderSide(color: ECardoTokens.border(context))),
          boxShadow: ECardoTokens.shadowSheet(context),
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
                    backgroundColor: ECardoTokens.brand900(context),
                    foregroundColor: ECardoTokens.inkOnBrand,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg.r),
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.amountInput.value = _amount.toInt().toString();
                    controller.selectedTenure.value = _tenureMonths;
                    controller.termsAccepted.value = true;
                    Get.to(() => const LoanConfirmScreen());
                  },
                  child: Text(
                    l10nPick(
                      context,
                      fa: 'بررسی و پذیرش شرایط',
                      en: 'Review and accept terms',
                      ar: 'مراجعة وقبول الشروط',
                      zh: '查看并接受条款',
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
                  fa: 'تا قبل از پذیرش نهایی شرایط، هیچ مبلغی مسدود نخواهد شد.',
                  en: 'Nothing is locked until you accept the terms.',
                  ar: 'لن يتم قفل أي مبلغ حتى توافق على الشروط.',
                  zh: '在您接受条款前不会冻结任何资金。',
                ),
                style: TextStyle(
                  fontSize: 11.5.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCostRow(
    BuildContext context, {
    required String label,
    required String value,
    bool isPrimary = false,
    bool isStrong = false,
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: isStrong ? ECardoTokens.ink(context) : ECardoTokens.inkMuted(context),
            fontWeight: isStrong ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 15.sp : 14.sp,
            fontWeight: (isPrimary || isStrong) ? FontWeight.w800 : FontWeight.w700,
            color: valueColor ?? (isPrimary ? ECardoTokens.brand900(context) : ECardoTokens.ink(context)),
          ),
        ),
      ],
    );
  }
}
