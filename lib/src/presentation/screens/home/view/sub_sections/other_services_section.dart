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

/// v1.0.46: the financial services card — the money-services grid as its own
/// dashboard card (separated from travel, which has its own section below).
/// Dynamic PIN stays the first tile. Remittance, escrow and money transfer
/// live in the business services section; travel has its own section.
class OtherServicesSection extends StatefulWidget {
  const OtherServicesSection({super.key});

  @override
  State<OtherServicesSection> createState() => _OtherServicesSectionState();
}

class _OtherServicesSectionState extends State<OtherServicesSection> {
  final HomeController homeController = Get.find();
  final SettingsService settings = Get.find();

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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // ── ALL Rx reads happen HERE, synchronously inside the Obx scope. ──
      final addons = homeController.userModel.value.data?.addons;
      final KycBadge? badge = currentKycBadge();

      final localization = AppLocalizations.of(context)!;
      final tiles = _financialServiceList(
        addons,
      ).map((tile) => resolveTile(tile, badge)).toList(growable: false);

      return Column(
        children: [
          SectionHeader(
            sectionName: localization.financialServicesTitle,
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
