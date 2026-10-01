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

/// Digital Train Ticket / Boarding Pass Voucher
class TrainConfirmationScreen extends StatelessWidget {
  final String reference;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final String trainName;
  final String trainNumber;
  final String operatorName;
  final String departureTime;
  final String arrivalTime;
  final String trainClass;
  final int totalPrice;
  final List<Map<String, String>> passengers;

  const TrainConfirmationScreen({
    super.key,
    required this.reference,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.trainName,
    required this.trainNumber,
    required this.operatorName,
    required this.departureTime,
    required this.arrivalTime,
    required this.trainClass,
    required this.totalPrice,
    required this.passengers,
  });

  String _generateBarcodeSvg() {
    final barcode = Barcode.code128();
    return barcode.toSvg(
      reference,
      width: 260,
      height: 60,
      drawText: false,
    );
  }

  String _generateQrSvg() {
    final barcode = Barcode.qrCode();
    return barcode.toSvg(
      'TRAIN-$reference-$trainNumber-$origin-$destination',
      width: 140,
      height: 140,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final formattedDate = DateFormat('yyyy-MM-dd').format(departureDate);

    return TravelPage(
      title: l10nPick(
        context,
        en: 'Train Boarding Ticket',
        fa: 'بلیط و رسید قطار',
        ar: 'تذكرة ركوب القطار',
        zh: '火车乘车票据',
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
                    Clipboard.setData(ClipboardData(text: reference));
                    showTravelMessage(
                      context,
                      title: l10nPick(
                        context,
                        en: 'Reference Copied',
                        fa: 'کد رهگیری کپی شد',
                        ar: 'تم نسخ الرقم المرجعي',
                        zh: '参考编号已复制',
                      ),
                      message: reference,
                    );
                  },
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Copy Ticket Code',
                      fa: 'کپی کد بلیط',
                      ar: 'نسخ رقم التذكرة',
                      zh: '复制车票编号',
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
                  backgroundColor: TravelTheme.blue,
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
          // Success Status Card
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
                          en: 'Train Ticket Issued Successfully',
                          fa: 'بلیط قطار با موفقیت صادر شد',
                          ar: 'تم إصدار تذكرة القطار بنجاح',
                          zh: '火车票已成功出票',
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
                          en: 'Present this digital voucher at the station gate.',
                          fa: 'این رسید دیجیتال را هنگام ورود به ایستگاه نشان دهید.',
                          ar: 'يرجى إبراز هذا الإيصال عند بوابة المحطة.',
                          zh: '请在进站验票口出示此电子凭证。',
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

          // Digital Ticket Card
          TravelCard(
            padding: EdgeInsetsDirectional.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ticket Header: Operator & Reference
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.train_rounded, color: TravelTheme.blue, size: 24),
                        SizedBox(width: 8.w),
                        Text(
                          operatorName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w900,
                            color: TravelTheme.ink,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: TravelTheme.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        reference,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          color: TravelTheme.blue,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Stations & Times
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          departureTime,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: TravelTheme.ink,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TravelBidiText(
                          origin,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: TravelTheme.ink,
                          ),
                        ),
                        Text(
                          localization.travelOrigin,
                          style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Icon(Icons.arrow_forward_rounded, color: TravelTheme.blue, size: 24.r),
                        SizedBox(height: 2.h),
                        Text(
                          trainName,
                          style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          arrivalTime,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: TravelTheme.ink,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        TravelBidiText(
                          destination,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: TravelTheme.ink,
                          ),
                        ),
                        Text(
                          localization.travelDestination,
                          style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Carriage & Class Info
                Row(
                  children: [
                    Expanded(
                      child: _TicketFact(
                        label: l10nPick(context, en: 'Date', fa: 'تاریخ حرکت', ar: 'التاريخ', zh: '出行日期'),
                        value: formattedDate,
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                    Expanded(
                      child: _TicketFact(
                        label: l10nPick(context, en: 'Train No.', fa: 'شماره قطار', ar: 'رقم القطار', zh: '车次'),
                        value: trainNumber,
                        icon: Icons.numbers_rounded,
                      ),
                    ),
                    Expanded(
                      child: _TicketFact(
                        label: l10nPick(context, en: 'Class', fa: 'کلاس سالن', ar: 'الدرجة', zh: '座席等级'),
                        value: trainClass,
                        icon: Icons.airline_seat_recline_extra_rounded,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Passengers List
                Text(
                  l10nPick(context, en: 'Passenger(s)', fa: 'مسافران', ar: 'المسافرون', zh: '乘车人'),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: TravelTheme.ink,
                  ),
                ),
                SizedBox(height: 8.h),
                ...passengers.asMap().entries.map((entry) {
                  final p = entry.value;
                  return Container(
                    margin: EdgeInsetsDirectional.only(bottom: 6.h),
                    padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: TravelTheme.blue.withValues(alpha: 0.1),
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w900, color: TravelTheme.blue),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              p['name'] ?? '',
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        if (p['national_code'] != null && p['national_code']!.isNotEmpty)
                          Text(
                            p['national_code']!,
                            style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted, fontFamily: 'monospace'),
                          ),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),

                // Barcode & QR Code Section
                Center(
                  child: Column(
                    children: [
                      SvgPicture.string(_generateBarcodeSvg(), height: 50.h),
                      SizedBox(height: 6.h),
                      Text(
                        reference,
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
                          en: 'Scan at the station gate barcode reader',
                          fa: 'بارکد را در گیت ورودی ایستگاه اسکن نمایید',
                          ar: 'امسح الباركود عند بوابة المحطة',
                          zh: '进站时请在闸机处扫描二维码',
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
                      '${formatMockAmount(totalPrice)} ${localization.travelMockCurrency}',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: TravelTheme.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Station Arrival Tips
          Container(
            padding: EdgeInsetsDirectional.all(14.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: TravelTheme.radius,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: TravelTheme.blue, size: 20),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Travel Guidelines',
                          fa: 'نکات مهم سفر با قطار',
                          ar: 'إرشادات السفر بالقطار',
                          zh: '乘车乘意事项',
                        ),
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          en: '• Please be at the station at least 45 minutes before departure.\n• Original national ID or passport is required.\n• Each passenger is allowed up to 30kg of personal luggage.',
                          fa: '• لطفاً حداقل ۴۵ دقیقه قبل از حرکت در ایستگاه حضور داشته باشید.\n• همراه داشتن کارت ملی یا گذرنامه برای همه مسافران الزامی است.\n• بار مجاز همراه هر مسافر تا ۳۰ کیلوگرم می‌باشد.',
                          ar: '• يرجى التواجد في المحطة قبل ٤٥ دقيقة من موعد المغادرة.\n• يلزم إحضار بطاقة الهوية الأصلية أو جواز السفر.\n• الحد المسموح به للأمتعة هو ٣٠ كجم لكل راكب.',
                          zh: '• 请在发车前至少45分钟抵达车站。\n• 乘车必须携带有效身份证件原件或护照。\n• 每位乘客免费携带行李额度为30公斤。',
                        ),
                        style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted, height: 1.5),
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

class _TicketFact extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _TicketFact({
    required this.label,
    required this.value,
    required this.icon,
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
            Text(
              label,
              style: TextStyle(fontSize: 10.5.sp, color: TravelTheme.muted, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
            color: TravelTheme.ink,
          ),
        ),
      ],
    );
  }
}
