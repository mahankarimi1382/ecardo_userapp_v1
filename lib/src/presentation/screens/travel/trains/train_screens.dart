/// Enhanced Railways Module (T-13) with European Trainline/DB Navigator patterns
/// Migration Complete: Uses ECardoTokens, Sleeper Berths, Gender Rules, Connection Safety
///
/// Features:
/// ✅ High-Speed / Express / Regional / Night Sleeper differentiation
/// ✅ Intermediate stops timeline with arrival/departure times and platforms
/// ✅ Sleeper berths (6-bed couchette, 4-bed couchette, double sleeper, single deluxe)
/// ✅ Compartment gender rules (Mixed, Female Only, Male Only, Private Coupe)
/// ✅ Connection safety alerts (<15 min tight alert, >20 min safe transfer)
/// ✅ Aztec/QR mobile rail pass voucher (UIC 918-3 standard)
/// ✅ Full ECardoTokens design system migration
/// ✅ ScreenUtil responsive + RTL/LTR localization

library;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

import '../services/mock_travel_data.dart';
import 'train_confirmation_screen.dart';
import 'train_models.dart';

export 'train_confirmation_screen.dart';
export 'train_models.dart';

// ---------------------------------------------------------------------------
// 1. TRAIN SEARCH SCREEN (Enhanced Form + Hero Section)
// ---------------------------------------------------------------------------

class TrainSearchScreen extends StatefulWidget {
  const TrainSearchScreen({super.key});

  @override
  State<TrainSearchScreen> createState() => _TrainSearchScreenState();
}

class _TrainSearchScreenState extends State<TrainSearchScreen> {
  String origin = mockIranCities.first;
  String destination = mockIranCities[1];
  DateTime departureDate = DateTime.now().add(const Duration(days: 7));
  int adultCount = 1;
  int childCount = 0;
  TrainCategory? selectedCategory; // high_speed, express, regional, night_sleeper

