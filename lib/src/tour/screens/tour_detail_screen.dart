
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

    return Scaffold(
      backgroundColor: TravelTheme.background,
      body: Obx(() {
        if (controller.isLoadingDetail.value && controller.selectedTour.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final tour = controller.selectedTour.value;
        if (tour == null) {
          return Center(
            child: Padding(
              padding: EdgeInsetsDirectional.all(24.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.orange,
                      size: 48,
                    ),
                  ),
                  SizedBox(height: 16.h),
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
                      color: TravelTheme.ink,
                    ),
                  ),
                  SizedBox(height: 8.h),
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
                      color: TravelTheme.muted,
                      fontSize: 12.sp,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Go Back',
                            fa: 'بازگشت',
                            ar: 'رجوع',
                            zh: '返回',
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: TravelTheme.blue),
                        onPressed: () => controller.loadTourDetail(widget.tourId),
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Retry',
                            fa: 'تلاش مجدد',
                            ar: 'إعادة المحاولة',
                            zh: '重试',
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
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
                backgroundColor: TravelTheme.ink,
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white, size: 18),
                  ),
                  onPressed: () => Get.back(),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      tour.featuredImage != null && tour.featuredImage!.startsWith('http')
                          ? Image.network(
                              tour.featuredImage!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(color: Colors.blueGrey),
                            )
                          : Container(color: Colors.blueGrey),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.8),
                            ],
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        bottom: 16.h,
                        start: 16.w,
                        end: 16.w,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: TravelTheme.blue,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                '${tour.city}, ${tour.countryCode}',
                                style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w800),
                              ),
                            ),
                            SizedBox(height: 6.h),
                            Text(
                              tour.title,
                              style: TextStyle(
                                color: Colors.white,
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
                    labelColor: TravelTheme.blue,
                    unselectedLabelColor: TravelTheme.muted,
                    indicatorColor: TravelTheme.blue,
                    indicatorWeight: 3,
                    labelStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800),
                    tabs: [
                      Tab(text: l10nPick(context, en: 'Itinerary', fa: 'برنامه روزانه')),
                      Tab(text: l10nPick(context, en: 'Hotels', fa: 'هتل‌ها و اقامت')),
                      Tab(text: l10nPick(context, en: 'Activities', fa: 'تفریحات')),
                      Tab(text: l10nPick(context, en: 'Services', fa: 'خدمات و شرایط')),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _ItineraryTab(itinerary: tour.itinerary),
              _HotelsTab(hotels: tour.hotels),
              _ActivitiesTab(activities: tour.activities),
              _ServicesTab(included: tour.includedServices, excluded: tour.excludedServices),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final tour = controller.selectedTour.value;
        if (tour == null) return const SizedBox.shrink();

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                        style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_formatPrice(tour.basePrice)} ${tour.currency}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w900,
                          color: TravelTheme.green,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TravelTheme.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                  ),
                  onPressed: () {
                    Get.to(() => TourBookScreen(tour: tour));
                  },
                  child: Text(
                    l10nPick(context, en: 'Book Tour', fa: 'شروع رزرو تور'),
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
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

class _ItineraryTab extends StatelessWidget {
  final List<TourItineraryDay> itinerary;

  const _ItineraryTab({required this.itinerary});

  @override
  Widget build(BuildContext context) {
    if (itinerary.isEmpty) {
      return Center(
        child: Text(l10nPick(context, en: 'No itinerary details available', fa: 'برنامه روزانه برای این تور ثبت نشده است')),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: itinerary.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final day = itinerary[index];
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: TravelTheme.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32.r,
                    height: 32.r,
                    decoration: const BoxDecoration(
                      color: TravelTheme.blue,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${day.dayNo}',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      day.title,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
                    ),
                  ),
                ],
              ),
              if (day.description.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Text(
                  day.description,
                  style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted, height: 1.4),
                ),
              ],
              if (day.meals.isNotEmpty) ...[
                SizedBox(height: 10.h),
                Wrap(
                  spacing: 6.w,
                  children: day.meals.map((m) => Chip(
                    label: Text(m, style: TextStyle(fontSize: 10.sp)),
                    backgroundColor: Colors.amber.shade50,
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )).toList(),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HotelsTab extends StatelessWidget {
  final List<TourHotel> hotels;
  const _HotelsTab({required this.hotels});

  @override
  Widget build(BuildContext context) {
    if (hotels.isEmpty) {
      return Center(
        child: Text(l10nPick(context, en: 'No hotels assigned', fa: 'هتلی برای این تور ثبت نشده است')),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: hotels.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final hotel = hotels[index];
        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: TravelTheme.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hotel.name,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: hotel.tier == 'LUX'
                          ? Colors.purple.shade50
                          : (hotel.tier == 'STD' ? Colors.blue.shade50 : Colors.green.shade50),
                      borderRadius: BorderRadius.circular(8.r),
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
              SizedBox(height: 6.h),
              Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                  SizedBox(width: 4.w),
                  Text('${hotel.rating}', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700)),
                ],
              ),
              if (hotel.amenities.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 4.h,
                  children: hotel.amenities
                      .map((a) => Chip(
                            label: Text(a, style: TextStyle(fontSize: 10.sp)),
                            backgroundColor: TravelTheme.background,
                            visualDensity: VisualDensity.compact,
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
  const _ActivitiesTab({required this.activities});

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Center(
        child: Text(l10nPick(context, en: 'No optional activities', fa: 'تفریح اختیاری برای این تور تعریف نشده است')),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: activities.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final act = activities[index];
        return Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: TravelTheme.shadow,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.r),
                decoration: BoxDecoration(
                  color: TravelTheme.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.surfing_rounded, color: TravelTheme.blue),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      act.title,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${l10nPick(context, en: 'Day', fa: 'روز')} ${act.dayNo} • ${act.durationHours} ${l10nPick(context, en: 'Hours', fa: 'ساعت')}',
                      style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted),
                    ),
                  ],
                ),
              ),
              Text(
                act.price > 0 ? '${act.price.toInt()} IRT' : l10nPick(context, en: 'Free', fa: 'رایگان'),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  color: act.price > 0 ? TravelTheme.ink : TravelTheme.green,
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

  const _ServicesTab({required this.included, required this.excluded});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16.r),
      children: [
        if (included.isNotEmpty) ...[
          Text(
            l10nPick(context, en: 'Included Services:', fa: 'خدمات شامل پکیج:'),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: TravelTheme.green),
          ),
          SizedBox(height: 8.h),
          ...included.map((s) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: TravelTheme.green, size: 16),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(s, style: TextStyle(fontSize: 12.sp, color: TravelTheme.ink))),
                  ],
                ),
              )),
          SizedBox(height: 16.h),
        ],
        if (excluded.isNotEmpty) ...[
          Text(
            l10nPick(context, en: 'Excluded Services:', fa: 'خدمات غیرشامل (به عهده مسافر):'),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: TravelTheme.red),
          ),
          SizedBox(height: 8.h),
          ...excluded.map((s) => Padding(
                padding: EdgeInsets.only(bottom: 6.h),
                child: Row(
                  children: [
                    const Icon(Icons.cancel_rounded, color: TravelTheme.red, size: 16),
                    SizedBox(width: 8.w),
                    Expanded(child: Text(s, style: TextStyle(fontSize: 12.sp, color: TravelTheme.ink))),
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

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

