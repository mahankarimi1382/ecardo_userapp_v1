
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
      backgroundColor: TravelTheme.background,
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
            color: TravelTheme.ink,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: TravelTheme.ink),
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
            icon: const Icon(Icons.confirmation_number_outlined, color: TravelTheme.blue),
            onPressed: () => Get.to(() => const TourMyBookingsScreen()),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: TravelTheme.blue,
        onRefresh: () => controller.loadTours(refresh: true),
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(16.w, 12.h, 16.w, 24.h),
          children: [
            // Tour-Yar Quiz Banner
            _TourYarBanner(
              onTap: () {
                controller.resetQuiz();
                Get.to(() => const TourMatchScreen());
              },
            ),
            SizedBox(height: 16.h),

            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: TravelTheme.shadow,
              ),
              padding: EdgeInsetsDirectional.symmetric(horizontal: 14.w),
              child: Row(
                children: [
                  const Icon(Icons.search_rounded, color: TravelTheme.muted),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: l10nPick(
                          context,
                          en: 'Search destination, city, or tour title...',
                          fa: 'جستجوی مقصد، شهر یا عنوان تور...',
                          ar: 'البحث عن وجهة أو مدينة أو رحلة...',
                          zh: '搜索目的地、城市或旅游路线...',
                        ),
                        hintStyle: TextStyle(fontSize: 12.sp, color: TravelTheme.muted),
                        border: InputBorder.none,
                      ),
                      onChanged: (val) {
                        controller.searchQuery.value = val;
                        controller.loadTours();
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),

            // Category Horizontal Chips
            SizedBox(
              height: 38.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 8.w),
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
                          color: isSelected ? Colors.white : TravelTheme.ink,
                        ),
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: TravelTheme.blue,
                      checkmarkColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                        side: BorderSide(
                          color: isSelected ? TravelTheme.blue : TravelTheme.border,
                        ),
                      ),
                      onSelected: (val) {
                        controller.selectedCategory.value = cat['code']!;
                        controller.loadTours();
                      },
                    );
                  });
                },
              ),
            ),
            SizedBox(height: 16.h),

            // Tour List View
            Obx(() {
              if (controller.isLoadingTours.value && controller.tours.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (controller.isServiceUnavailable.value) {
                return Container(
                  margin: EdgeInsetsDirectional.only(top: 10.h),
                  padding: EdgeInsetsDirectional.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    boxShadow: TravelTheme.shadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(14.r),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.cloud_off_rounded,
                          color: Colors.orange,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 12.h),
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
                          color: TravelTheme.ink,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'The tours catalog (/user/tours) is undergoing backend partner integration. Please retry shortly.',
                          fa: 'سرویس جامع تورهای بین‌المللی در حال همگام‌سازی با درگاه‌های تأمین‌کننده است. لطفاً بعداً تلاش فرمایید.',
                          ar: 'خوادم الجولات السياحية قيد التحديث مع الشركاء. يرجى المحاولة لاحقاً.',
                          zh: '旅游线路服务接口正在与后台合作伙伴联调中，请稍后重试。',
                        ),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TravelTheme.muted,
                          fontSize: 11.5.sp,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TravelTheme.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsetsDirectional.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                        ),
                        onPressed: () => controller.loadTours(refresh: true),
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                        label: Text(
                          l10nPick(
                            context,
                            en: 'Retry Connection',
                            fa: 'تلاش مجدد',
                            ar: 'إعادة المحاولة',
                            zh: '重试连接',
                          ),
                          style: TextStyle(color: Colors.white, fontSize: 12.sp),
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (controller.tours.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Column(
                      children: [
                        Icon(Icons.explore_off_outlined, size: 64.r, color: TravelTheme.muted),
                        SizedBox(height: 12.h),
                        Text(
                          l10nPick(
                            context,
                            en: 'No tours found',
                            fa: 'توری با این مشخصات یافت نشد',
                            ar: 'لم يتم العثور على جولات سياحية',
                            zh: '未找到符合条件的旅游路线',
                          ),
                          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.tours.length,
                separatorBuilder: (_, __) => SizedBox(height: 14.h),
                itemBuilder: (context, index) {
                  final tour = controller.tours[index];
                  return _TourCard(
                    tour: tour,
                    onTap: () {
                      controller.loadTourDetail(tour.id);
                      Get.to(() => TourDetailScreen(tourId: tour.id));
                    },
                  );
                },
              );
            }),
          ],
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
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF2C3E50), Color(0xFF3498DB), Color(0xFF9B51E0)],
        ),
        boxShadow: TravelTheme.shadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(18.r),
            child: Row(
              children: [
                Container(
                  width: 54.r,
                  height: 54.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.amber, size: 28),
                ),
                SizedBox(width: 14.w),
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
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              l10nPick(context, en: 'Smart Quiz', fa: 'کوییز هوشمند'),
                              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: Colors.black87),
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            l10nPick(context, en: 'Tour-Yar Advisor', fa: 'تور-یار هوشمند eCardo'),
                            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10nPick(
                          context,
                          en: 'Answer 8 quick questions to find your personalized travel package',
                          fa: 'با ۸ سوال کوتاه، تور مسافرتی ایده‌آل روحیه و بودجه‌ات را کشف کن',
                        ),
                        style: TextStyle(fontSize: 11.sp, color: Colors.white.withValues(alpha: 0.88)),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TourCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback onTap;

  const _TourCard({required this.tour, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final nextDep = tour.departures.isNotEmpty ? tour.departures.first : null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: TravelTheme.shadow,
        border: Border.all(color: TravelTheme.border.withValues(alpha: 0.5)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tour Image & Badges
            Stack(
              children: [
                SizedBox(
                  height: 160.h,
                  width: double.infinity,
                  child: tour.featuredImage != null && tour.featuredImage!.startsWith('http')
                      ? Image.network(
                          tour.featuredImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ImagePlaceholder(tour: tour),
                        )
                      : _ImagePlaceholder(tour: tour),
                ),
                PositionedDirectional(
                  top: 10.h,
                  start: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.location_on_rounded, color: Colors.amber, size: 14),
                        SizedBox(width: 4.w),
                        Text(
                          '${tour.city} (${tour.countryCode})',
                          style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 10.h,
                  end: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: TravelTheme.blue,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      '${tour.durationDays} ${l10nPick(context, en: 'Days', fa: 'روز')} / ${tour.durationNights} ${l10nPick(context, en: 'Nights', fa: 'شب')}',
                      style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
                if (tour.matchPercentage != null)
                  PositionedDirectional(
                    bottom: 10.h,
                    end: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: TravelTheme.green,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        '${tour.matchPercentage}% ${l10nPick(context, en: 'Match', fa: 'تطابق')}',
                        style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),

            // Tour Info
            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tour.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: TravelTheme.ink),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    tour.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: TravelTheme.muted, height: 1.35),
                  ),
                  SizedBox(height: 10.h),
                  const Divider(height: 1),
                  SizedBox(height: 10.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10nPick(context, en: 'Starts from:', fa: 'شروع قیمت از:'),
                            style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${_formatPrice(tour.basePrice)} ${tour.currency}',
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: TravelTheme.green),
                          ),
                        ],
                      ),
                      if (nextDep != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              l10nPick(context, en: 'Next Departure:', fa: 'حرکت بعدی:'),
                              style: TextStyle(fontSize: 10.sp, color: TravelTheme.muted),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              nextDep.departDate,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: TravelTheme.blue),
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

  String _formatPrice(double price) {
    return price.toInt().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final TourModel tour;
  const _ImagePlaceholder({required this.tour});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey.shade100,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.landscape_rounded, size: 48.r, color: Colors.blueGrey.shade400),
            SizedBox(height: 6.h),
            Text(
              tour.city,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.blueGrey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}

