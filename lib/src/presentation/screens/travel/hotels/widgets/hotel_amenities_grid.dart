import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import '../../shared/travel_theme.dart';

/// Data model representing a hotel amenity item with icon, label, and category.
class HotelAmenityItem {
  final String key;
  final String labelEn;
  final String labelFa;
  final IconData icon;
  final String categoryEn;
  final String categoryFa;
  final String tagEn;
  final String tagFa;

  const HotelAmenityItem({
    required this.key,
    required this.labelEn,
    required this.labelFa,
    required this.icon,
    required this.categoryEn,
    required this.categoryFa,
    this.tagEn = 'Included',
    this.tagFa = 'شامل',
  });

  String localizedLabel(bool isRtl) => isRtl ? labelFa : labelEn;
  String localizedCategory(bool isRtl) => isRtl ? categoryFa : categoryEn;
  String localizedTag(bool isRtl) => isRtl ? tagFa : tagEn;
}

/// Clean visual grid of hotel facilities and amenities with top highlights
/// and an expandable modal bottom sheet / accordion for all facilities.
class HotelAmenitiesGrid extends StatefulWidget {
  final List<String> amenities;
  final int initialItemCount;
  final bool enableBottomSheet;

  const HotelAmenitiesGrid({
    super.key,
    this.amenities = const [],
    this.initialItemCount = 8,
    this.enableBottomSheet = true,
  });

  @override
  State<HotelAmenitiesGrid> createState() => _HotelAmenitiesGridState();
}

class _HotelAmenitiesGridState extends State<HotelAmenitiesGrid> {
  bool _isAccordionExpanded = false;

  /// Top 10 Core Required Hotel Amenities
  static const List<HotelAmenityItem> coreAmenities = [
    HotelAmenityItem(
      key: 'wifi',
      labelEn: 'High-Speed WiFi',
      labelFa: 'اینترنت پرسرعت رایگان',
      icon: Icons.wifi_rounded,
      categoryEn: 'Connectivity',
      categoryFa: 'ارتباطات و اینترنت',
      tagEn: 'Free',
      tagFa: 'رایگان',
    ),
    HotelAmenityItem(
      key: 'pool',
      labelEn: 'Swimming Pool',
      labelFa: 'استخر سرپوشیده و روباز',
      icon: Icons.pool_rounded,
      categoryEn: 'Wellness & Spa',
      categoryFa: 'سلامت و اسپا',
      tagEn: 'Heated',
      tagFa: 'آب گرم',
    ),
    HotelAmenityItem(
      key: 'gym',
      labelEn: 'Fitness Center / Gym',
      labelFa: 'باشگاه بدنسازی و فیتنس',
      icon: Icons.fitness_center_rounded,
      categoryEn: 'Wellness & Spa',
      categoryFa: 'سلامت و اسپا',
      tagEn: '24/7 Access',
      tagFa: '۲۴ ساعته',
    ),
    HotelAmenityItem(
      key: 'spa',
      labelEn: 'Spa & Wellness',
      labelFa: 'مرکز اسپا، سونا و ماساژ',
      icon: Icons.spa_rounded,
      categoryEn: 'Wellness & Spa',
      categoryFa: 'سلامت و اسپا',
      tagEn: 'Available',
      tagFa: 'در دسترس',
    ),
    HotelAmenityItem(
      key: 'shuttle',
      labelEn: 'Free Airport Shuttle',
      labelFa: 'ترانسفر رایگان فرودگاهی',
      icon: Icons.airport_shuttle_rounded,
      categoryEn: 'Transportation',
      categoryFa: 'حمل‌ونقل',
      tagEn: 'On Demand',
      tagFa: 'با هماهنگی',
    ),
    HotelAmenityItem(
      key: 'restaurant',
      labelEn: 'Restaurant & Bar',
      labelFa: 'رستوران بین‌المللی و کافی‌شاپ',
      icon: Icons.restaurant_rounded,
      categoryEn: 'Dining & Drinks',
      categoryFa: 'غذا و نوشیدنی',
      tagEn: 'Multi-cuisine',
      tagFa: 'منوی ویژه',
    ),
    HotelAmenityItem(
      key: 'front_desk',
      labelEn: '24/7 Front Desk',
      labelFa: 'پذیرش ۲۴ ساعته',
      icon: Icons.support_agent_rounded,
      categoryEn: 'Services',
      categoryFa: 'خدمات هتل',
      tagEn: '24/7',
      tagFa: 'شبانه روزی',
    ),
    HotelAmenityItem(
      key: 'valet_parking',
      labelEn: 'Valet Parking',
      labelFa: 'پارکینگ اختصاصی و ولت',
      icon: Icons.local_parking_rounded,
      categoryEn: 'Transportation',
      categoryFa: 'حمل‌ونقل',
      tagEn: 'Secured',
      tagFa: 'امن',
    ),
    HotelAmenityItem(
      key: 'pet_friendly',
      labelEn: 'Pet Friendly',
      labelFa: 'امکان ورود حیوانات خانگی',
      icon: Icons.pets_rounded,
      categoryEn: 'Policies',
      categoryFa: 'قوانین و تسهیلات',
      tagEn: 'Allowed',
      tagFa: 'مجاز',
    ),
    HotelAmenityItem(
      key: 'business_center',
      labelEn: 'Business Center',
      labelFa: 'مرکز تجارت و اتاق جلسات',
      icon: Icons.business_center_rounded,
      categoryEn: 'Connectivity',
      categoryFa: 'ارتباطات و اینترنت',
      tagEn: 'Equipped',
      tagFa: 'مجهز',
    ),
  ];

