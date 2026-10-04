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
import '../models/boat_models.dart';

class BoatVoucherScreen extends StatelessWidget {
  final BoatBookingModel booking;

  const BoatVoucherScreen({
    super.key,
    required this.booking,
  });

  String _generateQrSvg() {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      'ECARDO-MARINE-PASS-${booking.bookingId}-${booking.boatId}-${booking.status}',
      width: 140,
      height: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const oceanNavy = Color(0xFF0A192F);
    const oceanCyan = Color(0xFF00B4D8);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF0F4F8),
      appBar: AppBar(
        backgroundColor: oceanNavy,
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
            fa: 'بلیت و کارت پرواز دریایی',
            en: 'Marine Boarding Pass',
            ar: 'بطاقة الصعود البحرية',
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
                    colors: [oceanNavy, Color(0xFF1B3B6F)],
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
                              Icon(Icons.directions_boat_rounded, color: oceanCyan, size: 22.sp),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'eCardo Marine Club',
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
                            color: AppColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: AppColors.success),
                          ),
                          child: Text(
                            'تأیید قطعی',
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      booking.boatTitle,
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
                        Icon(Icons.place_rounded, size: 14.sp, color: oceanCyan),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            booking.marinaName,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.white.withValues(alpha: 0.8),
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
                color: oceanNavy,
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
                    // Grid details
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'تاریخ گشت',
                            DateFormat('yyyy/MM/dd').format(booking.date),
                            Icons.calendar_today_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            'سانس حرکت',
                            booking.timeSlot.split('(').first.trim(),
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
                            'مدت برنامه',
                            '${booking.durationHours} ساعت در دریا',
                            Icons.timer_outlined,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            'جایگاه و اسکله',
                            booking.pierDockNumber,
                            Icons.anchor_rounded,
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
                            'سرنشینان',
                            '${booking.passengersCount} نفر مسافر',
                            Icons.people_outline_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            'مبلغ پرداخت‌شده',
                            '${booking.totalAmount.toStringAsFixed(0)} ${booking.currency}',
                            Icons.account_balance_wallet_outlined,
                            isDark,
                            valueColor: AppColors.success,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),
                    const Divider(),
                    SizedBox(height: 14.h),

                    // QR Code Section
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.greyLight),
                      ),
                      child: SvgPicture.string(
                        _generateQrSvg(),
                        width: 130.w,
                        height: 130.h,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'شناسه بلیت: ${booking.bookingId}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'این بارکد را هنگام ورود به اسکله به مسئول گشت یا کاپیتان نشان دهید.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),

                    SizedBox(height: 20.h),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                            label: const Text('تماس با کاپیتان'),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.snackbar(
                                'شماره کاپیتان شناور',
                                booking.captainPhone,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0077B6),
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            icon: const Icon(Icons.directions_rounded, size: 18, color: Colors.white),
                            label: const Text('مسیریابی اسکله', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.snackbar(
                                'مسیریابی اسکله',
                                'هدایت به لوکیشن ${booking.marinaName}',
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20.h),
              // Safety & Marine Advisory
              Container(
                padding: EdgeInsets.all(AppSpacing.md.r),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.warning, size: 20.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        'لطفاً حداقل ۲۰ دقیقه قبل از ساعت حرکت در اسکله حاضر باشید. پوشیدن جلیقه نجات در طول حضور در آب‌های آزاد برای کلیه سرنشینان الزامی است.',
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
    bool isDark, {
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
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
