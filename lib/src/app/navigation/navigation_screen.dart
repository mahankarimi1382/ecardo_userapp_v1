import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/beneficiary/controller/create_beneficiary_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/create_gift_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_code_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_history_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/controller/gift_redeem_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_code/view/gift_code_screen.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/home_screen.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/drawer/drawer_section.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/drawer/end_drawer_section.dart';
import 'package:qunzo_user/src/presentation/screens/settings/view/settings_screen.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/controller/transfer_controller.dart';
import 'package:qunzo_user/src/presentation/screens/transfer/view/transfer_screen.dart';
import 'package:qunzo_user/src/presentation/widgets/qr_scanner_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final HomeController homeController = Get.find<HomeController>();
  final String signUpBonus = Get.arguments?["bonus"] ?? "";

  final iconList = [
    PngAssets.bottomNavigationHomeSolidIcon,
    PngAssets.bottomNavigationTransferSolidIcon,
    PngAssets.bottomNavigationGiftSolidIcon,
    PngAssets.bottomNavigationSettingsSolidIcon,
  ];

  @override
  void initState() {
    super.initState();
    homeController.setScaffoldKey(_scaffoldKey);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final localization = AppLocalizations.of(context)!;

      final settings = Get.find<SettingsService>();
      bool isUserTransferEnabled = settings.getSetting("user_transfer") == "1";
      bool isUserGiftEnabled = settings.getSetting("user_gift") == "1";

      final labelList = [
        localization.bottomNavHome,
        localization.bottomNavTransfer,
        localization.bottomNavGift,
        localization.bottomNavSettings,
      ];

      final pages = [
        HomeScreen(signUpBonus: signUpBonus),
        TransferScreen(),
        GiftCodeScreen(),
        SettingsScreen(),
      ];

      return Scaffold(
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        drawer: DrawerSection(),
        endDrawer: EndDrawerSection(),
        body: pages[homeController.selectedIndex.value],
        floatingActionButton: MediaQuery.of(context).viewInsets.bottom == 0
            ? FloatingActionButton(
                heroTag: null,
                backgroundColor: AppColors.lightPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Image.asset(
                  PngAssets.commonScannerIcon,
                  color: AppColors.white,
                  width: 25,
                  height: 25,
                ),
                onPressed: () async {
                  final scannedCode = await Get.to(
                    () => const QrScannerScreen(),
                  );

                  if (scannedCode != null) {
                    final code = scannedCode.trim();
                    final aidMatch = RegExp(
                      r'^AID\s*:\s*(\d+)$',
                      caseSensitive: false,
                    ).firstMatch(code);
                    if (aidMatch != null) {
                      Get.toNamed(
                        BaseRoute.cashOut,
                        arguments: {"aid_account": aidMatch.group(1)},
                      );
                      return;
                    }
                    final midMatch = RegExp(
                      r'^MID\s*:\s*(\d+)$',
                      caseSensitive: false,
                    ).firstMatch(code);
                    if (midMatch != null) {
                      Get.toNamed(
                        BaseRoute.makePayment,
                        arguments: {"mid_account": midMatch.group(1)},
                      );
                      return;
                    }
                    final uidMatch = RegExp(
                      r'^UID\s*:\s*(\d+)$',
                      caseSensitive: false,
                    ).firstMatch(code);
                    if (uidMatch != null) {
                      Get.toNamed(
                        BaseRoute.transfer,
                        arguments: {"uid_account": uidMatch.group(1)},
                      );
                      return;
                    }
                    if (!RegExp(r'^\d+$').hasMatch(code)) {
                      ToastHelper().showErrorToast(
                        localization.qrInvalidFormat,
                      );
                    }
                  }
                },
              )
            : null,

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: AnimatedBottomNavigationBar.builder(
          height: 80,
          backgroundColor: AppColors.white,
          itemCount: iconList.length,
          activeIndex: homeController.selectedIndex.value,
          notchSmoothness: NotchSmoothness.softEdge,
          gapLocation: GapLocation.center,

          tabBuilder: (int index, bool isActive) {
            final color = isActive
                ? AppColors.lightPrimary
                : AppColors.lightTextPrimary.withValues(alpha: 0.30);

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  iconList[index],
                  color: color,
                  width: index == 0
                      ? 25
                      : index == 1
                      ? 26
                      : index == 2
                      ? 22
                      : 28,
                ),
                const SizedBox(height: 2),
                Text(
                  labelList[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
              ],
            );
          },

          onTap: (index) {
            if (index == 1 && !isUserTransferEnabled) {
              ToastHelper().showErrorToast(localization.userTransferNotEnabled);
              return;
            }

            if (index != 1) {
              if (Get.isRegistered<TransferController>()) {
                Get.delete<TransferController>();
              }
              if (Get.isRegistered<CreateBeneficiaryController>()) {
                Get.delete<CreateBeneficiaryController>();
              }
            }

            if (index == 2 && !isUserGiftEnabled) {
              ToastHelper().showErrorToast(localization.userGiftNotEnabled);
              return;
            }

            if (index != 2) {
              if (Get.isRegistered<GiftCodeController>()) {
                Get.delete<GiftCodeController>();
              }
              if (Get.isRegistered<GiftRedeemController>()) {
                Get.delete<GiftRedeemController>();
              }
              if (Get.isRegistered<GiftHistoryController>()) {
                Get.delete<GiftHistoryController>();
              }
              if (Get.isRegistered<CreateGiftController>()) {
                Get.delete<CreateGiftController>();
              }
            }

            homeController.selectedIndex.value = index;
          },

          shadow: BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 20,
            spreadRadius: 0,
            color: AppColors.black.withValues(alpha: 0.10),
          ),
        ),
      );
    });
  }
}
