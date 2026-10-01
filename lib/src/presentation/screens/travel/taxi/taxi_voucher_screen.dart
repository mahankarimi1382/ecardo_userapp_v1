import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'taxi_models.dart';

/// Digital Taxi & Airport Transfer Voucher
class TaxiVoucherScreen extends StatelessWidget {
  final TaxiBookingInfo booking;

  const TaxiVoucherScreen({super.key, required this.booking});

  String _generateBarcodeSvg() {
    final barcode = Barcode.code128();
    return barcode.toSvg(
      booking.reference,
      width: 260,
      height: 60,
      drawText: false,
    );
  }

  String _generateQrSvg() {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      'TAXI-${booking.reference}-${booking.passengerName}-${booking.totalFare}',
      width: 140,
      height: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final formattedDate = DateFormat('yyyy-MM-dd').format(booking.pickupDate);

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Transfer Voucher',
        fa: 'ووچر و رسید ترانسفر',
        ar: 'قسيمة التوصيل',
        zh: '接送服务电子凭证',
      ),
      showTravelNavigation: false,
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
                    Clipboard.setData(ClipboardData(text: booking.reference));
                    showTravelMessage(
                      context,
                      title: l10nPick(
                        context,
                        en: 'Reference Copied',
                        fa: 'کد رهگیری کپی شد',
                        ar: 'تم نسخ الرقم المرجعي',
                        zh: '参考编号已复制',
                      ),
                      message: booking.reference,
                    );
                  },
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Copy Booking Code',
                      fa: 'کپی کد رزرو',
                      ar: 'نسخ رقم الحجز',
                      zh: '复制预订码',
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
                    en: 'Back to Travel Home',
                    fa: 'بازگشت به خدمات سفر',
                    ar: 'العودة لخدمات السفر',
                    zh: '返回旅游首页',
                  ),
                  textColor: Colors.white,
                  backgroundColor: const Color(0xFF0D9488),
                  onPressed: () => Get.offAllNamed(BaseRoute.travel),
                ),
              ),
            ],
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
        children: [
          // Success Card
          Container(
            padding: EdgeInsetsDirectional.all(18.r),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: TravelTheme.radius,
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
                  child: const Icon(Icons.check_rounded, color: Colors.white, size: 24),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Transfer Booked & Confirmed',
                          fa: 'ترانسفر با موفقیت رزرو و تأیید شد',
                          ar: 'تم حجز التوصيل وتأكيده بنجاح',
                          zh: '接送服务预订成功并已确认',
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
                          en: 'Driver assignment details will be sent via SMS/WhatsApp.',
                          fa: 'مشخصات راننده و خودرو ۲ ساعت قبل از زمان حرکت پیامک خواهد شد.',
                          ar: 'سيتم إرسال بيانات السائق والسيارة عبر رسالة نصية.',
                          zh: '司机与车牌信息将在出发前2小时通过短信发送给您。',
                        ),
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Digital Voucher Card
          TravelCard(
            padding: EdgeInsetsDirectional.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.local_taxi_rounded, color: Color(0xFF0D9488), size: 24),
                        SizedBox(width: 8.w),
                        Text(
                          l10nPick(context, en: booking.vehicle.titleEn, fa: booking.vehicle.titleFa),
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: TravelTheme.ink),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        booking.reference,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Pickup & Dropoff Route
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Icon(Icons.trip_origin_rounded, color: Color(0xFF0D9488), size: 18),
                        Container(width: 2, height: 32.h, color: TravelTheme.border),
                        const Icon(Icons.location_on_rounded, color: Colors.red, size: 18),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, en: 'Pickup', fa: 'مبدأ سوار شدن', ar: 'الانطلاق', zh: '上车点'),
                            style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.muted),
                          ),
                          Text(
                            booking.origin,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            l10nPick(context, en: 'Destination', fa: 'مقصد پیاده شدن', ar: 'النزول', zh: '目的地'),
                            style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.muted),
                          ),
                          Text(
                            booking.destination,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Key Facts
                Row(
                  children: [
                    Expanded(
                      child: _FactItem(
                        icon: Icons.calendar_today_rounded,
                        label: l10nPick(context, en: 'Date', fa: 'تاریخ', ar: 'التاريخ', zh: '日期'),
                        value: formattedDate,
                      ),
                    ),
                    Expanded(
                      child: _FactItem(
                        icon: Icons.access_time_rounded,
                        label: l10nPick(context, en: 'Time', fa: 'ساعت', ar: 'الوقت', zh: '时间'),
                        value: booking.pickupTime,
                      ),
                    ),
                    Expanded(
                      child: _FactItem(
                        icon: Icons.people_alt_rounded,
                        label: l10nPick(context, en: 'Pax', fa: 'تعداد مسافر', ar: 'الركاب', zh: '人数'),
                        value: '${booking.passengerCount}',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Passenger & Flight Info
                Container(
                  padding: EdgeInsetsDirectional.all(12.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Passenger Name:', fa: 'نام مسافر:', ar: 'اسم الراكب:', zh: '乘车人姓名:'),
                            style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                          ),
                          Text(
                            booking.passengerName,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      if (booking.flightNumber.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Flight Tracking:', fa: 'شماره پرواز:', ar: 'رقم الرحلة:', zh: '航班号:'),
                              style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                            ),
                            Text(
                              booking.flightNumber,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ],
                      if (booking.meetAndGreet) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Meet & Greet:', fa: 'استقبال تشریفات:', ar: 'الاستقبال باللوحة:', zh: '举牌接机:'),
                              style: TextStyle(fontSize: 11.5.sp, color: TravelTheme.muted),
                            ),
                            Text(
                              l10nPick(context, en: 'Included (Name Sign)', fa: 'دارد (با تابلوی نام مسافر)', ar: 'مشمول', zh: '已包含'),
                              style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488)),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 24),

                // Barcode & QR Code Section
                Center(
                  child: Column(
                    children: [
                      SvgPicture.string(_generateBarcodeSvg(), height: 50.h),
                      SizedBox(height: 6.h),
                      Text(
                        booking.reference,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          color: TravelTheme.ink,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: TravelTheme.border),
                        ),
                        child: SvgPicture.string(_generateQrSvg(), width: 120.r, height: 120.r),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Present this QR pass to the chauffeur at pickup',
                          fa: 'این بارکد را هنگام سوار شدن به راننده نشان دهید',
                          ar: 'أبرز هذا الرمز للسائق عند ركوب السيارة',
                          zh: '上车时向司机出示此乘车二维码',
                        ),
                        style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.muted),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),

                // Total Fare
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.travelTotal,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: TravelTheme.muted),
                    ),
                    Text(
                      '${formatMockAmount(booking.totalFare)} ${localization.travelMockCurrency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0D9488),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // 24/7 Dispatch Hotline
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              borderRadius: TravelTheme.radius,
              border: Border.all(color: const Color(0xFFCCFBF1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.phone_in_talk_rounded, color: Color(0xFF0D9488)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: '24/7 Airport Transfer Dispatch', fa: 'مرکز دیسپچ و اعزام ترانسفر فرودگاهی', ar: 'مركز عمليات التوصيل ٢٤/٧', zh: '24/7 机场调度中心'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(context, en: 'Flight delay or terminal change? Call: +98-21-9100-3227', fa: 'تغییر ترمینال یا تأخیر؟ تماس فوری: ۰۲۱-۹۱۰۰۳۲۲۷', ar: 'للطوارئ والتأخير: 00982191003227', zh: '航站楼变更或紧急延误热线：+98-21-9100-3227'),
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

class _FactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FactItem({
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
