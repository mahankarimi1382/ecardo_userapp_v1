import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/p2p_ad_card.dart';

import '../p2p_appeal_order_screen.dart';

/// World-Class P2P Order Action Buttons:
/// 1. "I have paid" confirmation button with high-security confirmation dialog
/// 2. Seller "Payment Received, Release Crypto" button with balance check dialog
/// 3. Dispute & Cancel Order actions with safety warnings
/// 4. Micro-scale tap interaction and haptics
class OrderDetailsActionButtonsWidget extends StatelessWidget {
  final order_details.Data data;
  final P2pOrderDetailsController controller;

  const OrderDetailsActionButtonsWidget({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final status = (data.status ?? '').toLowerCase();
    final emeraldGreen = const Color(0xFF10B981);
    final rubyRed = const Color(0xFFEF4444);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Seller Actions
    if (!controller.isBuy) {
      switch (status) {
        case 'pending_payment':
          return Column(
            children: [
              Obx(
                () => CommonButton(
                  text: localization.p2pCancelOrder,
                  width: double.infinity,
                  isLoading: controller.isCancellingOrder.value,
                  backgroundColor: AppColors.transparent,
                  textColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  borderWidth: 1.2,
                  onPressed: () => _showCancelConfirmation(),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          );
        case 'paid':
          return Column(
            children: [
              Obx(
                () => MicroScaleTap(
                  onTap: controller.isReleasingOrder.value
                      ? null
                      : () => _showReleaseConfirmation(context),
                  child: Container(
                    height: 48.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: emeraldGreen,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                      boxShadow: [
                        BoxShadow(
                          color: emeraldGreen.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: controller.isReleasingOrder.value
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
                                  SizedBox(width: 8.w),
                                  Flexible(
                                    child: Text(
                                      l10nPick(
                                        context,
                                        en: 'Payment Received, Release Crypto',
                                        fa: 'تایید دریافت وجه و آزادسازی ارز',
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14.sp,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              CommonButton(
                text: localization.p2pDisputeOrder,
                width: double.infinity,
                backgroundColor: AppColors.transparent,
                textColor: rubyRed,
                borderColor: rubyRed.withValues(alpha: 0.5),
                borderWidth: 1.2,
                onPressed: () => _showDisputeReasonBottomSheet(),
              ),
              SizedBox(height: 20.h),
            ],
          );
        default:
          return const SizedBox.shrink();
      }
    }

    // Buyer Actions
    switch (status) {
      case 'pending_payment':
        return Column(
          children: [
            // "I have paid" confirmation button with confirmation dialog
            Obx(
              () => MicroScaleTap(
                onTap: controller.isMarkingPaid.value
                    ? null
                    : () => _showMarkPaidConfirmation(context),
                child: Container(
                  height: 48.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: emeraldGreen,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    boxShadow: [
                      BoxShadow(
                        color: emeraldGreen.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: controller.isMarkingPaid.value
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10.w),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: Text(
                                    l10nPick(
                                      context,
                                      en: 'Transferred, Notify Seller',
                                      fa: 'پرداخت کردم، اطلاع به فروشنده',
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Obx(
              () => CommonButton(
                text: localization.p2pCancelOrder,
                width: double.infinity,
                isLoading: controller.isCancellingOrder.value,
                backgroundColor: AppColors.transparent,
                textColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderWidth: 1.2,
                onPressed: () => _showCancelConfirmation(),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        );
      case 'paid':
        return Column(
          children: [
            Obx(
              () => CommonButton(
                text: localization.p2pDisputeOrder,
                width: double.infinity,
                isLoading: controller.isDisputingOrder.value,
                backgroundColor: rubyRed,
                onPressed: () => _showDisputeReasonBottomSheet(),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// "I have paid" Confirmation Dialog
  void _showMarkPaidConfirmation(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final emeraldGreen = const Color(0xFF10B981);

    final totalPayAmount = data.totalFiatAmount ?? data.fiatAmount ?? '--';
    final isConfirmed = false.obs;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(AppSpacing.radiusXl.r),
                topEnd: Radius.circular(AppSpacing.radiusXl.r),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Handle Bar
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),

                // Security Shield Header
                Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: emeraldGreen.withValues(alpha: isDark ? 0.22 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_user_rounded,
                        size: 22.r,
                        color: emeraldGreen,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Confirm Payment Transfer',
                              fa: 'تایید انتقال وجه و پرداخت',
                            ),
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.sp,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Amount: $totalPayAmount',
                              fa: 'مبلغ پرداختی: $totalPayAmount',
                            ),
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: emeraldGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                SizedBox(height: 14.h),

                // Warning Notice
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.35 : 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 18.r,
                        color: const Color(0xFFF59E0B),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Please ensure you have genuinely transferred the funds. Submitting a false payment confirmation will lead to immediate account suspension.',
                            fa: 'لطفاً اطمینان حاصل کنید که مبلغ را واریز کرده‌اید. اعلام پرداخت نادرست منجر به مسدود شدن فوری حساب کاربری خواهد شد.',
                          ),
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFFDE68A) : const Color(0xFFB45309),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                // Confirmation Checkbox
                Obx(
                  () => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      isConfirmed.value = !isConfirmed.value;
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isConfirmed.value,
                          activeColor: emeraldGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            isConfirmed.value = val ?? false;
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              l10nPick(
                                context,
                                en: 'I confirm that I have transferred the funds from my verified bank account.',
                                fa: 'تایید می‌کنم که مبلغ را شخصاً از حساب بانکی خود واریز کرده‌ام.',
                              ),
                              style: TextStyle(
                                letterSpacing: 0,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: l10nPick(context, en: 'Cancel', fa: 'انصراف'),
                        backgroundColor: AppColors.transparent,
                        textColor: textSecondary,
                        borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        borderWidth: 1.2,
                        onPressed: Get.back,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => CommonButton(
                          text: l10nPick(context, en: 'I Have Paid', fa: 'پرداخت کردم'),
                          backgroundColor: isConfirmed.value
                              ? emeraldGreen
                              : (isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300),
                          textColor: isConfirmed.value ? Colors.white : AppColors.softGray,
                          onPressed: isConfirmed.value
                              ? () {
                                  Get.back();
                                  controller.markOrderPaid();
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        },
      ),
      isScrollControlled: true,
    );
  }

  /// Seller Release Confirmation Dialog
  void _showReleaseConfirmation(BuildContext context) {
    HapticFeedback.lightImpact();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final emeraldGreen = const Color(0xFF10B981);
    final isConfirmed = false.obs;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setState) {
          return Container(
            padding: EdgeInsetsDirectional.fromSTEB(20.w, 16.h, 20.w, 24.h),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(AppSpacing.radiusXl.r),
                topEnd: Radius.circular(AppSpacing.radiusXl.r),
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 44.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkBorder : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                  ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: emeraldGreen.withValues(alpha: isDark ? 0.22 : 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 22.r,
                        color: emeraldGreen,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Release Crypto to Buyer',
                              fa: 'آزادسازی ارز دیجیتال برای خریدار',
                            ),
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              fontSize: 16.sp,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'Amount: ${data.assetAmount ?? '--'}',
                              fa: 'مقدار ارز: ${data.assetAmount ?? '--'}',
                            ),
                            style: TextStyle(
                              letterSpacing: 0,
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.w700,
                              color: emeraldGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),
                Divider(
                  height: 1,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),
                SizedBox(height: 14.h),

                // Warning Notice: Verify balance, not SMS
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: isDark ? 0.35 : 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 18.r,
                        color: const Color(0xFFEF4444),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          l10nPick(
                            context,
                            en: 'CRITICAL: Check your actual bank account balance via mobile banking. Do NOT release solely based on SMS notifications.',
                            fa: 'مهم: حتماً موجودی حساب بانکی خود را از طریق همراه بانک چک کنید. هرگز فقط به پیامک واریز استناد نکنید.',
                          ),
                          style: TextStyle(
                            letterSpacing: 0,
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFFFCA5A5) : const Color(0xFFB91C1C),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 14.h),

                Obx(
                  () => GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      isConfirmed.value = !isConfirmed.value;
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: isConfirmed.value,
                          activeColor: emeraldGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          onChanged: (val) {
                            HapticFeedback.selectionClick();
                            isConfirmed.value = val ?? false;
                          },
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: Text(
                              l10nPick(
                                context,
                                en: 'I have verified that the exact payment is received in my bank account.',
                                fa: 'تایید می‌کنم که مبلغ دقیق را در حساب بانکی خود دریافت کرده‌ام.',
                              ),
                              style: TextStyle(
                                letterSpacing: 0,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 18.h),

                Row(
                  children: [
                    Expanded(
                      child: CommonButton(
                        text: l10nPick(context, en: 'Cancel', fa: 'انصراف'),
                        backgroundColor: AppColors.transparent,
                        textColor: textSecondary,
                        borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        borderWidth: 1.2,
                        onPressed: Get.back,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Obx(
                        () => CommonButton(
                          text: l10nPick(context, en: 'Release Crypto', fa: 'آزادسازی ارز'),
                          backgroundColor: isConfirmed.value
                              ? emeraldGreen
                              : (isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300),
                          textColor: isConfirmed.value ? Colors.white : AppColors.softGray,
                          onPressed: isConfirmed.value
                              ? () {
                                  Get.back();
                                  controller.releaseOrder();
                                }
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showCancelConfirmation() {
    Get.bottomSheet(
      CommonAlertBottomSheet(
        title: AppLocalizations.of(Get.context!)!.p2pCancelOrder,
        message: AppLocalizations.of(Get.context!)!.p2pCancelOrderConfirmation,
        onCancel: Get.back,
        onConfirm: () async {
          Get.back();
          await controller.cancelOrder();
        },
      ),
      isScrollControlled: true,
    );
  }

  void _showDisputeReasonBottomSheet() {
    Get.to(() => P2pAppealOrderScreen(data: data, controller: controller));
  }
}
