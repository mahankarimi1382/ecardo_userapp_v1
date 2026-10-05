import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'taxi_controller.dart';
import 'taxi_models.dart';
import 'taxi_widgets.dart';

/// Digital Taxi & Airport Transfer Voucher
/// Displays QR pass for pickup verification, live operational status,
/// assigned driver card, cancel with refund calculator, rating, and 24/7 hotline.
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
    final controller = Get.isRegistered<TaxiController>()
        ? Get.find<TaxiController>()
        : Get.put(TaxiController());
    final isDark = TravelTheme.isDark(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);
    final textSecondary = TravelTheme.textSecondaryFor(context);
    final border = TravelTheme.borderFor(context);
    final formattedDate = DateFormat('yyyy-MM-dd').format(booking.pickupDate);

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Transfer Voucher & Pass',
        fa: 'ووچر و رسید ترانسفر فرودگاهی',
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
                    side: BorderSide(color: border),
                  ),
                  onPressed: () {
                    AppHaptics.light();
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
                      en: 'Copy Code',
                      fa: 'کپی کد رزرو',
                      ar: 'نسخ رقم الحجز',
                      zh: '复制预订码',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: CommonButton(
                  text: l10nPick(
                    context,
                    en: 'Back to Travel Hub',
                    fa: 'بازگشت به خدمات سفر',
                    ar: 'العودة لخدمات السفر',
                    zh: '返回旅游首页',
                  ),
                  textColor: Colors.white,
                  backgroundColor: const Color(0xFF0D9488),
                  onPressed: () {
                    AppHaptics.selection();
                    Get.offAllNamed(BaseRoute.travel);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 30.h),
        children: [
          // Booking Status Hero Card
          Obx(() {
            final active = controller.activeBooking.value ?? booking;
            final isCancelled = active.operationalStatus == RideBookingStatus.cancelled;

            return Container(
              padding: EdgeInsetsDirectional.all(18.r),
              decoration: BoxDecoration(
                color: isCancelled
                    ? Colors.red.withValues(alpha: 0.1)
                    : Colors.green.withValues(alpha: 0.1),
                borderRadius: TravelTheme.radius,
                border: Border.all(
                  color: isCancelled
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.green.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: isCancelled ? Colors.red : Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCancelled ? Icons.close_rounded : Icons.check_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isCancelled
                              ? l10nPick(context, en: 'Transfer Cancelled', fa: 'ترانسفر لغو گردید', ar: 'تم إلغاء الحجز')
                              : l10nPick(
                                  context,
                                  en: 'Transfer Confirmed & Scheduled',
                                  fa: 'ترانسفر با موفقیت رزرو و زمان‌بندی شد',
                                  ar: 'تم حجز التوصيل وتأكيده بنجاح',
                                  zh: '接送服务预订成功并已确认',
                                ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: isCancelled ? Colors.red.shade900 : Colors.green.shade900,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          isCancelled
                              ? l10nPick(context, en: 'Refund processed to your eCardo Wallet.', fa: 'مبلغ به کیف پول eCardo شما مسترد شد.')
                              : l10nPick(
                                  context,
                                  en: 'Guaranteed fixed price. Driver tracking active.',
                                  fa: 'نرخ قطعی تضمین‌شده. رصد پرواز و هماهنگی راننده فعال است.',
                                  ar: 'سعر ثابت مؤكد وتتبع مباشر للرحلة.',
                                  zh: '全天一口价，司机与车牌信息已就绪。',
                                ),
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isCancelled ? Colors.red.shade800 : Colors.green.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 16.h),

          // Operational Status Tracker Steps
          Obx(() {
            final active = controller.activeBooking.value ?? booking;
            return _OperationalStatusTimeline(status: active.operationalStatus);
          }),
          SizedBox(height: 16.h),

          // Assigned Driver Card with Call & WhatsApp
          Obx(() {
            final active = controller.activeBooking.value ?? booking;
            return TaxiLiveDriverCard(
              booking: active,
              onCallDriver: () {
                AppHaptics.light();
                showTravelMessage(
                  context,
                  title: l10nPick(context, en: 'Calling Chauffeur', fa: 'تماس با راننده تشریفات'),
                  message: '${active.driver?.name ?? "Chauffeur"} (${active.driver?.phone ?? "+98-912-345-6789"})',
                );
              },
              onOpenSupport: () {
                AppHaptics.selection();
              },
            );
          }),
          SizedBox(height: 16.h),

          // Digital Voucher Card (Theme-Aware)
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
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: textPrimary),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.12),
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
                        Container(width: 2, height: 32.h, color: border),
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
                            style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                          ),
                          TravelBidiText(
                            booking.origin,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: textPrimary),
                          ),
                          SizedBox(height: 14.h),
                          Text(
                            l10nPick(context, en: 'Destination', fa: 'مقصد پیاده شدن', ar: 'النزول', zh: '目的地'),
                            style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                          ),
                          TravelBidiText(
                            booking.destination,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Key Facts: Date, Time, Pax, Bags
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
                    Expanded(
                      child: _FactItem(
                        icon: Icons.luggage_rounded,
                        label: l10nPick(context, en: 'Luggage', fa: 'چمدان', ar: 'الحقائب', zh: '行李'),
                        value: '${booking.luggageCount}',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Passenger & Flight Info
                Container(
                  padding: EdgeInsetsDirectional.all(12.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(context, en: 'Lead Passenger:', fa: 'نام مسافر:', ar: 'اسم الراكب:', zh: '乘车人姓名:'),
                            style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                          ),
                          Text(
                            booking.passengerName,
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: textPrimary),
                          ),
                        ],
                      ),
                      if (booking.passengerPhone.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Mobile / WhatsApp:', fa: 'شماره تماس:', ar: 'رقم الهاتف:', zh: '联系电话:'),
                              style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                            ),
                            Text(
                              booking.passengerPhone,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: textPrimary),
                            ),
                          ],
                        ),
                      ],
                      if (booking.flightNumber.isNotEmpty) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Flight Tracking:', fa: 'شماره پرواز:', ar: 'رقم الرحلة:', zh: '航班号:'),
                              style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                            ),
                            Text(
                              booking.flightNumber,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: const Color(0xFF0D9488)),
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
                              style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                            ),
                            Text(
                              l10nPick(context, en: 'Included (Name Sign)', fa: 'دارد (با تابلوی نام مسافر)', ar: 'مشمول', zh: '已包含'),
                              style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488)),
                            ),
                          ],
                        ),
                      ],
                      if (booking.childSeatCount > 0) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10nPick(context, en: 'Child Safety Seats:', fa: 'صندلی کودک:', ar: 'مقاعد أمان:'),
                              style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                            ),
                            Text(
                              '${booking.childSeatCount} عدد',
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: textPrimary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const Divider(height: 24),

                // Barcode & QR Code Section (Inside scan-friendly white box for contrast with scanner)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: SvgPicture.string(_generateBarcodeSvg(), height: 50.h),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        booking.reference,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: border),
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
                        style: TextStyle(fontSize: 10.5.sp, color: textSecondary),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 24),

                // Total Fare & Guarantee Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.travelTotal,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: textSecondary),
                        ),
                        Text(
                          l10nPick(context, en: '100% Fixed Rate Guarantee', fa: 'کرایه قطعی و تضمین‌شده'),
                          style: TextStyle(fontSize: 9.5.sp, color: const Color(0xFF0D9488), fontWeight: FontWeight.w700),
                        ),
                      ],
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

          // Action Buttons: Cancel Ride & Rate Driver
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: Colors.red),
                  label: Text(
                    l10nPick(context, en: 'Cancel Ride', fa: 'لغو ترانسفر', ar: 'إلغاء الرحلة'),
                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: EdgeInsetsDirectional.symmetric(vertical: 12.h),
                  ),
                  onPressed: () {
                    AppHaptics.selection();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => TaxiCancellationBottomSheet(
                        booking: booking,
                        onConfirmCancel: (reason) async {
                          await controller.cancelBooking(reason);
                        },
                      ),
                    );
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.star_outline_rounded, size: 16, color: Color(0xFF0D9488)),
                  label: Text(
                    l10nPick(context, en: 'Rate Chauffeur', fa: 'امتیاز به راننده', ar: 'تقييم السائق'),
                    style: const TextStyle(color: Color(0xFF0D9488), fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF0D9488)),
                    padding: EdgeInsetsDirectional.symmetric(vertical: 12.h),
                  ),
                  onPressed: () {
                    AppHaptics.selection();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (ctx) => TaxiRatingBottomSheet(
                        rideId: booking.id,
                        driverName: booking.driver?.name ?? 'علی احمدی (Ali Ahmadi)',
                        onSubmit: (rating) async {
                          await controller.submitRating(rating);
                          if (context.mounted) {
                            showTravelMessage(
                              context,
                              title: l10nPick(context, en: 'Review Submitted', fa: 'امتیاز ثبت شد'),
                              message: l10nPick(context, en: 'Thank you for your feedback.', fa: 'از همراهی و بازخورد ارزشمند شما سپاسگزاریم.'),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // 24/7 Dispatch Hotline Banner (Theme-Aware)
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0D9488).withValues(alpha: 0.12) : const Color(0xFFF0FDFA),
              borderRadius: TravelTheme.radius,
              border: Border.all(
                color: isDark ? const Color(0xFF0D9488).withValues(alpha: 0.3) : const Color(0xFFCCFBF1),
              ),
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
                        l10nPick(context, en: '24/7 Airport Dispatch Center', fa: 'مرکز شبانه‌روزی ترانسفر و دیسپچ فرودگاه', ar: 'مركز عمليات التوصيل ٢٤/٧', zh: '24/7 机场调度中心'),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp, color: textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(context, en: 'Flight delay or terminal change? Call: +98-21-9100-3227', fa: 'تغییر ترمینال یا تأخیر؟ تماس فوری: ۰۲۱-۹۱۰۰۳۲۲۷', ar: 'للطوارئ والتأخير: 00982191003227', zh: '航站楼变更或紧急延误热线：+98-21-9100-3227'),
                        style: TextStyle(fontSize: 11.sp, color: textSecondary),
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
            Icon(icon, size: 14.r, color: TravelTheme.textSecondaryFor(context)),
            SizedBox(width: 4.w),
            Text(label, style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.textSecondaryFor(context), fontWeight: FontWeight.w600)),
          ],
        ),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: TravelTheme.textPrimaryFor(context))),
      ],
    );
  }
}

