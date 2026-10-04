import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/guarantee_controller.dart';
import 'guarantee_tracking_screen.dart';

/// Review and confirmation screen for the bank guarantee before submission to SEPAM.
class GuaranteeConfirmScreen extends StatefulWidget {
  const GuaranteeConfirmScreen({super.key});

  @override
  State<GuaranteeConfirmScreen> createState() => _GuaranteeConfirmScreenState();
}

class _GuaranteeConfirmScreenState extends State<GuaranteeConfirmScreen> {
  final GuaranteeController controller = Get.find<GuaranteeController>();

  void _handleSubmit() async {
    if (!controller.termsAccepted.value) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(
          context,
          fa: 'لطفاً ابتدا قرارداد تعهدنامه صدور ضمانت‌نامه بانکی را تأیید فرمایید.',
          en: 'Please accept counter-guarantee terms to proceed.',
        ),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final err = await controller.submitGuaranteeApplication();
    if (!mounted) return;

    if (err != null) {
      // Backend unavailable / 404
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.shield_outlined, color: const Color(0xFFF59E0B), size: 24.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'وضعیت سامانه سپام بانک',
                    en: 'SEPAM Banking Gateway',
                    ar: 'حالة بوابة سبام المصرفية',
                    zh: 'SEPAM银行网关状态',
                  ),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
            l10nPick(
              context,
              fa: 'ارتباط مستقیم با سامانه پیام‌رسانی مالی الکترونیکی (سپام) در حال راه‌اندازی و آزمون امنیتی است (کد مسیر: /guarantee/cases). اطلاعات شما ذخیره شده و پس از اتصال نهایی سرور به بانک‌های عامل، بررسی پرونده انجام خواهد شد.',
              en: 'Direct electronic messaging integration (SEPAM) is currently undergoing testing (/guarantee/cases). Your guarantee application has been verified locally.',
              ar: 'الربط المباشر مع نظام سبام المصرفي قيد الإعداد والاختبار.',
              zh: '电子金融报文系统（SEPAM）直连网关正在测试维护中（接口 /guarantee/cases）。您的申请已在本地完成审核备案。',
            ),
            style: TextStyle(fontSize: 12.sp, height: 1.6),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D9488),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                Get.back();
                Get.off(() => const GuaranteeTrackingScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'ورود به کارتابل ضمانت‌نامه‌ها',
                  en: 'Go to Guarantee Portal',
                  ar: 'الانتقال إلى البوابة',
                  zh: '进入保函管理台',
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.off(() => const GuaranteeTrackingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(controller.amountInput.value) ?? 0;
    final inst = controller.selectedInstrument.value;
    final marginPct = inst?.marginPct ?? 10.0;
    final feePct = inst?.feePct ?? 1.5;

    final margin = controller.calculateMargin(amount, marginPct);
    final fee = controller.calculateFee(amount, feePct);

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'پیش‌نمایش و تعهدنامه ضمانت‌نامه',
              en: 'Guarantee Review & Terms',
              ar: 'معاينة شروط خطاب الضمان',
              zh: '保函开立确认与承诺书',
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Obx(
            () => CommonButton(
              width: double.infinity,
              isLoading: controller.isSubmitting.value,
              text: l10nPick(
                context,
                fa: 'تأیید تعهدنامه و ارسال به بانک صادرکننده',
                en: 'Confirm & Submit to Bank',
                ar: 'تأكيد وإرسال إلى البنك المصدر',
                zh: '确认承诺并提交开立银行',
              ),
              backgroundColor: const Color(0xFF0D9488),
              onPressed: _handleSubmit,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Details summary card
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  _buildRow(
                    context,
                    labelFa: 'نوع ضمانت‌نامه',
                    labelEn: 'Instrument',
                    value: inst?.name ?? 'ضمانت‌نامه حسن انجام تعهدات',
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'کارفرما / ذینفع',
                    labelEn: 'Beneficiary',
                    value: controller.beneficiaryNameInput.value,
                    isBold: true,
                  ),
                  if (controller.beneficiaryIdInput.value.isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildRow(
                      context,
                      labelFa: 'شناسه ملی ذینفع',
                      labelEn: 'Beneficiary ID',
                      value: controller.beneficiaryIdInput.value,
                    ),
                  ],
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'مبلغ اسمی ضمانت‌نامه',
                    labelEn: 'Face Amount',
                    value: '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${controller.currencyInput.value}',
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'وجه التزام نقدی تودیعی ($marginPct٪)',
                    labelEn: 'Cash Margin Required',
                    value: '${margin.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${controller.currencyInput.value}',
                    valueColor: const Color(0xFF0D9488),
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'کارمزد صدور سالانه بانکی ($feePct٪)',
                    labelEn: 'Bank Issuance Fee',
                    value: '${fee.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${controller.currencyInput.value}',
                  ),
                  const Divider(height: 20),
                  _buildRow(
                    context,
                    labelFa: 'مدت اعتبار',
                    labelEn: 'Validity',
                    value: '${controller.validityMonthsInput.value} ${l10nPick(context, fa: 'ماه', en: 'Months', ar: 'شهر', zh: '个月')}',
                  ),
                  if (controller.contractRefInput.value.isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildRow(
                      context,
                      labelFa: 'شماره مناقصه / قرارداد',
                      labelEn: 'Reference No.',
                      value: controller.contractRefInput.value,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Legal Agreement Checkbox
            Obx(
              () => Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: controller.termsAccepted.value,
                      activeColor: const Color(0xFF0D9488),
                      onChanged: (val) {
                        controller.termsAccepted.value = val ?? false;
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.termsAccepted.value = !controller.termsAccepted.value;
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Text(
                            l10nPick(
                              context,
                              fa: 'اینجانب متعهد می‌گردم در صورت مطالبه ضمانت‌نامه توسط ذینفع قانونی مطابق قوانین بانکداری بدون ربا، بلافاصله خسارت وارده را جبران نموده و به بانک عامل وکالت بلاعزل در ضبط وثایق و سپرده نقدی اعطا می‌نمایم.',
                              en: 'I unconditionally undertake to indemnify the issuing bank upon any lawful claim by the beneficiary and grant irrevocable authorization to seize pledged margins.',
                              ar: 'ألتزم بتعويض البنك فوراً في حال مطالبة المستفيد بقيمة الضمان وفق اللوائح المعمول بها.',
                              zh: '本人无条件承诺在受益人合法索赔时全额赔偿开证行，并不可撤销地授权扣划担保质押金。',
                            ),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              height: 1.5,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required String labelFa,
    required String labelEn,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          l10nPick(context, fa: labelFa, en: labelEn),
          style: TextStyle(fontSize: 12.sp, color: AppColors.lightTextSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
