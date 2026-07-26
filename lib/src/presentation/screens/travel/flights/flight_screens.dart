import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                child: const Icon(Icons.flight_rounded, color: TravelTheme.blue),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travelLocalizedKey(localization, offer.subtitleKey),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      travelLocalizedKey(localization, offer.badgeKey),
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
                  code: offer.metadata['origin']!,
                  time: offer.metadata['departure']!,
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        offer.metadata['duration']!,
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
                  code: offer.metadata['destination']!,
                  time: offer.metadata['arrival']!,
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
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
  final String time;

  const _FlightTime({required this.code, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(time, style: const TextStyle(fontWeight: FontWeight.w900)),
        Text(code, style: const TextStyle(color: TravelTheme.muted)),
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
                      total: offer.total,
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
                    code: offer.metadata['origin']!,
                    time: offer.metadata['departure']!,
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
                    code: offer.metadata['destination']!,
                    time: offer.metadata['arrival']!,
                  ),
                ],
              ),
            ),
          ),
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
                _FareRow(
                  label: localization.travelBaseFare,
                  value: travelMoney(
                    context,
                    TravelMoney(
                      amount: offer.total.amount * .84,
                      currency: offer.total.currency,
                    ),
                  ),
                ),
                const Divider(),
                _FareRow(
                  label: localization.travelTaxesAndFees,
                  value: travelMoney(
                    context,
                    TravelMoney(
                      amount: offer.total.amount * .16,
                      currency: offer.total.currency,
                    ),
                  ),
                ),
                const Divider(),
                _FareRow(
                  label: localization.travelTotal,
                  value: travelMoney(context, offer.total),
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
