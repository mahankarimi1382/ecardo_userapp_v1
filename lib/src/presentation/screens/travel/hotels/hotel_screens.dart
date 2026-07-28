import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        details.checkInDate ?? DateTime.now().add(const Duration(days: 30));
    checkOutDate =
        details.checkOutDate ?? checkInDate.add(const Duration(days: 2));
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
                        showTravelMessage(
                          context,
                          title: localization.travelHotelSearch,
                          message: localization.travelDestinationCity,
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
                        showTravelMessage(
                          context,
                          title: localization.travelHotelSearch,
                          message: localization.allControllerLoadError,
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
                    onTap: () async {
                      await controller.loadOfferDetails(offer);
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SizedBox(
              height: 145.h,
              width: double.infinity,
              child: offer.imageUrl.isNotEmpty
                  ? Image.network(
                      offer.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const _HotelImageFallback(),
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
    return TravelPage(
      title: localization.travelHotelDetails,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          _HotelGallery(images: images, fallbackImageUrl: offer.imageUrl),
          SizedBox(height: 18.h),
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
                    const Icon(Icons.map_outlined, color: TravelTheme.purple),
                ],
              ),
            ),
          ],
          SizedBox(height: 20.h),
          _ProviderMoneySummary(offer: offer),
          if (description.isNotEmpty) ...[
            SizedBox(height: 26.h),
            TravelSectionHeader(title: localization.travelAboutHotel),
            SizedBox(height: 8.h),
            TravelBidiText(
              description,
              style: TextStyle(fontSize: 13.sp, height: 1.8),
            ),
          ],
          if (amenities.isNotEmpty) ...[
            SizedBox(height: 24.h),
            TravelSectionHeader(title: localization.travelIncluded),
            SizedBox(height: 10.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: amenities
                  .map((item) => Chip(label: Text(item)))
                  .toList(),
            ),
          ],
          if (rooms.isNotEmpty) ...[
            SizedBox(height: 24.h),
            TravelSectionHeader(title: localization.travelHotels),
            SizedBox(height: 10.h),
            ...rooms.map(
              (room) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _ProviderRoomCard(
                  room: room,
                  enabled: controller.canPurchase(TravelProductType.hotel),
                  onSelect: () {
                    final roomId = room['room_id']?.toString() ?? '';
                    final roomName =
                        room['room_name']?.toString() ??
                        room['name']?.toString() ??
                        '';
                    final unitPrice =
                        double.tryParse(room['price']?.toString() ?? '') ?? 0;
                    final nights =
                        bookingDetails.checkInDate != null &&
                            bookingDetails.checkOutDate != null
                        ? bookingDetails.checkOutDate!
                              .difference(bookingDetails.checkInDate!)
                              .inDays
                              .clamp(1, 365)
                              .toInt()
                        : 1;
                    final total = TravelMoney(
                      amount: unitPrice * bookingDetails.roomCount * nights,
                      currency:
                          room['currency']?.toString() ?? offer.total.currency,
                    );
                    Get.to(
                      () => TravelCheckoutScreen(
                        type: TravelProductType.hotel,
                        productId: offer.id,
                        title:
                            '${travelLocalizedKey(localization, offer.titleKey)} • $roomName',
                        total: total,
                        bookingDetails: bookingDetails.copyWith(
                          roomId: roomId,
                          roomName: roomName,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
          if (reviews.isNotEmpty) ...[
            SizedBox(height: 24.h),
            TravelSectionHeader(title: localization.travelStatus),
            SizedBox(height: 10.h),
            _ProviderMapCard(values: reviews),
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
            TravelSectionHeader(title: localization.travelPolicies),
            SizedBox(height: 10.h),
            _ProviderMapCard(values: offer.policies),
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
            child: Image.network(
              gallery[index],
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const _HotelImageFallback(),
            ),
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
  final VoidCallback onSelect;

  const _ProviderRoomCard({
    required this.room,
    required this.enabled,
    required this.onSelect,
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
    final description = room['description']?.toString().trim() ?? '';
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
              child: Image.network(
                imageUrls.first,
                height: 150.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelBidiText(
                  room['room_name']?.toString() ??
                      room['name']?.toString() ??
                      '',
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
                      TravelMoney(amount: price, currency: currency),
                    ),
                    style: const TextStyle(
                      color: TravelTheme.purple,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
                if (values.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  _ProviderMapRows(values: values),
                ],
                SizedBox(height: 14.h),
                CommonButton(
                  width: double.infinity,
                  text: enabled
                      ? AppLocalizations.of(context)!.travelSelect
                      : AppLocalizations.of(context)!.travelOfferUnavailable,
                  backgroundColor: enabled
                      ? TravelTheme.purple
                      : TravelTheme.muted,
                  onPressed: enabled && price > 0 ? onSelect : null,
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
        .where((entry) => _providerValue(entry.value).isNotEmpty)
        .toList();
    return Column(
      children: [
        for (var index = 0; index < entries.length; index++) ...[
          _PolicyRow(
            title: _providerLabel(entries[index].key),
            value: _providerValue(entries[index].value),
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

String _providerLabel(String key) {
  final words = key.replaceAll('_', ' ').trim();
  if (words.isEmpty) return '';
  return '${words[0].toUpperCase()}${words.substring(1)}';
}

String _providerValue(dynamic value) {
  if (value == null) return '';
  if (value is bool) return value ? '✓' : '—';
  if (value is List) {
    return value
        .map(_providerValue)
        .where((item) => item.isNotEmpty)
        .join(', ');
  }
  if (value is Map) {
    return value.entries
        .map(
          (entry) =>
              '${_providerLabel(entry.key.toString())}: ${_providerValue(entry.value)}',
        )
        .where((item) => !item.endsWith(': '))
        .join(' • ');
  }
  return value.toString();
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
