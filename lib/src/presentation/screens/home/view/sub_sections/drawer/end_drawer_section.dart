import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class EndDrawerSection extends StatefulWidget {
  const EndDrawerSection({super.key});

  @override
  State<EndDrawerSection> createState() => _EndDrawerSectionState();
}

class _EndDrawerSectionState extends State<EndDrawerSection> {
  final HomeController homeController = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return SafeArea(
      bottom: false,
      child: Obx(
        () => Stack(
          clipBehavior: Clip.none,
          children: [
            AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarIconBrightness: Brightness.dark,
              ),
              child: Drawer(
                width: 310,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                backgroundColor: AppColors.lightBackground,
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 28),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 60),
                                Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(30),
                                      child: Image.network(
                                        homeController
                                            .dashboardModel
                                            .value
                                            .data!
                                            .user!
                                            .avatarPath!,
                                        width: 48,
                                        height: 48,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Image.asset(
                                                PngAssets.profileImage,
                                                fit: BoxFit.contain,
                                              );
                                            },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            homeController
                                                    .dashboardModel
                                                    .value
                                                    .data!
                                                    .user!
                                                    .fullName ??
                                                "",
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 22,
                                              color: AppColors.lightTextPrimary,
                                            ),
                                          ),
                                          Text(
                                            homeController
                                                    .dashboardModel
                                                    .value
                                                    .data!
                                                    .user!
                                                    .email ??
                                                "",
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                              color:
                                                  AppColors.lightTextTertiary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20),
                                Divider(
                                  color: AppColors.lightTextPrimary.withValues(
                                    alpha: 0.10,
                                  ),
                                  height: 0,
                                ),
                                const SizedBox(height: 30),
                              ],
                            ),
                          ),
                          _buildNavigationSection(
                            title: localization.endDrawerProfileSettings,
                            icon: SvgAssets.commonSettingsIcon,
                            onPressed: () {
                              Get.toNamed(BaseRoute.profileSettings);
                            },
                          ),
                          _buildNavigationSection(
                            title: localization.endDrawerChangePassword,
                            icon: SvgAssets.commonLockIcon,
                            onPressed: () {
                              Get.toNamed(BaseRoute.changePassword);
                            },
                          ),
                          _buildNavigationSection(
                            title: localization.endDrawerAllNotification,
                            icon: SvgAssets.commonNotificationIcon,
                            onPressed: () {
                              Get.toNamed(BaseRoute.notifications);
                            },
                          ),
                          Get.find<SettingsService>().getSetting(
                                    "user_ticket",
                                  ) ==
                                  "1"
                              ? _buildNavigationSection(
                                  title: localization.endDrawerHelpSupport,
                                  icon: SvgAssets.commonSupportIcon,
                                  onPressed: () {
                                    Get.toNamed(BaseRoute.supportTickets);
                                  },
                                )
                              : SizedBox.shrink(),
                          Get.find<SettingsService>().getSetting(
                                    "language_switcher",
                                  ) ==
                                  "1"
                              ? _buildNavigationSection(
                                  title: localization.endDrawerLanguage,
                                  icon: SvgAssets.commonLanguageIcon,
                                  onPressed: () {
                                    Get.bottomSheet(
                                      CommonDropdownBottomSheet(
                                        notFoundText: localization
                                            .endDrawerLanguageNotFound,
                                        onValueSelected: (value) async {
                                          await homeController.changeLanguage(
                                            value,
                                          );
                                        },
                                        selectedValue: ["English", "Arabic"],
                                        dropdownItems: ["English", "Arabic"],
                                        selectedItem: homeController
                                            .languageController
                                            .text,
                                        textController:
                                            homeController.languageController,
                                        title: localization
                                            .endDrawerChooseLanguage,
                                        isShowTitle: true,
                                        bottomSheetHeight: 400,
                                        currentlySelectedValue: homeController
                                            .languageController
                                            .text,
                                      ),
                                    );
                                  },
                                  rightSideWidget: Row(
                                    children: [
                                      Obx(
                                        () => Text(
                                          homeController.language.value,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0,
                                            fontSize: 13,
                                            color: AppColors.lightTextTertiary,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Image.asset(
                                        PngAssets.arrowRightCommonIcon,
                                        width: 14,
                                        height: 14,
                                        color: AppColors.black,
                                      ),
                                    ],
                                  ),
                                )
                              : SizedBox.shrink(),
                          _buildNavigationSection(
                            isSwitch: true,
                            title: localization.endDrawerBiometric,
                            icon: SvgAssets.commonBiometricIcon,
                            onPressed: () {},
                            rightSideWidget: Transform.scale(
                              scale: 0.7,
                              child: Switch(
                                padding: EdgeInsets.zero,
                                value: homeController.isBiometricEnable.value,
                                activeThumbColor: AppColors.lightPrimary,
                                inactiveThumbColor: AppColors.lightTextTertiary,
                                inactiveTrackColor: AppColors.lightTextPrimary
                                    .withValues(alpha: 0.05),
                                onChanged: (_) async {
                                  await homeController.toggleBiometric();
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildSignOutSection(),
                  ],
                ),
              ),
            ),
            PositionedDirectional(
              top: 112,
              start: -20,
              child: Material(
                color: AppColors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Get.back(),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.10),
                          blurRadius: 20,
                          spreadRadius: 0,
                          offset: Offset(-1, 1),
                        ),
                      ],
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Image.asset(
                      PngAssets.closeCommonIcon,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignOutSection() {
    final localization = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsetsDirectional.only(
        bottom: 50,
        start: 28,
        end: 28,
      ),
      child: CommonIconButton(
        backgroundColor: AppColors.error,
        onPressed: () async {
          Get.back();
          await homeController.submitLogout();
        },
        width: double.infinity,
        text: localization.endDrawerSignOut,
        icon: PngAssets.signOutEndDrawerIcon,
        iconWidth: 22,
        iconHeight: 22,
        iconAndTextSpace: 5,
      ),
    );
  }

  Widget _buildNavigationSection({
    required String title,
    required String icon,
    Widget? rightSideWidget,
    required GestureTapCallback onPressed,
    bool? isSwitch = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: onPressed,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 28,
          vertical: isSwitch == true ? 7 : 18,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(
                    AppColors.lightTextPrimary.withValues(alpha: 0.44),
                    BlendMode.srcIn,
                  ),
                  width: 22,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
            rightSideWidget ?? const SizedBox(),
          ],
        ),
      ),
    );
  }
}
