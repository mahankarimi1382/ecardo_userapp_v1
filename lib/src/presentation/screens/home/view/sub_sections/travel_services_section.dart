import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/bindings/app_bindings.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/service_tiles.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/esim_intro_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/flights/flight_search_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/hotel_search_screen.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';

/// Travel services card — same tile grid language as financial / business.
///
/// v1.0.52: destination country chips removed from the dashboard; country
/// selection belongs inside each service flow. Hotels / Flights / eSIM are
/// live modules (addon-gated only, no KYC feature lock on the tile). The
/// rest stay greyed notBuilt until their screens ship.
class TravelServicesSection extends StatefulWidget {
  const TravelServicesSection({super.key});

  @override
  State<TravelServicesSection> createState() => _TravelServicesSectionState();
}

class _TravelServicesSectionState extends State<TravelServicesSection> {
  final HomeController homeController = Get.find();

  void _ensureTravelController() {
    if (!Get.isRegistered<TravelController>()) {
      TravelBinding().dependencies();
    }
  }

  List<ServiceTile> _travelServiceList(Addons? addons) {
    final localization = AppLocalizations.of(context)!;
    final travelOn = addons?.travel == true;

    return [
      // Live modules — uniform tiles, no dashboard country picker.
      ServiceTile(
        title: localization.travelHotels,
        iconData: Icons.hotel_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const HotelSearchScreen(),
      ),
      ServiceTile(
        title: localization.travelFlights,
        iconData: Icons.flight_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const FlightSearchScreen(),
      ),
      ServiceTile(
        title: localization.travelEsim,
        iconData: Icons.sim_card_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const EsimIntroScreen(),
      ),
      // Not shipped yet — same size tiles, grey + lock (notBuilt).
      ServiceTile(
        title: localization.travelServiceVisa,
        iconData: Icons.approval_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceTrain,
        iconData: Icons.train_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceCarRental,
        iconData: Icons.directions_car_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceTaxi,
        iconData: Icons.local_taxi_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceTour,
        iconData: Icons.tour_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceBoat,
        iconData: Icons.directions_boat_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceLocal,
        iconData: Icons.place_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceFood,
        iconData: Icons.delivery_dining_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceSupermarket,
        iconData: Icons.storefront_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceRestaurant,
        iconData: Icons.restaurant_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceStore,
        iconData: Icons.shopping_bag_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceTranslator,
        iconData: Icons.translate_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceEmergency,
        iconData: Icons.support_agent_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceAliPay,
        iconData: Icons.account_balance_wallet_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceMirPay,
        iconData: Icons.credit_card_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceSimTopUp,
        iconData: Icons.phone_android_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceInsurance,
        iconData: Icons.health_and_safety_rounded,
        route: '',
        available: false,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final addons = homeController.userModel.value.data?.addons;
      final KycBadge? badge = currentKycBadge();
      final localization = AppLocalizations.of(context)!;
      final tiles = _travelServiceList(addons)
          .map((tile) => resolveTile(tile, badge))
          .toList(growable: false);

      return Column(
        children: [
          SectionHeader(
            sectionName: localization.travelServicesTitle,
            isShowNavigateAction: false,
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.white,
            ),
            child: PagedServiceTilesGrid(tiles: tiles),
          ),
        ],
      );
    });
  }
}
