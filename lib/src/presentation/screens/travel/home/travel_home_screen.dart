import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';

import '../account/travel_account_screen.dart';
import '../bookings/travel_orders_screen.dart';
import '../core/controller/travel_controller.dart';
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
    final controller = Get.find<TravelController>();

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
            _Hero(localization: localization),
            SizedBox(height: 22.h),
            Row(
              children: [
                Expanded(
                  child: _ServiceTile(
                    color: TravelTheme.blue,
                    icon: Icons.flight_rounded,
                    label: localization.travelFlights,
                    onTap: () => Get.to(() => const FlightSearchScreen()),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ServiceTile(
                    color: TravelTheme.purple,
                    icon: Icons.hotel_rounded,
                    label: localization.travelHotels,
                    onTap: () => Get.to(() => const HotelSearchScreen()),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _ServiceTile(
                    color: TravelTheme.yellow,
                    icon: Icons.sim_card_rounded,
                    label: localization.travelEsim,
                    foreground: TravelTheme.ink,
                    onTap: () => Get.to(() => const EsimIntroScreen()),
                  ),
                ),
              ],
            ),
            SizedBox(height: 28.h),
            TravelSectionHeader(
              title: localization.travelRecentActivity,
              action: localization.travelViewAll,
              onAction: () => Get.to(() => const TravelOrdersScreen()),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => controller.isLoading.value && controller.activity.isEmpty
                  ? const Center(child: CircularProgressIndicator())
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
              onTap: () => Get.toNamed(BaseRoute.addMoney),
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
}

class _Hero extends StatelessWidget {
  final AppLocalizations localization;

  const _Hero({required this.localization});

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
                  localization.travelHeroEyebrow,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.84),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  localization.travelHeroTitle,
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
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(24.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 6.w),
          child: Column(
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
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: foreground,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
