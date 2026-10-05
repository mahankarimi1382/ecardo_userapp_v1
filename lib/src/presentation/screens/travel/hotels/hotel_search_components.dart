import 'dart:async';
import 'dart:math' as math;

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamsi_date/shamsi_date.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/theme/ecardo_tokens.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_widgets.dart';

String hotelFlowText(BuildContext context, String fa, String en) {
  return Localizations.localeOf(context).languageCode == 'fa' ? fa : en;
}

/// Calculate distance in kilometers between two geographic coordinates using Haversine formula
double calculateDistanceKm(double lat1, double lon1, double lat2, double lon2) {
  const p = 0.017453292519943295; // math.pi / 180
  final a = 0.5 -
      math.cos((lat2 - lat1) * p) / 2 +
      math.cos(lat1 * p) *
          math.cos(lat2 * p) *
          (1 - math.cos((lon2 - lon1) * p)) /
          2;
  return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
}

/// Helper to format distance nicely (e.g. "1.4 km", "850 m")
String formatDistance(double km, BuildContext context) {
  final isRtl = Directionality.of(context) == TextDirection.rtl;
  if (km < 1.0) {
    final meters = (km * 1000).round();
    return isRtl ? '$meters متر' : '$meters m';
  }
  final kmStr = km.toStringAsFixed(1);
  return isRtl ? '$kmStr کیلومتر' : '$kmStr km';
}

Future<TravelSuggestion?> showHotelDestinationPicker(
  BuildContext context, {
  String initialQuery = '',
  double? referenceLat,
  double? referenceLng,
}) {
  return Navigator.of(context).push<TravelSuggestion>(
    MaterialPageRoute(
      builder: (_) => HotelDestinationScreen(
        initialQuery: initialQuery,
        referenceLat: referenceLat,
        referenceLng: referenceLng,
      ),
    ),
  );
}

class HotelDestinationScreen extends StatefulWidget {
  final String initialQuery;
  final double? referenceLat;
  final double? referenceLng;

  const HotelDestinationScreen({
    super.key,
    this.initialQuery = '',
    this.referenceLat,
    this.referenceLng,
  });

  @override
  State<HotelDestinationScreen> createState() => _HotelDestinationScreenState();
}

class _HotelDestinationScreenState extends State<HotelDestinationScreen> {
  static const pageSize = 15;
  final queryController = TextEditingController();
  final scrollController = ScrollController();
  Timer? debounce;
  List<TravelSuggestion> suggestions = const [];
  bool loading = true;
  int visibleCount = pageSize;

  // City center coordinates for prominent world travel destinations
  static const Map<String, List<double>> knownCityCenters = {
    'tehran': [35.6892, 51.3890],
    'dubai': [25.2048, 55.2708],
    'istanbul': [41.0082, 28.9784],
    'doha': [25.2854, 51.5310],
    'kish': [26.5325, 53.9783],
    'mashhad': [36.2972, 59.6067],
    'shiraz': [29.5918, 52.5837],
    'isfahan': [32.6546, 51.6680],
    'paris': [48.8566, 2.3522],
    'london': [51.5074, -0.1278],
    'rome': [41.9028, 12.4964],
    'tokyo': [35.6762, 139.6503],
    'bangkok': [13.7563, 100.5018],
    'tbilisi': [41.7151, 44.8271],
    'yerevan': [40.1792, 44.4991],
  };

  @override
  void initState() {
    super.initState();
    queryController.text = widget.initialQuery;
    scrollController.addListener(_onScroll);
    unawaited(_load());
  }