  /// Comprehensive catalog of extended facilities for bottom sheet categorization
  static const List<HotelAmenityItem> extendedAmenities = [
    ...coreAmenities,
    HotelAmenityItem(
      key: 'ac',
      labelEn: 'Air Conditioning',
      labelFa: 'سیستم تهویه مطبوع مرکزی',
      icon: Icons.ac_unit_rounded,
      categoryEn: 'Room Features',
      categoryFa: 'امکانات اتاق',
    ),
    HotelAmenityItem(
      key: 'room_service',
      labelEn: '24-Hour Room Service',
      labelFa: 'روم‌سرویس ۲۴ ساعته',
      icon: Icons.room_service_rounded,
      categoryEn: 'Dining & Drinks',
      categoryFa: 'غذا و نوشیدنی',
    ),
    HotelAmenityItem(
      key: 'breakfast_buffet',
      labelEn: 'Buffet Breakfast',
      labelFa: 'بوفه صبحانه گرم و سرد',
      icon: Icons.bakery_dining_rounded,
      categoryEn: 'Dining & Drinks',
      categoryFa: 'غذا و نوشیدنی',
    ),
    HotelAmenityItem(
      key: 'concierge',
      labelEn: 'Concierge Service',
      labelFa: 'خدمات کانسیرج و راهنمای تور',
      icon: Icons.person_pin_circle_rounded,
      categoryEn: 'Services',
      categoryFa: 'خدمات هتل',
    ),
    HotelAmenityItem(
      key: 'luggage',
      labelEn: 'Luggage Storage',
      labelFa: 'انبار چمدان امن',
      icon: Icons.luggage_rounded,
      categoryEn: 'Services',
      categoryFa: 'خدمات هتل',
    ),
    HotelAmenityItem(
      key: 'elevator',
      labelEn: 'Elevator / Lift',
      labelFa: 'آسانسور سریع‌السیر',
      icon: Icons.elevator_rounded,
      categoryEn: 'Room Features',
      categoryFa: 'امکانات اتاق',
    ),
    HotelAmenityItem(
      key: 'safe',
      labelEn: 'In-Room Safe',
      labelFa: 'صندوق امانات الکترونیکی',
      icon: Icons.lock_outline_rounded,
      categoryEn: 'Room Features',
      categoryFa: 'امکانات اتاق',
    ),
    HotelAmenityItem(
      key: 'dry_cleaning',
      labelEn: 'Dry Cleaning & Laundry',
      labelFa: 'خشکشویی و اتوشویی',
      icon: Icons.local_laundry_service_rounded,
      categoryEn: 'Services',
      categoryFa: 'خدمات هتل',
    ),
  ];

