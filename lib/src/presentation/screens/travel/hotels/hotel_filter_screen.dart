import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

class HotelFilterState {
  final String name;
  final bool discountedOnly;
  final RangeValues? priceRange;
  final Set<int> stars;
  final Set<String> specialOffers;
  final Set<String> features;
  final Set<String> propertyTypes;
  final double? minimumRating;
  final bool availableRoomsOnly;

  const HotelFilterState({
    this.name = '',
    this.discountedOnly = false,
    this.priceRange,
    this.stars = const {},
    this.specialOffers = const {},
    this.features = const {},
    this.propertyTypes = const {},
    this.minimumRating,
    this.availableRoomsOnly = false,
  });

  bool get isActive =>
      name.trim().isNotEmpty ||
      discountedOnly ||
      priceRange != null ||
      stars.isNotEmpty ||
      specialOffers.isNotEmpty ||
      features.isNotEmpty ||
      propertyTypes.isNotEmpty ||
      minimumRating != null ||
      availableRoomsOnly;

  HotelFilterState copyWith({
    String? name,
    bool? discountedOnly,
    RangeValues? priceRange,
    bool clearPriceRange = false,
    Set<int>? stars,
    Set<String>? specialOffers,
    Set<String>? features,
    Set<String>? propertyTypes,
    double? minimumRating,
    bool clearMinimumRating = false,
    bool? availableRoomsOnly,
  }) {
    return HotelFilterState(
      name: name ?? this.name,
      discountedOnly: discountedOnly ?? this.discountedOnly,
      priceRange: clearPriceRange ? null : priceRange ?? this.priceRange,
      stars: stars ?? this.stars,
      specialOffers: specialOffers ?? this.specialOffers,
      features: features ?? this.features,
      propertyTypes: propertyTypes ?? this.propertyTypes,
      minimumRating: clearMinimumRating
          ? null
          : minimumRating ?? this.minimumRating,
      availableRoomsOnly: availableRoomsOnly ?? this.availableRoomsOnly,
    );
  }
}

class HotelFilterOptions {
  final double minimumPrice;
  final double maximumPrice;
  final Set<int> stars;
  final Set<String> features;
  final Set<String> propertyTypes;
  final Set<String> specialOffers;

  const HotelFilterOptions({
    required this.minimumPrice,
    required this.maximumPrice,
    required this.stars,
    required this.features,
    required this.propertyTypes,
    required this.specialOffers,
  });

  factory HotelFilterOptions.fromOffers(List<TravelOffer> offers) {
    final prices = offers
        .map((offer) => offer.total.amount)
        .where((price) => price > 0)
        .toList();
    final features = <String>{};
    final propertyTypes = <String>{};
    final specialOffers = <String>{};
    final stars = <int>{};
    for (final offer in offers) {
      features.addAll(offer.featureKeys);
      features.addAll(_strings(offer.product['amenities']));
      final star = int.tryParse(offer.attributes['stars']?.toString() ?? '');
      if (star != null && star > 0) stars.add(star);
      final type =
          offer.attributes['property_type']?.toString().trim() ??
          offer.attributes['type']?.toString().trim() ??
          '';
      if (type.isNotEmpty) propertyTypes.add(type);
      specialOffers.addAll(_strings(offer.attributes['special_offers']));
    }
    return HotelFilterOptions(
      minimumPrice: prices.isEmpty ? 0 : prices.reduce((a, b) => a < b ? a : b),
      maximumPrice: prices.isEmpty ? 1 : prices.reduce((a, b) => a > b ? a : b),
      stars: stars,
      features: features,
      propertyTypes: propertyTypes,
      specialOffers: specialOffers,
    );
  }
}

class HotelFilterScreen extends StatefulWidget {
  final HotelFilterState initial;
  final HotelFilterOptions options;

  const HotelFilterScreen({
    super.key,
    required this.initial,
    required this.options,
  });

  @override
  State<HotelFilterScreen> createState() => _HotelFilterScreenState();
}

class _HotelFilterScreenState extends State<HotelFilterScreen> {
  late HotelFilterState value;
  late final TextEditingController nameController;
  bool showAllFeatures = false;
  bool showAllTypes = false;

