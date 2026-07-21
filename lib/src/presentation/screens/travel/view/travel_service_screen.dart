import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/common_single_date_picker.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';

import '../controller/travel_controller.dart';
import '../model/travel_model.dart';
import 'travel_offer_screen.dart';
import 'widgets/travel_theme.dart';

class TravelServiceScreen extends StatefulWidget {
  final TravelServiceDefinition service;

  const TravelServiceScreen({super.key, required this.service});

  @override
  State<TravelServiceScreen> createState() => _TravelServiceScreenState();
}

class _TravelServiceScreenState extends State<TravelServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, dynamic> _values = {};
  late final TravelController _travel;
  String _tripType = 'round_trip';

  @override
  void initState() {
    super.initState();
    _travel = Get.find<TravelController>();
    for (final field in widget.service.searchFields) {
      _values[field.key] = field.defaultValue;
      _controllers[field.key] = TextEditingController(
        text: field.defaultValue?.toString() ?? '',
      );
    }
    _travel.offers.clear();
    _travel.facets.clear();
    _travel.errorMessage.value = '';
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TravelTheme.background,
        appBar: const CommonDefaultAppBar(
          backgroundColor: TravelTheme.background,
          surfaceTintColor: Colors.transparent,
        ),
        body: Obx(
          () => Stack(
            children: [
              Column(
                children: [
                  CommonAppBar(title: widget.service.displayName),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                      children: [
                        if (widget.service.searchLayout == 'flight')
                          _FlightHero(service: widget.service)
                        else if (widget.service.searchLayout == 'destination')
                          _DestinationHeader(service: widget.service)
                        else
                          _GenericHero(service: widget.service),
                        const SizedBox(height: 20),
                        if (widget.service.searchLayout == 'destination')
                          _DestinationContent(
                            service: widget.service,
                            onDestination: _applyDestination,
                          ),
                        Form(
                          key: _formKey,
                          child: _SearchCard(
                            service: widget.service,
                            tripType: _tripType,
                            onTripType: (value) =>
                                setState(() => _tripType = value),
                            fields: widget.service.searchFields
                                .map(_field)
                                .toList(),
                            isLoading: _travel.isSearchLoading.value,
                            onSubmit: _submit,
                          ),
                        ),
                        if (widget.service.searchLayout == 'flight') ...[
                          const SizedBox(height: 28),
                          _ContentSection(
                            title: 'مقاصد پیشنهادی',
                            items: widget.service.content(
                              'suggested_destinations',
                            ),
                            onTap: _applyDestination,
                          ),
                        ],
                        const SizedBox(height: 28),
                        _ResultsHeader(
                          visible:
                              _travel.offers.isNotEmpty ||
                              _travel.isSearchLoading.value,
                          count: _travel.offers.length,
                        ),
                        if (_travel.errorMessage.value.isNotEmpty)
                          _MessageCard(message: _travel.errorMessage.value),
                        if (!_travel.isSearchLoading.value &&
                            _travel.offers.isEmpty)
                          _SearchHint(service: widget.service),
                        ..._travel.offers.map(
                          (offer) => _OfferCard(
                            offer: offer,
                            service: widget.service,
                            onTap: () => Get.to(
                              () => TravelOfferScreen(
                                service: widget.service,
                                initialOffer: offer,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_travel.isSearchLoading.value)
                const Positioned.fill(child: CommonLoading(isColorShow: true)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TravelSearchField field) {
    if (field.type == 'date') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: CommonRequiredLabelAndDynamicField(
          labelText: field.label,
          isLabelRequired: field.required,
          dynamicField: CommonSingleDatePicker(
            hintText: field.hint.isNotEmpty ? field.hint : 'انتخاب تاریخ',
            fillColor: TravelTheme.field,
            isBorderShow: false,
            borderRadius: 14,
            suffixIcon: const Icon(
              Icons.calendar_month_rounded,
              color: TravelTheme.gold,
            ),
            initialDate: _initialDate(field),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 730)),
            datePattern: 'yyyy-MM-dd',
            onDateSelected: (date) {
              final value = DateFormat('yyyy-MM-dd').format(date);
              _values[field.key] = value;
              _controllers[field.key]!.text = value;
            },
          ),
        ),
      );
    }

    if (field.type == 'select' && field.options.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: CommonRequiredLabelAndDynamicField(
          labelText: field.label,
          isLabelRequired: field.required,
          dynamicField: CommonTextInputField(
            hintText: field.hint.isNotEmpty ? field.hint : 'انتخاب کنید',
            controller: _controllers[field.key],
            readOnly: true,
            isBorderShow: false,
            backgroundColor: TravelTheme.field,
            suffixIcon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: TravelTheme.gold,
            ),
            onTap: () => _showOptions(field),
            validator: (value) => field.required && (value?.isEmpty ?? true)
                ? 'این فیلد الزامی است.'
                : null,
          ),
        ),
      );
    }

    final numeric = field.type == 'integer';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: CommonRequiredLabelAndDynamicField(
        labelText: field.label,
        isLabelRequired: field.required,
        dynamicField: CommonTextInputField(
          controller: _controllers[field.key],
          hintText: field.hint.isNotEmpty ? field.hint : _hintFor(field.type),
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          backgroundColor: TravelTheme.field,
          isBorderShow: false,
          prefixIcon: Icon(_iconFor(field.type), color: TravelTheme.gold),
          validator: (value) {
            if (field.required && (value == null || value.trim().isEmpty)) {
              return 'این فیلد الزامی است.';
            }
            if (numeric &&
                value?.isNotEmpty == true &&
                int.tryParse(value!) == null) {
              return 'عدد معتبر وارد کنید.';
            }
            return null;
          },
        ),
      ),
    );
  }

  void _showOptions(TravelSearchField field) {
    final labels = field.options.map((option) => option.label).toList();
    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: field.label,
        isShowTitle: true,
        showSearch: labels.length > 8,
        notFoundText: 'گزینه‌ای پیدا نشد.',
        dropdownItems: labels,
        selectedItem: _controllers[field.key]!.text,
        textController: _controllers[field.key]!,
        currentlySelectedValue: _controllers[field.key]!.text,
        bottomSheetHeight: 460,
        onValueSelected: (label) {
          final option = field.options.firstWhere(
            (item) => item.label == label,
          );
          _values[field.key] = option.value;
          _controllers[field.key]!.text = option.label;
        },
      ),
    );
  }

  DateTime? _initialDate(TravelSearchField field) {
    final value = _values[field.key]?.toString();
    return value == null ? null : DateTime.tryParse(value);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final criteria = <String, dynamic>{};
    for (final field in widget.service.searchFields) {
      final raw = _values[field.key] ?? _controllers[field.key]?.text.trim();
      criteria[field.key] = field.type == 'integer'
          ? int.tryParse(raw?.toString() ?? '')
          : raw;
    }
    if (widget.service.key == 'flight') criteria['trip_type'] = _tripType;
    await _travel.search(widget.service, criteria);
  }

  void _applyDestination(TravelContentItem item) {
    final destination = widget.service.searchFields.firstWhereOrNull(
      (field) =>
          field.key == 'destination' ||
          field.key == 'country_code' ||
          field.type == 'country',
    );
    if (destination == null) return;
    final value = item.value.isNotEmpty ? item.value : item.title;
    _values[destination.key] = value;
    _controllers[destination.key]?.text = item.title;
    if (widget.service.searchLayout == 'destination') _submit();
  }

  IconData _iconFor(String type) => switch (type) {
    'location' => Icons.location_on_rounded,
    'airport' => Icons.flight_takeoff_rounded,
    'country' => Icons.public_rounded,
    'integer' => Icons.people_alt_rounded,
    _ => Icons.edit_rounded,
  };

  String _hintFor(String type) => switch (type) {
    'location' => 'نام شهر یا مقصد',
    'airport' => 'شهر یا کد فرودگاه',
    'country' => 'کشور مقصد',
    'integer' => 'تعداد',
    _ => 'وارد کنید',
  };
}

