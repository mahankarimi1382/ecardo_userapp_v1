import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

import '../bookings/travel_orders_screen.dart';
import '../core/models/travel_models.dart';
import '../shared/travel_theme.dart';
import '../shared/travel_widgets.dart';
import '../travelers/travelers_screen.dart';
import 'travel_history_screen.dart';

class TravelAccountScreen extends StatelessWidget {
  const TravelAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final user = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>().userModel.value.data
        : null;
    return TravelPage(
      title: localization.travelAccount,
      child: ListView(
        padding: EdgeInsets.all(20.r),
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              borderRadius: TravelTheme.radius,
              gradient: const LinearGradient(
                colors: [Color(0xFF005AB6), TravelTheme.blue],
              ),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: TravelTheme.blue,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.fullName?.isNotEmpty == true
                            ? user!.fullName!
                            : localization.travelAccountHolder,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        localization.travelMemberDescription,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: .8),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          _AccountTile(
            icon: Icons.hotel_rounded,
            title: localization.travelMyHotels,
            subtitle: localization.travelMyHotelsDescription,
            onTap: () => Get.to(
              () => const TravelOrdersScreen(
                initialType: TravelProductType.hotel,
              ),
            ),
          ),
          _AccountTile(
            icon: Icons.flight_rounded,
            title: localization.travelMyFlights,
            subtitle: localization.travelMyFlightsDescription,
            onTap: () => Get.to(
              () => const TravelOrdersScreen(
                initialType: TravelProductType.flight,
              ),
            ),
          ),
          _AccountTile(
            icon: Icons.sim_card_rounded,
            title: localization.travelMyEsims,
            subtitle: localization.travelMyEsimsDescription,
            onTap: () => Get.to(
              () => const TravelOrdersScreen(
                initialType: TravelProductType.esim,
              ),
            ),
          ),
          _AccountTile(
            icon: Icons.luggage_rounded,
            title: localization.travelAllBookings,
            subtitle: localization.travelMyBookingsDescription,
            onTap: () => Get.to(() => const TravelOrdersScreen()),
          ),
          _AccountTile(
            icon: Icons.people_alt_outlined,
            title: localization.travelSavedTravelers,
            subtitle: localization.travelSavedTravelersDescription,
            onTap: () => Get.to(() => const TravelersScreen()),
          ),
          _AccountTile(
            icon: Icons.badge_outlined,
            title: localization.travelPersonalInformation,
            subtitle: localization.travelPersonalInformationDescription,
            onTap: () => Get.toNamed(BaseRoute.profileSettings),
          ),
          _AccountTile(
            icon: Icons.history_rounded,
            title: localization.travelHistory,
            subtitle: localization.travelHistoryDescription,
            onTap: () => Get.to(() => const TravelHistoryScreen()),
          ),
          _AccountTile(
            icon: Icons.account_balance_wallet_outlined,
            title: localization.travelMainWallet,
            subtitle: localization.travelWalletSharedDescription,
            onTap: () => Get.toNamed(BaseRoute.addMoney),
          ),
        ],
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _AccountTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TravelCard(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(11.r),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF3FF),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Icon(icon, color: TravelTheme.blue),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: TextStyle(color: TravelTheme.muted, fontSize: 10.sp),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded),
          ],
        ),
      ),
    );
  }
}
