import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/view/sub_sections/wallet_list_section.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final WalletsController walletsController = Get.find<WalletsController>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        body: Column(
          children: [
            SizedBox(height: 16),
            CommonAppBar(
              title: localization.walletsScreenTitle,
              isBackLogicApply: true,
              backLogicFunction: () async {
                Get.offNamed(BaseRoute.navigation);
              },
              rightSideWidget: GestureDetector(
                onTap: () => Get.toNamed(BaseRoute.createNewWallet),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(end: 18),
                  child: Image.asset(PngAssets.commonWalletAddIcon, width: 30),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () => walletsController.isLoading.value
                    ? CommonLoading()
                    : RefreshIndicator(
                        color: AppColors.lightPrimary,
                        onRefresh: () => walletsController.fetchWallets(),
                        child: WalletListSection(),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