  Future<void> _pickCity({required bool isOrigin}) async {
    final localization = AppLocalizations.of(context)!;
    final result = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
      ),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                isOrigin ? localization.travelOrigin : localization.travelDestination,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: ECardoTokens.ink(context),
                ),
              ),
            ),
            ...mockIranCities.map(
              (city) => ListTile(
                leading: Icon(Icons.train_rounded, color: ECardoTokens.brand500(context)),
                title: TravelBidiText(city),
                onTap: () => Navigator.pop(context, city),
              ),
            ),
          ],
        ),
      ),
    );
    if (result == null) return;
    setState(() {
      if (isOrigin) {
        origin = result;
        if (destination == origin) destination = mockIranCities[1];
      } else {
        destination = result;
        if (origin == destination) origin = mockIranCities[1];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      body: Column(
        children: [
          // Header with gradient brand background
          Container(
            padding: EdgeInsets.only(top: 2.h, bottom: 32.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ECardoTokens.brand900(context),
                  ECardoTokens.brand700(context),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: ECardoTokens.inkOnBrand),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        localization?.travelServiceTrain ?? 'Train',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.inkOnBrand,
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.train_rounded,
                        size: 120.r,
                        color: ECardoTokens.inkOnBrand.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    localization?.travelTrainHero ?? 'Train Travel',
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.inkOnBrand,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'Fast & Comfortable Journey Across Iran',
                      fa: 'سفر سریع و راحت در سراسر ایران',
                      ar: 'رحلة سريعة ومريحة عبر إيران',
                      zh: '便捷舒适的伊朗境内之旅',
                    ),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: ECardoTokens.inkOnBrandMuted(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Form Card
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Origin/Destination Fields
                  _SearchFieldCard(
                    title: localization?.travelOrigin ?? 'Origin',
                    subtitle: origin,
                    icon: Icons.trip_origin_rounded,
                    onTap: () => _pickCity(isOrigin: true),
                  ),

                  SizedBox(height: 12.h),

                  // Swap Button
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        final temp = origin;
                        origin = destination;
                        destination = temp;
                        setState(() {});
                      },
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand100(context),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.swap_horiz_rounded,
                          color: ECardoTokens.brand500(context),
                          size: 20.r,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Destination Field
                  _SearchFieldCard(
                    title: localization?.travelDestination ?? 'Destination',
                    subtitle: destination,
                    icon: Icons.location_on_rounded,
                    onTap: () => _pickCity(isOrigin: false),
                  ),

                  SizedBox(height: 20.h),

                  // Date Picker Field
                  _SearchFieldCard(
                    title: localization?.travelDepartureDate ?? 'Departure Date',
                    subtitle: DateFormat('yyyy-MM-dd').format(departureDate),
                    icon: Icons.calendar_month_rounded,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: departureDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        builder: (context, child) {
                          return Theme(
                            data: ThemeData.light(),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => departureDate = picked);
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Passenger Count (Adul+Child)
                  _PassengerSection(adultCount: adultCount, childCount: childCount),

                  SizedBox(height: 20.h),

                  // Train Category Filter
                  if (selectedCategory != null) ...[
                    Text(
                      'Filter by Train Type:',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 10.w,
                      runSpacing: 10.h,
                      children: TrainCategory.values.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                cat.icon,
                                size: 14.r,
                                color: isSelected
                                    ? ECardoTokens.inkOnBrand
                                    : ECardoTokens.brand500(context),
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                cat.localizedLabel(context, isRtl: false),
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? ECardoTokens.inkOnBrand
                                      : ECardoTokens.ink(context),
                                ),
                              ),
                            ],
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() => selectedCategory = selected ? cat : null);
                          },
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 16.h),
                  ],

                  // Info Banner
                  Container(
                    padding: EdgeInsets.all(14.r),
                    decoration: BoxDecoration(
                      color: ECardoTokens.sand100(context),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(
                        color: ECardoTokens.sand400(context).withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: ECardoTokens.sand600(context),
                          size: 20.r,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            l10nPick(
                              context,
                              en: 'Direct booking on Raja, Fadak, Safir and Noor rail networks.',
                              fa: 'رزرو مستقیم قطارهای رجا، فدک، سفیر و نورالرضا با صدور آنی بلیط.',
                              ar: 'حجز مباشر لقطارات السكك الحديدية مع إصدار فوري للتذاكر.',
                              zh: '直接预订干线铁路客运，即时生成电子乘车凭证。',
                            ),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: ECardoTokens.sand600(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28.h),

                  // Search Button
                  CommonButton(
                    text: l10nPick(
                      context,
                      en: 'Search Trains',
                      fa: 'جستجوی قطارها',
                      ar: 'البحث عن القطارات',
                      zh: '搜索火车',
                    ),
                    width: double.infinity,
                    backgroundColor: ECardoTokens.brand500(context),
                    textColor: ECardoTokens.inkOnBrand,
                    borderRadius: ECardoTokens.radiusLg,
                    onPressed: () {
                      final journeys = generateRailJourneys(
                        origin: origin,
                        destination: destination,
                        departureDate: departureDate,
                      );

                      Get.to(
                        () => TrainResultsScreen(
                          origin: origin,
                          destination: destination,
                          departureDate: departureDate,
                          adultCount: adultCount,
                          childCount: childCount,
                          selectedCategory: selectedCategory,
                          journeys: journeys,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. RESULTS SCREEN (Timetable Grid + Filter Cards)
// ---------------------------------------------------------------------------

class TrainResultsScreen extends StatelessWidget {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final int adultCount;
  final int childCount;
  final TrainCategory? selectedCategory;
  final List<RailJourney> journeys;

  const TrainResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.adultCount,
    required this.childCount,
    this.selectedCategory,
    required this.journeys,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final filteredJourneys = selectedCategory != null
        ? journeys.where((j) => j.category == selectedCategory).toList()
        : journeys;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          localization?.travelTrainResults ?? 'Trains',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Container(
              padding: EdgeInsets.all(18.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$filteredJourneys.length trains available',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: ECardoTokens.inkMuted(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  TravelBidiText(
                    '$origin → $destination',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    DateFormat('dd MMM yyyy').format(departureDate),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: ECardoTokens.inkMuted(context),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: filteredJourneys.length,
              itemBuilder: (context, index) {
                final journey = filteredJourneys[index];
                return JourneyCard(
                  journey: journey,
                  adultCount: adultCount,
                  childCount: childCount,
                  onSelect: () {
                    Get.to(
                      () => JourneyDetailsScreen(
                        journey: journey,
                        origin: origin,
                        destination: destination,
                        departureDate: departureDate,
                        adultCount: adultCount,
                        childCount: childCount,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. JOURNEY DETAILS SCREEN (Full Timetable + Sleeper Selection)
// ---------------------------------------------------------------------------

class JourneyDetailsScreen extends StatefulWidget {
  final RailJourney journey;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final int adultCount;
  final int childCount;

  const JourneyDetailsScreen({
    super.key,
    required this.journey,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.adultCount,
    required this.childCount,
  });

  @override
  State<JourneyDetailsScreen> createState() => _JourneyDetailsScreenState();
}

class _JourneyDetailsScreenState extends State<JourneyDetailsScreen> {
  late SleeperBerthType _selectedSleeper;
  late CompartmentGenderRule _selectedGenderRule;

  @override
  void initState() {
    super.initState();
    _selectedSleeper = widget.journey.availableSleepers.first;
    _selectedGenderRule = widget.journey.availableGenderRules.first;
  }

  int get _calculatedPrice {
    final basePrice = widget.journey.basePrice;
    final sleeperPremium = _selectedSleeper.pricePremium();
    return (basePrice + sleeperPremium) * (widget.adultCount + widget.childCount);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 16.h, bottom: 24.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  ECardoTokens.brand900(context),
                  ECardoTokens.brand700(context),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new_rounded, color: ECardoTokens.inkOnBrand),
                        onPressed: () => Get.back(),
                      ),
                      Text(
                        widget.journey.trainName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.inkOnBrand,
                        ),
                      ),
                      SizedBox(width: 48.w),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Departure/Arrival Summary
                _HeaderSummary(
                  origin: widget.origin,
                  destination: widget.destination,
                  departTime: widget.journey.departLabel,
                  arrivalTime: widget.journey.arrivalLabel,
                  duration: widget.journey.durationLabel,
                  category: widget.journey.category,
                  operator: widget.journey.operator,
                ),

                SizedBox(height: 24.h),

                // Amenities Tags
                if (widget.journey.amenities.isNotEmpty) ...[
                  Text(
                    'Amenities:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: widget.journey.amenities.map((amenity) {
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand100(context),
                          borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                        ),
                        child: Text(
                          amenity,
                          style: TextStyle(fontSize: 10.sp, color: ECardoTokens.brand900(context)),
                        ),
                      );
                    }).toList(),
                  ),

                  SizedBox(height: 20.h),
                ],

                // Connection Safety Alert
                if (widget.journey.transferInfo != null) ...[
                  _ConnectionSafetyAlert(info: widget.journey.transferInfo!),
                  SizedBox(height: 20.h),
                ],

                // Sleeper & Gender Rule Selection
                _SleeperSelectionPanel(
                  selectedSleeper: _selectedSleeper,
                  selectedGenderRule: _selectedGenderRule,
                  sleepers: widget.journey.availableSleepers,
                  genderRules: widget.journey.availableGenderRules,
                  onSleeperChanged: (sleeper) {
                    setState(() => _selectedSleeper = sleeper);
                  },
                  onGenderRuleChanged: (rule) {
                    setState(() => _selectedGenderRule = rule);
                  },
                ),

                SizedBox(height: 20.h),

                // Intermediate Stops Timeline
                if (widget.journey.intermediateStops.isNotEmpty) ...[
                  Text(
                    'Intermediate Stops:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  StopTimeline(stops: widget.journey.intermediateStops),

                  SizedBox(height: 24.h),
                ],

                // Price Summary
                _PriceSummary(
                  adultPrice: widget.journey.basePrice,
                  sleeperPremium: _selectedSleeper.pricePremium(),
                  adultCount: widget.adultCount,
                  childCount: widget.childCount,
                ),

                SizedBox(height: 24.h),

                // Book Button
                CommonButton(
                  text: 'Continue Booking',
                  width: double.infinity,
                  backgroundColor: ECardoTokens.brand500(context),
                  textColor: ECardoTokens.inkOnBrand,
                  borderRadius: ECardoTokens.radiusLg,
                  onPressed: () {
                    Get.to(
                      () => BookingConfirmationScreen(
                        journey: widget.journey,
                        origin: widget.origin,
                        destination: widget.destination,
                        departureDate: widget.departureDate,
                        adultCount: widget.adultCount,
                        childCount: widget.childCount,
                        selectedSleeper: _selectedSleeper,
                        selectedGenderRule: _selectedGenderRule,
                        totalPrice: _calculatedPrice,
                      ),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. BOOKING CONFIRMATION SCREEN (Passenger Details)
// ---------------------------------------------------------------------------

class BookingConfirmationScreen extends StatefulWidget {
  final RailJourney journey;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final int adultCount;
  final int childCount;
  final SleeperBerthType selectedSleeper;
  final CompartmentGenderRule selectedGenderRule;
  final int totalPrice;

  const BookingConfirmationScreen({
    super.key,
    required this.journey,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.adultCount,
    required this.childCount,
    required this.selectedSleeper,
    required this.selectedGenderRule,
    required this.totalPrice,
  });

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final _formKey = GlobalKey<FormState>();
  late List<Map<String, dynamic>> _passengers;

  @override
  void initState() {
    super.initState();
    final total = widget.adultCount + widget.childCount;
    _passengers = List.generate(
      total,
      (_) => {'name': '', 'nationalCode': '', 'phone': ''},
    );
  }

  void _submitBooking() {
    if (!_formKey.currentState!.validate()) return;

    // Convert passengers to List<Map<String, String>>
    final passengerList = _passengers.map((p) {
      return <String, String>{
        'name': p['name'] as String? ?? '',
        'national_code': p['nationalCode'] as String? ?? '',
      };
    }).toList();

    // Generate ticket with Aztec/QR based on voucher type
    Get.to(
      () => TrainConfirmationScreen(
        reference: 'EC-RAIL-${DateTime.now().millisecondsSinceEpoch}',
        origin: widget.origin,
        destination: widget.destination,
        departureDate: widget.departureDate,
        trainName: widget.journey.trainName,
        trainNumber: widget.journey.trainNumber,
        operatorName: widget.journey.operator,
        departureTime: widget.journey.departLabel,
        arrivalTime: widget.journey.arrivalLabel,
        trainClass: widget.selectedSleeper.localizedTitle(isRtl: false),
        totalPrice: widget.totalPrice,
        passengers: passengerList,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ECardoTokens.surfaceCanvas(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          localization.travelTrainPassengers,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: ECardoTokens.ink(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter passenger details:',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: ECardoTokens.ink(context),
                ),
              ),

              SizedBox(height: 16.h),

              ...List.generate(_passengers.length, (index) {
                final p = _passengers[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: ECardoTokens.surfaceCard(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                    boxShadow: ECardoTokens.shadowCard(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passenger ${index + 1}',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      TextFormField(
                        initialValue: p['name'] ?? '',
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                          ),
                        ),
                        validator: (value) => value?.trim().isEmpty ?? true
                            ? 'Required'
                            : null,
                        onSaved: (value) => p['name'] = value?.trim() ?? '',
                      ),

                      SizedBox(height: 12.h),

                      TextFormField(
                        initialValue: p['nationalCode'] ?? '',
                        decoration: InputDecoration(
                          labelText: 'National ID',
                          prefixIcon: const Badge(
                            child: Icon(Icons.badge_rounded),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                          ),
                        ),
                        validator: (value) => (value?.trim().length ?? 0) < 10
                            ? 'Invalid'
                            : null,
                        onSaved: (value) => p['nationalCode'] = value?.trim() ?? '',
                      ),

                      SizedBox(height: 12.h),

                      TextFormField(
                        initialValue: p['phone'] ?? '',
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          prefixIcon: const Icon(Icons.phone_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                          ),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) => (value?.trim().length ?? 0) < 10
                            ? 'Invalid phone'
                            : null,
                        onSaved: (value) => p['phone'] = value?.trim() ?? '',
                      ),
                    ],
                  ),
                );
              }),

              SizedBox(height: 24.h),

              CommonButton(
                text: 'Confirm Booking',
                width: double.infinity,
                backgroundColor: ECardoTokens.brand500(context),
                textColor: ECardoTokens.inkOnBrand,
                borderRadius: ECardoTokens.radiusLg,
                onPressed: _submitBooking,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// WIDGET HELPERS (Cards, Panels, Timelines)
// ---------------------------------------------------------------------------

class _SearchFieldCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _SearchFieldCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(18.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
          border: Border.all(
            color: ECardoTokens.border(context),
          ),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: ECardoTokens.brand100(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              ),
              child: Icon(icon, color: ECardoTokens.brand500(context), size: 20.r),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: ECardoTokens.inkMuted(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14.r,
              color: ECardoTokens.inkMuted(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _PassengerSection extends StatelessWidget {
  final int adultCount;
  final int childCount;

  const _PassengerSection({required this.adultCount, required this.childCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passengers:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _PassengerCounter(
                label: 'Adults',
                count: adultCount,
                icon: Icons.person_outline_rounded,
              ),
              _PassengerCounter(
                label: 'Children',
                count: childCount,
                icon: Icons.child_care_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PassengerCounter extends StatelessWidget {
  final String label;
  final int count;
  final IconData icon;

  const _PassengerCounter({required this.label, required this.count, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: ECardoTokens.brand100(context),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: ECardoTokens.brand500(context), size: 24.r),
        ),
        SizedBox(height: 8.h),
        Text(label, style: TextStyle(fontSize: 11.sp, color: ECardoTokens.inkMuted(context))),
        SizedBox(height: 4.h),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: ECardoTokens.ink(context),
          ),
        ),
      ],
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  final String origin;
  final String destination;
  final String departTime;
  final String arrivalTime;
  final String duration;
  final TrainCategory category;
  final String operator;

  const _HeaderSummary({
    required this.origin,
    required this.destination,
    required this.departTime,
    required this.arrivalTime,
    required this.duration,
    required this.category,
    required this.operator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                ),
                child: Icon(category.icon, color: ECardoTokens.brand500(context), size: 16.r),
              ),
              SizedBox(width: 10.w),
              Text(
                operator,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: ECardoTokens.inkMuted(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StationBlock(city: origin, time: departTime, type: 'origin'),
              Expanded(child: _DurationBlock(duration: duration)),
              _StationBlock(city: destination, time: arrivalTime, type: 'dest'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StationBlock extends StatelessWidget {
  final String city;
  final String time;
  final String type;

  const _StationBlock({required this.city, required this.time, required this.type});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: type == 'origin' || type == 'dest' ? 1 : 2,
      child: Column(
        crossAxisAlignment: type == 'origin' ? CrossAxisAlignment.start : CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w900,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            city,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: ECardoTokens.ink(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBlock extends StatelessWidget {
  final String duration;

  const _DurationBlock({required this.duration});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.swap_horiz_rounded, color: ECardoTokens.brand500(context), size: 20.r),
          SizedBox(height: 6.h),
          Text(
            duration,
            style: TextStyle(
              fontSize: 10.sp,
              color: ECardoTokens.inkMuted(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConnectionSafetyAlert extends StatelessWidget {
  final ConnectionTransferInfo info;

  const _ConnectionSafetyAlert({required this.info});

  @override
  Widget build(BuildContext context) {
    final safetyLevel = info.safetyLevel;
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: safetyLevel.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        border: Border.all(color: safetyLevel.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            safetyLevel.icon,
            color: safetyLevel.color,
            size: 28.r,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  safetyLevel.displayName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: safetyLevel.color,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'Connection at ${info.transferMinutes} minutes',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: safetyLevel.color.withValues(alpha: 0.8),
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

class _SleeperSelectionPanel extends StatelessWidget {
  final SleeperBerthType selectedSleeper;
  final CompartmentGenderRule selectedGenderRule;
  final List<SleeperBerthType> sleepers;
  final List<CompartmentGenderRule> genderRules;
  final ValueChanged<SleeperBerthType> onSleeperChanged;
  final ValueChanged<CompartmentGenderRule> onGenderRuleChanged;

  const _SleeperSelectionPanel({
    required this.selectedSleeper,
    required this.selectedGenderRule,
    required this.sleepers,
    required this.genderRules,
    required this.onSleeperChanged,
    required this.onGenderRuleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sleeper Class & Compartment Type:',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 16.h),

          // Sleeper options
          Text(
            'Sleeper Type:',
            style: TextStyle(
              fontSize: 11.sp,
              color: ECardoTokens.inkMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: sleepers.map((sleeper) {
              final isSelected = selectedSleeper == sleeper;
              return InkWell(
                onTap: () => onSleeperChanged(sleeper),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? ECardoTokens.brand900(context) : ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    border: Border.all(
                      color: isSelected ? ECardoTokens.brand500(context) : ECardoTokens.border(context),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(sleeper.icon, color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.inkMuted(context), size: 24.r),
                      SizedBox(height: 6.h),
                      Text(
                        sleeper.localizedTitle(isRtl: false),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '+${sleeper.pricePremium()} Toman',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.success(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 20.h),

          // Gender rule options
          Text(
            'Compartment Gender Rule:',
            style: TextStyle(
              fontSize: 11.sp,
              color: ECardoTokens.inkMuted(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: genderRules.map((rule) {
              final isSelected = selectedGenderRule == rule;
              return InkWell(
                onTap: () => onGenderRuleChanged(rule),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? ECardoTokens.brand900(context) : ECardoTokens.surfaceSunken(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    border: Border.all(
                      color: isSelected ? ECardoTokens.brand500(context) : ECardoTokens.border(context),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(rule.icon, color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.inkMuted(context), size: 20.r),
                      SizedBox(width: 8.w),
                      Text(
                        rule.localizedBadge(isRtl: false),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? ECardoTokens.inkOnBrand : ECardoTokens.ink(context),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class StopTimeline extends StatelessWidget {
  final List<IntermediateStop> stops;

  const StopTimeline({super.key, required this.stops});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(stops.length, (index) {
        final stop = stops[index];

        return Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 8.r,
                  backgroundColor: stop.isMajorHub ? ECardoTokens.brand500(context) : ECardoTokens.inkMuted(context),
                  child: null,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stop.stationName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: index == 0 || index == stops.length - 1 ? FontWeight.w800 : FontWeight.w600,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      Text(
                        'Platform ${stop.platform}',
                        style: TextStyle(
                          fontSize: 10.sp,
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
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    if (index > 0)
                      Text(
                        stop.arrivalTime,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: ECardoTokens.inkMuted(context),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (index < stops.length - 1) ...[
              SizedBox(height: 8.h),
              Container(
                width: 8.w,
                margin: EdgeInsetsDirectional.only(start: 12.w + 8.r),
                child: Divider(
                  thickness: 2,
                  color: ECardoTokens.borderStrong(context),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _PriceSummary extends StatelessWidget {
  final int adultPrice;
  final int sleeperPremium;
  final int adultCount;
  final int childCount;

  const _PriceSummary({
    required this.adultPrice,
    required this.sleeperPremium,
    required this.adultCount,
    required this.childCount,
  });

  @override
  Widget build(BuildContext context) {
    final baseTotal = adultPrice * (adultCount + childCount);
    final sleeperTotal = sleeperPremium * (adultCount + childCount);
    final grandTotal = baseTotal + sleeperTotal;

    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: ECardoTokens.brand100(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
        border: Border.all(color: ECardoTokens.brand500(context).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Base fare ($adultPrice Toman)',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: ECardoTokens.inkMuted(context),
                ),
              ),
              Text(
                formatAmount(adultPrice),
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: ECardoTokens.ink(context),
                ),
              ),
            ],
          ),
          if (sleeperPremium > 0) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sleeper premium ($sleeperPremium Toman)',
                  style: TextStyle(fontSize: 11.sp, color: ECardoTokens.inkMuted(context)),
                ),
                Text(formatAmount(sleeperPremium), style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: ECardoTokens.success(context))),
              ],
            ),
          ],
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: ECardoTokens.brand900(context),
              borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TOTAL',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.inkOnBrand,
                  ),
                ),
                Text(
                  formatAmount(grandTotal),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.inkOnBrand,
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

String formatAmount(int amount) {
  final formatter = NumberFormat('#,###', 'en_US');
  return '${formatter.format(amount)} Toman';
}

// ---------------------------------------------------------------------------
// 5. TRIP CARD (For Results Screen)
// ---------------------------------------------------------------------------

class JourneyCard extends StatelessWidget {
  final RailJourney journey;
  final int adultCount;
  final int childCount;
  final VoidCallback onSelect;

  const JourneyCard({
    super.key,
    required this.journey,
    required this.adultCount,
    required this.childCount,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final totalPeople = adultCount + childCount;
    final baseTotal = journey.basePrice * totalPeople;
    final sleeperTotal = journey.availableSleepers.first.pricePremium() * totalPeople;
    final total = baseTotal + sleeperTotal;

    return GestureDetector(
      onTap: onSelect,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: ECardoTokens.surfaceCard(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
          boxShadow: ECardoTokens.shadowCard(context),
        ),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.brand100(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                  ),
                  child: Icon(
                    journey.category.icon,
                    color: ECardoTokens.brand500(context),
                    size: 16.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Text(
                  journey.operator,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: ECardoTokens.inkMuted(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),

            // Time Line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journey.departLabel,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(journey.originStation, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context))),
                      Text(journey.departurePlatform, style: TextStyle(fontSize: 10.sp, color: ECardoTokens.inkMuted(context))),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.swap_horiz_rounded, color: ECardoTokens.brand500(context), size: 20.r),
                      SizedBox(height: 6.h),
                      Text(
                        journey.durationLabel,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: ECardoTokens.inkMuted(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        journey.arrivalLabel,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(journey.destinationStation, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context))),
                      Text(journey.arrivalPlatform, style: TextStyle(fontSize: 10.sp, color: ECardoTokens.inkMuted(context))),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Train Name & Badges
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        journey.trainName,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: ECardoTokens.ink(context)),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Train #${journey.trainNumber}',
                        style: TextStyle(fontSize: 10.sp, color: ECardoTokens.inkMuted(context)),
                      ),
                    ],
                  ),
                ),
                if (journey.transferInfo != null) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: journey.transferInfo!.safetyLevel.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                    ),
                    child: Icon(
                      journey.transferInfo!.safetyLevel.icon,
                      color: journey.transferInfo!.safetyLevel.color,
                      size: 14.r,
                    ),
                  ),
                  SizedBox(width: 6.w),
                ],
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: ECardoTokens.sand100(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                    border: Border.all(color: ECardoTokens.sand400(context).withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    formatAmount(total),
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.brand900(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
