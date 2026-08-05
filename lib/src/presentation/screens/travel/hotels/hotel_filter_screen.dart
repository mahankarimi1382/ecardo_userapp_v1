import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import 'hotel_search_components.dart';

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
      title: hotelFlowText(context, 'فیلتر هتل‌ها', 'Hotel filters'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: FilledButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(value.copyWith(name: nameController.text.trim())),
            style: FilledButton.styleFrom(
              backgroundColor: TravelTheme.purple,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              hotelFlowText(context, 'اعمال فیلترها', 'Apply filters'),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  hotelFlowText(
                    context,
                    'نتایج را دقیق‌تر کنید',
                    'Refine your results',
                  ),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => setState(() {
                  value = const HotelFilterState();
                  nameController.clear();
                }),
                child: Text(hotelFlowText(context, 'پاک کردن', 'Clear all')),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              labelText: hotelFlowText(
                context,
                'جستجوی نام هتل',
                'Search hotel name',
              ),
              prefixIcon: const Icon(Icons.search_rounded),
            ),
          ),
          SizedBox(height: 12.h),
          _SwitchFilter(
            title: hotelFlowText(
              context,
              'فقط هتل‌های دارای تخفیف',
              'Discounted hotels only',
            ),
            value: value.discountedOnly,
            onChanged: (next) =>
                setState(() => value = value.copyWith(discountedOnly: next)),
          ),
          _FilterSection(
            title: hotelFlowText(context, 'محدوده قیمت', 'Price range'),
            child: Column(
              children: [
                RangeSlider(
                  values: range,
                  min: options.minimumPrice,
                  max: options.maximumPrice <= options.minimumPrice
                      ? options.minimumPrice + 1
                      : options.maximumPrice,
                  onChanged: (next) =>
                      setState(() => value = value.copyWith(priceRange: next)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(range.start.toStringAsFixed(0)),
                    Text(range.end.toStringAsFixed(0)),
                  ],
                ),
              ],
            ),
          ),
          if (options.stars.isNotEmpty)
            _FilterSection(
              title: hotelFlowText(context, 'ستاره هتل', 'Hotel stars'),
              child: Wrap(
                spacing: 8.w,
                children: (options.stars.toList()..sort())
                    .map(
                      (star) => FilterChip(
                        label: Text('$star ★'),
                        selected: value.stars.contains(star),
                        onSelected: (_) => _toggle(
                          value.stars,
                          star,
                          (next) => setState(
                            () => value = value.copyWith(stars: next),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          _FilterSection(
            title: hotelFlowText(context, 'پیشنهادهای ویژه', 'Special offers'),
            child: options.specialOffers.isEmpty
                ? Text(
                    hotelFlowText(
                      context,
                      'پیشنهادهای ویژه پس از تعریف در پنل مدیریت اینجا نمایش داده می‌شوند.',
                      'Admin-configured special offers will appear here.',
                    ),
                    style: TextStyle(color: TravelTheme.muted),
                  )
                : Wrap(
                    spacing: 8.w,
                    children: options.specialOffers
                        .map(
                          (item) => FilterChip(
                            label: Text(item),
                            selected: value.specialOffers.contains(item),
                            onSelected: (_) => _toggle(
                              value.specialOffers,
                              item,
                              (next) => setState(
                                () =>
                                    value = value.copyWith(specialOffers: next),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
          if (features.isNotEmpty)
            _FilterSection(
              title: hotelFlowText(context, 'امکانات هتل', 'Hotel features'),
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
              title: hotelFlowText(context, 'نوع اقامتگاه', 'Property type'),
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
            title: hotelFlowText(context, 'امتیاز کاربران', 'Guest rating'),
            child: Wrap(
              spacing: 8.w,
              children: [3.0, 3.5, 4.0, 4.5]
                  .map(
                    (rating) => ChoiceChip(
                      label: Text('$rating+'),
                      selected: value.minimumRating == rating,
                      onSelected: (selected) => setState(
                        () => value = value.copyWith(
                          minimumRating: rating,
                          clearMinimumRating: !selected,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          _SwitchFilter(
            title: hotelFlowText(
              context,
              'فقط هتل‌های دارای اتاق موجود',
              'Hotels with available rooms only',
            ),
            value: value.availableRoomsOnly,
            onChanged: (next) => setState(
              () => value = value.copyWith(availableRoomsOnly: next),
            ),
          ),
        ],
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
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
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      value: value,
      onChanged: onChanged,
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
          runSpacing: 6.h,
          children: visible
              .map(
                (item) => FilterChip(
                  label: Text(item),
                  selected: selected.contains(item),
                  onSelected: (_) => onSelected(item),
                ),
              )
              .toList(),
        ),
        if (values.length > 6)
          TextButton.icon(
            onPressed: onToggleExpanded,
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
