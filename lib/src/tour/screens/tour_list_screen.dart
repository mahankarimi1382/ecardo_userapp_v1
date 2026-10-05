import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../controllers/tour_controller.dart';
import '../models/tour_model.dart';
import 'tour_detail_screen.dart';
import 'tour_match_screen.dart';
import 'tour_my_bookings_screen.dart';

class TourListScreen extends StatelessWidget {
  const TourListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TourController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categories = [
      {
        'code': '',
        'label_fa': 'همه تورها',
        'label_en': 'All Tours',
        'label_ar': 'جميع الرحلات',
        'label_zh': '全部行程',
      },
      {
        'code': 'nature',
        'label_fa': 'طبیعت‌گردی',
        'label_en': 'Nature',
        'label_ar': 'طبيعة ومغامرات',
        'label_zh': '自然风光',
      },
      {
        'code': 'cultural',
        'label_fa': 'فرهنگی و تاریخی',
        'label_en': 'Cultural',
        'label_ar': 'ثقافية وتاريخية',
        'label_zh': '历史文化',
      },
      {
        'code': 'beach',
        'label_fa': 'ساحلی و تفریحی',
        'label_en': 'Beach',
        'label_ar': 'شاطئية وترفيهية',
        'label_zh': '海滨度假',
      },
      {
        'code': 'luxury',
        'label_fa': 'لوکس و اختصاصی',
        'label_en': 'Luxury',
        'label_ar': 'فاخرة وخاصة',
        'label_zh': '奢华定制',
      },
      {
        'code': 'family',
        'label_fa': 'خانوادگی',
        'label_en': 'Family',
        'label_ar': 'عائلية',
        'label_zh': '家庭亲子',
      },
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          l10nPick(
            context,
            en: 'Tours & Travel Packages',
            fa: 'تورهای مسافرتی و پکیج‌ها',
            ar: 'الجولات السياحية والباقات',
            zh: '旅游线路与度假套餐',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            size: AppSpacing.iconSm.r,
          ),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            tooltip: l10nPick(
              context,
              en: 'My Bookings',
              fa: 'رزروهای من',
              ar: 'حجوزاتي',
              zh: '我的预订',
            ),
            icon: Icon(
              Icons.confirmation_number_outlined,
              color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.to(() => const TourMyBookingsScreen());
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadTours(refresh: true),
        color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
        child: ListView(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.lg.w,
            vertical: AppSpacing.md.h,
          ),
          children: [
            // Tour-Yar Smart AI Quiz Banner
            _TourYarBanner(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.to(() => const TourMatchScreen());
              },
            ),
            SizedBox(height: AppSpacing.md.h),

            // Category Horizontal Filter Chips
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, _) => SizedBox(width: AppSpacing.sm.w),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Obx(() {
                    final isSelected = controller.selectedCategory.value == cat['code'];
                    return FilterChip(
                      selected: isSelected,
                      label: Text(
                        l10nPick(context, en: cat['label_en']!, fa: cat['label_fa']!),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? AppColors.white
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
                      selectedColor: isDark ? AppColors.mutedBlue : TravelTheme.blue,
                      checkmarkColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                        side: BorderSide(
                          color: isSelected
                              ? (isDark ? AppColors.mutedBlue : TravelTheme.blue)
                              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      onSelected: (val) {
                        HapticFeedback.lightImpact();
                        controller.selectedCategory.value = cat['code']!;
                        controller.loadTours();
                      },
                    );
                  });
                },
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),

            // Tour List View (4 States)
            Obx(() {
              // 1. Loading Shimmer
              if (controller.isLoadingTours.value && controller.tours.isEmpty) {
                return _buildTourSkeleton(isDark);
              }

              // 2. Error / Unavailable State
              if (controller.isServiceUnavailable.value) {
                return Container(
                  margin: EdgeInsetsDirectional.only(top: AppSpacing.sm.h),
                  padding: EdgeInsetsDirectional.all(AppSpacing.xl.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                    border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.r),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.warning,
                          size: 40.r,
                        ),
                      ),
                      SizedBox(height: AppSpacing.md.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Tours Service Temporarily Unavailable',
                          fa: 'سرویس رزرو تور موقتاً در دسترس نیست',
                          ar: 'خدمة حجز الجولات غير متوفرة مؤقتاً',
                          zh: '旅游线路预订服务暂不可用',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'The tours catalog is undergoing partner integration. Please retry shortly.',
                          fa: 'سرویس جامع تورهای بین‌المللی در حال همگام‌سازی با درگاه‌های تأمین‌کننده است. لطفاً بعداً تلاش فرمایید.',
                          ar: 'خوادم الجولات السياحية قيد التحديث مع الشركاء. يرجى المحاولة لاحقاً.',
                          zh: '旅游线路服务接口正在与后台合作伙伴联调中，请稍后重试。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          fontSize: 11.5.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: AppSpacing.lg.h),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                          foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                          ),
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: AppSpacing.xl.w,
                            vertical: AppSpacing.sm.h,
                          ),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.loadTours(refresh: true);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Retry Connection',
                            fa: 'تلاش مجدد',
                            ar: 'إعادة المحاولة',
                            zh: '重试连接',
                          ),
                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // 3. Empty State
              if (controller.tours.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(AppSpacing.xl.r),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.explore_off_outlined,
                            size: 48.r,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          ),
                        ),
                        SizedBox(height: AppSpacing.md.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'No tours found in this category',
                            fa: 'توری با این مشخصات یافت نشد',
                            ar: 'لم يتم العثور على جولات سياحية',
                            zh: '未找到符合条件的旅游路线',
                          ),
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'Try selecting another category or take our smart quiz to find tours.',
                            fa: 'دسته‌بندی دیگری را انتخاب کنید یا با کوییز هوشمند تورهای متناسب را بیابید.',
                          ),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg.h),
                        OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            controller.selectedCategory.value = '';
                            controller.loadTours();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isDark ? AppColors.darkPrimary : TravelTheme.blue),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                          ),
                          child: Text(
                            l10nPick(context, en: 'View All Tours', fa: 'مشاهده همه تورها'),
                            style: TextStyle(
                              color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 4. Content State
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.tours.length,
                separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                itemBuilder: (context, index) {
                  final tour = controller.tours[index];
                  return _TourCard(
                    tour: tour,
                    isDark: isDark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      controller.loadTourDetail(tour.id);
                      Get.to(() => TourDetailScreen(tourId: tour.id));
                    },
                  );
                },
              );
            }),
            SizedBox(height: AppSpacing.xxxl.h),
          ],
        ),
      ),
    );
  }

  Widget _buildTourSkeleton(bool isDark) {
    final baseColor = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300;
    final highlightColor = isDark ? AppColors.darkSurface : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: EdgeInsets.only(bottom: AppSpacing.cardGap.h),
            height: 240.h,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
            ),
          ),
        ),
      ),
    );
  }
}