  @override
  void initState() {
    super.initState();
    value = widget.initial;
    nameController = TextEditingController(text: value.name);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  void _toggle<T>(Set<T> source, T item, ValueChanged<Set<T>> update) {
    final next = source.toSet();
    next.contains(item) ? next.remove(item) : next.add(item);
    update(next);
  }

  @override
  Widget build(BuildContext context) {
    final options = widget.options;
    final features = options.features.toList()..sort();
    final types = options.propertyTypes.toList()..sort();
    final range =
        value.priceRange ??
        RangeValues(options.minimumPrice, options.maximumPrice);

    return TravelPage(
      title: AppLocalizations.of(context)!.hotel_hotel_filters,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          decoration: BoxDecoration(
            color: ECardoTokens.surfaceCard(context),
            border: Border(top: BorderSide(color: ECardoTokens.border(context))),
            boxShadow: ECardoTokens.shadowSheet(context),
          ),
          child: SizedBox(
            height: 52.h,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(
                value.copyWith(name: nameController.text.trim()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ECardoTokens.brand900(context),
                foregroundColor: ECardoTokens.inkOnBrand,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.hotel_apply_filters,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: ListView(
          padding: EdgeInsets.all(20.r),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.hotel_refine_your_results,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.ink(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    value = const HotelFilterState();
                    nameController.clear();
                  }),
                  style: TextButton.styleFrom(
                    foregroundColor: ECardoTokens.brand500(context),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.hotel_clear_all,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.sp,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              decoration: BoxDecoration(
                color: ECardoTokens.surfaceCard(context),
                borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                border: Border.all(color: ECardoTokens.border(context)),
                boxShadow: ECardoTokens.shadowCard(context),
              ),
              child: TextField(
                controller: nameController,
                style: TextStyle(
                  color: ECardoTokens.ink(context),
                  fontSize: 14.sp,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                  border: InputBorder.none,
                  labelText: AppLocalizations.of(context)!.hotel_search_hotel_name,
                  labelStyle: TextStyle(
                    color: ECardoTokens.inkMuted(context),
                    fontSize: 13.sp,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: ECardoTokens.brand500(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12.h),
            _SwitchFilter(
              title: AppLocalizations.of(context)!.hotel_discounted_hotels_only,
              value: value.discountedOnly,
              onChanged: (next) =>
                  setState(() => value = value.copyWith(discountedOnly: next)),
            ),
            _FilterSection(
              title: AppLocalizations.of(context)!.hotel_price_range,
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(color: ECardoTokens.border(context)),
                ),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: ECardoTokens.brand700(context),
                        inactiveTrackColor: ECardoTokens.surfaceSunken(context),
                        thumbColor: ECardoTokens.brand700(context),
                        overlayColor:
                            ECardoTokens.brand500(context).withValues(alpha: 0.15),
                      ),
                      child: RangeSlider(
                        values: range,
                        min: options.minimumPrice,
                        max: options.maximumPrice <= options.minimumPrice
                            ? options.minimumPrice + 1
                            : options.maximumPrice,
                        onChanged: (next) => setState(
                          () => value = value.copyWith(priceRange: next),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          range.start.toStringAsFixed(0),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                        Text(
                          range.end.toStringAsFixed(0),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: ECardoTokens.ink(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (options.stars.isNotEmpty)
              _FilterSection(
                title: AppLocalizations.of(context)!.hotel_hotel_stars,
                child: Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: (options.stars.toList()..sort())
                      .map(
                        (star) {
                          final selected = value.stars.contains(star);
                          return FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$star',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: selected
                                        ? ECardoTokens.sand600(context)
                                        : ECardoTokens.ink(context),
                                  ),
                                ),
                                SizedBox(width: 3.w),
                                Icon(
                                  Icons.star_rounded,
                                  size: 14.sp,
                                  color: ECardoTokens.sand600(context),
                                ),
                              ],
                            ),
                            selected: selected,
                            backgroundColor: ECardoTokens.surfaceCard(context),
                            selectedColor: ECardoTokens.sand100(context),
                            checkmarkColor: ECardoTokens.sand600(context),
                            side: BorderSide(
                              color: selected
                                  ? ECardoTokens.sand400(context)
                                  : ECardoTokens.border(context),
                            ),
                            onSelected: (_) => _toggle(
                              value.stars,
                              star,
                              (next) => setState(
                                () => value = value.copyWith(stars: next),
                              ),
                            ),
                          );
                        },
                      )
                      .toList(),
                ),
              ),
            _FilterSection(
              title: AppLocalizations.of(context)!.hotel_special_offers,
              child: options.specialOffers.isEmpty
                  ? Text(
                      AppLocalizations.of(context)!
                          .hotel_admin_configured_special_offers_will_appear,
                      style: TextStyle(color: ECardoTokens.inkMuted(context)),
                    )
                  : Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: options.specialOffers
                          .map(
                            (item) {
                              final selected =
                                  value.specialOffers.contains(item);
                              return FilterChip(
                                label: Text(
                                  item,
                                  style: TextStyle(
                                    color: selected
                                        ? ECardoTokens.brand700(context)
                                        : ECardoTokens.ink(context),
                                  ),
                                ),
                                selected: selected,
                                backgroundColor:
                                    ECardoTokens.surfaceCard(context),
                                selectedColor:
                                    ECardoTokens.brand100(context),
                                checkmarkColor:
                                    ECardoTokens.brand700(context),
                                side: BorderSide(
                                  color: selected
                                      ? ECardoTokens.brand500(context)
                                      : ECardoTokens.border(context),
                                ),
                                onSelected: (_) => _toggle(
                                  value.specialOffers,
                                  item,
                                  (next) => setState(
                                    () => value =
                                        value.copyWith(specialOffers: next),
                                  ),
                                ),
                              );
                            },
                          )
                          .toList(),
                    ),
            ),
            if (features.isNotEmpty)
              _FilterSection(
                title: AppLocalizations.of(context)!.hotel_hotel_features,
                child: _ExpandableFilterChips(
                  values: features,
                  selected: value.features,
                  expanded: showAllFeatures,
                  onToggleExpanded: () =>
                      setState(() => showAllFeatures = !showAllFeatures),
                  onSelected: (item) => _toggle(
                    value.features,
                    item,
                    (next) =>
                        setState(() => value = value.copyWith(features: next)),
                  ),
                ),
              ),
            if (types.isNotEmpty)
              _FilterSection(
                title: AppLocalizations.of(context)!.hotel_property_type,
                child: _ExpandableFilterChips(
                  values: types,
                  selected: value.propertyTypes,
                  expanded: showAllTypes,
                  onToggleExpanded: () =>
                      setState(() => showAllTypes = !showAllTypes),
                  onSelected: (item) => _toggle(
                    value.propertyTypes,
                    item,
                    (next) => setState(
                      () => value = value.copyWith(propertyTypes: next),
                    ),
                  ),
                ),
              ),
            _FilterSection(
              title: AppLocalizations.of(context)!.hotel_guest_rating,
              child: Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: [3.0, 3.5, 4.0, 4.5]
                    .map(
                      (rating) {
                        final selected = value.minimumRating == rating;
                        return ChoiceChip(
                          label: Text(
                            '$rating+',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: selected
                                  ? ECardoTokens.inkOnBrand
                                  : ECardoTokens.ink(context),
                            ),
                          ),
                          selected: selected,
                          selectedColor: ECardoTokens.brand900(context),
                          backgroundColor: ECardoTokens.surfaceCard(context),
                          side: BorderSide(
                            color: selected
                                ? ECardoTokens.brand900(context)
                                : ECardoTokens.border(context),
                          ),
                          onSelected: (sel) => setState(
                            () => value = value.copyWith(
                              minimumRating: rating,
                              clearMinimumRating: !sel,
                            ),
                          ),
                        );
                      },
                    )
                    .toList(),
              ),
            ),
            _SwitchFilter(
              title: AppLocalizations.of(context)!
                  .hotel_hotels_with_available_rooms_only,
              value: value.availableRoomsOnly,
              onChanged: (next) => setState(
                () => value = value.copyWith(availableRoomsOnly: next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _FilterSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 22.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 14.sp,
              color: ECardoTokens.ink(context),
            ),
          ),
          SizedBox(height: 10.h),
          child,
        ],
      ),
    );
  }
}

class _SwitchFilter extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchFilter({
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: ECardoTokens.surfaceCard(context),
        borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
        border: Border.all(color: ECardoTokens.border(context)),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
            color: ECardoTokens.ink(context),
          ),
        ),
        activeTrackColor: ECardoTokens.brand700(context),
        activeThumbColor: ECardoTokens.surfaceCard(context),
        inactiveTrackColor: ECardoTokens.surfaceSunken(context),
        inactiveThumbColor: ECardoTokens.inkMuted(context),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}

