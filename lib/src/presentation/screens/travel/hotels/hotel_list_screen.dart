import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';

import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';
import 'hotel_detail_screen.dart';
import 'hotel_filter_screen.dart';
import 'hotel_screens.dart' show formatHotelOccupancy;
import 'hotel_search_components.dart';

enum HotelSortOption { recommended, priceLowToHigh, priceHighToLow, rating }

/// International-Grade Hotel List Screen presenting card-based results with
/// Star Rating, Price per Night, Cancellation badge, Free amenities icons,
/// and interactive comparison.
class HotelListScreen extends StatefulWidget {
  final int? initialMinStars;
  final bool initialFreeCancellation;

  const HotelListScreen({
    super.key,
    this.initialMinStars,
    this.initialFreeCancellation = false,
  });

  @override
  State<HotelListScreen> createState() => _HotelListScreenState();
}

class _HotelListScreenState extends State<HotelListScreen> {
  HotelSortOption _sort = HotelSortOption.recommended;
  double? _minimumRating;
  final Set<String> _comparisonIds = {};
  final ScrollController _scrollController = ScrollController();
  late HotelFilterState _filters;
  int _visibleCount = 8;

  @override
  void initState() {
    super.initState();
    _filters = HotelFilterState(
      stars: widget.initialMinStars != null ? {widget.initialMinStars!} : const {},
      specialOffers: widget.initialFreeCancellation ? {'Free Cancellation'} : const {},
    );
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
    final next = await showModalBottomSheet<HotelSortOption>(
      context: context,
      showDragHandle: true,
      backgroundColor: ECardoTokens.surfaceCard(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ECardoTokens.radius2xl),
        ),
      ),
      builder: (context) {
        final localization = AppLocalizations.of(context)!;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.sort_rounded,
                      color: ECardoTokens.brand700(context),
                      size: 22.sp,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      l10nPick(context, en: 'Sort', fa: 'مرتب‌سازی', ar: 'فرز', zh: '排序'),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w900,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: ECardoTokens.border(context)),
              for (final option in HotelSortOption.values)
                if ((canSortByPrice ||
                        !{
                          HotelSortOption.priceLowToHigh,
                          HotelSortOption.priceHighToLow,
                        }.contains(option)) &&
                    (hasRatings || option != HotelSortOption.rating))
                  ListTile(
                    title: Text(
                      _hotelSortLabel(localization, option),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: _sort == option
                            ? FontWeight.w900
                            : FontWeight.w600,
                        color: _sort == option
                            ? ECardoTokens.brand700(context)
                            : ECardoTokens.ink(context),
                      ),
                    ),
                    trailing: _sort == option
                        ? Icon(
                            Icons.check_circle_rounded,
                            color: ECardoTokens.brand700(context),
                          )
                        : null,
                    onTap: () => Navigator.of(context).pop(option),
                  ),
            ],
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
      backgroundColor: ECardoTokens.surfaceCard(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(ECardoTokens.radius2xl),
        ),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                AppLocalizations.of(context)!.hotel_all_ratings,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: ECardoTokens.ink(context),
                ),
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
            for (final rating in [3.0, 4.0, 4.5])
              ListTile(
                leading: Icon(
                  Icons.star_rounded,
                  color: ECardoTokens.sand600(context),
                ),
                title: Text(
                  '$rating+ ★',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: ECardoTokens.ink(context),
                  ),
                ),
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
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: Obx(() {
          final search = controller.lastHotelSearch.value;
          final offers = controller.hotelOffers.toList();
          final canSortByPrice = _canSortHotelOffersByPrice(offers);
          final hasRatings = offers.any((offer) => offer.rating > 0);
          final effectiveSort = canSortByPrice
              ? _sort
              : switch (_sort) {
                  HotelSortOption.priceLowToHigh ||
                  HotelSortOption.priceHighToLow => HotelSortOption.recommended,
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
                _HotelSearchSummaryCard(
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
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: ECardoTokens.brand100(context),
                    borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                    border: Border.all(
                      color: ECardoTokens.brand700(context).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localization.travelSelectedForComparison(
                            _comparisonIds.length,
                          ),
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _showHotelComparison(
                          context,
                          offers
                              .where((offer) => _comparisonIds.contains(offer.id))
                              .toList(),
                        ),
                        icon: Icon(
                          Icons.compare_arrows_rounded,
                          color: ECardoTokens.brand700(context),
                        ),
                        label: Text(
                          localization.travelCompare,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.brand700(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              if (controller.isLoading.value)
                const TravelShimmerLoading(
                  type: TravelShimmerType.hotelCard,
                  count: 4,
                )
              else if (offers.isEmpty)
                _HotelResultsEmptyState(
                  hasError: controller.searchError.value != null,
                  onEdit: Get.back,
                  onRetry: search == null
                      ? null
                      : () => controller.searchHotels(search),
                  onNotify: search == null
                      ? null
                      : () async {
                          final dep = search.checkInDate;
                          final dateStr =
                              '${dep.year.toString().padLeft(4, '0')}-'
                              '${dep.month.toString().padLeft(2, '0')}-'
                              '${dep.day.toString().padLeft(2, '0')}';
                          final ok = await controller.subscribeNotifyMe(
                            serviceType: 'hotel',
                            destination: search.city,
                            travelDate: dateStr,
                          );
                          final ctx = Get.context;
                          if (ctx == null || !ctx.mounted) return;
                          Get.snackbar(
                            ok ? 'OK' : 'Error',
                            ok
                                ? 'We will notify you when matching hotels are available.'
                                : (controller.checkoutError.value ??
                                    'Request failed'),
                          );
                        },
                )
              else ...[
                _HotelResultActionsBar(
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
                    _sort = HotelSortOption.recommended;
                    _minimumRating = null;
                    _filters = const HotelFilterState();
                  }),
                ),
                SizedBox(height: 16.h),
                if (comparedOffers.isEmpty)
                  _HotelFilteredEmptyState(
                    onReset: () => setState(() {
                      _sort = HotelSortOption.recommended;
                      _minimumRating = null;
                      _filters = const HotelFilterState();
                    }),
                  )
                else ...[
                  ...visibleOffers.map(
                    (offer) => Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: HotelResultCard(
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
                            Get.to(() => const HotelDetailScreen());
                          }
                        },
                      ),
                    ),
                  ),
                  if (visibleOffers.length < comparedOffers.length)
                    Padding(
                      padding: EdgeInsets.all(18.r),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ECardoTokens.brand700(context),
                        ),
                      ),
                    ),
                ],
              ],
            ],
          );
        }),
      ),
    );
  }
}