class _TourYarBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _TourYarBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF1E2E42), Color(0xFF2F80ED), Color(0xFF6C5CE7)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2F80ED).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.lg.r),
            child: Row(
              children: [
                Container(
                  width: 52.r,
                  height: 52.r,
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 26.r),
                ),
                SizedBox(width: AppSpacing.md.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                            ),
                            child: Text(
                              l10nPick(context, en: 'Smart Quiz', fa: 'کوییز هوشمند'),
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: AppColors.deepBlack),
                            ),
                          ),
                          SizedBox(width: AppSpacing.xs.w),
                          Flexible(
                            child: Text(
                              l10nPick(context, en: 'Tour-Yar Advisor', fa: 'تور-یار هوشمند eCardo'),
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.xs.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Answer 8 quick questions to find your personalized travel package',
                          fa: 'با ۸ سوال کوتاه، تور مسافرتی ایده‌آل روحیه و بودجه‌ات را کشف کن',
                        ),
                        style: TextStyle(fontSize: 11.sp, color: AppColors.white.withValues(alpha: 0.9), height: 1.35),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: AppColors.white, size: AppSpacing.iconXs.r),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Attractive tour package card with image, highlight badges,
/// departure chips, and starting price tag.
class _TourCard extends StatelessWidget {
  final TourModel tour;
  final bool isDark;
  final VoidCallback onTap;

