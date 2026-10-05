// DATA: MOCK (Ready for REAL backend domain registration under schema_version: 1.0)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import '../controllers/local_experience_controller.dart';
import '../models/local_experience_models.dart';
import '../../local/models/experience_contracts.dart';
import '../../local/widgets/experience_ui_components.dart';
import 'local_detail_screen.dart';
import 'local_voucher_screen.dart';

class LocalCatalogScreen extends StatefulWidget {
  const LocalCatalogScreen({super.key});

  @override
  State<LocalCatalogScreen> createState() => _LocalCatalogScreenState();
}

class _LocalCatalogScreenState extends State<LocalCatalogScreen> {
  late final LocalExperienceController controller;

  final List<Map<String, dynamic>> _cities = const [
    {'key': 'ALL', 'label': 'همه شهرها 🌍'},
    {'key': 'استانبول', 'label': 'استانبول 🇹🇷'},
    {'key': 'دبی', 'label': 'دبی 🇦🇪'},
    {'key': 'کیش', 'label': 'کیش 🇮🇷'},
  ];

  final List<Map<String, dynamic>> _types = const [
    {'type': null, 'label': 'همه خدمات'},
    {'type': LocalServiceType.tourGuide, 'label': 'راهنمای تور 🏛️'},
    {'type': LocalServiceType.chauffeur, 'label': 'راننده لوکس 🚗'},
    {'type': LocalServiceType.photographer, 'label': 'عکاس حرفه‌ای 📸'},
    {'type': LocalServiceType.meetAndGreet, 'label': 'فرودگاه VIP ✈️'},
  ];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<LocalExperienceController>()
        ? Get.find<LocalExperienceController>()
        : Get.put(LocalExperienceController());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const tealColor = Color(0xFF0F766E);

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
            fa: 'خدمات محلی و تجربیات شهری',
            en: 'Local Experiences & City Guide',
            ar: 'الخدمات المحلية ودليل المدينة',
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
              color: tealColor,
              size: 22.sp,
            ),
            tooltip: 'واچرهای من',
            onPressed: () => _showMyBookingsSheet(context, isDark),
          ),
        ],
      ),
      body: Column(
        children: [
          // Offline Banner
          Obx(() => controller.isOffline.value
              ? ExperienceOfflineBanner(onRetry: () => controller.loadCatalog())
              : const SizedBox.shrink()),

          // Search Field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w, vertical: 4.h),
            child: TextField(
              onChanged: controller.onSearchChanged,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              ),
              decoration: InputDecoration(
                hintText: l10nPick(
                  context,
                  fa: 'جستجوی خدمت، راهنما یا جاذبه...',
                  en: 'Search service, provider or attraction...',
                ),
                hintStyle: TextStyle(
                  fontSize: 11.5.sp,
                  color: isDark ? AppColors.darkTextHint : AppColors.lightTextHint,
                ),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18.sp,
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 12.w),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide:
                      BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                ),
              ),
            ),
          ),

          // City Selector Row
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
                    selectedColor: tealColor,
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                      side: BorderSide(
                        color: isSelected
                            ? tealColor
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
              final activeType = controller.selectedType.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg.w),
                itemCount: _types.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.w),
                itemBuilder: (context, idx) {
                  final cat = _types[idx];
                  final isSelected = activeType == cat['cat'];

                  return FilterChip(
                    label: Text(
                      cat['label']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? tealColor
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                    ),
                    selected: isSelected,
                    showCheckmark: false,
                    selectedColor: tealColor.withValues(alpha: 0.14),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                      side: BorderSide(
                        color: isSelected
                            ? tealColor
                            : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                      ),
                    ),
                    onSelected: (_) {
                      HapticFeedback.selectionClick();
                      controller.setType(cat['cat'] as LocalServiceType?);
                    },
                  );
                },
              );
            }),
          ),

          SizedBox(height: 6.h),

          // Services List with 12-state UI machine
          Expanded(
            child: Obx(() {
              final list = controller.filteredExperiences;
              final state = controller.uiState.value;

              switch (state) {
                case ExperienceServiceState.loading:
                case ExperienceServiceState.skeleton:
                  return ExperienceCatalogSkeleton(itemCount: 4);

                case ExperienceServiceState.error:
                  return ExperienceErrorView(
                    errorMessage: controller.errorMessage.value.isNotEmpty
                        ? controller.errorMessage.value
                        : 'خطا در بارگذاری تجربه‌های محلی',
                    onRetry: () => controller.loadCatalog(),
                  );

                case ExperienceServiceState.offline:
                  return ExperienceErrorView(
                    errorMessage: 'اتصال اینترنت قطع است.',
                    onRetry: () => controller.loadCatalog(),
                  );

                case ExperienceServiceState.empty:
                case ExperienceServiceState.partial:
                  return ExperienceEmptyView(
                    icon: Icons.place_rounded,
                    title: 'خدمتی با این مشخصات یافت نشد.',
                    subtitle: 'فیلتر شهر یا نوع خدمت را تغییر دهید.',
                    onReset: () => controller.resetFilters(),
                  );

                case ExperienceServiceState.success:
                case ExperienceServiceState.completed:
                case ExperienceServiceState.cancelled:
                  return ListView.builder(
                    padding: EdgeInsets.fromLTRB(AppSpacing.lg.w, 4.h, AppSpacing.lg.w, AppSpacing.xl.h),
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final exp = list[index];
                      return _buildExperienceCard(context, exp, isDark, tealColor);
                    },
                  );

                case ExperienceServiceState.validationError:
                case ExperienceServiceState.processing:
                case ExperienceServiceState.defaultState:
                  return const SizedBox.shrink();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(
    BuildContext context,
    LocalExperienceItemModel exp,
    bool isDark,
    Color tealColor,
  ) {
    return Semantics(
      label: '${exp.title} - ${exp.price.toStringAsFixed(0)} ${exp.currency}',
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
              Get.to(() => LocalDetailScreen(experience: exp));
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
                            color: tealColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            exp.typeLabel,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              fontWeight: FontWeight.w700,
                              color: tealColor,
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
                            '${exp.rating} (${exp.reviewsCount})',
                            style: TextStyle(
                              fontSize: 11.sp,
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
                    exp.title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    exp.subtitle,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      _buildPill(Icons.location_on_rounded, exp.city, isDark),
                      _buildPill(Icons.timer_outlined, exp.durationLabel, isDark),
                      if (exp.freeCancellation)
                        _buildPill(Icons.shield_outlined, 'لغو رایگان', isDark),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تعرفه پایه',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color:
                                  isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                          Text(
                            '${exp.price.toStringAsFixed(0)} ${exp.currency}',
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w900,
                              color: tealColor,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: tealColor,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          minimumSize: Size(110.w, 44.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.to(() => LocalDetailScreen(experience: exp));
                        },
                        child: const Text('رزرو',
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
          Icon(icon,
              size: 12.sp,
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

  void _showMyBookingsSheet(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl.r)),
      ),
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(AppSpacing.lg.r),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.75),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'واچرهای خدمات محلی من',
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: Obx(() {
                  final bookings = controller.myBookings;
                  if (bookings.isEmpty) {
                    return Center(
                      child: Text(
                        'شما هیچ واچر فعالی ندارید.',
                        style: TextStyle(
                          color:
                              isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, idx) {
                      final b = bookings[idx];
                      return Card(
                        margin: EdgeInsets.only(bottom: 10.h),
                        color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                        child: ListTile(
                          title: Text(
                            b.serviceTitle,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${b.providerName} • ${DateFormat('dd MMM').format(b.serviceDate)}',
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            Navigator.pop(ctx);
                            Get.to(() => LocalVoucherScreen(booking: b));
                          },
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
