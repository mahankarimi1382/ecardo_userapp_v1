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
import 'license_dispute_screen.dart';

class LicenseDeliveryScreen extends StatefulWidget {
  final LicenseOrderItem order;

  const LicenseDeliveryScreen({super.key, required this.order});

  @override
  State<LicenseDeliveryScreen> createState() => _LicenseDeliveryScreenState();
}

class _LicenseDeliveryScreenState extends State<LicenseDeliveryScreen> {
  final LicenseController controller = Get.find<LicenseController>();

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
              en: 'License Key Issued',
              fa: 'تحویل کلید لایسنس',
              ar: 'مفتاح الترخيص',
              zh: '许可证密钥',
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpacing.lg.r),
        child: Column(
          children: [
            // Success Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpacing.xl.r),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, color: AppColors.success, size: 48.sp),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    l10nPick(context, en: 'Payment Confirmed & Key Issued!', fa: 'پرداخت تأیید شد و کلید صادر گردید!'),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Order #${widget.order.orderNo}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // License Key Prominent Box
            Container(
              padding: EdgeInsets.all(AppSpacing.xl.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10nPick(context, en: 'Your Digital License Key:', fa: 'کلید دیجیتال لایسنس شما:'),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                        ),
                        child: Text(
                          widget.order.edition,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md.h),

                  // Key box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.md.w, vertical: AppSpacing.md.h),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                      border: Border.all(
                        color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
                      ),
                    ),
                    child: Text(
                      widget.order.licenseKey ?? widget.order.keyMasked ?? 'XXXX-XXXX-XXXX-XXXX',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md.h),

                  // Copy Key Button (BTN_COPY_KEY)
                  CommonButton(
                    width: double.infinity,
                    height: 44,
                    backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    textColor: isDark ? AppColors.deepBlack : AppColors.white,
                    text: l10nPick(
                      context,
                      en: 'Copy Key',
                      fa: 'کپی کلید',
                      ar: 'نسخ المفتاح',
                      zh: '复制密钥',
                    ),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      final textToCopy = widget.order.licenseKey ?? widget.order.keyMasked ?? '';
                      Clipboard.setData(ClipboardData(text: textToCopy));
                      ToastHelper().showSuccessToast(l10nPick(
                        context,
                        en: 'License key copied to clipboard!',
                        fa: 'کلید لایسنس در حافظه کپی شد!',
                      ));
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xl.h),

            // Activation Guide Card
            Container(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: AppSpacing.iconSm.sp,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                      SizedBox(width: AppSpacing.sm.w),
                      Text(
                        l10nPick(context, en: 'How to Activate', fa: 'راهنمای فعال‌سازی'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    l10nPick(
                      context,
                      en: '1. Launch your software or open activation settings.\n2. Enter the license key copied above.\n3. Confirm online activation.',
                      fa: '۱. نرم‌افزار را اجرا کرده و وارد منوی فعال‌سازی شوید.\n۲. کلید کپی‌شده در بالا را وارد نمایید.\n۳. فعال‌سازی اینترنتی را تکمیل کنید.',
                    ),
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpacing.xxl.h),

            // Confirm Activation Button (BTN_CONFIRM_ACTIVATION)
            CommonButton(
              width: double.infinity,
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              textColor: isDark ? AppColors.deepBlack : AppColors.white,
              text: l10nPick(
                context,
                en: 'Confirm Activation',
                fa: 'فعال‌سازی انجام شد',
                ar: 'تم التفعيل',
                zh: '确认激活',
              ),
              onPressed: () async {
                HapticFeedback.lightImpact();
                final ok = await controller.confirmActivation(widget.order.id);
                if (ok) {
                  Get.back();
                }
              },
            ),
            SizedBox(height: AppSpacing.md.h),

            // Report Issue / Dispute Button (BTN_REPORT_ISSUE)
            TextButton.icon(
              icon: Icon(Icons.report_problem_outlined, size: 18.sp, color: AppColors.warning),
              label: Text(
                l10nPick(
                  context,
                  en: 'Report Issue / Dispute',
                  fa: 'ثبت اختلاف و گزارش مشکل',
                  ar: 'الإبلاغ عن مشكلة',
                  zh: '报告问题',
                ),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.warning),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                Get.to(() => LicenseDisputeScreen(order: widget.order));
              },
            ),
          ],
        ),
      ),
    );
  }
}