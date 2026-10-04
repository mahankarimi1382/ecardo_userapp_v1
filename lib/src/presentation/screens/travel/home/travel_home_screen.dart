import 'package:ecardo_user/src/tour/screens/tour_list_screen.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/helper/app_haptics.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';

import '../account/travel_account_screen.dart';
import '../bookings/travel_orders_screen.dart';
import '../core/models/travel_models.dart';
import '../esim/esim_intro_screen.dart';
import '../flights/flight_search_screen.dart';
import '../hotels/hotel_search_screen.dart';
import '../insurance/insurance_screens.dart';
import '../sim/sim_topup_screen.dart';
import '../taxi/taxi_search_screen.dart';
import '../trains/train_screens.dart';
import 'package:ecardo_user/src/rental/screens/rental_home_screen.dart';
import 'package:ecardo_user/src/visa/screens/visa_catalog_screen.dart';
import '../services/cip_lounge_screen.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';

class TravelHomeScreen extends StatelessWidget {
  const TravelHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = ensureTravelController();

    return TravelPage(
      title: localization.travelTitle,
      trailing: Padding(
        padding: EdgeInsetsDirectional.only(end: 12.w),
        child: IconButton(
          onPressed: () => Get.to(() => const TravelAccountScreen()),
          icon: const Icon(Icons.account_circle_outlined),
        ),
      ),
      child: RefreshIndicator(
        color: TravelTheme.blue,
        onRefresh: controller.loadDashboard,
        child: ListView(
          padding: EdgeInsetsDirectional.fromSTEB(20.w, 12.h, 20.w, 36.h),
          children: [
            Obx(() {
              final bootstrap = controller.bootstrap.value;
              final services = bootstrap?.services ?? const [];
              final homeHero = _homeHero(services);

              return Column(
                children: [
                  _Hero(
                    eyebrow:
                        homeHero['subtitle']?.toString() ??
                        localization.travelHeroEyebrow,
                    title:
                        homeHero['title']?.toString() ??
                        localization.travelHeroTitle,
                  ),
                  SizedBox(height: 22.h),
                  _Services(
                    services: services,
                    isLoading: controller.isBootstrapLoading.value,
                    hasError:
                        bootstrap == null &&
                        controller.bootstrapError.value != null,
                    localization: localization,
                    onRetry: controller.reloadBootstrap,
                  ),
                ],
              );
            }),
            SizedBox(height: 28.h),
            TravelSectionHeader(
              title: localization.travelRecentActivity,
              action: localization.travelViewAll,
              onAction: () => Get.to(() => const TravelOrdersScreen()),
            ),
            SizedBox(height: AppSpacing.sm.h),
            Obx(
              () =>
                  controller.isActivityLoading.value &&
                  controller.activity.isEmpty
                  ? const TravelShimmerLoading(
                      type: TravelShimmerType.tile,
                      count: 2,
                    )
                  : controller.activity.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      children: controller.activity
                          .take(3)
                          .map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: AppSpacing.sm.h),
                              child: _ActivityTile(activity: item),
                            ),
                          )
                          .toList(),
                    ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Builder(
              builder: (context) {
                final isDark = TravelTheme.isDark(context);
                return TravelCard(
                  color: isDark
                      ? AppColors.darkSurfaceVariant
                      : const Color(0xFFEAF3FF),
                  onTap: () => Get.toNamed(
                    BaseRoute.addMoney,
                    arguments: {'returnRoute': BaseRoute.travel},
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(AppSpacing.md.r),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: TravelTheme.green,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              localization.travelMainWallet,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: TravelTheme.textPrimaryFor(context),
                              ),
                            ),
                            SizedBox(height: AppSpacing.xs.h),
                            Text(
                              localization.travelWalletSharedDescription,
                              style: TextStyle(
                                color: TravelTheme.textSecondaryFor(context),
                                fontSize: 11.sp,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: TravelTheme.textSecondaryFor(context),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _homeHero(List<TravelServiceConfig> services) {
    for (final service in services) {
      final items = service.presentation['home_hero'];
      if (items is! List || items.isEmpty) continue;
      final first = items.first;
      if (first is Map<String, dynamic>) return first;
      if (first is Map) return Map<String, dynamic>.from(first);
    }
    return const {};
  }
}

class _Hero extends StatelessWidget {
  final String eyebrow;
  final String title;

  const _Hero({required this.eyebrow, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final heroGradient = isDark
        ? const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [Color(0xFF0A1E36), Color(0xFF1E3A5F), Color(0xFF2E4E74)],
          )
        : const LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [Color(0xFF0D47A1), TravelTheme.blue, TravelTheme.purple],
          );

    return Container(
      height: 205.h,
      padding: EdgeInsets.all(AppSpacing.xxl.r),
      decoration: BoxDecoration(
        borderRadius: TravelTheme.radius,
        gradient: heroGradient,
        boxShadow: TravelTheme.shadowFor(context),
      ),
      child: Stack(
        children: [
          PositionedDirectional(
            end: -18.w,
            top: -14.h,
            child: Icon(
              Icons.public_rounded,
              color: Colors.white.withValues(alpha: 0.13),
              size: 180.r,
            ),
          ),
          Align(
            alignment: AlignmentDirectional.bottomStart,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpacing.sm.h),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    height: 1.3,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Services extends StatelessWidget {
  final List<TravelServiceConfig> services;
  final bool isLoading;
  final bool hasError;
  final AppLocalizations localization;
  final Future<void> Function() onRetry;

  const _Services({
    required this.services,
    required this.isLoading,
    required this.hasError,
    required this.localization,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      if (isLoading) {
        return const TravelShimmerLoading(
          type: TravelShimmerType.card,
          count: 2,
        );
      }
      if (hasError) {
        return TravelErrorState(
          message: localization.allControllerLoadError,
          onRetry: onRetry,
        );
      }
      return TravelEmptyState(
        message: localization.travelOfferUnavailable,
        icon: Icons.travel_explore_rounded,
      );
    }

    final serviceByType = {for (final service in services) service.type: service};
    final visibleServices = [
      TravelProductType.flight,
      TravelProductType.hotel,
      TravelProductType.esim,
    ]
        .map((type) => serviceByType[type])
        .whereType<TravelServiceConfig>()
        .toList();

    return Column(
      children: [
        // Primary Row: Flights, Hotels, eSIM, Tours, Visa
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < visibleServices.length; index++) ...[
              Expanded(
                child: _ServiceTile(
                  color: travelProductColor(visibleServices[index].type),
                  icon: travelProductIcon(visibleServices[index].type),
                  label: visibleServices[index].displayName,
                  foreground:
                      visibleServices[index].type == TravelProductType.esim
                      ? TravelTheme.ink
                      : Colors.white,
                  onTap: () => _openService(visibleServices[index].type),
                ),
              ),
              SizedBox(width: 8.w),
            ],
            Expanded(
              child: _ServiceTile(
                color: const Color(0xFF9B51E0),
                icon: Icons.tour_rounded,
                label: l10nPick(
                  context,
                  en: 'Tours',
                  fa: 'تور مسافرتی',
                  ar: 'الجولات',
                  zh: '旅游路线',
                ),
                foreground: Colors.white,
                onTap: () => Get.to(() => const TourListScreen()),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ServiceTile(
                color: const Color(0xFF6C5CE7),
                icon: Icons.card_membership_rounded,
                label: l10nPick(
                  context,
                  en: 'Visa',
                  fa: 'خدمات ویزا',
                  ar: 'التأشيرات',
                  zh: '签证服务',
                ),
                foreground: Colors.white,
                onTap: () => Get.to(() => const VisaCatalogScreen()),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),

        // Secondary Row: Trains, Car Rental, Taxi, Insurance, SIM Top-Up
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ServiceTile(
                color: TravelTheme.green,
                icon: Icons.train_rounded,
                label: l10nPick(
                  context,
                  en: 'Train',
                  fa: 'قطار',
                  ar: 'القطار',
                  zh: '火车票',
                ),
                foreground: Colors.white,
                onTap: () => Get.to(() => const TrainSearchScreen()),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ServiceTile(
                color: const Color(0xFF456A8C),
                icon: Icons.directions_car_rounded,
                label: l10nPick(
                  context,
                  en: 'Car Rental',
                  fa: 'اجاره خودرو',
                  ar: 'تأجير سيارات',
                  zh: '租车自驾',
                ),
                foreground: Colors.white,
                onTap: () => Get.to(() => const RentalHomeScreen()),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ServiceTile(
                color: const Color(0xFF0D9488),
                icon: Icons.local_taxi_rounded,
                label: l10nPick(
                  context,
                  en: 'Taxi',
                  fa: 'ترانسفر و تاکسی',
                  ar: 'تاكسي وتوصيل',
                  zh: '接送专车',
                ),
                foreground: Colors.white,
                onTap: () => Get.to(() => const TaxiSearchScreen()),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ServiceTile(
                color: const Color(0xFF2563EB),
                icon: Icons.health_and_safety_rounded,
                label: l10nPick(
                  context,
                  en: 'Insurance',
                  fa: 'بیمه سفر',
                  ar: 'تأمين السفر',
                  zh: '旅游保险',
                ),
                foreground: Colors.white,
                onTap: () => Get.to(() => const TravelInsuranceScreen()),
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: _ServiceTile(
                color: const Color(0xFFE60000),
                icon: Icons.phone_android_rounded,
                label: l10nPick(
                  context,
                  en: 'SIM Top-Up',
                  fa: 'شارژ سیم‌کارت',
                  ar: 'شحن رصيد',
                  zh: '话费充值',
                ),
                foreground: Colors.white,
                onTap: () => Get.to(() => const SimTopUpScreen()),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        // VIP CIP & Airport Lounge Banner
        InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: () => Get.to(() => const CipLoungeReservationScreen()),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
              ),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.airline_seat_recline_extra_rounded,
                    color: Color(0xFFD4AF37),
                    size: 20,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Airport CIP & VIP Lounge',
                          fa: 'تشریفات فرودگاهی و لانژ CIP',
                          ar: 'خدمات كبار الشخصيات بالمطار (CIP)',
                          zh: '机场贵宾室 (CIP)',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        l10nPick(
                          context,
                          en: 'Fast-track passport, private transfer & dining buffet',
                          fa: 'گیت اختصاصی، ترانسفر پای پرواز و بوفه پذیرایی',
                          ar: 'مسار سريع، نقل خاص وبوفيه مفتوح',
                          zh: '专属安检通道、摆渡专车与自助餐饮',
                        ),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: const Color(0xFFD4AF37),
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _openService(TravelProductType type) {
    switch (type) {
      case TravelProductType.hotel:
        Get.to(() => const HotelSearchScreen());
        return;
      case TravelProductType.flight:
        Get.to(() => const FlightSearchScreen());
        return;
      case TravelProductType.esim:
        Get.to(() => const EsimIntroScreen());
        return;
    }
  }
}

class _ServiceTile extends StatelessWidget {
  final Color color;
  final Color foreground;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.color,
    required this.icon,
    required this.label,
    required this.onTap,
    this.foreground = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = TravelTheme.isDark(context);
    final iconBg = isDark
        ? AppColors.darkSurface
        : Colors.white.withValues(alpha: 0.94);

    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
        child: InkWell(
          onTap: () {
            AppHaptics.light();
            onTap();
          },
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                SizedBox(height: AppSpacing.md.h),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 11.sp,
                    height: 1.25,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final TravelActivity activity;

  const _ActivityTile({required this.activity});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final color = activity.isCredit
        ? TravelTheme.green
        : travelProductColor(activity.type ?? TravelProductType.hotel);
    return TravelCard(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
      child: Row(
        children: [
          Container(
            width: 46.r,
            height: 46.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Icon(
              activity.isCredit
                  ? Icons.account_balance_wallet_rounded
                  : travelProductIcon(
                      activity.type ?? TravelProductType.hotel,
                    ),
              color: color,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travelLocalizedKey(localization, activity.titleKey),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  travelLocalizedKey(localization, activity.subtitleKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: TravelTheme.muted,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              '${activity.isCredit ? '+' : '-'}${travelMoney(context, activity.amount)}',
              style: TextStyle(
                color: activity.isCredit ? TravelTheme.green : TravelTheme.red,
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

