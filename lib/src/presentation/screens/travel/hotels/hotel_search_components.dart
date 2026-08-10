import 'dart:async';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

String hotelFlowText(BuildContext context, String fa, String en) {
  return Localizations.localeOf(context).languageCode == 'fa' ? fa : en;
}

Future<TravelSuggestion?> showHotelDestinationPicker(
  BuildContext context, {
  String initialQuery = '',
}) {
  return Navigator.of(context).push<TravelSuggestion>(
    MaterialPageRoute(
      builder: (_) => HotelDestinationScreen(initialQuery: initialQuery),
    ),
  );
}

class HotelDestinationScreen extends StatefulWidget {
  final String initialQuery;

  const HotelDestinationScreen({super.key, this.initialQuery = ''});

  @override
  State<HotelDestinationScreen> createState() => _HotelDestinationScreenState();
}

class _HotelDestinationScreenState extends State<HotelDestinationScreen> {
  static const pageSize = 12;
  final queryController = TextEditingController();
  final scrollController = ScrollController();
  Timer? debounce;
  List<TravelSuggestion> suggestions = const [];
  bool loading = true;
  int visibleCount = pageSize;

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

  @override
  Widget build(BuildContext context) {
    final visible = suggestions.take(visibleCount).toList();
    return TravelPage(
      title: hotelFlowText(
        context,
        'شهر یا هتل مقصد',
        'Destination city or hotel',
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
            child: TextField(
              controller: queryController,
              autofocus: true,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: hotelFlowText(
                  context,
                  'نام شهر یا هتل را جستجو کنید',
                  'Search by city or hotel name',
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: TravelTheme.purple,
                ),
                suffixIcon: queryController.text.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          queryController.clear();
                          _load();
                        },
                        icon: const Icon(Icons.close_rounded),
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
                    ? hotelFlowText(
                        context,
                        'همه شهرهای دارای هتل',
                        'All cities with hotels',
                      )
                    : hotelFlowText(context, 'نتایج جستجو', 'Search results'),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : visible.isEmpty
                ? TravelEmptyState(
                    message: hotelFlowText(
                      context,
                      'شهر یا هتلی با این نام پیدا نشد.',
                      'No matching city or hotel was found.',
                    ),
                  )
                : ListView.separated(
                    controller: scrollController,
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 28.h),
                    itemCount:
                        visible.length +
                        (visible.length < suggestions.length ? 1 : 0),
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      if (index == visible.length) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final suggestion = visible[index];
                      final hotelCount = int.tryParse(
                        suggestion.metadata['property_count']?.toString() ?? '',
                      );
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(vertical: 5.h),
                        leading: CircleAvatar(
                          backgroundColor: TravelTheme.purple.withValues(
                            alpha: .1,
                          ),
                          child: Icon(
                            suggestion.kind == 'hotel'
                                ? Icons.hotel_rounded
                                : Icons.location_city_rounded,
                            color: TravelTheme.purple,
                          ),
                        ),
                        title: TravelBidiText(
                          suggestion.title,
                          style: const TextStyle(fontWeight: FontWeight.w900),
                        ),
                        subtitle: hotelCount == null
                            ? (suggestion.subtitle.isEmpty
                                  ? null
                                  : TravelBidiText(suggestion.subtitle))
                            : Text(
                                hotelFlowText(
                                  context,
                                  '$hotelCount هتل',
                                  '$hotelCount hotels',
                                ),
                              ),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => Navigator.of(context).pop(suggestion),
                      );
                    },
                  ),
          ),
        ],
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
    return TravelPage(
      title: hotelFlowText(context, 'انتخاب تاریخ اقامت', 'Select stay dates'),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: FilledButton(
            onPressed: start != null && end != null && end.isAfter(start)
                ? () => Navigator.of(
                    context,
                  ).pop(DateTimeRange(start: start, end: end))
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: TravelTheme.purple,
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(
              hotelFlowText(context, 'تأیید تاریخ‌ها', 'Confirm dates'),
            ),
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
            child: TravelCard(
              child: Column(
                children: [
                  SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: Text(
                          hotelFlowText(context, 'تقویم شمسی', 'Persian'),
                        ),
                      ),
                      ButtonSegment(
                        value: false,
                        label: Text(
                          hotelFlowText(context, 'تقویم میلادی', 'Gregorian'),
                        ),
                      ),
                    ],
                    selected: {persianCalendar},
                    onSelectionChanged: (selection) =>
                        setState(() => persianCalendar = selection.first),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectedDateSummary(
                          label: hotelFlowText(
                            context,
                            'تاریخ ورود',
                            'Check-in',
                          ),
                          value: start == null ? '—' : _dateLabel(start),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_rounded),
                      Expanded(
                        child: _SelectedDateSummary(
                          label: hotelFlowText(
                            context,
                            'تاریخ خروج',
                            'Check-out',
                          ),
                          value: end == null ? '—' : _dateLabel(end),
                        ),
                      ),
                    ],
                  ),
                  if (start != null && end != null) ...[
                    SizedBox(height: 10.h),
                    Text(
                      hotelFlowText(
                        context,
                        '${end.difference(start).inDays} شب',
                        '${end.difference(start).inDays} nights',
                      ),
                      style: const TextStyle(
                        color: TravelTheme.purple,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Expanded(
            child: CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                calendarType: CalendarDatePicker2Type.range,
                calendarViewMode: CalendarDatePicker2Mode.scroll,
                firstDate: DateUtils.dateOnly(DateTime.now()),
                lastDate: DateTime.now().add(const Duration(days: 730)),
                selectedDayHighlightColor: TravelTheme.purple,
                selectedRangeHighlightColor: TravelTheme.purple.withValues(
                  alpha: .16,
                ),
                rangeBidirectional: true,
                centerAlignModePicker: true,
                controlsTextStyle: const TextStyle(fontWeight: FontWeight.w900),
              ),
              value: values,
              onValueChanged: (next) => setState(() => values = next),
            ),
          ),
        ],
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
          style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
        ),
        SizedBox(height: 4.h),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
