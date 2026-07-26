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

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  final cityController = TextEditingController();
  late DateTime checkInDate;
  late DateTime checkOutDate;
  int roomCount = 1;
  int adultCount = 2;
  int childCount = 0;

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
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final service = controller.serviceFor(TravelProductType.hotel);
    final cityField = service?.searchFields.firstWhereOrNull(
      (field) => field.key == 'city',
    );
    final heroTitle =
        service?.presentation['hero_title']?.toString() ??
        localization.travelHotelHero;
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
                heroTitle,
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
                CommonTextInputField(
                  controller: cityController,
                  hintText:
                      cityField?.hint ??
                      cityField?.label ??
                      localization.travelDestinationCity,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    color: TravelTheme.purple,
                  ),
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
                  value: '$roomCount / $adultCount / $childCount',
                  icon: Icons.group_outlined,
                  onTap: _showGuestPicker,
                ),
                SizedBox(height: 20.h),
                Obx(
                  () => CommonButton(
                    width: double.infinity,
                    text: localization.travelSearchHotels,
                    backgroundColor: TravelTheme.purple,
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      final city = cityController.text.trim().toUpperCase();
                      if (city.isEmpty) {
                        Get.snackbar(
                          localization.travelHotelSearch,
                          localization.travelDestinationCity,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                        return;
                      }
                      controller.hotelBookingDetails.value =
                          TravelBookingDetails(
                            checkInDate: checkInDate,
                            checkOutDate: checkOutDate,
                            roomCount: roomCount,
                            adultCount: adultCount,
                            childCount: childCount,
                          );
                      final succeeded = await controller.searchHotels(
                        TravelHotelSearch(
                          city: city,
                          checkInDate: checkInDate,
                          checkOutDate: checkOutDate,
                          roomCount: roomCount,
                          adultCount: adultCount,
                          childCount: childCount,
                        ),
                      );
                      if (succeeded) {
                        Get.to(() => const HotelResultsScreen());
                      } else {
                        Get.snackbar(
                          localization.travelHotelSearch,
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
        ],
      ),
    );
  }

  Future<void> _showGuestPicker() async {
    var selectedRooms = roomCount;
    var selectedAdults = adultCount;
    var selectedChildren = childCount;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final localization = AppLocalizations.of(context)!;
        return StatefulBuilder(
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
                  _CountRow(
                    label: localization.travelGuests,
                    value: selectedRooms,
                    minimum: 1,
                    maximum: 8,
                    onChanged: (value) =>
                        setSheetState(() => selectedRooms = value),
                  ),
                  _CountRow(
                    label: localization.travelAdults,
                    value: selectedAdults,
                    minimum: 1,
                    maximum: 8,
                    onChanged: (value) =>
                        setSheetState(() => selectedAdults = value),
                  ),
                  _CountRow(
                    label: localization.travelChildren,
                    value: selectedChildren,
                    minimum: 0,
                    maximum: 6,
                    onChanged: (value) =>
                        setSheetState(() => selectedChildren = value),
                  ),
                  SizedBox(height: 16.h),
                  CommonButton(
                    width: double.infinity,
                    text: localization.travelSelect,
                    backgroundColor: TravelTheme.purple,
                    onPressed: () {
                      setState(() {
                        roomCount = selectedRooms;
                        adultCount = selectedAdults;
                        childCount = selectedChildren;
                      });
                      Get.back();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CountRow extends StatelessWidget {
  final String label;
  final int value;
  final int minimum;
  final int maximum;
  final ValueChanged<int> onChanged;

  const _CountRow({
    required this.label,
    required this.value,
    required this.minimum,
    required this.maximum,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
          IconButton(
            onPressed: value > minimum ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          SizedBox(
            width: 34.w,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          IconButton(
            onPressed: value < maximum ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
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
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
            child: SizedBox(
              height: 145.h,
              width: double.infinity,
              child: offer.imageUrl.isNotEmpty
                  ? Image.network(
                      offer.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _HotelImageFallback(),
                    )
                  : const _HotelImageFallback(),
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
                    if (offer.rating > 0)
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
                    SizedBox(
                      width: 120.w,
                      child: CommonButton(
                        height: 42,
                        fontSize: 11,
                        backgroundColor: TravelTheme.purple,
                        text: localization.travelViewDetails,
                        onPressed: onTap,
                      ),
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

class _HotelImageFallback extends StatelessWidget {
  const _HotelImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
    );
  }
}

class HotelDetailsScreen extends StatelessWidget {
  const HotelDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.find<TravelController>();
    final offer = controller.selectedOffer.value;
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
            text: controller.canPurchase(TravelProductType.hotel)
                ? localization.travelReserveHotel
                : localization.travelOfferUnavailable,
            backgroundColor:
                controller.canPurchase(TravelProductType.hotel)
                ? TravelTheme.purple
                : TravelTheme.muted,
            onPressed: controller.canPurchase(TravelProductType.hotel)
                ? () => Get.to(
                    () => TravelCheckoutScreen(
                      type: TravelProductType.hotel,
                      productId: offer.id,
                      title: travelLocalizedKey(localization, offer.titleKey),
                      total: offer.total,
                      bookingDetails: controller.hotelBookingDetails.value,
                    ),
                  )
                : null,
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          ClipRRect(
            borderRadius: TravelTheme.radius,
            child: SizedBox(
              height: 230.h,
              width: double.infinity,
              child: offer.imageUrl.isNotEmpty
                  ? Image.network(
                      offer.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const _HotelImageFallback(),
                    )
                  : const _HotelImageFallback(),
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
