import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class FlightSearchScreen extends StatelessWidget {
  const FlightSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
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
                    localization.travelFlightHero,
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
                TravelFieldTile(
                  label: localization.travelOrigin,
                  value: localization.travelMockTehranAirport,
                  icon: Icons.flight_takeoff_rounded,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  child: const CircleAvatar(
                    backgroundColor: TravelTheme.blue,
                    child: Icon(Icons.swap_vert_rounded, color: Colors.white),
                  ),
                ),
                TravelFieldTile(
                  label: localization.travelDestination,
                  value: localization.travelMockIstanbulAirport,
                  icon: Icons.flight_land_rounded,
                ),
                SizedBox(height: 12.h),
                TravelFieldTile(
                  label: localization.travelDepartureDate,
                  value: '2026/08/20',
                  icon: Icons.calendar_month_outlined,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: TravelFieldTile(
                        label: localization.travelAdults,
                        value: '1',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: TravelFieldTile(
                        label: localization.travelChildren,
                        value: '0',
                        icon: Icons.child_care_rounded,
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
                      await controller.searchFlights();
                      Get.to(() => const FlightResultsScreen());
                    },
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 26.h),
          TravelSectionHeader(title: localization.travelRecentSearches),
          SizedBox(height: 10.h),
          TravelCard(
            child: Row(
              children: [
                const Icon(Icons.flight_rounded, color: TravelTheme.blue),
                SizedBox(width: 12.w),
                Expanded(
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(localization.travelMockRouteTehranIstanbul),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
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
            ? TravelEmptyState(message: localization.travelNoFlightResults)
            : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: controller.flightOffers.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final offer = controller.flightOffers[index];
                  return _FlightOfferCard(
                    offer: offer,
                    onTap: () {
                      controller.selectedOffer.value = offer;
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
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: TravelTheme.blue),
              onPressed: onTap,
              child: Text(localization.travelSelectFlight),
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
    return TravelPage(
      title: localization.travelFlightDetails,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelContinueToPayment,
            backgroundColor: TravelTheme.blue,
            onPressed: () => Get.to(
              () => TravelCheckoutScreen(
                type: TravelProductType.flight,
                productId: offer.id,
                title: travelLocalizedKey(localization, offer.titleKey),
                total: offer.total,
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
