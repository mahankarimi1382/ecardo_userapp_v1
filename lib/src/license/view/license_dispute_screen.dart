import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    size: AppSpacing.iconMd.sp,
                  ),
                  SizedBox(width: AppSpacing.md.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${widget.order.orderNo}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${widget.order.edition} • ${widget.order.durationMonths} ${l10nPick(context, en: 'Months', fa: 'ماهه', ar: 'شهر', zh: '个月')}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // SLA Banner
            Container(
              padding: EdgeInsets.all(AppSpacing.md.r),
              decoration: BoxDecoration(
                color: (isDark ? AppColors.darkPrimaryContainer : AppColors.lightSecondaryContainer),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.shield_outlined,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    size: AppSpacing.iconSm.sp,
                  ),
                  SizedBox(width: AppSpacing.sm.w),
                  Expanded(
                    child: Text(
                      l10nPick(
                        context,
                        en: '7-Day Buyer Protection: Provider will review and respond within 48 hours with a replacement key or refund.',
                        fa: 'ضمانت ۷ روزه خریدار: کارشناس فروش ظرف ۴۸ ساعت با صدور کلید جایگزین یا عودت وجه پاسخ خواهد داد.',
                        ar: 'حماية المشتري لمدة ٧ أيام مع ضمان استبدال أو استرداد.',
                        zh: '7天买家保障：供应商将在48小时内审核并提供换绑密钥或全额退款。',
                      ),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Fixed Reason Selector
            Text(
              l10nPick(context, en: 'Select Issue Reason', fa: 'علت گزارش مشکل', ar: 'سبب المشكلة', zh: '选择问题原因'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            RadioGroup<String>(
              groupValue: selectedReason,
              onChanged: (val) {
                if (val != null) {
                  HapticFeedback.selectionClick();
                  setState(() => selectedReason = val);
                }
              },
              child: Column(
                children: reasons.map((r) {
                  final isSelected = selectedReason == r['code'];
                  final primaryColor = isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

                  return Container(
                    margin: EdgeInsets.only(bottom: AppSpacing.sm.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? primaryColor.withValues(alpha: 0.08)
                          : (isDark ? AppColors.darkCard : AppColors.lightCard),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                      border: Border.all(
                        color: isSelected
                            ? primaryColor
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: RadioListTile<String>(
                      value: r['code']!,
                      activeColor: primaryColor,
                      title: Text(
                        l10nPick(context, en: r['en']!, fa: r['fa']!),
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? primaryColor
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Description TextField
            Text(
              l10nPick(context, en: 'Detailed Description', fa: 'شرح مشکل و متن خطا', ar: 'الوصف التفصيلي', zh: '详细问题描述'),
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              style: TextStyle(
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontSize: 13.sp,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightCard,
                hintText: l10nPick(
                  context,
                  en: 'Describe the error code or activation failure (min 10 characters)...',
                  fa: 'شرح خطای فعال‌سازی یا کد پیام دریافتی (حداقل ۱۰ کاراکتر)...',
                  ar: 'اكتب تفاصيل رمز الخطأ...',
                  zh: '请描述错误代码或激活失败原因（至少10个字符）...',
                ),
                hintStyle: TextStyle(
                  fontSize: 12.sp,
                  color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),

            // Submit Button (BTN_REPORT_ISSUE)
            CommonButton(
              width: double.infinity,
              isLoading: isSubmitting,
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              textColor: isDark ? AppColors.deepBlack : AppColors.white,
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

                HapticFeedback.lightImpact();
                setState(() => isSubmitting = true);
                final ok = await controller.submitDispute(widget.order.id, selectedReason, desc);
                if (!mounted) return;
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