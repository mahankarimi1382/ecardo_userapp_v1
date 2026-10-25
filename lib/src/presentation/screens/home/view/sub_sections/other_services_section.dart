import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
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
      // --- Page 1: Core Financial Movements ---
      ServiceTile(
        title: localization.otherServicesDynamicPassword,
        iconData: FluentIcons.password_24_regular,
        route: BaseRoute.dynamicPassword,
      ),
      ServiceTile(
        title: localization.otherServicesTransfer,
        iconData: FluentIcons.arrow_swap_24_regular,
        route: BaseRoute.transfer,
        feature: 'transfer',
      ),
      ServiceTile(
        title: localization.otherServicesAddMoney,
        iconData: FluentIcons.wallet_credit_card_24_regular,
        route: BaseRoute.addMoney,
        available: true,
      ),
      ServiceTile(
        title: localization.otherServicesWithdraw,
        iconData: FluentIcons.money_hand_24_regular,
        route: BaseRoute.withdraw,
        feature: 'withdraw',
      ),
      ServiceTile(
        title: localization.otherServicesExchange,
        iconData: FluentIcons.arrow_sync_24_regular,
        route: BaseRoute.exchange,
        feature: 'exchange',
      ),
      ServiceTile(
        title: localization.otherServicesWallets,
        iconData: FluentIcons.wallet_24_regular,
        route: BaseRoute.wallets,
      ),
      ServiceTile(
        title: localization.otherServicesTransactions,
        iconData: FluentIcons.receipt_sparkles_24_regular,
        route: BaseRoute.transactions,
      ),
      ServiceTile(
        title: localization.otherServicesQrCode,
        iconData: FluentIcons.qr_code_24_regular,
        route: BaseRoute.qrCode,
      ),

      // --- Page 2: Merchant, Cards, Utility & Sharing ---
      ServiceTile(
        title: localization.otherServicesVirtualCard,
        iconData: FluentIcons.payment_24_regular,
        route: BaseRoute.virtualCard,
        feature: 'paycardo',
        available: true,
      ),
      ServiceTile(
        title: localization.otherServicesBillPayment,
        iconData: FluentIcons.receipt_24_regular,
        route: BaseRoute.billPayment,
        feature: 'pay-bill',
      ),
      ServiceTile(
        title: localization.otherServicesRequestMoney,
        iconData: FluentIcons.handshake_24_regular,
        route: BaseRoute.requestMoney,
        feature: 'request-money',
      ),
      ServiceTile(
        title: localization.otherServicesPaymentLinks,
        iconData: FluentIcons.link_square_24_regular,
        route: BaseRoute.paymentLinks,
        feature: 'payment-links',
      ),
      ServiceTile(
        title: localization.otherServicesMakePayment,
        iconData: FluentIcons.building_bank_link_24_regular,
        route: BaseRoute.makePayment,
        available: true,
      ),
      ServiceTile(
        title: localization.otherServicesCashOut,
        iconData: FluentIcons.money_24_regular,
        route: BaseRoute.cashOut,
        feature: 'cashout',
        available: true,
      ),
      ServiceTile(
        title: localization.otherServicesGift,
        iconData: FluentIcons.gift_card_24_regular,
        route: BaseRoute.giftCode,
        feature: 'gift_send',
        available: true,
      ),
      ServiceTile(
        title: localization.otherServicesGiftCards,
        iconData: FluentIcons.gift_24_regular,
        route: BaseRoute.giftCard,
        feature: 'gift_redeem',
        available: true,
      ),
      ServiceTile(
        title: localization.otherServicesInvite,
        iconData: FluentIcons.person_add_24_regular,
        route: BaseRoute.referral,
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

      final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isDark ? AppColors.darkSurface : AppColors.white,
            ),
            child: PagedServiceTilesGrid(tiles: tiles),
          ),
        ],
      );
    });
  }
}
