import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_single_date_picker.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  late DateTime checkInDate;
  late DateTime checkOutDate;

  @override
  void initState() {
    super.initState();
    final details = Get.find<TravelController>().hotelBookingDetails.value;
    checkInDate =
        details.checkInDate ??
        DateTime.now().add(const Duration(days: 30));
    checkOutDate =
        details.checkOutDate ??
        checkInDate.add(const Duration(days: 2));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    return TravelPage(
      title: localization.travelHotelSearch,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 170.h,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                colors: [Color(0xFF6A1B9A), TravelTheme.purple],
              ),
            ),
            child: Align(
              alignment: AlignmentDirectional.bottomStart,
              child: Text(
                localization.travelHotelHero,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          SizedBox(height: 22.h),
          TravelCard(
            child: Column(
              children: [
                TravelFieldTile(
                  label: localization.travelDestinationCountry,
                  value: localization.travelMockIran,
                  icon: Icons.public_rounded,
                ),
                SizedBox(height: 12.h),
                TravelFieldTile(
                  label: localization.travelDestinationCity,
                  value: localization.travelMockTehran,
                  icon: Icons.location_on_outlined,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: _TravelDateField(
                        label: localization.travelCheckIn,
                        initialDate: checkInDate,
                        firstDate: DateTime.now(),
                        onDateSelected: (value) {
                          setState(() {
                            checkInDate = value;
                            if (!checkOutDate.isAfter(checkInDate)) {
                              checkOutDate = checkInDate.add(
                                const Duration(days: 1),
                              );
                            }
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: _TravelDateField(
                        key: ValueKey(checkOutDate),
                        label: localization.travelCheckOut,
                        initialDate: checkOutDate,
                        firstDate: checkInDate.add(const Duration(days: 1)),
                        onDateSelected: (value) {
                          setState(() => checkOutDate = value);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                TravelFieldTile(
                  label: localization.travelGuests,
                  value: localization.travelMockGuests,
                  icon: Icons.group_outlined,
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CommonButton(
                    width: double.infinity,
                    text: localization.travelSearchHotels,
                    backgroundColor: TravelTheme.purple,
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      controller.hotelBookingDetails.value =
                          TravelBookingDetails(
                            checkInDate: checkInDate,
                            checkOutDate: checkOutDate,
                            roomCount: 1,
                            adultCount: 2,
                            childCount: 1,
                          );
                      await controller.searchHotels();
                      Get.to(() => const HotelResultsScreen());
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
                const Icon(Icons.apartment_rounded, color: TravelTheme.purple),
                SizedBox(width: 12.w),
                Expanded(child: Text(localization.travelMockTehranHotels)),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HotelResultsScreen extends StatelessWidget {
  const HotelResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    return TravelPage(
      title: localization.travelHotelResults,
      child: Obx(
        () => controller.hotelOffers.isEmpty
            ? TravelEmptyState(message: localization.travelNoHotelResults)
            : ListView.separated(
                padding: EdgeInsets.all(20.r),
                itemCount: controller.hotelOffers.length,
                separatorBuilder: (_, __) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final offer = controller.hotelOffers[index];
                  return _HotelOfferCard(
                    offer: offer,
                    onTap: () {
                      controller.selectedOffer.value = offer;
                      Get.to(() => const HotelDetailsScreen());
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _HotelOfferCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;

  const _HotelOfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 145.h,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              gradient: LinearGradient(
                colors: [Color(0xFF4A148C), TravelTheme.purple],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.hotel_rounded,
                size: 72.r,
                color: Colors.white.withValues(alpha: 0.88),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        travelLocalizedKey(localization, offer.titleKey),
                        style: TextStyle(
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text('★ ${offer.rating}'),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                Text(
                  travelLocalizedKey(localization, offer.subtitleKey),
                  style: TextStyle(color: TravelTheme.muted, fontSize: 11.sp),
                ),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 7.h,
                  children: offer.featureKeys
                      .map(
                        (feature) => Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(
                            travelLocalizedKey(localization, feature),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localization.travelStartingPrice,
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 10.sp,
                            ),
                          ),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              travelMoney(context, offer.total),
                              style: TextStyle(
                                color: TravelTheme.purple,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: TravelTheme.purple,
                      ),
                      onPressed: onTap,
                      child: Text(localization.travelViewDetails),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HotelDetailsScreen extends StatelessWidget {
  const HotelDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final offer = Get.find<TravelController>().selectedOffer.value;
    if (offer == null) {
      return TravelPage(
        title: localization.travelHotelDetails,
        child: TravelEmptyState(message: localization.travelOfferUnavailable),
      );
    }
    return TravelPage(
      title: localization.travelHotelDetails,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelReserveHotel,
            backgroundColor: TravelTheme.purple,
            onPressed: () => Get.to(
              () => TravelCheckoutScreen(
                type: TravelProductType.hotel,
                productId: offer.id,
                title: travelLocalizedKey(localization, offer.titleKey),
                total: offer.total,
                bookingDetails:
                    Get.find<TravelController>().hotelBookingDetails.value,
              ),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 230.h,
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [Color(0xFF311B92), TravelTheme.purple],
              ),
            ),
            child: const Center(
              child: Icon(Icons.king_bed_rounded, size: 100, color: Colors.white),
            ),
          ),
          SizedBox(height: 18.h),
          Text(
            travelLocalizedKey(localization, offer.titleKey),
            style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 6.h),
          Text(
            travelLocalizedKey(localization, offer.subtitleKey),
            style: TextStyle(color: TravelTheme.muted, fontSize: 12.sp),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _DetailHighlight(
                  icon: Icons.restaurant_rounded,
                  label: localization.travelFeatureBreakfast,
                  value: localization.travelIncluded,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DetailHighlight(
                  icon: Icons.wifi_rounded,
                  label: localization.travelFeatureWifi,
                  value: localization.travelFree,
                ),
              ),
            ],
          ),
          SizedBox(height: 26.h),
          TravelSectionHeader(title: localization.travelAboutHotel),
          SizedBox(height: 8.h),
          Text(
            localization.travelHotelDescription,
            style: TextStyle(fontSize: 13.sp, height: 1.8),
          ),
          SizedBox(height: 24.h),
          TravelSectionHeader(title: localization.travelPolicies),
          SizedBox(height: 10.h),
          TravelCard(
            child: Column(
              children: [
                _PolicyRow(
                  title: localization.travelCheckIn,
                  value: '14:00',
                ),
                const Divider(),
                _PolicyRow(
                  title: localization.travelCheckOut,
                  value: '12:00',
                ),
                const Divider(),
                _PolicyRow(
                  title: localization.travelCancellation,
                  value: localization.travelCancellationSummary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TravelDateField extends StatelessWidget {
  final String label;
  final DateTime initialDate;
  final DateTime firstDate;
  final ValueChanged<DateTime> onDateSelected;

  const _TravelDateField({
    super.key,
    required this.label,
    required this.initialDate,
    required this.firstDate,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsetsDirectional.only(start: 4.w, bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(color: TravelTheme.muted, fontSize: 11.sp),
          ),
        ),
        CommonSingleDatePicker(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: DateTime.now().add(const Duration(days: 730)),
          datePattern: 'yyyy/MM/dd',
          verticalPadding: 14.h,
          suffixIcon: const Icon(
            Icons.calendar_month_outlined,
            color: TravelTheme.purple,
          ),
          onDateSelected: onDateSelected,
        ),
      ],
    );
  }
}

class _DetailHighlight extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailHighlight({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: TravelTheme.purple),
          SizedBox(height: 12.h),
          Text(label, style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp)),
          SizedBox(height: 3.h),
          Text(value, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.sp)),
        ],
      ),
    );
  }
}

class _PolicyRow extends StatelessWidget {
  final String title;
  final String value;

  const _PolicyRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: Text(title)),
        SizedBox(width: 12.w),
        Flexible(
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: Text(value, textAlign: TextAlign.end),
          ),
        ),
      ],
    );
  }
}
