import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../models/dining_models.dart';

class DiningOrderPassScreen extends StatelessWidget {
  final DiningOrderModel order;

  const DiningOrderPassScreen({
    super.key,
    required this.order,
  });

  String _generateBarcodeSvg() {
    final barcode = Barcode.code128();
    return barcode.toSvg(
      order.orderId,
      width: 220,
      height: 70,
      drawText: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const gourmetAmber = Color(0xFFD97706);
    const gourmetRed = Color(0xFF991B1B);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFFFFBEB),
      appBar: AppBar(
        backgroundColor: gourmetRed,
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
                  gradient: const LinearGradient(
                    colors: [gourmetRed, gourmetAmber],
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
                              Icon(Icons.restaurant_rounded, color: Colors.white, size: 22.sp),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'eCardo In-Transit Dining',
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
                            color: AppColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.white),
                          ),
                          child: Text(
                            order.status == 'ready_for_pickup' ? 'آماده تحویل' : 'در حال آماده‌سازی',
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      order.restaurantName,
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
                        Icon(Icons.place_rounded, size: 14.sp, color: Colors.white70),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            order.terminalLocation,
                            style: TextStyle(
                              fontSize: 11.5.sp,
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
                color: gourmetRed,
                child: Row(
                  children: List.generate(
                    24,
                    (i) => Expanded(
                      child: Container(
                        height: 2,
                        color: i % 2 == 0 ? Colors.transparent : AppColors.white.withValues(alpha: 0.4),
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
                            'ساعت تحویل',
                            order.pickupTime,
                            Icons.access_time_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            'محل تحویل / گیت',
                            order.gateOrTable ?? 'پیشخوان سالن ترانزیت',
                            Icons.flight_takeoff_rounded,
                            isDark,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    const Divider(),
                    SizedBox(height: 8.h),

                    // Order items list
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'اقلام سفارش شما:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ...order.items.map((it) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 6.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${it.quantity}× ${it.item.title}',
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${it.subtotal.toStringAsFixed(0)} ${order.currency}',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.w700,
                                color: gourmetAmber,
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
                          'مجموع پرداختی:',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          '${order.totalAmount.toStringAsFixed(0)} ${order.currency}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
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
                            height: 60.h,
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            order.orderId,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                              letterSpacing: 2.0,
                              color: Colors.black87,
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
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    String label,
    String value,
    IconData icon,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.sp, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
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
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
