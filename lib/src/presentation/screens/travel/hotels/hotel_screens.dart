import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';

import '../bookings/travel_checkout_screen.dart';
import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'hotel_filter_screen.dart';
import 'hotel_search_components.dart';

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

  @override
  void initState() {
    super.initState();
    final controller = ensureTravelController();
    final previousSearch = controller.lastHotelSearch.value;
    final details = controller.hotelBookingDetails.value;
    cityController.text = previousSearch?.city ?? '';
    checkInDate =
        previousSearch?.checkInDate ??
        details.checkInDate ??
        DateTime.now().add(const Duration(days: 30));
    checkOutDate =
        previousSearch?.checkOutDate ??
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
        message: hotelFlowText(
          context,
          'شهر یا هتل مقصد را انتخاب کنید.',
          'Select a destination city or hotel.',
        ),
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
      Get.to(() => const HotelResultsScreen());
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
                TextFormField(
                  controller: cityController,
                  readOnly: true,
                  onTap: _selectDestination,
                  decoration: InputDecoration(
                    labelText: hotelFlowText(
                      context,
                      'شهر یا هتل مقصد',
                      cityField?.hint ??
                          cityField?.label ??
                          localization.travelDestinationCity,
                    ),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: TravelTheme.purple,
                    ),
                    suffixIcon: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
                SizedBox(height: 12.h),
                InkWell(
                  onTap: _selectDates,
                  borderRadius: BorderRadius.circular(16.r),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Icons.date_range_outlined,
                        color: TravelTheme.purple,
                      ),
                      suffixIcon: const Icon(Icons.chevron_right_rounded),
                      labelText: hotelFlowText(
                        context,
                        'تاریخ ورود و خروج',
                        'Check-in and check-out',
                      ),
                    ),
                    child: Text(
                      '${MaterialLocalizations.of(context).formatCompactDate(checkInDate)}'
                      '  –  '
                      '${MaterialLocalizations.of(context).formatCompactDate(checkOutDate)}'
                      '  •  '
                      '${checkOutDate.difference(checkInDate).inDays} '
                      '${hotelFlowText(context, 'شب', 'nights')}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
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
                    onPressed: _submitSearch,
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
            message: localization.travelHotelSearchGuidance,
          ),
          SizedBox(height: 24.h),
          TravelSectionHeader(
            title: hotelFlowText(context, 'شهرهای محبوب', 'Popular cities'),
          ),
          SizedBox(height: 10.h),
          if (popularCities.isEmpty && discoveryLoading)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              height: 112.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: popularCities.length,
                separatorBuilder: (_, _) => SizedBox(width: 10.w),
                itemBuilder: (context, index) {
                  final city = popularCities[index];
                  final count =
                      city.metadata['property_count']?.toString() ?? '—';
                  return SizedBox(
                    width: 145.w,
                    child: TravelCard(
                      onTap: () {
                        setState(() => cityController.text = city.value);
                        _loadRecommendations(city.value);
                      },
                      color: city.value == recommendedCity
                          ? TravelTheme.purple.withValues(alpha: .1)
                          : Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_city_rounded,
                            color: TravelTheme.purple,
                          ),
                          const Spacer(),
                          TravelBidiText(
                            city.title,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            hotelFlowText(
                              context,
                              '$count هتل',
                              '$count hotels',
                            ),
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 10.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          SizedBox(height: 24.h),
          TravelSectionHeader(
            title: hotelFlowText(
              context,
              'هتل‌های پیشنهادی',
              'Recommended hotels',
            ),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: popularCities
                .take(6)
                .map(
                  (city) => ChoiceChip(
                    label: Text(city.title),
                    selected: city.value == recommendedCity,
                    onSelected: (_) => _loadRecommendations(city.value),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 12.h),
          if (discoveryLoading)
            const Center(child: CircularProgressIndicator())
          else if (recommendedHotels.isEmpty)
            TravelEmptyState(
              message: hotelFlowText(
                context,
                'هتل پیشنهادی برای این شهر موجود نیست.',
                'No recommended hotels are available for this city.',
              ),
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
          Obx(() {
            if (controller.recentHotelSearches.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: EdgeInsets.only(top: 22.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TravelSectionHeader(title: localization.travelRecentSearches),
                  SizedBox(height: 10.h),
                  ...controller.recentHotelSearches.map(
                    (search) => Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: TravelCard(
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
                        child: Row(
                          children: [
                            const Icon(
                              Icons.history_rounded,
                              color: TravelTheme.purple,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TravelBidiText(
                                    search.city,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${MaterialLocalizations.of(context).formatCompactDate(search.checkInDate)}'
                                    ' – '
                                    '${MaterialLocalizations.of(context).formatCompactDate(search.checkOutDate)}',
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
        ],
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        onPressed: selectedRooms.length > 1
                            ? () => setSheetState(selectedRooms.removeLast)
                            : null,
                        icon: const Icon(Icons.remove_circle_outline_rounded),
                      ),
                      Text(
                        '${selectedRooms.length}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      IconButton(
                        onPressed: selectedRooms.length < 8
                            ? () => setSheetState(
                                () => selectedRooms.add(
                                  const TravelRoomOccupancy(adults: 1),
                                ),
                              )
                            : null,
                        icon: const Icon(Icons.add_circle_outline_rounded),
                      ),
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (
                            var index = 0;
                            index < selectedRooms.length;
                            index++
                          )
                            Padding(
                              padding: EdgeInsets.only(top: 10.h),
                              child: TravelCard(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment:
                                          AlignmentDirectional.centerStart,
                                      child: Text(
                                        '${localization.travelRoom} ${index + 1}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
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
                    text: localization.travelSelect,
                    backgroundColor: TravelTheme.purple,
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

enum _HotelSort { recommended, priceLowToHigh, priceHighToLow, rating }

class HotelResultsScreen extends StatefulWidget {
  const HotelResultsScreen({super.key});

  @override
  State<HotelResultsScreen> createState() => _HotelResultsScreenState();
}

class _HotelResultsScreenState extends State<HotelResultsScreen> {
  _HotelSort _sort = _HotelSort.recommended;
  double? _minimumRating;
  final Set<String> _comparisonIds = {};
  final ScrollController _scrollController = ScrollController();
  HotelFilterState _filters = const HotelFilterState();
  int _visibleCount = 8;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_loadMore);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_loadMore)
      ..dispose();
    super.dispose();
  }

  void _loadMore() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 360) {
      return;
    }
    setState(() => _visibleCount += 8);
  }

  Future<void> _openFilters(
    List<TravelOffer> offers,
    HotelFilterOptions options,
  ) async {
    final next = await Navigator.of(context).push<HotelFilterState>(
      MaterialPageRoute(
        builder: (_) => HotelFilterScreen(initial: _filters, options: options),
      ),
    );
    if (!mounted || next == null) return;
    setState(() {
      _filters = next;
      _minimumRating = next.minimumRating;
      _visibleCount = 8;
    });
  }

  Future<void> _showSortSheet({
    required bool canSortByPrice,
    required bool hasRatings,
  }) async {
    final next = await showModalBottomSheet<_HotelSort>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final localization = AppLocalizations.of(context)!;
        return SafeArea(
          child: RadioGroup<_HotelSort>(
            groupValue: _sort,
            onChanged: (value) => Navigator.of(context).pop(value),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final option in _HotelSort.values)
                  if ((canSortByPrice ||
                          !{
                            _HotelSort.priceLowToHigh,
                            _HotelSort.priceHighToLow,
                          }.contains(option)) &&
                      (hasRatings || option != _HotelSort.rating))
                    RadioListTile<_HotelSort>(
                      value: option,
                      title: Text(_hotelSortLabel(localization, option)),
                    ),
              ],
            ),
          ),
        );
      },
    );
    if (next != null && mounted) setState(() => _sort = next);
  }

  Future<void> _showRatingShortcut() async {
    final next = await showModalBottomSheet<double?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                hotelFlowText(context, 'همه امتیازها', 'All ratings'),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            for (final rating in [3.0, 4.0, 4.5])
              ListTile(
                leading: const Icon(Icons.star_rounded, color: Colors.amber),
                title: Text('$rating+'),
                onTap: () => Navigator.of(context).pop(rating),
              ),
          ],
        ),
      ),
    );
    if (mounted) {
      setState(() {
        _minimumRating = next;
        _filters = _filters.copyWith(
          minimumRating: next,
          clearMinimumRating: next == null,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    return TravelPage(
      title: localization.travelHotelResults,
      child: Obx(() {
        final search = controller.lastHotelSearch.value;
        final offers = controller.hotelOffers.toList();
        final canSortByPrice = _canSortHotelOffersByPrice(offers);
        final hasRatings = offers.any((offer) => offer.rating > 0);
        final effectiveSort = canSortByPrice
            ? _sort
            : switch (_sort) {
                _HotelSort.priceLowToHigh ||
                _HotelSort.priceHighToLow => _HotelSort.recommended,
                _ => _sort,
              };
        final options = HotelFilterOptions.fromOffers(offers);
        final filteredOffers = applyHotelFilters(offers, _filters);
        final comparedOffers = _compareHotelOffers(
          filteredOffers,
          sort: effectiveSort,
          minimumRating: _minimumRating,
        );
        final visibleOffers = comparedOffers.take(_visibleCount).toList();
        return ListView(
          controller: _scrollController,
          padding: EdgeInsets.all(20.r),
          children: [
            if (search != null)
              _HotelSearchSummary(
                search: search,
                resultCount: comparedOffers.length,
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
              message: localization.travelHotelResultsGuidance,
            ),
            SizedBox(height: 16.h),
            if (_comparisonIds.isNotEmpty) ...[
              TravelCard(
                color: TravelTheme.purple.withValues(alpha: .08),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        localization.travelSelectedForComparison(
                          _comparisonIds.length,
                        ),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showHotelComparison(
                        context,
                        offers
                            .where((offer) => _comparisonIds.contains(offer.id))
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
            else if (offers.isEmpty)
              _HotelResultsEmptyState(
                hasError: controller.searchError.value != null,
                onEdit: Get.back,
                onRetry: search == null
                    ? null
                    : () => controller.searchHotels(search),
              )
            else ...[
              _HotelResultActions(
                sort: effectiveSort,
                activeFilters: _filters.isActive,
                onSort: () => _showSortSheet(
                  canSortByPrice: canSortByPrice,
                  hasRatings: hasRatings,
                ),
                onFilters: () => _openFilters(offers, options),
                onRating: hasRatings ? _showRatingShortcut : null,
                onDiscount: () => setState(
                  () => _filters = _filters.copyWith(
                    discountedOnly: !_filters.discountedOnly,
                  ),
                ),
                discountedOnly: _filters.discountedOnly,
                onReset: () => setState(() {
                  _sort = _HotelSort.recommended;
                  _minimumRating = null;
                  _filters = const HotelFilterState();
                }),
              ),
              SizedBox(height: 16.h),
              if (comparedOffers.isEmpty)
                _HotelFilteredEmptyState(
                  onReset: () => setState(() {
                    _sort = _HotelSort.recommended;
                    _minimumRating = null;
                    _filters = const HotelFilterState();
                  }),
                )
              else ...[
                ...visibleOffers.map(
                  (offer) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _HotelOfferCard(
                      offer: offer,
                      isLoading: controller.isOfferLoadingFor(offer),
                      isCompared: _comparisonIds.contains(offer.id),
                      onCompare: () => setState(() {
                        if (_comparisonIds.contains(offer.id)) {
                          _comparisonIds.remove(offer.id);
                        } else if (_comparisonIds.length < 3) {
                          _comparisonIds.add(offer.id);
                        } else {
                          showTravelMessage(
                            context,
                            title: localization.travelCompare,
                            message: localization.travelCompareLimit,
                          );
                        }
                      }),
                      onTap: () async {
                        if (await controller.loadOfferDetails(offer)) {
                          Get.to(() => const HotelDetailsScreen());
                        }
                      },
                    ),
                  ),
                ),
                if (visibleOffers.length < comparedOffers.length)
                  const Padding(
                    padding: EdgeInsets.all(18),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ],
          ],
        );
      }),
    );
  }
}

class _HotelResultActions extends StatelessWidget {
  final _HotelSort sort;
  final bool activeFilters;
  final bool discountedOnly;
  final VoidCallback onSort;
  final VoidCallback onFilters;
  final VoidCallback? onRating;
  final VoidCallback onDiscount;
  final VoidCallback onReset;

  const _HotelResultActions({
    required this.sort,
    required this.activeFilters,
    required this.discountedOnly,
    required this.onSort,
    required this.onFilters,
    required this.onRating,
    required this.onDiscount,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ActionChip(
                avatar: const Icon(Icons.sort_rounded, size: 18),
                label: Text(_hotelSortLabel(localization, sort)),
                onPressed: onSort,
              ),
              ActionChip(
                avatar: const Icon(Icons.tune_rounded, size: 18),
                label: Text(
                  activeFilters
                      ? hotelFlowText(
                          context,
                          'فیلترهای فعال',
                          'Active filters',
                        )
                      : hotelFlowText(context, 'همه فیلترها', 'All filters'),
                ),
                onPressed: onFilters,
              ),
              if (onRating != null)
                ActionChip(
                  avatar: const Icon(Icons.star_outline_rounded, size: 18),
                  label: Text(localization.travelRating),
                  onPressed: onRating,
                ),
              FilterChip(
                avatar: const Icon(Icons.local_offer_outlined, size: 18),
                label: Text(hotelFlowText(context, 'تخفیف‌دار', 'Discounted')),
                selected: discountedOnly,
                onSelected: (_) => onDiscount(),
              ),
            ],
          ),
          if (activeFilters || sort != _HotelSort.recommended)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: Text(localization.reset),
              ),
            ),
        ],
      ),
    );
  }
}

class _HotelFilteredEmptyState extends StatelessWidget {
  final VoidCallback onReset;

  const _HotelFilteredEmptyState({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Column(
      children: [
        TravelEmptyState(message: localization.travelNoHotelResults),
        SizedBox(height: 12.h),
        TextButton.icon(
          onPressed: onReset,
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(localization.reset),
        ),
      ],
    );
  }
}

String _hotelSortLabel(AppLocalizations localization, _HotelSort sort) {
  return switch (sort) {
    _HotelSort.recommended => localization.travelRecommended,
    _HotelSort.priceLowToHigh => localization.travelPriceLowToHigh,
    _HotelSort.priceHighToLow => localization.travelPriceHighToLow,
    _HotelSort.rating => localization.travelRatingHighToLow,
  };
}

bool _canSortHotelOffersByPrice(List<TravelOffer> offers) {
  final pricedOffers = offers.where((offer) => offer.total.amount > 0).toList();
  if (pricedOffers.length < 2) return false;
  final currencies = pricedOffers
      .map((offer) => offer.total.currency.trim().toUpperCase())
      .where((currency) => currency.isNotEmpty)
      .toSet();
  return currencies.length == 1 && pricedOffers.length == offers.length;
}

List<TravelOffer> _compareHotelOffers(
  List<TravelOffer> offers, {
  required _HotelSort sort,
  required double? minimumRating,
}) {
  final visibleOffers = offers
      .where((offer) => minimumRating == null || offer.rating >= minimumRating)
      .toList();
  switch (sort) {
    case _HotelSort.recommended:
      break;
    case _HotelSort.priceLowToHigh:
      visibleOffers.sort(
        (first, second) => first.total.amount.compareTo(second.total.amount),
      );
    case _HotelSort.priceHighToLow:
      visibleOffers.sort(
        (first, second) => second.total.amount.compareTo(first.total.amount),
      );
    case _HotelSort.rating:
      visibleOffers.sort(
        (first, second) => second.rating.compareTo(first.rating),
      );
  }
  return visibleOffers;
}

class _HotelOfferCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;
  final VoidCallback onCompare;
  final bool isLoading;
  final bool isCompared;

  const _HotelOfferCard({
    required this.offer,
    required this.onTap,
    required this.onCompare,
    this.isLoading = false,
    this.isCompared = false,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelCard(
      padding: EdgeInsets.zero,
      onTap: isLoading ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 145.h,
              width: double.infinity,
              child: offer.imageUrl.isNotEmpty
                  ? _HotelNetworkImage(url: offer.imageUrl)
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
                    IconButton(
                      tooltip: localization.travelCompare,
                      onPressed: onCompare,
                      icon: Icon(
                        isCompared
                            ? Icons.library_add_check_rounded
                            : Icons.library_add_outlined,
                        color: isCompared
                            ? TravelTheme.purple
                            : TravelTheme.muted,
                      ),
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
                        isLoading: isLoading,
                        onPressed: isLoading ? null : onTap,
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
    return TravelCard(
      padding: EdgeInsets.zero,
      onTap: isLoading ? null : onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 105.h,
              width: double.infinity,
              child: offer.imageUrl.isEmpty
                  ? const _HotelImageFallback()
                  : _HotelNetworkImage(url: offer.imageUrl),
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
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    travelLocalizedKey(localization, offer.subtitleKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          travelMoney(context, offer.total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: TravelTheme.purple,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (isLoading)
                        SizedBox(
                          width: 20.r,
                          height: 20.r,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: TravelTheme.purple,
                        ),
                    ],
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

Future<void> _showHotelComparison(
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
            TravelSectionHeader(title: localization.travelCompareHotels),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TravelBidiText(
                        travelLocalizedKey(localization, offer.titleKey),
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      SizedBox(height: 8.h),
                      _PolicyRow(
                        title: localization.travelStartingPrice,
                        value: travelMoney(context, offer.total),
                      ),
                      if (offer.rating > 0) ...[
                        const Divider(),
                        _PolicyRow(
                          title: localization.travelRating,
                          value: '★ ${offer.rating}',
                        ),
                      ],
                      if (offer.featureKeys.isNotEmpty) ...[
                        const Divider(),
                        _PolicyRow(
                          title: localization.travelIncluded,
                          value: offer.featureKeys
                              .map(
                                (value) =>
                                    travelLocalizedKey(localization, value),
                              )
                              .join(' • '),
                        ),
                      ],
                    ],
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

class _HotelSearchSummary extends StatelessWidget {
  final TravelHotelSearch search;
  final int resultCount;
  final int totalResultCount;
  final VoidCallback onEdit;

  const _HotelSearchSummary({
    required this.search,
    required this.resultCount,
    required this.totalResultCount,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final dates =
        '${MaterialLocalizations.of(context).formatCompactDate(search.checkInDate)}'
        ' – '
        '${MaterialLocalizations.of(context).formatCompactDate(search.checkOutDate)}';
    return TravelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: TravelTheme.purple),
              SizedBox(width: 8.w),
              Expanded(
                child: TravelBidiText(
                  search.city,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
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
          SizedBox(height: 8.h),
          Text(dates, style: TextStyle(color: TravelTheme.muted)),
          SizedBox(height: 6.h),
          Text(
            '${localization.travelGuests}: '
            '${search.roomCount} / ${search.adultCount} / ${search.childCount}',
            style: TextStyle(color: TravelTheme.muted),
          ),
          const Divider(height: 24),
          Text(
            '$resultCount / $totalResultCount '
            '${localization.travelHotelResults}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _HotelResultsEmptyState extends StatelessWidget {
  final bool hasError;
  final VoidCallback onEdit;
  final VoidCallback? onRetry;

  const _HotelResultsEmptyState({
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
              : localization.travelNoHotelResults,
        ),
        SizedBox(height: 16.h),
        if (hasError && onRetry != null)
          CommonButton(
            width: double.infinity,
            text: localization.noInternetConnectionRetryButton,
            backgroundColor: TravelTheme.purple,
            onPressed: onRetry,
          ),
        SizedBox(height: 10.h),
        TextButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(localization.travelSearchHotels),
        ),
      ],
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

class _HotelNetworkImage extends StatelessWidget {
  final String url;

  const _HotelNetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.cover,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      errorBuilder: (_, _, _) => const _HotelImageFallback(),
    );
  }
}

class HotelDetailsScreen extends StatefulWidget {
  const HotelDetailsScreen({super.key});

  @override
  State<HotelDetailsScreen> createState() => _HotelDetailsScreenState();
}

class _HotelDetailsScreenState extends State<HotelDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _roomsKey = GlobalKey();
  final GlobalKey _overviewKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _rulesKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final Map<String, int> _roomQuantities = {};
  bool _showAllAmenities = false;
  bool _showAllDescription = false;
  bool _showSectionNavigation = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_handleScroll)
      ..dispose();
    super.dispose();
  }

  void _handleScroll() {
    final next = _scrollController.hasClients && _scrollController.offset > 250;
    if (next != _showSectionNavigation) {
      setState(() => _showSectionNavigation = next);
    }
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: .08,
    );
  }

  Future<void> _changeDates(TravelController controller) async {
    final details = controller.hotelBookingDetails.value;
    final start =
        details.checkInDate ?? DateTime.now().add(const Duration(days: 30));
    final end = details.checkOutDate ?? start.add(const Duration(days: 2));
    final range = await showHotelDateRangePicker(
      context,
      initialStart: start,
      initialEnd: end,
    );
    if (!mounted || range == null) return;
    controller.hotelBookingDetails.value = details.copyWith(
      checkInDate: range.start,
      checkOutDate: range.end,
    );
    setState(() {});
  }

  List<TravelSelectedRoom> _selectedRooms(
    List<Map<String, dynamic>> rooms,
    String fallbackCurrency,
  ) {
    return rooms
        .map((room) {
          final id = room['room_id']?.toString() ?? '';
          final quantity = _roomQuantities[id] ?? 0;
          if (id.isEmpty || quantity <= 0) return null;
          return TravelSelectedRoom(
            id: id,
            name: travelBackendText(context, room['room_name'] ?? room['name']),
            quantity: quantity,
            unitPrice: double.tryParse(room['price']?.toString() ?? '') ?? 0,
            currency: room['currency']?.toString() ?? fallbackCurrency,
          );
        })
        .whereType<TravelSelectedRoom>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();
    final offer = controller.selectedOffer.value;
    if (offer == null) {
      return TravelPage(
        title: localization.travelHotelDetails,
        child: TravelEmptyState(message: localization.travelOfferUnavailable),
      );
    }
    final product = offer.product;
    final attributes = offer.attributes;
    final description = product['description']?.toString().trim() ?? '';
    final amenities = _providerStrings(product['amenities']);
    final images = _providerImages(product['images']);
    final rooms = _providerMaps(product['rooms']);
    final reviews = _providerMap(product['reviews']);
    final address = attributes['address']?.toString().trim() ?? '';
    final latitude = attributes['latitude'];
    final longitude = attributes['longitude'];
    final hasCoordinates = latitude != null && longitude != null;
    final sourceUpdatedAt =
        product['source_updated_at']?.toString().trim() ?? '';
    final bookingDetails = controller.hotelBookingDetails.value;
    final nights =
        bookingDetails.checkInDate != null &&
            bookingDetails.checkOutDate != null
        ? bookingDetails.checkOutDate!
              .difference(bookingDetails.checkInDate!)
              .inDays
              .clamp(1, 365)
              .toInt()
        : 1;
    final selectedRooms = _selectedRooms(rooms, offer.total.currency);
    final selectedRoomCount = selectedRooms.fold(
      0,
      (total, room) => total + room.quantity,
    );
    final selectedTotal = selectedRooms.fold<double>(
      0,
      (total, room) => total + (room.unitPrice * room.quantity * nights),
    );
    final selectedCurrency = selectedRooms.firstOrNull?.currency;
    final currencies = selectedRooms.map((room) => room.currency).toSet();
    final canCheckout =
        selectedRooms.isNotEmpty &&
        currencies.length == 1 &&
        selectedRooms.every((room) => room.unitPrice > 0) &&
        controller.canPurchase(TravelProductType.hotel);
    return TravelPage(
      title: localization.travelHotelDetails,
      bottomNavigationBar: selectedRooms.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: EdgeInsets.all(14.r),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Color(0x18000000), blurRadius: 18),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotelFlowText(
                              context,
                              '$selectedRoomCount اتاق برای $nights شب',
                              '$selectedRoomCount rooms for $nights nights',
                            ),
                            style: TextStyle(
                              color: TravelTheme.muted,
                              fontSize: 10.sp,
                            ),
                          ),
                          Text(
                            travelMoney(
                              context,
                              TravelMoney(
                                amount: selectedTotal,
                                currency:
                                    selectedCurrency ?? offer.total.currency,
                              ),
                            ),
                            style: const TextStyle(
                              color: TravelTheme.purple,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 150.w,
                      child: CommonButton(
                        width: double.infinity,
                        text: hotelFlowText(
                          context,
                          'ادامه رزرو',
                          'Continue booking',
                        ),
                        backgroundColor: TravelTheme.purple,
                        onPressed: canCheckout
                            ? () {
                                final first = selectedRooms.first;
                                Get.to(
                                  () => TravelCheckoutScreen(
                                    type: TravelProductType.hotel,
                                    productId: offer.id,
                                    title: travelLocalizedKey(
                                      localization,
                                      offer.titleKey,
                                    ),
                                    total: TravelMoney(
                                      amount: selectedTotal,
                                      currency: first.currency,
                                    ),
                                    bookingDetails: bookingDetails.copyWith(
                                      roomId: first.id,
                                      roomName: first.name,
                                      roomCount: selectedRoomCount,
                                      selectedRooms: selectedRooms,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      child: Stack(
        children: [
          ListView(
            controller: _scrollController,
            padding: EdgeInsets.all(20.r),
            children: [
              _HotelGallery(images: images, fallbackImageUrl: offer.imageUrl),
              if (_showSectionNavigation) ...[
                SizedBox(height: 12.h),
                SizedBox(
                  height: 42.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _SectionChip(
                        label: hotelFlowText(context, 'معرفی', 'Overview'),
                        onTap: () => _scrollTo(_overviewKey),
                      ),
                      _SectionChip(
                        label: hotelFlowText(context, 'امکانات', 'Features'),
                        onTap: () => _scrollTo(_featuresKey),
                      ),
                      _SectionChip(
                        label: hotelFlowText(context, 'اتاق‌ها', 'Rooms'),
                        onTap: () => _scrollTo(_roomsKey),
                      ),
                      _SectionChip(
                        label: hotelFlowText(context, 'قوانین', 'Rules'),
                        onTap: () => _scrollTo(_rulesKey),
                      ),
                      _SectionChip(
                        label: hotelFlowText(context, 'نظرات', 'Reviews'),
                        onTap: () => _scrollTo(_reviewsKey),
                      ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 18.h),
              SizedBox(key: _overviewKey),
              TravelBidiText(
                travelLocalizedKey(localization, offer.titleKey),
                style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w900),
              ),
              SizedBox(height: 6.h),
              TravelBidiText(
                travelLocalizedKey(localization, offer.subtitleKey),
                style: TextStyle(color: TravelTheme.muted, fontSize: 12.sp),
              ),
              if (address.isNotEmpty) ...[
                SizedBox(height: 10.h),
                TravelCard(
                  onTap: hasCoordinates
                      ? () async {
                          await Clipboard.setData(
                            ClipboardData(text: '$latitude,$longitude'),
                          );
                          if (!context.mounted) return;
                          showTravelMessage(
                            context,
                            title: localization.travelHotelDetails,
                            message: '$latitude, $longitude',
                          );
                        }
                      : null,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: TravelTheme.purple,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(child: TravelBidiText(address)),
                      if (hasCoordinates)
                        const Icon(
                          Icons.map_outlined,
                          color: TravelTheme.purple,
                        ),
                    ],
                  ),
                ),
              ],
              SizedBox(height: 20.h),
              _ProviderMoneySummary(offer: offer),
              SizedBox(height: 18.h),
              TravelJourneyGuide(
                currentStep: 2,
                steps: [
                  localization.travelJourneySearch,
                  localization.travelJourneyCompare,
                  localization.travelJourneyReview,
                  localization.travelJourneyPay,
                ],
                message: localization.travelHotelDetailsGuidance,
              ),
              if (description.isNotEmpty) ...[
                SizedBox(height: 26.h),
                TravelSectionHeader(title: localization.travelAboutHotel),
                SizedBox(height: 8.h),
                TravelBidiText(
                  description,
                  maxLines: _showAllDescription ? null : 5,
                  overflow: _showAllDescription
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 13.sp, height: 1.8),
                ),
                TextButton(
                  onPressed: () => setState(
                    () => _showAllDescription = !_showAllDescription,
                  ),
                  child: Text(
                    _showAllDescription
                        ? hotelFlowText(context, 'نمایش کمتر', 'Show less')
                        : hotelFlowText(context, 'نمایش بیشتر', 'Show more'),
                  ),
                ),
              ],
              if (amenities.isNotEmpty) ...[
                SizedBox(height: 24.h),
                SizedBox(key: _featuresKey),
                TravelSectionHeader(title: localization.travelIncluded),
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (_showAllAmenities ? amenities : amenities.take(8))
                      .map((item) => Chip(label: Text(item)))
                      .toList(),
                ),
                if (amenities.length > 8)
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _showAllAmenities = !_showAllAmenities),
                    icon: Icon(
                      _showAllAmenities
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                    ),
                    label: Text(
                      _showAllAmenities
                          ? hotelFlowText(context, 'نمایش کمتر', 'Show less')
                          : hotelFlowText(
                              context,
                              'نمایش همه امکانات',
                              'Show more',
                            ),
                    ),
                  ),
              ],
              if (rooms.isNotEmpty) ...[
                SizedBox(height: 24.h),
                SizedBox(key: _roomsKey),
                Row(
                  children: [
                    Expanded(
                      child: TravelSectionHeader(
                        title: hotelFlowText(
                          context,
                          'اتاق‌های موجود',
                          'Available rooms',
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _changeDates(controller),
                      icon: const Icon(Icons.edit_calendar_outlined),
                      label: Text(
                        hotelFlowText(context, 'تغییر تاریخ', 'Edit dates'),
                      ),
                    ),
                  ],
                ),
                TravelCard(
                  color: TravelTheme.purple.withValues(alpha: .07),
                  onTap: () => _changeDates(controller),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.date_range_rounded,
                        color: TravelTheme.purple,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          '${MaterialLocalizations.of(context).formatCompactDate(bookingDetails.checkInDate!)}'
                          ' – '
                          '${MaterialLocalizations.of(context).formatCompactDate(bookingDetails.checkOutDate!)}'
                          ' • $nights ${hotelFlowText(context, 'شب', 'nights')}',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                ...rooms.map(
                  (room) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _ProviderRoomCard(
                      room: room,
                      enabled: controller.canPurchase(TravelProductType.hotel),
                      nights: nights,
                      quantity:
                          _roomQuantities[room['room_id']?.toString() ?? ''] ??
                          0,
                      onQuantityChanged: (quantity) => setState(() {
                        final id = room['room_id']?.toString() ?? '';
                        if (id.isNotEmpty) _roomQuantities[id] = quantity;
                      }),
                    ),
                  ),
                ),
              ],
              if (reviews.isNotEmpty) ...[
                SizedBox(height: 24.h),
                SizedBox(key: _reviewsKey),
                TravelSectionHeader(
                  title: hotelFlowText(
                    context,
                    'امتیاز و نظر کاربران',
                    'Guest ratings and reviews',
                  ),
                ),
                SizedBox(height: 10.h),
                _ExpandableProviderMapCard(values: reviews),
              ],
              if (attributes.isNotEmpty) ...[
                SizedBox(height: 24.h),
                TravelSectionHeader(title: localization.travelHotelDetails),
                SizedBox(height: 10.h),
                _ProviderMapCard(
                  values: Map<String, dynamic>.from(attributes)
                    ..remove('address')
                    ..remove('latitude')
                    ..remove('longitude'),
                ),
              ],
              if (offer.policies.isNotEmpty) ...[
                SizedBox(height: 24.h),
                SizedBox(key: _rulesKey),
                TravelSectionHeader(title: localization.travelPolicies),
                SizedBox(height: 10.h),
                _ProviderMapCard(values: offer.policies),
              ],
              if (controller.hotelOffers.any(
                (item) => item.id != offer.id,
              )) ...[
                SizedBox(height: 26.h),
                TravelSectionHeader(
                  title: hotelFlowText(
                    context,
                    'هتل‌های مشابه',
                    'Similar hotels',
                  ),
                ),
                SizedBox(height: 10.h),
                SizedBox(
                  height: 300.h,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.hotelOffers
                        .where((item) => item.id != offer.id)
                        .take(6)
                        .length,
                    separatorBuilder: (_, _) => SizedBox(width: 12.w),
                    itemBuilder: (context, index) {
                      final similar = controller.hotelOffers
                          .where((item) => item.id != offer.id)
                          .elementAt(index);
                      return SizedBox(
                        width: 260.w,
                        child: _HotelRailCard(
                          offer: similar,
                          isLoading: controller.isOfferLoadingFor(similar),
                          onTap: () async {
                            if (await controller.loadOfferDetails(similar)) {
                              Get.off(() => const HotelDetailsScreen());
                            }
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (sourceUpdatedAt.isNotEmpty) ...[
                SizedBox(height: 14.h),
                Text(
                  sourceUpdatedAt,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
                ),
              ],
            ],
          ),
          if (_showSectionNavigation)
            PositionedDirectional(
              end: 12.w,
              bottom: 18.h,
              child: FloatingActionButton.extended(
                heroTag: 'hotel-rooms-jump',
                onPressed: () => _scrollTo(_roomsKey),
                backgroundColor: TravelTheme.purple,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.bed_rounded),
                label: Text(hotelFlowText(context, 'اتاق‌ها', 'Rooms')),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SectionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(end: 8.w),
      child: ActionChip(label: Text(label), onPressed: onTap),
    );
  }
}

class _HotelGallery extends StatelessWidget {
  final List<String> images;
  final String fallbackImageUrl;

  const _HotelGallery({required this.images, required this.fallbackImageUrl});

  @override
  Widget build(BuildContext context) {
    final gallery = [
      if (fallbackImageUrl.isNotEmpty) fallbackImageUrl,
      ...images.where((image) => image != fallbackImageUrl),
    ];
    if (gallery.isEmpty) {
      return ClipRRect(
        borderRadius: TravelTheme.radius,
        child: SizedBox(height: 230.h, child: const _HotelImageFallback()),
      );
    }
    return SizedBox(
      height: 230.h,
      child: PageView.builder(
        itemCount: gallery.length,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsetsDirectional.only(
            end: index == gallery.length - 1 ? 0.0 : 8.w,
          ),
          child: ClipRRect(
            borderRadius: TravelTheme.radius,
            child: _HotelNetworkImage(url: gallery[index]),
          ),
        ),
      ),
    );
  }
}

class _ProviderMoneySummary extends StatelessWidget {
  final TravelOffer offer;

  const _ProviderMoneySummary({required this.offer});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final maximum =
        double.tryParse(offer.attributes['price_max']?.toString() ?? '') ?? 0;
    return TravelCard(
      child: Column(
        children: [
          _PolicyRow(
            title: localization.travelStartingPrice,
            value: travelMoney(context, offer.total),
          ),
          if (maximum > 0) ...[
            const Divider(),
            _PolicyRow(
              title: localization.travelTotal,
              value: travelMoney(
                context,
                TravelMoney(amount: maximum, currency: offer.total.currency),
              ),
            ),
          ],
          ...offer.pricingComponents.map(
            (component) => Column(
              children: [
                const Divider(),
                _PolicyRow(
                  title:
                      component['label']?.toString() ??
                      localization.travelPriceSummary,
                  value: travelMoney(
                    context,
                    TravelMoney(
                      amount:
                          double.tryParse(
                            component['amount']?.toString() ?? '',
                          ) ??
                          0,
                      currency:
                          component['currency']?.toString() ??
                          offer.total.currency,
                    ),
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

class _ProviderRoomCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final bool enabled;
  final int nights;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  const _ProviderRoomCard({
    required this.room,
    required this.enabled,
    required this.nights,
    required this.quantity,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrls = _providerImages(room['images']);
    final values = Map<String, dynamic>.from(room)
      ..remove('images')
      ..remove('room_name')
      ..remove('price')
      ..remove('currency')
      ..remove('description');
    final description = travelBackendText(context, room['description']);
    final cancellationSummary = _providerCancellationSummary(context, room);
    final price = double.tryParse(room['price']?.toString() ?? '') ?? 0;
    final currency = room['currency']?.toString() ?? 'IRR';
    return TravelCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrls.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: SizedBox(
                height: 150.h,
                width: double.infinity,
                child: _HotelNetworkImage(url: imageUrls.first),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelBidiText(
                  travelBackendText(context, room['room_name'] ?? room['name']),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  TravelBidiText(description),
                ],
                if (price > 0) ...[
                  SizedBox(height: 10.h),
                  Text(
                    travelMoney(
                      context,
                      TravelMoney(
                        amount: price * nights * (quantity == 0 ? 1 : quantity),
                        currency: currency,
                      ),
                    ),
                    style: const TextStyle(
                      color: TravelTheme.purple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    quantity == 0
                        ? hotelFlowText(
                            context,
                            'قیمت برای $nights شب و یک اتاق',
                            'Price for $nights nights and one room',
                          )
                        : hotelFlowText(
                            context,
                            '$quantity اتاق × $nights شب',
                            '$quantity rooms × $nights nights',
                          ),
                    style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
                  ),
                ],
                if (cancellationSummary.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _ProviderPolicyNotice(
                    title: AppLocalizations.of(
                      context,
                    )!.travelCancellationPolicy,
                    value: cancellationSummary,
                  ),
                ],
                if (values.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _ProviderMapRows(
                    values: Map<String, dynamic>.fromEntries(
                      values.entries.take(4),
                    ),
                  ),
                ],
                SizedBox(height: 14.h),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: () => Get.to(
                        () => _RoomDetailsScreen(room: room, nights: nights),
                      ),
                      icon: const Icon(Icons.info_outline_rounded),
                      label: Text(
                        hotelFlowText(context, 'جزئیات و قوانین', 'Details'),
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: enabled && quantity > 0
                          ? () => onQuantityChanged(quantity - 1)
                          : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded),
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    IconButton(
                      onPressed: enabled && price > 0 && quantity < 20
                          ? () => onQuantityChanged(quantity + 1)
                          : null,
                      icon: const Icon(Icons.add_circle_rounded),
                      color: TravelTheme.purple,
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

class _RoomDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> room;
  final int nights;

  const _RoomDetailsScreen({required this.room, required this.nights});

  @override
  Widget build(BuildContext context) {
    final values = Map<String, dynamic>.from(room)
      ..remove('images')
      ..remove('room_name')
      ..remove('name')
      ..remove('price')
      ..remove('currency')
      ..remove('description');
    final price = double.tryParse(room['price']?.toString() ?? '') ?? 0;
    final currency = room['currency']?.toString() ?? 'IRR';
    final cancellation = _providerCancellationSummary(context, room);
    return TravelPage(
      title: hotelFlowText(context, 'جزئیات اتاق', 'Room details'),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          TravelBidiText(
            travelBackendText(context, room['room_name'] ?? room['name']),
            style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w900),
          ),
          SizedBox(height: 14.h),
          if (travelBackendText(context, room['description']).isNotEmpty)
            TravelCard(
              child: TravelBidiText(
                travelBackendText(context, room['description']),
              ),
            ),
          if (price > 0) ...[
            SizedBox(height: 12.h),
            TravelCard(
              child: _PolicyRow(
                title: hotelFlowText(
                  context,
                  'قیمت یک اتاق برای $nights شب',
                  'One room for $nights nights',
                ),
                value: travelMoney(
                  context,
                  TravelMoney(amount: price * nights, currency: currency),
                ),
              ),
            ),
          ],
          if (cancellation.isNotEmpty) ...[
            SizedBox(height: 12.h),
            _ProviderPolicyNotice(
              title: AppLocalizations.of(context)!.travelCancellationPolicy,
              value: cancellation,
            ),
          ],
          if (values.isNotEmpty) ...[
            SizedBox(height: 20.h),
            TravelSectionHeader(
              title: hotelFlowText(context, 'اطلاعات اتاق', 'Room information'),
            ),
            SizedBox(height: 10.h),
            _ProviderMapCard(values: values),
          ],
        ],
      ),
    );
  }
}

class _ExpandableProviderMapCard extends StatefulWidget {
  final Map<String, dynamic> values;

  const _ExpandableProviderMapCard({required this.values});

  @override
  State<_ExpandableProviderMapCard> createState() =>
      _ExpandableProviderMapCardState();
}

class _ExpandableProviderMapCardState
    extends State<_ExpandableProviderMapCard> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    final entries = widget.values.entries.toList();
    final visible = expanded ? entries : entries.take(5);
    return Column(
      children: [
        _ProviderMapCard(values: Map<String, dynamic>.fromEntries(visible)),
        if (entries.length > 5)
          TextButton.icon(
            onPressed: () => setState(() => expanded = !expanded),
            icon: Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
            ),
            label: Text(
              expanded
                  ? hotelFlowText(context, 'نمایش کمتر', 'Show less')
                  : hotelFlowText(context, 'نمایش بیشتر', 'Show more'),
            ),
          ),
      ],
    );
  }
}

class _ProviderPolicyNotice extends StatelessWidget {
  final String title;
  final String value;

  const _ProviderPolicyNotice({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: TravelTheme.purple.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: TravelTheme.purple.withValues(alpha: .18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.policy_outlined, color: TravelTheme.purple),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                SizedBox(height: 4.h),
                TravelBidiText(
                  value,
                  style: TextStyle(color: TravelTheme.muted, fontSize: 11.sp),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProviderMapCard extends StatelessWidget {
  final Map<String, dynamic> values;

  const _ProviderMapCard({required this.values});

  @override
  Widget build(BuildContext context) {
    return TravelCard(child: _ProviderMapRows(values: values));
  }
}

class _ProviderMapRows extends StatelessWidget {
  final Map<String, dynamic> values;

  const _ProviderMapRows({required this.values});

  @override
  Widget build(BuildContext context) {
    final entries = values.entries
        .where((entry) => travelBackendValue(context, entry.value).isNotEmpty)
        .toList();
    final localization = AppLocalizations.of(context)!;
    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          _PolicyRow(
            title: travelBackendFieldLabel(localization, entries[index].key),
            value: travelBackendValue(context, entries[index].value),
          ),
          if (index != entries.length - 1) const Divider(),
        ],
      ],
    );
  }
}

Map<String, dynamic> _providerMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return const {};
}

List<Map<String, dynamic>> _providerMaps(dynamic value) {
  if (value is! List) return const [];
  return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
}

List<String> _providerStrings(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

List<String> _providerImages(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) {
        if (item is Map) return item['url']?.toString() ?? '';
        return item?.toString() ?? '';
      })
      .where((item) => item.isNotEmpty)
      .toList();
}

String _providerCancellationSummary(
  BuildContext context,
  Map<String, dynamic> source,
) {
  const keys = [
    'cancellation_policy',
    'cancellation',
    'cancellation_rules',
    'refund_policy',
    'refundability',
    'policies',
  ];
  for (final key in keys) {
    final value = travelBackendValue(context, source[key]).trim();
    if (value.isNotEmpty) return value;
  }
  if (source['refundable'] is bool) {
    return travelBackendValue(context, source['refundable']);
  }
  return '';
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
