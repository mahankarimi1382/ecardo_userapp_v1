import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/service_tiles.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';

/// v1.0.45 (SERVICES HUB): the old flat "other services" card becomes a
/// two-tab services hub —
///   tab 1  خدمات مالی (Financial Services)   → the existing money services
///                                             grid (dynamic password kept
///                                             as its first tile)
///   tab 2  خدمات سفر (Travel Services)       → the travel card: destination
///                                             country chips + travel
///                                             services. Built modules
///                                             (flight / hotel / eSIM) open
///                                             the travel module with the
///                                             chosen destination; services
///                                             not built yet show greyed
///                                             with a lock and explain on
///                                             tap (notBuilt state).
///
/// Remittance and P2P escrow moved to the dedicated business services
/// section below this card.
class OtherServicesSection extends StatefulWidget {
  const OtherServicesSection({super.key});

  @override
  State<OtherServicesSection> createState() => _OtherServicesSectionState();
}

class _OtherServicesSectionState extends State<OtherServicesSection> {
  final HomeController homeController = Get.find();
  final SettingsService settings = Get.find();

  static const int _financialTab = 0;
  static const int _travelTab = 1;

  int _selectedTab = _financialTab;

  /// v1.0.45: destination countries the travel module currently serves —
  /// chips select the destination passed to the travel module.
  static const List<String> _destinationCountries = [
    'CN',
    'RU',
    'TR',
    'AE',
    'IQ',
    'OM',
    'GE',
  ];
  int _selectedCountryIndex = 0;

  List<ServiceTile> _financialServiceList(Addons? addons) {
    final localization = AppLocalizations.of(context)!;

    return [
      ServiceTile(
        title: localization.otherServicesDynamicPassword,
        iconData: Icons.pin_rounded,
        route: BaseRoute.dynamicPassword,
      ),
      ServiceTile(
        title: localization.otherServicesQrCode,
        icon: PngAssets.qrCodeService,
        route: BaseRoute.qrCode,
      ),
      ServiceTile(
        title: localization.otherServicesAddMoney,
        icon: PngAssets.addMoneyService,
        route: BaseRoute.addMoney,
        available: settings.getSetting("user_deposit") == "1",
      ),
      ServiceTile(
        title: localization.otherServicesCashOut,
        icon: PngAssets.cashOutService,
        route: BaseRoute.cashOut,
        feature: 'cashout',
        available: settings.getSetting("agent_system") == "1",
      ),
      ServiceTile(
        title: localization.otherServicesMakePayment,
        icon: PngAssets.makePaymentService,
        route: BaseRoute.makePayment,
        available: settings.getSetting("merchant_system") == "1",
      ),
      ServiceTile(
        title: localization.otherServicesTransactions,
        icon: PngAssets.transactionService,
        route: BaseRoute.transactions,
      ),
      ServiceTile(
        title: localization.otherServicesPaymentLinks,
        icon: PngAssets.paymentLinksService,
        route: BaseRoute.paymentLinks,
        feature: 'payment-links',
      ),
      ServiceTile(
        title: localization.otherServicesRequestMoney,
        icon: PngAssets.requestMoneyService,
        route: BaseRoute.requestMoney,
        feature: 'request-money',
      ),
      ServiceTile(
        title: localization.otherServicesGift,
        icon: PngAssets.giftService,
        route: BaseRoute.giftCode,
        feature: 'gift_send',
        available: settings.getSetting("user_gift") == "1",
      ),
      ServiceTile(
        title: localization.otherServicesWallets,
        icon: PngAssets.walletsService,
        route: BaseRoute.wallets,
      ),
      ServiceTile(
        title: localization.otherServicesWithdraw,
        icon: PngAssets.withdrawService,
        route: BaseRoute.withdraw,
        feature: 'withdraw',
      ),
      ServiceTile(
        title: localization.otherServicesExchange,
        icon: PngAssets.exchangeService,
        route: BaseRoute.exchange,
        feature: 'exchange',
      ),
      ServiceTile(
        title: localization.otherServicesTransfer,
        icon: PngAssets.transferService,
        route: BaseRoute.transfer,
        feature: 'transfer',
      ),
      ServiceTile(
        title: localization.otherServicesInvite,
        icon: PngAssets.inviteService,
        route: BaseRoute.referral,
      ),
      ServiceTile(
        title: localization.otherServicesBillPayment,
        icon: PngAssets.billPaymentService,
        route: BaseRoute.billPayment,
        feature: 'pay-bill',
      ),
      ServiceTile(
        title: localization.otherServicesVirtualCard,
        icon: PngAssets.virtualCardService,
        route: BaseRoute.virtualCard,
        feature: 'paycardo',
        available: addons?.virtualCards == true,
      ),
      ServiceTile(
        title: localization.otherServicesGiftCards,
        icon: PngAssets.giftCardsService,
        route: BaseRoute.giftCard,
        feature: 'gift_redeem',
        available: addons?.giftCards == true,
      ),
    ];
  }

