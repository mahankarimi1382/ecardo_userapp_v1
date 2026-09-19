import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';

/// v1.0.37 (SUPER-APP GRID): every tile is in one of three states —
///   available   → navigates to the module
///   kycLocked   → greyed with a lock badge; tapping opens the
///                 UpgradeRequiredScreen which resolves the required level
///                 from the tiered KYC system (server feature keys)
///   comingSoon  → greyed; tapping shows a localized "coming soon" toast
///                 (module disabled by addon / admin toggle on this
///                 deployment)
/// Gating truth stays server-side (the 403 KYC contract enforces it); the
/// grid is the user-facing mirror of it.
///
/// v1.0.43 (CRITICAL Obx fix): ALL Rx reads (userModel addons, KYC badge)
/// happen synchronously INSIDE the Obx builder scope. The previous
/// structure read them from GridView's deferred itemBuilder — outside GetX's
/// registration window — so the Obx registered ZERO observables and GetX
/// threw "improper use of a GetX" on every build, grey-screening the
/// dashboard right after the wallet section (the reported regression).
enum _TileState { available, kycLocked, comingSoon }

class _ServiceTile {
  final String title;
  final String? icon;
  final IconData? iconData;
  final String route;
  final String? feature;
  final bool available;

  const _ServiceTile({
    required this.title,
    this.icon,
    this.iconData,
    required this.route,
    this.feature,
    this.available = true,
  });
}

class _ResolvedTile {
  final _ServiceTile tile;
  final _TileState state;

  const _ResolvedTile(this.tile, this.state);
}

class OtherServicesSection extends StatefulWidget {
  const OtherServicesSection({super.key});

  @override
  State<OtherServicesSection> createState() => _OtherServicesSectionState();
}

class _OtherServicesSectionState extends State<OtherServicesSection> {
  final HomeController homeController = Get.find();
  final SettingsService settings = Get.find();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  /// Tiered feature check — fail-open when the KYC badge is not ready yet
  /// (fresh navigation frame); the server 403 contract is the enforcement
  /// anyway.
  bool _hasFeature(String? feature, KycBadge? badge) {
    if (feature == null) return true;
    if (badge == null) return true;
    return badge.hasFeature(feature);
  }

  _ResolvedTile _resolve(_ServiceTile tile, KycBadge? badge) {
    if (!tile.available) return _ResolvedTile(tile, _TileState.comingSoon);
    if (!_hasFeature(tile.feature, badge)) {
      return _ResolvedTile(tile, _TileState.kycLocked);
    }
    return _ResolvedTile(tile, _TileState.available);
  }

  void _onTileTap(_ResolvedTile resolved) {
    final localization = AppLocalizations.of(context)!;
    switch (resolved.state) {
      case _TileState.available:
        if (resolved.tile.route.isNotEmpty) {
          Get.toNamed(resolved.tile.route);
        }
        return;
      case _TileState.kycLocked:
        Get.toNamed(
          BaseRoute.upgradeRequired,
          arguments: <String, dynamic>{'feature': resolved.tile.feature},
        );
        return;
      case _TileState.comingSoon:
        ToastHelper().showErrorToast(localization.commonComingSoon);
        return;
    }
  }

