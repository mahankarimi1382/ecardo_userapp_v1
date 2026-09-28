import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/mock_travel_data.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/service_form_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/travel_service_requests_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

/// Generic browse screen for the extra travel services (car rental, tours,
/// boats, food, ...) that run on the curated demo catalogs.
class CatalogServiceScreen extends StatefulWidget {
  final ExtraServiceConfig config;

  const CatalogServiceScreen({super.key, required this.config});

  @override
  State<CatalogServiceScreen> createState() => _CatalogServiceScreenState();
}

class _CatalogServiceScreenState extends State<CatalogServiceScreen> {
  final _queryController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final items = widget.config.items(localization);
    final query = _query.trim().toLowerCase();
    final filtered = query.isEmpty
        ? items
        : items
              .where(
                (item) =>
                    item.title.toLowerCase().contains(query) ||
                    item.subtitle.toLowerCase().contains(query),
              )
              .toList();

    return TravelPage(
      title: widget.config.title(localization),
      showTravelNavigation: false,
      trailing: IconButton(
        tooltip: localization.travelMyRequests,
        onPressed: () => Get.to(() => const TravelServiceRequestsScreen()),
        icon: const Icon(Icons.receipt_long_rounded),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            height: 140.h,
            padding: EdgeInsets.all(22.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: LinearGradient(
                colors: [widget.config.heroStart, widget.config.heroEnd],
              ),
            ),
            child: Stack(
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: Icon(
                    widget.config.icon,
                    size: 96.r,
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Text(
                    widget.config.heroTitle(localization),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          TextField(
            controller: _queryController,
            onChanged: (value) => setState(() => _query = value),
            decoration: InputDecoration(
              hintText: localization.travelSearchPlaceholder,
              prefixIcon: const Icon(Icons.search_rounded),
              border: const OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 14.h),
          if (filtered.isEmpty)
            TravelEmptyState(message: localization.travelCatalogNoResults)
          else
            ...filtered.map(
              (item) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _CatalogItemCard(
                  item: item,
                  priceUnit: widget.config.priceUnit(localization),
                  onTap: () => Get.to(
                    () => CatalogServiceDetailScreen(
                      config: widget.config,
                      item: item,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CatalogItemCard extends StatelessWidget {
  final MockCatalogItem item;
  final String priceUnit;
  final VoidCallback onTap;

  const _CatalogItemCard({
    required this.item,
    required this.priceUnit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return TravelCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: TravelTheme.blue.withValues(alpha: .10),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(item.icon, color: TravelTheme.blue, size: 26.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TravelBidiText(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3.h),
                TravelBidiText(
                  item.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: TravelTheme.muted, fontSize: 10.5.sp),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    if (item.rating.isNotEmpty) ...[
                      Icon(Icons.star_rounded, size: 15.r, color: TravelTheme.yellow),
                      SizedBox(width: 2.w),
                      Text(
                        item.rating,
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(width: 10.w),
                    ],
                    Text(
                      '${localization.travelStartingPrice}: ${formatMockAmount(item.price)} ${localization.travelMockCurrency} / $priceUnit',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                        color: TravelTheme.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left_rounded, color: TravelTheme.muted, size: 26.r),
        ],
      ),
    );
  }
}

class CatalogServiceDetailScreen extends StatelessWidget {
  final ExtraServiceConfig config;
  final MockCatalogItem item;

  const CatalogServiceDetailScreen({
    super.key,
    required this.config,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final rows = config.detailRows?.call(item, localization) ?? const [];
    final amountLabel =
        '${formatMockAmount(item.price)} ${localization.travelMockCurrency} / '
        '${config.priceUnit(localization)}';
    return TravelPage(
      title: config.title(localization),
      showTravelNavigation: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: CommonButton(
            width: double.infinity,
            text: localization.travelCatalogRequest,
            backgroundColor: config.heroEnd,
            onPressed: () => Get.to(
              () => TravelServiceFormScreen(
                serviceKey: config.key,
                title: config.title(localization),
                itemTitle: item.title,
                itemSubtitle: item.subtitle,
                amountLabel: amountLabel,
                fields: config.formFields(item, localization),
              ),
            ),
          ),
        ),
      ),
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          TravelCard(
            color: config.heroEnd.withValues(alpha: .08),
            child: Row(
              children: [
                Container(
                  width: 60.r,
                  height: 60.r,
                  decoration: BoxDecoration(
                    color: config.heroEnd.withValues(alpha: .14),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Icon(item.icon, color: config.heroEnd, size: 30.r),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TravelBidiText(
                        item.title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      TravelBidiText(
                        item.subtitle,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          TravelJourneyGuide(
            currentStep: 1,
            steps: [
              localization.travelJourneySearch,
              localization.travelJourneyReview,
              localization.travelJourneyPay,
            ],
            message: localization.travelExtraUnderReviewNote,
          ),
          SizedBox(height: 20.h),
          TravelSectionHeader(title: localization.travelCatalogDetails),
          SizedBox(height: 10.h),
          TravelCard(
            child: Column(
              children: [
                _detailRow(
                  localization.travelStartingPrice,
                  '${formatMockAmount(item.price)} ${localization.travelMockCurrency} / '
                  '${config.priceUnit(localization)}',
                ),
                if (item.rating.isNotEmpty) ...[
                  Divider(color: TravelTheme.border),
                  _detailRow(localization.travelCatalogRating, item.rating),
                ],
                ...rows.map(
                  (row) => Column(
                    children: [
                      Divider(color: TravelTheme.border),
                      _detailRow(row.key, row.value),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: TravelTheme.muted, fontSize: 12.sp)),
          ),
          Expanded(
            flex: 3,
            child: TravelBidiText(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
