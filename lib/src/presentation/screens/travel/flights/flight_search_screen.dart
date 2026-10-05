import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';
import 'flight_models.dart';
import 'flight_list_screen.dart';

/// International-Grade Flight Search Screen (Service T-02)
///
/// Features:
/// - Origin/Destination selector with searchable airport codes (IATA)
/// - Trip type selector: Round-trip / One-way / Multi-city
/// - Date range picker (Departure & Return dates, Multi-city leg dates)
/// - Passenger counter modal with age categories (Adult 12+, Child 2-11, Infant under 2)
/// - Cabin class selector (Economy, Premium Economy, Business, First)
/// - Responsive design (mobile-first 375px, tablet, desktop)
/// - Semantic accessibility labels & touch targets >= 44dp
/// - Bi-directional RTL/LTR support
/// - 100% ECardoTokens design system compliant (no hardcoded Colors.white)
class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  AirportItem _selectedOrigin = AirportItem.findByCode('DXB');
  AirportItem _selectedDestination = AirportItem.findByCode('LHR');

  FlightTripType _tripType = FlightTripType.roundTrip;
  DateTime _departureDate = DateTime.now().add(const Duration(days: 7));
  DateTime _returnDate = DateTime.now().add(const Duration(days: 14));

  // Multi-city legs
  final List<MultiCitySegmentQuery> _multiCityLegs = [
    MultiCitySegmentQuery(
      origin: 'DXB',
      destination: 'IST',
      date: DateTime.now().add(const Duration(days: 7)),
    ),
    MultiCitySegmentQuery(
      origin: 'IST',
      destination: 'LHR',
      date: DateTime.now().add(const Duration(days: 12)),
    ),
  ];

  PassengerBreakdown _passengers = const PassengerBreakdown(
    adults: 1,
    children: 0,
    infants: 0,
  );

  FlightCabinClass _cabinClass = FlightCabinClass.economy;
  bool _directFlightsOnly = false;

  @override
  void initState() {
    super.initState();
    final controller = ensureTravelController();
    final previous = controller.lastFlightSearch.value;
    if (previous != null) {
      if (previous.origin != null && previous.origin!.isNotEmpty) {
        _selectedOrigin = AirportItem.findByCode(previous.origin!);
      }
      if (previous.destination != null && previous.destination!.isNotEmpty) {
        _selectedDestination = AirportItem.findByCode(previous.destination!);
      }
      if (previous.departureDate != null) {
        _departureDate = previous.departureDate!;
      }
      if (previous.returnDate != null) {
        _returnDate = previous.returnDate!;
        _tripType = FlightTripType.roundTrip;
      } else {
        _tripType = FlightTripType.oneWay;
      }
      _passengers = PassengerBreakdown(
        adults: previous.adultCount > 0 ? previous.adultCount : 1,
        children: previous.childCount,
        infants: previous.infantCount,
      );
      if (previous.cabinClass.isNotEmpty) {
        _cabinClass = FlightCabinClass.fromString(previous.cabinClass);
      }
    }
    _originController.text = _selectedOrigin.code;
    _destinationController.text = _selectedDestination.code;
    controller.loadUpcomingFlights();
  }

  @override
  void dispose() {
    _originController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _swapAirports() {
    AppHaptics.light();
    setState(() {
      final temp = _selectedOrigin;
      _selectedOrigin = _selectedDestination;
      _selectedDestination = temp;
      _originController.text = _selectedOrigin.code;
      _destinationController.text = _selectedDestination.code;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final isDark = ECardoTokens.isDark(context);
    final lang = Localizations.localeOf(context).languageCode;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth >= 640;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        title: Text(
          localization.travelFlightSearch,
          style: TextStyle(
            color: ECardoTokens.ink(context),
            fontWeight: FontWeight.w800,
            fontSize: 18.sp,
          ),
        ),
        backgroundColor: ECardoTokens.surfaceCard(context),
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: ECardoTokens.ink(context)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860),
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: isTabletOrDesktop ? 24.w : 16.w,
                vertical: 16.h,
              ),
              children: [
                _buildHeroBanner(context, isDark, lang),
                SizedBox(height: 16.h),
                _buildTripTypeSelector(context, lang),
                SizedBox(height: 16.h),
                if (_tripType == FlightTripType.multiCity)
                  _buildMultiCitySection(context, lang)
                else
                  _buildStandardSearchCard(context, localization, lang),
                SizedBox(height: 16.h),
                _buildPassengerAndCabinCard(context, lang),
                SizedBox(height: 20.h),
                _buildSearchButton(context, localization, controller),
                SizedBox(height: 24.h),
                _buildRecentSearchesSection(context, controller),
                SizedBox(height: 16.h),
                _buildPopularRoutesSection(context, lang),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDark, String lang) {
    final title = l10nPick(
      context,
      en: 'Explore the World with eCardo Flights',
      fa: 'پروازهای بین‌المللی با کارت eCardo',
      ar: 'رحلات طيران دولية عبر بطاقة eCardo',
    );
    final subtitle = l10nPick(
      context,
      en: 'Over 500 airlines, guaranteed fares & instant digital ticketing',
      fa: 'بیش از ۵۰۰ خط هوایی، تضمین بهترین قیمت و صدور آنی بلیت',
      ar: 'أكثر من 500 شركة طيران، أفضل الأسعار وإصدار تذاكر فوري',
    );

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart.resolve(Directionality.of(context)),
          end: AlignmentDirectional.bottomEnd.resolve(Directionality.of(context)),
          colors: isDark
              ? [
                  ECardoTokens.brand900(context),
                  ECardoTokens.brand700(context),
                ]
              : [
                  ECardoTokens.brand700(context),
                  ECardoTokens.brand500(context),
                ],
        ),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -10,
            bottom: -15,
            child: Icon(
              Icons.flight_takeoff_rounded,
              size: 110.r,
              color: ECardoTokens.inkOnBrand.withValues(alpha: 0.12),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.sand600(context).withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_rounded,
                      size: 14.r,
                      color: ECardoTokens.sand400(context),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      l10nPick(
                        context,
                        en: 'IATA Certified Booking',
                        fa: 'رزرو با تاییدیه IATA',
                        ar: 'حجز معتمد من إياتا',
                      ),
                      style: TextStyle(
                        color: ECardoTokens.sand400(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  color: ECardoTokens.inkOnBrand,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                subtitle,
                style: TextStyle(
                  color: ECardoTokens.inkOnBrandMuted(context),
                  fontSize: 11.5.sp,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTripTypeSelector(BuildContext context, String lang) {
    return Container(
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceSunken(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      padding: EdgeInsets.all(4.r),
      child: Row(
        children: FlightTripType.values.map((type) {
          final isSelected = _tripType == type;
          return Expanded(
            child: Semantics(
              button: true,
              selected: isSelected,
              label: type.localizedLabel(lang),
              child: InkWell(
                onTap: () {
                  AppHaptics.selection();
                  setState(() => _tripType = type);
                },
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? ECardoTokens.surfaceCard(context)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: ECardoTokens.brand900(context)
                                  .withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      type.localizedLabel(lang),
                      style: TextStyle(
                        color: isSelected
                            ? ECardoTokens.brand500(context)
                            : ECardoTokens.inkMuted(context),
                        fontWeight:
                            isSelected ? FontWeight.w800 : FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStandardSearchCard(
    BuildContext context,
    AppLocalizations localization,
    String lang,
  ) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        children: [
          _buildAirportSelectorRow(context, lang),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Divider(color: ECardoTokens.border(context), height: 1),
          ),
          _buildDatesSelector(context, localization, lang),
          SizedBox(height: 12.h),
          Row(
            children: [
              Semantics(
                label: l10nPick(
                  context,
                  en: 'Direct flights only checkbox',
                  fa: 'فقط پروازهای مستقیم',
                  ar: 'رحلات مباشرة فقط',
                ),
                child: Checkbox(
                  value: _directFlightsOnly,
                  activeColor: ECardoTokens.brand500(context),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  ),
                  onChanged: (val) {
                    AppHaptics.selection();
                    setState(() => _directFlightsOnly = val ?? false);
                  },
                ),
              ),
              Text(
                l10nPick(
                  context,
                  en: 'Direct flights only',
                  fa: 'فقط پروازهای مستقیم',
                  ar: 'رحلات مباشرة فقط',
                ),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAirportSelectorRow(BuildContext context, String lang) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildAirportTile(
                context,
                title: l10nPick(context, en: 'From', fa: 'مبدأ', ar: 'من'),
                airport: _selectedOrigin,
                icon: Icons.flight_takeoff_rounded,
                onTap: () => _openAirportPicker(
                  context,
                  title: l10nPick(
                    context,
                    en: 'Select Origin Airport',
                    fa: 'انتخاب فرودگاه مبدأ',
                    ar: 'اختر مطار الإقلاع',
                  ),
                  onSelected: (airport) {
                    setState(() {
                      _selectedOrigin = airport;
                      _originController.text = airport.code;
                    });
                  },
                ),
              ),
            ),
            SizedBox(width: 44.w),
            Expanded(
              child: _buildAirportTile(
                context,
                title: l10nPick(context, en: 'To', fa: 'مقصد', ar: 'إلى'),
                airport: _selectedDestination,
                icon: Icons.flight_land_rounded,
                onTap: () => _openAirportPicker(
                  context,
                  title: l10nPick(
                    context,
                    en: 'Select Destination Airport',
                    fa: 'انتخاب فرودگاه مقصد',
                    ar: 'اختر مطار الوصول',
                  ),
                  onSelected: (airport) {
                    setState(() {
                      _selectedDestination = airport;
                      _destinationController.text = airport.code;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        Semantics(
          label: l10nPick(
            context,
            en: 'Swap origin and destination airports',
            fa: 'جابه‌جایی مبدأ و مقصد',
            ar: 'تبديل مطار المغادرة والوصول',
          ),
          button: true,
          child: Material(
            color: ECardoTokens.brand100(context),
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              onTap: _swapAirports,
              customBorder: const CircleBorder(),
              child: Container(
                width: 44.r,
                height: 44.r,
                alignment: Alignment.center,
                child: Icon(
                  Icons.swap_horiz_rounded,
                  color: ECardoTokens.brand500(context),
                  size: 24.r,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAirportTile(
    BuildContext context, {
    required String title,
    required AirportItem airport,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: '$title ${airport.city} ${airport.code}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceSunken(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
            border: Border.all(color: ECardoTokens.border(context)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 14.r, color: ECardoTokens.brand500(context)),
                  SizedBox(width: 4.w),
                  Text(
                    title,
                    style: TextStyle(
                      color: ECardoTokens.inkMuted(context),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  airport.code,
                  style: TextStyle(
                    color: ECardoTokens.ink(context),
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                airport.city,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                airport.country,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: ECardoTokens.inkMuted(context),
                  fontSize: 9.5.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatesSelector(
    BuildContext context,
    AppLocalizations localization,
    String lang,
  ) {
    final isRoundTrip = _tripType == FlightTripType.roundTrip;
    final formatter = DateFormat('EEE, d MMM yyyy');

    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: '${localization.travelDepartureDate}: ${formatter.format(_departureDate)}',
            child: InkWell(
              onTap: () => _pickDepartureDate(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceSunken(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(color: ECardoTokens.border(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13.r,
                          color: ECardoTokens.brand500(context),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          localization.travelDepartureDate,
                          style: TextStyle(
                            color: ECardoTokens.inkMuted(context),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        DateFormat('d MMM, yyyy').format(_departureDate),
                        style: TextStyle(
                          color: ECardoTokens.ink(context),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('EEEE').format(_departureDate),
                      style: TextStyle(
                        color: ECardoTokens.inkMuted(context),
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (isRoundTrip) ...[
          SizedBox(width: 12.w),
          Expanded(
            child: Semantics(
              button: true,
              label: '${localization.travelReturnDate}: ${formatter.format(_returnDate)}',
              child: InkWell(
                onTap: () => _pickReturnDate(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    border: Border.all(color: ECardoTokens.border(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_repeat_rounded,
                            size: 13.r,
                            color: ECardoTokens.brand500(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            localization.travelReturnDate,
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text(
                          DateFormat('d MMM, yyyy').format(_returnDate),
                          style: TextStyle(
                            color: ECardoTokens.ink(context),
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('EEEE').format(_returnDate),
                        style: TextStyle(
                          color: ECardoTokens.inkMuted(context),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMultiCitySection(BuildContext context, String lang) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10nPick(
                  context,
                  en: 'Multi-City Itinerary',
                  fa: 'برنامه سفر چند مسیره',
                  ar: 'رحلات مدن متعددة',
                ),
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                ),
              ),
              if (_multiCityLegs.length < 5)
                TextButton.icon(
                  onPressed: () {
                    AppHaptics.light();
                    setState(() {
                      final last = _multiCityLegs.last;
                      _multiCityLegs.add(
                        MultiCitySegmentQuery(
                          origin: last.destination,
                          destination: 'DXB',
                          date: last.date.add(const Duration(days: 4)),
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: Text(
                    l10nPick(context, en: 'Add Flight', fa: 'افزودن پرواز', ar: 'إضافة رحلة'),
                    style: TextStyle(
                      color: ECardoTokens.brand500(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.sp,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ..._multiCityLegs.asMap().entries.map((entry) {
            final idx = entry.key;
            final leg = entry.value;
            return Container(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceSunken(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                border: Border.all(color: ECardoTokens.border(context)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l10nPick(context, en: 'Flight', fa: 'پرواز', ar: 'رحلة')} ${idx + 1}',
                        style: TextStyle(
                          color: ECardoTokens.brand500(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 11.sp,
                        ),
                      ),
                      if (_multiCityLegs.length > 2)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                          onPressed: () {
                            AppHaptics.light();
                            setState(() => _multiCityLegs.removeAt(idx));
                          },
                          icon: Icon(
                            Icons.delete_outline_rounded,
                            size: 18.r,
                            color: ECardoTokens.danger(context),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _openAirportPicker(
                            context,
                            title: l10nPick(context, en: 'Origin', fa: 'مبدأ', ar: 'المغادرة'),
                            onSelected: (airport) =>
                                setState(() => leg.origin = airport.code),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: ECardoTokens.surfaceCard(context),
                              borderRadius:
                                  BorderRadius.circular(ECardoTokens.radiusSm),
                            ),
                            child: Text(
                              leg.origin,
                              style: TextStyle(
                                color: ECardoTokens.ink(context),
                                fontWeight: FontWeight.w800,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16.r,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () => _openAirportPicker(
                            context,
                            title: l10nPick(context, en: 'Destination', fa: 'مقصد', ar: 'الوصول'),
                            onSelected: (airport) =>
                                setState(() => leg.destination = airport.code),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: ECardoTokens.surfaceCard(context),
                              borderRadius:
                                  BorderRadius.circular(ECardoTokens.radiusSm),
                            ),
                            child: Text(
                              leg.destination,
                              style: TextStyle(
                                color: ECardoTokens.ink(context),
                                fontWeight: FontWeight.w800,
                                fontSize: 13.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: leg.date,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setState(() => leg.date = picked);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: ECardoTokens.surfaceCard(context),
                              borderRadius:
                                  BorderRadius.circular(ECardoTokens.radiusSm),
                            ),
                            child: Text(
                              DateFormat('d MMM').format(leg.date),
                              style: TextStyle(
                                color: ECardoTokens.ink(context),
                                fontWeight: FontWeight.w700,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPassengerAndCabinCard(BuildContext context, String lang) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              button: true,
              label: '${l10nPick(context, en: 'Passengers', fa: 'مسافران', ar: 'المسافرين')}: ${_passengers.summaryText(lang)}',
              child: InkWell(
                onTap: () => _openPassengerSelector(context, lang),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    border: Border.all(color: ECardoTokens.border(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.people_outline_rounded,
                            size: 14.r,
                            color: ECardoTokens.brand500(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            l10nPick(
                              context,
                              en: 'Passengers',
                              fa: 'مسافران',
                              ar: 'المسافرون',
                            ),
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _passengers.summaryText(lang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ECardoTokens.ink(context),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${_passengers.totalPassengers} ${l10nPick(context, en: 'Total', fa: 'نفر', ar: 'شخص')}',
                        style: TextStyle(
                          color: ECardoTokens.inkMuted(context),
                          fontSize: 9.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Semantics(
              button: true,
              label: '${l10nPick(context, en: 'Cabin Class', fa: 'کلاس پروازی', ar: 'درجة السفر')}: ${_cabinClass.localizedLabel(lang)}',
              child: InkWell(
                onTap: () => _openCabinSelector(context, lang),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    border: Border.all(color: ECardoTokens.border(context)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.airline_seat_recline_extra_rounded,
                            size: 14.r,
                            color: ECardoTokens.brand500(context),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            l10nPick(
                              context,
                              en: 'Cabin Class',
                              fa: 'کلاس پروازی',
                              ar: 'درجة السفر',
                            ),
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _cabinClass.localizedLabel(lang),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ECardoTokens.ink(context),
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        _cabinClass.label,
                        style: TextStyle(
                          color: ECardoTokens.inkMuted(context),
                          fontSize: 9.5.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(
    BuildContext context,
    AppLocalizations localization,
    dynamic controller,
  ) {
    return Obx(
      () => Semantics(
        button: true,
        label: localization.travelSearchFlights,
        child: SizedBox(
          width: double.infinity,
          height: 52.h,
          child: ElevatedButton(
            onPressed: controller.isLoading.value ? null : () => _executeSearch(context, localization, controller),
            style: ElevatedButton.styleFrom(
              backgroundColor: ECardoTokens.brand700(context),
              foregroundColor: ECardoTokens.inkOnBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
              ),
              elevation: 2,
            ),
            child: controller.isLoading.value
                ? SizedBox(
                    width: 24.r,
                    height: 24.r,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ECardoTokens.inkOnBrand,
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_rounded),
                      SizedBox(width: 8.w),
                      Text(
                        localization.travelSearchFlights,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _executeSearch(
    BuildContext context,
    AppLocalizations localization,
    dynamic controller,
  ) async {
    AppHaptics.medium();

    final origin = _selectedOrigin.code.trim().toUpperCase();
    final destination = _selectedDestination.code.trim().toUpperCase();

    if (_tripType != FlightTripType.multiCity) {
      if (origin.isEmpty || destination.isEmpty || origin == destination) {
        showTravelMessage(
          context,
          title: localization.travelFlightSearch,
          message: l10nPick(
            context,
            en: 'Please select different origin and destination airports',
            fa: 'لطفاً فرودگاه مبدأ و مقصد متفاوتی انتخاب کنید',
            ar: 'يرجى اختيار مطار مغادرة ووصول مختلفين',
          ),
        );
        return;
      }
      if (_tripType == FlightTripType.roundTrip &&
          !_returnDate.isAfter(_departureDate)) {
        showTravelMessage(
          context,
          title: localization.travelFlightSearch,
          message: l10nPick(
            context,
            en: 'Return date must be after departure date',
            fa: 'تاریخ برگشت باید بعد از تاریخ رفت باشد',
            ar: 'تاريخ العودة يجب أن يكون بعد تاريخ المغادرة',
          ),
        );
        return;
      }
    }

    if (_passengers.infants > _passengers.adults) {
      showTravelMessage(
        context,
        title: localization.travelFlightSearch,
        message: l10nPick(
          context,
          en: 'Each infant must be accompanied by an adult',
          fa: 'هر نوزاد باید همراه یک بزرگسال باشد',
          ar: 'يجب أن يرافق كل رضيع شخص بالغ',
        ),
      );
      return;
    }

    final searchPayload = TravelFlightSearch(
      origin: origin,
      destination: destination,
      departureDate: _departureDate,
      returnDate: _tripType == FlightTripType.roundTrip ? _returnDate : null,
      adultCount: _passengers.adults,
      childCount: _passengers.children,
      infantCount: _passengers.infants,
      cabinClass: _cabinClass.key,
    );

    final succeeded = await controller.searchFlights(searchPayload);
    controller.flightBookingDetails.value = TravelBookingDetails(
      adultCount: _passengers.adults,
      childCount: _passengers.children,
      infantCount: _passengers.infants,
      cabinClass: _cabinClass.key,
    );

    if (!context.mounted) return;
    if (succeeded) {
      Get.to(() => const FlightListScreen());
    } else {
      showTravelMessage(
        context,
        title: localization.travelFlightSearch,
        message: localization.allControllerLoadError,
      );
    }
  }

  Widget _buildRecentSearchesSection(BuildContext context, dynamic controller) {
    return Obx(() {
      final searches = controller.recentFlightSearches;
      if (searches.isEmpty) return const SizedBox.shrink();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                size: 16.r,
                color: ECardoTokens.brand500(context),
              ),
              SizedBox(width: 6.w),
              Text(
                AppLocalizations.of(context)!.travelRecentSearches,
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontWeight: FontWeight.w800,
                  fontSize: 13.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 58.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: searches.length,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, idx) {
                final search = searches[idx];
                return InkWell(
                  onTap: () {
                    AppHaptics.selection();
                    setState(() {
                      if (search.origin != null && search.origin!.isNotEmpty) {
                        _selectedOrigin = AirportItem.findByCode(search.origin!);
                        _originController.text = _selectedOrigin.code;
                      }
                      if (search.destination != null &&
                          search.destination!.isNotEmpty) {
                        _selectedDestination =
                            AirportItem.findByCode(search.destination!);
                        _destinationController.text = _selectedDestination.code;
                      }
                      if (search.departureDate != null) {
                        _departureDate = search.departureDate!;
                      }
                      if (search.returnDate != null) {
                        _returnDate = search.returnDate!;
                        _tripType = FlightTripType.roundTrip;
                      } else {
                        _tripType = FlightTripType.oneWay;
                      }
                      _passengers = PassengerBreakdown(
                        adults: search.adultCount > 0 ? search.adultCount : 1,
                        children: search.childCount,
                        infants: search.infantCount,
                      );
                      if (search.cabinClass.isNotEmpty) {
                        _cabinClass =
                            FlightCabinClass.fromString(search.cabinClass);
                      }
                    });
                  },
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceCard(context),
                      borderRadius:
                          BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(color: ECardoTokens.border(context)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            '${search.origin ?? ''} ✈ ${search.destination ?? ''}',
                            style: TextStyle(
                              color: ECardoTokens.ink(context),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11.r,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildPopularRoutesSection(BuildContext context, String lang) {
    const popularRoutes = [
      ('DXB', 'LHR', 'Dubai to London', 'From \$420'),
      ('IKA', 'IST', 'Tehran to Istanbul', 'From \$210'),
      ('DOH', 'CDG', 'Doha to Paris', 'From \$490'),
      ('DXB', 'JFK', 'Dubai to New York', 'From \$680'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              size: 16.r,
              color: ECardoTokens.sand600(context),
            ),
            SizedBox(width: 6.w),
            Text(
              l10nPick(
                context,
                en: 'Popular International Routes',
                fa: 'مسیرهای پرطرفدار بین‌المللی',
                ar: 'أشهر الوجهات الدولية',
              ),
              style: TextStyle(
                color: ECardoTokens.ink(context),
                fontWeight: FontWeight.w800,
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: popularRoutes.map((route) {
            return InkWell(
              onTap: () {
                AppHaptics.selection();
                setState(() {
                  _selectedOrigin = AirportItem.findByCode(route.$1);
                  _selectedDestination = AirportItem.findByCode(route.$2);
                  _originController.text = _selectedOrigin.code;
                  _destinationController.text = _selectedDestination.code;
                });
              },
              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceSunken(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(color: ECardoTokens.border(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${route.$1} → ${route.$2}',
                        style: TextStyle(
                          color: ECardoTokens.brand500(context),
                          fontWeight: FontWeight.w800,
                          fontSize: 11.5.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      route.$4,
                      style: TextStyle(
                        color: ECardoTokens.success(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _pickDepartureDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _departureDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ECardoTokens.brand700(context),
              onPrimary: ECardoTokens.inkOnBrand,
              surface: ECardoTokens.surfaceCard(context),
              onSurface: ECardoTokens.ink(context),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      AppHaptics.selection();
      setState(() {
        _departureDate = picked;
        if (_tripType == FlightTripType.roundTrip &&
            _returnDate.isBefore(_departureDate.add(const Duration(days: 1)))) {
          _returnDate = _departureDate.add(const Duration(days: 7));
        }
      });
    }
  }

  Future<void> _pickReturnDate(BuildContext context) async {
    final minDate = _departureDate.add(const Duration(days: 1));
    final initial = _returnDate.isAfter(minDate) ? _returnDate : minDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: minDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: ECardoTokens.brand700(context),
              onPrimary: ECardoTokens.inkOnBrand,
              surface: ECardoTokens.surfaceCard(context),
              onSurface: ECardoTokens.ink(context),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      AppHaptics.selection();
      setState(() => _returnDate = picked);
    }
  }

  void _openAirportPicker(
    BuildContext context, {
    required String title,
    required ValueChanged<AirportItem> onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _AirportSearchBottomSheet(
        title: title,
        onSelected: (airport) {
          onSelected(airport);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  void _openPassengerSelector(BuildContext context, String lang) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => _PassengerModalSheet(
        initial: _passengers,
        lang: lang,
        onConfirm: (updated) {
          setState(() => _passengers = updated);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  void _openCabinSelector(BuildContext context, String lang) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CabinClassModalSheet(
        selected: _cabinClass,
        lang: lang,
        onSelect: (cabin) {
          setState(() => _cabinClass = cabin);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }
}

/// Searchable airport selection modal.
class _AirportSearchBottomSheet extends StatefulWidget {
  final String title;
  final ValueChanged<AirportItem> onSelected;

  const _AirportSearchBottomSheet({
    required this.title,
    required this.onSelected,
  });

  @override
  State<_AirportSearchBottomSheet> createState() =>
      _AirportSearchBottomSheetState();
}

class _AirportSearchBottomSheetState extends State<_AirportSearchBottomSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<AirportItem> _filtered = AirportItem.popularAirports;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = AirportItem.popularAirports;
      } else {
        _filtered = AirportItem.popularAirports.where((item) {
          return item.code.toLowerCase().contains(query) ||
              item.city.toLowerCase().contains(query) ||
              item.name.toLowerCase().contains(query) ||
              item.country.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ECardoTokens.radius2xl),
        ),
        boxShadow: ECardoTokens.shadowSheet(context),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 38.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: ECardoTokens.borderStrong(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusFull),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: ECardoTokens.ink(context),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: ECardoTokens.inkMuted(context),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: TextStyle(color: ECardoTokens.ink(context)),
                decoration: InputDecoration(
                  hintText: l10nPick(
                    context,
                    en: 'Search city, airport name, or IATA code...',
                    fa: 'جستجوی شهر، نام فرودگاه یا کد یاتا...',
                    ar: 'ابحث عن المدينة، المطار أو رمز إياتا...',
                  ),
                  hintStyle: TextStyle(
                    color: ECardoTokens.inkMuted(context),
                    fontSize: 12.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: ECardoTokens.brand500(context),
                  ),
                  filled: true,
                  fillColor: ECardoTokens.surfaceSunken(context),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    borderSide: BorderSide(color: ECardoTokens.border(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    borderSide: BorderSide(color: ECardoTokens.border(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    borderSide:
                        BorderSide(color: ECardoTokens.focusRing(context)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: _filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.flight_takeoff_rounded,
                            size: 48.r,
                            color: ECardoTokens.inkMuted(context),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            l10nPick(
                              context,
                              en: 'No airports found',
                              fa: 'فرودگاهی یافت نشد',
                              ar: 'لم يتم العثور على مطارات',
                            ),
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      itemCount: _filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: ECardoTokens.border(context), height: 1),
                      itemBuilder: (context, idx) {
                        final airport = _filtered[idx];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          leading: Container(
                            width: 46.r,
                            height: 46.r,
                            decoration: BoxDecoration(
                              color: ECardoTokens.brand100(context),
                              borderRadius:
                                  BorderRadius.circular(ECardoTokens.radiusMd),
                            ),
                            alignment: Alignment.center,
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                airport.code,
                                style: TextStyle(
                                  color: ECardoTokens.brand500(context),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            airport.city,
                            style: TextStyle(
                              color: ECardoTokens.ink(context),
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5.sp,
                            ),
                          ),
                          subtitle: Text(
                            '${airport.name}, ${airport.country}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 10.5.sp,
                            ),
                          ),
                          trailing: Icon(
                            Icons.north_west_rounded,
                            size: 16.r,
                            color: ECardoTokens.inkMuted(context),
                          ),
                          onTap: () {
                            AppHaptics.selection();
                            widget.onSelected(airport);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Passenger counter bottom sheet.
class _PassengerModalSheet extends StatefulWidget {
  final PassengerBreakdown initial;
  final String lang;
  final ValueChanged<PassengerBreakdown> onConfirm;

  const _PassengerModalSheet({
    required this.initial,
    required this.lang,
    required this.onConfirm,
  });

  @override
  State<_PassengerModalSheet> createState() => _PassengerModalSheetState();
}

class _PassengerModalSheetState extends State<_PassengerModalSheet> {
  late int _adults;
  late int _children;
  late int _infants;

  @override
  void initState() {
    super.initState();
    _adults = widget.initial.adults;
    _children = widget.initial.children;
    _infants = widget.initial.infants;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ECardoTokens.radius2xl),
        ),
        boxShadow: ECardoTokens.shadowSheet(context),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: ECardoTokens.borderStrong(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusFull),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10nPick(
                context,
                en: 'Select Passengers',
                fa: 'تعداد مسافران',
                ar: 'اختيار المسافرين',
              ),
              style: TextStyle(
                color: ECardoTokens.ink(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 16.h),
            _buildCounterRow(
              context,
              title: l10nPick(context, en: 'Adults', fa: 'بزرگسال', ar: 'بالغ'),
              subtitle: l10nPick(
                context,
                en: 'Age 12+',
                fa: '۱۲ سال به بالا',
                ar: '12 سنة فما فوق',
              ),
              count: _adults,
              min: 1,
              max: 9,
              onChanged: (val) {
                setState(() {
                  _adults = val;
                  if (_infants > _adults) _infants = _adults;
                });
              },
            ),
            Divider(color: ECardoTokens.border(context), height: 24),
            _buildCounterRow(
              context,
              title: l10nPick(context, en: 'Children', fa: 'کودک', ar: 'طفل'),
              subtitle: l10nPick(
                context,
                en: 'Age 2-11 years',
                fa: '۲ تا ۱۱ سال',
                ar: 'من 2 إلى 11 سنة',
              ),
              count: _children,
              min: 0,
              max: 8,
              onChanged: (val) => setState(() => _children = val),
            ),
            Divider(color: ECardoTokens.border(context), height: 24),
            _buildCounterRow(
              context,
              title: l10nPick(context, en: 'Infants', fa: 'نوزاد', ar: 'رضيع'),
              subtitle: l10nPick(
                context,
                en: 'Under 2 years (on lap)',
                fa: 'زیر ۲ سال (روی پای والدین)',
                ar: 'أقل من سنتين (على الحجر)',
              ),
              count: _infants,
              min: 0,
              max: _adults,
              onChanged: (val) => setState(() => _infants = val),
            ),
            SizedBox(height: 24.h),
            SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: () {
                  AppHaptics.medium();
                  widget.onConfirm(
                    PassengerBreakdown(
                      adults: _adults,
                      children: _children,
                      infants: _infants,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ECardoTokens.brand700(context),
                  foregroundColor: ECardoTokens.inkOnBrand,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  ),
                ),
                child: Text(
                  l10nPick(context, en: 'Apply Passengers', fa: 'تایید مسافران', ar: 'تأكيد المسافرين'),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCounterRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required int count,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: ECardoTokens.ink(context),
                fontWeight: FontWeight.w800,
                fontSize: 13.5.sp,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                color: ECardoTokens.inkMuted(context),
                fontSize: 10.5.sp,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Semantics(
              button: true,
              label: 'Decrease $title',
              child: Material(
                color: ECardoTokens.surfaceSunken(context),
                shape: const CircleBorder(),
                child: IconButton(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: const Icon(Icons.remove_rounded),
                  color: count > min
                      ? ECardoTokens.ink(context)
                      : ECardoTokens.inkMuted(context),
                  onPressed: count > min ? () => onChanged(count - 1) : null,
                ),
              ),
            ),
            SizedBox(
              width: 44.w,
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: ECardoTokens.ink(context),
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            Semantics(
              button: true,
              label: 'Increase $title',
              child: Material(
                color: ECardoTokens.surfaceSunken(context),
                shape: const CircleBorder(),
                child: IconButton(
                  constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                  icon: const Icon(Icons.add_rounded),
                  color: count < max
                      ? ECardoTokens.brand500(context)
                      : ECardoTokens.inkMuted(context),
                  onPressed: count < max ? () => onChanged(count + 1) : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Cabin class selection bottom sheet.
class _CabinClassModalSheet extends StatelessWidget {
  final FlightCabinClass selected;
  final String lang;
  final ValueChanged<FlightCabinClass> onSelect;

  const _CabinClassModalSheet({
    required this.selected,
    required this.lang,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(ECardoTokens.radius2xl),
        ),
        boxShadow: ECardoTokens.shadowSheet(context),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: ECardoTokens.borderStrong(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusFull),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10nPick(
                context,
                en: 'Select Cabin Class',
                fa: 'انتخاب کلاس پروازی',
                ar: 'اختر درجة السفر',
              ),
              style: TextStyle(
                color: ECardoTokens.ink(context),
                fontSize: 16.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 12.h),
            ...FlightCabinClass.values.map((cabin) {
              final isSelected = selected == cabin;
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ECardoTokens.brand100(context)
                      : ECardoTokens.surfaceSunken(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? ECardoTokens.brand500(context)
                        : ECardoTokens.border(context),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    cabin == FlightCabinClass.firstClass
                        ? Icons.workspace_premium_rounded
                        : cabin == FlightCabinClass.business
                            ? Icons.business_center_rounded
                            : Icons.airline_seat_recline_normal_rounded,
                    color: isSelected
                        ? ECardoTokens.brand500(context)
                        : ECardoTokens.inkMuted(context),
                  ),
                  title: Text(
                    cabin.localizedLabel(lang),
                    style: TextStyle(
                      color: isSelected
                          ? ECardoTokens.brand500(context)
                          : ECardoTokens.ink(context),
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13.sp,
                    ),
                  ),
                  subtitle: Text(
                    cabin.label,
                    style: TextStyle(
                      color: ECardoTokens.inkMuted(context),
                      fontSize: 10.sp,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: ECardoTokens.brand500(context),
                        )
                      : null,
                  onTap: () {
                    AppHaptics.selection();
                    onSelect(cabin);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
