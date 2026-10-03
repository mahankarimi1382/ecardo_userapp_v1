import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

import '../models/rental_models.dart';

/// Digital Car Rental Voucher & Handover Pass
class RentalVoucherScreen extends StatelessWidget {
  final RentalBookingModel booking;

  const RentalVoucherScreen({super.key, required this.booking});

  String _generateBarcodeSvg() {
    final barcode = Barcode.code128();
    return barcode.toSvg(
      booking.bookingNo.isNotEmpty ? booking.bookingNo : 'RNT-${booking.id}',
      width: 260,
      height: 60,
      drawText: false,
    );
  }

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

    return Scaffold(
      backgroundColor: TravelTheme.background,
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
            color: TravelTheme.ink,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: TravelTheme.ink),
          onPressed: () => Get.back(),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsetsDirectional.all(16.r),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsetsDirectional.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    side: const BorderSide(color: TravelTheme.border),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: booking.bookingNo));
                    showTravelMessage(
                      context,
                      title: l10nPick(
                        context,
                        en: 'Reference Copied',
                        fa: 'شماره رزرو کپی شد',
                        ar: 'تم نسخ رقم الحجز',
                        zh: '预订编号已复制',
                      ),
                      message: booking.bookingNo,
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
                      color: TravelTheme.ink,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CommonButton(
                  text: l10nPick(
                    context,
                    en: 'Done',
                    fa: 'تأیید و بازگشت',
                    ar: 'تم',
                    zh: '完成',
                  ),
                  textColor: Colors.white,
                  backgroundColor: AppColors.lightPrimary,
                  onPressed: () => Get.back(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(16.w, 14.h, 16.w, 30.h),
        children: [
          // Status banner
          Container(
            padding: EdgeInsetsDirectional.all(16.r),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 22),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Rental Voucher Confirmed',
                          fa: 'رزرو خودرو با موفقیت ثبت شد',
                          ar: 'تم تأكيد حجز السيارة',
                          zh: '租车凭证已确认',
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: Colors.green.shade900,
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
                        style: TextStyle(fontSize: 11.sp, color: Colors.green.shade800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Voucher Card
          Container(
            padding: EdgeInsetsDirectional.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: TravelTheme.shadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.directions_car_rounded, color: AppColors.lightPrimary, size: 24),
                        SizedBox(width: 8.w),
                        Text(
                          car?.title ?? '—',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w900,
                            color: TravelTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.lightPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        booking.bookingNo,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Vehicle Specs
                Row(
                  children: [
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.category_rounded,
                        label: l10nPick(context, en: 'Category', fa: 'کلاس', ar: 'الفئة', zh: '类别'),
                        value: car?.category ?? '—',
                      ),
                    ),
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.settings_rounded,
                        label: l10nPick(context, en: 'Transmission', fa: 'گیربکس', ar: 'ناقل الحركة', zh: '变速箱'),
                        value: car?.transmission ?? '—',
                      ),
                    ),
                    Expanded(
                      child: _RentalFact(
                        icon: Icons.shield_rounded,
                        label: l10nPick(context, en: 'Insurance', fa: 'بیمه', ar: 'التأمين', zh: '保险'),
                        value: booking.insuranceTier,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Dates & Locations
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, en: 'Pickup', fa: 'تحویل گرفتن', ar: 'الاستلام', zh: '取车时间'),
                            style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.pickupAt != null ? booking.pickupAt!.toIso8601String().split('T').first : '—',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: TravelTheme.muted, size: 20.r),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            l10nPick(context, en: 'Return', fa: 'استرداد خودرو', ar: 'الإرجاع', zh: '还车时间'),
                            style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            booking.returnAt != null ? booking.returnAt!.toIso8601String().split('T').first : '—',
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Pricing Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Rental Total', fa: 'مجموع کرایه', ar: 'إجمالي الإيجار', zh: '租金合计'),
                      style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted),
                    ),
                    Text(
                      '${booking.rentalTotal}',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(context, en: 'Security Deposit (Locked)', fa: 'ودیعه ضمانت (قفل موقت)', ar: 'مبلغ التأمين (محجوز)', zh: '押金（预授权冻结）'),
                      style: TextStyle(fontSize: 12.sp, color: TravelTheme.muted),
                    ),
                    Text(
                      car != null ? '${car.depositAmount}' : '—',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.blueGrey),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // QR Code
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: TravelTheme.border),
                        ),
                        child: SvgPicture.string(_generateQrSvg(), width: 120.r, height: 120.r),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Scan QR at pickup point for 8-angle condition check-in',
                          fa: 'اسکن بارکد در محل تحویل خودرو جهت ثبت تصاویر دیجیتال ۸ جهته',
                          ar: 'امسح الرمز لتسجيل فحص السيارة من ٨ زوايا',
                          zh: '取车时扫描二维码以完成八方位车况记录',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Roadside Assistance
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: TravelTheme.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.support_agent_rounded, color: AppColors.lightPrimary, size: 24),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: '24/7 Roadside Assistance', fa: 'امداد جاده‌ای و پشتیبانی ۲۴ ساعته', ar: 'المساعدة على الطريق ٢٤/٧', zh: '24/7 道路救援支持'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(context, en: 'Direct support line: +98 21 8888 0000', fa: 'تماس مستقیم اضطراری: ۰۲۱-۸۸۸۸۰۰۰۰', ar: 'خط الدعم المباشر: 00982188880000', zh: '紧急支持电话：+98 21 8888 0000'),
                        style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
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

  const _RentalFact({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.r, color: TravelTheme.muted),
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.muted, fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink)),
      ],
    );
  }
}
