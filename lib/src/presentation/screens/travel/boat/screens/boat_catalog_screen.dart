// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../../local/models/experience_contracts.dart';
import '../controllers/boat_controller.dart';
import '../models/boat_models.dart';
import '../../local/widgets/experience_ui_components.dart';
import 'boat_detail_screen.dart';
import 'boat_voucher_screen.dart';

class BoatCatalogScreen extends StatefulWidget {
  const BoatCatalogScreen({super.key});

  @override
  State<BoatCatalogScreen> createState() => _BoatCatalogScreenState();
}

class _BoatCatalogScreenState extends State<BoatCatalogScreen> {
  late final BoatController controller;
  bool _showMyBookingsSheet = false;

  final List<Map<String, dynamic>> _cities = const [
    {'key': 'ALL', 'label': 'همه ماریناها ⚓'},
    {'key': 'کیش', 'label': 'کیش 🇮🇷'},
    {'key': 'دبی', 'label': 'دبی 🇦🇪'},
    {'key': 'استانبول', 'label': 'استانبول 🇹🇷'},
  ];

  final List<Map<String, dynamic>> _categories = const [
    {'cat': null, 'label': 'همه شناورها'},
    {'cat': BoatCategory.yacht, 'label': 'یات لوکس 🛥️'},
    {'cat': BoatCategory.speedboat, 'label': 'قایق تندرو ⚡'},
    {'cat': BoatCategory.catamaran, 'label': 'کاتاماران ⛵'},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<BoatController>()
        ? Get.find<BoatController>()
        : Get.put(BoatController());

    // Subscribe to UI state changes
    controller.uiState.listen((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const oceanColor = Color(0xFF0077B6);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSpacing.iconSm.sp,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Get.back();
          },
        ),
        title: Text(
          l10nPick(
            context,
            fa: 'گشت و تفریحات دریایی',
            en: 'Marine & Yacht Club',
            ar: 'اليخوت والرحلات البحرية',
          ),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.confirmation_number_outlined,
              color: oceanColor,
              size: 22.sp,
            ),
            tooltip: 'بلیت‌های من',
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _showMyBookingsSheet = true);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline banner
          Obx(() => controller.isOffline.value
              ? ExperienceOfflineBanner(onRetry: () {
                  setState(() {
                    _showMyBookingsSheet = false;
                    controller.loadCatalog(forceRefresh: true);
                  });
                })
              : const SizedBox.shrink()),

