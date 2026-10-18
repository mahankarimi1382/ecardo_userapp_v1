import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

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
    List<TravelSuggestion> values = [];
    try {
      values = await ensureTravelController().getSuggestions(
        widget.type,
        query: query,
        limit: 20,
      );
    } catch (_) {}

    if (values.isEmpty) {
      values = _getCuratedFallbackSuggestions(widget.type, query);
    }

    if (!mounted) return;
    setState(() {
      suggestions = values;
      isLoading = false;
    });
  }

  List<TravelSuggestion> _getCuratedFallbackSuggestions(
    TravelProductType type,
    String query,
  ) {
    final q = query.trim().toLowerCase();

    final all = switch (type) {
      TravelProductType.flight => const [
        TravelSuggestion(id: 'f-ika', value: 'IKA', title: 'تهران — فرودگاه امام خمینی', subtitle: 'IKA • Tehran Imam Khomeini, Iran', kind: 'airport'),
        TravelSuggestion(id: 'f-thr', value: 'THR', title: 'تهران — فرودگاه مهرآباد', subtitle: 'THR • Tehran Mehrabad, Iran', kind: 'airport'),
        TravelSuggestion(id: 'f-ist', value: 'IST', title: 'استانبول — فرودگاه اصلی', subtitle: 'IST • Istanbul Airport, Turkey', kind: 'airport'),
        TravelSuggestion(id: 'f-saw', value: 'SAW', title: 'استانبول — صبیحه گوکچن', subtitle: 'SAW • Sabiha Gokcen, Turkey', kind: 'airport'),
        TravelSuggestion(id: 'f-dxb', value: 'DXB', title: 'دبی — فرودگاه بین‌المللی', subtitle: 'DXB • Dubai International, UAE', kind: 'airport'),
        TravelSuggestion(id: 'f-kih', value: 'KIH', title: 'جزیره کیش — فرودگاه کیش', subtitle: 'KIH • Kish Island, Iran', kind: 'airport'),
        TravelSuggestion(id: 'f-mhd', value: 'MHD', title: 'مشهد — فرودگاه شهید هاشمی‌نژاد', subtitle: 'MHD • Mashhad International, Iran', kind: 'airport'),
        TravelSuggestion(id: 'f-syz', value: 'SYZ', title: 'شیراز — فرودگاه شهید دستغیب', subtitle: 'SYZ • Shiraz International, Iran', kind: 'airport'),
        TravelSuggestion(id: 'f-isf', value: 'ISF', title: 'اصفهان — فرودگاه شهید بهشتی', subtitle: 'ISF • Isfahan International, Iran', kind: 'airport'),
        TravelSuggestion(id: 'f-tbz', value: 'TBZ', title: 'تبریز — فرودگاه شهید مدنی', subtitle: 'TBZ • Tabriz International, Iran', kind: 'airport'),
        TravelSuggestion(id: 'f-doh', value: 'DOH', title: 'دوحه — فرودگاه بین‌المللی حمد', subtitle: 'DOH • Doha Hamad, Qatar', kind: 'airport'),
        TravelSuggestion(id: 'f-mct', value: 'MCT', title: 'مسقط — فرودگاه بین‌المللی مسقط', subtitle: 'MCT • Muscat International, Oman', kind: 'airport'),
        TravelSuggestion(id: 'f-njf', value: 'NJF', title: 'نجف اشرف — فرودگاه بین‌المللی', subtitle: 'NJF • Al Najaf International, Iraq', kind: 'airport'),
        TravelSuggestion(id: 'f-tbs', value: 'TBS', title: 'تفلیس — فرودگاه شوتا روستاولی', subtitle: 'TBS • Tbilisi International, Georgia', kind: 'airport'),
        TravelSuggestion(id: 'f-evn', value: 'EVN', title: 'ایروان — فرودگاه زوارتنوتس', subtitle: 'EVN • Yerevan Zvartnots, Armenia', kind: 'airport'),
        TravelSuggestion(id: 'f-lhr', value: 'LHR', title: 'لندن — فرودگاه هیترو', subtitle: 'LHR • London Heathrow, UK', kind: 'airport'),
        TravelSuggestion(id: 'f-cdg', value: 'CDG', title: 'پاریس — فرودگاه شارل دوگل', subtitle: 'CDG • Paris Charles de Gaulle, France', kind: 'airport'),
        TravelSuggestion(id: 'f-fra', value: 'FRA', title: 'فرانکفورت — فرودگاه راین‌ماین', subtitle: 'FRA • Frankfurt Airport, Germany', kind: 'airport'),
      ],
      TravelProductType.hotel => const [
        TravelSuggestion(id: 'h-teh', value: 'تهران', title: 'تهران (Tehran)', subtitle: 'پایتخت ایران • هتل‌های ۵ ستاره اسپیناس پالاس، آزادی، استقلال', kind: 'city'),
        TravelSuggestion(id: 'h-mhd', value: 'مشهد', title: 'مشهد (Mashhad)', subtitle: 'خراسان رضوی • هتل‌های قصر طلایی، درویشی، الماس، مدینه‌الرضا', kind: 'city'),
        TravelSuggestion(id: 'h-kih', value: 'کیش', title: 'جزیره کیش (Kish Island)', subtitle: 'خلیج فارس • هتل‌های ترنج دریایی، داریوش، مارینا پارک، شایان', kind: 'city'),
        TravelSuggestion(id: 'h-isf', value: 'اصفهان', title: 'اصفهان (Isfahan)', subtitle: 'نصف جهان • هتل تاریخی عباسی، کوثر، پیروزی', kind: 'city'),
        TravelSuggestion(id: 'h-syz', value: 'شیراز', title: 'شیراز (Shiraz)', subtitle: 'شهر بهارنارنج • هتل بزرگ شیراز، زندیه، چمران', kind: 'city'),
        TravelSuggestion(id: 'h-ist', value: 'استانبول', title: 'استانبول (Istanbul)', subtitle: 'ترکیه • هتل‌های چراغان کمپینسکی، تکسیم، شیشلی، بسفر', kind: 'city'),
        TravelSuggestion(id: 'h-dxb', value: 'دبی', title: 'دبی (Dubai)', subtitle: 'امارات • داون‌تاون، مارینا، پالم جمیرا، سیتی سنتر', kind: 'city'),
        TravelSuggestion(id: 'h-ayt', value: 'آنتالیا', title: 'آنتالیا (Antalya)', subtitle: 'سواحل مدیترانه • ریزورت‌های آل اینکلوسیو لارا و بلک', kind: 'city'),
        TravelSuggestion(id: 'h-tbz', value: 'تبریز', title: 'تبریز (Tabriz)', subtitle: 'آذربایجان شرقی • هتل کایا لاله پارک، پارس ائل‌گلی', kind: 'city'),
        TravelSuggestion(id: 'h-mct', value: 'مسقط', title: 'مسقط (Muscat)', subtitle: 'عمان • هتل‌های ساحلی شاطی القرم و مطرح', kind: 'city'),
      ],
      _ => const [
        TravelSuggestion(id: 'c-teh', value: 'تهران', title: 'تهران (Tehran)', subtitle: 'ایران', kind: 'city'),
        TravelSuggestion(id: 'c-ist', value: 'استانبول', title: 'استانبول (Istanbul)', subtitle: 'ترکیه', kind: 'city'),
        TravelSuggestion(id: 'c-dxb', value: 'دبی', title: 'دبی (Dubai)', subtitle: 'امارات متحده عربی', kind: 'city'),
        TravelSuggestion(id: 'c-kih', value: 'کیش', title: 'کیش (Kish)', subtitle: 'ایران', kind: 'city'),
        TravelSuggestion(id: 'c-mhd', value: 'مشهد', title: 'مشهد (Mashhad)', subtitle: 'ایران', kind: 'city'),
        TravelSuggestion(id: 'c-syz', value: 'شیراز', title: 'شیراز (Shiraz)', subtitle: 'ایران', kind: 'city'),
        TravelSuggestion(id: 'c-isf', value: 'اصفهان', title: 'اصفهان (Isfahan)', subtitle: 'ایران', kind: 'city'),
      ],
    };

    if (q.isEmpty) return all;
    return all.where((item) {
      return item.value.toLowerCase().contains(q) ||
          item.title.toLowerCase().contains(q) ||
          item.subtitle.toLowerCase().contains(q);
    }).toList();
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
      decoration: BoxDecoration(
        color: TravelTheme.cardSurfaceFor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
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
                      color: TravelTheme.textPrimaryFor(context),
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
                  ? const TravelShimmerLoading(type: TravelShimmerType.tile, count: 5)
                  : suggestions.isEmpty
                  ? TravelEmptyState(
                      message: localization.travelOfferUnavailable,
                    )
                  : ListView.separated(
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: TravelTheme.borderFor(context),
                      ),
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
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: TravelTheme.textPrimaryFor(context),
                            ),
                          ),
                          subtitle: suggestion.subtitle.isEmpty
                              ? null
                              : TravelBidiText(
                                  suggestion.subtitle,
                                  style: TextStyle(
                                    color: TravelTheme.textSecondaryFor(context),
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
