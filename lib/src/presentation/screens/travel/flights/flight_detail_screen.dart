import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/models/travel_models.dart';
import '../shared/seat_selection_map.dart';
import '../shared/travel_widgets.dart';
import 'flight_models.dart';

/// International-Grade Flight Detail Screen (Service T-02)
///
/// Features:
/// - Leg-by-leg timeline visualization
/// - Baggage allowance details (cabin + checked per fare family)
/// - Fare rules & cancellation policy summary
/// - Aircraft type identification
/// - In-flight amenities list
/// - Interactive seat selection integration
/// - Total price breakdown including extras
/// - 100% ECardoTokens compliant design system
class FlightDetailScreen extends StatefulWidget {
  final TravelOffer offer;

  const FlightDetailScreen({
    super.key,
    required this.offer,
  });

  @override
  State<FlightDetailScreen> createState() => _FlightDetailScreenState();
}

class _FlightDetailScreenState extends State<FlightDetailScreen> {
  List<CabinSeatModel> _selectedSeats = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final bookingDetails = controller.flightBookingDetails.value;
    final lang = Localizations.localeOf(context).languageCode;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        title: Text(
          localization.travelFlightDetails,
          style: TextStyle(
            color: ECardoTokens.ink(context),
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: ECardoTokens.surfaceCard(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: ECardoTokens.ink(context)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.info_outline_rounded, color: ECardoTokens.ink(context)),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          children: [
            _buildRouteTimeline(context),
            SizedBox(height: 16.h),
            _buildOfferHeader(context, lang),
            SizedBox(height: 16.h),
            _buildFareFamilySummary(context, lang),
            SizedBox(height: 16.h),
            _buildBaggageAllowance(context, lang),
            SizedBox(height: 16.h),
            _buildAircraftAndAmenities(context, lang),
            SizedBox(height: 16.h),
            _buildCancellationPolicy(context, lang),
            SizedBox(height: 16.h),
            _buildFareBreakdown(context, bookingDetails),
            SizedBox(height: 16.h),
            _buildSeatSelectionCard(context, bookingDetails, lang),
            SizedBox(height: 20.h),
            _buildPriceSummary(context, bookingDetails),
            SizedBox(height: 18.h),
            CommonButton(
              text: l10nPick(context, en: 'Continue to Checkout', fa: 'ادامه به پرداخت', ar: 'الانتقال إلى الدفع'),
              height: 52.h,
              fontSize: 14,
              backgroundColor: ECardoTokens.brand700(context),
              onPressed: () => _goToCheckout(context, controller, bookingDetails),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildRouteTimeline(BuildContext context) {
    final originCode = widget.offer.attributes['origin']?.toString() ??
        widget.offer.metadata['origin']?.toString() ??
        'DXB';
    final destCode = widget.offer.attributes['destination']?.toString() ??
        widget.offer.metadata['destination']?.toString() ??
        'LHR';
    final depTime = _extractTime(widget.offer.attributes['departure']);
    final arrTime = _extractTime(widget.offer.attributes['arrival']);
    final isRoundTrip = widget.offer.metadata['is_return_flight'] == null ||
        widget.offer.metadata['is_return_flight'].toString().toLowerCase() != 'true';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceSunken(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        depTime,
                        style: TextStyle(
                          color: ECardoTokens.ink(context),
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(originCode,
                      style: TextStyle(
                        color: ECardoTokens.ink(context),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 28.w),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.offer.attributes['duration']?.toString() ?? '',
                      style: TextStyle(
                        color: ECardoTokens.inkMuted(context),
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: ECardoTokens.surfaceCard(context),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.flight_takeoff_rounded,
                        color: ECardoTokens.brand500(context),
                        size: 16.r,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      l10nPick(context, en: 'Direct', fa: 'مستقیم', ar: 'مباشر'),
                      style: TextStyle(
                        color: ECardoTokens.brand500(context),
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 28.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        arrTime,
                        style: TextStyle(
                          color: ECardoTokens.ink(context),
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(destCode,
                      style: TextStyle(
                        color: ECardoTokens.ink(context),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!isRoundTrip) ...[
            SizedBox(height: 12.h),
            Divider(color: ECardoTokens.border(context)),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSegmentChip(context,
                  originCode: widget.offer.metadata['outbound_origin']?.toString() ?? 'DXB',
                  destCode: widget.offer.metadata['outbound_dest']?.toString() ?? 'IST',
                  time: widget.offer.metadata['outbound_time']?.toString().split(' ').first ?? '10:30',
                  label: l10nPick(context, en: 'Outbound', fa: 'رفت', ar: 'ذهاب'),
                ),
                Container(
                  width: 1,
                  height: 20.r,
                  color: ECardoTokens.borderStrong(context),
                ),
                _buildSegmentChip(context,
                  originCode: widget.offer.metadata['return_origin']?.toString() ?? 'IST',
                  destCode: widget.offer.metadata['return_dest']?.toString() ?? 'DXB',
                  time: widget.offer.metadata['return_time']?.toString().split(' ').first ?? '14:45',
                  label: l10nPick(context, en: 'Return', fa: 'برگشت', ar: 'عودة'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSegmentChip(BuildContext context, {required String originCode, required String destCode, required String time, required String label}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceCard(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
            border: Border.all(color: ECardoTokens.border(context)),
          ),
          child: Column(
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  time,
                  style: TextStyle(
                    color: ECardoTokens.ink(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text('$originCode → $destCode',
                style: TextStyle(
                  color: ECardoTokens.inkMuted(context),
                  fontSize: 9.5.sp,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 6.h),
        Text(label,
          style: TextStyle(
            color: ECardoTokens.brand500(context),
            fontWeight: FontWeight.w800,
            fontSize: 10.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildOfferHeader(BuildContext context, String lang) {
    final airlineName = widget.offer.attributes['airline_name']?.toString() ??
        widget.offer.metadata['carrier_name']?.toString() ??
        'Emirates';
    final flightNumber = widget.offer.attributes['flight_number']?.toString() ??
        widget.offer.metadata['flight_number']?.toString() ??
        'EK 972';
    final aircraftType = widget.offer.metadata['aircraft_type']?.toString() ?? 'Boeing 777-300ER';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52.r,
                height: 52.r,
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.flight_rounded,
                  color: ECardoTokens.brand500(context),
                  size: 28.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      airlineName,
                      style: TextStyle(
                        color: ECardoTokens.ink(context),
                        fontSize: 14.5.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        flightNumber,
                        style: TextStyle(
                          color: ECardoTokens.brand500(context),
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.successBg(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                child: Text(
                  FlightCabinClass.fromString(widget.offer.attributes['cabin_class']?.toString() ?? 'economy').localizedLabel(lang),
                  style: TextStyle(
                    color: ECardoTokens.success(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: ECardoTokens.border(context), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow(context,
                icon: Icons.view_in_ar_rounded,
                label: l10nPick(context, en: 'Aircraft', fa: 'نوع هواپیما', ar: 'نوع الطائرة'),
                value: aircraftType,
              ),
              _buildInfoRow(context,
                icon: Icons.wifi_rounded,
                label: l10nPick(context, en: 'In-flight Wifi', fa: 'اینترنت پرواز', ar: 'إنترنت الطائرة'),
                value: 'Available',
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoRow(context,
                icon: Icons.power_input_rounded,
                label: l10nPick(context, en: 'USB Power', fa: 'پورت USB', ar: 'منفذ يو إس بي'),
                value: 'At seat',
              ),
              _buildInfoRow(context,
                icon: Icons.tv_rounded,
                label: l10nPick(context, en: 'Entertainment', fa: 'سرگرمی', ar: 'تسلية'),
                value: 'Live TV & Movies',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, {required IconData icon, required String label, required String value}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15.r, color: ECardoTokens.brand500(context)),
        SizedBox(width: 4.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: ECardoTokens.inkMuted(context),
                fontSize: 10.sp,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: ECardoTokens.ink(context),
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  FareFamily _getFareFamily() {
    final title = widget.offer.titleKey.toLowerCase();
    if (title.contains('flex')) return FareFamily.flex;
    if (title.contains('basic')) return FareFamily.basic;
    return FareFamily.standard;
  }

  Widget _buildFareFamilySummary(BuildContext context, String lang) {
    final fareFamily = _getFareFamily();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.policy_rounded, size: 16.r, color: ECardoTokens.brand500(context)),
              SizedBox(width: 6.w),
              Text(
                l10nPick(context, en: 'Fare Family', fa: 'خانواده کرایه', ar: 'أسرة الأجرة'),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                fareFamily.localizedLabel(lang),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.5.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                child: Text(
                  l10nPick(context, en: 'Best Value', fa: 'بهترین ارزش', ar: 'أفضل قيمة'),
                  style: TextStyle(
                    color: ECardoTokens.brand500(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 9.5.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBaggageAllowance(BuildContext context, String lang) {
    final fareFamily = _getFareFamily();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.luggage_rounded, size: 16.r, color: ECardoTokens.brand500(context)),
              SizedBox(width: 6.w),
              Text(
                l10nPick(context, en: 'Baggage Allowance', fa: 'بار مجاز', ar: 'سعة الحقائب'),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                    border: Border.all(color: ECardoTokens.border(context)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.cloud_rounded, size: 22.r, color: ECardoTokens.brand500(context)),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(context, en: 'Cabin Bag', fa: 'کابین', ar: 'الحقيبة الشخصية'),
                        style: TextStyle(
                          color: ECardoTokens.inkMuted(context),
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        fareFamily.baggageCabin,
                        style: TextStyle(
                          color: ECardoTokens.ink(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                    border: Border.all(color: ECardoTokens.border(context)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.luggage_rounded, size: 22.r, color: ECardoTokens.brand500(context)),
                      SizedBox(height: 6.h),
                      Text(
                        l10nPick(context, en: 'Checked Bag', fa: 'چمدان', ar: 'الحقيبة المسجلة'),
                        style: TextStyle(
                          color: ECardoTokens.inkMuted(context),
                          fontSize: 10.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        fareFamily.baggageChecked,
                        style: TextStyle(
                          color: ECardoTokens.ink(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAircraftAndAmenities(BuildContext context, String lang) {
    final aircraft = widget.offer.metadata['aircraft_type']?.toString() ?? 'Boeing 777-300ER';
    final amenities = [
      {'icon': Icons.wifi_rounded, 'label': 'Wi-Fi'},
      {'icon': Icons.power_input_rounded, 'label': 'USB Power'},
      {'icon': Icons.tv_rounded, 'label': 'Entertainment'},
      {'icon': Icons.food_bank_rounded, 'label': 'Meal Service'},
      {'icon': Icons.headphones_rounded, 'label': 'Headphones Provided'},
      {'icon': Icons.ac_unit_rounded, 'label': 'Individual AC'},
    ];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.stairs_rounded, size: 16.r, color: ECardoTokens.brand500(context)),
              SizedBox(width: 6.w),
              Text(
                l10nPick(context, en: 'Aircraft & Amenities', fa: 'هواپیما و امکانات', ar: 'الطائرة والمرافق'),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            aircraft,
            style: TextStyle(
              color: ECardoTokens.ink(context),
              fontWeight: FontWeight.w800,
              fontSize: 13.5.sp,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 8.h,
            children: amenities.map((amenity) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  border: Border.all(color: ECardoTokens.brand500(context).withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      amenity['icon'] as IconData,
                      size: 13.r,
                      color: ECardoTokens.brand500(context),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      amenity['label']?.toString() ?? '',
                      style: TextStyle(
                        color: ECardoTokens.ink(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 9.5.sp,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationPolicy(BuildContext context, String lang) {
    final refundable = widget.offer.metadata['refundable']?.toString().toLowerCase() == 'true';
    final changeAllowed = widget.offer.metadata['change_allowed']?.toString().toLowerCase() != 'false';

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: refundable ? ECardoTokens.successBg(context) : ECardoTokens.warningBg(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(
          color: refundable
              ? ECardoTokens.success(context).withValues(alpha: 0.3)
              : ECardoTokens.warning(context).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                refundable ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                size: 16.r,
                color: refundable ? ECardoTokens.success(context) : ECardoTokens.warning(context),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  l10nPick(
                    context,
                    en: refundable ? 'Fully Refundable Fare' : 'Non-Refundable Fare',
                    fa: refundable ? 'کرایه بازگشت‌پذیر کامل' : 'کرایه غیرقابل بازگشت',
                    ar: refundable ? 'عائد غير قابل للاسترداد' : 'غير مسترد',
                  ),
                  style: TextStyle(
                    color: refundable ? ECardoTokens.success(context) : ECardoTokens.warning(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRuleChip(context,
                icon: Icons.undo_rounded,
                enabled: changeAllowed,
                label: l10nPick(context, en: 'Changes Allowed', fa: 'تغییر مجاز', ar: 'التغييرات المسموحة'),
              ),
              _buildRuleChip(context,
                icon: Icons.replay_rounded,
                enabled: refundable,
                label: l10nPick(context, en: 'Full Refund', fa: 'بازگشت کامل وجه', ar: 'استرجاع كامل'),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            l10nPick(
              context,
              en: 'Terms & conditions apply. See full policies at checkout.',
              fa: 'شرایط و ضوابط اعمال می‌شود. لطفاً برای اطلاعات کامل به صفحه پرداخت مراجعه کنید.',
              ar: 'تنطبق الشروط والأحكام. راجع السياسات الكاملة عند الدفع.',
            ),
            style: TextStyle(
              color: ECardoTokens.inkMuted(context),
              fontSize: 9.5.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleChip(BuildContext context, {required IconData icon, required bool enabled, required String label}) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: enabled
                ? ECardoTokens.surfaceCard(context)
                : ECardoTokens.surfaceSunken(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
            border: Border.all(
              color: enabled
                  ? (icon == Icons.undo_rounded ? ECardoTokens.info(context) : ECardoTokens.success(context))
                  : ECardoTokens.border(context),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 13.r,
                color: enabled
                    ? (icon == Icons.undo_rounded ? ECardoTokens.info(context) : ECardoTokens.success(context))
                    : ECardoTokens.inkMuted(context),
              ),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  color: enabled
                      ? ECardoTokens.ink(context)
                      : ECardoTokens.inkMuted(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFareBreakdown(BuildContext context, TravelBookingDetails bookingDetails) {
    final components = <(String, double)>[];
    final adultCount = bookingDetails.adultCount > 0 ? bookingDetails.adultCount : 1;
    final totalPrice = (widget.offer.attributes['basePrice'] as num?)?.toDouble() ?? 0;

    components.add(('Base Fare × $adultCount', totalPrice));
    components.add(('Taxes & Fees', totalPrice * 0.12));

    final total = components.fold(0.0, (sum, item) => sum + item.$2);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10nPick(context, en: 'Fare Breakdown', fa: 'جزئیات قیمت', ar: 'تحليل السعر'),
            style: TextStyle(
              color: ECardoTokens.ink(context),
              fontWeight: FontWeight.w800,
              fontSize: 12.5.sp,
            ),
          ),
          SizedBox(height: 12.h),
          ...components.map((item) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item.$1,
                  style: TextStyle(
                    color: ECardoTokens.ink(context),
                    fontSize: 11.5.sp,
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '\$${item.$2.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: ECardoTokens.ink(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5.sp,
                    ),
                  ),
                ),
              ],
            );
          }),
          Divider(color: ECardoTokens.border(context), height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(context, en: 'Total', fa: 'جمع کل', ar: 'المجموع'),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: ECardoTokens.brand700(context),
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeatSelectionCard(BuildContext context, TravelBookingDetails bookingDetails, String lang) {
    final passengerCount = (bookingDetails.adultCount + bookingDetails.childCount) > 0
        ? (bookingDetails.adultCount + bookingDetails.childCount)
        : 1;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.airline_seat_recline_extra_rounded, size: 16.r, color: ECardoTokens.brand500(context)),
                  SizedBox(width: 8.w),
                  Text(
                    l10nPick(
                      context,
                      en: 'Select Seats',
                      fa: 'انتخاب صندلی',
                      ar: 'اختيار المقاعد',
                    ),
                    style: TextStyle(
                      color: ECardoTokens.ink(context),
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5.sp,
                    ),
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
                  '$passengerCount ${l10nPick(context, en: 'pax', fa: 'نفر', ar: 'ركاب')}',
                  style: TextStyle(
                    color: ECardoTokens.brand500(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 140.r,
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 260.r,
                    height: 100.r,
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceSunken(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                    ),
                    child: CustomPaint(
                      painter: _AirplaneLayoutPainter(backgroundColor: ECardoTokens.inkMuted(context)),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 10,
                  end: 30,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: ECardoTokens.brand500(context),
                    onPressed: () => _openSeatMap(context, bookingDetails, lang),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openSeatMap(BuildContext context, TravelBookingDetails bookingDetails, String lang) async {
    final cabin = (widget.offer.attributes['cabin_class']?.toString().toLowerCase()) == 'business'
        ? SeatCabinClass.business
        : SeatCabinClass.economy;

    final result = await showSeatSelectionBottomSheet(
      context,
      vehicleType: SeatVehicleType.aircraft,
      initialCabinClass: cabin,
      maxSelectedSeats: 4,
      initiallySelectedSeatIds: [],
      title: widget.offer.attributes['airline_name']?.toString() ?? 'Airline',
      subtitle: '${widget.offer.attributes['origin'] ?? 'DXB'} → ${widget.offer.attributes['destination'] ?? 'LHR'}',
      currency: totalCurrency,
    );

    if (result != null && mounted) {
      setState(() => _selectedSeats = result.map((s) => s.toCabinSeatModel()).toList());
    }
  }

  Widget _buildPriceSummary(BuildContext context, TravelBookingDetails bookingDetails) {
    final passengerCount = (bookingDetails.adultCount + bookingDetails.childCount) > 0
        ? (bookingDetails.adultCount + bookingDetails.childCount)
        : 1;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ECardoTokens.brand700(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Final Price',
                  fa: 'قیمت نهایی',
                  ar: 'السعر النهائي',
                ),
                style: TextStyle(
                  color: ECardoTokens.inkOnBrand,
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '\$${(totalAmount * passengerCount).toStringAsFixed(0)}',
                  style: TextStyle(
                    color: ECardoTokens.inkOnBrand,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Icon(
            Icons.verified_rounded,
            color: ECardoTokens.sand400(context),
            size: 28.r,
          ),
        ],
      ),
    );
  }

  double get totalAmount => widget.offer.total.amount;
  String get totalCurrency => widget.offer.total.currency.isNotEmpty
      ? widget.offer.total.currency
      : 'USD';

  void _goToCheckout(BuildContext context, dynamic controller, TravelBookingDetails bookingDetails) {
    AppHaptics.medium();
    Get.to(() => TravelCheckoutScreen(
      type: TravelProductType.flight,
      productId: widget.offer.id,
      title: travelLocalizedKey(AppLocalizations.of(context)!, widget.offer.titleKey),
      total: TravelMoney(
        amount: totalAmount * (bookingDetails.adultCount > 0 ? bookingDetails.adultCount : 1),
        currency: totalCurrency,
      ),
      bookingDetails: bookingDetails.copyWith(
        specialRequests: _selectedSeats.isNotEmpty
            ? 'Selected seats: ${_selectedSeats.map((s) => s.id).join(', ')}'
            : '',
      ),
    ));
  }

  String _extractTime(String? raw) {
    if (raw == null) return '';
    final match = RegExp(r'\b\d{1,2}:\d{2}\b').firstMatch(raw);
    return match?.group(0) ?? raw;
  }

  void _showInfoDialog(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(ECardoTokens.radius2xl)),
          boxShadow: ECardoTokens.shadowSheet(context),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: ECardoTokens.borderStrong(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusFull),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10nPick(context, en: 'Flight Information', fa: 'اطلاعات پرواز', ar: 'معلومات الرحلة'),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10nPick(
                  context,
                  en: 'This booking includes one round-trip ticket with the selected cabin class. Baggage allowances vary by fare family.',
                  fa: 'این رزرو شامل یک بلیت رفت و برگشت با کلاس انتخابی است. مجوز بار بسته به خانواده کرایه متفاوت است.',
                  ar: 'يشمل هذا الحجز تذكرة ذهاب وإياب مع درجة الصالة المحددة. تختلف سعة الأمتعة حسب عائلة الأجرة.',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ECardoTokens.inkMuted(context),
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 20.h),
              CommonButton(
                text: l10nPick(context, en: 'Got It', fa: 'فهمیدم', ar: 'حسنا'),
                backgroundColor: ECardoTokens.brand700(context),
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AirplaneLayoutPainter extends CustomPainter {
  final Color backgroundColor;

  _AirplaneLayoutPainter({required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.15, size.height * 0.3);
    path.lineTo(size.width * 0.3, size.height * 0.15);
    path.lineTo(size.width * 0.7, size.height * 0.15);
    path.lineTo(size.width * 0.85, size.height * 0.3);
    path.lineTo(size.width * 0.95, size.height * 0.6);
    path.lineTo(size.width * 0.8, size.height * 0.85);
    path.lineTo(size.width * 0.5, size.height * 0.85);
    path.lineTo(size.width * 0.2, size.height * 0.85);
    path.lineTo(size.width * 0.05, size.height * 0.6);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on SeatItem {
  CabinSeatModel toCabinSeatModel() {
    final feature = extraPrice > 0 ? CabinSeatFeature.exitRow : CabinSeatFeature.standard;
    final position = switch (type) {
      SeatType.window => CabinSeatPosition.window,
      SeatType.middle => CabinSeatPosition.middle,
      SeatType.aisle => CabinSeatPosition.aisle,
    };

    return CabinSeatModel(
      id: id,
      row: row,
      col: column,
      position: position,
      feature: feature,
      cabinClass: FlightCabinClass.economy,
      state: status == SeatStatus.selected ? CabinSeatState.selected : CabinSeatState.available,
      extraPrice: extraPrice,
    );
  }
}