class _OperationalStatusTimeline extends StatelessWidget {
  final RideBookingStatus status;

  const _OperationalStatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final border = TravelTheme.borderFor(context);

    int getStepIndex() {
      switch (status) {
        case RideBookingStatus.requested:
        case RideBookingStatus.findingDriver:
          return 0;
        case RideBookingStatus.driverAssigned:
          return 1;
        case RideBookingStatus.driverEnRoute:
        case RideBookingStatus.arrivedAtPickup:
          return 2;
        case RideBookingStatus.inProgress:
          return 3;
        case RideBookingStatus.completed:
          return 4;
        case RideBookingStatus.cancelled:
        case RideBookingStatus.expired:
          return -1;
      }
    }

    final activeStep = getStepIndex();

    final steps = [
      l10nPick(context, en: 'Booked', fa: 'ثبت', ar: 'تم الحجز'),
      l10nPick(context, en: 'Driver Assigned', fa: 'راننده', ar: 'السائق'),
      l10nPick(context, en: 'En Route', fa: 'در مسیر', ar: 'في الطريق'),
      l10nPick(context, en: 'In Transit', fa: 'سفر', ar: 'الرحلة'),
      l10nPick(context, en: 'Completed', fa: 'پایان', ar: 'انتهت'),
    ];

    return Container(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(steps.length, (index) {
          final isDone = activeStep >= index && activeStep != -1;
          final isCurrent = activeStep == index;

          return Expanded(
            child: Row(
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20.r,
                      height: 20.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDone ? const Color(0xFF0D9488) : (isDark ? const Color(0xFF333333) : Colors.grey.shade300),
                        border: isCurrent ? Border.all(color: const Color(0xFF0D9488), width: 2) : null,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, size: 12, color: Colors.white)
                            : Text('${index + 1}', style: TextStyle(fontSize: 9.sp, color: Colors.white)),
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      steps[index],
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                        color: isCurrent ? const Color(0xFF0D9488) : TravelTheme.textSecondaryFor(context),
                      ),
                    ),
                  ],
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: activeStep > index ? const Color(0xFF0D9488) : border,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
