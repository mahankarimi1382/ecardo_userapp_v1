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
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/esim_intro_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/flights/flight_search_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/hotel_search_screen.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';

/// v1.0.46 (TRAVEL SERVICES): the travel card as its own dashboard section.
/// Destination-country chips (Iran added, Wrap layout so every chip fits) +
/// the traveler services. The modules that exist open their real screens
/// directly (flights → flight search, hotels → hotel search, eSIM → eSIM
/// intro) with the chosen destination country attached; the services not
/// built in the travel module yet stay greyed with a lock and explain the
/// KYC requirement on tap (notBuilt state).
class TravelServicesSection extends StatefulWidget {
  const TravelServicesSection({super.key});

  @override
  State<TravelServicesSection> createState() => _TravelServicesSectionState();
}

class _TravelServicesSectionState extends State<TravelServicesSection> {
  final HomeController homeController = Get.find();

  /// Destination countries the travel module currently serves.
  static const List<String> _destinationCountries = [
    'IR',
    'CN',
    'RU',
    'TR',
    'AE',
    'IQ',
    'OM',
    'GE',
  ];
  int _selectedCountryIndex = 0;

  String get _selectedCountry => _destinationCountries[_selectedCountryIndex];

  Map<String, dynamic> _destinationArgs() => <String, dynamic>{
        'destination_country': _selectedCountry,
      };

  void _ensureTravelController() {
    // The travel route binding registers this lazily; when the dashboard
    // opens a travel screen directly the controller must exist first.
    if (!Get.isRegistered<TravelController>()) {
      TravelBinding().dependencies();
    }
  }

  List<ServiceTile> _travelServiceList(Addons? addons) {
    final localization = AppLocalizations.of(context)!;
    final travelOn = addons?.travel == true;

    return [
      ServiceTile(
        title: localization.travelHotels,
        iconData: Icons.hotel_rounded,
        route: '',
        feature: 'travel',
        available: travelOn,
        argumentsBuilder: _destinationArgs,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const HotelSearchScreen(),
      ),
      ServiceTile(
        title: localization.travelFlights,
        iconData: Icons.flight_rounded,
        route: '',
        feature: 'travel',
        available: travelOn,
        argumentsBuilder: _destinationArgs,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const FlightSearchScreen(),
      ),
      ServiceTile(
        title: localization.travelEsim,
        iconData: Icons.sim_card_rounded,
        route: '',
        feature: 'travel',
        available: travelOn,
        argumentsBuilder: _destinationArgs,
        beforeNavigate: _ensureTravelController,
        pageBuilder: () => const EsimIntroScreen(),
      ),
      // Not built in the travel module yet — greyed with a lock; tapping
      // explains availability + the KYC level requirement.
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
        iconData: Icons.map_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceFood,
        iconData: Icons.restaurant_menu_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.travelServiceSupermarket,
        iconData: Icons.shopping_basket_rounded,
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
        iconData: Icons.storefront_rounded,
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
        iconData: Icons.emergency_rounded,
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
      // ── ALL Rx reads happen HERE, synchronously inside the Obx scope. ──
      final addons = homeController.userModel.value.data?.addons;
      final KycBadge? badge = currentKycBadge();

      final localization = AppLocalizations.of(context)!;
      final tiles = _travelServiceList(
        addons,
      ).map((tile) => resolveTile(tile, badge)).toList(growable: false);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
                  child: Text(
                    localization.travelServicesHint,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.55),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDestinationChips(localization),
                const SizedBox(height: 14),
                PagedServiceTilesGrid(tiles: tiles),
              ],
            ),
          ),
        ],
      );
    });
  }

  /// Compact destination chips in a Wrap — every chip always fits (no
  /// horizontal cutoff), Iran included.
  Widget _buildDestinationChips(AppLocalizations localization) {
    final countryNames = _destinationCountries
        .map((code) => _countryName(localization, code))
        .toList(growable: false);

    return Padding(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(countryNames.length, (index) {
          final isSelected = index == _selectedCountryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCountryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsetsDirectional.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.lightPrimary
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected
                      ? AppColors.lightPrimary
                      : AppColors.lightTextPrimary.withValues(alpha: 0.14),
                ),
              ),
              child: Text(
                countryNames[index],
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: isSelected
                      ? AppColors.white
                      : AppColors.lightTextPrimary.withValues(alpha: 0.65),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  String _countryName(AppLocalizations localization, String code) {
    switch (code) {
      case 'IR':
        return localization.countryIran;
      case 'CN':
        return localization.countryChina;
      case 'RU':
        return localization.countryRussia;
      case 'TR':
        return localization.countryTurkey;
      case 'AE':
        return localization.countryUAE;
      case 'IQ':
        return localization.countryIraq;
      case 'OM':
        return localization.countryOman;
      case 'GE':
        return localization.countryGeorgia;
      default:
        return code;
    }
  }
}
