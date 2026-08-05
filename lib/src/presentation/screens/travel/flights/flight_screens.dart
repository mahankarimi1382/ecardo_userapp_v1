import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_single_date_picker.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_suggestion_picker.dart';
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
  DateTime returnDate = DateTime.now().add(const Duration(days: 14));
  bool isRoundTrip = false;
  int adultCount = 1;
  int childCount = 0;
  int infantCount = 0;
  String cabinClass = 'economy';

  @override
  void initState() {
    super.initState();
    final controller = ensureTravelController();
    final previousSearch = controller.lastFlightSearch.value;
    originController.text = previousSearch?.origin ?? '';
    destinationController.text = previousSearch?.destination ?? '';
    departureDate = previousSearch?.departureDate ?? departureDate;
    returnDate = previousSearch?.returnDate ?? returnDate;
    isRoundTrip = previousSearch?.isRoundTrip ?? false;
    adultCount = previousSearch?.adultCount ?? adultCount;
    childCount = previousSearch?.childCount ?? childCount;
    infantCount = previousSearch?.infantCount ?? infantCount;
    cabinClass = previousSearch?.cabinClass.isNotEmpty == true
        ? previousSearch!.cabinClass
        : cabinClass;
    controller.loadUpcomingFlights();
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
    final controller = ensureTravelController();
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
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: false,
                      label: Text(localization.travelOneWay),
                      icon: const Icon(Icons.trending_flat_rounded),
                    ),
                    ButtonSegment(
                      value: true,
                      label: Text(localization.travelRoundTrip),
                      icon: const Icon(Icons.sync_alt_rounded),
                    ),
                  ],
                  selected: {isRoundTrip},
                  onSelectionChanged: (selection) =>
                      setState(() => isRoundTrip = selection.first),
                ),
                SizedBox(height: 16.h),
                TravelSuggestionField(
                  controller: originController,
                  label:
                      originField?.hint ??
                      originField?.label ??
                      localization.travelOrigin,
                  icon: Icons.flight_takeoff_rounded,
                  color: TravelTheme.blue,
                  type: TravelProductType.flight,
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
                TravelSuggestionField(
                  controller: destinationController,
                  label:
                      destinationField?.hint ??
                      destinationField?.label ??
                      localization.travelDestination,
                  icon: Icons.flight_land_rounded,
                  color: TravelTheme.blue,
                  type: TravelProductType.flight,
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
                if (isRoundTrip) ...[
                  SizedBox(height: 12.h),
                  CommonSingleDatePicker(
                    initialDate: returnDate.isAfter(departureDate)
                        ? returnDate
                        : departureDate.add(const Duration(days: 1)),
                    firstDate: departureDate.add(const Duration(days: 1)),
                    hintText: localization.travelReturnDate,
                    suffixIcon: const Icon(Icons.event_repeat_rounded),
                    onDateSelected: (value) =>
                        setState(() => returnDate = value),
                  ),
                ],
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
                SizedBox(height: 10.h),
                Row(
                  children: [
                    Expanded(
                      child: TravelFieldTile(
                        label: localization.travelInfants,
                        value: '$infantCount',
                        icon: Icons.child_friendly_rounded,
                        onTap: () => _selectCount(
                          label: localization.travelInfants,
                          current: infantCount,
                          minimum: 0,
                          maximum: adultCount,
                          onSelected: (value) =>
                              setState(() => infantCount = value),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: cabinClass,
                        decoration: InputDecoration(
                          labelText: localization.travelCabinClass,
                          prefixIcon: const Icon(
                            Icons.airline_seat_recline_normal_rounded,
                          ),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'economy',
                            child: Text(localization.travelEconomy),
                          ),
                          DropdownMenuItem(
                            value: 'business',
                            child: Text(localization.travelBusiness),
                          ),
                        ],
                        onChanged: (value) =>
                            setState(() => cabinClass = value ?? 'economy'),
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
                          origin == destination ||
                          (isRoundTrip && !returnDate.isAfter(departureDate)) ||
                          infantCount > adultCount) {
                        showTravelMessage(
                          context,
                          title: localization.travelFlightSearch,
                          message: localization.travelOfferUnavailable,
                        );
                        return;
                      }
                      final succeeded = await controller.searchFlights(
                        TravelFlightSearch(
                          origin: origin,
                          destination: destination,
                          departureDate: departureDate,
                          returnDate: isRoundTrip ? returnDate : null,
                          adultCount: adultCount,
                          childCount: childCount,
                          infantCount: infantCount,
                          cabinClass: cabinClass,
                        ),
                      );
                      controller.flightBookingDetails.value =
                          TravelBookingDetails(
                            adultCount: adultCount,
                            childCount: childCount,
                            infantCount: infantCount,
                            cabinClass: cabinClass,
                          );
                      if (!context.mounted) return;
                      if (succeeded) {
                        Get.to(() => const FlightResultsScreen());
                      } else {
                        showTravelMessage(
                          context,
                          title: localization.travelFlightSearch,
                          message: localization.allControllerLoadError,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          TravelJourneyGuide(
            currentStep: 0,
            steps: [
              localization.travelJourneySearch,
              localization.travelJourneyCompare,
              localization.travelJourneyReview,
              localization.travelJourneyPay,
            ],
            message: localization.travelFlightSearchGuidance,
          ),
          Obx(() {
            if (controller.recentFlightSearches.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 22.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TravelSectionHeader(title: localization.travelRecentSearches),
                  SizedBox(height: 10.h),
                  ...controller.recentFlightSearches.map(
                    (search) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: TravelCard(
                        onTap: () => setState(() {
                          originController.text = search.origin ?? '';
                          destinationController.text = search.destination ?? '';
                          departureDate = search.departureDate ?? departureDate;
                          returnDate = search.returnDate ?? returnDate;
                          isRoundTrip = search.isRoundTrip;
                          adultCount = search.adultCount;
                          childCount = search.childCount;
                          infantCount = search.infantCount;
                          cabinClass = search.cabinClass.isEmpty
                              ? 'economy'
                              : search.cabinClass;
                        }),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: TravelTheme.blue,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      '${search.origin ?? ''} → ${search.destination ?? ''}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  if (search.departureDate != null)
                                    Text(
                                      MaterialLocalizations.of(
                                        context,
                                      ).formatCompactDate(
                                        search.departureDate!,
                                      ),
                                      style: TextStyle(
                                        color: TravelTheme.muted,
                                        fontSize: 10.sp,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.north_west_rounded),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
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
                        isLoading: controller.isOfferLoadingFor(offer),
                        onTap: () async {
                          if (await controller.loadOfferDetails(offer)) {
                            Get.to(() => const FlightDetailsScreen());
                          }
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

class FlightResultsScreen extends StatefulWidget {
  const FlightResultsScreen({super.key});

  @override
  State<FlightResultsScreen> createState() => _FlightResultsScreenState();
}

class _FlightResultsScreenState extends State<FlightResultsScreen> {
  _FlightSort sort = _FlightSort.recommended;
  final selectedAirlines = <String>{};
  final selectedCabins = <String>{};
  final selectedRefundability = <String>{};
  final selectedComparisonIds = <String>{};

  bool get hasActiveComparison =>
      sort != _FlightSort.recommended ||
      selectedAirlines.isNotEmpty ||
      selectedCabins.isNotEmpty ||
      selectedRefundability.isNotEmpty;

  void resetComparison() {
    setState(() {
      sort = _FlightSort.recommended;
      selectedAirlines.clear();
      selectedCabins.clear();
      selectedRefundability.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    return TravelPage(
      title: localization.travelFlightResults,
      child: Obx(() {
        final search = controller.lastFlightSearch.value;
        final offers = controller.flightOffers;
        final comparison = _FlightComparison.fromOffers(
          offers,
          localization: localization,
          sort: sort,
          selectedAirlines: selectedAirlines,
          selectedCabins: selectedCabins,
          selectedRefundability: selectedRefundability,
        );
        return ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            if (search != null)
              _FlightSearchSummary(
                search: search,
                resultCount: comparison.offers.length,
                totalResultCount: offers.length,
                onEdit: Get.back,
              ),
            if (search != null) SizedBox(height: 16.h),
            TravelJourneyGuide(
              currentStep: 1,
              steps: [
                localization.travelJourneySearch,
                localization.travelJourneyCompare,
                localization.travelJourneyReview,
                localization.travelJourneyPay,
              ],
              message: localization.travelFlightResultsGuidance,
            ),
            SizedBox(height: 16.h),
            if (selectedComparisonIds.isNotEmpty) ...[
              TravelCard(
                color: TravelTheme.blue.withValues(alpha: .08),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.travelSelectedForComparison(
                          selectedComparisonIds.length,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showFlightComparison(
                        context,
                        offers
                            .where(
                              (offer) =>
                                  selectedComparisonIds.contains(offer.id),
                            )
                            .toList(),
                      ),
                      icon: const Icon(Icons.compare_arrows_rounded),
                      label: Text(localization.travelCompare),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
            ],
            if (controller.isLoading.value)
              const Center(child: CircularProgressIndicator())
            else if (offers.isEmpty) ...[
              _FlightResultsEmptyState(
                hasError: controller.searchError.value != null,
                onEdit: Get.back,
                onRetry: search == null
                    ? null
                    : () => controller.searchFlights(search),
              ),
              if (controller.upcomingFlightOffers.isNotEmpty) ...[
                SizedBox(height: 24.h),
                TravelSectionHeader(
                  title: localization.travelAlternativeFlights,
                  action: localization.p2pEdit,
                ),
                SizedBox(height: 6.h),
                Text(
                  localization.travelAlternativeFlightsDescription,
                  style: TextStyle(color: TravelTheme.muted, fontSize: 11.sp),
                ),
                SizedBox(height: 10.h),
                ...controller.upcomingFlightOffers
                    .take(8)
                    .map(
                      (offer) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _FlightOfferCard(
                          offer: offer,
                          isLoading: controller.isOfferLoadingFor(offer),
                          isCompared: selectedComparisonIds.contains(offer.id),
                          onCompare: () =>
                              _toggleFlightComparison(offer, localization),
                          onTap: () async {
                            if (await controller.loadOfferDetails(offer)) {
                              Get.to(() => const FlightDetailsScreen());
                            }
                          },
                        ),
                      ),
                    ),
              ],
            ] else ...[
              if (comparison.hasControls) ...[
                _FlightComparisonControls(
                  comparison: comparison,
                  sort: sort,
                  selectedAirlines: selectedAirlines,
                  selectedCabins: selectedCabins,
                  selectedRefundability: selectedRefundability,
                  hasActiveComparison: hasActiveComparison,
                  onSortSelected: (value) => setState(() => sort = value),
                  onAirlineSelected: (value, selected) => setState(
                    () => selected
                        ? selectedAirlines.add(value)
                        : selectedAirlines.remove(value),
                  ),
                  onCabinSelected: (value, selected) => setState(
                    () => selected
                        ? selectedCabins.add(value)
                        : selectedCabins.remove(value),
                  ),
                  onRefundabilitySelected: (value, selected) => setState(
                    () => selected
                        ? selectedRefundability.add(value)
                        : selectedRefundability.remove(value),
                  ),
                  onReset: resetComparison,
                ),
                SizedBox(height: 14.h),
              ],
              if (comparison.offers.isEmpty)
                Column(
                  children: [
                    TravelEmptyState(
                      message: localization.travelNoFlightResults,
                    ),
                    SizedBox(height: 10.h),
                    TextButton.icon(
                      onPressed: resetComparison,
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: Text(localization.reset),
                    ),
                  ],
                )
              else
                ...comparison.offers.map(
                  (offer) => Padding(
                    padding: EdgeInsets.only(bottom: 14.h),
                    child: _FlightOfferCard(
                      offer: offer,
                      isLoading: controller.isOfferLoadingFor(offer),
                      isCompared: selectedComparisonIds.contains(offer.id),
                      onCompare: () =>
                          _toggleFlightComparison(offer, localization),
                      onTap: () async {
                        if (await controller.loadOfferDetails(offer)) {
                          Get.to(() => const FlightDetailsScreen());
                        }
                      },
                    ),
                  ),
                ),
            ],
          ],
        );
      }),
    );
  }

  void _toggleFlightComparison(
    TravelOffer offer,
    AppLocalizations localization,
  ) {
    setState(() {
      if (selectedComparisonIds.contains(offer.id)) {
        selectedComparisonIds.remove(offer.id);
      } else if (selectedComparisonIds.length < 3) {
        selectedComparisonIds.add(offer.id);
      } else {
        showTravelMessage(
          context,
          title: localization.travelCompare,
          message: localization.travelCompareLimit,
        );
      }
    });
  }
}

class _FlightOfferCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;
  final VoidCallback? onCompare;
  final bool isLoading;
  final bool isCompared;

  const _FlightOfferCard({
    required this.offer,
    required this.onTap,
    this.onCompare,
    this.isLoading = false,
    this.isCompared = false,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
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
      onTap: isLoading ? null : onTap,
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
                    ? const Icon(Icons.flight_rounded, color: TravelTheme.blue)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15.r),
                        child: Image.network(
                          offer.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Icon(
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
              if (onCompare != null)
                IconButton(
                  tooltip: localization.travelCompare,
                  onPressed: onCompare,
                  icon: Icon(
                    isCompared
                        ? Icons.library_add_check_rounded
                        : Icons.library_add_outlined,
                    color: isCompared ? TravelTheme.blue : TravelTheme.muted,
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
                text: controller.isSelectingReturnFlight.value
                    ? localization.travelSelectReturnFlight
                    : localization.travelSelectFlight,
                isLoading: isLoading,
                onPressed: isLoading ? null : onTap,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _showFlightComparison(
  BuildContext context,
  List<TravelOffer> offers,
) async {
  if (offers.isEmpty) return;
  final localization = AppLocalizations.of(context)!;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) => SafeArea(
      child: FractionallySizedBox(
        heightFactor: .86,
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            TravelSectionHeader(title: localization.travelCompareFlights),
            SizedBox(height: 12.h),
            Text(
              localization.travelComparisonUsesBackendFacts,
              style: TextStyle(color: TravelTheme.muted, fontSize: 11.sp),
            ),
            SizedBox(height: 16.h),
            ...offers.map(
              (offer) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: TravelCard(
                  child: _FlightDetailRows(
                    values: {
                      localization.travelAirline: _flightValue(
                        offer,
                        'airline_name',
                        fallback: offer.titleKey,
                      ),
                      localization.travelFlightNumber: _flightValue(
                        offer,
                        'flight_number',
                      ),
                      localization.travelDeparture: _flightDateTime(
                        offer,
                        'departure',
                      ),
                      localization.travelArrival: _flightDateTime(
                        offer,
                        'arrival',
                      ),
                      localization.travelDuration: _flightValue(
                        offer,
                        'duration',
                      ),
                      localization.travelCabin: _flightValue(
                        offer,
                        'cabin_class',
                      ),
                      localization.travelBaggage: _flightValue(
                        offer,
                        'baggage',
                      ),
                      localization.travelTotal: travelMoney(
                        context,
                        offer.total,
                      ),
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _FlightSearchSummary extends StatelessWidget {
  final TravelFlightSearch search;
  final int resultCount;
  final int totalResultCount;
  final VoidCallback onEdit;

  const _FlightSearchSummary({
    required this.search,
    required this.resultCount,
    required this.totalResultCount,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final departureDate = search.departureDate;
    final formattedDeparture = departureDate == null
        ? ''
        : MaterialLocalizations.of(context).formatCompactDate(departureDate);
    final formattedReturn = search.returnDate == null
        ? ''
        : MaterialLocalizations.of(
            context,
          ).formatCompactDate(search.returnDate!);
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flight_takeoff_rounded, color: TravelTheme.blue),
              SizedBox(width: 8.w),
              Expanded(
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '${search.origin ?? ''} → ${search.destination ?? ''}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: Text(localization.p2pEdit),
              ),
            ],
          ),
          if (formattedDeparture.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              [
                formattedDeparture,
                if (formattedReturn.isNotEmpty) formattedReturn,
              ].join(' → '),
              style: TextStyle(color: TravelTheme.muted),
            ),
          ],
          SizedBox(height: 6.h),
          Text(
            '${localization.travelAdults}: ${search.adultCount}  •  '
            '${localization.travelChildren}: ${search.childCount}  •  '
            '${localization.travelInfants}: ${search.infantCount}',
            style: TextStyle(color: TravelTheme.muted),
          ),
          const Divider(height: 24),
          Text(
            resultCount == totalResultCount
                ? '$resultCount ${localization.travelFlightResults}'
                : '$resultCount / $totalResultCount '
                      '${localization.travelFlightResults}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

enum _FlightSort { recommended, price, departure, duration }

class _FlightComparison {
  final List<TravelOffer> offers;
  final List<String> airlines;
  final List<String> cabins;
  final List<String> refundability;
  final bool canSortByPrice;
  final bool canSortByDeparture;
  final bool canSortByDuration;

  const _FlightComparison({
    required this.offers,
    required this.airlines,
    required this.cabins,
    required this.refundability,
    required this.canSortByPrice,
    required this.canSortByDeparture,
    required this.canSortByDuration,
  });

  bool get hasControls =>
      canSortByPrice ||
      canSortByDeparture ||
      canSortByDuration ||
      airlines.length > 1 ||
      cabins.length > 1 ||
      refundability.length > 1;

  factory _FlightComparison.fromOffers(
    Iterable<TravelOffer> source, {
    required AppLocalizations localization,
    required _FlightSort sort,
    required Set<String> selectedAirlines,
    required Set<String> selectedCabins,
    required Set<String> selectedRefundability,
  }) {
    final original = source.toList(growable: false);
    final airlines = _flightDistinctValues(
      original.map((offer) => _flightExplicitValue(offer, 'airline_name')),
    );
    final cabins = _flightDistinctValues(
      original.map((offer) => _flightExplicitValue(offer, 'cabin_class')),
    );
    final refundability = _flightDistinctValues(
      original.map((offer) => _flightRefundability(offer, localization)),
    );
    final currencies = original
        .map((offer) => offer.total.currency.trim().toUpperCase())
        .where((value) => value.isNotEmpty)
        .toSet();
    final canSortByPrice =
        original.length > 1 &&
        currencies.length == 1 &&
        original.every((offer) => offer.total.amount.isFinite);
    final canSortByDeparture =
        original.length > 1 &&
        original.every((offer) => _flightDepartureInstant(offer) != null);
    final canSortByDuration =
        original.length > 1 &&
        original.every((offer) => _flightDurationMinutes(offer) != null);

    final filtered = original.where((offer) {
      final airline = _flightExplicitValue(offer, 'airline_name');
      final cabin = _flightExplicitValue(offer, 'cabin_class');
      final refundable = _flightRefundability(offer, localization);
      return (selectedAirlines.isEmpty || selectedAirlines.contains(airline)) &&
          (selectedCabins.isEmpty || selectedCabins.contains(cabin)) &&
          (selectedRefundability.isEmpty ||
              selectedRefundability.contains(refundable));
    }).toList();

    switch (sort) {
      case _FlightSort.price when canSortByPrice:
        filtered.sort(
          (first, second) => first.total.amount.compareTo(second.total.amount),
        );
      case _FlightSort.departure when canSortByDeparture:
        filtered.sort(
          (first, second) => _flightDepartureInstant(
            first,
          )!.compareTo(_flightDepartureInstant(second)!),
        );
      case _FlightSort.duration when canSortByDuration:
        filtered.sort(
          (first, second) => _flightDurationMinutes(
            first,
          )!.compareTo(_flightDurationMinutes(second)!),
        );
      case _FlightSort.recommended:
      case _FlightSort.price:
      case _FlightSort.departure:
      case _FlightSort.duration:
        break;
    }

    return _FlightComparison(
      offers: filtered,
      airlines: airlines,
      cabins: cabins,
      refundability: refundability,
      canSortByPrice: canSortByPrice,
      canSortByDeparture: canSortByDeparture,
      canSortByDuration: canSortByDuration,
    );
  }
}

class _FlightComparisonControls extends StatelessWidget {
  final _FlightComparison comparison;
  final _FlightSort sort;
  final Set<String> selectedAirlines;
  final Set<String> selectedCabins;
  final Set<String> selectedRefundability;
  final bool hasActiveComparison;
  final ValueChanged<_FlightSort> onSortSelected;
  final void Function(String, bool) onAirlineSelected;
  final void Function(String, bool) onCabinSelected;
  final void Function(String, bool) onRefundabilitySelected;
  final VoidCallback onReset;

  const _FlightComparisonControls({
    required this.comparison,
    required this.sort,
    required this.selectedAirlines,
    required this.selectedCabins,
    required this.selectedRefundability,
    required this.hasActiveComparison,
    required this.onSortSelected,
    required this.onAirlineSelected,
    required this.onCabinSelected,
    required this.onRefundabilitySelected,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: TravelTheme.blue),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  localization.travelSortAndFilter,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (hasActiveComparison)
                TextButton(onPressed: onReset, child: Text(localization.reset)),
            ],
          ),
          Wrap(
            spacing: 8.w,
            runSpacing: 6.h,
            children: [
              ChoiceChip(
                label: Text(localization.travelRecommended),
                selected: sort == _FlightSort.recommended,
                onSelected: (_) => onSortSelected(_FlightSort.recommended),
              ),
              if (comparison.canSortByPrice)
                ChoiceChip(
                  label: Text(localization.travelLowestPrice),
                  selected: sort == _FlightSort.price,
                  onSelected: (_) => onSortSelected(_FlightSort.price),
                ),
              if (comparison.canSortByDeparture)
                ChoiceChip(
                  label: Text(localization.travelDeparture),
                  selected: sort == _FlightSort.departure,
                  onSelected: (_) => onSortSelected(_FlightSort.departure),
                ),
              if (comparison.canSortByDuration)
                ChoiceChip(
                  label: Text(localization.travelShortestDuration),
                  selected: sort == _FlightSort.duration,
                  onSelected: (_) => onSortSelected(_FlightSort.duration),
                ),
            ],
          ),
          if (comparison.airlines.length > 1) ...[
            SizedBox(height: 14.h),
            Text(
              localization.travelAirline,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6.h),
            _FlightFilterChips(
              values: comparison.airlines,
              selectedValues: selectedAirlines,
              onSelected: onAirlineSelected,
            ),
          ],
          if (comparison.cabins.length > 1) ...[
            SizedBox(height: 14.h),
            Text(
              localization.travelCabin,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6.h),
            _FlightFilterChips(
              values: comparison.cabins,
              selectedValues: selectedCabins,
              onSelected: onCabinSelected,
            ),
          ],
          if (comparison.refundability.length > 1) ...[
            SizedBox(height: 14.h),
            Text(
              localization.travelCancellationsAndRefunds,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            SizedBox(height: 6.h),
            _FlightFilterChips(
              values: comparison.refundability,
              selectedValues: selectedRefundability,
              onSelected: onRefundabilitySelected,
            ),
          ],
        ],
      ),
    );
  }
}

class _FlightFilterChips extends StatelessWidget {
  final List<String> values;
  final Set<String> selectedValues;
  final void Function(String, bool) onSelected;

  const _FlightFilterChips({
    required this.values,
    required this.selectedValues,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 6.h,
      children: values
          .map(
            (value) => FilterChip(
              label: TravelBidiText(value),
              selected: selectedValues.contains(value),
              onSelected: (selected) => onSelected(value, selected),
            ),
          )
          .toList(),
    );
  }
}

class _FlightResultsEmptyState extends StatelessWidget {
  final bool hasError;
  final VoidCallback onEdit;
  final VoidCallback? onRetry;

  const _FlightResultsEmptyState({
    required this.hasError,
    required this.onEdit,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Column(
      children: [
        TravelEmptyState(
          message: hasError
              ? localization.allControllerLoadError
              : localization.travelNoFlightResults,
        ),
        SizedBox(height: 16.h),
        if (hasError && onRetry != null)
          CommonButton(
            width: double.infinity,
            text: localization.noInternetConnectionRetryButton,
            backgroundColor: TravelTheme.blue,
            onPressed: onRetry,
          ),
        SizedBox(height: 10.h),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(localization.travelSearchFlights),
        ),
      ],
    );
  }
}

class _FlightTime extends StatelessWidget {
  final String code;
  final String city;
  final String time;

  const _FlightTime({required this.code, required this.time, this.city = ''});

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
    final controller = ensureTravelController();
    final offer = controller.selectedOffer.value;
    if (offer == null) {
      return TravelPage(
        title: localization.travelFlightDetails,
        child: TravelEmptyState(message: localization.travelOfferUnavailable),
      );
    }
    final canPurchase = controller.canPurchase(TravelProductType.flight);
    final bookingDetails = controller.flightBookingDetails.value;
    final outboundOffer = controller.selectedOutboundOffer.value;
    final search = controller.lastFlightSearch.value;
    final needsReturnSelection =
        search?.isRoundTrip == true && outboundOffer == null;
    final currentTotal = _flightTotal(offer, bookingDetails);
    final total = outboundOffer == null
        ? currentTotal
        : TravelMoney(
            amount:
                _flightTotal(outboundOffer, bookingDetails).amount +
                currentTotal.amount,
            currency: currentTotal.currency,
          );
    final departure = _flightDateTime(offer, 'departure');
    final arrival = _flightDateTime(offer, 'arrival');
    final segments = _flightMaps(offer.product['segments']);
    final cancellationRules = _flightMaps(offer.product['cancellation_rules']);
    return TravelPage(
      title: localization.travelFlightDetails,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: canPurchase
                ? needsReturnSelection
                      ? localization.travelSelectReturnFlight
                      : localization.travelContinueToPayment
                : localization.travelOfferUnavailable,
            backgroundColor: canPurchase ? TravelTheme.blue : TravelTheme.muted,
            onPressed: !canPurchase
                ? null
                : needsReturnSelection
                ? () async {
                    if (await controller.beginReturnFlightSelection(offer)) {
                      Get.off(() => const FlightResultsScreen());
                    } else if (context.mounted) {
                      showTravelMessage(
                        context,
                        title: localization.travelReturnFlight,
                        message: localization.travelSearchFailedDescription,
                      );
                    }
                  }
                : () => Get.to(
                    () => TravelCheckoutScreen(
                      type: TravelProductType.flight,
                      productId: outboundOffer?.id ?? offer.id,
                      title: travelLocalizedKey(
                        localization,
                        outboundOffer?.titleKey ?? offer.titleKey,
                      ),
                      total: total,
                      bookingDetails: bookingDetails.copyWith(
                        returnOfferId: outboundOffer == null ? '' : offer.id,
                      ),
                    ),
                  ),
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
          if (outboundOffer != null) ...[
            SizedBox(height: 12.h),
            TravelSectionHeader(title: localization.travelOutboundFlight),
            SizedBox(height: 10.h),
            _FlightOfferCard(offer: outboundOffer, onTap: () {}),
            SizedBox(height: 12.h),
            TravelSectionHeader(title: localization.travelReturnFlight),
          ],
          SizedBox(height: 18.h),
          TravelJourneyGuide(
            currentStep: 2,
            steps: [
              localization.travelJourneySearch,
              localization.travelJourneyCompare,
              localization.travelJourneyReview,
              localization.travelJourneyPay,
            ],
            message: localization.travelFlightDetailsGuidance,
          ),
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelFlightDetails),
          SizedBox(height: 10.h),
          TravelCard(
            child: _FlightDetailRows(
              values: {
                localization.travelAirline: _flightValue(offer, 'airline_name'),
                localization.travelFlightNumber: _flightValue(
                  offer,
                  'flight_number',
                ),
                localization.travelDeparture: departure,
                localization.travelArrival: arrival,
                localization.travelDuration: _flightValue(offer, 'duration'),
                localization.travelCabin: _flightValue(offer, 'cabin_class'),
                localization.travelBaggage:
                    _flightValue(offer, 'baggage').isEmpty
                    ? ''
                    : '${_flightValue(offer, 'baggage')} kg',
                localization.travelAircraft: _flightValue(
                  offer,
                  'aircraft_code',
                ),
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
                child: TravelCard(child: _FlightDetailRows(values: segment)),
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
                child: _FlightPolicyCard(values: rule),
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
                const Icon(
                  Icons.check_circle_rounded,
                  color: TravelTheme.green,
                ),
              ],
            ),
          ),
          SizedBox(height: 22.h),
          TravelSectionHeader(title: localization.travelFareDetails),
          SizedBox(height: 10.h),
          TravelCard(
            child: Column(
              children: [
                for (final component in _pricedFlightComponents(
                  offer,
                  bookingDetails,
                )) ...[
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
    final unit =
        double.tryParse(
          (component['unit_amount'] ?? component['amount'])?.toString() ?? '',
        ) ??
        0;
    final quantity = switch (type) {
      'adult' => bookingDetails.adultCount,
      'child' => bookingDetails.childCount,
      'infant' => bookingDetails.infantCount,
      _ => 0,
    };
    if (quantity <= 0 || unit <= 0) continue;
    result.add((
      '${component['label'] ?? _flightLabel(type)} × $quantity',
      TravelMoney(
        amount: unit * quantity,
        currency: component['currency']?.toString() ?? offer.total.currency,
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

class _FlightPolicyCard extends StatelessWidget {
  final Map<String, dynamic> values;

  const _FlightPolicyCard({required this.values});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final summary = _flightCancellationSummary(values);
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (summary.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.policy_outlined, color: TravelTheme.blue),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localization.travelCancellationPolicy,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 4.h),
                      TravelBidiText(
                        summary,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 22),
          ],
          _FlightDetailRows(values: values),
        ],
      ),
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
                  style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
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

String _flightCancellationSummary(Map<String, dynamic> source) {
  const keys = [
    'summary',
    'description',
    'policy',
    'cancellation_policy',
    'refund_policy',
    'penalty',
  ];
  for (final key in keys) {
    final value = _flightDisplayValue(source[key]).trim();
    if (value.isNotEmpty) return value;
  }
  if (source['refundable'] is bool) {
    return _flightDisplayValue(source['refundable']);
  }
  return '';
}

String _flightValue(TravelOffer offer, String key, {String fallback = ''}) {
  final value = offer.attributes[key] ?? offer.metadata[key];
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text == 'null' ? fallback : text;
}

String _flightExplicitValue(TravelOffer offer, String key) {
  final value = offer.attributes[key] ?? offer.metadata[key];
  final text = value?.toString().trim() ?? '';
  return text.isEmpty || text.toLowerCase() == 'null' ? '' : text;
}

List<String> _flightDistinctValues(Iterable<String> values) {
  final result = values.where((value) => value.isNotEmpty).toSet().toList();
  result.sort(
    (first, second) => first.toLowerCase().compareTo(second.toLowerCase()),
  );
  return result;
}

DateTime? _flightDepartureInstant(TravelOffer offer) {
  final raw = _flightExplicitValue(offer, 'departure');
  return DateTime.tryParse(raw.replaceFirst(' ', 'T'));
}

int? _flightDurationMinutes(TravelOffer offer) {
  final explicitMinutes =
      offer.attributes['duration_minutes'] ??
      offer.metadata['duration_minutes'];
  final minutes = int.tryParse(explicitMinutes?.toString() ?? '');
  if (minutes != null && minutes >= 0) return minutes;

  final raw = _flightExplicitValue(offer, 'duration').toLowerCase().trim();
  final clock = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(raw);
  if (clock != null) {
    return int.parse(clock.group(1)!) * 60 + int.parse(clock.group(2)!);
  }
  final hours = RegExp(r'(\d+(?:\.\d+)?)\s*(?:h|hr|hour)').firstMatch(raw);
  final minutePart = RegExp(r'(\d+)\s*(?:m|min|minute)').firstMatch(raw);
  if (hours == null && minutePart == null) return null;
  return ((double.tryParse(hours?.group(1) ?? '0') ?? 0) * 60).round() +
      (int.tryParse(minutePart?.group(1) ?? '0') ?? 0);
}

String _flightRefundability(TravelOffer offer, AppLocalizations localization) {
  const keys = [
    'refundability',
    'refundable',
    'is_refundable',
    'cancellation_type',
  ];
  for (final key in keys) {
    final value =
        offer.attributes[key] ?? offer.policies[key] ?? offer.metadata[key];
    if (value == null) continue;
    if (value is bool) {
      return value
          ? localization.travelFeatureRefundable
          : localization.travelNonRefundable;
    }
    final text = value.toString().trim();
    if (text.isEmpty || text.toLowerCase() == 'null') continue;
    return text;
  }
  return '';
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
  final infantFare = component('infant', 0);
  return TravelMoney(
    amount:
        adultFare * bookingDetails.adultCount +
        childFare * bookingDetails.childCount +
        infantFare * bookingDetails.infantCount,
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
