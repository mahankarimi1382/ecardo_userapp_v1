import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/bindings/app_bindings.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/esim_intro_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/flights/flight_search_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/hotel_search_screen.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Travel dashboard card — v1.0.50 redesign.
///
/// Layout (intentional, not a flat 20-tile soup):
///   1. Destination chips
///   2. **Available now** — Hotels / Flights / eSIM (live modules, no KYC
///      feature lock — only the `travel` addon gate)
///   3. **Coming soon** — compact muted chips for modules not shipped yet
class TravelServicesSection extends StatefulWidget {
  const TravelServicesSection({super.key});

  @override
  State<TravelServicesSection> createState() => _TravelServicesSectionState();
}

class _TravelServicesSectionState extends State<TravelServicesSection> {
  final HomeController homeController = Get.find();

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
    if (!Get.isRegistered<TravelController>()) {
      TravelBinding().dependencies();
    }
  }

  void _openReady(Widget Function() pageBuilder) {
    _ensureTravelController();
    Get.to(
      () => pageBuilder(),
      arguments: _destinationArgs(),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final addons = homeController.userModel.value.data?.addons;
      final localization = AppLocalizations.of(context)!;
      final travelOn = addons?.travel == true;

      return Column(
        children: [
          SectionHeader(
            sectionName: localization.travelServicesTitle,
            isShowNavigateAction: false,
          ),
          const SizedBox(height: 16),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 18),
            padding: const EdgeInsets.fromLTRB(14, 18, 14, 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.travelServicesHint,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 12),
                _buildDestinationChips(localization),
                const SizedBox(height: 18),
                _sectionLabel(
                  localization.travelAvailableNow,
                  AppColors.lightPrimary,
                ),
                const SizedBox(height: 10),
                _buildReadyRow(localization, travelOn),
                const SizedBox(height: 18),
                _sectionLabel(
                  localization.travelComingSoonSection,
                  AppColors.lightTextTertiary,
                ),
                const SizedBox(height: 10),
                _buildComingSoonWrap(localization),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _sectionLabel(String text, Color accent) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  /// Three equal primary cards — Hotels / Flights / eSIM.
  /// No KYC `feature` gate: these modules are usable without upgrade; the
  /// server still enforces addon + auth on booking APIs.
  Widget _buildReadyRow(AppLocalizations localization, bool travelOn) {
    final items = <_ReadyTravelItem>[
      _ReadyTravelItem(
        title: localization.travelHotels,
        icon: Icons.hotel_rounded,
        onTap: travelOn
            ? () => _openReady(() => const HotelSearchScreen())
            : () => ToastHelper().showErrorToast(localization.commonComingSoon),
        enabled: travelOn,
      ),
      _ReadyTravelItem(
        title: localization.travelFlights,
        icon: Icons.flight_rounded,
        onTap: travelOn
            ? () => _openReady(() => const FlightSearchScreen())
            : () => ToastHelper().showErrorToast(localization.commonComingSoon),
        enabled: travelOn,
      ),
      _ReadyTravelItem(
        title: localization.travelEsim,
        icon: Icons.sim_card_rounded,
        onTap: travelOn
            ? () => _openReady(() => const EsimIntroScreen())
            : () => ToastHelper().showErrorToast(localization.commonComingSoon),
        enabled: travelOn,
      ),
    ];

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(child: _ReadyTravelCard(item: items[i])),
        ],
      ],
    );
  }

  Widget _buildComingSoonWrap(AppLocalizations localization) {
    final upcoming = <(String, IconData)>[
      (localization.travelServiceVisa, Icons.approval_rounded),
      (localization.travelServiceTrain, Icons.train_rounded),
      (localization.travelServiceCarRental, Icons.directions_car_rounded),
      (localization.travelServiceTaxi, Icons.local_taxi_rounded),
      (localization.travelServiceTour, Icons.tour_rounded),
      (localization.travelServiceBoat, Icons.directions_boat_rounded),
      (localization.travelServiceLocal, Icons.place_rounded),
      (localization.travelServiceFood, Icons.delivery_dining_rounded),
      (localization.travelServiceSupermarket, Icons.storefront_rounded),
      (localization.travelServiceRestaurant, Icons.restaurant_rounded),
      (localization.travelServiceStore, Icons.shopping_bag_rounded),
      (localization.travelServiceTranslator, Icons.translate_rounded),
      (localization.travelServiceEmergency, Icons.support_agent_rounded),
      (localization.travelServiceAliPay, Icons.account_balance_wallet_rounded),
      (localization.travelServiceMirPay, Icons.credit_card_rounded),
      (localization.travelServiceSimTopUp, Icons.phone_android_rounded),
      (localization.travelServiceInsurance, Icons.health_and_safety_rounded),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final (title, icon) in upcoming)
          _ComingSoonChip(
            title: title,
            icon: icon,
            onTap: () => ToastHelper()
                .showErrorToast(localization.serviceNotAvailableYet),
          ),
      ],
    );
  }

  Widget _buildDestinationChips(AppLocalizations localization) {
    final countryNames = _destinationCountries
        .map((code) => _countryName(localization, code))
        .toList(growable: false);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(countryNames.length, (index) {
          final isSelected = index == _selectedCountryIndex;
          return Padding(
            padding: EdgeInsetsDirectional.only(
              end: index == countryNames.length - 1 ? 0 : 8,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCountryIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                padding: const EdgeInsetsDirectional.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.lightPrimary
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.lightPrimary
                        : AppColors.lightTextPrimary.withValues(alpha: 0.12),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.lightPrimary.withValues(alpha: 0.22),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
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

class _ReadyTravelItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _ReadyTravelItem({
    required this.title,
    required this.icon,
    required this.onTap,
    required this.enabled,
  });
}

class _ReadyTravelCard extends StatelessWidget {
  final _ReadyTravelItem item;

  const _ReadyTravelCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: item.enabled ? 1 : 0.5,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.lightPrimary.withValues(alpha: 0.10),
                  AppColors.lightPrimary.withValues(alpha: 0.04),
                ],
              ),
              border: Border.all(
                color: AppColors.lightPrimary.withValues(alpha: 0.14),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightPrimary.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.lightPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.9),
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

class _ComingSoonChip extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ComingSoonChip({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100),
        child: Container(
          padding: const EdgeInsetsDirectional.only(
            start: 10,
            end: 12,
            top: 7,
            bottom: 7,
          ),
          decoration: BoxDecoration(
            color: AppColors.lightBackground,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.08),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: AppColors.lightTextTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0,
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.45),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
