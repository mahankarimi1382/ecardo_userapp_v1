import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/home_skeleton_loader.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/my_wallet_section.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/other_services_section.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/recent_transactions_section.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/sign_up_bonus_pop_up.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/top_header_section.dart';

class HomeScreen extends StatefulWidget {
  final String? signUpBonus;

  const HomeScreen({super.key, this.signUpBonus});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.signUpBonus?.isNotEmpty ?? false) {
        if (Get.find<SettingsService>().getSetting("referral_signup_bonus") ==
            "1") {
          await loadBonusPopUp();
        }
      }
    });
  }

  Future<void> loadBonusPopUp() async {
    final email = await SettingsService.getLoggedInUserEmail();
    if (email == null) return;

    final bool isBonusShown =
        await SettingsService.getBonusPopUpShow(email) ?? false;

    if (!isBonusShown) {
      Future.delayed(const Duration(seconds: 5), () async {
        showGiftDialog(signUpBonus: widget.signUpBonus.toString());
        await Get.find<SettingsService>().saveBonusPopUpShow(email, true);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        showExitApplicationAlertDialog();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(statusBarIconBrightness: Brightness.light),
        child: Scaffold(
          body: Stack(
            children: [
              Obx(
                () => homeController.isLoading.value
                    ? const HomeSkeletonLoader()
                    : RefreshIndicator(
                        color: AppColors.lightPrimary,
                        onRefresh: () => homeController.loadData(),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              TopHeaderSection(),
                              SizedBox(height: 30),
                              MyWalletSection(),
                              SizedBox(height: 30),
                              OtherServicesSection(),
                              SizedBox(height: 30),
                              RecentTransactionsSection(),
                              SizedBox(height: 50),
                            ],
                          ),
                        ),
                      ),
              ),
              Obx(
                () => Visibility(
                  visible: homeController.isSignOutLoading.value,
                  child: CommonLoading(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showExitApplicationAlertDialog() {
    final localization = AppLocalizations.of(context)!;
    Get.bottomSheet(
      CommonAlertBottomSheet(
        title: localization.exitApplicationTitle,
        message: localization.exitApplicationMessage,
        onConfirm: () => exit(0),
        onCancel: () => Get.back(),
      ),
    );
  }

  void showGiftDialog({required String signUpBonus}) {
    Get.dialog(SignUpBonusPopUp(signUpBonus: signUpBonus));
  }
}