  const _TourCard({
    required this.tour,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final nextDep = tour.departures.isNotEmpty ? tour.departures.first : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Image with Badges
            Stack(
              children: [
                SizedBox(
                  height: 165.h,
                  width: double.infinity,
                  child: tour.featuredImage != null && tour.featuredImage!.startsWith('http')
                      ? Image.network(
                          tour.featuredImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _ImagePlaceholder(tour: tour, isDark: isDark),
                        )
                      : _ImagePlaceholder(tour: tour, isDark: isDark),
                ),
                // Location Badge
                PositionedDirectional(
                  top: 10.h,
                  start: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.amber, size: 14),
                        SizedBox(width: AppSpacing.xs.w),
                        Text(
                          '${tour.city} (${tour.countryCode})',
                          style: TextStyle(color: AppColors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                // Duration Pill
                PositionedDirectional(
                  top: 10.h,
                  end: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: TravelTheme.blue,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    ),
                    child: Text(
                      '${tour.durationDays} ${l10nPick(context, en: 'Days', fa: 'روز')} / ${tour.durationNights} ${l10nPick(context, en: 'Nights', fa: 'شب')}',
                      style: TextStyle(color: AppColors.white, fontSize: 10.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                // Match Percentage Badge if available
                if (tour.matchPercentage != null)
                  PositionedDirectional(
                    bottom: 10.h,
                    end: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                      ),
                      child: Text(
                        '${tour.matchPercentage}% ${l10nPick(context, en: 'Match', fa: 'تطابق')}',
                        style: TextStyle(color: AppColors.white, fontSize: 11.sp, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),

            // Tour Info & Package Highlights
            Padding(
              padding: EdgeInsets.all(AppSpacing.md.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    tour.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),

                  // Highlights row
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 4.h,
                    children: [
                      // Rating Pill
                      _buildHighlightPill(
                        isDark: isDark,
                        icon: Icons.star_rounded,
                        iconColor: Colors.amber,
                        text: '${tour.ratingAvg.toStringAsFixed(1)} (${tour.ratingCount})',
                      ),
                      // Hotel tier pill
                      if (tour.hotelTiers.contains('LUX'))
                        _buildHighlightPill(
                          isDark: isDark,
                          icon: Icons.hotel_rounded,
                          iconColor: TravelTheme.blue,
                          text: l10nPick(context, en: '5-Star Luxury', fa: 'اقامت ۵ ستاره'),
                        )
                      else
                        _buildHighlightPill(
                          isDark: isDark,
                          icon: Icons.hotel_rounded,
                          iconColor: TravelTheme.blue,
                          text: l10nPick(context, en: 'Standard Hotel', fa: 'هتل استاندارد'),
                        ),
                      // Deposit allowed pill
                      if (tour.depositAllowed)
                        _buildHighlightPill(
                          isDark: isDark,
                          icon: Icons.offline_bolt_rounded,
                          iconColor: AppColors.success,
                          text: '${tour.depositPercent.toInt()}% ${l10nPick(context, en: 'Deposit', fa: 'پیش‌پرداخت')}',
                        ),
                    ],
                  ),

                  SizedBox(height: AppSpacing.sm.h),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                  ),
                  SizedBox(height: AppSpacing.sm.h),

                  // Price and Next Departure
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, en: 'Starts from:', fa: 'شروع قیمت از:'),
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${_formatPrice(tour.basePrice)} ${tour.currency}',
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w900,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                      if (nextDep != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10nPick(context, en: 'Next Departure:', fa: 'حرکت بعدی:'),
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.calendar_month_outlined,
                                  size: 13.r,
                                  color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  nextDep.departDate,
                                  style: TextStyle(
                                    fontSize: 11.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHighlightPill({
    required bool isDark,
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.r, color: iconColor),
          SizedBox(width: 3.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final TourModel tour;
  final bool isDark;

  const _ImagePlaceholder({required this.tour, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDark ? AppColors.darkSurfaceVariant : Colors.blueGrey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.landscape_rounded,
              size: 44.r,
              color: isDark ? AppColors.darkTextSecondary : Colors.blueGrey.shade400,
            ),
            SizedBox(height: AppSpacing.xs.h),
            Text(
              tour.city,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextPrimary : Colors.blueGrey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
