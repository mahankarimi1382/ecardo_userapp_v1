import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';
import 'hotel_list_screen.dart';
import 'hotel_search_components.dart';

/// International-Grade Hotel Search Screen with multi-criteria filters,
/// city autocomplete with distance calculation, guest occupancy selection,
/// popular cities, and recent searches.
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
  List<TravelRoomOccupancy> roomOccupancies = const [
    TravelRoomOccupancy(adults: 2),
  ];
  List<TravelSuggestion> popularCities = const [];
  List<TravelOffer> recommendedHotels = const [];
  String recommendedCity = '';
  bool discoveryLoading = true;

  // Multi-criteria filter options on search screen
  bool filterFreeCancellation = false;
  bool filterBreakfastIncluded = false;
  int? filterMinStars;

  @override
  void initState() {
    super.initState();
    final controller = ensureTravelController();
    final previousSearch = controller.lastHotelSearch.value;
    final details = controller.hotelBookingDetails.value;
    cityController.text = previousSearch?.city ?? '';
    checkInDate = previousSearch?.checkInDate ??
        details.checkInDate ??
        DateTime.now().add(const Duration(days: 30));
    checkOutDate = previousSearch?.checkOutDate ??
        details.checkOutDate ??
        checkInDate.add(const Duration(days: 2));
    roomCount = previousSearch?.roomCount ?? details.roomCount;
    adultCount = previousSearch?.adultCount ?? details.adultCount;
    childCount = previousSearch?.childCount ?? details.childCount;
    roomOccupancies = _normalizedRoomOccupancies(
      previousSearch?.roomOccupancies.isNotEmpty == true
          ? previousSearch!.roomOccupancies
          : details.roomOccupancies,
      roomCount: roomCount,
      adults: adultCount,
      children: childCount,
    );
    _loadDiscovery();
  }

  @override
  void dispose() {
    cityController.dispose();
    super.dispose();
  }

  Future<void> _loadDiscovery() async {
    final controller = ensureTravelController();
    final cities = await controller.getSuggestions(
      TravelProductType.hotel,
      limit: 10,
    );
    if (!mounted) return;
    setState(() {
      popularCities = cities;
      recommendedCity = cities.firstOrNull?.value ?? '';
    });
    if (recommendedCity.isNotEmpty) {
      await _loadRecommendations(recommendedCity);
    }
    if (mounted) setState(() => discoveryLoading = false);
  }

  Future<void> _loadRecommendations(String city) async {
    if (city.isEmpty) return;
    setState(() {
      recommendedCity = city;
      discoveryLoading = true;
    });
    try {
      final values = await ensureTravelController().repository.searchHotels(
            TravelHotelSearch(
              city: city,
              checkInDate: checkInDate,
              checkOutDate: checkOutDate,
              roomCount: roomCount,
              adultCount: adultCount,
              childCount: childCount,
              roomOccupancies: roomOccupancies,
            ),
          );
      if (mounted) setState(() => recommendedHotels = values.take(8).toList());
    } catch (_) {
      if (mounted) setState(() => recommendedHotels = const []);
    } finally {
      if (mounted) setState(() => discoveryLoading = false);
    }
  }

  Future<void> _selectDestination() async {
    final selected = await showHotelDestinationPicker(
      context,
      initialQuery: cityController.text,
    );
    if (!mounted || selected == null) return;
    setState(() => cityController.text = selected.value);
    _loadRecommendations(selected.value);
  }

  Future<void> _selectDates() async {
    final selected = await showHotelDateRangePicker(
      context,
      initialStart: checkInDate,
      initialEnd: checkOutDate,
    );
    if (!mounted || selected == null) return;
    setState(() {
      checkInDate = selected.start;
      checkOutDate = selected.end;
    });
  }

  Future<void> _submitSearch() async {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final city = cityController.text.trim();
    if (city.isEmpty) {
      showTravelMessage(
        context,
        title: localization.travelHotelSearch,
        message: AppLocalizations.of(context)!
            .hotel_select_a_destination_city_or_hotel,
      );
      return;
    }
    controller.hotelBookingDetails.value = TravelBookingDetails(
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      roomCount: roomCount,
      adultCount: adultCount,
      childCount: childCount,
      roomOccupancies: roomOccupancies,
    );
    final succeeded = await controller.searchHotels(
      TravelHotelSearch(
        city: city,
        checkInDate: checkInDate,
        checkOutDate: checkOutDate,
        roomCount: roomCount,
        adultCount: adultCount,
        childCount: childCount,
        roomOccupancies: roomOccupancies,
      ),
    );
    if (!mounted) return;
    if (succeeded) {
      Get.to(() => HotelListScreen(
            initialMinStars: filterMinStars,
            initialFreeCancellation: filterFreeCancellation,
          ));
    } else {
      showTravelMessage(
        context,
        title: localization.travelHotelSearch,
        message: localization.allControllerLoadError,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TravelPage(
      title: localization.travelHotelSearch,
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: ListView(
          padding: EdgeInsets.all(AppSpacing.xl.r),
          children: [
            // Hero Brand Header
            Container(
              height: 160.h,
              padding: EdgeInsets.all(ECardoTokens.space5.r),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ECardoTokens.radius2xl),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ECardoTokens.brand900(context),
                    ECardoTokens.brand700(context),
                  ],
                ),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: isRtl ? null : 0,
                    left: isRtl ? 0 : null,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.12,
                      child: Icon(
                        Icons.hotel_rounded,
                        size: 110.sp,
                        color: ECardoTokens.inkOnBrand,
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: ECardoTokens.inkOnBrand.withValues(alpha: 0.18),
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusSm),
                        ),
                        child: Text(
                          isRtl
                              ? 'سفر و اقامت بین‌المللی'
                              : 'Worldwide Accommodations',
                          style: TextStyle(
                            color: ECardoTokens.inkOnBrand,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        localization.travelHotelHero,
                        style: TextStyle(
                          color: ECardoTokens.inkOnBrand,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: ECardoTokens.space4.h),

            // Search Form Card
            Container(
              padding: EdgeInsets.all(ECardoTokens.space4.r),
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Destination City / Hotel Input
                  Semantics(
                    label: isRtl ? 'مقصد شهر یا هتل' : 'Destination city or hotel',
                    button: true,
                    child: InkWell(
                      onTap: _selectDestination,
                      borderRadius:
                          BorderRadius.circular(ECardoTokens.radiusMd),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: ECardoTokens.surfaceSunken(context),
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusMd),
                          border: Border.all(
                            color: ECardoTokens.border(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38.r,
                              height: 38.r,
                              decoration: BoxDecoration(
                                color: ECardoTokens.brand100(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.location_on_rounded,
                                color: ECardoTokens.brand500(context),
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    hotelFlowText(
                                      context,
                                      'شهر یا هتل مقصد',
                                      localization.travelDestinationCity,
                                    ),
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: ECardoTokens.inkMuted(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    cityController.text.isEmpty
                                        ? AppLocalizations.of(context)!
                                            .hotel_search_by_city_or_hotel_name
                                        : cityController.text,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w800,
                                      color: cityController.text.isEmpty
                                          ? ECardoTokens.inkMuted(context)
                                          : ECardoTokens.ink(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isRtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: ECardoTokens.inkMuted(context),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Dates Picker Tile
                  Semantics(
                    label: isRtl ? 'تاریخ ورود و خروج' : 'Stay Dates',
                    button: true,
                    child: InkWell(
                      onTap: _selectDates,
                      borderRadius:
                          BorderRadius.circular(ECardoTokens.radiusMd),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: ECardoTokens.surfaceSunken(context),
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusMd),
                          border: Border.all(
                            color: ECardoTokens.border(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38.r,
                              height: 38.r,
                              decoration: BoxDecoration(
                                color: ECardoTokens.brand100(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.calendar_month_rounded,
                                color: ECardoTokens.brand500(context),
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!
                                        .hotel_check_in_and_check_out,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: ECardoTokens.inkMuted(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Text(
                                      '${MaterialLocalizations.of(context).formatCompactDate(checkInDate)}'
                                      ' – '
                                      '${MaterialLocalizations.of(context).formatCompactDate(checkOutDate)}'
                                      '  •  '
                                      '${checkOutDate.difference(checkInDate).inDays} '
                                      '${AppLocalizations.of(context)!.hotel_nights}',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w800,
                                        color: ECardoTokens.ink(context),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isRtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: ECardoTokens.inkMuted(context),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // Guests & Rooms Tile
                  Semantics(
                    label: isRtl ? 'تعداد مهمانان و اتاق‌ها' : 'Guests and Rooms',
                    button: true,
                    child: InkWell(
                      onTap: _showGuestPicker,
                      borderRadius:
                          BorderRadius.circular(ECardoTokens.radiusMd),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: ECardoTokens.surfaceSunken(context),
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusMd),
                          border: Border.all(
                            color: ECardoTokens.border(context),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38.r,
                              height: 38.r,
                              decoration: BoxDecoration(
                                color: ECardoTokens.brand100(context),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.group_rounded,
                                color: ECardoTokens.brand500(context),
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localization.travelGuests,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: ECardoTokens.inkMuted(context),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    formatHotelOccupancy(
                                      context,
                                      rooms: roomCount,
                                      adults: adultCount,
                                      children: childCount,
                                    ),
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w800,
                                      color: ECardoTokens.ink(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              isRtl
                                  ? Icons.chevron_left_rounded
                                  : Icons.chevron_right_rounded,
                              color: ECardoTokens.inkMuted(context),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Quick Criteria Filters
                  Text(
                    isRtl ? 'فیلترهای سریع' : 'Quick Filters',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: ECardoTokens.inkMuted(context),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      FilterChip(
                        avatar: Icon(
                          Icons.verified_user_outlined,
                          size: 16.sp,
                          color: filterFreeCancellation
                              ? ECardoTokens.success(context)
                              : ECardoTokens.inkMuted(context),
                        ),
                        label: Text(
                          hotelFlowText(context, 'کنسلی رایگان', 'Free Cancellation'),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: filterFreeCancellation
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: filterFreeCancellation
                                ? ECardoTokens.success(context)
                                : ECardoTokens.ink(context),
                          ),
                        ),
                        selected: filterFreeCancellation,
                        backgroundColor: ECardoTokens.surfaceSunken(context),
                        selectedColor: ECardoTokens.successBg(context),
                        side: BorderSide(
                          color: filterFreeCancellation
                              ? ECardoTokens.success(context)
                              : ECardoTokens.border(context),
                        ),
                        onSelected: (val) =>
                            setState(() => filterFreeCancellation = val),
                      ),
                      FilterChip(
                        avatar: Icon(
                          Icons.restaurant_rounded,
                          size: 16.sp,
                          color: filterBreakfastIncluded
                              ? ECardoTokens.brand700(context)
                              : ECardoTokens.inkMuted(context),
                        ),
                        label: Text(
                          isRtl ? 'شامل صبحانه' : 'Breakfast Included',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: filterBreakfastIncluded
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: filterBreakfastIncluded
                                ? ECardoTokens.brand700(context)
                                : ECardoTokens.ink(context),
                          ),
                        ),
                        selected: filterBreakfastIncluded,
                        backgroundColor: ECardoTokens.surfaceSunken(context),
                        selectedColor: ECardoTokens.brand100(context),
                        side: BorderSide(
                          color: filterBreakfastIncluded
                              ? ECardoTokens.brand700(context)
                              : ECardoTokens.border(context),
                        ),
                        onSelected: (val) =>
                            setState(() => filterBreakfastIncluded = val),
                      ),
                      ChoiceChip(
                        avatar: Icon(
                          Icons.star_rounded,
                          size: 16.sp,
                          color: ECardoTokens.sand600(context),
                        ),
                        label: Text(
                          '5 ★',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: filterMinStars == 5
                                ? FontWeight.w800
                                : FontWeight.w600,
                            color: filterMinStars == 5
                                ? ECardoTokens.sand600(context)
                                : ECardoTokens.ink(context),
                          ),
                        ),
                        selected: filterMinStars == 5,
                        backgroundColor: ECardoTokens.surfaceSunken(context),
                        selectedColor: ECardoTokens.sand100(context),
                        side: BorderSide(
                          color: filterMinStars == 5
                              ? ECardoTokens.sand400(context)
                              : ECardoTokens.border(context),
                        ),
                        onSelected: (sel) => setState(
                          () => filterMinStars = sel ? 5 : null,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Search Hotels Button
                  Obx(
                    () => CommonButton(
                      width: double.infinity,
                      height: 52,
                      text: localization.travelSearchHotels,
                      backgroundColor: ECardoTokens.brand900(context),
                      isLoading: controller.isLoading.value,
                      onPressed: () {
                        AppHaptics.light();
                        _submitSearch();
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),

            // Journey Guide
            TravelJourneyGuide(
              currentStep: 0,
              steps: [
                localization.travelJourneySearch,
                localization.travelJourneyCompare,
                localization.travelJourneyReview,
                localization.travelJourneyPay,
              ],
              message: localization.travelHotelSearchGuidance,
            ),
            SizedBox(height: 24.h),

            // Popular Destinations Header & Rail
            TravelSectionHeader(
              title: AppLocalizations.of(context)!.hotel_popular_cities,
            ),
            SizedBox(height: 10.h),
            if (popularCities.isEmpty && discoveryLoading)
              const TravelShimmerLoading(type: TravelShimmerType.card, count: 1)
            else
              SizedBox(
                height: 118.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: popularCities.length,
                  separatorBuilder: (_, _) => SizedBox(width: 10.w),
                  itemBuilder: (context, index) {
                    final city = popularCities[index];
                    final count =
                        city.metadata['property_count']?.toString() ?? '—';
                    final isSelected = city.value == recommendedCity;
                    return SizedBox(
                      width: 145.w,
                      child: Material(
                        color: isSelected
                            ? ECardoTokens.brand100(context)
                            : ECardoTokens.surfaceCard(context),
                        borderRadius:
                            BorderRadius.circular(ECardoTokens.radiusLg),
                        child: InkWell(
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusLg),
                          onTap: () {
                            setState(() => cityController.text = city.value);
                            _loadRecommendations(city.value);
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.r),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(ECardoTokens.radiusLg),
                              border: Border.all(
                                color: isSelected
                                    ? ECardoTokens.brand700(context)
                                    : ECardoTokens.border(context),
                                width: isSelected ? 1.5.w : 1.w,
                              ),
                              boxShadow: ECardoTokens.shadowCard(context),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(6.r),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? ECardoTokens.surfaceCard(context)
                                        : ECardoTokens.brand100(context),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.location_city_rounded,
                                    size: 18.sp,
                                    color: ECardoTokens.brand700(context),
                                  ),
                                ),
                                const Spacer(),
                                TravelBidiText(
                                  city.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13.sp,
                                    color: ECardoTokens.ink(context),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  AppLocalizations.of(context)!
                                      .hotelHotelsCount(count),
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
                    );
                  },
                ),
              ),

            SizedBox(height: 24.h),

            // Recommended Hotels Carousel
            TravelSectionHeader(
              title: AppLocalizations.of(context)!.hotel_recommended_hotels,
            ),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: popularCities
                  .take(6)
                  .map(
                    (city) => ChoiceChip(
                      label: Text(
                        city.title,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: city.value == recommendedCity
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: city.value == recommendedCity
                              ? ECardoTokens.inkOnBrand
                              : ECardoTokens.ink(context),
                        ),
                      ),
                      selected: city.value == recommendedCity,
                      selectedColor: ECardoTokens.brand900(context),
                      backgroundColor: ECardoTokens.surfaceCard(context),
                      side: BorderSide(
                        color: city.value == recommendedCity
                            ? ECardoTokens.brand900(context)
                            : ECardoTokens.border(context),
                      ),
                      onSelected: (_) => _loadRecommendations(city.value),
                    ),
                  )
                  .toList(),
            ),
            SizedBox(height: 12.h),
            if (discoveryLoading)
              const TravelShimmerLoading(type: TravelShimmerType.card, count: 2)
            else if (recommendedHotels.isEmpty)
              TravelEmptyState(
                icon: Icons.hotel_rounded,
                title: AppLocalizations.of(context)!
                    .hotel_no_recommended_hotels_are_available_for_this,
                message: localization.travelOfferUnavailable,
              )
            else
              SizedBox(
                height: 245.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: recommendedHotels.length,
                  separatorBuilder: (_, _) => SizedBox(width: 12.w),
                  itemBuilder: (context, index) {
                    final hotel = recommendedHotels[index];
                    return SizedBox(
                      width: 250.w,
                      child: _HotelRailCard(
                        offer: hotel,
                        isLoading: controller.isOfferLoadingFor(hotel),
                        onTap: () async {
                          setState(() => cityController.text = recommendedCity);
                          await _submitSearch();
                        },
                      ),
                    );
                  },
                ),
              ),

            // Recent Searches
            Obx(() {
              if (controller.recentHotelSearches.isEmpty) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(top: 22.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TravelSectionHeader(
                      title: localization.travelRecentSearches,
                    ),
                    SizedBox(height: 10.h),
                    ...controller.recentHotelSearches.map(
                      (search) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Material(
                          color: ECardoTokens.surfaceCard(context),
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusMd),
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(ECardoTokens.radiusMd),
                            onTap: () => setState(() {
                              cityController.text = search.city;
                              checkInDate = search.checkInDate;
                              checkOutDate = search.checkOutDate;
                              roomCount = search.roomCount;
                              adultCount = search.adultCount;
                              childCount = search.childCount;
                              roomOccupancies = _normalizedRoomOccupancies(
                                search.roomOccupancies,
                                roomCount: search.roomCount,
                                adults: search.adultCount,
                                children: search.childCount,
                              );
                            }),
                            child: Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  ECardoTokens.radiusMd,
                                ),
                                border: Border.all(
                                  color: ECardoTokens.border(context),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(8.r),
                                    decoration: BoxDecoration(
                                      color: ECardoTokens.brand100(context),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.history_rounded,
                                      size: 18.sp,
                                      color: ECardoTokens.brand700(context),
                                    ),
                                  ),
                                  SizedBox(width: 10.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        TravelBidiText(
                                          search.city,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13.sp,
                                            color: ECardoTokens.ink(context),
                                          ),
                                        ),
                                        Text(
                                          '${MaterialLocalizations.of(context).formatCompactDate(search.checkInDate)}'
                                          ' – '
                                          '${MaterialLocalizations.of(context).formatCompactDate(search.checkOutDate)}',
                                          style: TextStyle(
                                            color:
                                                ECardoTokens.inkMuted(context),
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.north_west_rounded,
                                    size: 18.sp,
                                    color: ECardoTokens.inkMuted(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Future<void> _showGuestPicker() async {
    var selectedRooms = roomOccupancies.toList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final localization = AppLocalizations.of(context)!;
        return StatefulBuilder(
          builder: (context, setSheetState) => Container(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
            decoration: BoxDecoration(
              color: ECardoTokens.surfaceCard(context),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ECardoTokens.radius2xl),
              ),
              border: Border.all(color: ECardoTokens.border(context)),
              boxShadow: ECardoTokens.shadowSheet(context),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.travelRooms,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 15.sp,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedRooms.length > 1
                            ? () => setSheetState(selectedRooms.removeLast)
                            : null,
                        icon: Icon(
                          Icons.remove_circle_outline_rounded,
                          color: selectedRooms.length > 1
                              ? ECardoTokens.brand700(context)
                              : ECardoTokens.inkMuted(context),
                        ),
                      ),
                      Text(
                        '${selectedRooms.length}',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15.sp,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedRooms.length < 8
                            ? () => setSheetState(
                                  () => selectedRooms.add(
                                    const TravelRoomOccupancy(adults: 1),
                                  ),
                                )
                            : null,
                        icon: Icon(
                          Icons.add_circle_outline_rounded,
                          color: selectedRooms.length < 8
                              ? ECardoTokens.brand700(context)
                              : ECardoTokens.inkMuted(context),
                        ),
                      ),
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (var index = 0;
                              index < selectedRooms.length;
                              index++)
                            Padding(
                              padding: EdgeInsets.only(top: 10.h),
                              child: Container(
                                padding: EdgeInsets.all(12.r),
                                decoration: BoxDecoration(
                                  color: ECardoTokens.surfaceSunken(context),
                                  borderRadius: BorderRadius.circular(
                                    ECardoTokens.radiusMd,
                                  ),
                                  border: Border.all(
                                    color: ECardoTokens.border(context),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        '${localization.travelRoom} ${index + 1}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                          fontSize: 13.sp,
                                          color: ECardoTokens.ink(context),
                                        ),
                                      ),
                                    ),
                                    _CountRow(
                                      label: localization.travelAdults,
                                      value: selectedRooms[index].adults,
                                      minimum: 1,
                                      maximum: 8,
                                      onChanged: (value) => setSheetState(
                                        () => selectedRooms[index] =
                                            TravelRoomOccupancy(
                                          adults: value,
                                          children:
                                              selectedRooms[index].children,
                                        ),
                                      ),
                                    ),
                                    _CountRow(
                                      label: localization.travelChildren,
                                      value: selectedRooms[index].children,
                                      minimum: 0,
                                      maximum: 6,
                                      onChanged: (value) => setSheetState(
                                        () => selectedRooms[index] =
                                            TravelRoomOccupancy(
                                          adults:
                                              selectedRooms[index].adults,
                                          children: value,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  CommonButton(
                    width: double.infinity,
                    height: 48,
                    text: localization.travelSelect,
                    backgroundColor: ECardoTokens.brand900(context),
                    onPressed: () {
                      setState(() {
                        roomOccupancies = selectedRooms;
                        roomCount = selectedRooms.length;
                        adultCount = selectedRooms.fold(
                          0,
                          (total, room) => total + room.adults,
                        );
                        childCount = selectedRooms.fold(
                          0,
                          (total, room) => total + room.children,
                        );
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

List<TravelRoomOccupancy> _normalizedRoomOccupancies(
  List<TravelRoomOccupancy> source, {
  required int roomCount,
  required int adults,
  required int children,
}) {
  if (source.length == roomCount && source.isNotEmpty) return source.toList();
  final rooms = List.generate(
    roomCount,
    (_) => const TravelRoomOccupancy(adults: 1),
  );
  var remainingAdults = adults - roomCount;
  var remainingChildren = children;
  var index = 0;
  while (remainingAdults > 0) {
    final room = rooms[index % rooms.length];
    rooms[index % rooms.length] = TravelRoomOccupancy(
      adults: room.adults + 1,
      children: room.children,
    );
    remainingAdults--;
    index++;
  }
  index = 0;
  while (remainingChildren > 0) {
    final room = rooms[index % rooms.length];
    rooms[index % rooms.length] = TravelRoomOccupancy(
      adults: room.adults,
      children: room.children + 1,
    );
    remainingChildren--;
    index++;
  }
  return rooms;
}

/// Human-readable, localized guest occupancy string for hotels.
String formatHotelOccupancy(
  BuildContext context, {
  required int rooms,
  required int adults,
  required int children,
}) {
  final lang = Localizations.localeOf(context).languageCode;
  if (lang == 'fa') {
    final roomStr = '$rooms اتاق';
    final adultStr = '$adults بزرگسال';
    final childStr = children > 0 ? '، $children کودک' : '';
    return '$roomStr، $adultStr$childStr';
  } else if (lang == 'ar') {
    final roomStr = '$rooms غرفة';
    final adultStr = '$adults بالغ';
    final childStr = children > 0 ? '، $children طفل' : '';
    return '$roomStr، $adultStr$childStr';
  } else if (lang == 'zh') {
    final roomStr = '$rooms 间房';
    final adultStr = '$adults 成人';
    final childStr = children > 0 ? '，$children 儿童' : '';
    return '$roomStr，$adultStr$childStr';
  } else {
    final roomStr = '$rooms ${rooms > 1 ? 'Rooms' : 'Room'}';
    final adultStr = '$adults ${adults > 1 ? 'Adults' : 'Adult'}';
    final childStr =
        children > 0 ? ', $children ${children > 1 ? 'Children' : 'Child'}' : '';
    return '$roomStr, $adultStr$childStr';
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
    final textPrimary = ECardoTokens.ink(context);
    final textSecondary = ECardoTokens.inkMuted(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: textPrimary,
                fontSize: 13.sp,
              ),
            ),
          ),
          IconButton(
            onPressed: value > minimum ? () => onChanged(value - 1) : null,
            icon: Icon(
              Icons.remove_circle_outline_rounded,
              color: value > minimum
                  ? ECardoTokens.brand700(context)
                  : textSecondary,
            ),
          ),
          SizedBox(
            width: 32.w,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 14.sp,
                color: textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: value < maximum ? () => onChanged(value + 1) : null,
            icon: Icon(
              Icons.add_circle_outline_rounded,
              color: value < maximum
                  ? ECardoTokens.brand700(context)
                  : textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HotelRailCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;
  final bool isLoading;

  const _HotelRailCard({
    required this.offer,
    required this.onTap,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
          onTap: isLoading ? null : onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ECardoTokens.radiusXl),
                ),
                child: SizedBox(
                  height: 105.h,
                  width: double.infinity,
                  child: offer.imageUrl.isEmpty
                      ? Container(
                          color: ECardoTokens.brand100(context),
                          child: Icon(
                            Icons.hotel_rounded,
                            size: 40.sp,
                            color: ECardoTokens.brand500(context),
                          ),
                        )
                      : Image.network(
                          offer.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            color: ECardoTokens.brand100(context),
                            child: Icon(
                              Icons.hotel_rounded,
                              size: 40.sp,
                              color: ECardoTokens.brand500(context),
                            ),
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        travelLocalizedKey(localization, offer.titleKey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13.sp,
                          color: ECardoTokens.ink(context),
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        travelLocalizedKey(localization, offer.subtitleKey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ECardoTokens.inkMuted(context),
                          fontSize: 10.sp,
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                travelMoney(context, offer.total),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: ECardoTokens.brand700(context),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ),
                          if (isLoading)
                            SizedBox(
                              width: 18.r,
                              height: 18.r,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: ECardoTokens.brand700(context),
                              ),
                            )
                          else
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16.sp,
                              color: ECardoTokens.brand700(context),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
