import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import '../models/guarantee_models.dart';
import '../widgets/guarantee_collateral_card.dart';
import 'guarantee_confirm_screen.dart';

/// Form screen for creating a new bank guarantee or LC case.
class GuaranteeApplicationScreen extends StatefulWidget {
  const GuaranteeApplicationScreen({super.key});

  @override
  State<GuaranteeApplicationScreen> createState() => _GuaranteeApplicationScreenState();
}

class _GuaranteeApplicationScreenState extends State<GuaranteeApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final GuaranteeController controller = Get.isRegistered<GuaranteeController>()
      ? Get.find<GuaranteeController>()
      : Get.put(GuaranteeController());

  final _beneficiaryController = TextEditingController();
  final _beneficiaryIdController = TextEditingController();
  final _amountController = TextEditingController();
  final _contractRefController = TextEditingController();

  String _currency = 'IRR';
  int _validityMonths = 12;
  GuaranteeCollateralType _selectedCollateralType = GuaranteeCollateralType.cash;

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    if (controller.amountInput.value.isNotEmpty) {
      _amountController.text = controller.amountInput.value;
    }
    _amountController.addListener(_onAmountChanged);
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _beneficiaryController.dispose();
    _beneficiaryIdController.dispose();
    _amountController.dispose();
    _contractRefController.dispose();
    super.dispose();
  }

  void _onProceed() {
    if (_formKey.currentState?.validate() != true) return;

    controller.beneficiaryNameInput.value = _beneficiaryController.text.trim();
    controller.beneficiaryIdInput.value = _beneficiaryIdController.text.trim();
    controller.amountInput.value = _amountController.text.trim();
    controller.currencyInput.value = _currency;
    controller.validityMonthsInput.value = _validityMonths;
    controller.contractRefInput.value = _contractRefController.text.trim();
    controller.collateralTypeInput.value = _selectedCollateralType.id;

    Get.to(() => const GuaranteeConfirmScreen());
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
              fa: 'فرم صدور ضمانت‌نامه بانکی',
              en: 'Bank Guarantee Application',
              ar: 'طلب إصدار خطاب ضمان',
              zh: '保函开立申请表',
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
              fa: 'پیش‌نمایش شرایط و تعهدات',
              en: 'Review & Terms',
              ar: 'مراجعة الشروط والالتزامات',
              zh: '预览条款与担保条件',
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
            // Instrument selector
            Text(
              l10nPick(
                context,
                fa: 'نوع ضمانت‌نامه درخواستی',
                en: 'Guarantee Instrument Type',
                ar: 'نوع خطاب الضمان',
                zh: '保函业务种类',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Obx(() {
              if (controller.instruments.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.shield_rounded, color: const Color(0xFF0D9488), size: 22.sp),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            fa: 'ضمانت‌نامه حسن انجام تعهدات (پیش‌فرض)',
                            en: 'Performance Bond (Default)',
                            ar: 'ضمان حسن التنفيذ (افتراضي)',
                            zh: '履约保函（默认）',
                          ),
                          style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return DropdownButtonFormField<GuaranteeInstrumentModel>(
                initialValue: controller.selectedInstrument.value ?? controller.instruments.first,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: const BorderSide(color: AppColors.lightBorder),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                ),
                items: controller.instruments.map((inst) {
                  return DropdownMenuItem<GuaranteeInstrumentModel>(
                    value: inst,
                    child: Text('${inst.name} (وجه التزام: ${inst.marginPct}٪)'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedInstrument.value = val;
                },
              );
            }),

            SizedBox(height: 16.h),

            // Beneficiary Name
            Text(
              l10nPick(
                context,
                fa: 'نام کامل کارفرما یا ذینفع ضمانت‌نامه',
                en: 'Beneficiary / Employer Name',
                ar: 'اسم المستفيد / الجهة الطالبة',
                zh: '受益人/雇主全称',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _beneficiaryController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: l10nPick(
                  context,
                  fa: 'مثال: شرکت ملی مس ایران / اداره کل راه و شهرسازی',
                  en: 'e.g. National Copper Corp / Ministry of Transport',
                  ar: 'مثال: شركة المقاولات العامة / هيئة الطرق',
                  zh: '例：国家基础设施开发集团/交通运输局',
                ),
                prefixIcon: const Icon(Icons.business_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().length < 3) {
                  return l10nPick(
                    context,
                    fa: 'وارد کردن نام ذینفع الزامی است (حداقل ۳ حرف)',
                    en: 'Beneficiary name is required (min 3 chars)',
                  );
                }
                return null;
              },
            ),

            SizedBox(height: 16.h),

            // Beneficiary ID / National code
            Text(
              l10nPick(
                context,
                fa: 'شناسه ملی / کد اقتصادی ذینفع (اختیاری)',
                en: 'Beneficiary National/Tax ID (Optional)',
                ar: 'الرقم الضريبي أو السجل التجاري للمستفيد',
                zh: '受益人统一信用代码/税号（选填）',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _beneficiaryIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'شناسه ۱۱ رقمی اشخاص حقوقی',
                prefixIcon: const Icon(Icons.badge_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Amount and Currency
            Text(
              l10nPick(
                context,
                fa: 'مبلغ اسمی ضمانت‌نامه',
                en: 'Guarantee Face Amount',
                ar: 'مبلغ الضمان الاسمي',
                zh: '保函开立金额',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'مثال: ۱۰۰,۰۰۰,۰۰۰',
                      prefixIcon: const Icon(Icons.monetization_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: AppColors.lightBorder),
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return l10nPick(context, fa: 'مبلغ الزامی است', en: 'Amount is required');
                      }
                      final numVal = double.tryParse(val.replaceAll(',', '').trim());
                      if (numVal == null || numVal <= 0) {
                        return l10nPick(context, fa: 'مبلغ عددی معتبر وارد کنید', en: 'Enter a valid amount');
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    initialValue: _currency,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(color: AppColors.lightBorder),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 12.h),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'IRR', child: Text('IRR')),
                      DropdownMenuItem(value: 'USD', child: Text('USD')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                      DropdownMenuItem(value: 'AED', child: Text('AED')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _currency = val);
                    },
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Validity Duration (Months)
            Text(
              l10nPick(
                context,
                fa: 'مدت اعتبار ضمانت‌نامه',
                en: 'Validity Period',
                ar: 'مدة سريان الضمان',
                zh: '保函有效期限',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              children: [3, 6, 12, 18, 24].map((m) {
                final selected = _validityMonths == m;
                return ChoiceChip(
                  label: Text(
                    '$m ' + l10nPick(context, fa: 'ماهه', en: 'mo', ar: 'شهر', zh: '月'),
                    style: TextStyle(
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                      color: selected ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  selected: selected,
                  selectedColor: const Color(0xFF0D9488),
                  onSelected: (val) {
                    if (val) setState(() => _validityMonths = m);
                  },
                );
              }).toList(),
            ),

            SizedBox(height: 16.h),

            // Contract / Tender Reference
            Text(
              l10nPick(
                context,
                fa: 'شماره و مشخصات مناقصه یا قرارداد مبنا',
                en: 'Tender / Contract Reference No.',
                ar: 'رقم المناقصة أو العقد الأساسي',
                zh: '关联合同/招标书编号',
              ),
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: _contractRefController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'مثال: TND-1403/987',
                prefixIcon: const Icon(Icons.file_present_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.r),
                  borderSide: const BorderSide(color: AppColors.lightBorder),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Guarantee Collateral Selection & Deposit Card
            Obx(() {
              final currentInstrument = controller.selectedInstrument.value;
              final marginPct = currentInstrument?.marginPct ?? 10.0;
              final parsedAmt = double.tryParse(_amountController.text.replaceAll(',', '').trim()) ?? 0.0;

              return GuaranteeCollateralCard(
                guaranteeAmount: parsedAmt,
                marginPct: marginPct,
                currency: _currency,
                initialType: _selectedCollateralType,
                onCollateralTypeChanged: (type) {
                  setState(() => _selectedCollateralType = type);
                  controller.collateralTypeInput.value = type.id;
                },
              );
            }),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
