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
    HapticFeedback.lightImpact();
    if (!controller.termsAccepted.value) {
      Get.snackbar(
        l10nPick(context, fa: 'خطا', en: 'Error'),
        l10nPick(
          context,
          fa: 'لطفاً ابتدا تفاهم‌نامه و شرایط دریافت تسهیلات را تأیید فرمایید.',
          en: 'Please accept terms and conditions to proceed.',
        ),
        backgroundColor: AppColors.error,
        colorText: AppColors.white,
      );
      return;
    }

    final err = await controller.applyForLoan();
    if (!mounted) return;

    if (err != null) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r)),
          title: Row(
            children: [
              Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 24.sp),
              SizedBox(width: AppSpacing.sm.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    fa: 'وضعیت درگاه تسهیلات',
                    en: 'Credit Gateway Status',
                    ar: 'حالة بوابة التسهيلات',
                    zh: '信贷网关状态',
                  ),
                  style: AppTextStyles.titleSmall.copyWith(fontWeight: FontWeight.w800),
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
            style: AppTextStyles.bodySmall.copyWith(height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.back();
              },
              child: Text(l10nPick(context, fa: 'متوجه شدم', en: 'Understood', ar: 'حسناً', zh: '知道了')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
              ),
              onPressed: () {
                HapticFeedback.lightImpact();
                Get.back();
                Get.off(() => const LoanTrackingScreen());
              },
              child: Text(
                l10nPick(context, fa: 'مشاهده کارتابل', en: 'View Dashboard', ar: 'لوحة المتابعة', zh: '查看进度'),
                style: const TextStyle(color: AppColors.white),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.off(() => const LoanTrackingScreen());
      Get.snackbar(
        l10nPick(context, fa: 'ثبت موفق', en: 'Application Submitted', ar: 'تم التسجيل', zh: '提交成功'),
        l10nPick(
          context,
          fa: 'درخواست تسهیلات شما با موفقیت ثبت شد و در فرآیند سنجش اعتبار قرار گرفت.',
          en: 'Loan application submitted successfully and sent for credit scoring.',
          ar: 'تم تقديم الطلب بنجاح وهو قيد التقييم الائتماني.',
          zh: '您的贷款申请已成功提交并进入信用评级流程。',
        ),
        backgroundColor: AppColors.success,
        colorText: AppColors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryAccent = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final amount = double.tryParse(controller.amountInput.value) ?? 50000000;
    final tenure = controller.selectedTenure.value > 0 ? controller.selectedTenure.value : 12;
    final grace = controller.graceMonthsInput.value;
    final rate = controller.selectedProduct.value?.baseRateAnnual ?? 18.0;

    final emi = controller.calculateMonthlyInstallment(
      principal: amount,
      annualInterestRatePct: rate,
      tenureMonths: tenure,
      gracePeriodMonths: grace,
    );

    final total = controller.calculateTotalRepayment(
      principal: amount,
      annualInterestRatePct: rate,
      tenureMonths: tenure,
      gracePeriodMonths: grace,
    );

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
          padding: EdgeInsetsDirectional.all(AppSpacing.page.w),
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
              backgroundColor: primaryAccent,
              onPressed: _handleSubmit,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsDirectional.symmetric(horizontal: AppSpacing.page.w, vertical: AppSpacing.md.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Card
            Container(
              padding: EdgeInsetsDirectional.all(AppSpacing.lg.w),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    isDark: isDark,
                    labelFa: 'طرح انتخابی',
                    labelEn: 'Selected Scheme',
                    value: controller.selectedProduct.value?.name ?? 'تسهیلات هوشمند زرین',
                    isBold: true,
                  ),
                  Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildSummaryRow(
                    context,
                    isDark: isDark,
                    labelFa: 'مبلغ درخواستی',
                    labelEn: 'Requested Amount',
                    value: '${amount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔')}',
                    isBold: true,
                  ),
                  Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildSummaryRow(
                    context,
                    isDark: isDark,
                    labelFa: 'مدت بازپرداخت',
                    labelEn: 'Tenure',
                    value: '$tenure ${l10nPick(context, fa: 'ماه', en: 'Months', ar: 'شهر', zh: '个月')}',
                  ),
                  if (grace > 0) ...[
                    Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _buildSummaryRow(
                      context,
                      isDark: isDark,
                      labelFa: 'دوره تنفس',
                      labelEn: 'Grace Period',
                      value: '$grace ${l10nPick(context, fa: 'ماه (فقط پرداخت سود)', en: 'Months (Interest only)', ar: 'شهر (فائدة فقط)', zh: '个月（仅还利息）')}',
                    ),
                  ],
                  Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildSummaryRow(
                    context,
                    isDark: isDark,
                    labelFa: 'نرخ سود سالیانه',
                    labelEn: 'Annual Interest Rate',
                    value: '$rate%',
                  ),
                  Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildSummaryRow(
                    context,
                    isDark: isDark,
                    labelFa: 'قسط ماهیانه تخمینی',
                    labelEn: 'Monthly Installment (EMI)',
                    value: '${emi.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔')}',
                    valueColor: isDark ? const Color(0xFF4ADE80) : const Color(0xFF059669),
                    isBold: true,
                  ),
                  Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildSummaryRow(
                    context,
                    isDark: isDark,
                    labelFa: 'مجموع بازپرداخت اصل و سود',
                    labelEn: 'Total Repayment',
                    value: '${total.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} ${l10nPick(context, fa: 'ریال', en: 'IRR', ar: 'ريال', zh: '里亚尔')}',
                  ),
                  Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                  _buildSummaryRow(
                    context,
                    isDark: isDark,
                    labelFa: 'نوع وثیقه تودیعی',
                    labelEn: 'Collateral Type',
                    value: controller.collateralTypeInput.value,
                  ),
                  if (controller.purposeInput.value.isNotEmpty) ...[
                    Divider(height: 20, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                    _buildSummaryRow(
                      context,
                      isDark: isDark,
                      labelFa: 'موضوع تسهیلات',
                      labelEn: 'Loan Purpose',
                      value: controller.purposeInput.value,
                    ),
                  ],
                ],
              ),
            ),

            SizedBox(height: AppSpacing.lg.h),

            // Terms & Conditions checkbox
            Obx(
              () => Container(
                padding: EdgeInsetsDirectional.all(AppSpacing.md.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: controller.termsAccepted.value,
                      activeColor: primaryAccent,
                      onChanged: (val) {
                        HapticFeedback.selectionClick();
                        controller.termsAccepted.value = val ?? false;
                      },
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          controller.termsAccepted.value = !controller.termsAccepted.value;
                        },
                        child: Padding(
                          padding: EdgeInsetsDirectional.only(top: 8.h),
                          child: Text(
                            l10nPick(
                              context,
                              fa: 'اینجانب صحت اطلاعات ثبت‌شده را تأیید نموده و شرایط و ضوابط عمومی تخصیص اعتبار، استعلام رتبه اعتباری از بانک مرکزی و کسر اقساط از کیف پول را می‌پذیرم.',
                              en: 'I confirm the veracity of provided information and accept credit assignment terms, central bank scoring inquiry, and automatic wallet installment deductions.',
                              ar: 'أؤكد صحة البيانات وأوافق على الشروط واستعلام السجل الائتماني وسداد الأقساط.',
                              zh: '本人确认所填信息真实无误，同意授信条款、征信查询及分期自动代扣协议。',
                            ),
                            style: AppTextStyles.bodySmall.copyWith(
                              height: 1.5,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required bool isDark,
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
          style: AppTextStyles.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: valueColor ?? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ),
      ],
    );
  }
}
