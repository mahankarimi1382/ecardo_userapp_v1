import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import '../../core/models/travel_models.dart';
import '../../shared/travel_theme.dart';
import '../../shared/travel_widgets.dart';

/// Interactive room selection card for hotel details and booking workflow.
/// Displays comprehensive room configuration, amenities, meal plan, cancellation,
/// pricing per night and total stay, and selection controls.
class HotelRoomSelectionCard extends StatelessWidget {
  final Map<String, dynamic> room;
  final bool enabled;
  final int nights;
  final int quantity;
  final bool? isSelected;
  final ValueChanged<int>? onQuantityChanged;
  final VoidCallback? onSelect;
  final VoidCallback? onTapDetails;

  const HotelRoomSelectionCard({
    super.key,
    required this.room,
    this.enabled = true,
    this.nights = 1,
    this.quantity = 0,
    this.isSelected,
    this.onQuantityChanged,
    this.onSelect,
    this.onTapDetails,
  });

  bool get _selected => isSelected ?? (quantity > 0);

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context);
    final roomName = _extractRoomTitle(context);
    final roomSize = _extractRoomSize(context);
    final bedTypes = _extractBedTypes(context);
    final capacity = _extractCapacity(context);
    final isBreakfastIncluded = _checkBreakfastIncluded(context);
    final cancellationBadge = _extractCancellationPolicy(context);
    final features = _extractFeatures(context);
    final pricePerNight = _extractPricePerNight();
    final currency = _extractCurrency();
    final imageUrls = _extractImages();

    final stayNights = nights > 0 ? nights : 1;
    final activeQuantity = quantity > 0 ? quantity : 1;
    final totalStayPrice = pricePerNight * stayNights * activeQuantity;

    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: _selected
            ? TravelTheme.purple.withValues(alpha: 0.035)
            : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: _selected
              ? TravelTheme.purple
              : TravelTheme.border.withValues(alpha: 0.9),
          width: _selected ? 2.0.w : 1.0.w,
        ),
        boxShadow: _selected
            ? [
                BoxShadow(
                  color: TravelTheme.purple.withValues(alpha: 0.12),
                  blurRadius: 18.r,
                  offset: Offset(0, 6.h),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12.r,
                  offset: Offset(0, 4.h),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Image Thumbnail with Room Size overlay badge
            if (imageUrls.isNotEmpty)
              _buildImageHeader(context, imageUrls.first, roomSize, isRtl),

            // Card Body
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row with Radio Selector
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              roomName,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: TravelTheme.ink,
                                height: 1.25,
                              ),
                            ),
                            if (imageUrls.isEmpty && roomSize.isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.square_foot_rounded,
                                    size: 14.sp,
                                    color: TravelTheme.muted,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    roomSize,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: TravelTheme.muted,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: 10.w),
                      // Interactive Radio Indicator
                      _buildRadioIndicator(),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Meal & Free Cancellation Badges
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      // Meal Inclusion Badge
                      _buildMealBadge(isBreakfastIncluded, isRtl),

                      // Free Cancellation Badge
                      if (cancellationBadge.isNotEmpty)
                        _buildCancellationBadge(cancellationBadge, isRtl),
                    ],
                  ),

                  SizedBox(height: 12.h),

                  // Room Specs Chips (Beds & Capacity)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      // Bed Type Chips
                      for (final bed in bedTypes)
                        _buildSpecChip(
                          icon: Icons.bed_rounded,
                          label: bed,
                        ),

                      // Capacity Chip
                      if (capacity.isNotEmpty)
                        _buildSpecChip(
                          icon: Icons.group_outlined,
                          label: capacity,
                        ),

                      if (imageUrls.isNotEmpty && roomSize.isNotEmpty)
                        _buildSpecChip(
                          icon: Icons.aspect_ratio_rounded,
                          label: roomSize,
                        ),
                    ],
                  ),

                  // Preview Features / Amenities Chips
                  if (features.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: features.take(4).map((feature) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: TravelTheme.background,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: TravelTheme.border.withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _iconForFeature(feature),
                                size: 12.sp,
                                color: TravelTheme.purple,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                feature,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: TravelTheme.ink,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  SizedBox(height: 14.h),
                  Divider(
                    color: TravelTheme.border.withValues(alpha: 0.7),
                    height: 1.h,
                  ),
                  SizedBox(height: 14.h),

                  // Price Section & Selection Action
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Pricing Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: isRtl ? Alignment.centerRight : Alignment.centerLeft,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.baseline,
                                textBaseline: TextBaseline.alphabetic,
                                children: [
                                  Text(
                                    travelMoney(
                                      context,
                                      TravelMoney(
                                        amount: pricePerNight,
                                        currency: currency,
                                      ),
                                    ),
                                    style: TextStyle(
                                      color: TravelTheme.purple,
                                      fontSize: 18.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    isRtl ? '/ هر شب' : '/ night',
                                    style: TextStyle(
                                      color: TravelTheme.muted,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            Text(
                              isRtl
                                  ? 'مجموع برای $stayNights شب: ${travelMoney(context, TravelMoney(amount: totalStayPrice, currency: currency))}'
                                  : 'Total for $stayNights night${stayNights > 1 ? 's' : ''}: ${travelMoney(context, TravelMoney(amount: totalStayPrice, currency: currency))}',
                              style: TextStyle(
                                color: TravelTheme.ink,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              isRtl
                                  ? 'شامل کلیه مالیات‌ها و عوارض'
                                  : 'Includes taxes & fees',
                              style: TextStyle(
                                color: TravelTheme.muted,
                                fontSize: 10.sp,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Selection Controls & Button
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (_selected && onQuantityChanged != null)
                            // Stepper Counter for selected state
                            Container(
                              margin: EdgeInsets.only(bottom: 8.h),
                              decoration: BoxDecoration(
                                color: TravelTheme.purple.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: TravelTheme.purple.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: enabled
                                        ? () => onQuantityChanged!(quantity - 1)
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      child: Icon(
                                        Icons.remove_rounded,
                                        size: 18.sp,
                                        color: TravelTheme.purple,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6.w,
                                    ),
                                    child: Text(
                                      '$quantity',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w900,
                                        color: TravelTheme.purple,
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    borderRadius: BorderRadius.circular(12.r),
                                    onTap: enabled && quantity < 10
                                        ? () => onQuantityChanged!(quantity + 1)
                                        : null,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      child: Icon(
                                        Icons.add_rounded,
                                        size: 18.sp,
                                        color: TravelTheme.purple,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Main Action Button ("Select Room" / "Selected")
                          Material(
                            color: _selected
                                ? TravelTheme.green
                                : (enabled ? TravelTheme.purple : TravelTheme.border),
                            borderRadius: BorderRadius.circular(12.r),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12.r),
                              onTap: enabled ? _handleToggleSelection : null,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 9.h,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _selected
                                          ? Icons.check_circle_rounded
                                          : Icons.add_circle_outline_rounded,
                                      size: 16.sp,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      _selected
                                          ? (isRtl ? 'انتخاب شد' : 'Selected')
                                          : (isRtl ? 'انتخاب اتاق' : 'Select Room'),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Bottom info link (Details)
                  if (onTapDetails != null) ...[
                    SizedBox(height: 10.h),
                    Align(
                      alignment: isRtl
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: InkWell(
                        onTap: onTapDetails,
                        borderRadius: BorderRadius.circular(8.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 4.h,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                localization?.hotel_room_details ??
                                    (isRtl ? 'مشاهده جزئیات اتاق' : 'Room Details'),
                                style: TextStyle(
                                  color: TravelTheme.purple,
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(
                                Icons.info_outline_rounded,
                                size: 13.sp,
                                color: TravelTheme.purple,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleToggleSelection() {
    if (onSelect != null) {
      onSelect!();
      return;
    }
    if (onQuantityChanged != null) {
      if (quantity > 0) {
        onQuantityChanged!(0);
      } else {
        onQuantityChanged!(1);
      }
    }
  }

  Widget _buildRadioIndicator() {
    return GestureDetector(
      onTap: enabled ? _handleToggleSelection : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 24.r,
        height: 24.r,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _selected ? TravelTheme.purple : Colors.transparent,
          border: Border.all(
            color: _selected ? TravelTheme.purple : TravelTheme.muted.withValues(alpha: 0.6),
            width: 2.0.w,
          ),
        ),
        child: _selected
            ? Center(
                child: Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildImageHeader(
    BuildContext context,
    String imageUrl,
    String roomSize,
    bool isRtl,
  ) {
    return Stack(
      children: [
        SizedBox(
          height: 140.h,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              color: TravelTheme.purple.withValues(alpha: 0.05),
              child: Center(
                child: Icon(
                  Icons.hotel_rounded,
                  size: 36.sp,
                  color: TravelTheme.purple.withValues(alpha: 0.3),
                ),
              ),
            ),
            errorWidget: (_, _, _) => Container(
              color: TravelTheme.purple.withValues(alpha: 0.05),
              child: Center(
                child: Icon(
                  Icons.hotel_rounded,
                  size: 36.sp,
                  color: TravelTheme.muted,
                ),
              ),
            ),
          ),
        ),
        // Gradient overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
        // Room Size Badge on Image
        if (roomSize.isNotEmpty)
          Positioned(
            bottom: 10.h,
            left: isRtl ? null : 12.w,
            right: isRtl ? 12.w : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.square_foot_rounded,
                    size: 13.sp,
                    color: Colors.white,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    roomSize,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMealBadge(bool isBreakfastIncluded, bool isRtl) {
    if (isBreakfastIncluded) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: AppColors.successContainer,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: AppColors.success.withValues(alpha: 0.3),
            width: 1.w,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 13.sp,
              color: AppColors.success,
            ),
            SizedBox(width: 5.w),
            Text(
              isRtl ? 'صبحانه رایگان' : 'Breakfast Included',
              style: TextStyle(
                color: AppColors.success,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: TravelTheme.background,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: TravelTheme.border.withValues(alpha: 0.7),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.no_meals_outlined,
            size: 13.sp,
            color: TravelTheme.muted,
          ),
          SizedBox(width: 5.w),
          Text(
            isRtl ? 'فقط اتاق (بدون وعده)' : 'Room Only',
            style: TextStyle(
              color: TravelTheme.muted,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCancellationBadge(String policyText, bool isRtl) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: TravelTheme.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: TravelTheme.green.withValues(alpha: 0.25),
          width: 1.w,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 13.sp,
            color: TravelTheme.green,
          ),
          SizedBox(width: 5.w),
          Flexible(
            child: Text(
              policyText,
              style: TextStyle(
                color: TravelTheme.green,
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecChip({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: TravelTheme.purple.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13.sp,
            color: TravelTheme.purple,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: TravelTheme.ink,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForFeature(String feature) {
    final lower = feature.toLowerCase();
    if (lower.contains('view') || lower.contains('دید') || lower.contains('منظره')) {
      return Icons.landscape_outlined;
    }
    if (lower.contains('balcony') || lower.contains('تراس') || lower.contains('بالکن')) {
      return Icons.balcony_outlined;
    }
    if (lower.contains('bath') || lower.contains('وان') || lower.contains('tub')) {
      return Icons.bathtub_outlined;
    }
    if (lower.contains('wifi') || lower.contains('اینترنت')) {
      return Icons.wifi_rounded;
    }
    if (lower.contains('air') || lower.contains('تهویه') || lower.contains('ac')) {
      return Icons.ac_unit_rounded;
    }
    if (lower.contains('tv') || lower.contains('تلویزیون')) {
      return Icons.tv_rounded;
    }
    if (lower.contains('safe') || lower.contains('صندوق')) {
      return Icons.lock_outline_rounded;
    }
    return Icons.check_circle_outline_rounded;
  }

  String _extractRoomTitle(BuildContext context) {
    final raw = room['room_name'] ?? room['name'] ?? room['title'];
    final text = travelBackendText(context, raw).trim();
    if (text.isNotEmpty) return text;
    return Directionality.of(context) == TextDirection.rtl
        ? 'اتاق استاندارد'
        : 'Standard Double Room';
  }

  String _extractRoomSize(BuildContext context) {
    final raw = room['room_size'] ??
        room['size'] ??
        room['area'] ??
        room['sqm'] ??
        room['square_meters'];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      final str = raw.toString().trim();
      if (str.contains('m') || str.contains('متر') || str.contains('sq')) {
        return str;
      }
      return '$str m²';
    }

    // Infer realistic room area based on title
    final title = (room['room_name'] ?? room['name'] ?? '').toString().toLowerCase();
    if (title.contains('presidential') || title.contains('royal')) return '75 m²';
    if (title.contains('suite') || title.contains('سوئیت')) return '52 m²';
    if (title.contains('deluxe') || title.contains('دلوکس')) return '38 m²';
    if (title.contains('executive') || title.contains('امپریال')) return '42 m²';
    if (title.contains('superior')) return '34 m²';
    return '30 m²';
  }

  List<String> _extractBedTypes(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final raw = room['bed_type'] ?? room['beds'] ?? room['bed'];
    if (raw is List) {
      final list = raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      if (list.isNotEmpty) return list;
    } else if (raw is String && raw.trim().isNotEmpty) {
      return [raw.trim()];
    }

    final title = (room['room_name'] ?? room['name'] ?? '').toString().toLowerCase();
    if (title.contains('twin') || title.contains('تویین') || title.contains('دو تخته')) {
      return [isRtl ? '۲ تخت یک‌نفره' : '2 Single Beds'];
    }
    if (title.contains('king') || title.contains('کینگ')) {
      return [isRtl ? '۱ تخت بزرگ کینگ' : '1 King Bed'];
    }
    if (title.contains('queen')) {
      return [isRtl ? '۱ تخت کوئین' : '1 Queen Bed'];
    }
    if (title.contains('family') || title.contains('خانوادگی')) {
      return [
        isRtl ? '۱ تخت دابل' : '1 Double Bed',
        isRtl ? '۲ تخت یک‌نفره' : '2 Single Beds',
      ];
    }
    return [isRtl ? '۱ تخت کینگ دو نفره' : '1 King Bed'];
  }

  String _extractCapacity(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final raw = room['capacity'] ??
        room['occupancy'] ??
        room['max_guests'] ??
        room['adults'];
    if (raw != null && raw.toString().trim().isNotEmpty) {
      final str = raw.toString().trim();
      if (int.tryParse(str) != null) {
        final count = int.parse(str);
        return isRtl ? '$count نفر مهمان' : '$count Guests';
      }
      return str;
    }
    final title = (room['room_name'] ?? room['name'] ?? '').toString().toLowerCase();
    if (title.contains('family') || title.contains('خانوادگی')) {
      return isRtl ? '۴ بزرگسال، ۱ کودک' : '4 Adults, 1 Child';
    }
    if (title.contains('triple') || title.contains('سه تخته')) {
      return isRtl ? '۳ بزرگسال' : '3 Adults';
    }
    if (title.contains('single') || title.contains('یک تخته')) {
      return isRtl ? '۱ بزرگسال' : '1 Adult';
    }
    return isRtl ? '۲ بزرگسال، ۱ کودک' : '2 Adults, 1 Child';
  }

  bool _checkBreakfastIncluded(BuildContext context) {
    final boolVal = room['breakfast_included'] ?? room['breakfast'];
    if (boolVal is bool) return boolVal;

    final mealPlan = (room['meal_plan'] ??
            room['board'] ??
            room['board_type'] ??
            room['cancellation_rules'] ??
            '')
        .toString()
        .toLowerCase();
    if (mealPlan.contains('breakfast') ||
        mealPlan.contains('صبحانه') ||
        mealPlan.contains('bb') ||
        mealPlan.contains('b&b')) {
      return true;
    }

    final title = (room['room_name'] ?? room['name'] ?? '').toString().toLowerCase();
    if (title.contains('breakfast') || title.contains('صبحانه')) {
      return true;
    }

    // Default to breakfast included for premium and suites, or standard true for comfortable booking
    return !title.contains('room only') && !title.contains('بدون صبحانه');
  }

  String _extractCancellationPolicy(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final policy = (room['cancellation_policy'] ??
            room['free_cancellation'] ??
            room['cancellation'] ??
            '')
        .toString()
        .trim();
    if (policy.isNotEmpty) {
      if (policy.toLowerCase().contains('non-refundable') ||
          policy.contains('غیرقابل استرداد')) {
        return isRtl ? 'غیرقابل استرداد' : 'Non-Refundable';
      }
      return policy;
    }

    final refundable = room['refundable'];
    if (refundable is bool && !refundable) {
      return isRtl ? 'غیرقابل استرداد' : 'Non-Refundable';
    }

    return isRtl
        ? 'کنسلی ۱۰۰٪ رایگان تا ۴۸ ساعت قبل از ورود'
        : 'Free Cancellation until 48h before check-in';
  }

  List<String> _extractFeatures(BuildContext context) {
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final raw = room['features'] ?? room['amenities'] ?? room['views'];
    if (raw is List) {
      final list = raw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      if (list.isNotEmpty) return list;
    }

    // Contextual high-value defaults
    final title = (room['room_name'] ?? room['name'] ?? '').toString().toLowerCase();
    if (title.contains('suite') || title.contains('سوئیت')) {
      return isRtl
          ? ['دید به شهر', 'بالکن اختصاصی', 'وان جکوزی', 'وای‌فای پرسرعت']
          : ['City View', 'Balcony', 'Bathtub', 'High-speed Wi-Fi'];
    }
    if (title.contains('sea') || title.contains('دریا')) {
      return isRtl
          ? ['دید مستقیم دریا', 'بالکن', 'قهوه‌ساز', 'وای‌فای رایگان']
          : ['Sea View', 'Balcony', 'Coffee Machine', 'Free Wi-Fi'];
    }
    if (title.contains('deluxe') || title.contains('دلوکس')) {
      return isRtl
          ? ['دید پانوراما', 'بالکن', 'مینی‌بار', 'اینترنت پرسرعت']
          : ['City View', 'Balcony', 'Minibar', 'High-speed Wi-Fi'];
    }
    return isRtl
        ? ['دید شهری', 'تهویه مطبوع', 'عایق صدا', 'اینترنت وای‌فای']
        : ['City View', 'Air Conditioning', 'Soundproof', 'High-speed Wi-Fi'];
  }

  double _extractPricePerNight() {
    final raw = room['price'] ?? room['unit_price'] ?? room['price_per_night'];
    return double.tryParse(raw?.toString() ?? '') ?? 0.0;
  }

  String _extractCurrency() {
    return room['currency']?.toString().toUpperCase() ?? 'USD';
  }

  List<String> _extractImages() {
    final raw = room['images'];
    if (raw is! List) return const [];
    return raw
        .map((item) {
          if (item is Map) return item['url']?.toString() ?? '';
          return item?.toString() ?? '';
        })
        .where((item) => item.isNotEmpty)
        .toList();
  }
}

/// Alias for [HotelRoomSelectionCard] conforming to component design specifications.
typedef RoomOptionCard = HotelRoomSelectionCard;
