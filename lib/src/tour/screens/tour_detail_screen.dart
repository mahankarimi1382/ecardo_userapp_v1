import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_theme.dart';
import '../controllers/tour_controller.dart';
import '../models/tour_model.dart';
import 'tour_book_screen.dart';

class TourDetailScreen extends StatefulWidget {
  final int tourId;

  const TourDetailScreen({super.key, required this.tourId});

  @override
  State<TourDetailScreen> createState() => _TourDetailScreenState();
}

class _TourDetailScreenState extends State<TourDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TourController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Obx(() {
        if (controller.isLoadingDetail.value && controller.selectedTour.value == null) {
          return Center(
            child: CircularProgressIndicator(
              color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
            ),
          );
        }

        final tour = controller.selectedTour.value;
        if (tour == null) {
          return Center(
            child: Padding(
              padding: EdgeInsetsDirectional.all(AppSpacing.xxl.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpacing.lg.r),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_off_rounded,
                      color: AppColors.warning,
                      size: 48.r,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'Tour Details Temporarily Unavailable',
                      fa: 'جزئیات تور موقتاً در دسترس نیست',
                      ar: 'تفاصيل الرحلة غير متوفرة مؤقتاً',
                      zh: '旅游路线详情暂时不可用',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: AppSpacing.sm.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'The tours service is undergoing backend partner integration. Please retry shortly.',
                      fa: 'سرویس اطلاعات تور در حال به‌روزرسانی با درگاه تأمین‌کننده است.',
                      ar: 'خوادم تفاصيل الجولة قيد التحديث. يرجى المحاولة لاحقاً.',
                      zh: '路线详情接口正在联调中，请稍后重试。',
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppSpacing.lg.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => Get.back(),
                        icon: const Icon(Icons.arrow_back_rounded, size: 16),
                        label: Text(l10nPick(context, en: 'Back', fa: 'بازگشت')),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                        ),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                          foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.loadTourDetail(widget.tourId);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: Text(l10nPick(context, en: 'Retry', fa: 'تلاش مجدد')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 250.h,
                pinned: true,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
                leading: Container(
                  margin: EdgeInsets.all(AppSpacing.sm.r),
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.darkSurface : AppColors.white).withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      size: AppSpacing.iconSm.r,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      tour.featuredImage != null && tour.featuredImage!.startsWith('http')
                          ? Image.network(
                              tour.featuredImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(color: Colors.blueGrey.shade700),
                            )
                          : Container(color: Colors.blueGrey.shade700),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AppColors.deepBlack.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: AppSpacing.lg.h,
                        start: AppSpacing.lg.w,
                        end: AppSpacing.lg.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                  decoration: BoxDecoration(
                                    color: TravelTheme.blue,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                                  ),
                                  child: Text(
                                    '${tour.durationDays} ${l10nPick(context, en: 'Days', fa: 'روز')} / ${tour.durationNights} ${l10nPick(context, en: 'Nights', fa: 'شب')}',
                                    style: TextStyle(color: AppColors.white, fontSize: 10.5.sp, fontWeight: FontWeight.w800),
                                  ),
                                ),
                                SizedBox(width: AppSpacing.sm.w),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                    SizedBox(width: 3.w),
                                    Text(
                                      '${tour.ratingAvg}',
                                      style: TextStyle(color: AppColors.white, fontSize: 11.5.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.xs.h),
                            Text(
                              tour.title,
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    labelColor: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                    unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                    indicatorColor: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                    tabs: [
                      Tab(text: l10nPick(context, en: 'Itinerary Stepper', fa: 'برنامه سفر (استپر)')),
                      Tab(text: l10nPick(context, en: 'Hotels', fa: 'هتل‌ها و اقامت')),
                      Tab(text: l10nPick(context, en: 'Activities', fa: 'تفریحات')),
                      Tab(text: l10nPick(context, en: 'Services', fa: 'خدمات و شرایط')),
                    ],
                  ),
                  isDark: isDark,
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _ItineraryTab(itinerary: tour.itinerary, isDark: isDark),
              _HotelsTab(hotels: tour.hotels, isDark: isDark),
              _ActivitiesTab(activities: tour.activities, isDark: isDark),
              _ServicesTab(included: tour.includedServices, excluded: tour.excludedServices, isDark: isDark),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final tour = controller.selectedTour.value;
        if (tour == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppSpacing.xl.w,
            vertical: AppSpacing.md.h,
          ),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(context, en: 'Total from:', fa: 'قیمت پایه هر مسافر:'),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_formatPrice(tour.basePrice)} ${tour.currency}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSpacing.lg.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                    foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: AppSpacing.xxl.w, vertical: 14.h),
                  ),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Get.to(() => TourBookScreen(tour: tour));
                  },
                  child: Text(
                    l10nPick(context, en: 'Book Tour', fa: 'شروع رزرو تور'),
                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// Creative Itinerary Stepper with timeline nodes, day badges,
/// meals included chips, and daily activities list.
class _ItineraryTab extends StatelessWidget {
  final List<TourItineraryDay> itinerary;
  final bool isDark;

  const _ItineraryTab({required this.itinerary, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (itinerary.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.xl.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_month_outlined, size: 48.r, color: isDark ? AppColors.darkTextSecondary : AppColors.softGray),
              SizedBox(height: AppSpacing.md.h),
              Text(
                l10nPick(context, en: 'No itinerary details available', fa: 'برنامه روزانه برای این تور ثبت نشده است'),
                style: TextStyle(
                  fontSize: 13.5.sp,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: itinerary.length,
      itemBuilder: (context, index) {
        final day = itinerary[index];
        final isLast = index == itinerary.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline Node & Connecting Line
              Column(
                children: [
                  Container(
                    width: 38.r,
                    height: 38.r,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkPrimary, AppColors.mutedBlue]
                            : [TravelTheme.blue, const Color(0xFF5B86E5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? AppColors.darkPrimary : TravelTheme.blue).withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${day.dayNo}',
                        style: TextStyle(
                          color: isDark ? AppColors.deepBlack : AppColors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2.w,
                        margin: EdgeInsets.symmetric(vertical: 4.h),
                        color: isDark
                            ? AppColors.darkBorder
                            : TravelTheme.blue.withValues(alpha: 0.25),
                      ),
                    ),
                ],
              ),
              SizedBox(width: AppSpacing.md.w),

              // Day Content Card
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
                  padding: EdgeInsets.all(AppSpacing.md.r),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : AppColors.white,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                    border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    boxShadow: [
                      BoxShadow(
                        color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkPrimaryContainer
                                  : TravelTheme.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                            ),
                            child: Text(
                              '${l10nPick(context, en: 'DAY', fa: 'روز')} ${day.dayNo}',
                              style: TextStyle(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                              ),
                            ),
                          ),
                          if (day.meals.isNotEmpty)
                            Row(
                              children: day.meals.map((m) {
                                return Padding(
                                  padding: EdgeInsetsDirectional.only(start: 4.w),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                    decoration: BoxDecoration(
                                      color: isDark ? AppColors.darkSurfaceVariant : Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusXs.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.restaurant_rounded, size: 10.r, color: Colors.amber.shade800),
                                        SizedBox(width: 3.w),
                                        Text(
                                          m,
                                          style: TextStyle(
                                            fontSize: 9.5.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? AppColors.darkTextPrimary : Colors.amber.shade900,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm.h),
                      Text(
                        day.title,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                      if (day.description.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs.h),
                        Text(
                          day.description,
                          style: TextStyle(
                            fontSize: 11.5.sp,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (day.activities.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.sm.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 4.h,
                          children: day.activities.map((a) {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.place_rounded,
                                    size: 11.r,
                                    color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                                  ),
                                  SizedBox(width: 3.w),
                                  Text(
                                    a,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HotelsTab extends StatelessWidget {
  final List<TourHotel> hotels;
  final bool isDark;

  const _HotelsTab({required this.hotels, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty) {
      return Center(
        child: Text(
          l10nPick(context, en: 'No hotels assigned', fa: 'هتلی برای این تور ثبت نشده است'),
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: hotels.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        return Container(
          padding: EdgeInsets.all(AppSpacing.md.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hotel.name,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: hotel.tier == 'LUX'
                          ? Colors.purple.withValues(alpha: 0.15)
                          : (hotel.tier == 'STD' ? Colors.blue.withValues(alpha: 0.15) : Colors.green.withValues(alpha: 0.15)),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    ),
                    child: Text(
                      hotel.tierLabel,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w800,
                        color: hotel.tier == 'LUX'
                            ? Colors.purple
                            : (hotel.tier == 'STD' ? Colors.blue : Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.xs.h),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  SizedBox(width: 4.w),
                  Text(
                    '${hotel.rating}',
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
              if (hotel.amenities.isNotEmpty) ...[
                SizedBox(height: AppSpacing.sm.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: hotel.amenities
                      .map((a) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                            ),
                            child: Text(
                              a,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActivitiesTab extends StatelessWidget {
  final List<TourActivity> activities;
  final bool isDark;

  const _ActivitiesTab({required this.activities, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Text(
          l10nPick(context, en: 'No optional activities', fa: 'تفریح اختیاری برای این تور تعریف نشده است'),
          style: TextStyle(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      itemCount: activities.length,
      separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
      itemBuilder: (context, index) {
        final act = activities[index];
        return Container(
          padding: EdgeInsets.all(AppSpacing.md.r),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpacing.sm.r),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.darkPrimary : TravelTheme.blue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                ),
                child: Icon(
                  Icons.surfing_rounded,
                  color: isDark ? AppColors.darkPrimary : TravelTheme.blue,
                  size: AppSpacing.iconSm.r,
                ),
              ),
              SizedBox(width: AppSpacing.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act.title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      '${l10nPick(context, en: 'Day', fa: 'روز')} ${act.dayNo} • ${act.durationHours} ${l10nPick(context, en: 'Hours', fa: 'ساعت')}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                act.price > 0 ? '${act.price.toInt()} IRT' : l10nPick(context, en: 'Free', fa: 'رایگان'),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: act.price > 0
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                      : AppColors.success,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ServicesTab extends StatelessWidget {
  final List<String> included;
  final List<String> excluded;
  final bool isDark;

  const _ServicesTab({
    required this.included,
    required this.excluded,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(AppSpacing.lg.r),
      children: [
        if (included.isNotEmpty) ...[
          Text(
            l10nPick(context, en: 'Included Services:', fa: 'خدمات شامل پکیج:'),
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          ...included.map((s) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 16),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          SizedBox(height: AppSpacing.lg.h),
        ],
        if (excluded.isNotEmpty) ...[
          Text(
            l10nPick(context, en: 'Excluded Services:', fa: 'خدمات غیرشامل (به عهده مسافر):'),
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          ...excluded.map((s) => Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xs.h),
                child: Row(
                  children: [
                    const Icon(Icons.cancel_rounded, color: AppColors.error, size: 16),
                    SizedBox(width: AppSpacing.sm.w),
                    Expanded(
                      child: Text(
                        s,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  final bool isDark;

  _SliverAppBarDelegate(this._tabBar, {required this.isDark});

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
