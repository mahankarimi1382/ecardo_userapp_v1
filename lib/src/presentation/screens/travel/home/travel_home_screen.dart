import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';

import '../account/travel_account_screen.dart';
import '../bookings/travel_orders_screen.dart';
import '../core/models/travel_models.dart';
import '../esim/esim_intro_screen.dart';
import '../flights/flight_search_screen.dart';
import '../hotels/hotel_search_screen.dart';
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
            SizedBox(height: 8.h),
            Obx(
              () =>
                  controller.isActivityLoading.value &&
                  controller.activity.isEmpty
                  ? const SizedBox(height: 120, child: CommonLoading())
                  : controller.activity.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      children: controller.activity
                          .take(3)
                          .map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 10.h),
                              child: _ActivityTile(activity: item),
                            ),
                          )
                          .toList(),
                    ),
            ),
            SizedBox(height: 14.h),
            TravelCard(
              color: const Color(0xFFEAF3FF),
              onTap: () => Get.toNamed(
                BaseRoute.addMoney,
                arguments: {'returnRoute': BaseRoute.travel},
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: TravelTheme.green,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          localization.travelMainWallet,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          localization.travelWalletSharedDescription,
                          style: TextStyle(
                            color: TravelTheme.muted,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
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
    return Container(
      height: 205.h,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        borderRadius: TravelTheme.radius,
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [Color(0xFF0D47A1), TravelTheme.blue, TravelTheme.purple],
        ),
        boxShadow: TravelTheme.shadow,
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
                SizedBox(height: 8.h),
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
        return const SizedBox(height: 112, child: CommonLoading());
      }
      if (hasError) {
        return Column(
          children: [
            TravelEmptyState(message: localization.allControllerLoadError),
            CommonButton(
              width: double.infinity,
              text: localization.noInternetConnectionRetryButton,
              onPressed: onRetry,
            ),
          ],
        );
      }
      return TravelEmptyState(message: localization.travelOfferUnavailable);
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

    return Row(
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
          if (index < visibleServices.length - 1) SizedBox(width: 12.w),
        ],
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
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(24.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 6.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50.r,
                  height: 50.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.94),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color),
                ),
                SizedBox(height: 12.h),
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
