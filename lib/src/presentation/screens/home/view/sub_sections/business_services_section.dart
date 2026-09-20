import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/service_tiles.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';

/// v1.0.45 (BUSINESS SERVICES): commercial & business services card on the
/// dashboard — remittance + P2P escrow (built modules, moved here from the
/// old flat services grid) plus the upcoming business services (service
/// guarantee, bank loan, license, stocks & exchange) shown greyed with a
/// lock until their modules ship; tapping explains availability and the
/// KYC level requirement (notBuilt state).
class BusinessServicesSection extends StatefulWidget {
  const BusinessServicesSection({super.key});

  @override
  State<BusinessServicesSection> createState() =>
      _BusinessServicesSectionState();
}

class _BusinessServicesSectionState extends State<BusinessServicesSection> {
  final HomeController homeController = Get.find();

  List<ServiceTile> _businessServiceList(Addons? addons) {
    final localization = AppLocalizations.of(context)!;

    return [
      ServiceTile(
        title: localization.drawerRemittance,
        icon: PngAssets.billPaymentService,
        route: BaseRoute.remittance,
        feature: 'remittance',
      ),
      ServiceTile(
        title: localization.businessServiceMoneyTransfer,
        icon: PngAssets.transferService,
        route: BaseRoute.transfer,
        feature: 'transfer',
      ),
      ServiceTile(
        title: localization.businessServiceP2pEscrow,
        icon: PngAssets.p2pTradingService,
        route: BaseRoute.p2pTrading,
        available: addons?.p2pTrading == true,
      ),
      // Upcoming business modules — greyed with a lock; tapping explains
      // availability + the KYC level requirement.
      ServiceTile(
        title: localization.businessServiceGuarantee,
        iconData: Icons.verified_user_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.businessServiceBankLoan,
        iconData: Icons.account_balance_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.businessServiceLicense,
        iconData: Icons.workspace_premium_rounded,
        route: '',
        available: false,
      ),
      ServiceTile(
        title: localization.businessServiceStocks,
        iconData: Icons.trending_up_rounded,
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
      final tiles = _businessServiceList(
        addons,
      ).map((tile) => resolveTile(tile, badge)).toList(growable: false);

      return Column(
        children: [
          SectionHeader(
            sectionName: localization.businessServicesTitle,
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