class _SearchCard extends StatelessWidget {
  final TravelServiceDefinition service;
  final String tripType;
  final ValueChanged<String> onTripType;
  final List<Widget> fields;
  final bool isLoading;
  final VoidCallback onSubmit;

  const _SearchCard({
    required this.service,
    required this.tripType,
    required this.onTripType,
    required this.fields,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: service.searchLayout == 'destination' ? 22 : 0,
      ),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TravelTheme.cardRadius,
        boxShadow: TravelTheme.cardShadow,
      ),
      child: Column(
        children: [
          if (service.searchLayout == 'flight') ...[
            _Segmented(
              value: tripType,
              onChanged: onTripType,
              options: const {
                'round_trip': 'رفت و برگشت',
                'one_way': 'یک‌طرفه',
                'multi_city': 'چند مسیره',
              },
            ),
            const SizedBox(height: 18),
          ],
          ...fields,
          CommonButton(
            width: double.infinity,
            height: 54,
            borderRadius: 999,
            text: service.key == 'flight'
                ? 'جستجوی پرواز'
                : service.key == 'esim'
                ? 'مشاهده بسته‌ها'
                : 'جستجو',
            isLoading: isLoading,
            backgroundColor: TravelTheme.navy,
            boxShadow: const [
              BoxShadow(
                color: Color(0x330F172A),
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _Segmented extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  final Map<String, String> options;

  const _Segmented({
    required this.value,
    required this.onChanged,
    required this.options,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TravelTheme.field,
        borderRadius: TravelTheme.pillRadius,
      ),
      child: Row(
        children: options.entries.map((entry) {
          final selected = entry.key == value;
          return Expanded(
            child: InkWell(
              onTap: () => onChanged(entry.key),
              borderRadius: TravelTheme.pillRadius,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected ? TravelTheme.goldSoft : Colors.transparent,
                  borderRadius: TravelTheme.pillRadius,
                ),
                child: Text(
                  entry.value,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: TravelTheme.navy,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FlightHero extends StatelessWidget {
  final TravelServiceDefinition service;

  const _FlightHero({required this.service});

  @override
  Widget build(BuildContext context) {
    return _ServiceHero(
      service: service,
      title: service.copy('hero_title', 'سفری به سبک برتر'),
      subtitle: service.copy(
        'hero_subtitle',
        'پروازهای داخلی و خارجی را یکجا مقایسه و انتخاب کنید.',
      ),
      icon: Icons.flight_takeoff_rounded,
    );
  }
}

class _GenericHero extends StatelessWidget {
  final TravelServiceDefinition service;

  const _GenericHero({required this.service});

  @override
  Widget build(BuildContext context) {
    return _ServiceHero(
      service: service,
      title: service.displayName,
      subtitle: service.description,
      icon: service.icon,
    );
  }
}

class _ServiceHero extends StatelessWidget {
  final TravelServiceDefinition service;
  final String title;
  final String subtitle;
  final IconData icon;

  const _ServiceHero({
    required this.service,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final image = service.presentation['hero_image_url']?.toString() ?? '';
    return Container(
      height: 205,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: TravelTheme.cardRadius,
        color: TravelTheme.navy,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (image.isNotEmpty)
            CachedNetworkImage(
              imageUrl: image,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => const SizedBox.shrink(),
            ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x220F172A), Color(0xE60F172A)],
              ),
            ),
          ),
          Positioned(
            right: 20,
            left: 20,
            bottom: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Color(0xFFE2E8F0),
                          fontSize: 12,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(icon, color: TravelTheme.goldSoft, size: 42),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DestinationHeader extends StatelessWidget {
  final TravelServiceDefinition service;

  const _DestinationHeader({required this.service});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          service.copy('hero_title', 'انتخاب مقصد'),
          style: const TextStyle(
            color: TravelTheme.navy,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          service.copy(
            'hero_subtitle',
            'اینترنت پرسرعت در هر کجای جهان، بدون سیم‌کارت فیزیکی.',
          ),
          style: const TextStyle(
            color: TravelTheme.muted,
            fontSize: 14,
            height: 1.7,
          ),
        ),
      ],
    );
  }
}

class _DestinationContent extends StatelessWidget {
  final TravelServiceDefinition service;
  final ValueChanged<TravelContentItem> onDestination;

  const _DestinationContent({
    required this.service,
    required this.onDestination,
  });

  @override
  Widget build(BuildContext context) {
    final benefits = service.content('benefits');
    final destinations = service.content('suggested_destinations');
    return Column(
      children: [
        if (benefits.isNotEmpty)
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: benefits.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final item = benefits[index];
                return Container(
                  width: 250,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: index == 0 ? TravelTheme.navy : TravelTheme.field,
                    borderRadius: TravelTheme.cardRadius,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        index == 0
                            ? Icons.bolt_rounded
                            : Icons.sim_card_download_rounded,
                        color: index == 0
                            ? TravelTheme.goldSoft
                            : TravelTheme.gold,
                        size: 34,
                      ),
                      const Spacer(),
                      Text(
                        item.title,
                        style: TextStyle(
                          color: index == 0 ? Colors.white : TravelTheme.navy,
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      Text(
                        item.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: index == 0
                              ? const Color(0xFFCBD5E1)
                              : TravelTheme.muted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        if (destinations.isNotEmpty) ...[
          const SizedBox(height: 26),
          _ContentSection(
            title: 'مناطق محبوب',
            items: destinations,
            onTap: onDestination,
          ),
        ],
      ],
    );
  }
}

class _ContentSection extends StatelessWidget {
  final String title;
  final List<TravelContentItem> items;
  final ValueChanged<TravelContentItem> onTap;

  const _ContentSection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: TravelTheme.navy,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, index) {
              final item = items[index];
              return InkWell(
                onTap: () => onTap(item),
                borderRadius: TravelTheme.cardRadius,
                child: Container(
                  width: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: TravelTheme.navy,
                    borderRadius: TravelTheme.cardRadius,
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (item.imageUrl.isNotEmpty)
                        CachedNetworkImage(
                          imageUrl: item.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Color(0xE60F172A)],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 13,
                        left: 13,
                        bottom: 13,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              item.subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFE2E8F0),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ResultsHeader extends StatelessWidget {
  final bool visible;
  final int count;

  const _ResultsHeader({required this.visible, required this.count});

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(
            'پیشنهادها ($count)',
            style: const TextStyle(
              color: TravelTheme.navy,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const Spacer(),
          const Icon(Icons.tune_rounded, color: TravelTheme.gold),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  final TravelOffer offer;
  final TravelServiceDefinition service;
  final VoidCallback onTap;

  const _OfferCard({
    required this.offer,
    required this.service,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (service.resultLayout == 'flight_cards') {
      return _FlightOfferCard(offer: offer, onTap: onTap);
    }
    if (service.resultLayout == 'esim_packages') {
      return _EsimOfferCard(offer: offer, onTap: onTap);
    }
    return _GenericOfferCard(offer: offer, onTap: onTap);
  }
}

class _FlightOfferCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;

  const _FlightOfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final from = _attribute(offer, ['origin', 'departure_airport'], 'مبدا');
    final to = _attribute(offer, ['destination', 'arrival_airport'], 'مقصد');
    final departure = _attribute(offer, [
      'departure_time',
      'depart_at',
    ], '--:--');
    final arrival = _attribute(offer, ['arrival_time', 'arrive_at'], '--:--');
    return _OfferSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OfferTitle(offer: offer),
          const SizedBox(height: 22),
          Row(
            children: [
              _RoutePoint(time: departure, code: from),
              const Expanded(
                child: Column(
                  children: [
                    Text(
                      'مستقیم',
                      style: TextStyle(color: TravelTheme.muted, fontSize: 10),
                    ),
                    Row(
                      children: [
                        Expanded(child: Divider(color: TravelTheme.line)),
                        Icon(Icons.flight_rounded, color: TravelTheme.navy),
                        Expanded(child: Divider(color: TravelTheme.line)),
                      ],
                    ),
                  ],
                ),
              ),
              _RoutePoint(time: arrival, code: to),
            ],
          ),
          const SizedBox(height: 18),
          const Divider(color: TravelTheme.line),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _Price(offer: offer)),
              SizedBox(
                width: 110,
                child: CommonButton(
                  height: 46,
                  borderRadius: 999,
                  text: 'انتخاب',
                  backgroundColor: TravelTheme.navy,
                  onPressed: onTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EsimOfferCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;

  const _EsimOfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final popular =
        offer.badge.isNotEmpty ||
        offer.attributes['popular'] == true ||
        offer.attributes['recommended'] == true;
    return InkWell(
      onTap: onTap,
      borderRadius: TravelTheme.cardRadius,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: TravelTheme.cardRadius,
          border: Border.all(
            color: popular ? TravelTheme.gold : TravelTheme.line,
            width: popular ? 2 : 1,
          ),
          boxShadow: TravelTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: popular ? TravelTheme.goldSoft : TravelTheme.field,
                shape: BoxShape.circle,
              ),
              child: Icon(
                popular
                    ? Icons.bolt_rounded
                    : Icons.signal_cellular_alt_rounded,
                color: TravelTheme.navy,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: const TextStyle(
                      color: TravelTheme.navy,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    offer.subtitle,
                    style: const TextStyle(
                      color: TravelTheme.muted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            _Price(offer: offer),
          ],
        ),
      ),
    );
  }
}

class _GenericOfferCard extends StatelessWidget {
  final TravelOffer offer;
  final VoidCallback onTap;

  const _GenericOfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: TravelTheme.cardRadius,
      child: _OfferSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _OfferTitle(offer: offer),
            if (offer.highlights.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: offer.highlights
                    .map(
                      (item) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: TravelTheme.field,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
            const SizedBox(height: 16),
            _Price(offer: offer),
          ],
        ),
      ),
    );
  }
}

class _OfferSurface extends StatelessWidget {
  final Widget child;

  const _OfferSurface({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TravelTheme.cardRadius,
        boxShadow: TravelTheme.cardShadow,
      ),
      child: child,
    );
  }
}

class _OfferTitle extends StatelessWidget {
  final TravelOffer offer;

  const _OfferTitle({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: TravelTheme.field,
            shape: BoxShape.circle,
          ),
          child: offer.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: offer.imageUrl,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.flight_rounded, color: TravelTheme.navy),
                )
              : Icon(
                  offer.service == 'flight'
                      ? Icons.flight_rounded
                      : Icons.travel_explore_rounded,
                  color: TravelTheme.navy,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                offer.title,
                style: const TextStyle(
                  color: TravelTheme.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (offer.subtitle.isNotEmpty)
                Text(
                  offer.subtitle,
                  style: const TextStyle(
                    color: TravelTheme.muted,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
        if (offer.badge.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(
              color: TravelTheme.goldSoft,
              borderRadius: TravelTheme.pillRadius,
            ),
            child: Text(
              offer.badge,
              style: const TextStyle(
                color: Color(0xFF745C00),
                fontSize: 9,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
      ],
    );
  }
}

class _RoutePoint extends StatelessWidget {
  final String time;
  final String code;

  const _RoutePoint({required this.time, required this.code});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          textDirection: ui.TextDirection.ltr,
          style: const TextStyle(
            color: TravelTheme.navy,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          code,
          textDirection: ui.TextDirection.ltr,
          style: const TextStyle(color: TravelTheme.muted, fontSize: 11),
        ),
      ],
    );
  }
}

class _Price extends StatelessWidget {
  final TravelOffer offer;

  const _Price({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${NumberFormat('#,###').format(offer.totalAmount)} ${offer.currency}',
      textDirection: ui.TextDirection.ltr,
      style: const TextStyle(
        color: Color(0xFF806600),
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _SearchHint extends StatelessWidget {
  final TravelServiceDefinition service;

  const _SearchHint({required this.service});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: TravelTheme.cardRadius,
      ),
      child: Column(
        children: [
          Icon(service.icon, color: TravelTheme.gold, size: 38),
          const SizedBox(height: 10),
          const Text(
            'اطلاعات جستجو را وارد کنید تا پیشنهادهای تامین‌کنندگان نمایش داده شوند.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TravelTheme.muted, height: 1.6),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final String message;

  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: TravelTheme.danger.withValues(alpha: 0.07),
        borderRadius: TravelTheme.cardRadius,
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: TravelTheme.danger, height: 1.6),
      ),
    );
  }
}

String _attribute(TravelOffer offer, List<String> keys, String fallback) {
  for (final key in keys) {
    final value = offer.attributes[key]?.toString();
    if (value?.isNotEmpty == true) return value!;
  }
  return fallback;
}
