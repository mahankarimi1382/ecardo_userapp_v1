import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

import '../models/rental_models.dart';

/// Digital Car Rental Voucher & Handover Pass
class RentalVoucherScreen extends StatelessWidget {
  final RentalBookingModel booking;

  const RentalVoucherScreen({super.key, required this.booking});

  String _generateQrSvg() {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      'CAR-RENTAL-${booking.bookingNo}-${booking.car?.title ?? ''}-${booking.status}',
      width: 140,
      height: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final car = booking.car;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(
            context,
            en: 'Car Rental Voucher',
            fa: 'رسید و ووچر اجاره خودرو',
            ar: 'قسيمة تأجير السيارة',
            zh: '租车电子凭证',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(AppSpacing.lg.r),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    ),
                    side: BorderSide(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Clipboard.setData(ClipboardData(text: booking.bookingNo));
                    ToastHelper().showSuccessToast(
                      l10nPick(
                        context,
                        en: 'Booking number copied: ${booking.bookingNo}',
                        fa: 'شماره رزرو کپی شد: ${booking.bookingNo}',
                        ar: 'تم نسخ رقم الحجز',
                        zh: '预订编号已复制',
                      ),
                    );
                  },
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Copy Booking No',
                      fa: 'کپی شماره رزرو',
                      ar: 'نسخ رقم الحجز',
                      zh: '复制预订号',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: CommonButton(
                  text: l10nPick(
                    context,
                    en: 'Done',
                    fa: 'تأیید و بازگشت',
                    ar: 'تم',
                    zh: '完成',
                  ),
                  textColor: isDark ? AppColors.deepBlack : AppColors.white,
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(AppSpacing.lg.w, AppSpacing.md.h, AppSpacing.lg.w, AppSpacing.xxxl.h),
        children: [
          // Status banner
          Container(
            padding: EdgeInsetsDirectional.all(AppSpacing.lg.r),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSpacing.radius.r),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.sm.r),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Rental Voucher Confirmed',
                          fa: 'رزرو خودرو با موفقیت تأیید شد',
                          ar: 'تم تأكيد حجز السيارة',
                          zh: '租车凭证已确认',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Present this voucher and your original driving license at vehicle handover.',
                          fa: 'این برگه را همراه با اصل گواهینامه معتبر هنگام تحویل خودرو ارائه فرمایید.',
                          ar: 'يرجى تقديم هذه القسيمة مع رخصة القيادة الأصلية عند الاستلام.',
                          zh: '请在取车时出示此凭证及有效驾照原件。',
                        ),
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
          SizedBox(height: AppSpacing.lg.h),

          // Voucher Card
          Container(
            padding: EdgeInsetsDirectional.all(AppSpacing.xl.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                  blurRadius: 12,
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
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.directions_car_rounded,
                            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                            size: AppSpacing.iconMd.sp,
                          ),
                          SizedBox(width: AppSpacing.sm.w),
                          Expanded(
                            child: Text(
                              car?.title ?? '—',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm.w),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                      ),
                      child: Text(
                        booking.bookingNo,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),

                // Vehicle Specs
                Row(
                  children: [
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.category_rounded,
                        label: l10nPick(context, en: 'Category', fa: 'کلاس', ar: 'الفئة', zh: '类别'),
                        value: car?.category ?? '—',
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.settings_rounded,
                        label: l10nPick(context, en: 'Transmission', fa: 'گیربکس', ar: 'ناقل الحركة', zh: '变速箱'),
                        value: car?.transmission ?? 'Auto',
                        isDark: isDark,
                      ),
                    ),
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.shield_rounded,
                        label: l10nPick(context, en: 'Insurance', fa: 'بیمه', ar: 'التأمين', zh: '保险'),
                        value: booking.insuranceTier,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),

                // Dates & Locations
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, en: 'Pickup', fa: 'تحویل گرفتن', ar: 'الاستلام', zh: '取车时间'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.pickupAt != null ? booking.pickupAt!.toIso8601String().split('T').first : '—',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      size: 20.r,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10nPick(context, en: 'Return', fa: 'استرداد خودرو', ar: 'الإرجاع', zh: '还车时间'),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.returnAt != null ? booking.returnAt!.toIso8601String().split('T').first : '—',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),

                // Pricing Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(context, en: 'Rental Total', fa: 'مجموع کرایه', ar: 'إجمالي الإيجار', zh: '租金合计'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '\$${booking.rentalTotal}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        l10nPick(context, en: 'Security Deposit (Locked)', fa: 'ودیعه ضمانت (قفل موقت)', ar: 'مبلغ التأمين (محجوز)', zh: '押金（预授权冻结）'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      car != null ? '\$${car.depositAmount}' : '—',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                Divider(
                  height: 24.h,
                  color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                ),

                // QR Code
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: SvgPicture.string(_generateQrSvg(), width: 120.r, height: 120.r),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Scan QR at pickup point for 8-angle condition check-in',
                          fa: 'اسکن بارکد در محل تحویل خودرو جهت ثبت تصاویر دیجیتال ۸ جهته',
                          ar: 'امسح الرمز لتسجيل فحص السيارة من ٨ زوايا',
                          zh: '取车时扫描二维码以完成八方位车况记录',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpacing.lg.h),

          // Roadside Assistance
          Container(
            padding: EdgeInsetsDirectional.all(AppSpacing.lg.r),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.lightCard,
              borderRadius: BorderRadius.circular(AppSpacing.radius.r),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  size: 24.sp,
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: '24/7 Roadside Assistance', fa: 'امداد جاده‌ای و پشتیبانی ۲۴ ساعته', ar: 'المساعدة على الطريق ٢٤/٧', zh: '24/7 道路救援支持'),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(context, en: 'Direct emergency line: +98 21 9100 ECAR', fa: 'تماس اضطراری ۲۴ ساعته: ۰۲۱-۹۱۰۰-اکاردو', ar: 'خط الدعم المباشر', zh: '紧急支持专线：+98 21 9100 ECAR'),
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
        ],
      ),
    );
  }
}

class _RentalFact extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;

  const _RentalFact({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 14.r,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            SizedBox(width: 4.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.5.sp,
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }
}