import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
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
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            // Success Card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.green.shade600, size: 48.sp),
                  SizedBox(height: 10.h),
                  Text(
                    l10nPick(context, en: 'Payment Confirmed & Key Issued!', fa: 'پرداخت تأیید شد و کلید صادر گردید!'),
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: Colors.green.shade900),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Order #${widget.order.orderNo}',
                    style: TextStyle(fontSize: 12.sp, color: Colors.green.shade700),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // License Key Prominent Box
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
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
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.lightPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          widget.order.edition,
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.lightPrimary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 14.h),

                  // Key box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      widget.order.licenseKey ?? widget.order.keyMasked ?? 'XXXX-XXXX-XXXX-XXXX',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace',
                        letterSpacing: 1.2,
                        color: AppColors.lightTextPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 14.h),

                  // Copy Key Button (BTN_COPY_KEY)
                  CommonButton(
                    width: double.infinity,
                    height: 44,
                    backgroundColor: AppColors.lightPrimary,
                    text: l10nPick(
                      context,
                      en: 'Copy Key',
                      fa: 'کپی کلید',
                      ar: 'نسخ المفتاح',
                      zh: '复制密钥',
                    ),
                    onPressed: () {
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
            SizedBox(height: 20.h),

            // Activation Guide Card
            Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 20.sp, color: AppColors.lightPrimary),
                      SizedBox(width: 8.w),
                      Text(
                        l10nPick(context, en: 'How to Activate', fa: 'راهنمای فعال‌سازی'),
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    l10nPick(
                      context,
                      en: '1. Launch your software or open activation settings.\n2. Enter the license key copied above.\n3. Confirm online activation.',
                      fa: '۱. نرم‌افزار را اجرا کرده و وارد منوی فعال‌سازی شوید.\n۲. کلید کپی‌شده در بالا را وارد نمایید.\n۳. فعال‌سازی اینترنتی را تکمیل کنید.',
                    ),
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade700, height: 1.5),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),

            // Confirm Activation Button (BTN_CONFIRM_ACTIVATION)
            CommonButton(
              width: double.infinity,
              text: l10nPick(
                context,
                en: 'Confirm Activation',
                fa: 'فعال‌سازی انجام شد',
                ar: 'تم التفعيل',
                zh: '确认激活',
              ),
              onPressed: () async {
                final ok = await controller.confirmActivation(widget.order.id);
                if (ok) {
                  Get.back();
                }
              },
            ),
            SizedBox(height: 12.h),

            // Report Issue / Dispute Button (BTN_REPORT_ISSUE)
            TextButton.icon(
              icon: Icon(Icons.report_problem_outlined, size: 18.sp, color: Colors.amber.shade800),
              label: Text(
                l10nPick(
                  context,
                  en: 'Report Issue / Dispute',
                  fa: 'ثبت اختلاف و گزارش مشکل',
                  ar: 'الإبلاغ عن مشكلة',
                  zh: '报告问题',
                ),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: Colors.amber.shade800),
              ),
              onPressed: () {
                Get.to(() => LicenseDisputeScreen(order: widget.order));
              },
            ),
          ],
        ),
      ),
    );
  }
}