  List<_ServiceTile> _rawServiceList() {
    final localization = AppLocalizations.of(context)!;
    final addons = homeController.userModel.value.data?.addons;

    return [
      _ServiceTile(
        title: localization.otherServicesDynamicPassword,
        iconData: Icons.pin_rounded,
        route: BaseRoute.dynamicPassword,
      ),
      _ServiceTile(
        title: localization.otherServicesQrCode,
        icon: PngAssets.qrCodeService,
        route: BaseRoute.qrCode,
      ),
      _ServiceTile(
        title: localization.otherServicesAddMoney,
        icon: PngAssets.addMoneyService,
        route: BaseRoute.addMoney,
        available: settings.getSetting("user_deposit") == "1",
      ),
      _ServiceTile(
        title: localization.otherServicesCashOut,
        icon: PngAssets.cashOutService,
        route: BaseRoute.cashOut,
        feature: 'cashout',
        available: settings.getSetting("agent_system") == "1",
      ),
      _ServiceTile(
        title: localization.otherServicesMakePayment,
        icon: PngAssets.makePaymentService,
        route: BaseRoute.makePayment,
        available: settings.getSetting("merchant_system") == "1",
      ),
      _ServiceTile(
        title: localization.otherServicesTransactions,
        icon: PngAssets.transactionService,
        route: BaseRoute.transactions,
      ),
      _ServiceTile(
        title: localization.otherServicesPaymentLinks,
        icon: PngAssets.paymentLinksService,
        route: BaseRoute.paymentLinks,
        feature: 'payment-links',
      ),
      _ServiceTile(
        title: localization.otherServicesRequestMoney,
        icon: PngAssets.requestMoneyService,
        route: BaseRoute.requestMoney,
        feature: 'request-money',
      ),
      _ServiceTile(
        title: localization.otherServicesGift,
        icon: PngAssets.giftService,
        route: BaseRoute.giftCode,
        feature: 'gift_send',
        available: settings.getSetting("user_gift") == "1",
      ),
      _ServiceTile(
        title: localization.otherServicesWallets,
        icon: PngAssets.walletsService,
        route: BaseRoute.wallets,
      ),
      _ServiceTile(
        title: localization.otherServicesWithdraw,
        icon: PngAssets.withdrawService,
        route: BaseRoute.withdraw,
        feature: 'withdraw',
      ),
      _ServiceTile(
        title: localization.otherServicesExchange,
        icon: PngAssets.exchangeService,
        route: BaseRoute.exchange,
        feature: 'exchange',
      ),
      _ServiceTile(
        title: localization.otherServicesTransfer,
        icon: PngAssets.transferService,
        route: BaseRoute.transfer,
        feature: 'transfer',
      ),
      _ServiceTile(
        title: localization.otherServicesInvite,
        icon: PngAssets.inviteService,
        route: BaseRoute.referral,
      ),
      _ServiceTile(
        title: localization.otherServicesBillPayment,
        icon: PngAssets.billPaymentService,
        route: BaseRoute.billPayment,
        feature: 'pay-bill',
      ),
      _ServiceTile(
        title: localization.drawerRemittance,
        icon: PngAssets.billPaymentService,
        route: BaseRoute.remittance,
        feature: 'remittance',
      ),
      _ServiceTile(
        title: localization.otherServicesVirtualCard,
        icon: PngAssets.virtualCardService,
        route: BaseRoute.virtualCard,
        feature: 'paycardo',
        available: addons?.virtualCards == true,
      ),
      _ServiceTile(
        title: localization.otherServicesGiftCards,
        icon: PngAssets.giftCardsService,
        route: BaseRoute.giftCard,
        feature: 'gift_redeem',
        available: addons?.giftCards == true,
      ),
      _ServiceTile(
        title: localization.otherServicesP2pTrading,
        icon: PngAssets.p2pTradingService,
        route: BaseRoute.p2pTrading,
        available: addons?.p2pTrading == true,
      ),
      _ServiceTile(
        title: localization.travelTitle,
        iconData: Icons.flight_takeoff_rounded,
        route: BaseRoute.travel,
        feature: 'travel',
        available: addons?.travel == true,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── ALL Rx reads happen HERE, synchronously inside the Obx scope. ──
      final addons = homeController.userModel.value.data?.addons;
      final KycBadge? badge = Get.isRegistered<KycLevelController>()
          ? Get.find<KycLevelController>().badge.value
          : null;

      final localization = AppLocalizations.of(context)!;
      final tiles = _rawServiceList()
          .map((t) => _resolve(t, badge))
          .toList(growable: false);
      final serviceCount = tiles.length;

      final int itemsPerPage = 8;
      final int pageCount = (serviceCount / itemsPerPage).ceil();

      final pages = List.generate(pageCount, (index) {
        final start = index * itemsPerPage;
        final end = (start + itemsPerPage < serviceCount)
            ? start + itemsPerPage
            : serviceCount;
        return tiles.sublist(start, end);
      });

      final rows = ((pages.first.length) / 4).ceil();
      final double dynamicHeight = rows * 90.0;

      return Column(
        children: [
          SectionHeader(
            sectionName: localization.otherServicesTitle,
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
              children: [
                SizedBox(
                  height: dynamicHeight,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: pages.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, pageIndex) {
                      final pageItems = pages[pageIndex];
                      return GridView.builder(
                        itemCount: pageItems.length,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              mainAxisSpacing: 10,
                              childAspectRatio: 1,
                            ),
                        itemBuilder: (context, index) {
                          final resolved = pageItems[index];
                          final tile = resolved.tile;
                          final disabled =
                              resolved.state != _TileState.available;

                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () => _onTileTap(resolved),
                            child: Opacity(
                              opacity: disabled ? 0.55 : 1,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      if (tile.iconData is IconData)
                                        Container(
                                          width: 38,
                                          height: 38,
                                          decoration: BoxDecoration(
                                            color: AppColors.lightPrimary
                                                .withValues(alpha: .10),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            tile.iconData as IconData,
                                            color: AppColors.lightPrimary,
                                            size: 22,
                                          ),
                                        )
                                      else
                                        Image.asset(
                                          tile.icon as String,
                                          width: 35,
                                          color: disabled
                                              ? AppColors.black.withValues(
                                                  alpha: 0.30,
                                                )
                                              : null,
                                        ),
                                      if (resolved.state ==
                                          _TileState.kycLocked)
                                        PositionedDirectional(
                                          top: -4,
                                          end: -4,
                                          child: Container(
                                            padding: const EdgeInsets.all(2.5),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.black
                                                    .withValues(alpha: 0.08),
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.lock_rounded,
                                              size: 9,
                                              color: AppColors.lightTextTertiary,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    tile.title,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: const Color(0xFF2D2D2D).withValues(
                                        alpha: disabled ? 0.35 : 0.60,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (serviceCount > 8) ...[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  height: 6,
                  width: _currentPage == index ? 16 : 6,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? AppColors.lightPrimary
                        : AppColors.lightPrimary.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