class _ExpandableFilterChips extends StatelessWidget {
  final List<String> values;
  final Set<String> selected;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<String> onSelected;

  const _ExpandableFilterChips({
    required this.values,
    required this.selected,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final visible = expanded ? values : values.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: visible
              .map(
                (item) {
                  final isSelected = selected.contains(item);
                  return FilterChip(
                    label: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected
                            ? ECardoTokens.brand700(context)
                            : ECardoTokens.ink(context),
                      ),
                    ),
                    selected: isSelected,
                    backgroundColor: ECardoTokens.surfaceCard(context),
                    selectedColor: ECardoTokens.brand100(context),
                    checkmarkColor: ECardoTokens.brand700(context),
                    side: BorderSide(
                      color: isSelected
                          ? ECardoTokens.brand500(context)
                          : ECardoTokens.border(context),
                    ),
                    onSelected: (_) => onSelected(item),
                  );
                },
              )
              .toList(),
        ),
        if (values.length > 6)
          TextButton.icon(
            onPressed: onToggleExpanded,
            style: TextButton.styleFrom(
              foregroundColor: ECardoTokens.brand500(context),
            ),
            icon: Icon(
              expanded
                  ? Icons.keyboard_arrow_up_rounded
                  : Icons.keyboard_arrow_down_rounded,
              size: 18.sp,
            ),
            label: Text(
              expanded
                  ? AppLocalizations.of(context)!.hotel_show_less
                  : AppLocalizations.of(context)!.hotel_show_more,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

List<String> _strings(dynamic value) {
  if (value is! List) return const [];
  return value
      .map((item) => item?.toString().trim() ?? '')
      .where((item) => item.isNotEmpty)
      .toList();
}

List<TravelOffer> applyHotelFilters(
  List<TravelOffer> offers,
  HotelFilterState filter,
) {
  return offers.where((offer) {
    final title = offer.titleKey.toLowerCase();
    if (filter.name.isNotEmpty &&
        !title.contains(filter.name.trim().toLowerCase())) {
      return false;
    }
    if (filter.discountedOnly &&
        offer.attributes['discount'] != true &&
        (double.tryParse(offer.attributes['discount']?.toString() ?? '') ??
                0) <=
            0) {
      return false;
    }
    if (filter.priceRange != null &&
        (offer.total.amount < filter.priceRange!.start ||
            offer.total.amount > filter.priceRange!.end)) {
      return false;
    }
    final stars =
        int.tryParse(offer.attributes['stars']?.toString() ?? '') ?? 0;
    if (filter.stars.isNotEmpty && !filter.stars.contains(stars)) return false;
    if (filter.minimumRating != null && offer.rating < filter.minimumRating!) {
      return false;
    }
    final features = {
      ...offer.featureKeys,
      ..._strings(offer.product['amenities']),
    };
    if (!features.containsAll(filter.features)) return false;
    final type =
        offer.attributes['property_type']?.toString().trim() ??
        offer.attributes['type']?.toString().trim() ??
        '';
    if (filter.propertyTypes.isNotEmpty &&
        !filter.propertyTypes.contains(type)) {
      return false;
    }
    final specials = _strings(offer.attributes['special_offers']).toSet();
    if (!specials.containsAll(filter.specialOffers)) return false;
    if (filter.availableRoomsOnly) {
      final roomCount =
          int.tryParse(offer.attributes['rooms_count']?.toString() ?? '') ?? 0;
      if (roomCount <= 0 && offer.product['rooms'] is! List) return false;
    }
    return true;
  }).toList();
}
