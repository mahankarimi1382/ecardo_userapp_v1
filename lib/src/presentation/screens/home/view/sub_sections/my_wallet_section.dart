import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/wallet_live_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/widgets/wallet_card_carousel.dart';
import 'package:ecardo_user/src/presentation/widgets/empty_view.dart';
import 'package:ecardo_user/src/helper/responsive.dart';

class MyWalletSection extends StatelessWidget {
  const MyWalletSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final homeController = Get.find<HomeController>();

    // Obx so live-rate refresh redraws without a full reload.
    return Obx(() {
      final wallets = homeController.walletsList.toList();
      if (Get.isRegistered<WalletLiveRateService>()) {
        // Touch ratesIrr so GetX tracks it.
        Get.find<WalletLiveRateService>().ratesIrr.length;
      }
      return Column(
        children: [
          SectionHeader(
            sectionName: localization.myWalletSectionTitle,
            onTap: () {
              Get.toNamed(BaseRoute.wallets);
            },
          ),
          SizedBox(height: Responsive.sectionGap(context) / 2),
          if (wallets.isEmpty)
            EmptyView.wallets(onCta: () => Get.toNamed(BaseRoute.wallets))
          else
            WalletCardCarousel(wallets: wallets),
        ],
      );
    });
  }
}