          // Marina City Selector Row
          Container(
            height: 44.h,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Obx(() {
              final activeCity = controller.selectedCity.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                itemCount: _cities.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, idx) {
                  final c = _cities[idx];
                  final isSelected = activeCity == c['key'];

                  return ChoiceChip(
                    label: Text(
                      c['label']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: oceanColor,
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: isSelected
                            ? oceanColor
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      controller.setCity(c['key']!);
                    },
                  );
                },
              );
            }),
          ),

          // Category Filter Row
          Container(
            height: 42.h,
            padding: EdgeInsets.symmetric(vertical: 4.h),
            child: Obx(() {
              final activeCat = controller.selectedCategory.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                itemCount: _categories.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, idx) {
                  final cat = _categories[idx];
                  final isSelected = activeCat == cat['cat'];

                  return FilterChip(
                    label: Text(
                      cat['label']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? oceanColor
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: oceanColor.withValues(alpha: 0.14),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: isSelected
                            ? oceanColor
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      controller.setCategory(cat['cat'] as BoatCategory?);
                    },
                  );
                },
              );
            }),
          ),

          SizedBox(height: 6.h),

          // Boats List with state handling
          Expanded(
            child: Obx(() {
              final boats = controller.filteredBoats;
              final state = controller.uiState.value;

              switch (state) {
                case ExperienceServiceState.loading:
                case ExperienceServiceState.skeleton:
                  return ExperienceCatalogSkeleton(itemCount: 4);

                case ExperienceServiceState.error:
                  return ExperienceErrorView(
                    errorMessage: controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'خطا در بارگذاری داده‌ها',
                    onRetry: () => controller.loadCatalog(),
                  );

                case ExperienceServiceState.offline:
                  return ExperienceErrorView(
                    errorMessage: 'شما آفلاین هستید. لطفاً اتصال اینترنت را بررسی کنید.',
                    onRetry: () => controller.loadCatalog(forceRefresh: true),
                  );

                case ExperienceServiceState.empty:
                case ExperienceServiceState.partial:
                  return ExperienceEmptyView(
                    icon: Icons.directions_boat_outlined,
                    title: 'شناوری در این منطقه یافت نشد.',
                    subtitle: 'فیلترها را تغییر دهید یا همه مناطق را مشاهده کنید.',
                    onReset: () => controller.resetFilters(),
                  );

                case ExperienceServiceState.success:
                case ExperienceServiceState.completed:
                case ExperienceServiceState.cancelled:
                  return IndexedStack(
                    index: _showMyBookingsSheet ? 1 : 0,
                    children: [
                      _buildBoatsList(context, boats, isDark, oceanColor),
                      _buildMyBookingsSheet(context, isDark, oceanColor),
                    ],
                  );

                case ExperienceServiceState.validationError:
                case ExperienceServiceState.processing:
                case ExperienceServiceState.defaultState:
                  return ExperienceErrorView(
                    errorMessage: 'در حال پردازش...',
                    onRetry: () => controller.loadCatalog(),
                  );
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBoatsList(BuildContext context, List<BoatExperienceModel> boats, bool isDark,
      Color oceanColor) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg.w, 4.h, AppSpacing.lg.w, AppSpacing.xl.h),
      itemCount: boats.length,
      itemBuilder: (context, index) {
        final boat = boats[index];
        return _buildBoatCard(context, boat, isDark, oceanColor);
      },
    );
  }

  Widget _buildBoatCard(
    BuildContext context,
    BoatExperienceModel boat,
    bool isDark,
    Color oceanColor,
  ) {
    return Semantics(
      label: '${boat.title} - ${boat.hourlyRate.toStringAsFixed(0)} ${boat.currency} بر ساعت',
      button: true,
      child: Container(
        margin: EdgeInsets.only(bottom: AppSpacing.lg.h),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(AppSpacing.radius.r),
          border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              Get.to(() => BoatDetailScreen(boat: boat));
            },
            borderRadius: BorderRadius.circular(AppSpacing.radius.r),
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                          decoration: BoxDecoration(
                            color: oceanColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            boat.categoryLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: oceanColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.warning, size: 15),
                          SizedBox(width: 4.w),
                          Text(
                            '${boat.rating}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    boat.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.place_rounded,
                        size: 14.sp,
                        color:
                            isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Text(
                          boat.marinaName,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color:
                                isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _buildPill(Icons.people_alt_outlined, '${boat.maxPassengers} نفر', isDark),
                      _buildPill(Icons.straighten_rounded, '${boat.lengthMeters} متر', isDark),
                      _buildPill(Icons.timer_outlined, 'از ۱ ساعت', isDark),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'کرایه هر ساعت',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color:
                                    isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                              ),
                            ),
                            Text(
                              '${boat.hourlyRate.toStringAsFixed(0)} ${boat.currency}',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: oceanColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 8.w),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: oceanColor,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          minimumSize: Size(120.w, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.to(() => BoatDetailScreen(boat: boat));
                        },
                        child: const Text('مشاهده و رزرو',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPill(IconData icon, String label, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp,
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5.sp,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyBookingsSheet(BuildContext context, bool isDark, Color oceanColor) {
    return Obx(() {
      final bookings = controller.myBookings;
      if (bookings.isEmpty) {
        return ExperienceEmptyView(
          icon: Icons.confirmation_number_outlined,
          title: 'شما بلیت دریایی فعالی ندارید.',
          subtitle: 'با انتخاب یکی از شناورها می‌توانید گشت دریایی رزرو کنید.',
          onReset: () => setState(() => _showMyBookingsSheet = false),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg.w,
          AppSpacing.md.h,
          AppSpacing.lg.w,
          AppSpacing.xl.h,
        ),
        itemCount: bookings.length,
        itemBuilder: (context, idx) {
          final b = bookings[idx];
          return _buildBookingCard(context, b, isDark, oceanColor);
        },
      );
    });
  }

  Widget _buildBookingCard(
    BuildContext context,
    BoatBookingModel booking,
    bool isDark,
    Color oceanColor,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: 10.h),
      color: isDark ? AppColors.darkCard : AppColors.lightSurface,
      elevation: 2,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        leading: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: oceanColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Icon(
              Icons.directions_boat_rounded,
              size: 22.sp,
              color: oceanColor,
            ),
          ),
        ),
        title: Text(
          booking.boatTitle,
          style: const TextStyle(fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text('${booking.marinaName} • ${booking.timeSlot}'),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 12.sp),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
          Get.to(() => BoatVoucherScreen(booking: booking));
        },
      ),
    );
  }
}
