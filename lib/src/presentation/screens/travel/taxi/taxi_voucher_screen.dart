import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../services/mock_travel_data.dart';
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
    final textPrimary = ECardoTokens.ink(context);
    final textSecondary = ECardoTokens.inkMuted(context);
    final border = ECardoTokens.border(context);
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
          padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsetsDirectional.symmetric(vertical: ECardoTokens.space4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
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
              SizedBox(width: ECardoTokens.space3.w),
              Expanded(
                child: CommonButton(
                  text: l10nPick(
                    context,
                    en: 'Back to Travel Hub',
                    fa: 'بازگشت به خدمات سفر',
                    ar: 'العودة لخدمات السفر',
                    zh: '返回旅游首页',
                  ),
                  textColor: ECardoTokens.inkOnBrand,
                  backgroundColor: ECardoTokens.brand500(context),
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
        padding: EdgeInsetsDirectional.fromSTEB(
          ECardoTokens.space5.w,
          ECardoTokens.space3.h,
          ECardoTokens.space5.w,
          ECardoTokens.space8.h,
        ),
        children: [
          // Booking Status Hero Card
          Obx(() {
            final active = controller.activeBooking.value ?? booking;
            final isCancelled = active.operationalStatus == RideBookingStatus.cancelled;

            return Container(
              padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r + 6.r),
              decoration: BoxDecoration(
                color: isCancelled ? ECardoTokens.dangerBg(context) : ECardoTokens.successBg(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                border: Border.all(
                  color: isCancelled ? ECardoTokens.danger(context).withValues(alpha: 0.3) : ECardoTokens.success(context).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: isCancelled ? ECardoTokens.danger(context) : ECardoTokens.success(context),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isCancelled ? Icons.close_rounded : Icons.check_rounded,
                      color: ECardoTokens.inkOnBrand,
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
                            color: isCancelled ? ECardoTokens.danger(context) : ECardoTokens.success(context),
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
                            color: isCancelled ? ECardoTokens.danger(context) : ECardoTokens.success(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: ECardoTokens.space4.h),

          // Operational Status Tracker Steps
          Obx(() {
            final active = controller.activeBooking.value ?? booking;
            return _OperationalStatusTimeline(status: active.operationalStatus);
          }),
          SizedBox(height: ECardoTokens.space4.h),

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
          SizedBox(height: ECardoTokens.space4.h),

          // Digital Voucher Card (Theme-Aware)
          TravelCard(
            color: ECardoTokens.surfaceCard(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
            padding: EdgeInsetsDirectional.all(ECardoTokens.space5.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.local_taxi_rounded, color: ECardoTokens.brand500(context), size: 24.r),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              l10nPick(context, en: booking.vehicle.titleEn, fa: booking.vehicle.titleFa),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: textPrimary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.brand100(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                      ),
                      child: Text(
                        booking.reference,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.brand500(context),
                        ),
                      ),
                    ),
                  ],
                ),
                Divider(height: 24, color: ECardoTokens.border(context)),

                // Pickup & Dropoff Route
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.trip_origin_rounded, color: ECardoTokens.brand500(context), size: 18.r),
                        Container(width: 2, height: 32.h, color: ECardoTokens.borderStrong(context)),
                        Icon(Icons.location_on_rounded, color: ECardoTokens.danger(context), size: 18.r),
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
                Divider(height: 24, color: ECardoTokens.border(context)),

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
                  padding: EdgeInsetsDirectional.all(ECardoTokens.space3.r),
                  decoration: BoxDecoration(
                    color: ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10nPick(context, en: 'Lead Passenger:', fa: 'نام مسافر:', ar: 'اسم الراكب:', zh: '乘车人姓名:'),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                            ),
                          ),
                          SizedBox(width: 4.w),
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
                            Expanded(
                              child: Text(
                                l10nPick(context, en: 'Mobile / WhatsApp:', fa: 'شماره تماس:', ar: 'رقم الهاتف:', zh: '联系电话:'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                              ),
                            ),
                            SizedBox(width: 4.w),
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
                            Expanded(
                              child: Text(
                                l10nPick(context, en: 'Flight Tracking:', fa: 'شماره پرواز:', ar: 'رقم الرحلة:', zh: '航班号:'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                booking.flightNumber,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, fontFamily: 'monospace', color: ECardoTokens.brand500(context)),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (booking.meetAndGreet) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10nPick(context, en: 'Meet & Greet:', fa: 'استقبال تشریفات:', ar: 'الاستقبال باللوحة:', zh: '举牌接机:'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                l10nPick(context, en: 'Included (Name Sign)', fa: 'دارد (با تابلوی نام مسافر)', ar: 'مشمول', zh: '已包含'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: ECardoTokens.brand500(context)),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (booking.childSeatCount > 0) ...[
                        SizedBox(height: 6.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                l10nPick(context, en: 'Child Safety Seats:', fa: 'صندلی کودک:', ar: 'مقاعد أمان:'),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.5.sp, color: textSecondary),
                              ),
                            ),
                            SizedBox(width: 4.w),
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
                Divider(height: 24, color: ECardoTokens.border(context)),

                // Barcode & QR Code Section (Inside scan-friendly white box for contrast with scanner)
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
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
                        padding: EdgeInsets.all(ECardoTokens.space3.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
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
                Divider(height: 24, color: ECardoTokens.border(context)),

                // Total Fare & Guarantee Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localization.travelTotal,
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: textSecondary),
                          ),
                          Text(
                            l10nPick(context, en: '100% Fixed Rate Guarantee', fa: 'کرایه قطعی و تضمین‌شده'),
                            style: TextStyle(fontSize: 9.5.sp, color: ECardoTokens.brand500(context), fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: Text(
                        '${formatMockAmount(booking.totalFare)} ${localization.travelMockCurrency}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.brand500(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: ECardoTokens.space4.h),

          // Action Buttons: Cancel Ride & Rate Driver
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.cancel_outlined, size: 16, color: ECardoTokens.danger(context)),
                  label: Text(
                    l10nPick(context, en: 'Cancel Ride', fa: 'لغو ترانسفر', ar: 'إلغاء الرحلة'),
                    style: TextStyle(color: ECardoTokens.danger(context), fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ECardoTokens.danger(context)),
                    padding: EdgeInsetsDirectional.symmetric(vertical: ECardoTokens.space3.h),
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
              SizedBox(width: ECardoTokens.space3.w),
              Expanded(
                child: OutlinedButton.icon(
                  icon: Icon(Icons.star_outline_rounded, size: 16, color: ECardoTokens.brand500(context)),
                  label: Text(
                    l10nPick(context, en: 'Rate Chauffeur', fa: 'امتیاز به راننده', ar: 'تقييم السائق'),
                    style: TextStyle(color: ECardoTokens.brand500(context), fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ECardoTokens.brand500(context)),
                    padding: EdgeInsetsDirectional.symmetric(vertical: ECardoTokens.space3.h),
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
          SizedBox(height: ECardoTokens.space4.h),

          // 24/7 Dispatch Hotline Banner (Theme-Aware)
          Container(
            padding: EdgeInsetsDirectional.all(ECardoTokens.space4.r),
            decoration: BoxDecoration(
              color: ECardoTokens.brand100(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              border: Border.all(
                color: ECardoTokens.brand500(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_in_talk_rounded, color: ECardoTokens.brand500(context)),
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
            Icon(icon, size: 14.r, color: ECardoTokens.inkMuted(context)),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.5.sp, color: ECardoTokens.inkMuted(context), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context)),
        ),
      ],
    );
  }
}

class _OperationalStatusTimeline extends StatelessWidget {
  final RideBookingStatus status;

  const _OperationalStatusTimeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final border = ECardoTokens.border(context);

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
        color: ECardoTokens.surfaceSunken(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
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
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 20.r,
                        height: 20.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDone ? ECardoTokens.brand500(context) : ECardoTokens.borderStrong(context),
                          border: isCurrent ? Border.all(color: ECardoTokens.brand500(context), width: 2) : null,
                        ),
                        child: Center(
                          child: isDone
                              ? Icon(Icons.check, size: 12, color: ECardoTokens.inkOnBrand)
                              : Text('${index + 1}', style: TextStyle(fontSize: 9.sp, color: ECardoTokens.inkOnBrand)),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        steps[index],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                          color: isCurrent ? ECardoTokens.brand500(context) : ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 2,
                      color: activeStep > index ? ECardoTokens.brand500(context) : border,
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
