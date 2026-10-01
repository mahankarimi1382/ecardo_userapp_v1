import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controllers/loan_controller.dart';
import 'loan_tracking_screen.dart';

/// Review and confirmation screen for the loan request before final dispatch.
class LoanConfirmScreen extends StatefulWidget {
  const LoanConfirmScreen({super.key});

  @override
  State<LoanConfirmScreen> createState() => _LoanConfirmScreenState();
}

class _LoanConfirmScreenState extends State<LoanConfirmScreen> {
  final LoanController controller = Get.find<LoanController>();

  void _handleSubmit() async {
    if (!controller.termsAccepted.value) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(
          context,
          fa: 'لطفاً ابتدا تفاهم‌نامه و شرایط دریافت تسهیلات را تأیید فرمایید.',
          en: 'Please accept terms and conditions to proceed.',
        ),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final err = await controller.applyForLoan();
    if (!mounted) return;

    if (err != null) {
      // Backend returned error or 404
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: const Color(0xFFF59E0B), size: 24.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'وضعیت درگاه تسهیلات',
                    en: 'Credit Gateway Status',
                    ar: 'حالة بوابة التسهيلات',
                    zh: '信贷网关状态',
                  ),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          content: Text(
            l10nPick(
              context,
              fa: 'ارتباط آنلاین با زیرساخت اعتبارسنجی بانکی در حال به‌روزرسانی است (کد اندپوینت: /loan/apply). اطلاعات فرم شما در صف آزمایشی ثبت شد و به محض اتصال مستقیم سرور عملیاتی خواهد شد.',
              en: 'The online banking scoring gateway is undergoing maintenance (endpoint /loan/apply). Your application parameters have been verified locally.',
              ar: 'جاري تحديث الربط المباشر مع بوابة التسهيلات الائتمانية.',
              zh: '信贷评分在线网关正在维护更新中（接口 /loan/apply）。您的申请参数已完成本地校验。',
            ),
            style: TextStyle(fontSize: 12.sp, height: 1.6),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              onPressed: () {
                Get.back();
                Get.off(() => const LoanTrackingScreen());
              },
              child: Text(
                l10nPick(
                  context,
                  fa: 'مشاهده کارتابل پیگیری',
                  en: 'View Tracking Portal',
                  ar: 'عرض بوابة المتابعة',
                  zh: '查看追踪进度',
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      // Successful submission
      Get.off(() => const LoanTrackingScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(controller.amountInput.value) ?? 0;
    final tenure = controller.selectedTenure.value > 0 ? controller.selectedTenure.value : 12;
    final rate = controller.selectedProduct.value?.baseRateAnnual ?? 18.0;

    final emi = controller.calculateMonthlyInstallment(
      principal: amount,
      annualInterestRatePct: rate,
      tenureMonths: tenure,
    );
    final total = emi * tenure;

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.h),
        child: SafeArea(
          child: CommonAppBar(
            title: l10nPick(
              context,
              fa: 'پیش‌نمایش و تأیید نهایی وام',
              en: 'Review & Confirmation',
              ar: 'معاينة وتأكيد التسهيل',
              zh: '审核并最终确认',
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
                fa: 'تأیید و ارسال درخواست به اعتبارسنجی',
                en: 'Confirm & Submit to Scoring',
                ar: 'تأكيد وإرسال إلى التقييم',
                zh: '确认并提交信用审核',
              ),
              backgroundColor: AppColors.lightPrimary,
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
            // Summary Card
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    labelFa: 'طرح انتخابی',
                    labelEn: 'Selected Scheme',
                    value: controller.selectedProduct.value?.name ?? 'تسهیلات هوشمند زرین',
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    context,
                    labelFa: 'مبلغ درخواستی',
                    labelEn: 'Requested Amount',
                    value: '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ' +
                        l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔'),
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    context,
                    labelFa: 'مدت بازپرداخت',
                    labelEn: 'Tenure',
                    value: '$tenure ' + l10nPick(context, fa: 'ماه', en: 'Months', ar: 'شهر', zh: '个月'),
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    context,
                    labelFa: 'نرخ سود سالیانه',
                    labelEn: 'Annual Interest Rate',
                    value: '$rate%',
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    context,
                    labelFa: 'قسط ماهیانه تخمینی',
                    labelEn: 'Monthly Installment (EMI)',
                    value: '${emi.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ' +
                        l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔'),
                    valueColor: const Color(0xFF059669),
                    isBold: true,
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    context,
                    labelFa: 'مجموع بازپرداخت اصل و سود',
                    labelEn: 'Total Repayment',
                    value: '${total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ' +
                        l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔'),
                  ),
                  const Divider(height: 20),
                  _buildSummaryRow(
                    context,
                    labelFa: 'نوع وثیقه تودیعی',
                    labelEn: 'Collateral Type',
                    value: controller.collateralTypeInput.value,
                  ),
                  if (controller.purposeInput.value.isNotEmpty) ...[
                    const Divider(height: 20),
                    _buildSummaryRow(
                      context,
                      labelFa: 'موضوع تسهیلات',
                      labelEn: 'Loan Purpose',
                      value: controller.purposeInput.value,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: 18.h),

            // Terms & Conditions checkbox
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
                      activeColor: AppColors.lightPrimary,
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
                              fa: 'اینجانب صحت اطلاعات ثبت‌شده را تأیید نموده و شرایط و ضوابط عمومی تخصیص اعتبار، استعلام رتبه اعتباری از بانک مرکزی و کسر اقساط از کیف پول را می‌پذیرم.',
                              en: 'I confirm the veracity of provided information and accept credit assignment terms, central bank scoring inquiry, and automatic wallet installment deductions.',
                              ar: 'أؤكد صحة البيانات وأوافق على الشروط واستعلام السجل الائتماني وسداد الأقساط.',
                              zh: '本人确认所填信息真实无误，同意授信条款、征信查询及分期自动代扣协议。',
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

  Widget _buildSummaryRow(
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