class _HotelResultActionsBar extends StatelessWidget {
  final HotelSortOption sort;
  final bool activeFilters;
  final bool discountedOnly;
  final VoidCallback onSort;
  final VoidCallback onFilters;
  final VoidCallback? onRating;
  final VoidCallback onDiscount;
  final VoidCallback onReset;

  const _HotelResultActionsBar({
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
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              ActionChip(
                avatar: Icon(
                  Icons.sort_rounded,
                  size: 18.sp,
                  color: ECardoTokens.brand700(context),
                ),
                label: Text(
                  _hotelSortLabel(localization, sort),
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.ink(context),
                  ),
                ),
                backgroundColor: ECardoTokens.surfaceSunken(context),
                side: BorderSide(color: ECardoTokens.border(context)),
                onPressed: onSort,
              ),
              ActionChip(
                avatar: Icon(
                  Icons.tune_rounded,
                  size: 18.sp,
                  color: activeFilters
                      ? ECardoTokens.brand700(context)
                      : ECardoTokens.inkMuted(context),
                ),
                label: Text(
                  activeFilters
                      ? AppLocalizations.of(context)!.hotel_active_filters
                      : AppLocalizations.of(context)!.hotel_all_filters,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: activeFilters
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: activeFilters
                        ? ECardoTokens.brand700(context)
                        : ECardoTokens.ink(context),
                  ),
                ),
                backgroundColor: activeFilters
                    ? ECardoTokens.brand100(context)
                    : ECardoTokens.surfaceSunken(context),
                side: BorderSide(
                  color: activeFilters
                      ? ECardoTokens.brand700(context)
                      : ECardoTokens.border(context),
                ),
                onPressed: onFilters,
              ),
              if (onRating != null)
                ActionChip(
                  avatar: Icon(
                    Icons.star_outline_rounded,
                    size: 18.sp,
                    color: ECardoTokens.sand600(context),
                  ),
                  label: Text(
                    localization.travelRating,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                  backgroundColor: ECardoTokens.surfaceSunken(context),
                  side: BorderSide(color: ECardoTokens.border(context)),
                  onPressed: onRating,
                ),
              FilterChip(
                avatar: Icon(
                  Icons.local_offer_outlined,
                  size: 18.sp,
                  color: discountedOnly
                      ? ECardoTokens.brand700(context)
                      : ECardoTokens.inkMuted(context),
                ),
                label: Text(
                  AppLocalizations.of(context)!.hotel_discounted,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: discountedOnly
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: discountedOnly
                        ? ECardoTokens.brand700(context)
                        : ECardoTokens.ink(context),
                  ),
                ),
                selected: discountedOnly,
                backgroundColor: ECardoTokens.surfaceSunken(context),
                selectedColor: ECardoTokens.brand100(context),
                side: BorderSide(
                  color: discountedOnly
                      ? ECardoTokens.brand700(context)
                      : ECardoTokens.border(context),
                ),
                onSelected: (_) => onDiscount(),
              ),
            ],
          ),
          if (activeFilters || sort != HotelSortOption.recommended)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: onReset,
                icon: Icon(
                  Icons.restart_alt_rounded,
                  size: 16.sp,
                  color: ECardoTokens.brand500(context),
                ),
                label: Text(
                  localization.reset,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: ECardoTokens.brand500(context),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HotelSearchSummaryCard extends StatelessWidget {
  final TravelHotelSearch search;
  final int resultCount;
  final int totalResultCount;
  final VoidCallback onEdit;

  const _HotelSearchSummaryCard({
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

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
        border: Border.all(color: ECardoTokens.border(context)),
        boxShadow: ECardoTokens.shadowCard(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.brand100(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on_rounded,
                  color: ECardoTokens.brand700(context),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: TravelBidiText(
                  search.city,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w900,
                    color: ECardoTokens.ink(context),
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: Icon(
                  Icons.edit_outlined,
                  size: 16.sp,
                  color: ECardoTokens.brand700(context),
                ),
                label: Text(
                  localization.p2pEdit,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.sp,
                    color: ECardoTokens.brand700(context),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Text(
            dates,
            style: TextStyle(
              color: ECardoTokens.inkMuted(context),
              fontSize: 12.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '${localization.travelGuests}: '
            '${formatHotelOccupancy(context, rooms: search.roomCount, adults: search.adultCount, children: search.childCount)}',
            style: TextStyle(
              color: ECardoTokens.inkMuted(context),
              fontSize: 12.sp,
            ),
          ),
          Divider(color: ECardoTokens.border(context), height: 20.h),
          Text(
            '$resultCount / $totalResultCount '
            '${localization.travelHotelResults}',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.sp,
              color: ECardoTokens.ink(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Comprehensive Card for displaying an individual Hotel Offer with Star Rating,
/// Price per night, Cancellation Badge, and Free Amenities Icons.
class HotelResultCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;
  final VoidCallback onCompare;
  final bool isLoading;
  final bool isCompared;

  const HotelResultCard({
    super.key,
    required this.offer,
    required this.onTap,
    required this.onCompare,
    this.isLoading = false,
    this.isCompared = false,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final starCount = int.tryParse(offer.attributes['stars']?.toString() ?? '');
    final hasFreeCancellation = offer.attributes['free_cancellation'] == true ||
        offer.attributes['cancellation_free'] == true ||
        offer.attributes['cancellation_policy']
                ?.toString()
                .toLowerCase()
                .contains('free') ==
            true ||
        offer.product['cancellation_policy']
                ?.toString()
                .toLowerCase()
                .contains('free') ==
            true;

    return Semantics(
      label: '${travelLocalizedKey(localization, offer.titleKey)}, hotel details',
      button: true,
      child: Container(
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
                // Top Image with Star Rating & Compare Badge
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(ECardoTokens.radiusXl),
                      ),
                      child: SizedBox(
                        height: 155.h,
                        width: double.infinity,
                        child: offer.imageUrl.isNotEmpty
                            ? Image.network(
                                offer.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _buildImagePlaceholder(context),
                              )
                            : _buildImagePlaceholder(context),
                      ),
                    ),
                    // Rating Badge on Image
                    if (offer.rating > 0)
                      Positioned(
                        top: 10.h,
                        left: 12.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: ECardoTokens.surfaceCard(context).withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
                            boxShadow: ECardoTokens.shadowCard(context),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14.sp,
                                color: ECardoTokens.sand600(context),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                offer.rating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w900,
                                  color: ECardoTokens.ink(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Compare Toggle Button on Image
                    Positioned(
                      top: 6.h,
                      right: 8.w,
                      child: IconButton(
                        iconSize: 22.sp,
                        tooltip: localization.travelCompare,
                        onPressed: onCompare,
                        icon: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: ECardoTokens.surfaceCard(context).withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCompared
                                ? Icons.bookmark_added_rounded
                                : Icons.bookmark_add_outlined,
                            color: isCompared
                                ? ECardoTokens.brand700(context)
                                : ECardoTokens.inkMuted(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Card Body
                Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & Stars Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              travelLocalizedKey(localization, offer.titleKey),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: ECardoTokens.ink(context),
                              ),
                            ),
                          ),
                          if (starCount != null && starCount > 0)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6.w,
                                vertical: 2.h,
                              ),
                              decoration: BoxDecoration(
                                color: ECardoTokens.sand100(context),
                                borderRadius:
                                    BorderRadius.circular(ECardoTokens.radiusSm),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  for (int i = 0; i < starCount && i < 5; i++)
                                    Icon(
                                      Icons.star_rounded,
                                      size: 12.sp,
                                      color: ECardoTokens.sand600(context),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        travelLocalizedKey(localization, offer.subtitleKey),
                        style: TextStyle(
                          color: ECardoTokens.inkMuted(context),
                          fontSize: 12.sp,
                        ),
                      ),

                      // Cancellation Badge
                      if (hasFreeCancellation)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              color: ECardoTokens.successBg(context),
                              borderRadius:
                                  BorderRadius.circular(ECardoTokens.radiusSm),
                              border: Border.all(
                                color: ECardoTokens.success(context)
                                    .withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle_outline_rounded,
                                  size: 13.sp,
                                  color: ECardoTokens.success(context),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  hotelFlowText(
                                    context,
                                    'کنسلی رایگان',
                                    'Free Cancellation',
                                  ),
                                  style: TextStyle(
                                    color: ECardoTokens.success(context),
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      SizedBox(height: 10.h),

                      // Free Amenities Icons Row
                      _buildAmenitiesRow(context, offer),

                      Divider(
                        color: ECardoTokens.border(context),
                        height: 24.h,
                      ),

                      // Pricing & CTA Button
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localization.travelStartingPrice,
                                  style: TextStyle(
                                    color: ECardoTokens.inkMuted(context),
                                    fontSize: 10.sp,
                                  ),
                                ),
                                Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text(
                                    travelMoney(context, offer.total),
                                    style: TextStyle(
                                      color: ECardoTokens.brand700(context),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  hotelFlowText(
                                    context,
                                    'شامل مالیات و عوارض',
                                    'Taxes & fees included',
                                  ),
                                  style: TextStyle(
                                    color: ECardoTokens.inkMuted(context),
                                    fontSize: 10.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: 125.w,
                            child: CommonButton(
                              height: 44,
                              fontSize: 12,
                              backgroundColor: ECardoTokens.brand900(context),
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
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      color: ECardoTokens.brand100(context),
      child: Center(
        child: Icon(
          Icons.hotel_rounded,
          size: 48.sp,
          color: ECardoTokens.brand500(context),
        ),
      ),
    );
  }

  Widget _buildAmenitiesRow(BuildContext context, TravelOffer offer) {
    final amenities = <Map<String, dynamic>>[];
    final allFeatures = [
      ...offer.featureKeys,
      if (offer.product['amenities'] is List)
        ...(offer.product['amenities'] as List).map((e) => e.toString()),
    ];

    final featuresLower = allFeatures.map((f) => f.toLowerCase()).join(' ');

    if (featuresLower.contains('wifi') || featuresLower.contains('اینترنت')) {
      amenities.add({'icon': Icons.wifi_rounded, 'label': 'Free WiFi'});
    }
    if (featuresLower.contains('breakfast') || featuresLower.contains('صبحانه')) {
      amenities.add({'icon': Icons.restaurant_rounded, 'label': 'Breakfast'});
    }
    if (featuresLower.contains('pool') || featuresLower.contains('استخر')) {
      amenities.add({'icon': Icons.pool_rounded, 'label': 'Pool'});
    }
    if (featuresLower.contains('parking') || featuresLower.contains('پارکینگ')) {
      amenities.add({'icon': Icons.local_parking_rounded, 'label': 'Parking'});
    }
    if (featuresLower.contains('gym') || featuresLower.contains('باشگاه')) {
      amenities.add({'icon': Icons.fitness_center_rounded, 'label': 'Gym'});
    }
    if (featuresLower.contains('shuttle') || featuresLower.contains('ترانسفر')) {
      amenities.add({'icon': Icons.airport_shuttle_rounded, 'label': 'Shuttle'});
    }

    if (amenities.isEmpty) {
      amenities.addAll([
        {'icon': Icons.wifi_rounded, 'label': 'Free WiFi'},
        {'icon': Icons.ac_unit_rounded, 'label': 'AC'},
        {'icon': Icons.room_service_rounded, 'label': 'Room Service'},
      ]);
    }

    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: amenities.take(5).map((amenity) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceSunken(context),
            borderRadius: BorderRadius.circular(ECardoTokens.radiusSm),
            border: Border.all(color: ECardoTokens.border(context)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                amenity['icon'] as IconData,
                size: 13.sp,
                color: ECardoTokens.brand700(context),
              ),
              SizedBox(width: 4.w),
              Text(
                amenity['label'] as String,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: ECardoTokens.ink(context),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _HotelResultsEmptyState extends StatelessWidget {
  final bool hasError;
  final VoidCallback onEdit;
  final VoidCallback? onRetry;
  final VoidCallback? onNotify;

  const _HotelResultsEmptyState({
    required this.hasError,
    required this.onEdit,
    required this.onRetry,
    this.onNotify,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    if (hasError) {
      return TravelErrorState(
        message: localization.allControllerLoadError,
        onRetry: onRetry,
      );
    }
    return Column(
      children: [
        TravelEmptyState(
          icon: Icons.hotel_rounded,
          title: localization.travelNoHotelResults,
          message: localization.travelOfferUnavailable,
          actionText: localization.travelSearchHotels,
          onAction: onEdit,
        ),
        if (onNotify != null) ...[
          SizedBox(height: AppSpacing.sm.h),
          FilledButton.icon(
            onPressed: onNotify,
            style: FilledButton.styleFrom(
              backgroundColor: ECardoTokens.brand900(context),
              foregroundColor: ECardoTokens.inkOnBrand,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
              ),
            ),
            icon: const Icon(Icons.notifications_active_outlined),
            label: Text(
              () {
                final code = Localizations.localeOf(context).languageCode;
                if (code == 'fa') return 'موجود شد خبرم کن';
                if (code == 'ar') return 'أعلمني عند التوفر';
                return 'Notify me when available';
              }(),
            ),
          ),
        ],
      ],
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
          style: TextButton.styleFrom(
            foregroundColor: ECardoTokens.brand700(context),
          ),
          icon: const Icon(Icons.restart_alt_rounded),
          label: Text(localization.reset),
        ),
      ],
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
    backgroundColor: ECardoTokens.surfaceCard(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(ECardoTokens.radius2xl),
      ),
    ),
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
              style: TextStyle(
                color: ECardoTokens.inkMuted(context),
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 16.h),
            ...offers.map(
              (offer) => Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(14.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceSunken(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(color: ECardoTokens.border(context)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TravelBidiText(
                      travelLocalizedKey(localization, offer.titleKey),
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14.sp,
                        color: ECardoTokens.ink(context),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          localization.travelStartingPrice,
                          style: TextStyle(
                            color: ECardoTokens.inkMuted(context),
                            fontSize: 12.sp,
                          ),
                        ),
                        const Spacer(),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            travelMoney(context, offer.total),
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: ECardoTokens.brand700(context),
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (offer.rating > 0) ...[
                      Divider(color: ECardoTokens.border(context)),
                      Row(
                        children: [
                          Text(
                            localization.travelRating,
                            style: TextStyle(
                              color: ECardoTokens.inkMuted(context),
                              fontSize: 12.sp,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '★ ${offer.rating}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: ECardoTokens.sand600(context),
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
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

String _hotelSortLabel(AppLocalizations localization, HotelSortOption sort) {
  return switch (sort) {
    HotelSortOption.recommended => localization.travelRecommended,
    HotelSortOption.priceLowToHigh => localization.travelPriceLowToHigh,
    HotelSortOption.priceHighToLow => localization.travelPriceHighToLow,
    HotelSortOption.rating => localization.travelRatingHighToLow,
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
  required HotelSortOption sort,
  required double? minimumRating,
}) {
  final visibleOffers = offers
      .where((offer) => minimumRating == null || offer.rating >= minimumRating)
      .toList();
  switch (sort) {
    case HotelSortOption.recommended:
      break;
    case HotelSortOption.priceLowToHigh:
      visibleOffers.sort(
        (first, second) => first.total.amount.compareTo(second.total.amount),
      );
    case HotelSortOption.priceHighToLow:
      visibleOffers.sort(
        (first, second) => second.total.amount.compareTo(first.total.amount),
      );
    case HotelSortOption.rating:
      visibleOffers.sort(
        (first, second) => second.rating.compareTo(first.rating),
      );
  }
  return visibleOffers;
}
