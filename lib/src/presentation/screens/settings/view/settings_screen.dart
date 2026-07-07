import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final HomeController homeController = Get.find();
  final localization = AppLocalizations.of(Get.context!)!;

  @override
  void initState() {
    super.initState();
    if (!homeController.isSettingsInitialized.value) {
      homeController.loadUser();
      homeController.isSettingsInitialized.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> settingsList = [
      {
        "icon": PngAssets.profileSettingsEndDrawerIcon,
        "title": localization.settingsProfileSettings,
        "is_status": false,
        "navigate": BaseRoute.profileSettings,
      },
      {
        "icon": PngAssets.changePasswordEndDrawerIcon,
        "title": localization.settingsChangePassword,
        "is_status": false,
        "navigate": BaseRoute.changePassword,
      },
      {
        "icon": PngAssets.allNotificationEndDrawerIcon,
        "title": localization.settingsAllNotification,
        "is_status": false,
        "navigate": BaseRoute.notifications,
      },
      {
        "icon": PngAssets.signOutEndDrawerIcon,
        "title": localization.settingsSignOut,
        "is_status": false,
        "navigate": "",
      },
    ];

    if (Get.find<SettingsService>().getSetting("fa_verification") == "1") {
      settingsList.insert(2, {
        "icon": PngAssets.twoFaAuthenticationEndDrawerIcon,
        "title": localization.settingsTwoFactorAuthentication,
        "is_status": false,
        "navigate": BaseRoute.twoFactorAuthentication,
      });
    }
    if (Get.find<SettingsService>().getSetting("kyc_verification") == "1") {
      settingsList.insert(3, {
        "icon": PngAssets.idVerificationEndDrawerIcon,
        "title": localization.settingsIdVerification,
        "is_status": true,
        "navigate": BaseRoute.kycHistory,
      });
    }
    if (Get.find<SettingsService>().getSetting("user_ticket") == "1") {
      settingsList.insert(4, {
        "icon": PngAssets.supportEndDrawerIcon,
        "title": localization.settingsSupport,
        "is_status": false,
        "navigate": BaseRoute.supportTickets,
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) async {
        await Future.delayed(Duration(milliseconds: 50));
        if (homeController.selectedIndex.value == 3) {
          homeController.selectedIndex.value = 0;
        }
      },
      child: Scaffold(
        appBar: CommonDefaultAppBar(),
        body: Stack(
          children: [
            RefreshIndicator(
              color: AppColors.lightPrimary,
              onRefresh: () => homeController.loadUser(),
              child: Obx(
                () => homeController.isUserLoading.value
                    ? CommonLoading()
                    : SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            CommonAppBar(
                              title: localization.settingsScreenTitle,
                              isBackLogicApply: true,
                              backLogicFunction: () async {
                                await Future.delayed(
                                  Duration(milliseconds: 50),
                                );
                                if (homeController.selectedIndex.value == 3) {
                                  homeController.selectedIndex.value = 0;
                                }
                              },
                            ),
                            const SizedBox(height: 30),
                            Container(
                              margin: const EdgeInsetsDirectional.symmetric(
                                horizontal: 18,
                              ),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  final item = settingsList[index];

                                  return InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () async {
                                      if (item["title"] ==
                                          localization.settingsSignOut) {
                                        await homeController.submitLogout();
                                      } else {
                                        Get.toNamed(item["navigate"]);
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsetsDirectional.symmetric(
                                        horizontal: 16,
                                        vertical: 16,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.lightBackground,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Image.asset(
                                                  item["icon"],
                                                  width: 24,
                                                ),
                                                const SizedBox(width: 10),
                                                Text(
                                                  item["title"],
                                                  style: TextStyle(
                                                    letterSpacing: 0,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 16,
                                                    color:
                                                        item["title"] ==
                                                            localization
                                                                .settingsSignOut
                                                        ? AppColors.error
                                                        : AppColors
                                                              .lightTextTertiary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              if (item["is_status"])
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          50,
                                                        ),
                                                    color:
                                                        homeController
                                                                .userModel
                                                                .value
                                                                .data
                                                                ?.kyc ==
                                                            1
                                                        ? AppColors.success
                                                        : homeController
                                                                  .userModel
                                                                  .value
                                                                  .data
                                                                  ?.kyc ==
                                                              2
                                                        ? AppColors.warning
                                                        : homeController
                                                                  .userModel
                                                                  .value
                                                                  .data
                                                                  ?.kyc ==
                                                              3
                                                        ? AppColors.error
                                                        : AppColors.warning,
                                                  ),
                                                  alignment: Alignment.center,
                                                  padding:
                                                      const EdgeInsetsDirectional.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                  child: Text(
                                                    homeController
                                                                .userModel
                                                                .value
                                                                .data
                                                                ?.kyc ==
                                                            1
                                                        ? localization
                                                              .settingsKycVerified
                                                        : homeController
                                                                  .userModel
                                                                  .value
                                                                  .data
                                                                  ?.kyc ==
                                                              2
                                                        ? localization
                                                              .settingsKycPending
                                                        : homeController
                                                                  .userModel
                                                                  .value
                                                                  .data
                                                                  ?.kyc ==
                                                              3
                                                        ? localization
                                                              .settingsKycFailed
                                                        : localization
                                                              .settingsKycNotSubmitted,
                                                    style: const TextStyle(
                                                      letterSpacing: 0,
                                                      fontWeight:
                                                          FontWeight.w900,
                                                      fontSize: 13,
                                                      color: AppColors.white,
                                                    ),
                                                  ),
                                                ),
                                              if (item["is_status"])
                                                const SizedBox(width: 10),
                                              Image.asset(
                                                PngAssets.arrowRightCommonIcon,
                                                width: 24,
                                                color:
                                                    item["title"] ==
                                                        localization
                                                            .settingsSignOut
                                                    ? AppColors.error
                                                    : AppColors
                                                          .lightTextTertiary,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 16);
                                },
                                itemCount: settingsList.length,
                              ),
                            ),
                            const SizedBox(height: 50),
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
    );
  }
}
