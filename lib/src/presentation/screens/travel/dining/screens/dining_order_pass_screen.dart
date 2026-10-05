// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/dining_controller.dart';
import '../models/dining_models.dart';
import '../../local/widgets/experience_ui_components.dart';

class DiningOrderPassScreen extends StatefulWidget {
  final DiningOrderModel order;

  const DiningOrderPassScreen({
    super.key,
    required this.order,
  });

  @override
  State<DiningOrderPassScreen> createState() => _DiningOrderPassScreenState();
}

class _DiningOrderPassScreenState extends State<DiningOrderPassScreen> {
  late DiningOrderModel currentOrder;
  late final DiningController controller;

  @override
  void initState() {
    super.initState();
    currentOrder = widget.order;
    controller = Get.isRegistered<DiningController>()
        ? Get.find<DiningController>()
        : Get.put(DiningController());
  }

  String _generateBarcodeSvg() {
    final barcode = Barcode.code128();
    final payload = currentOrder.qrPayload;
    return barcode.toSvg(
      payload.isNotEmpty ? payload : currentOrder.orderId,
      width: 220,
      height: 70,
      drawText: false,
    );
  }

  Future<void> _handleCancelOrder() async {
    final calc = currentOrder.calculateCancellationRefund();
    final confirmed = await showExperienceCancellationSheet(
      context: context,
      bookingId: currentOrder.orderId,
      title: currentOrder.restaurantName,
      calculation: calc,
      onConfirmCancellation: (reason) async {
        final success = await controller.cancelOrder(currentOrder.orderId, reason: reason);
        if (success) {
          final updated = controller.myOrders.firstWhereOrNull(
            (o) => o.orderId == currentOrder.orderId,
          );
          if (updated != null && mounted) {
            setState(() {
              currentOrder = updated;
            });
          }
        }
        return success;
      },
    );

    if (confirmed == true && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const gourmetAmber = Color(0xFFD97706);
    const gourmetRed = Color(0xFF991B1B);

    final isCancelled = currentOrder.isCancelled;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: isCancelled ? const Color(0xFF991B1B) : gourmetRed,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: AppColors.white,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(
            context,
            fa: 'رسید و پاس تحویل غذای سفر',
            en: 'Travel Dining Pass',
            ar: 'بطاقة استلام الوجبة',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          child: Column(
            children: [
              // Ticket Header
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isCancelled
                        ? [const Color(0xFF7F1D1D), const Color(0xFF991B1B)]
                        : [gourmetRed, gourmetAmber],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppSpacing.radiusXl.r),
                    topRight: Radius.circular(AppSpacing.radiusXl.r),
                  ),
                ),
                padding: EdgeInsets.all(AppSpacing.xl.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Icon(Icons.dinner_dining_rounded,
                                  color: isCancelled ? AppColors.white : Colors.white, size: 22.sp),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'eCardo Travel Dining',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.white,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isCancelled
                                ? AppColors.error.withValues(alpha: 0.2)
                                : AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                                color: isCancelled ? AppColors.error : AppColors.success),
                          ),
                          child: Text(
                            isCancelled ? 'لغو شده' : 'تأیید شده',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: isCancelled ? Colors.white : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      currentOrder.restaurantName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.white,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(Icons.flight_takeoff_rounded, size: 14.sp, color: Colors.white70),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            currentOrder.terminalLocation,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.white.withValues(alpha: 0.9),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Tear-line Separator
              Container(
                color: isCancelled ? const Color(0xFF991B1B) : gourmetRed,
                child: Row(
                  children: List.generate(
                    24,
                    (i) => Expanded(
                      child: Container(
                        height: 2,
                        color:
                            i % 2 == 0 ? Colors.transparent : AppColors.white.withValues(alpha: 0.4),
                      ),
                    ),
                  ),
                ),
              ),

              // Ticket Body & Details
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(AppSpacing.radiusXl.r),
                    bottomRight: Radius.circular(AppSpacing.radiusXl.r),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: EdgeInsets.all(AppSpacing.xl.r),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'سفارش در تاریخ',
                            DateFormat('yyyy/MM/dd').format(currentOrder.orderedAt),
                            Icons.calendar_today_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            'زمان تحویل/سرو',
                            currentOrder.pickupTime,
                            Icons.access_time_rounded,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'نوع سرو',
                            _modeLabel(currentOrder.mode),
                            Icons.delivery_dining_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            isCancelled ? 'مبلغ استرداد شده' : 'مجموع پرداختی',
                            isCancelled
                                ? '+${currentOrder.refundedAmount.toStringAsFixed(0)} ${currentOrder.refundDestinationWalletCurrency}'
                                : '${currentOrder.totalAmount.toStringAsFixed(0)} ${currentOrder.currency}',
                            Icons.account_balance_wallet_outlined,
                            isDark,
                            valueColor: isCancelled ? AppColors.info : AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    if (isCancelled && currentOrder.cancellationReason != null) ...[
                      SizedBox(height: 14.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'توضیحات لغو: ${currentOrder.cancellationReason}',
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: AppColors.error,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],

                    SizedBox(height: 20.h),
                    const Divider(),
                    SizedBox(height: 14.h),

                    // Menu Items
                    Text(
                      l10nPick(context, fa: 'آیات سفارش', en: 'Order Items'),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    ...currentOrder.items.map((it) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                it.quantity > 1 ? '${it.quantity} × ${it.item.title}' : it.item.title,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${it.subtotal.toStringAsFixed(0)} ${currentOrder.currency}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 14.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'مجموع نهایی:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${currentOrder.totalAmount.toStringAsFixed(0)} ${currentOrder.currency}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: isCancelled ? AppColors.error : AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                    const Divider(),
                    SizedBox(height: 14.h),

                    // Barcode Section
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: AppColors.greyLight),
                      ),
                      child: Column(
                        children: [
                          SvgPicture.string(
                            _generateBarcodeSvg(),
                            width: 220.w,
                            height: 70.h,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            currentOrder.orderId,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 2.0,
                              color: isDark ? AppColors.darkTextPrimary : const Color(0xFF2E2E2E),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'این بارکد را به صندوق‌دار یا پرسنل تحویل غذا در پایانه نشان دهید.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),

                    SizedBox(height: 20.h),
                    // Cancel button if eligible
                    if (currentOrder.canCancel) ...[
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(double.infinity, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          side: BorderSide(color: AppColors.error),
                          foregroundColor: AppColors.error,
                        ),
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('درخواست لغو رزرو و استرداد وجه'),
                        onPressed: _handleCancelOrder,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _modeLabel(DiningServiceMode mode) {
    switch (mode) {
      case DiningServiceMode.airportGatePickup:
        return 'تحویل درب گیت پرواز';
      case DiningServiceMode.loungeDelivery:
        return 'سرو اختصاصی در لانژ';
      case DiningServiceMode.tableReservation:
        return 'رزرو قطعی میز رستوران';
      case DiningServiceMode.chefTastingExperience:
        return 'تجربه مزه‌گردی سرآشپز';
    }
  }

  Widget _buildDetailTile(
    String label,
    String value,
    IconData icon,
    bool isDark, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: valueColor ??
                (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
