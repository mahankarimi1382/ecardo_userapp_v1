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
import '../models/local_experience_models.dart';

class LocalVoucherScreen extends StatelessWidget {
  final LocalBookingModel booking;

  const LocalVoucherScreen({
    super.key,
    required this.booking,
  });

  String _generateQrSvg() {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      'ECARDO-LOCAL-PASS-${booking.bookingId}-${booking.serviceId}-${booking.status}',
      width: 140,
      height: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const tealHeader = Color(0xFF0F766E);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF0FDF4),
      appBar: AppBar(
        backgroundColor: tealHeader,
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
            fa: 'واچر رسمی خدمات و گشت محلی',
            en: 'Local Service Pass',
            ar: 'بطاقة الخدمة المحلية',
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
                    colors: [tealHeader, Color(0xFF115E59)],
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
                              Icon(Icons.place_rounded, color: Colors.white, size: 22.sp),
                              SizedBox(width: 8.w),
                              Flexible(
                                child: Text(
                                  'eCardo Local Experiences',
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
                      booking.serviceTitle,
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
                        Icon(Icons.person_pin_rounded, size: 14.sp, color: Colors.white70),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            booking.providerName,
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
                color: tealHeader,
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
                            'تاریخ خدمت',
                            DateFormat('yyyy/MM/dd').format(booking.serviceDate),
                            Icons.calendar_today_rounded,
                            isDark,
                          ),
                        ),
                        Expanded(
                          child: _buildDetailTile(
                            'ساعت قرار / اجرا',
                            booking.serviceTime,
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
                            'تعداد همراهان',
                            '${booking.guestsCount} نفر',
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
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDetailTile(
                            'محل ملاقات',
                            booking.meetingPoint,
                            Icons.place_outlined,
                            isDark,
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
                      'شناسه واچر: ${booking.bookingId}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'این واچر را در ابتدای گشت به راهنما یا راننده خود نشان دهید.',
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
                            label: const Text('تماس با مجری'),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.snackbar(
                                'شماره مجری خدمت',
                                booking.providerPhone,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: tealHeader,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            icon: const Icon(Icons.directions_rounded, size: 18, color: Colors.white),
                            label: const Text('مسیریابی نقطه قرار', style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              Get.snackbar(
                                'مسیریابی',
                                'هدایت به ${booking.meetingPoint}',
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
