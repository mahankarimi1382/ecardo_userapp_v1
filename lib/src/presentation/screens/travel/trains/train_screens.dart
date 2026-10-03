import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/mock_travel_data.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_request.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/seat_selection_map.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

import 'train_confirmation_screen.dart';

export 'train_confirmation_screen.dart';

/// Train module — mirrors the flights skeleton (search → results → details →
/// passengers) on the deterministic demo catalog. Submissions become local
/// service requests with the under-review status; nothing touches the
/// flight/hotel/esim backend contract.
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
  String trainClass = 'economy';

  Future<void> _pickCity({required bool isOrigin}) async {
    final localization = AppLocalizations.of(context)!;
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: TravelTheme.radius),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                isOrigin
                    ? localization.travelOrigin
                    : localization.travelDestination,
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900),
              ),
            ),
            ...mockIranCities.map(
              (city) => ListTile(
                leading: const Icon(Icons.train_rounded),
                title: TravelBidiText(city),
                onTap: () => Navigator.pop(context, city),
              ),
            ),
          ],
        ),
      ),
    );
    if (selected == null) return;
    setState(() {
      if (isOrigin) {
        origin = selected;
        if (destination == origin) destination = mockIranCities.first;
      } else {
        destination = selected;
        if (origin == destination) origin = mockIranCities[1];
      }
    });
  }

  Future<void> _selectCount({
    required String label,
    required int current,
    required int minimum,
    required int maximum,
    required ValueChanged<int> onSelected,
  }) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: TravelTheme.radius),
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
            ),
            for (var value = minimum; value <= maximum; value++)
              ListTile(
                title: Text('$value'),
                trailing: value == current
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (selected != null) onSelected(selected);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelServiceTrain,
      showTravelNavigation: false,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 170.h,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                colors: [Color(0xFF00695C), TravelTheme.green],
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.train_rounded,
                    size: 110.r,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    localization.travelTrainHero,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          TravelCard(
            child: Column(
              children: [
                TravelFieldTile(
                  label: localization.travelOrigin,
                  value: origin,
                  icon: Icons.trip_origin_rounded,
                  onTap: () => _pickCity(isOrigin: true),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: IconButton(
                    onPressed: () => setState(() {
                      final swapped = origin;
                      origin = destination;
                      destination = swapped;
                    }),
                    icon: const CircleAvatar(
                      backgroundColor: TravelTheme.green,
                      child: Icon(
                        Icons.swap_vert_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                TravelFieldTile(
                  label: localization.travelDestination,
                  value: destination,
                  icon: Icons.location_on_rounded,
                  onTap: () => _pickCity(isOrigin: false),
                ),
                SizedBox(height: 12.h),
                CommonSingleDatePicker(
                  initialDate: departureDate,
                  firstDate: DateTime.now(),
                  hintText: localization.travelDepartureDate,
                  suffixIcon: const Icon(Icons.calendar_month_outlined),
                  onDateSelected: (value) =>
                      setState(() => departureDate = value),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TravelFieldTile(
                        label: localization.travelAdults,
                        value: '$adultCount',
                        icon: Icons.person_outline_rounded,
                        onTap: () => _selectCount(
                          label: localization.travelAdults,
                          current: adultCount,
                          minimum: 1,
                          maximum: 6,
                          onSelected: (value) =>
                              setState(() => adultCount = value),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TravelFieldTile(
                        label: localization.travelChildren,
                        value: '$childCount',
                        icon: Icons.child_care_rounded,
                        onTap: () => _selectCount(
                          label: localization.travelChildren,
                          current: childCount,
                          minimum: 0,
                          maximum: 4,
                          onSelected: (value) =>
                              setState(() => childCount = value),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                DropdownButtonFormField<String>(
                  initialValue: trainClass,
                  decoration: InputDecoration(
                    labelText: localization.travelTrainClass,
                    prefixIcon: const Icon(
                      Icons.airline_seat_recline_normal_rounded,
                    ),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'economy',
                      child: Text(localization.travelTrainEconomy),
                    ),
                    DropdownMenuItem(
                      value: 'coupe',
                      child: Text(localization.travelTrainCoupe),
                    ),
                    DropdownMenuItem(
                      value: 'vip',
                      child: Text(localization.travelTrainVip),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => trainClass = value ?? 'economy'),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsetsDirectional.all(12.r),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: TravelTheme.blue, size: 20),
                SizedBox(width: 10.w),
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
                      color: TravelTheme.ink,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          CommonButton(
            width: double.infinity,
            text: l10nPick(
              context,
              en: 'Search Trains',
              fa: 'جستجوی قطارها',
              ar: 'البحث عن القطارات',
              zh: '搜索火车',
            ),
            backgroundColor: TravelTheme.green,
            onPressed: () {
              final trips = generateTrainTrips(
                origin,
                destination,
                departureDate,
              );
              Get.to(
                () => TrainResultsScreen(
                  origin: origin,
                  destination: destination,
                  departureDate: departureDate,
                  adultCount: adultCount,
                  childCount: childCount,
                  preferredClass: trainClass,
                  trips: trips,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Results
// ---------------------------------------------------------------------------

enum _TrainSort { recommended, price, departure, duration }

class TrainResultsScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final DateTime departureDate;
  final int adultCount;
  final int childCount;
  final String preferredClass;
  final List<TrainTrip> trips;

  const TrainResultsScreen({
    super.key,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.adultCount,
    required this.childCount,
    required this.preferredClass,
    required this.trips,
  });

  @override
  State<TrainResultsScreen> createState() => _TrainResultsScreenState();
}

class _TrainResultsScreenState extends State<TrainResultsScreen> {
  _TrainSort _sort = _TrainSort.recommended;

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final trips = [...widget.trips];
    switch (_sort) {
      case _TrainSort.price:
        trips.sort((a, b) => a.minPrice.compareTo(b.minPrice));
      case _TrainSort.departure:
        trips.sort(
          (a, b) => a.departMinutes.compareTo(b.departMinutes),
        );
      case _TrainSort.duration:
        trips.sort(
          (a, b) => a.durationMinutes.compareTo(b.durationMinutes),
        );
      case _TrainSort.recommended:
        break;
    }

    return TravelPage(
      title: localization.travelTrainResults,
      showTravelNavigation: false,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          TravelCard(
            color: const Color(0xFFE8F5EE),
            child: Row(
              children: [
                Expanded(
                  child: TravelBidiText(
                    '${widget.origin} ← ${widget.destination}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                Text(
                  DateFormat('yyyy-MM-dd').format(widget.departureDate),
                  style: TextStyle(
                    color: TravelTheme.muted,
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          TravelJourneyGuide(
            currentStep: 1,
            steps: [
              localization.travelJourneySearch,
              localization.travelJourneyCompare,
              localization.travelJourneyReview,
              localization.travelJourneyPay,
            ],
            message: localization.travelTrainResultsGuidance,
          ),
          SizedBox(height: 14.h),
          Wrap(
            spacing: 8.w,
            children: _TrainSort.values.map((sort) {
              final label = switch (sort) {
                _TrainSort.recommended => localization.travelSortRecommended,
                _TrainSort.price => localization.travelSortCheapest,
                _TrainSort.departure => localization.travelSortEarliest,
                _TrainSort.duration => localization.travelSortFastest,
              };
              final selected = _sort == sort;
              return ChoiceChip(
                label: Text(label),
                selected: selected,
                onSelected: (_) => setState(() => _sort = sort),
              );
            }).toList(),
          ),
          SizedBox(height: 14.h),
          ...trips.map(
            (trip) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _TrainTripCard(
                trip: trip,
                preferredClass: widget.preferredClass,
                onTap: () => Get.to(
                  () => TrainDetailsScreen(
                    trip: trip,
                    origin: widget.origin,
                    destination: widget.destination,
                    departureDate: widget.departureDate,
                    adultCount: widget.adultCount,
                    childCount: widget.childCount,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrainTripCard extends StatelessWidget {
  final TrainTrip trip;
  final String preferredClass;
  final VoidCallback onTap;

  const _TrainTripCard({
    required this.trip,
    required this.preferredClass,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelCard(
      onTap: onTap,
      child: Column(
        children: [
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                _TrainTime(
                  code: trip.departLabel,
                  label: localization.travelDeparture,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Column(
                      children: [
                        Text(
                          trip.durationLabel,
                          style: TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 10.sp,
                          ),
                        ),
                        const Divider(color: TravelTheme.green),
                        Icon(
                          Icons.train_rounded,
                          color: TravelTheme.green,
                          size: 18.r,
                        ),
                      ],
                    ),
                  ),
                ),
                _TrainTime(
                  code: trip.arrivalLabel,
                  label: localization.travelArrival,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TravelBidiText(
                      trip.trainName,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      '${localization.travelTrainNumber}: ${trip.trainNumber}',
                      style: TextStyle(
                        color: TravelTheme.muted,
                        fontSize: 10.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${formatMockAmount(trip.minPrice)} ${localization.travelMockCurrency}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w900,
                      color: TravelTheme.green,
                    ),
                  ),
                  Text(
                    localization.travelStartingPrice,
                    style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrainTime extends StatelessWidget {
  final String code;
  final String label;

  const _TrainTime({required this.code, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          code,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w900,
            color: TravelTheme.green,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: TravelTheme.muted, fontSize: 9.5.sp),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Details
// ---------------------------------------------------------------------------

class TrainDetailsScreen extends StatelessWidget {
  final TrainTrip trip;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final int adultCount;
  final int childCount;

  const TrainDetailsScreen({
    super.key,
    required this.trip,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.adultCount,
    required this.childCount,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelTrainDetails,
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelTrainContinueToPassengers,
            backgroundColor: TravelTheme.green,
            onPressed: () => Get.to(
              () => TrainBookingScreen(
                trip: trip,
                origin: origin,
                destination: destination,
                departureDate: departureDate,
                adultCount: adultCount,
                childCount: childCount,
              ),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          TravelCard(
            color: const Color(0xFFE8F5EE),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  _TrainTime(code: trip.departLabel, label: origin),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          Icon(Icons.train_rounded, color: TravelTheme.green),
                          Divider(color: TravelTheme.green),
                        ],
                      ),
                    ),
                  ),
                  _TrainTime(code: trip.arrivalLabel, label: destination),
                ],
              ),
            ),
          ),
          SizedBox(height: 20.h),
          TravelJourneyGuide(
            currentStep: 2,
            steps: [
              localization.travelJourneySearch,
              localization.travelJourneyCompare,
              localization.travelJourneyReview,
              localization.travelJourneyPay,
            ],
            message: localization.travelTrainDetailsGuidance,
          ),
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelTrainDetails),
          SizedBox(height: 10.h),
          TravelCard(
            child: Column(
              children: [
                _trainRow(
                  localization.travelTrainOperator,
                  trip.operator,
                ),
                Divider(color: TravelTheme.border),
                _trainRow(
                  localization.travelTrainNumber,
                  trip.trainNumber,
                ),
                Divider(color: TravelTheme.border),
                _trainRow(localization.travelDepartureDate, trip.departLabel),
                Divider(color: TravelTheme.border),
                _trainRow(localization.travelDuration, trip.durationLabel),
                Divider(color: TravelTheme.border),
                _trainRow(
                  localization.travelTrainWagon,
                  localization.travelTrainWagonType,
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelTrainClass),
          SizedBox(height: 10.h),
          ...trip.classes.map(
            (option) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: TravelCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            trainClassLabel(option.code, localization),
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${option.seatsLeft} ${localization.travelTrainSeatsLeft}',
                            style: TextStyle(
                              color: option.seatsLeft < 10
                                  ? TravelTheme.red
                                  : TravelTheme.muted,
                              fontSize: 10.5.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${formatMockAmount(option.price)} ${localization.travelMockCurrency}',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: TravelTheme.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelPolicies),
          SizedBox(height: 10.h),
          TravelCard(
            child: TravelBidiText(
              localization.travelTrainPolicyNote,
              style: TextStyle(color: TravelTheme.muted, fontSize: 11.5.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trainRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: TravelTheme.muted, fontSize: 12.sp)),
          TravelBidiText(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

String trainClassLabel(String code, AppLocalizations localization) =>
    switch (code) {
      'coupe' => localization.travelTrainCoupe,
      'vip' => localization.travelTrainVip,
      _ => localization.travelTrainEconomy,
    };

// ---------------------------------------------------------------------------
// Booking (local passengers → request)
// ---------------------------------------------------------------------------

class TrainBookingScreen extends StatefulWidget {
  final TrainTrip trip;
  final String origin;
  final String destination;
  final DateTime departureDate;
  final int adultCount;
  final int childCount;

  const TrainBookingScreen({
    super.key,
    required this.trip,
    required this.origin,
    required this.destination,
    required this.departureDate,
    required this.adultCount,
    required this.childCount,
  });

  @override
  State<TrainBookingScreen> createState() => _TrainBookingScreenState();
}

class _TrainBookingScreenState extends State<TrainBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final List<_PassengerForm> _passengers;
  final _phoneController = TextEditingController();
  String _selectedClass = 'economy';
  List<SeatItem> _selectedSeats = const [];

  @override
  void initState() {
    super.initState();
    final total = widget.adultCount + widget.childCount;
    _selectedClass = widget.trip.classes.first.code;
    _passengers = List.generate(
      total,
      (_) => _PassengerForm(),
    );
  }

  @override
  void dispose() {
    for (final passenger in _passengers) {
      passenger.dispose();
    }
    _phoneController.dispose();
    super.dispose();
  }

  TrainClassOption get _selectedOption => widget.trip.classes.firstWhere(
    (option) => option.code == _selectedClass,
    orElse: () => widget.trip.classes.first,
  );

  int get _seatExtraTotal =>
      _selectedSeats.fold(0, (sum, s) => sum + s.extraPrice.toInt());

  int get _totalPrice =>
      (_selectedOption.price * (widget.adultCount + widget.childCount)) +
      _seatExtraTotal;

  Future<void> _submit() async {
    final localization = AppLocalizations.of(context)!;
    if (_formKey.currentState?.validate() != true) return;
    final passengers = _passengers
        .map((passenger) => passenger.toPassenger())
        .toList();
    final details = <String, String>{
      localization.travelOrigin: widget.origin,
      localization.travelDestination: widget.destination,
      localization.travelDepartureDate: DateFormat(
        'yyyy-MM-dd',
      ).format(widget.departureDate),
      localization.travelTrainOperator: widget.trip.operator,
      localization.travelTrainNumber: widget.trip.trainNumber,
      localization.travelTrainClass: trainClassLabel(
        _selectedClass,
        localization,
      ),
      localization.travelContactPhone: _phoneController.text.trim(),
    };
    if (_selectedSeats.isNotEmpty) {
      details[l10nPick(
        context,
        en: 'Selected Seats',
        fa: 'صندلی‌های انتخابی',
        ar: 'المقاعد المختارة',
      )] = _selectedSeats.map((s) => s.code).join(', ');
    }
    passengers.asMap().forEach((index, passenger) {
      passenger.toDetails().forEach((key, value) {
        details['${localization.travelTrainPassengerLabel} '
                '${index + 1} — $key'] = value;
      });
    });
    final request = TravelServiceRequest(
      id: 'req-${DateTime.now().microsecondsSinceEpoch}',
      serviceKey: 'train',
      title: '${widget.origin} ← ${widget.destination}',
      subtitle:
          '${widget.trip.trainName} · ${DateFormat('yyyy-MM-dd').format(widget.departureDate)} '
          '${widget.trip.departLabel}',
      amountLabel:
          '${formatMockAmount(_totalPrice)} ${localization.travelMockCurrency}',
      reference: TravelServiceRequest.generateReference(),
      createdAt: DateTime.now(),
      details: details,
    );
    await TravelServiceRequestStore.add(request);
    if (!mounted) return;
    final passengerMaps = passengers.asMap().entries.map((entry) {
      final index = entry.key;
      final p = entry.value;
      return {
        'name': p.fullName,
        'national_code': p.nationalCode,
        'gender': p.gender,
        if (index < _selectedSeats.length) 'seat': _selectedSeats[index].code,
      };
    }).toList();
    Get.off(
      () => TrainConfirmationScreen(
        reference: request.reference,
        origin: widget.origin,
        destination: widget.destination,
        departureDate: widget.departureDate,
        trainName: widget.trip.trainName,
        trainNumber: widget.trip.trainNumber,
        operatorName: widget.trip.operator,
        departureTime: widget.trip.departLabel,
        arrivalTime: widget.trip.arrivalLabel,
        trainClass: trainClassLabel(_selectedClass, localization),
        totalPrice: _totalPrice,
        passengers: passengerMaps,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelPage(
      title: localization.travelTrainPassengers,
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelTrainConfirmBooking,
            backgroundColor: TravelTheme.green,
            onPressed: _submit,
          ),
        ),
      ),
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            TravelCard(
              color: const Color(0xFFE8F5EE),
              child: Column(
                children: [
                  TravelBidiText(
                    '${widget.origin} ← ${widget.destination}',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedClass,
                    decoration: InputDecoration(
                      labelText: localization.travelTrainClass,
                      prefixIcon: const Icon(
                        Icons.airline_seat_recline_normal_rounded,
                      ),
                    ),
                    items: widget.trip.classes
                        .map(
                          (option) => DropdownMenuItem(
                            value: option.code,
                            child: Text(
                              trainClassLabel(option.code, localization),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedClass = value ?? 'economy'),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            _TrainSeatSelectionCard(
              selectedSeats: _selectedSeats,
              passengerCount: widget.adultCount + widget.childCount,
              onTap: () async {
                final cabin = _selectedClass == 'vip'
                    ? SeatCabinClass.business
                    : SeatCabinClass.economy;
                final totalSeats = widget.adultCount + widget.childCount;
                final result = await showSeatSelectionBottomSheet(
                  context,
                  vehicleType: SeatVehicleType.train,
                  initialCabinClass: cabin,
                  maxSelectedSeats: totalSeats > 0 ? totalSeats : 1,
                  initiallySelectedSeatIds:
                      _selectedSeats.map((s) => s.id).toList(),
                  title: '${widget.trip.operator} ${widget.trip.trainNumber}',
                  subtitle: '${widget.origin} → ${widget.destination}',
                  currency: localization.travelMockCurrency,
                );
                if (result != null && mounted) {
                  setState(() => _selectedSeats = result);
                }
              },
            ),
            SizedBox(height: 18.h),
            ..._passengers.asMap().entries.map(
              (entry) => Padding(
                padding: EdgeInsets.only(bottom: 14.h),
                child: TravelCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${localization.travelTrainPassengerLabel} ${entry.key + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 12.5.sp,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _passengerField(
                        entry.value,
                        entry.value.nameController,
                        localization.travelFieldName,
                        Icons.person_outline_rounded,
                      ),
                      SizedBox(height: 10.h),
                      _passengerField(
                        entry.value,
                        entry.value.nationalCodeController,
                        localization.travelTrainNationalCode,
                        Icons.badge_rounded,
                        digitsOnly: true,
                        length: 10,
                      ),
                      SizedBox(height: 10.h),
                      DropdownButtonFormField<String>(
                        initialValue: entry.value.gender,
                        decoration: InputDecoration(
                          labelText: localization.travelTrainGender,
                          prefixIcon: const Icon(Icons.wc_rounded),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'male',
                            child: Text(localization.commonDropdownMale),
                          ),
                          DropdownMenuItem(
                            value: 'female',
                            child: Text(localization.commonDropdownFemale),
                          ),
                        ],
                        onChanged: (value) =>
                            entry.value.gender = value ?? 'male',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            TravelCard(
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: localization.travelContactPhone,
                  prefixIcon: const Icon(Icons.phone_rounded),
                ),
                validator: (value) =>
                    value == null || value.trim().length < 10
                    ? localization.travelFormRequired
                    : null,
              ),
            ),
            SizedBox(height: 16.h),
            TravelCard(
              color: const Color(0xFFE8F5EE),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    localization.travelTotal,
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '${formatMockAmount(_totalPrice)} ${localization.travelMockCurrency}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: TravelTheme.green,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              localization.travelTrainBookingNote,
              textAlign: TextAlign.center,
              style: TextStyle(color: TravelTheme.muted, fontSize: 10.5.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passengerField(
    _PassengerForm passenger,
    TextEditingController controller,
    String label,
    IconData icon, {
    bool digitsOnly = false,
    int? length,
  }) {
    final localization = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      keyboardType: digitsOnly ? TextInputType.number : TextInputType.text,
      maxLength: length,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        counterText: '',
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        final text = value?.trim() ?? '';
        if (text.isEmpty) return localization.travelFormRequired;
        if (digitsOnly && text.length < (length ?? 1)) {
          return localization.travelFormRequired;
        }
        return null;
      },
    );
  }
}

class _PassengerForm {
  final nameController = TextEditingController();
  final nationalCodeController = TextEditingController();
  String gender = 'male';

  TravelLocalPassenger toPassenger() => TravelLocalPassenger(
    fullName: nameController.text.trim(),
    nationalCode: nationalCodeController.text.trim(),
    gender: gender,
  );

  void dispose() {
    nameController.dispose();
    nationalCodeController.dispose();
  }
}

class _TrainSeatSelectionCard extends StatelessWidget {
  final List<SeatItem> selectedSeats;
  final int passengerCount;
  final VoidCallback onTap;

  const _TrainSeatSelectionCard({
    required this.selectedSeats,
    required this.passengerCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    if (selectedSeats.isEmpty) {
      return TravelCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5EE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.airline_seat_recline_normal_rounded,
                color: TravelTheme.green,
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
                      en: 'Select Seats',
                      fa: 'انتخاب صندلی',
                      ar: 'اختيار المقاعد',
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5.sp,
                      color: TravelTheme.ink,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'Choose preferred seats in the train carriage',
                      fa: 'انتخاب صندلی مورد نظر در واگن قطار',
                      ar: 'اختر المقاعد المفضلة في عربة القطار',
                    ),
                    style: TextStyle(
                      color: TravelTheme.muted,
                      fontSize: 10.5.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: TravelTheme.green,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                l10nPick(
                  context,
                  en: 'Select',
                  fa: 'انتخاب',
                  ar: 'اختيار',
                ),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11.5.sp,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return TravelCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.airline_seat_recline_normal_rounded,
                    color: TravelTheme.green,
                    size: 18,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    l10nPick(
                      context,
                      en: 'Selected Seats (${selectedSeats.length}/$passengerCount)',
                      fa: 'صندلی‌های انتخابی (${selectedSeats.length}/$passengerCount)',
                      ar: 'المقاعد المختارة (${selectedSeats.length}/$passengerCount)',
                    ),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: onTap,
                icon: const Icon(Icons.edit_outlined, size: 14),
                label: Text(
                  l10nPick(context, en: 'Change', fa: 'تغییر', ar: 'تغيير'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: TravelTheme.green,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: selectedSeats.map((seat) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5EE),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: TravelTheme.green.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      seat.isPremium
                          ? Icons.star_rounded
                          : Icons.airline_seat_recline_normal_rounded,
                      size: 13.r,
                      color: seat.isPremium
                          ? const Color(0xFFD4AF37)
                          : TravelTheme.green,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${seat.code} (${seat.type.localizedLabel(isRtl)})',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 11.sp,
                        color: TravelTheme.ink,
                      ),
                    ),
                    if (seat.extraPrice > 0) ...[
                      SizedBox(width: 4.w),
                      Text(
                        '+${seat.extraPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: TravelTheme.green,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

