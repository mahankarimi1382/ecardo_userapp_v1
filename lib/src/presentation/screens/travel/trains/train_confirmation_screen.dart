import 'package:barcode/barcode.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

import 'train_models.dart';

/// Digital Train Ticket / Mobile Rail Pass Voucher (UIC 918-3 & European Pattern)
/// Upgraded to ECardoTokens with Aztec / QR barcode generation,
/// sleeper berth indicators, connection safety alerts, and responsive dark/light support.
class TrainConfirmationScreen extends StatefulWidget {
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
  final String? originStation;
  final String? destinationStation;
  final String? departurePlatform;
  final String? arrivalPlatform;
  final TrainCategory? category;
  final SleeperBerthType? sleeperType;
  final CompartmentGenderRule? genderRule;
  final RailPassVoucherType voucherType;
  final ConnectionTransferInfo? transferInfo;
  final List<IntermediateStop>? intermediateStops;

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
    this.originStation,
    this.destinationStation,
    this.departurePlatform,
    this.arrivalPlatform,
    this.category,
    this.sleeperType,
    this.genderRule,
    this.voucherType = RailPassVoucherType.aztec,
    this.transferInfo,
    this.intermediateStops,
  });

  @override
  State<TrainConfirmationScreen> createState() => _TrainConfirmationScreenState();
}

class _TrainConfirmationScreenState extends State<TrainConfirmationScreen> {
  late RailPassVoucherType _activeVoucherType;
  bool _showAllStops = false;

  @override
  void initState() {
    super.initState();
    _activeVoucherType = widget.voucherType;
  }

  String _generateBarcodeSvg() {
    final barcode = Barcode.code128();
    return barcode.toSvg(
      widget.reference,
      width: 260,
      height: 52,
      drawText: false,
    );
  }

