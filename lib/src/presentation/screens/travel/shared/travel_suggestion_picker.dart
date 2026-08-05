import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';

import '../core/models/travel_models.dart';
import 'travel_theme.dart';
import 'travel_widgets.dart';

class TravelSuggestionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final Color color;
  final TravelProductType type;

  const TravelSuggestionField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    required this.color,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final suggestion = await showModalBottomSheet<TravelSuggestion>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) =>
              _TravelSuggestionSheet(title: label, type: type, color: color),
        );
        if (suggestion != null) {
          controller.text = suggestion.value;
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: color),
        suffixIcon: const Icon(Icons.keyboard_arrow_down_rounded),
      ),
    );
  }
}

class _TravelSuggestionSheet extends StatefulWidget {
  final String title;
  final TravelProductType type;
  final Color color;

  const _TravelSuggestionSheet({
    required this.title,
    required this.type,
    required this.color,
  });

  @override
  State<_TravelSuggestionSheet> createState() => _TravelSuggestionSheetState();
}

class _TravelSuggestionSheetState extends State<_TravelSuggestionSheet> {
  final queryController = TextEditingController();
  Timer? debounce;
  bool isLoading = true;
  List<TravelSuggestion> suggestions = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    debounce?.cancel();
    queryController.dispose();
    super.dispose();
  }

  Future<void> _load([String query = '']) async {
    if (mounted) setState(() => isLoading = true);
    final values = await ensureTravelController().getSuggestions(
      widget.type,
      query: query,
      limit: 20,
    );
    if (!mounted) return;
    setState(() {
      suggestions = values;
      isLoading = false;
    });
  }

  void _search(String query) {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 300), () => _load(query));
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.78,
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: Navigator.of(context).pop,
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: queryController,
              autofocus: true,
              onChanged: _search,
              decoration: InputDecoration(
                hintText: widget.title,
                prefixIcon: Icon(Icons.search_rounded, color: widget.color),
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: widget.color),
                    )
                  : suggestions.isEmpty
                  ? TravelEmptyState(
                      message: localization.travelOfferUnavailable,
                    )
                  : ListView.separated(
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final suggestion = suggestions[index];
                        return ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 4.h,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: widget.color.withValues(
                              alpha: 0.1,
                            ),
                            child: Icon(
                              widget.type == TravelProductType.flight
                                  ? Icons.flight_takeoff_rounded
                                  : Icons.location_city_rounded,
                              color: widget.color,
                            ),
                          ),
                          title: TravelBidiText(
                            suggestion.title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          subtitle: suggestion.subtitle.isEmpty
                              ? null
                              : TravelBidiText(
                                  suggestion.subtitle,
                                  style: TextStyle(
                                    color: TravelTheme.muted,
                                    fontSize: 11.sp,
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
      ),
    );
  }
}
