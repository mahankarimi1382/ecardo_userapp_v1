import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../app/constants/app_colors.dart';
import '../../app/constants/app_spacing.dart';
import '../../helper/l10n_pick.dart';
import '../controllers/visa_controller.dart';
import '../models/visa_models.dart';
import '../widgets/visa_widgets.dart';
import 'visa_detail_screen.dart';

class VisaPaymentScreen extends StatelessWidget {
  final VisaRequestModel request;

  const VisaPaymentScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<VisaController>()
        ? Get.find<VisaController>()
        : Get.put(VisaController());

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(context, en: 'Visa Payment', fa: 'پرداخت هزینه ویزا'),
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final isPaying = controller.isPaying.value;

        return Stack(
          children: [
            ListView(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.lg.w,
                vertical: AppSpacing.lg.h,
              ),
              children: [
                // Case & Destination Summary
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              VisaCountryFlag(flagUrl: request.countryFlag, size: 36),
                              SizedBox(width: AppSpacing.sm.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    request.countryName,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  Text(
                                    request.visaTitle,
                                    style: TextStyle(
                                      fontSize: 11.5.sp,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          VisaStatusBadge(status: request.status),
                        ],
                      ),
                      Divider(
                        height: AppSpacing.xxl,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Case Tracking No.', fa: 'شماره پیگیری پرونده:'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              request.caseNo,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Applicant Name:', fa: 'نام متقاضی:'),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          Text(
                            request.applicantName,
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),

                // Payment Breakdown Card
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Fee Breakdown', fa: 'ریز هزینه‌های قابل پرداخت'),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),

                      // Row 1: Service Fee
                      _costItem(
                        context,
                        isDark: isDark,
                        title: l10nPick(context, en: '1. Platform Service Fee', fa: '۱. هزینه خدمات و کارشناسی پرونده'),
                        subtitle: l10nPick(context, en: 'Application audit, translation check, and tracking', fa: 'بررسی مدارک، فرم‌بندی و پیگیری اختصاصی'),
                        amount: '\$${request.serviceFee.toStringAsFixed(2)}',
                      ),
                      Divider(
                        height: AppSpacing.xxl,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),

                      // Row 2: Gov Fee
                      _costItem(
                        context,
                        isDark: isDark,
                        title: l10nPick(context, en: '2. Embassy & Government Fee', fa: '۲. تعرفه رسمی سفارت و اداره مهاجرت'),
                        subtitle: l10nPick(context, en: 'Official immigration authority fee for issuance', fa: 'تعرفه مستقیم مراجع صادرکننده ویزا'),
                        amount: '\$${request.govFee.toStringAsFixed(2)}',
                      ),
                      Divider(
                        height: AppSpacing.xxl,
                        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                      ),

                      // Total Row
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.r),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.infoContainer,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Total Amount to Pay:', fa: 'کل مبلغ قابل پرداخت:'),
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.deepBlack,
                              ),
                            ),
                            Text(
                              '\$${request.totalFee.toStringAsFixed(2)} ${request.currency}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.lg.h),

                // Payment Method Card
                VisaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Payment Method', fa: 'روش پرداخت'),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.r),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                          border: Border.all(
                            color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(AppSpacing.sm.r),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkPrimaryContainer : AppColors.infoContainer,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet_rounded,
                                color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                                size: AppSpacing.iconSm.r,
                              ),
                            ),
                            SizedBox(width: AppSpacing.md.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10nPick(context, en: 'eCardo Multi-Currency Wallet', fa: 'کیف پول چندارزی eCardo'),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    l10nPick(context, en: 'Instant debit with double-entry ledger lock', fa: 'کسر آنی با ضمانت بازگشت و ایمنی کامل'),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.check_circle_rounded,
                              color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xl.h),

                // Security & Refund Policy Note
                Container(
                  padding: EdgeInsets.all(AppSpacing.md.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.success.withValues(alpha: 0.15) : AppColors.successContainer,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.security_rounded, color: AppColors.success, size: 20.r),
                      SizedBox(width: AppSpacing.sm.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Protection Guarantee: If documents are rejected during our consultant pre-review, your payment will be refunded 100% to your wallet.',
                            fa: 'ضمانت بازگشت وجه: در صورت عدم تایید اولیه مدارک توسط کارشناسان پیش از ارسال رسمی، مبلغ ۱۰۰٪ به کیف پول بازگردانده می‌شود.',
                          ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: AppColors.success,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpacing.xxxl.h),
              ],
            ),

            if (isPaying)
              Container(
                color: AppColors.black.withValues(alpha: 0.35),
                child: Center(
                  child: CircularProgressIndicator(
                    color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                  ),
                ),
              ),
          ],
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.lg.w,
          vertical: AppSpacing.md.h,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () async {
              HapticFeedback.lightImpact();
              final ok = await controller.payForRequest(request.caseNo);
              if (ok) {
                Get.off(() => VisaDetailScreen(caseNo: request.caseNo));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              padding: EdgeInsets.symmetric(vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 18),
                SizedBox(width: AppSpacing.sm.w),
                Text(
                  '${l10nPick(context, en: 'Pay', fa: 'پرداخت')} \$${request.totalFee.toStringAsFixed(2)} ${request.currency}',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _costItem(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String subtitle,
    required String amount,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}
