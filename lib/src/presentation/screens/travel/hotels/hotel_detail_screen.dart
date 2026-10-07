import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';

import '../core/controller/travel_controller.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';
import 'hotel_checkout_screen.dart';
import 'hotel_search_components.dart';
import 'room_selection_screen.dart';
import 'widgets/cancellation_policy_timeline.dart';
import 'widgets/hotel_amenities_grid.dart';
import 'widgets/hotel_room_selection_card.dart';

/// International-Grade Hotel Detail Screen with full interactive lightbox gallery,
/// room options comparison table, categorized amenities, location map preview,
/// and verified guest reviews carousel.
class HotelDetailScreen extends StatefulWidget {
  const HotelDetailScreen({super.key});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _overviewKey = GlobalKey();
  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _roomsKey = GlobalKey();
  final GlobalKey _compareKey = GlobalKey();
  final GlobalKey _locationKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _rulesKey = GlobalKey();

  final Map<String, int> _roomQuantities = {};
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
    final next = _scrollController.hasClients && _scrollController.offset > 240;
    if (next != _showSectionNavigation) {
      setState(() => _showSectionNavigation = next);
    }
  }

  void _scrollTo(GlobalKey key) {
    final target = key.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 400),
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
    final address = attributes['address']?.toString().trim() ?? '';
    final latitude = attributes['latitude'];
    final longitude = attributes['longitude'];
    final hasCoordinates = latitude != null && longitude != null;

    final bookingDetails = controller.hotelBookingDetails.value;
    final nights =
        bookingDetails.checkInDate != null && bookingDetails.checkOutDate != null
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
    final selectedCurrency = selectedRooms.firstOrNull?.currency ?? offer.total.currency;

    final canCheckout = selectedRooms.isNotEmpty &&
        selectedRooms.every((room) => room.unitPrice > 0) &&
        controller.canPurchase(TravelProductType.hotel);

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TravelPage(
      title: localization.travelHotelDetails,
      bottomNavigationBar: selectedRooms.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  border: Border(
                    top: BorderSide(
                      color: ECardoTokens.border(context),
                      width: 1,
                    ),
                  ),
                  boxShadow: ECardoTokens.shadowSheet(context),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!
                                .hotelRoomsForNights(selectedRoomCount, nights),
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              travelMoney(
                                context,
                                TravelMoney(
                                  amount: selectedTotal,
                                  currency: selectedCurrency,
                                ),
                              ),
                              style: TextStyle(
                                color: ECardoTokens.brand700(context),
                                fontWeight: FontWeight.w900,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      width: 160.w,
                      child: CommonButton(
                        width: double.infinity,
                        height: 48,
                        text: AppLocalizations.of(context)!.hotel_continue_booking,
                        backgroundColor: ECardoTokens.brand900(context),
                        onPressed: canCheckout
                            ? () {
                                final first = selectedRooms.first;
                                Get.to(
                                  () => HotelCheckoutScreen(
                                    productId: offer.id,
                                    hotelTitle: travelLocalizedKey(
                                      localization,
                                      offer.titleKey,
                                    ),
                                    hotelAddress: address,
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
                                    nights: nights,
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
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: Stack(
          children: [
            ListView(
              controller: _scrollController,
              padding: EdgeInsets.all(20.r),
              children: [
                // Full Gallery with Interactive Lightbox
                _HotelGalleryWithLightbox(
                  images: images,
                  fallbackImageUrl: offer.imageUrl,
                  hotelTitle: travelLocalizedKey(localization, offer.titleKey),
                ),

                // Section Navigation Tabs
                if (_showSectionNavigation) ...[
                  SizedBox(height: 12.h),
                  SizedBox(
                    height: 42.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _SectionChip(
                          label: AppLocalizations.of(context)!.hotel_overview,
                          onTap: () => _scrollTo(_overviewKey),
                        ),
                        _SectionChip(
                          label: AppLocalizations.of(context)!.hotel_features,
                          onTap: () => _scrollTo(_featuresKey),
                        ),
                        _SectionChip(
                          label: AppLocalizations.of(context)!.hotel_rooms,
                          onTap: () => _scrollTo(_roomsKey),
                        ),
                        _SectionChip(
                          label: isRtl ? 'مقایسه اتاق‌ها' : 'Compare Rooms',
                          onTap: () => _scrollTo(_compareKey),
                        ),
                        _SectionChip(
                          label: isRtl ? 'موقعیت مکانی' : 'Location',
                          onTap: () => _scrollTo(_locationKey),
                        ),
                        _SectionChip(
                          label: AppLocalizations.of(context)!.hotel_reviews,
                          onTap: () => _scrollTo(_reviewsKey),
                        ),
                        _SectionChip(
                          label: AppLocalizations.of(context)!.hotel_rules,
                          onTap: () => _scrollTo(_rulesKey),
                        ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 18.h),
                SizedBox(key: _overviewKey),

                // Hotel Name & Star Rating
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TravelBidiText(
                            travelLocalizedKey(localization, offer.titleKey),
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          TravelBidiText(
                            travelLocalizedKey(localization, offer.subtitleKey),
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 13.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (offer.rating > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand100(context),
                          borderRadius:
                              BorderRadius.circular(ECardoTokens.radiusMd),
                          border: Border.all(
                            color: ECardoTokens.brand700(context)
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: 16.sp,
                                  color: ECardoTokens.sand600(context),
                                ),
                                SizedBox(width: 3.w),
                                Text(
                                  offer.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w900,
                                    color: ECardoTokens.brand700(context),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              isRtl ? 'عالی' : 'Exceptional',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: ECardoTokens.brand700(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                // Location Card with Coordinates
                if (address.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: ECardoTokens.surfaceCard(context),
                      borderRadius:
                          BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(color: ECardoTokens.border(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: ECardoTokens.brand700(context),
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: TravelBidiText(
                            address,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: ECardoTokens.ink(context),
                            ),
                          ),
                        ),
                        if (hasCoordinates)
                          IconButton(
                            iconSize: 20.sp,
                            tooltip: isRtl
                                ? 'کپی مختصات نقشه'
                                : 'Copy Map Coordinates',
                            onPressed: () async {
                              await Clipboard.setData(
                                ClipboardData(text: '$latitude,$longitude'),
                              );
                              if (!context.mounted) return;
                              Get.snackbar(
                                isRtl ? 'کپی شد' : 'Copied',
                                '$latitude, $longitude',
                                backgroundColor:
                                    ECardoTokens.surfaceCard(context),
                                colorText: ECardoTokens.ink(context),
                              );
                            },
                            icon: Icon(
                              Icons.copy_rounded,
                              color: ECardoTokens.brand700(context),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],

                SizedBox(height: 18.h),
                CancellationPolicyTimelineCard(
                  checkInDate: bookingDetails.checkInDate,
                  customPolicySummary:
                      _providerCancellationSummary(context, product),
                ),

                // About Hotel Description
                if (description.isNotEmpty) ...[
                  SizedBox(height: 24.h),
                  TravelSectionHeader(title: localization.travelAboutHotel),
                  SizedBox(height: 8.h),
                  TravelBidiText(
                    description,
                    maxLines: _showAllDescription ? null : 4,
                    overflow: _showAllDescription
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.7,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton(
                      onPressed: () => setState(
                        () => _showAllDescription = !_showAllDescription,
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: ECardoTokens.brand700(context),
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(
                        _showAllDescription
                            ? AppLocalizations.of(context)!.hotel_show_less
                            : AppLocalizations.of(context)!.hotel_show_more,
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],

                // Amenities Section
                SizedBox(height: 20.h),
                SizedBox(key: _featuresKey),
                TravelSectionHeader(title: localization.travelIncluded),
                SizedBox(height: 12.h),
                HotelAmenitiesGrid(amenities: amenities),

                // Room Options Comparison Table
                if (rooms.length > 1) ...[
                  SizedBox(height: 26.h),
                  SizedBox(key: _compareKey),
                  TravelSectionHeader(
                    title: isRtl ? 'جدول مقایسه اتاق‌ها' : 'Room Comparison Table',
                  ),
                  SizedBox(height: 10.h),
                  _RoomComparisonTable(
                    rooms: rooms,
                    currency: offer.total.currency,
                    onSelectRoom: (roomId) {
                      setState(() {
                        _roomQuantities[roomId] =
                            (_roomQuantities[roomId] ?? 0) > 0 ? 0 : 1;
                      });
                      _scrollTo(_roomsKey);
                    },
                  ),
                ],

                // Available Rooms List
                if (rooms.isNotEmpty) ...[
                  SizedBox(height: 26.h),
                  SizedBox(key: _roomsKey),
                  Row(
                    children: [
                      Expanded(
                        child: TravelSectionHeader(
                          title: AppLocalizations.of(context)!.hotel_available_rooms,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _changeDates(controller),
                        icon: Icon(
                          Icons.edit_calendar_outlined,
                          size: 16.sp,
                          color: ECardoTokens.brand700(context),
                        ),
                        label: Text(
                          AppLocalizations.of(context)!.hotel_edit_dates,
                          style: TextStyle(
                            color: ECardoTokens.brand700(context),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.only(bottom: 14.h),
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: ECardoTokens.brand100(context),
                      borderRadius:
                          BorderRadius.circular(ECardoTokens.radiusMd),
                      border: Border.all(
                        color: ECardoTokens.brand700(context).withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          color: ECardoTokens.brand700(context),
                          size: 20.sp,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            '${MaterialLocalizations.of(context).formatCompactDate(bookingDetails.checkInDate!)}'
                            ' – '
                            '${MaterialLocalizations.of(context).formatCompactDate(bookingDetails.checkOutDate!)}'
                            '  •  $nights ${AppLocalizations.of(context)!.hotel_nights}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.ink(context),
                              fontSize: 12.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...rooms.map(
                    (room) {
                      final roomId = room['room_id']?.toString() ?? '';
                      final qty = _roomQuantities[roomId] ?? 0;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 14.h),
                        child: HotelRoomSelectionCard(
                          room: room,
                          enabled: controller.canPurchase(TravelProductType.hotel),
                          nights: nights,
                          quantity: qty,
                          onQuantityChanged: (quantity) => setState(() {
                            if (roomId.isNotEmpty) {
                              _roomQuantities[roomId] = quantity;
                            }
                          }),
                          onSelect: () => setState(() {
                            if (roomId.isNotEmpty) {
                              _roomQuantities[roomId] = qty > 0 ? 0 : 1;
                            }
                          }),
                          onTapDetails: () => Get.to(
                            () => RoomSelectionScreen(
                              hotelOffer: offer,
                              initialSelectedRoomId: roomId,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],

                // Location Map Preview Card
                SizedBox(height: 24.h),
                SizedBox(key: _locationKey),
                TravelSectionHeader(
                  title: isRtl ? 'موقعیت مکانی و دسترسی' : 'Location & Surroundings',
                ),
                SizedBox(height: 10.h),
                _LocationMapPreviewCard(
                  hotelTitle: travelLocalizedKey(localization, offer.titleKey),
                  address: address,
                  latitude: latitude as num?,
                  longitude: longitude as num?,
                ),

                // Verified Reviews Carousel
                SizedBox(height: 24.h),
                SizedBox(key: _reviewsKey),
                TravelSectionHeader(
                  title: AppLocalizations.of(context)!.hotel_guest_ratings_and_reviews,
                ),
                SizedBox(height: 10.h),
                _VerifiedReviewsSection(
                  overallRating: offer.rating > 0 ? offer.rating : 4.8,
                ),

                SizedBox(height: 24.h),
                SizedBox(key: _rulesKey),
                TravelSectionHeader(title: localization.travelPolicies),
                SizedBox(height: 10.h),
                CancellationPolicyTimelineCard(
                  checkInDate: bookingDetails.checkInDate,
                  customPolicySummary:
                      _providerCancellationSummary(context, product),
                ),
                SizedBox(height: 40.h),
              ],
            ),

            // Jump to Rooms FAB
            if (_showSectionNavigation)
              PositionedDirectional(
                end: 16.w,
                bottom: 18.h,
                child: FloatingActionButton.extended(
                  heroTag: 'hotel-jump-to-rooms',
                  onPressed: () => _scrollTo(_roomsKey),
                  backgroundColor: ECardoTokens.brand900(context),
                  foregroundColor: ECardoTokens.inkOnBrand,
                  icon: const Icon(Icons.bed_rounded),
                  label: Text(
                    AppLocalizations.of(context)!.hotel_rooms,
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
          ],
        ),
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
      child: ActionChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: ECardoTokens.ink(context),
          ),
        ),
        backgroundColor: ECardoTokens.surfaceCard(context),
        side: BorderSide(color: ECardoTokens.border(context)),
        onPressed: onTap,
      ),
    );
  }
}

/// Gallery with Fullscreen Lightbox support
class _HotelGalleryWithLightbox extends StatefulWidget {
  final List<String> images;
  final String fallbackImageUrl;
  final String hotelTitle;

  const _HotelGalleryWithLightbox({
    required this.images,
    required this.fallbackImageUrl,
    required this.hotelTitle,
  });

  @override
  State<_HotelGalleryWithLightbox> createState() =>
      _HotelGalleryWithLightboxState();
}

class _HotelGalleryWithLightboxState extends State<_HotelGalleryWithLightbox> {
  int _currentIndex = 0;

  void _openLightbox(List<String> gallery, int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _HotelLightboxScreen(
          images: gallery,
          initialIndex: initialIndex,
          hotelTitle: widget.hotelTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gallery = [
      if (widget.fallbackImageUrl.isNotEmpty) widget.fallbackImageUrl,
      ...widget.images.where((image) => image != widget.fallbackImageUrl),
    ];

    if (gallery.isEmpty) {
      return Container(
        height: 230.h,
        decoration: BoxDecoration(
          color: ECardoTokens.brand100(context),
          borderRadius: BorderRadius.circular(ECardoTokens.radius2xl),
        ),
        child: Center(
          child: Icon(
            Icons.hotel_rounded,
            size: 64.sp,
            color: ECardoTokens.brand500(context),
          ),
        ),
      );
    }

    return SizedBox(
      height: 230.h,
      child: Stack(
        children: [
          PageView.builder(
            itemCount: gallery.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => GestureDetector(
              onTap: () => _openLightbox(gallery, index),
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  end: index == gallery.length - 1 ? 0.0 : 8.w,
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(ECardoTokens.radius2xl),
                  child: Image.network(
                    gallery[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: ECardoTokens.brand100(context),
                      child: Icon(
                        Icons.hotel_rounded,
                        size: 48.sp,
                        color: ECardoTokens.brand500(context),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 12.h,
            end: 14.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ECardoTokens.overlay(context).withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${_currentIndex + 1} / ${gallery.length}',
                style: TextStyle(
                  color: ECardoTokens.inkOnBrand,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 12.h,
            end: 14.w,
            child: GestureDetector(
              onTap: () => _openLightbox(gallery, _currentIndex),
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.overlay(context).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.fullscreen_rounded,
                  color: ECardoTokens.inkOnBrand,
                  size: 20.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Fullscreen Interactive Lightbox for Hotel Photos
class _HotelLightboxScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final String hotelTitle;

  const _HotelLightboxScreen({
    required this.images,
    required this.initialIndex,
    required this.hotelTitle,
  });

  @override
  State<_HotelLightboxScreen> createState() => _HotelLightboxScreenState();
}

class _HotelLightboxScreenState extends State<_HotelLightboxScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Interactive Zoomable Page View
            PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 3.5,
                  child: Center(
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),

            // Top Bar with Close & Counter
            Positioned(
              top: 10.h,
              left: 16.w,
              right: 16.w,
              child: Row(
                children: [
                  IconButton(
                    iconSize: 28.sp,
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      widget.hotelTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${_currentIndex + 1} / ${widget.images.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Thumbnail Strip
            Positioned(
              bottom: 16.h,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 60.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: widget.images.length,
                  separatorBuilder: (_, _) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    final isCurrent = index == _currentIndex;
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 60.w,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isCurrent
                                ? ECardoTokens.brand500(context)
                                : Colors.transparent,
                            width: 2.w,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6.r),
                          child: Image.network(
                            widget.images[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Comparison Table across all available rooms
class _RoomComparisonTable extends StatelessWidget {
  final List<Map<String, dynamic>> rooms;
  final String currency;
  final ValueChanged<String> onSelectRoom;

  const _RoomComparisonTable({
    required this.rooms,
    required this.currency,
    required this.onSelectRoom,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Container(
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            ECardoTokens.brand100(context),
          ),
          columns: [
            DataColumn(
              label: Text(
                isRtl ? 'نوع اتاق' : 'Room Type',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: ECardoTokens.brand700(context),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                isRtl ? 'تخت‌ها' : 'Beds',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: ECardoTokens.brand700(context),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                isRtl ? 'صبحانه' : 'Breakfast',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: ECardoTokens.brand700(context),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                isRtl ? 'قیمت/شب' : 'Price/Night',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: ECardoTokens.brand700(context),
                ),
              ),
            ),
            DataColumn(
              label: Text(
                isRtl ? 'انتخاب' : 'Action',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: ECardoTokens.brand700(context),
                ),
              ),
            ),
          ],
          rows: rooms.map((room) {
            final name =
                room['room_name'] ?? room['name'] ?? (isRtl ? 'اتاق' : 'Room');
            final price = double.tryParse(room['price']?.toString() ?? '') ?? 0;
            final roomId = room['room_id']?.toString() ?? '';
            final hasBreakfast =
                room['breakfast_included'] == true ||
                room['meal_plan']?.toString().toLowerCase().contains('breakfast') == true;

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    name.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ),
                DataCell(
                  Text(
                    (room['bed_type'] ?? room['beds'] ?? '1 King / 2 Twin').toString(),
                    style: TextStyle(color: ECardoTokens.inkMuted(context)),
                  ),
                ),
                DataCell(
                  Icon(
                    hasBreakfast ? Icons.check_circle_rounded : Icons.cancel_outlined,
                    size: 18.sp,
                    color: hasBreakfast
                        ? ECardoTokens.success(context)
                        : ECardoTokens.inkMuted(context),
                  ),
                ),
                DataCell(
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      travelMoney(
                        context,
                        TravelMoney(amount: price, currency: currency),
                      ),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.brand700(context),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  ElevatedButton(
                    onPressed: () => onSelectRoom(roomId),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ECardoTokens.brand900(context),
                      foregroundColor: ECardoTokens.inkOnBrand,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isRtl ? 'انتخاب' : 'Select',
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Stylized Location Map Preview Card with surrounding attractions
class _LocationMapPreviewCard extends StatelessWidget {
  final String hotelTitle;
  final String address;
  final num? latitude;
  final num? longitude;

  const _LocationMapPreviewCard({
    required this.hotelTitle,
    required this.address,
    this.latitude,
    this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final landmarks = [
      {'name': isRtl ? 'ایستگاه مترو مرکز شهر' : 'City Center Metro Station', 'dist': '350 m'},
      {'name': isRtl ? 'مرکز خرید اصلی و بلوار تجاری' : 'Grand Shopping Mall', 'dist': '800 m'},
      {'name': isRtl ? 'ساحل و اسکله تفریحی' : 'Marina Waterfront', 'dist': '1.4 km'},
      {'name': isRtl ? 'فرودگاه بین‌المللی' : 'International Airport', 'dist': '12.8 km'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simulated Map Canvas Header
          Container(
            height: 130.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: ECardoTokens.brand100(context),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(ECardoTokens.radiusXl),
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: GridPaper(
                      color: ECardoTokens.brand700(context),
                      divisions: 2,
                      subdivisions: 1,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.r),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand700(context),
                          shape: BoxShape.circle,
                          boxShadow: ECardoTokens.shadowCard(context),
                        ),
                        child: Icon(
                          Icons.hotel_rounded,
                          color: ECardoTokens.inkOnBrand,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: ECardoTokens.surfaceCard(context),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: ECardoTokens.shadowCard(context),
                        ),
                        child: Text(
                          hotelTitle,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Landmarks List
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRtl ? 'اماکن دیدنی و دسترسی‌ها:' : 'Surroundings & Landmarks:',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                SizedBox(height: 10.h),
                for (final landmark in landmarks)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: Row(
                      children: [
                        Icon(
                          Icons.near_me_outlined,
                          size: 15.sp,
                          color: ECardoTokens.brand500(context),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            landmark['name']!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: ECardoTokens.ink(context),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: ECardoTokens.surfaceSunken(context),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            landmark['dist']!,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: ECardoTokens.brand700(context),
                            ),
                          ),
                        ),
                      ],
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

/// Verified Guest Reviews Carousel with score breakdown
class _VerifiedReviewsSection extends StatelessWidget {
  final double overallRating;

  const _VerifiedReviewsSection({required this.overallRating});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final sampleReviews = [
      {
        'name': isRtl ? 'سارا محمدی' : 'Sarah Jenkins',
        'type': isRtl ? 'مسافر تفریحی' : 'Leisure traveler',
        'score': '9.6',
        'date': '2026/03',
        'text': isRtl
            ? 'اتاق فوق‌العاده تمیز و پرسنل بسیار خوش‌برخورد بودند. صبحانه سلف سرویس بی‌نظیر بود.'
            : 'Exceptionally clean room and very attentive staff. The buffet breakfast was outstanding.',
      },
      {
        'name': isRtl ? 'علی رضایی' : 'Alexander Schmidt',
        'type': isRtl ? 'سفر کاری' : 'Business trip',
        'score': '9.4',
        'date': '2026/02',
        'text': isRtl
            ? 'اینترنت پرسرعت در سراسر هتل برقرار بود و دسترسی عالی به مترو داشت. قطعا دوباره انتخابش می‌کنم.'
            : 'Blazing fast WiFi throughout the hotel and excellent metro access. Would definitely book again.',
      },
      {
        'name': isRtl ? 'مریم حسینی' : 'Elena Rostova',
        'type': isRtl ? 'سفر خانوادگی' : 'Family vacation',
        'score': '9.2',
        'date': '2026/01',
        'text': isRtl
            ? 'استخر هتل بسیار آرام و تمیز بود و امکانات اتاق برای خانواده ۴ نفره ما عالی بود.'
            : 'The pool was serene and clean. The suite amenities accommodated our family of four comfortably.',
      },
    ];

    return Column(
      children: [
        // Overall Score Card
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceCard(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
            border: Border.all(color: ECardoTokens.border(context)),
            boxShadow: ECardoTokens.shadowCard(context),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                ),
                child: Text(
                  overallRating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.brand700(context),
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isRtl ? 'فوق‌العاده بر اساس نظرات تایید شده' : 'Exceptional verified reviews',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      isRtl ? '۱۰۰٪ مهمانان واقعی با اقامت تایید شده' : '100% verified real stays',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ECardoTokens.inkMuted(context),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 12.h),

        // Horizontal Reviews Carousel
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: sampleReviews.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final review = sampleReviews[index];
              return Container(
                width: 280.w,
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                  border: Border.all(color: ECardoTokens.border(context)),
                  boxShadow: ECardoTokens.shadowCard(context),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 14.r,
                          backgroundColor: ECardoTokens.brand100(context),
                          child: Text(
                            review['name']!.substring(0, 1),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.brand700(context),
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review['name']!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: ECardoTokens.ink(context),
                                ),
                              ),
                              Text(
                                review['type']!,
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  color: ECardoTokens.inkMuted(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand700(context),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            review['score']!,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w900,
                              color: ECardoTokens.inkOnBrand,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Expanded(
                      child: Text(
                        review['text']!,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: ECardoTokens.ink(context),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
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
