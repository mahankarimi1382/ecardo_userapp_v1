import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/controller/p2p_order_details_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;

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
    if (controller.isBuy) {
      return _buildBuyStatusTitle();
    }

    return _buildSellStatusTitle();
  }

  Widget _buildBuyStatusTitle() {
    final localization = AppLocalizations.of(Get.context!)!;
    final status = (data.status ?? '').toLowerCase();
    final orderNumber = data.orderNumber ?? '--';

    switch (status) {
      case 'pending_payment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${localization.p2pOrderCreatedPayTheSellerWithin}\n',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    TextSpan(
                      text: controller.countdownText,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' min',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Text(
                  '${localization.p2pOrderNumber}: ',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                  ),
                ),
                Flexible(
                  child: Text(
                    orderNumber,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: orderNumber));
                    ToastHelper().showSuccessToast(
                      localization.p2pOrderNumberCopied,
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    size: 14.w,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ],
            ),
          ],
        );
      case 'completed':
        return _OrderStatusBlock(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          title: localization.p2pOrderCompleted,
          description: '${localization.p2pOrderNumber}: $orderNumber',
        );
      case 'cancelled':
        return _OrderStatusBlock(
          icon: Icons.cancel_rounded,
          iconColor: AppColors.error,
          title: localization.p2pOrderCancelled,
          titleColor: AppColors.error,
          description: '${localization.p2pOrderNumber}: $orderNumber',
        );
      case 'paid':
        return _OrderStatusBlock(
          icon: Icons.watch_later_rounded,
          iconColor: AppColors.lightPrimary,
          title: localization.p2pPendingRelease,
          description: '${localization.p2pOrderNumber}: $orderNumber',
        );
      case 'disputed':
        return _OrderStatusBlock(
          icon: Icons.gpp_bad_rounded,
          iconColor: AppColors.error,
          title: localization.p2pOrderDisputed,
          description: localization.p2pSellerFundsLockedInEscrow,
        );
      case 'expired':
        return _OrderStatusBlock(
          icon: Icons.timer_off_rounded,
          iconColor: AppColors.error,
          title: localization.p2pOrderExpired,
          description: localization.p2pPaymentNotCompletedInAllowedTime,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSellStatusTitle() {
    final localization = AppLocalizations.of(Get.context!)!;
    final status = (data.status ?? '').toLowerCase();
    final orderNumber = data.orderNumber ?? '--';

    switch (status) {
      case 'pending_payment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '${localization.p2pBuyerHasNotPaidYetPaymentDueWithin}\n',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    TextSpan(
                      text: controller.countdownText,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: AppColors.lightPrimary,
                      ),
                    ),
                    TextSpan(
                      text: ' min',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Text(
                  '${localization.p2pOrderNumber}: ',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 12.sp,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                  ),
                ),
                Flexible(
                  child: Text(
                    orderNumber,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.sp,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: orderNumber));
                    ToastHelper().showSuccessToast(
                      localization.p2pOrderNumberCopied,
                    );
                  },
                  child: Icon(
                    Icons.copy_rounded,
                    size: 14.w,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ],
            ),
          ],
        );
      case 'completed':
        return _OrderStatusBlock(
          icon: Icons.check_circle_rounded,
          iconColor: AppColors.success,
          title: localization.p2pOrderCompleted,
          description: '${localization.p2pOrderNumber}: $orderNumber',
        );
      case 'cancelled':
        return _OrderStatusBlock(
          icon: Icons.cancel_rounded,
          iconColor: AppColors.error,
          title: localization.p2pOrderCancelled,
          titleColor: AppColors.error,
          description: '${localization.p2pOrderNumber}: $orderNumber',
        );
      case 'paid':
        return _OrderStatusBlock(
          icon: Icons.payments_rounded,
          iconColor: AppColors.lightPrimary,
          title: localization.p2pBuyerMarkedAsPaid,
          description: '${localization.p2pOrderNumber}: $orderNumber',
        );
      case 'disputed':
        return _OrderStatusBlock(
          icon: Icons.gpp_bad_rounded,
          iconColor: AppColors.error,
          title: localization.p2pOrderDisputed,
          description: localization.p2pYourLockedAssetsInEscrow,
        );
      case 'expired':
        return _OrderStatusBlock(
          icon: Icons.timer_off_rounded,
          iconColor: AppColors.error,
          title: localization.p2pOrderExpired,
          description: localization.p2pBuyerDidNotCompletePaymentInAllowedTime,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _OrderStatusBlock extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;
  final Color? titleColor;

  const _OrderStatusBlock({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor.withValues(alpha: 0.12),
          ),
          child: Icon(icon, size: 18.w, color: iconColor),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                  color: titleColor ?? AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                description,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w500,
                  fontSize: 12.sp,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