  String _generatePassBarcodeSvg() {
    final content = 'UIC918-3:${widget.reference}:${widget.trainNumber}:${widget.origin}:${widget.destination}';
    if (_activeVoucherType == RailPassVoucherType.aztec) {
      final barcode = Barcode.aztec();
      return barcode.toSvg(
        content,
        width: 140,
        height: 140,
      );
    } else {
      final barcode = Barcode.qrCode();
      return barcode.toSvg(
        content,
        width: 140,
        height: 140,
      );
    }
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'en_US');
    return '${formatter.format(amount)} Toman';
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.departureDate);

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: ECardoTokens.ink(context),
          ),
          onPressed: () => Get.offAllNamed(BaseRoute.travel),
        ),
        title: Text(
          l10nPick(
            context,
            en: 'Train Boarding Voucher',
            fa: 'بلیط دیجیتال و رسید قطار',
            ar: 'تذكرة ركوب القطار الإلكترونية',
            zh: '火车乘车电子客票',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    ),
                    side: BorderSide(color: ECardoTokens.border(context)),
                  ),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.reference));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10nPick(
                            context,
                            en: 'Booking reference copied: ${widget.reference}',
                            fa: 'کد رهگیری کپی شد: ${widget.reference}',
                            ar: 'تم نسخ الرقم المرجعي: ${widget.reference}',
                            zh: '预订参考号已复制：${widget.reference}',
                          ),
                        ),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: ECardoTokens.brand900(context),
                      ),
                    );
                  },
                  child: Text(
                    l10nPick(
                      context,
                      en: 'Copy Code',
                      fa: 'کپی کد بلیط',
                      ar: 'نسخ الرمز',
                      zh: '复制车票码',
                    ),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.ink(context),
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
                  textColor: ECardoTokens.inkOnBrand,
                  backgroundColor: ECardoTokens.brand500(context),
                  borderRadius: ECardoTokens.radiusMd,
                  onPressed: () => Get.offAllNamed(BaseRoute.travel),
                ),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          // Success Status Card (ECardoTokens)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: ECardoTokens.successBg(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
              border: Border.all(
                color: ECardoTokens.success(context).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: ECardoTokens.success(context),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Train Ticket Confirmed & Issued',
                          fa: 'بلیط قطار با موفقیت صادر شد',
                          ar: 'تم تأكيد وإصدار تذكرة القطار بنجاح',
                          zh: '车票已成功确认并出票',
                        ),
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.success(context),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Present the Aztec/QR barcode at station ticket barriers.',
                          fa: 'بارکد آزتک / کیوآر را در گیت ورودی ایستگاه اسکن نمایید.',
                          ar: 'يرجى إبراز باركود آزتك / QR عند بوابات المحطة.',
                          zh: '进站时请在闸机处扫描 Aztec / QR 二维码。',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Main Digital Pass Boarding Card
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
              border: Border.all(color: ECardoTokens.border(context)),
              boxShadow: ECardoTokens.shadowCard(context),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Operator & Train Badges & PNR
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8.r),
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand100(context),
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                          ),
                          child: Icon(
                            widget.category?.icon ?? Icons.train_rounded,
                            color: ECardoTokens.brand500(context),
                            size: 20.r,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.operatorName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w900,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                            Text(
                              widget.trainName,
                              style: TextStyle(
                                fontSize: 10.5.sp,
                                color: ECardoTokens.inkMuted(context),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: ECardoTokens.brand100(context),
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                        border: Border.all(color: ECardoTokens.brand500(context).withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        widget.reference,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace',
                          color: ECardoTokens.brand700(context),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),
                Divider(color: ECardoTokens.border(context), height: 1),
                SizedBox(height: 18.h),

                // Stations, Platforms & Schedule
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Origin
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.departureTime,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          TravelBidiText(
                            widget.origin,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                          if (widget.originStation != null)
                            Text(
                              widget.originStation!,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: ECardoTokens.inkMuted(context),
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: ECardoTokens.surfaceSunken(context),
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                            ),
                            child: Text(
                              widget.departurePlatform ?? 'Platform 1',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Train Arrow & Category
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Column(
                        children: [
                          Icon(
                            Icons.arrow_forward_rounded,
                            color: ECardoTokens.brand500(context),
                            size: 22.r,
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: ECardoTokens.brand100(context),
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                            ),
                            child: Text(
                              widget.category != null
                                  ? widget.category!.localizedLabel(context, isRtl: isRtl)
                                  : 'Rail Express',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: ECardoTokens.brand700(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Destination
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            widget.arrivalTime,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                          SizedBox(height: 3.h),
                          TravelBidiText(
                            widget.destination,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                          if (widget.destinationStation != null)
                            Text(
                              widget.destinationStation!,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: ECardoTokens.inkMuted(context),
                              ),
                            ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: ECardoTokens.surfaceSunken(context),
                              borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                            ),
                            child: Text(
                              widget.arrivalPlatform ?? 'Platform 2',
                              style: TextStyle(
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w700,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),
                Divider(color: ECardoTokens.border(context), height: 1),
                SizedBox(height: 16.h),

                // Key Facts Row (Date, Train No, Class & Sleeper)
                Row(
                  children: [
                    Expanded(
                      child: _VoucherFact(
                        label: l10nPick(context, en: 'Travel Date', fa: 'تاریخ سفر', ar: 'تاريخ السفر', zh: '出行日期'),
                        value: formattedDate,
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                    Expanded(
                      child: _VoucherFact(
                        label: l10nPick(context, en: 'Train No.', fa: 'شماره قطار', ar: 'رقم القطار', zh: '车次'),
                        value: widget.trainNumber,
                        icon: Icons.numbers_rounded,
                      ),
                    ),
                    Expanded(
                      child: _VoucherFact(
                        label: l10nPick(context, en: 'Class', fa: 'کلاس سالن', ar: 'الدرجة', zh: '席别'),
                        value: widget.sleeperType != null
                            ? widget.sleeperType!.localizedTitle(isRtl: isRtl)
                            : widget.trainClass,
                        icon: widget.sleeperType?.icon ?? Icons.airline_seat_recline_extra_rounded,
                      ),
                    ),
                  ],
                ),

                // Gender Rule & Coupe Badge if applicable
                if (widget.genderRule != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: ECardoTokens.sand100(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(color: ECardoTokens.sand400(context).withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(widget.genderRule!.icon, color: ECardoTokens.sand600(context), size: 18.r),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            widget.genderRule!.localizedTitle(isRtl: isRtl),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: ECardoTokens.sand600(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Connection Safety Information Banner if Transfer
                if (widget.transferInfo != null) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: widget.transferInfo!.safetyLevel.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(
                        color: widget.transferInfo!.safetyLevel.color.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          widget.transferInfo!.safetyLevel.icon,
                          color: widget.transferInfo!.safetyLevel.color,
                          size: 20.r,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.transferInfo!.localizedTitle(isRtl: isRtl),
                                style: TextStyle(
                                  fontSize: 11.5.sp,
                                  fontWeight: FontWeight.w800,
                                  color: widget.transferInfo!.safetyLevel.color,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                '${widget.transferInfo!.stationName} · ${widget.transferInfo!.arrivalPlatform} → ${widget.transferInfo!.departurePlatform}',
                                style: TextStyle(
                                  fontSize: 10.sp,
                                  color: widget.transferInfo!.safetyLevel.color.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 18.h),
                Divider(color: ECardoTokens.border(context), height: 1),
                SizedBox(height: 16.h),

                // Passengers List
                Text(
                  l10nPick(context, en: 'Passenger(s) & Berth Allocation', fa: 'مسافران و تخت‌های تخصیص‌یافته', ar: 'المسافرون وتخصيص المقاعد', zh: '乘车人及座位/铺位分配'),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                SizedBox(height: 8.h),

                ...widget.passengers.asMap().entries.map((entry) {
                  final p = entry.value;
                  final seatNumber = p['seat'] ?? 'Carriage 3 / Berth ${entry.key + 12}';
                  return Container(
                    margin: EdgeInsets.only(bottom: 8.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(color: ECardoTokens.border(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12.r,
                              backgroundColor: ECardoTokens.brand100(context),
                              child: Text(
                                '${entry.key + 1}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w900,
                                  color: ECardoTokens.brand500(context),
                                ),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p['name']?.isNotEmpty == true ? p['name']! : 'Passenger ${entry.key + 1}',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w700,
                                    color: ECardoTokens.ink(context),
                                  ),
                                ),
                                if (p['national_code'] != null && p['national_code']!.isNotEmpty)
                                  Text(
                                    'ID: ${p['national_code']!}',
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontFamily: 'monospace',
                                      color: ECardoTokens.inkMuted(context),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand100(context),
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                          ),
                          child: Text(
                            seatNumber,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.brand700(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                // Intermediate stops toggle if available
                if (widget.intermediateStops != null && widget.intermediateStops!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () => setState(() => _showAllStops = !_showAllStops),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 6.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10nPick(
                              context,
                              en: 'Route & Intermediate Stops (${widget.intermediateStops!.length})',
                              fa: 'ایستگاه‌های بین‌راهی (${widget.intermediateStops!.length} ایستگاه)',
                              ar: 'محطات المسار (${widget.intermediateStops!.length})',
                              zh: '途径站点信息 (${widget.intermediateStops!.length} 站)',
                            ),
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                              color: ECardoTokens.brand500(context),
                            ),
                          ),
                          Icon(
                            _showAllStops ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                            color: ECardoTokens.brand500(context),
                            size: 18.r,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showAllStops) ...[
                    SizedBox(height: 8.h),
                    _ConfirmationStopTimeline(stops: widget.intermediateStops!),
                  ],
                ],

                SizedBox(height: 18.h),
                Divider(color: ECardoTokens.border(context), height: 1),
                SizedBox(height: 18.h),

                // European Mobile Rail Pass Voucher (UIC 918-3 Aztec / QR)
                Center(
                  child: Column(
                    children: [
                      // Linear barcode 128
                      SvgPicture.string(
                        _generateBarcodeSvg(),
                        height: 48.h,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        widget.reference,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Barcode format switcher
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ChoiceChip(
                            label: Text(
                              'UIC 918-3 Aztec',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: _activeVoucherType == RailPassVoucherType.aztec
                                    ? ECardoTokens.inkOnBrand
                                    : ECardoTokens.ink(context),
                              ),
                            ),
                            selected: _activeVoucherType == RailPassVoucherType.aztec,
                            selectedColor: ECardoTokens.brand900(context),
                            backgroundColor: ECardoTokens.surfaceSunken(context),
                            onSelected: (_) => setState(() => _activeVoucherType = RailPassVoucherType.aztec),
                          ),
                          SizedBox(width: 8.w),
                          ChoiceChip(
                            label: Text(
                              'Standard QR Code',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: _activeVoucherType == RailPassVoucherType.qrCode
                                    ? ECardoTokens.inkOnBrand
                                    : ECardoTokens.ink(context),
                              ),
                            ),
                            selected: _activeVoucherType == RailPassVoucherType.qrCode,
                            selectedColor: ECardoTokens.brand900(context),
                            backgroundColor: ECardoTokens.surfaceSunken(context),
                            onSelected: (_) => setState(() => _activeVoucherType = RailPassVoucherType.qrCode),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // 2D Barcode container (Aztec or QR)
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                          border: Border.all(color: ECardoTokens.border(context)),
                          boxShadow: ECardoTokens.shadowCard(context),
                        ),
                        child: SvgPicture.string(
                          _generatePassBarcodeSvg(),
                          width: 140.r,
                          height: 140.r,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        _activeVoucherType == RailPassVoucherType.aztec
                            ? 'UIC 918-3 European Rail Pass Secure Aztec Code'
                            : 'Standard ISO QR Code for Station Turnstiles',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: ECardoTokens.inkMuted(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 20.h),
                Divider(color: ECardoTokens.border(context), height: 1),
                SizedBox(height: 16.h),

                // Total Fare Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization?.travelTotal ?? 'Total Fare',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                    Text(
                      _formatAmount(widget.totalPrice),
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.brand900(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          // Station Arrival Tips Banner
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: ECardoTokens.surfaceSunken(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
              border: Border.all(color: ECardoTokens.border(context)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: ECardoTokens.brand500(context),
                  size: 20.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Railway Travel Guidelines',
                          fa: 'نکات مهم سفر با قطار',
                          ar: 'إرشادات السفر بالقطار',
                          zh: '乘车乘意事项',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(
                          context,
                          en: '• Please arrive at the station at least 30-45 minutes before departure.\n• Original national ID or passport required for all passengers.\n• Luggage allowance: 30kg personal luggage per passenger.\n• Sleeper carriages provide fresh linens, blanket, and amenity kit.',
                          fa: '• لطفاً حداقل ۳۰ تا ۴۵ دقیقه قبل از زمان حرکت در ایستگاه حضور داشته باشید.\n• همراه داشتن کارت شناسایی ملی معتبر یا گذرنامه برای همه مسافران الزامی است.\n• بار مجاز همراه هر مسافر ۳۰ کیلوگرم می‌باشد.\n• در کوپه‌های خواب ملحفه، بالش، پتو و بسته پذیرایی در اختیار مسافر قرار می‌گیرد.',
                          ar: '• يرجى التواجد في المحطة قبل 30-45 دقيقة من موعد المغادرة.\n• يلزم إبراز بطاقة الهوية الوطنية أو جواز السفر لجميع المسافرين.\n• الحد المسموح به للأمتعة هو 30 كجم لكل راكب.\n• توفر عربات النوم بياضات نظيفة وبطانية ومستلزمات الراحة.',
                          zh: '• 请在发车前至少30-45分钟抵达车站候车。\n• 所有乘客乘车时必须携带有效身份证件或护照原件。\n• 每位乘客免费行李额度为30公斤。\n• 卧铺车厢提供干净卧具、毛毯和旅行洗漱包。',
                        ),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: ECardoTokens.inkMuted(context),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _VoucherFact extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _VoucherFact({
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
            Icon(icon, size: 14.r, color: ECardoTokens.inkMuted(context)),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: ECardoTokens.inkMuted(context),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}

class _ConfirmationStopTimeline extends StatelessWidget {
  final List<IntermediateStop> stops;

  const _ConfirmationStopTimeline({required this.stops});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(stops.length, (index) {
        final stop = stops[index];
        final isLast = index == stops.length - 1;
        final isFirst = index == 0;

        return Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 6.r,
                  backgroundColor: stop.isMajorHub
                      ? ECardoTokens.brand500(context)
                      : ECardoTokens.inkMuted(context),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.stationName,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: isFirst || isLast ? FontWeight.w800 : FontWeight.w600,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      Text(
                        'Platform ${stop.platform}',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      stop.departureTime,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    if (!isFirst)
                      Text(
                        stop.arrivalTime,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 14.h,
                margin: EdgeInsets.only(left: isFirst ? 5.w : 5.w),
                color: ECardoTokens.border(context),
              ),
          ],
        );
      }),
    );
  }
}
