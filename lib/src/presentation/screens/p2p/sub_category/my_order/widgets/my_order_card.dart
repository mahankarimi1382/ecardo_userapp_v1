import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/widgets/p2p_order_details_screen.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/chat/view/order_chat_screen.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/my_order/model/my_order_response_model.dart';

class MyOrderCard extends StatelessWidget {
  final Order order;

  const MyOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final adType = (order.adType ?? '').toLowerCase();
    final isBuy = adType == 'buy';
    final typeColor = isBuy ? AppColors.error : AppColors.success;
    final typeText =
        '${isBuy ? localization.p2pSell : localization.p2pBuy} ${order.adsAssetCurrency ?? ''}'
        .trim();

    final status = _statusLabel(order.status);
    final statusColor = AppColors.white;
    final statusBgColor = _statusColor(order.status);
    final counterPartyName = _counterpartyName(order);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14.w, 12.h, 14.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    typeText,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                      color: typeColor,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14.w, 8.h, 14.w, 0),
            child: Row(
              children: [
                Text(
                  order.orderNumber ?? '--',
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.80),
                  ),
                ),
                SizedBox(width: 6.w),
                GestureDetector(
                  onTap: _copyOrderNumber,
                  child: Image.asset(
                    PngAssets.copyCommonIcon,
                    width: 16.w,
                    color: AppColors.lightPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14.w, 6.h, 14.w, 0),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                _formatDateTime(order.createdAt),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14.w, 14.h, 14.w, 12.h),
            child: Row(
              children: [
                Expanded(
                  child: _buildAmountBlock(
                    title: '${localization.p2pFiat} :',
                    value: (order.fiatAmount ?? '--').trim(),
                    alignEnd: false,
                  ),
                ),
                Expanded(
                  child: _buildAmountBlock(
                    title: '${localization.p2pCryptoAmount}:',
                    value: (order.assetAmount ?? '--').trim(),
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.12),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(14.w, 10.h, 14.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.p2pCounterparty,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 11.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        counterPartyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 12.sp,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                CommonButton(
                  text: localization.p2pView,
                  onPressed: () {
                    final orderId = order.id;
                    if (orderId == null) return;
                    Get.to(() => P2pOrderDetailsScreen(orderId: orderId));
                  },
                  width: 50.w,
                  height: 26.h,
                  borderRadius: 10.r,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  backgroundColor: AppColors.transparent,
                  textColor: AppColors.lightPrimary,
                  borderColor: AppColors.lightPrimary.withValues(alpha: 0.45),
                  borderWidth: 1.1,
                ),
                SizedBox(width: 8.w),
                CommonButton(
                  text: localization.p2pChat,
                  onPressed: () {
                    Get.to(
                      () => OrderChatScreen(
                        orderId: order.id.toString(),
                        role: order.role!,
                      ),
                    );
                  },
                  width: 50.w,
                  height: 26.h,
                  borderRadius: 10.r,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountBlock({
    required String title,
    required String value,
    required bool alignEnd,
  }) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          textAlign: alignEnd ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            fontSize: 12.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Color _statusColor(String? status) {
    switch (status?.trim().toLowerCase()) {
      case 'paid':
        return AppColors.lightPrimary;
      case 'completed':
        return AppColors.success;
      case 'pending_payment':
      case 'disputed':
        return AppColors.warning;
      case 'cancelled':
      case 'expired':
      case 'failed':
      case 'rejected':
        return AppColors.error;
      case 'active':
        return AppColors.success;
      default:
        return AppColors.lightPrimary;
    }
  }

  String _statusLabel(String? value) {
    if (value == null || value.trim().isEmpty) return '-';
    final source = value.trim().toLowerCase();
    final localization = AppLocalizations.of(Get.context!)!;
    if (source == 'pending_payment') return localization.p2pPendingRelease.replaceFirst(' Release', '');
    if (source == 'paid') return 'Paid';
    if (source == 'disputed') return localization.p2pOrderDisputed.replaceFirst('Order ', '');
    if (source == 'completed') return localization.p2pOrderCompleted.replaceFirst('Order ', '');
    if (source == 'cancelled') return localization.p2pOrderCancelled.replaceFirst('Order ', '');
    if (source == 'expired') return localization.p2pOrderExpired.replaceFirst('Order ', '');
    return source[0].toUpperCase() + source.substring(1);
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '--';
    return DateFormat('dd MMM yyyy HH:mm:ss').format(value.toLocal());
  }

  String _counterpartyName(Order order) {
    if (order.role?.isBuyer == true) {
      return order.role?.seller?.name ?? order.role?.seller?.username ?? '--';
    }
    return order.role?.buyer?.name ?? order.role?.buyer?.username ?? '--';
  }

  Future<void> _copyOrderNumber() async {
    final orderNumber = order.orderNumber?.trim() ?? '';
    if (orderNumber.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: orderNumber));
    ToastHelper().showSuccessToast(AppLocalizations.of(Get.context!)!.p2pOrderNumberCopied);
  }
}