  @override
  void dispose() {
    debounce?.cancel();
    queryController.dispose();
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!scrollController.hasClients ||
        scrollController.position.extentAfter > 280 ||
        visibleCount >= suggestions.length) {
      return;
    }
    setState(() {
      visibleCount = (visibleCount + pageSize).clamp(0, suggestions.length);
    });
  }

  Future<void> _load() async {
    if (mounted) setState(() => loading = true);
    final values = await ensureTravelController().getSuggestions(
      TravelProductType.hotel,
      query: queryController.text.trim(),
      limit: 100,
    );
    if (!mounted) return;
    setState(() {
      suggestions = values;
      visibleCount = pageSize.clamp(0, values.length);
      loading = false;
    });
  }

  void _search(String _) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), _load);
  }

  double? _resolveDistance(TravelSuggestion suggestion) {
    final meta = suggestion.metadata;
    final direct = meta['distance_km'] ?? meta['distance'];
    if (direct != null && direct is num) return direct.toDouble();

    // Check lat/lng on suggestion
    final lat = (meta['latitude'] ?? meta['lat']) as num?;
    final lng = (meta['longitude'] ?? meta['lng']) as num?;

    if (lat != null && lng != null) {
      final refLat = widget.referenceLat ?? 35.6892;
      final refLng = widget.referenceLng ?? 51.3890;
      return calculateDistanceKm(
        lat.toDouble(),
        lng.toDouble(),
        refLat,
        refLng,
      );
    }

    // Try matching city name against known city centers
    final key = suggestion.title.toLowerCase().trim();
    for (final entry in knownCityCenters.entries) {
      if (key.contains(entry.key)) {
        final refLat = widget.referenceLat ?? 35.6892;
        final refLng = widget.referenceLng ?? 51.3890;
        return calculateDistanceKm(
          entry.value[0],
          entry.value[1],
          refLat,
          refLng,
        );
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final visible = suggestions.take(visibleCount).toList();
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return TravelPage(
      title: AppLocalizations.of(context)!.hotel_destination_city_or_hotel,
      child: Container(
        color: ECardoTokens.surfaceCanvas(context),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Container(
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusMd),
                  border: Border.all(color: ECardoTokens.border(context)),
                  boxShadow: ECardoTokens.shadowCard(context),
                ),
                child: TextField(
                  controller: queryController,
                  autofocus: true,
                  onChanged: _search,
                  style: TextStyle(
                    color: ECardoTokens.ink(context),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    border: InputBorder.none,
                    hintText: AppLocalizations.of(context)!
                        .hotel_search_by_city_or_hotel_name,
                    hintStyle: TextStyle(
                      color: ECardoTokens.inkMuted(context),
                      fontSize: 13.sp,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: ECardoTokens.brand500(context),
                      size: 22.sp,
                    ),
                    suffixIcon: queryController.text.isEmpty
                        ? null
                        : IconButton(
                            iconSize: 20.sp,
                            color: ECardoTokens.inkMuted(context),
                            onPressed: () {
                              queryController.clear();
                              _load();
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  queryController.text.trim().isEmpty
                      ? AppLocalizations.of(context)!.hotel_all_cities_with_hotels
                      : AppLocalizations.of(context)!.hotel_search_results,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13.sp,
                    color: ECardoTokens.ink(context),
                  ),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Expanded(
              child: loading
                  ? const TravelShimmerLoading(
                      type: TravelShimmerType.tile,
                      count: 6,
                    )
                  : visible.isEmpty
                      ? TravelEmptyState(
                          icon: Icons.location_city_rounded,
                          title: AppLocalizations.of(context)!
                              .hotel_no_matching_city_or_hotel_was_found,
                          message: AppLocalizations.of(context)!
                              .hotel_search_by_city_or_hotel_name,
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
                          itemCount: visible.length +
                              (visible.length < suggestions.length ? 1 : 0),
                          separatorBuilder: (_, _) => Divider(
                            height: 1,
                            color: ECardoTokens.border(context),
                          ),
                          itemBuilder: (context, index) {
                            if (index == visible.length) {
                              return Padding(
                                padding: EdgeInsets.all(20.r),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: ECardoTokens.brand500(context),
                                  ),
                                ),
                              );
                            }
                            final suggestion = visible[index];
                            final hotelCount = int.tryParse(
                              suggestion.metadata['property_count']
                                      ?.toString() ??
                                  '',
                            );
                            final distanceKm = _resolveDistance(suggestion);

                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                minVerticalPadding: 12.h,
                                contentPadding:
                                    EdgeInsets.symmetric(horizontal: 8.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    ECardoTokens.radiusMd,
                                  ),
                                ),
                                leading: Container(
                                  width: 44.r,
                                  height: 44.r,
                                  decoration: BoxDecoration(
                                    color: ECardoTokens.brand100(context),
                                    borderRadius: BorderRadius.circular(
                                      ECardoTokens.radiusMd,
                                    ),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      suggestion.kind == 'hotel'
                                          ? Icons.hotel_rounded
                                          : Icons.location_city_rounded,
                                      color: ECardoTokens.brand500(context),
                                      size: 22.sp,
                                    ),
                                  ),
                                ),
                                title: TravelBidiText(
                                  suggestion.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14.sp,
                                    color: ECardoTokens.ink(context),
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: EdgeInsets.only(top: 4.h),
                                  child: Row(
                                    children: [
                                      if (hotelCount != null) ...[
                                        Text(
                                          AppLocalizations.of(context)!
                                              .hotelHotelsCount(
                                            hotelCount.toString(),
                                          ),
                                          style: TextStyle(
                                            color: ECardoTokens.inkMuted(context),
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                        if (distanceKm != null)
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 6.w,
                                            ),
                                            child: Text(
                                              '•',
                                              style: TextStyle(
                                                color: ECardoTokens.inkMuted(
                                                  context,
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                      if (distanceKm != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6.w,
                                            vertical: 2.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ECardoTokens.surfaceSunken(
                                              context,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.r),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.near_me_rounded,
                                                size: 11.sp,
                                                color: ECardoTokens.brand500(
                                                  context,
                                                ),
                                              ),
                                              SizedBox(width: 3.w),
                                              Text(
                                                formatDistance(
                                                  distanceKm,
                                                  context,
                                                ),
                                                style: TextStyle(
                                                  color: ECardoTokens.ink(
                                                    context,
                                                  ),
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else if (suggestion.subtitle.isNotEmpty)
                                        Expanded(
                                          child: TravelBidiText(
                                            suggestion.subtitle,
                                            style: TextStyle(
                                              color: ECardoTokens.inkMuted(
                                                context,
                                              ),
                                              fontSize: 11.sp,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                trailing: Icon(
                                  isRtl
                                      ? Icons.chevron_left_rounded
                                      : Icons.chevron_right_rounded,
                                  color: ECardoTokens.inkMuted(context),
                                  size: 20.sp,
                                ),
                                onTap: () =>
                                    Navigator.of(context).pop(suggestion),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<DateTimeRange?> showHotelDateRangePicker(
  BuildContext context, {
  required DateTime initialStart,
  required DateTime initialEnd,
}) {
  return Navigator.of(context).push<DateTimeRange>(
    MaterialPageRoute(
      builder: (_) => HotelDateRangeScreen(
        initialStart: initialStart,
        initialEnd: initialEnd,
      ),
    ),
  );
}

class HotelDateRangeScreen extends StatefulWidget {
  final DateTime initialStart;
  final DateTime initialEnd;

  const HotelDateRangeScreen({
    super.key,
    required this.initialStart,
    required this.initialEnd,
  });

  @override
  State<HotelDateRangeScreen> createState() => _HotelDateRangeScreenState();
}

class _HotelDateRangeScreenState extends State<HotelDateRangeScreen> {
  late List<DateTime?> values;
  bool persianCalendar = true;

  @override
  void initState() {
    super.initState();
    values = [widget.initialStart, widget.initialEnd];
  }

  String _dateLabel(DateTime value) {
    if (!persianCalendar) {
      return '${value.year}/${value.month.toString().padLeft(2, '0')}/'
          '${value.day.toString().padLeft(2, '0')}';
    }
    final jalali = Jalali.fromDateTime(value);
    return '${jalali.year}/${jalali.month.toString().padLeft(2, '0')}/'
        '${jalali.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final start = values.whereType<DateTime>().firstOrNull;
    final end = values.whereType<DateTime>().length > 1
        ? values.whereType<DateTime>().elementAt(1)
        : null;

    final canConfirm = start != null && end != null && end.isAfter(start);

    return TravelPage(
      title: AppLocalizations.of(context)!.hotel_select_stay_dates,
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
              onPressed: canConfirm
                  ? () => Navigator.of(context).pop(
                        DateTimeRange(start: start, end: end),
                      )
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: canConfirm
                    ? ECardoTokens.brand900(context)
                    : ECardoTokens.surfaceSunken(context),
                foregroundColor: canConfirm
                    ? ECardoTokens.inkOnBrand
                    : ECardoTokens.inkMuted(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusLg),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.hotel_confirm_dates,
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
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: ECardoTokens.surfaceCard(context),
                  borderRadius: BorderRadius.circular(ECardoTokens.radiusXl),
                  border: Border.all(color: ECardoTokens.border(context)),
                  boxShadow: ECardoTokens.shadowCard(context),
                ),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: ECardoTokens.surfaceSunken(context),
                        borderRadius:
                            BorderRadius.circular(ECardoTokens.radiusMd),
                      ),
                      padding: EdgeInsets.all(4.r),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => persianCalendar = true),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: persianCalendar
                                      ? ECardoTokens.surfaceCard(context)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    ECardoTokens.radiusSm,
                                  ),
                                  boxShadow: persianCalendar
                                      ? ECardoTokens.shadowCard(context)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)!.hotel_persian,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: persianCalendar
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: persianCalendar
                                        ? ECardoTokens.brand700(context)
                                        : ECardoTokens.inkMuted(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => persianCalendar = false),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: !persianCalendar
                                      ? ECardoTokens.surfaceCard(context)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    ECardoTokens.radiusSm,
                                  ),
                                  boxShadow: !persianCalendar
                                      ? ECardoTokens.shadowCard(context)
                                      : null,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  AppLocalizations.of(context)!.hotel_gregorian,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: !persianCalendar
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    color: !persianCalendar
                                        ? ECardoTokens.brand700(context)
                                        : ECardoTokens.inkMuted(context),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Row(
                      children: [
                        Expanded(
                          child: _SelectedDateSummary(
                            label:
                                AppLocalizations.of(context)!.hotel_check_in,
                            value: start == null ? '—' : _dateLabel(start),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: ECardoTokens.brand100(context),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16.sp,
                            color: ECardoTokens.brand500(context),
                          ),
                        ),
                        Expanded(
                          child: _SelectedDateSummary(
                            label:
                                AppLocalizations.of(context)!.hotel_check_out,
                            value: end == null ? '—' : _dateLabel(end),
                          ),
                        ),
                      ],
                    ),
                    if (start != null && end != null) ...[
                      SizedBox(height: 10.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: ECardoTokens.brand100(context),
                          borderRadius: BorderRadius.circular(
                            ECardoTokens.radiusSm,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.hotelNightsCount(
                            end.difference(start).inDays,
                          ),
                          style: TextStyle(
                            color: ECardoTokens.brand700(context),
                            fontWeight: FontWeight.w900,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(context).colorScheme.copyWith(
                        primary: ECardoTokens.brand700(context),
                        surface: ECardoTokens.surfaceCard(context),
                      ),
                ),
                child: CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    calendarType: CalendarDatePicker2Type.range,
                    calendarViewMode: CalendarDatePicker2Mode.scroll,
                    firstDate: DateUtils.dateOnly(DateTime.now()),
                    lastDate: DateTime.now().add(const Duration(days: 730)),
                    selectedDayHighlightColor:
                        ECardoTokens.brand700(context),
                    selectedRangeHighlightColor:
                        ECardoTokens.brand100(context),
                    rangeBidirectional: true,
                    centerAlignModePicker: true,
                    controlsTextStyle: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: ECardoTokens.ink(context),
                    ),
                    dayTextStyle: TextStyle(
                      color: ECardoTokens.ink(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: values,
                  onValueChanged: (next) => setState(() => values = next),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedDateSummary extends StatelessWidget {
  final String label;
  final String value;

  const _SelectedDateSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: ECardoTokens.inkMuted(context),
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 13.sp,
              color: ECardoTokens.ink(context),
            ),
          ),
        ),
      ],
    );
  }
}
