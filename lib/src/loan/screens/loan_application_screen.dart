import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import '../models/loan_models.dart';
import 'loan_confirm_screen.dart';

/// Form screen for submitting a loan request with rigorous input validation.
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

  @override
  void initState() {
    super.initState();
    if (controller.amountInput.value.isNotEmpty) {
      _amountController.text = controller.amountInput.value;
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

    Get.to(() => const LoanConfirmScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              fa: 'بررسی نهایی و تأیید شرایط',
              en: 'Review & Confirm',
              ar: 'مراجعة وتأكيد الشروط',
              zh: '审核并确认条件',
            ),
            backgroundColor: AppColors.lightPrimary,
            onPressed: _onProceed,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
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
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              if (controller.products.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.stars_rounded, color: AppColors.mainSoftBlue, size: 24.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'طرح اعتباری هوشمند زرین (پیش‌فرض سیستم)',
                            en: 'Zarrin Smart Credit Scheme (Default)',
                            ar: 'خطة زرين الائتمانية الذكية (افتراضي)',
                            zh: 'Zarrin 智能信贷方案（默认）',
                          ),
                          style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
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
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: controller.products.map((p) {
                  return DropdownMenuItem<LoanProductModel>(
                    value: p,
                    child: Text('${p.name} (${p.baseRateAnnual}% سالانه)'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectProduct(val);
                },
              );
            }),

            SizedBox(height: 16.h),

            // Requested Amount
            Text(
              l10nPick(
                context,
                fa: 'مبلغ درخواستی تسهیلات (ریال / واحد)',
                en: 'Requested Amount',
                ar: 'المبلغ المطلوب',
                zh: '申请融资金额',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'مثال: ۵۰,۰۰۰,۰۰۰',
                prefixIcon: const Icon(Icons.attach_money_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return l10nPick(context, fa: 'وارد کردن مبلغ الزامی است', en: 'Amount is required');
                }
                final numVal = double.tryParse(val.replaceAll(',', '').trim());
                if (numVal == null || numVal <= 0) {
                  return l10nPick(context, fa: 'مبلغ عددی معتبر وارد کنید', en: 'Enter a valid numeric amount');
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

            SizedBox(height: 16.h),

            // Tenure selector
            Text(
              l10nPick(
                context,
                fa: 'مدت بازپرداخت اقساط',
                en: 'Repayment Tenure',
                ar: 'مدة السداد',
                zh: '还款期限',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              final activeTenure = controller.selectedTenure.value;
              final options = controller.selectedProduct.value?.tenureOptions ?? [6, 12, 18, 24, 36];
              return Wrap(
                spacing: 8.w,
                children: options.map((m) {
                  final isSelected = activeTenure == m;
                  return ChoiceChip(
                    label: Text(
                      '$m ' + l10nPick(context, fa: 'ماهه', en: 'mo', ar: 'شهر', zh: '月'),
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.lightPrimary,
                    onSelected: (val) {
                      if (val) controller.selectedTenure.value = m;
                    },
                  );
                }).toList(),
              );
            }),

            SizedBox(height: 16.h),

            // Loan purpose
            Text(
              l10nPick(
                context,
                fa: 'موضوع یا هدف تسهیلات',
                en: 'Loan Purpose',
                ar: 'الغرض من التسهيل',
                zh: '贷款用途',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _purposeController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: l10nPick(
                  context,
                  fa: 'مثال: خرید تجهیزات، سرمایه در گردش، هزینه‌های بازرگانی',
                  en: 'e.g. Working capital, purchase, trade financing',
                  ar: 'مثال: تمويل رأس المال العامل، مشتريات تجارية',
                  zh: '例：流动资金周转、设备采购、贸易融资',
                ),
                prefixIcon: const Icon(Icons.description_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
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

            SizedBox(height: 16.h),

            // Monthly Documented Income
            Text(
              l10nPick(
                context,
                fa: 'درآمد ماهیانه مستند / اظهارشده (جهت اعتبارسنجی)',
                en: 'Documented Monthly Income',
                ar: 'الدخل الشهري الموثق',
                zh: '月收入凭证金额',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'مثال: ۳۰,۰۰۰,۰۰۰',
                prefixIcon: const Icon(Icons.account_balance_wallet_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
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

            SizedBox(height: 16.h),

            // Collateral type
            Text(
              l10nPick(
                context,
                fa: 'نوع وثیقه پیشنهادی',
                en: 'Collateral Type',
                ar: 'نوع الضمان المقترح',
                zh: '抵押物担保类型',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            DropdownButtonFormField<String>(
              initialValue: _collateralType,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                if (val != null) setState(() => _collateralType = val);
              },
            ),

            SizedBox(height: 16.h),

            // Guarantor National ID (if applicable)
            Text(
              l10nPick(
                context,
                fa: 'کد ملی یا شناسه ضامن (اختیاری)',
                en: 'Guarantor National ID (Optional)',
                ar: 'الرقم القومي للضامن (اختياري)',
                zh: '担保人身份证号（选填）',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _guarantorController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'کد ملی ۱۰ رقمی ضامن',
                prefixIcon: const Icon(Icons.person_add_alt_1_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