  List<ServiceTile> _travelServiceList(Addons? addons) {
    final localization = AppLocalizations.of(context)!;

    Map<String, dynamic> destinationArgs() => <String, dynamic>{
          'destination_country':
              _destinationCountries[_selectedCountryIndex],
        };

    // Built travel modules — gated by the travel addon + tiered feature
    // key, exactly like the old single travel tile.
    return [
      ServiceTile(
        title: localization.travelFlights,
        iconData: Icons.flight_rounded,
        route: BaseRoute.travel,
        feature: 'travel',
        available: addons?.travel == true,
        argumentsBuilder: destinationArgs,
      ),
      ServiceTile(
        title: localization.travelHotels,
        iconData: Icons.hotel_rounded,
        route: BaseRoute.travel,
        feature: 'travel',
        available: addons?.travel == true,
        argumentsBuilder: destinationArgs,
      ),
      ServiceTile(
        title: localization.travelEsim,
        iconData: Icons.sim_card_rounded,
        route: BaseRoute.travel,
        feature: 'travel',
        available: addons?.travel == true,
        argumentsBuilder: destinationArgs,
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

  List<ResolvedTile> _resolvedFinancialTiles(Addons? addons, KycBadge? badge) {
    return _financialServiceList(
      addons,
    ).map((tile) => resolveTile(tile, badge)).toList(growable: false);
  }

  List<ResolvedTile> _resolvedTravelTiles(Addons? addons, KycBadge? badge) {
    return _travelServiceList(
      addons,
    ).map((tile) => resolveTile(tile, badge)).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── ALL Rx reads happen HERE, synchronously inside the Obx scope. ──
      final addons = homeController.userModel.value.data?.addons;
      final KycBadge? badge = currentKycBadge();

      final localization = AppLocalizations.of(context)!;
      final isTravelTab = _selectedTab == _travelTab;
      final sectionTitle = isTravelTab
          ? localization.travelServicesTitle
          : localization.financialServicesTitle;
      final tiles = isTravelTab
          ? _resolvedTravelTiles(addons, badge)
          : _resolvedFinancialTiles(addons, badge);

      return Column(
        children: [
          SectionHeader(sectionName: sectionTitle, isShowNavigateAction: false),
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
                _buildTabSwitch(localization),
                const SizedBox(height: 16),
                if (isTravelTab) ...[
                  Padding(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 10,
                    ),
                    child: Text(
                      localization.travelServicesHint,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.lightTextPrimary.withValues(
                          alpha: 0.55,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildDestinationChips(),
                  const SizedBox(height: 14),
                ],
                PagedServiceTilesGrid(tiles: tiles),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildTabSwitch(AppLocalizations localization) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabOption(
              label: localization.financialServicesTitle,
              isSelected: _selectedTab == _financialTab,
              onTap: () => setState(() => _selectedTab = _financialTab),
            ),
          ),
          Expanded(
            child: _buildTabOption(
              label: localization.travelServicesTitle,
              isSelected: _selectedTab == _travelTab,
              onTap: () => setState(() => _selectedTab = _travelTab),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: 34,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightPrimary : AppColors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: isSelected
                  ? AppColors.white
                  : AppColors.lightTextPrimary.withValues(alpha: 0.60),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDestinationChips() {
    final localization = AppLocalizations.of(context)!;
    final countryNames = _destinationCountries
        .map((code) => _countryName(localization, code))
        .toList(growable: false);

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 10),
        itemCount: countryNames.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCountryIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedCountryIndex = index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
              alignment: Alignment.center,
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
        },
      ),
    );
  }

  String _countryName(AppLocalizations localization, String code) {
    switch (code) {
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