  List<HotelAmenityItem> _resolveAmenities() {
    if (widget.amenities.isEmpty) {
      return coreAmenities;
    }

    final matched = <HotelAmenityItem>[];

    for (final raw in widget.amenities) {
      final rawLower = raw.toLowerCase().trim();
      final item = extendedAmenities.firstWhere(
        (amenity) =>
            amenity.key == rawLower ||
            amenity.labelEn.toLowerCase().contains(rawLower) ||
            rawLower.contains(amenity.labelEn.toLowerCase()) ||
            rawLower.contains(amenity.key) ||
            amenity.labelFa.contains(raw),
        orElse: () => _createDynamicAmenity(raw),
      );
      if (!matched.any((m) => m.key == item.key)) {
        matched.add(item);
      }
    }

    // Ensure core required amenities are represented if user didn't specify everything
    for (final core in coreAmenities) {
      if (!matched.any((m) => m.key == core.key)) {
        matched.add(core);
      }
    }

    return matched;
  }

  HotelAmenityItem _createDynamicAmenity(String raw) {
    final lower = raw.toLowerCase();
    IconData icon = Icons.check_circle_outline_rounded;
    String category = 'General';
    String categoryFa = 'عمومی';

    if (lower.contains('wifi') || lower.contains('internet')) {
      icon = Icons.wifi_rounded;
      category = 'Connectivity';
      categoryFa = 'ارتباطات';
    } else if (lower.contains('pool') || lower.contains('استخر')) {
      icon = Icons.pool_rounded;
      category = 'Wellness & Spa';
      categoryFa = 'سلامت و اسپا';
    } else if (lower.contains('gym') || lower.contains('fitness') || lower.contains('ورزش')) {
      icon = Icons.fitness_center_rounded;
      category = 'Wellness & Spa';
      categoryFa = 'سلامت و اسپا';
    } else if (lower.contains('food') || lower.contains('restaurant') || lower.contains('رستوران')) {
      icon = Icons.restaurant_rounded;
      category = 'Dining & Drinks';
      categoryFa = 'غذا و نوشیدنی';
    } else if (lower.contains('parking') || lower.contains('پارکینگ')) {
      icon = Icons.local_parking_rounded;
      category = 'Transportation';
      categoryFa = 'حمل‌ونقل';
    }

    return HotelAmenityItem(
      key: raw.hashCode.toString(),
      labelEn: raw,
      labelFa: raw,
      icon: icon,
      categoryEn: category,
      categoryFa: categoryFa,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final allAmenities = _resolveAmenities();
    final visibleCount = _isAccordionExpanded
        ? allAmenities.length
        : widget.initialItemCount.clamp(1, allAmenities.length);
    final displayedAmenities = allAmenities.take(visibleCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Responsive 2-Column Grid
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: displayedAmenities.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10.w,
            mainAxisSpacing: 10.h,
            mainAxisExtent: 92.h,
          ),
          itemBuilder: (context, index) {
            final amenity = displayedAmenities[index];
            return _buildAmenityTile(context, amenity, isRtl);
          },
        ),

        SizedBox(height: 12.h),

        // Action Buttons Row: "View All Amenities" modal bottom sheet / accordion toggle
        Row(
          children: [
            if (widget.enableBottomSheet)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showAllAmenitiesBottomSheet(context, allAmenities, isRtl),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: TravelTheme.primaryFor(context),
                    side: BorderSide(
                      color: TravelTheme.primaryFor(context).withValues(alpha: 0.35),
                      width: 1.2.w,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                  ),
                  icon: Icon(
                    Icons.apps_rounded,
                    size: 16.sp,
                    color: TravelTheme.primaryFor(context),
                  ),
                  label: Text(
                    isRtl
                        ? 'مشاهده تمام امکانات (${allAmenities.length})'
                        : 'View all amenities (${allAmenities.length})',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              )
            else
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isAccordionExpanded = !_isAccordionExpanded;
                  });
                },
                icon: Icon(
                  _isAccordionExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: TravelTheme.primaryFor(context),
                ),
                label: Text(
                  _isAccordionExpanded
                      ? (isRtl ? 'نمایش کمتر' : 'Show less')
                      : (isRtl
                          ? 'نمایش بیشتر (${allAmenities.length})'
                          : 'Show all (${allAmenities.length})'),
                  style: TextStyle(
                    color: TravelTheme.primaryFor(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildAmenityTile(BuildContext context, HotelAmenityItem amenity, bool isRtl) {
    final cardBg = TravelTheme.cardSurfaceFor(context);
    final borderColor = TravelTheme.borderFor(context);
    final brandColor = TravelTheme.primaryFor(context);
    final textPrimary = TravelTheme.textPrimaryFor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: borderColor.withValues(alpha: 0.7),
          width: 1.w,
        ),
        boxShadow: TravelTheme.shadowFor(context),
      ),
      child: Row(
        children: [
          // Circular Icon Container with subtle brand accent
          Container(
            width: 36.r,
            height: 36.r,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                amenity.icon,
                size: 18.sp,
                color: brandColor,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Amenity Label
          Expanded(
            child: Text(
              amenity.localizedLabel(isRtl),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                height: 1.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllAmenitiesBottomSheet(
    BuildContext context,
    List<HotelAmenityItem> items,
    bool isRtl,
  ) {
    // Group amenities by category
    final grouped = <String, List<HotelAmenityItem>>{};
    for (final item in items) {
      final category = item.localizedCategory(isRtl);
      grouped.putIfAbsent(category, () => []).add(item);
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        final isDark = TravelTheme.isDark(bottomSheetContext);
        final cardBg = TravelTheme.cardSurfaceFor(bottomSheetContext);
        final borderColor = TravelTheme.borderFor(bottomSheetContext);
        final brandColor = TravelTheme.primaryFor(bottomSheetContext);
        final textPrimary = TravelTheme.textPrimaryFor(bottomSheetContext);

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(bottomSheetContext).size.height * 0.82,
          ),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: Column(
            children: [
              // Drag Handle
              SizedBox(height: 10.h),
              Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              SizedBox(height: 14.h),

              // Bottom Sheet Title & Close Button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: brandColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.hotel_rounded,
                        size: 20.sp,
                        color: brandColor,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        isRtl
                            ? 'تمام امکانات و خدمات هتل'
                            : 'Hotel Facilities & Amenities',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.of(bottomSheetContext).pop(),
                    ),
                  ],
                ),
              ),

              Divider(color: borderColor, height: 16.h),

              // Grouped Amenity Sections List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                  itemCount: grouped.keys.length,
                  itemBuilder: (context, index) {
                    final category = grouped.keys.elementAt(index);
                    final categoryAmenities = grouped[category]!;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Category Header
                          Row(
                            children: [
                              Container(
                                width: 4.w,
                                height: 14.h,
                                decoration: BoxDecoration(
                                  color: brandColor,
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                category,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w800,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Amenities in this category
                          Container(
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: borderColor.withValues(alpha: 0.8),
                              ),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: categoryAmenities.length,
                              separatorBuilder: (_, _) => Divider(
                                color: borderColor.withValues(alpha: 0.6),
                                height: 1.h,
                              ),
                              itemBuilder: (context, itemIdx) {
                                final item = categoryAmenities[itemIdx];
                                return Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 14.w,
                                    vertical: 10.h,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(7.r),
                                        decoration: BoxDecoration(
                                          color: isDark ? AppColors.darkSurface : AppColors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: TravelTheme.shadowFor(context),
                                        ),
                                        child: Icon(
                                          item.icon,
                                          size: 18.sp,
                                          color: brandColor,
                                        ),
                                      ),
                                      SizedBox(width: 12.w),
                                      Expanded(
                                        child: Text(
                                          item.localizedLabel(isRtl),
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.w600,
                                            color: textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
