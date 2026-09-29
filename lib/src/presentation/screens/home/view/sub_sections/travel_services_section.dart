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
import 'package:ecardo_user/src/presentation/screens/travel/services/catalog_service_screens.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/extra_service_registry.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/quick_service_screens.dart';
import 'package:ecardo_user/src/presentation/screens/travel/trains/train_screens.dart';
import 'package:ecardo_user/src/presentation/screens/travel/visa/visa_screens.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';

/// Travel services card — same tile grid language as financial / business.
///
/// v1.0.52: destination country chips removed from the dashboard; country
/// selection belongs inside each service flow.
///
/// vNext (travel services expansion): every extra service tile is live.
/// Trains mirror the flights skeleton on a deterministic demo catalog; visa
/// is an internal application form landing in the under-review state; the
/// remaining services browse curated in-app catalogs / request forms. All
/// extra-service submissions live in the local request book (no backend
/// contract yet) — see travel/services/travel_service_request.dart.
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
      // Extra services — demo catalogs + internal request forms.
      ServiceTile(
        title: localization.travelServiceVisa,
        iconData: Icons.approval_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const VisaIntroScreen(),
      ),
      ServiceTile(
        title: localization.travelServiceTrain,
        iconData: Icons.train_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const TrainSearchScreen(),
      ),
      ServiceTile(
        title: localization.travelServiceCarRental,
        iconData: Icons.directions_car_rounded,
        route: BaseRoute.rentalHome,
        available: true,
      ),
      ServiceTile(
        title: localization.travelServiceTaxi,
        iconData: Icons.local_taxi_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => taxiRequestScreen(localization),
      ),
      ServiceTile(
        title: localization.travelServiceTour,
        iconData: Icons.tour_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('tour')),
      ),
      ServiceTile(
        title: localization.travelServiceBoat,
        iconData: Icons.directions_boat_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('boat')),
      ),
      ServiceTile(
        title: localization.travelServiceLocal,
        iconData: Icons.place_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('local')),
      ),
      ServiceTile(
        title: localization.travelServiceFood,
        iconData: Icons.delivery_dining_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('food')),
      ),
      ServiceTile(
        title: localization.travelServiceSupermarket,
        iconData: Icons.storefront_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('supermarket')),
      ),
      ServiceTile(
        title: localization.travelServiceRestaurant,
        iconData: Icons.restaurant_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('restaurant')),
      ),
      ServiceTile(
        title: localization.travelServiceStore,
        iconData: Icons.shopping_bag_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('store')),
      ),
      ServiceTile(
        title: localization.travelServiceTranslator,
        iconData: Icons.translate_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('translator')),
      ),
      ServiceTile(
        title: localization.travelServiceEmergency,
        iconData: Icons.support_agent_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const EmergencyServiceScreen(),
      ),
      ServiceTile(
        title: localization.travelServiceAliPay,
        iconData: Icons.account_balance_wallet_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => WalletServiceScreen(
          serviceKey: 'aliPay',
          brandStart: const Color(0xFF1677FF),
          brandEnd: const Color(0xFF0E42A8),
          description: (localization) => localization.travelAliPayDescription,
        ),
      ),
      ServiceTile(
        title: localization.travelServiceMirPay,
        iconData: Icons.credit_card_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => WalletServiceScreen(
          serviceKey: 'mirPay',
          brandStart: const Color(0xFF2BB673),
          brandEnd: const Color(0xFF157A4A),
          description: (localization) => localization.travelMirPayDescription,
        ),
      ),
      ServiceTile(
        title: localization.travelServiceSimTopUp,
        iconData: Icons.phone_android_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => simTopUpRequestScreen(localization),
      ),
      ServiceTile(
        title: localization.travelServiceInsurance,
        iconData: Icons.health_and_safety_rounded,
        route: '',
        available: travelOn,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () =>
            CatalogServiceScreen(config: extraServiceConfig('insurance')),
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
