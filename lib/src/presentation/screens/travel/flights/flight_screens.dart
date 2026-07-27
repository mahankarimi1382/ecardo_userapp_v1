import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class FlightSearchScreen extends StatefulWidget {
  const FlightSearchScreen({super.key});

  @override
  State<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends State<FlightSearchScreen> {
  final originController = TextEditingController();
  final destinationController = TextEditingController();
  DateTime departureDate = DateTime.now().add(const Duration(days: 7));
  int adultCount = 1;
  int childCount = 0;

  @override
  void initState() {
    super.initState();
    Get.find<TravelController>().loadUpcomingFlights();
  }

  @override
  void dispose() {
    originController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final service = controller.serviceFor(TravelProductType.flight);
    final originField = service?.searchFields.firstWhereOrNull(
      (field) => field.key == 'origin',
    );
    final destinationField = service?.searchFields.firstWhereOrNull(
      (field) => field.key == 'destination',
    );
    final heroTitle =
        service?.presentation['hero_title']?.toString() ??
        localization.travelFlightHero;
    return TravelPage(
      title: localization.travelFlightSearch,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 170.h,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), TravelTheme.blue],
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    Icons.flight_takeoff_rounded,
                    size: 110.r,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    heroTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
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
                CommonTextInputField(
                  controller: originController,
                  hintText:
                      originField?.hint ??
                      originField?.label ??
                      localization.travelOrigin,
                  prefixIcon: const Icon(
                    Icons.flight_takeoff_rounded,
                    color: TravelTheme.blue,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: IconButton(
                    onPressed: () {
                      final origin = originController.text;
                      originController.text = destinationController.text;
                      destinationController.text = origin;
                    },
                    icon: const CircleAvatar(
                      backgroundColor: TravelTheme.blue,
                      child: Icon(Icons.swap_vert_rounded, color: Colors.white),
                    ),
                  ),
                ),
                CommonTextInputField(
                  controller: destinationController,
                  hintText:
                      destinationField?.hint ??
                      destinationField?.label ??
                      localization.travelDestination,
                  prefixIcon: const Icon(
                    Icons.flight_land_rounded,
                    color: TravelTheme.blue,
                  ),
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
                          maximum: 9,
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
                          maximum: 8,
                          onSelected: (value) =>
                              setState(() => childCount = value),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CommonButton(
                    width: double.infinity,
                    text: localization.travelSearchFlights,
                    backgroundColor: TravelTheme.blue,
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      final origin = originController.text.trim().toUpperCase();
                      final destination = destinationController.text
                          .trim()
                          .toUpperCase();
                      if (origin.isEmpty ||
                          destination.isEmpty ||
                          origin == destination) {
                        Get.snackbar(
                          localization.travelFlightSearch,
                          localization.travelOfferUnavailable,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      final succeeded = await controller.searchFlights(
                        TravelFlightSearch(
                          origin: origin,
                          destination: destination,
                          departureDate: departureDate,
                          adultCount: adultCount,
                          childCount: childCount,
                        ),
                      );
                      controller.flightBookingDetails.value =
                          TravelBookingDetails(
                            adultCount: adultCount,
                            childCount: childCount,
                          );
                      if (succeeded) {
                        Get.to(() => const FlightResultsScreen());
                      } else {
                        Get.snackbar(
                          localization.travelFlightSearch,
                          localization.allControllerLoadError,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          TravelSectionHeader(
            title:
                service?.presentation['upcoming_title']?.toString() ??
                localization.travelFlights,
          ),
          SizedBox(height: 10.h),
          Obx(() {
            if (controller.isUpcomingFlightsLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.upcomingFlightOffers.isEmpty) {
              return TravelEmptyState(
                message: localization.travelNoFlightResults,
              );
            }
            return Column(
              children: controller.upcomingFlightOffers
                  .take(5)
                  .map(
                    (offer) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _FlightOfferCard(
                        offer: offer,
                        onTap: () async {
                          await controller.loadOfferDetails(offer);
                          Get.to(() => const FlightDetailsScreen());
                        },
                      ),
                    ),
                  )
                  .toList(),
            );
          }),
        ],
      ),
    );
  }

  Future<void> _selectCount({
    required String label,
    required int current,
    required int minimum,
    required int maximum,
    required ValueChanged<int> onSelected,
  }) async {
    var selected = current;
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Container(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selected > minimum
                          ? () => setSheetState(() => selected--)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    SizedBox(
                      width: 54.w,
                      child: Text(
                        '$selected',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: selected < maximum
                          ? () => setSheetState(() => selected++)
                          : null,
                      icon: const Icon(Icons.add_circle_outline_rounded),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                CommonButton(
                  width: double.infinity,
                  text: AppLocalizations.of(context)!.travelSelect,
                  backgroundColor: TravelTheme.blue,
                  onPressed: () {
                    onSelected(selected);
                    Get.back();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FlightResultsScreen extends StatelessWidget {
  const FlightResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    return TravelPage(
      title: localization.travelFlightResults,
      child: Obx(
        () => controller.flightOffers.isEmpty
            ? ListView(
                padding: EdgeInsets.all(20.r),
                children: [
                  TravelEmptyState(
                    message: localization.travelNoFlightResults,
                  ),
                  if (controller.upcomingFlightOffers.isNotEmpty) ...[
                    SizedBox(height: 24.h),
                    TravelSectionHeader(
                      title: localization.travelFlights,
                    ),
                    SizedBox(height: 10.h),
                    ...controller.upcomingFlightOffers.take(8).map(
                      (offer) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _FlightOfferCard(
                          offer: offer,
                          onTap: () async {
                            await controller.loadOfferDetails(offer);
                            Get.to(() => const FlightDetailsScreen());
                          },
                        ),
                      ),
                    ),
                  ],
                ],
              )
            : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: controller.flightOffers.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final offer = controller.flightOffers[index];
                  return _FlightOfferCard(
                    offer: offer,
                    onTap: () async {
                      await controller.loadOfferDetails(offer);
                      Get.to(() => const FlightDetailsScreen());
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _FlightOfferCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;

  const _FlightOfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final origin = _flightValue(offer, 'origin');
    final destination = _flightValue(offer, 'destination');
    final departure = _flightDateTime(offer, 'departure');
    final arrival = _flightDateTime(offer, 'arrival');
    final airline = _flightValue(
      offer,
      'airline_name',
      fallback: offer.titleKey,
    );
    final flightNumber = _flightValue(offer, 'flight_number');
    final duration = _flightValue(offer, 'duration');
    return TravelCard(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF3FF),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: offer.imageUrl.isEmpty
                    ? const Icon(
                        Icons.flight_rounded,
                        color: TravelTheme.blue,
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: Image.network(
                          offer.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.flight_rounded,
                            color: TravelTheme.blue,
                          ),
                        ),
                      ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TravelBidiText(
                      airline,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    TravelBidiText(
                      [
                        if (flightNumber.isNotEmpty) flightNumber,
                        if (offer.badgeKey.isNotEmpty)
                          travelLocalizedKey(localization, offer.badgeKey),
                      ].join(' • '),
                      style: TextStyle(
                        color: TravelTheme.blue,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  travelMoney(context, offer.total),
                  style: TextStyle(
                    color: TravelTheme.blue,
                    fontWeight: FontWeight.w900,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                _FlightTime(
                  code: origin,
                  city: _flightValue(offer, 'origin_name'),
                  time: _flightTime(departure),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        duration,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 10.sp,
                        ),
                      ),
                      const Divider(color: TravelTheme.blue),
                      Text(
                        localization.travelDirect,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 9.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                _FlightTime(
                  code: destination,
                  city: _flightValue(offer, 'destination_name'),
                  time: _flightTime(arrival),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                departure.split(' ').first,
                style: TextStyle(
                  color: TravelTheme.muted,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: SizedBox(
              width: 130.w,
              child: CommonButton(
                height: 42,
                fontSize: 11,
                backgroundColor: TravelTheme.blue,
                text: localization.travelSelectFlight,
                onPressed: onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlightTime extends StatelessWidget {
  final String code;
  final String city;
  final String time;

  const _FlightTime({
    required this.code,
    required this.time,
    this.city = '',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(time, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(code, style: const TextStyle(color: TravelTheme.muted)),
        if (city.isNotEmpty)
          SizedBox(
            width: 92.w,
            child: TravelBidiText(
              city,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: TravelTheme.muted, fontSize: 9.sp),
            ),
          ),
      ],
    );
  }
}

class FlightDetailsScreen extends StatelessWidget {
  const FlightDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final offer = controller.selectedOffer.value;
    if (offer == null) {
      return TravelPage(
        title: localization.travelFlightDetails,
        child: TravelEmptyState(message: localization.travelOfferUnavailable),
      );
    }
    final canPurchase = controller.canPurchase(TravelProductType.flight);
    final bookingDetails = controller.flightBookingDetails.value;
    final total = _flightTotal(offer, bookingDetails);
    final departure = _flightDateTime(offer, 'departure');
    final arrival = _flightDateTime(offer, 'arrival');
    final segments = _flightMaps(offer.product['segments']);
    final cancellationRules = _flightMaps(
      offer.product['cancellation_rules'],
    );
    return TravelPage(
      title: localization.travelFlightDetails,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: canPurchase
                ? localization.travelContinueToPayment
                : localization.travelOfferUnavailable,
            backgroundColor: canPurchase
                ? TravelTheme.blue
                : TravelTheme.muted,
            onPressed: canPurchase
                ? () => Get.to(
                    () => TravelCheckoutScreen(
                      type: TravelProductType.flight,
                      productId: offer.id,
                      title: travelLocalizedKey(localization, offer.titleKey),
                      total: total,
                      bookingDetails: bookingDetails,
                    ),
                  )
                : null,
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          TravelCard(
            color: const Color(0xFFEAF3FF),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                children: [
                  _FlightTime(
                    code: _flightValue(offer, 'origin'),
                    city: _flightValue(offer, 'origin_name'),
                    time: _flightTime(departure),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        children: [
                          Icon(Icons.flight_rounded, color: TravelTheme.blue),
                          Divider(color: TravelTheme.blue),
                        ],
                      ),
                    ),
                  ),
                  _FlightTime(
                    code: _flightValue(offer, 'destination'),
                    city: _flightValue(offer, 'destination_name'),
                    time: _flightTime(arrival),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelFlightDetails),
          SizedBox(height: 10.h),
          TravelCard(
            child: _FlightDetailRows(
              values: {
                'Airline': _flightValue(offer, 'airline_name'),
                'Flight': _flightValue(offer, 'flight_number'),
                'Departure': departure,
                'Arrival': arrival,
                'Duration': _flightValue(offer, 'duration'),
                'Cabin': _flightValue(offer, 'cabin_class'),
                'Baggage': _flightValue(offer, 'baggage').isEmpty
                    ? ''
                    : '${_flightValue(offer, 'baggage')} kg',
                'Aircraft': _flightValue(offer, 'aircraft_code'),
              },
            ),
          ),
          if (segments.isNotEmpty) ...[
            SizedBox(height: 22.h),
            TravelSectionHeader(title: localization.travelFlightDetails),
            SizedBox(height: 10.h),
            ...segments.map(
              (segment) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: TravelCard(
                  child: _FlightDetailRows(values: segment),
                ),
              ),
            ),
          ],
          if (cancellationRules.isNotEmpty) ...[
            SizedBox(height: 22.h),
            TravelSectionHeader(title: localization.travelPolicies),
            SizedBox(height: 10.h),
            ...cancellationRules.map(
              (rule) => Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: TravelCard(
                  child: _FlightDetailRows(values: rule),
                ),
              ),
            ),
          ],
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelPassengerReview),
          SizedBox(height: 10.h),
          TravelCard(
            child: Row(
              children: [
                const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.travelPrimaryPassenger,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        localization.travelPassengerFromProfile,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.check_circle_rounded, color: TravelTheme.green),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelFareDetails),
          SizedBox(height: 10.h),
          TravelCard(
            child: Column(
              children: [
                for (final component
                    in _pricedFlightComponents(offer, bookingDetails)) ...[
                  _FareRow(
                    label: component.$1,
                    value: travelMoney(context, component.$2),
                  ),
                  const Divider(),
                ],
                _FareRow(
                  label: localization.travelTotal,
                  value: travelMoney(context, total),
                  strong: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

List<(String, TravelMoney)> _pricedFlightComponents(
  TravelOffer offer,
  TravelBookingDetails bookingDetails,
) {
  final result = <(String, TravelMoney)>[];
  for (final component in offer.pricingComponents) {
    final type = component['type']?.toString().toLowerCase() ?? '';
    final unit = double.tryParse(
          (component['unit_amount'] ?? component['amount'])?.toString() ?? '',
        ) ??
        0;
    final quantity = switch (type) {
      'adult' => bookingDetails.adultCount,
      'child' => bookingDetails.childCount,
      _ => 0,
    };
    if (quantity <= 0 || unit <= 0) continue;
    result.add((
      '${component['label'] ?? _flightLabel(type)} × $quantity',
      TravelMoney(
        amount: unit * quantity,
        currency:
            component['currency']?.toString() ?? offer.total.currency,
      ),
    ));
  }
  if (result.isEmpty) {
    result.add((
      'Fare × ${bookingDetails.adultCount}',
      TravelMoney(
        amount: offer.total.amount * bookingDetails.adultCount,
        currency: offer.total.currency,
      ),
    ));
  }
  return result;
}

class _FareRow extends StatelessWidget {
  final String label;
  final String value;
  final bool strong;

  const _FareRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: strong ? FontWeight.w900 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(value, style: style),
        ),
      ],
    );
  }
}

class _FlightDetailRows extends StatelessWidget {
  final Map<String, dynamic> values;

  const _FlightDetailRows({required this.values});

  @override
  Widget build(BuildContext context) {
    final entries = values.entries
        .where((entry) => entry.value?.toString().trim().isNotEmpty == true)
        .toList();
    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92.w,
                child: Text(
                  _flightLabel(entries[index].key),
                  style: TextStyle(
                    color: TravelTheme.muted,
                    fontSize: 10.sp,
                  ),
                ),
              ),
              Expanded(
                child: TravelBidiText(
                  _flightDisplayValue(entries[index].value),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (index != entries.length - 1) const Divider(height: 22),
        ],
      ],
    );
  }
}

String _flightValue(
  TravelOffer offer,
  String key, {
  String fallback = '',
}) {
  final value = offer.attributes[key] ?? offer.metadata[key];
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}

String _flightDateTime(TravelOffer offer, String key) {
  final raw = _flightValue(offer, key);
  final parsed = DateTime.tryParse(raw.replaceFirst(' ', 'T'));
  if (parsed == null) return raw;
  return DateFormat('yyyy-MM-dd HH:mm').format(parsed);
}

String _flightTime(String dateTime) {
  final parsed = DateTime.tryParse(dateTime.replaceFirst(' ', 'T'));
  if (parsed == null) {
    final match = RegExp(r'\b\d{1,2}:\d{2}\b').firstMatch(dateTime);
    return match?.group(0) ?? dateTime;
  }
  return DateFormat('HH:mm').format(parsed);
}

TravelMoney _flightTotal(
  TravelOffer offer,
  TravelBookingDetails bookingDetails,
) {
  double component(String type, double fallback) {
    for (final item in offer.pricingComponents) {
      final itemType = item['type']?.toString().toLowerCase() ?? '';
      final label = item['label']?.toString().toLowerCase() ?? '';
      if (itemType == type || label.startsWith(type)) {
        return double.tryParse(
              (item['unit_amount'] ?? item['amount'])?.toString() ?? '',
            ) ??
            fallback;
      }
    }
    return fallback;
  }

  final adultFare = component('adult', offer.total.amount);
  final childFare = component('child', 0);
  return TravelMoney(
    amount:
        adultFare * bookingDetails.adultCount +
        childFare * bookingDetails.childCount,
    currency: offer.total.currency,
  );
}

List<Map<String, dynamic>> _flightMaps(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

String _flightLabel(String key) {
  final words = key.replaceAll('_', ' ').trim();
  if (words.isEmpty) return '';
  return '${words[0].toUpperCase()}${words.substring(1)}';
}

String _flightDisplayValue(dynamic value) {
  if (value is Map) {
    return value.entries
        .map(
          (entry) =>
              '${_flightLabel(entry.key.toString())}: ${_flightDisplayValue(entry.value)}',
        )
        .join(' • ');
  }
  if (value is List) {
    return value.map(_flightDisplayValue).join(', ');
  }
  return value?.toString() ?? '';
}
