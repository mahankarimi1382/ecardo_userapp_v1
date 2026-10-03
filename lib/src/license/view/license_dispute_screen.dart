import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import '../controller/license_controller.dart';
import '../model/license_models.dart';

class LicenseDisputeScreen extends StatefulWidget {
  final LicenseOrderItem order;

  const LicenseDisputeScreen({super.key, required this.order});

  @override
  State<LicenseDisputeScreen> createState() => _LicenseDisputeScreenState();
}

class _LicenseDisputeScreenState extends State<LicenseDisputeScreen> {
  final LicenseController controller = Get.find<LicenseController>();
  final TextEditingController descriptionController = TextEditingController();

  String selectedReason = 'INVALID_KEY';
  bool isSubmitting = false;

  final reasons = [
    {
      'code': 'INVALID_KEY',
      'en': 'Key is Invalid / Not Recognized',
      'fa': 'کلید نامعتبر است یا توسط نرم‌افزار شناسایی نمی‌شود',
    },
    {
      'code': 'ALREADY_USED',
      'en': 'Key has Already Been Redeemed',
      'fa': 'کلید قبلاً توسط دستگاه یا کاربر دیگری مصرف شده است',
    },
    {
      'code': 'EDITION_MISMATCH',
      'en': 'Edition/Duration Does Not Match Order',
      'fa': 'ویرایش یا مدت لایسنس با سفارش مطابقت ندارد',
    },
    {
      'code': 'AMOUNT_MISMATCH',
      'en': 'Deducted Amount Discrepancy',
      'fa': 'مبلغ کسرشده با فاکتور سفارش مغایرت دارد',
    },
  ];

  @override
  void dispose() {
    descriptionController.dispose();
    super.dispose();
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
              en: 'Report License Issue',
              fa: 'ثبت اختلاف و گزارش نقص لایسنس',
              ar: 'الإبلاغ عن مشكلة',
              zh: '报告问题',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.receipt_long_rounded, color: AppColors.lightPrimary, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${widget.order.orderNo}',
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                        ),
                        Text(
                          '${widget.order.edition} • ${widget.order.durationMonths} Months',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // SLA Banner
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue.shade700, size: 22.sp),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        en: '7-Day Buyer Protection: Provider will review and respond within 48 hours with a replacement key or refund.',
                        fa: 'ضمانت ۷ روزه خریدار: کارشناس فروش ظرف ۴۸ ساعت با صدور کلید جایگزین یا عودت وجه پاسخ خواهد داد.',
                      ),
                      style: TextStyle(fontSize: 11.sp, color: Colors.blue.shade900, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Fixed Reason Selector
            Text(
              l10nPick(context, en: 'Select Issue Reason', fa: 'علت گزارش مشکل'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
            ),
            SizedBox(height: 10.h),
            RadioGroup<String>(
              groupValue: selectedReason,
              onChanged: (val) {
                if (val != null) setState(() => selectedReason = val);
              },
              child: Column(
              children: reasons.map((r) {
                final isSelected = selectedReason == r['code'];
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lightPrimary.withValues(alpha: 0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected ? AppColors.lightPrimary : Colors.grey.shade200,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: RadioListTile<String>(
                    value: r['code']!,
                    activeColor: AppColors.lightPrimary,
                    title: Text(
                      l10nPick(context, en: r['en']!, fa: r['fa']!),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.lightPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            ),
            SizedBox(height: 16.h),

            // Description TextField
            Text(
              l10nPick(context, en: 'Detailed Description', fa: 'شرح مشکل و متن خطا'),
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
            ),
            SizedBox(height: 8.h),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: l10nPick(
                  context,
                  en: 'Describe the error code or activation failure (min 10 characters)...',
                  fa: 'شرح خطای فعال‌سازی یا کد پیام دریافتی (حداقل ۱۰ کاراکتر)...',
                ),
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: const BorderSide(color: AppColors.lightPrimary)),
              ),
            ),
            SizedBox(height: 30.h),

            // Submit Button (BTN_REPORT_ISSUE)
            CommonButton(
              width: double.infinity,
              isLoading: isSubmitting,
              text: l10nPick(
                context,
                en: 'Submit Report',
                fa: 'ثبت اختلاف',
                ar: 'إرسال التقرير',
                zh: '提交报告',
              ),
              onPressed: () async {
                final desc = descriptionController.text.trim();
                if (desc.length < 10) {
                  ToastHelper().showErrorToast(l10nPick(
                    context,
                    en: 'Description must be at least 10 characters.',
                    fa: 'شرح مشکل باید حداقل ۱۰ کاراکتر باشد.',
                  ));
                  return;
                }

                setState(() => isSubmitting = true);
                final ok = await controller.submitDispute(widget.order.id, selectedReason, desc);
                setState(() => isSubmitting = false);
                if (ok) {
                  Get.back();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
