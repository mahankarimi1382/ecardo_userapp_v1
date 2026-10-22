import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;

/// Elevated P2P Order Details Header Block:
/// 1. Escrow Security Shield header ("Escrow Protected / تحت پوشش امانی")
/// 2. Real-time countdown timer (15:00 min window to pay or release)
/// 3. Crisp order status summary with one-tap copy order number
class OrderDetailsTitleBlockWidget extends StatelessWidget {
  final order_details.Data data;
  final P2pOrderDetailsController controller;

  const OrderDetailsTitleBlockWidget({
    super.key,
    required this.data,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Escrow Security Shield Header
        _buildEscrowSecurityBanner(context, isDark),
        SizedBox(height: 14.h),

        // 2. Real-time Countdown Timer & Status Header
        controller.isBuy
            ? _buildBuyStatusTitle(context, isDark)
            : _buildSellStatusTitle(context, isDark),
      ],
    );
  }

  /// Escrow Security Shield Header ("Escrow Protected / تحت پوشش امانی")
  Widget _buildEscrowSecurityBanner(BuildContext context, bool isDark) {
    final emeraldGreen = AppColors.success;
    final cardBg = isDark
        ? AppColors.darkSecondaryContainer
        : AppColors.successContainer;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final textHeading = isDark ? AppColors.white : AppColors.deepBlack;
    final textSub = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(color: borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: emeraldGreen.withValues(alpha: isDark ? 0.15 : 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Shield Icon Container with Glow
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: emeraldGreen.withValues(alpha: isDark ? 0.25 : 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: emeraldGreen.withValues(alpha: isDark ? 0.5 : 0.3),
              ),
            ),
            child: Icon(Icons.shield_rounded, size: 20.r, color: emeraldGreen),
          ),
          SizedBox(width: 12.w),

          // Title & Description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Escrow Protected',
                        fa: 'تحت پوشش امانی',
                      ),
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        fontSize: 13.5.sp,
                        color: textHeading,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 1.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: emeraldGreen,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs.r,
                        ),
                      ),
                      child: Text(
                        '100% SAFE',
                        style: TextStyle(
                          letterSpacing: 0.5,
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.h),
                Text(
                  l10nPick(
                    context,
                    en: 'Crypto held securely in eCardo Escrow until verified.',
                    fa: 'ارز دیجیتال تا زمان تایید نهایی پرداخت، در صندوق امانی اکاردو محفوظ است.',
                  ),
                  style: TextStyle(
                    letterSpacing: 0,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: textSub,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Buyer Status Header & Countdown
  Widget _buildBuyStatusTitle(BuildContext context, bool isDark) {
    final localization = AppLocalizations.of(context)!;
    final status = (data.status ?? '').toLowerCase();
    final orderNumber = data.orderNumber ?? '--';

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    switch (status) {
      case 'pending_payment':
        return _buildCountdownCard(
          context: context,
          isDark: isDark,
          title: localization.p2pOrderCreatedPayTheSellerWithin,
          orderNumber: orderNumber,
        );
      case 'paid':
        return _OrderStatusBlock(
          icon: Icons.hourglass_top_rounded,
          iconColor: const Color(0xFF3B82F6),
          title: localization.p2pPendingRelease,
          description: l10nPick(
            context,
            en: 'Waiting for seller to confirm payment and release crypto.',
            fa: 'در انتظار تایید پرداخت توسط فروشنده و آزادسازی ارز دیجیتال.',
          ),
          orderNumber: orderNumber,
        );
      case 'completed':
        return _OrderStatusBlock(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF10B981),
          title: localization.p2pOrderCompleted,
          description: l10nPick(
            context,
            en: 'Crypto has been released to your funding wallet.',
            fa: 'ارز دیجیتال با موفقیت به کیف پول شما واریز شد.',
          ),
          orderNumber: orderNumber,
        );
      case 'cancelled':
        return _OrderStatusBlock(
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFEF4444),
          title: localization.p2pOrderCancelled,
          titleColor: const Color(0xFFEF4444),
          description: l10nPick(
            context,
            en: 'This order was cancelled.',
            fa: 'این سفارش لغو شد.',
          ),
          orderNumber: orderNumber,
        );
      case 'disputed':
        return _OrderStatusBlock(
          icon: Icons.gpp_bad_rounded,
          iconColor: const Color(0xFFEF4444),
          title: localization.p2pOrderDisputed,
          description: localization.p2pSellerFundsLockedInEscrow,
          orderNumber: orderNumber,
        );
      case 'expired':
        return _OrderStatusBlock(
          icon: Icons.timer_off_rounded,
          iconColor: const Color(0xFFEF4444),
          title: localization.p2pOrderExpired,
          description: localization.p2pPaymentNotCompletedInAllowedTime,
          orderNumber: orderNumber,
        );
      default:
        return _buildOrderNumberRow(
          context,
          orderNumber,
          textPrimary,
          textSecondary,
        );
    }
  }

  /// Seller Status Header & Countdown
  Widget _buildSellStatusTitle(BuildContext context, bool isDark) {
    final localization = AppLocalizations.of(context)!;
    final status = (data.status ?? '').toLowerCase();
    final orderNumber = data.orderNumber ?? '--';

    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    switch (status) {
      case 'pending_payment':
        return _buildCountdownCard(
          context: context,
          isDark: isDark,
          title: localization.p2pBuyerHasNotPaidYetPaymentDueWithin,
          orderNumber: orderNumber,
        );
      case 'paid':
        return _OrderStatusBlock(
          icon: Icons.payments_rounded,
          iconColor: const Color(0xFF10B981),
          title: localization.p2pBuyerMarkedAsPaid,
          description: l10nPick(
            context,
            en: 'Please verify the funds in your bank account before releasing.',
            fa: 'لطفاً پیش از آزادسازی ارز، واریز وجه به حساب بانکی خود را بررسی کنید.',
          ),
          orderNumber: orderNumber,
        );
      case 'completed':
        return _OrderStatusBlock(
          icon: Icons.check_circle_rounded,
          iconColor: const Color(0xFF10B981),
          title: localization.p2pOrderCompleted,
          description: l10nPick(
            context,
            en: 'Order completed and crypto released to buyer.',
            fa: 'سفارش تکمیل شد و ارز دیجیتال برای خریدار آزاد گردید.',
          ),
          orderNumber: orderNumber,
        );
      case 'cancelled':
        return _OrderStatusBlock(
          icon: Icons.cancel_rounded,
          iconColor: const Color(0xFFEF4444),
          title: localization.p2pOrderCancelled,
          titleColor: const Color(0xFFEF4444),
          description: l10nPick(
            context,
            en: 'This order was cancelled.',
            fa: 'این سفارش لغو شد.',
          ),
          orderNumber: orderNumber,
        );
      case 'disputed':
        return _OrderStatusBlock(
          icon: Icons.gpp_bad_rounded,
          iconColor: const Color(0xFFEF4444),
          title: localization.p2pOrderDisputed,
          description: localization.p2pYourLockedAssetsInEscrow,
          orderNumber: orderNumber,
        );
      case 'expired':
        return _OrderStatusBlock(
          icon: Icons.timer_off_rounded,
          iconColor: const Color(0xFFEF4444),
          title: localization.p2pOrderExpired,
          description: localization.p2pBuyerDidNotCompletePaymentInAllowedTime,
          orderNumber: orderNumber,
        );
      default:
        return _buildOrderNumberRow(
          context,
          orderNumber,
          textPrimary,
          textSecondary,
        );
    }
  }

  /// Real-Time Countdown Hero Card
  Widget _buildCountdownCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String orderNumber,
  }) {
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Countdown Row with Clock Icon
          Obx(() {
            final remaining = controller.remainingDuration.value;
            final isUrgent = remaining.inMinutes < 3;
            final isWarning = remaining.inMinutes < 6 && !isUrgent;

            final timerColor = isUrgent
                ? const Color(0xFFEF4444)
                : isWarning
                ? const Color(0xFFF59E0B)
                : const Color(0xFF10B981);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 5.h,
                  ),
                  decoration: BoxDecoration(
                    color: timerColor.withValues(alpha: isDark ? 0.20 : 0.12),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    border: Border.all(
                      color: timerColor.withValues(alpha: isDark ? 0.45 : 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.timer_rounded, size: 15.r, color: timerColor),
                      SizedBox(width: 5.w),
                      Text(
                        controller.countdownText,
                        style: TextStyle(
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w900,
                          fontSize: 15.sp,
                          color: timerColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
          SizedBox(height: 10.h),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          SizedBox(height: 10.h),

          // Order Number Row with One-Tap Copy Button
          _buildOrderNumberRow(
            context,
            orderNumber,
            textPrimary,
            textSecondary,
          ),
        ],
      ),
    );
  }

  /// Order Number Row with One-Tap Copy
  Widget _buildOrderNumberRow(
    BuildContext context,
    String orderNumber,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Row(
      children: [
        Text(
          '${l10nPick(context, en: 'Order No', fa: 'شماره سفارش')}: ',
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            fontSize: 12.5.sp,
            color: textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            orderNumber,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              letterSpacing: 0.2,
              fontWeight: FontWeight.w800,
              fontSize: 13.sp,
              color: textPrimary,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.lightImpact();
            Clipboard.setData(ClipboardData(text: orderNumber));
            ToastHelper().showSuccessToast(
              l10nPick(
                context,
                en: 'Order number copied',
                fa: 'شماره سفارش کپی شد',
              ),
            );
          },
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: textSecondary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Icon(
              Icons.copy_rounded,
              size: 14.r,
              color: AppColors.brandViolet,
            ),
          ),
        ),
      ],
    );
  }
}

/// Generic Order Status Block Widget
class _OrderStatusBlock extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final String orderNumber;
  final Color? titleColor;

  const _OrderStatusBlock({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    required this.orderNumber,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final textSecondary = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34.r,
                height: 34.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: isDark ? 0.22 : 0.12),
                ),
                child: Icon(icon, size: 20.r, color: iconColor),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        fontSize: 15.5.sp,
                        color: titleColor ?? textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      description,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                        color: textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Text(
                '${l10nPick(context, en: 'Order No', fa: 'شماره سفارش')}: ',
                style: TextStyle(
                  letterSpacing: 0,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
              Flexible(
                child: Text(
                  orderNumber,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    letterSpacing: 0.2,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Clipboard.setData(ClipboardData(text: orderNumber));
                  ToastHelper().showSuccessToast(
                    l10nPick(
                      context,
                      en: 'Order number copied',
                      fa: 'شماره سفارش کپی شد',
                    ),
                  );
                },
                child: Icon(
                  Icons.copy_rounded,
                  size: 14.r,
                  color: AppColors.brandViolet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
