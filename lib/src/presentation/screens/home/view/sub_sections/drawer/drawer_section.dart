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
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class DrawerSection extends StatelessWidget {
  const DrawerSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final HomeController homeController = Get.find<HomeController>();
    final SettingsService settingsService = Get.find();
    final bool hasVirtualCard =
        homeController.userModel.value.data?.addons?.virtualCards == true;
    final bool hasGiftCard =
        homeController.userModel.value.data?.addons?.giftCards == true;
    final bool hasP2p =
        homeController.userModel.value.data?.addons?.p2pTrading == true;

    List<Map<String, dynamic>> buildNavigationList(
      SettingsService settingsService,
    ) {
      final List<Map<String, dynamic>> navigationItemList = [
        {
          "icon": SvgAssets.dashboardDrawerIcon,
          "navigation": localization.drawerDashboard,
          "navigate": "",
        },
        {
          "icon": SvgAssets.myWalletsDrawerIcon,
          "navigation": localization.drawerMyWallets,
          "navigate": BaseRoute.wallets,
        },
      ];

      final List<Map<String, dynamic>> conditionalItems = [
        {
          "setting": "user_deposit",
          "position": 2,
          "item": {
            "icon": SvgAssets.addMoneyDrawerIcon,
            "navigation": localization.drawerAddMoney,
            "navigate": BaseRoute.addMoney,
          },
        },
        {
          "setting": "user_cashout",
          "position": 3,
          "item": {
            "icon": SvgAssets.cashOutDrawerIcon,
            "navigation": localization.drawerCashOut,
            "navigate": BaseRoute.cashOut,
          },
        },
        {
          "setting": "always",
          "position": 4,
          "item": {
            "icon": SvgAssets.billPaymentDrawerIcon,
            "navigation": localization.drawerBillPayments,
            "navigate": BaseRoute.billPayment,
          },
        },

        if (hasVirtualCard)
          {
            "setting": "always",
            "position": 5,
            "item": {
              "icon": SvgAssets.virtualCardDrawerIcon,
              "navigation": localization.drawerVirtualCards,
              "navigate": BaseRoute.virtualCard,
            },
          },
        {
          "setting": "always",
          "position": hasVirtualCard ? 6 : 5,
          "item": {
            "icon": SvgAssets.paymentLinksDrawerIcon,
            "navigation": localization.drawerPaymentLinks,
            "navigate": BaseRoute.paymentLinks,
          },
        },
        {
          "setting": "user_payment",
          "position": hasVirtualCard ? 7 : 6,
          "item": {
            "icon": SvgAssets.makePaymentDrawerIcon,
            "navigation": localization.drawerMakePayment,
            "navigate": BaseRoute.makePayment,
          },
        },
        {
          "setting": "user_transfer",
          "position": hasVirtualCard ? 8 : 7,
          "item": {
            "icon": SvgAssets.transferDrawerIcon,
            "navigation": localization.drawerTransfer,
            "navigate": BaseRoute.transfer,
          },
        },
        {
          "setting": "user_withdraw",
          "position": hasVirtualCard ? 9 : 8,
          "item": {
            "icon": SvgAssets.withdrawDrawerIcon,
            "navigation": localization.drawerWithdraw,
            "navigate": BaseRoute.withdraw,
          },
        },
        {
          "setting": "user_exchange",
          "position": hasVirtualCard ? 10 : 9,
          "item": {
            "icon": SvgAssets.exchangeDrawerIcon,
            "navigation": localization.drawerExchange,
            "navigate": BaseRoute.exchange,
          },
        },
        {
          "setting": "sign_up_referral",
          "position": hasVirtualCard ? 11 : 10,
          "item": {
            "icon": SvgAssets.invitingDrawerIcon,
            "navigation": localization.drawerInviting,
            "navigate": BaseRoute.referral,
          },
        },
        if (hasGiftCard)
          {
            "setting": "always",
            "position": 12,
            "item": {
              "icon": SvgAssets.giftCardDrawerIcon,
              "navigation": localization.drawerGiftCard,
              "navigate": BaseRoute.giftCard,
            },
          },
        if (hasP2p)
          {
            "setting": "always",
            "position": 13,
            "item": {
              "icon": SvgAssets.p2pDrawerIcon,
              "navigation": localization.drawerP2pTrading,
              "navigate": BaseRoute.p2pTrading,
            },
          },
      ];

      for (var conditionalItem in conditionalItems) {
        final settingKey = conditionalItem["setting"] as String;
        final settingValue = settingsService.getSetting(settingKey);

        if (settingValue == "1" || settingKey == "always") {
          final position = conditionalItem["position"] as int;
          final item = conditionalItem["item"] as Map<String, dynamic>;

          final insertPosition = position > navigationItemList.length
              ? navigationItemList.length
              : position;

          navigationItemList.insert(insertPosition, item);
        }
      }

      return navigationItemList;
    }

    final navigationItemList = buildNavigationList(settingsService);

    return SafeArea(
      bottom: false,
      child: Stack(
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
              backgroundColor: AppColors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 50),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 28),
                    child: Image.asset(PngAssets.appLogo, height: 30),
                  ),
                  SizedBox(height: 20),
                  Divider(
                    endIndent: 28,
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
                    height: 0,
                    indent: 28,
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.only(top: 20),
                      itemBuilder: (context, index) {
                        final item = navigationItemList[index];
                        final isLastItem =
                            index == navigationItemList.length - 1;

                        return _DrawerItem(
                          item: item,
                          index: index,
                          isLastItem: isLastItem,
                          homeController: homeController,
                        );
                      },
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 10),
                      itemCount: navigationItemList.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
          PositionedDirectional(
            top: 79,
            end: -20,
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
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final int index;
  final bool isLastItem;
  final HomeController homeController;

  const _DrawerItem({
    required this.item,
    required this.index,
    required this.isLastItem,
    required this.homeController,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final settingsService = Get.find<SettingsService>();

    return Column(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(4),
          onTap: () {
            final nav = item["navigation"];
            final navigate = item["navigate"].toString();

            void navigateTo() {
              if (navigate.isNotEmpty) {
                Get.back();
                Get.toNamed(navigate);
              }
            }

            if (nav == localization.drawerTransfer) {
              if (settingsService.getSetting("kyc_fund_transfer") == "0" &&
                  homeController.userModel.value.data!.kyc == 0) {
                ToastHelper().showErrorToast(
                  localization.drawerKycVerification,
                );
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerDashboard) {
              Get.back();
            } else if (nav == localization.drawerMyWallets) {
              if (settingsService.getSetting("kyc_wallet") == "0" &&
                  homeController.userModel.value.data!.kyc == 0) {
                ToastHelper().showErrorToast(
                  localization.drawerKycVerification,
                );
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerAddMoney) {
              if (settingsService.getSetting("kyc_deposit") == "0" &&
                  homeController.userModel.value.data!.kyc == 0) {
                ToastHelper().showErrorToast(
                  localization.drawerKycVerification,
                );
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerCashOut) {
              if (settingsService.getSetting("kyc_cashout") == "0" &&
                  homeController.userModel.value.data!.kyc == 0) {
                ToastHelper().showErrorToast(
                  localization.drawerKycVerification,
                );
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerMakePayment) {
              if (settingsService.getSetting("kyc_payment") == "0" &&
                  homeController.userModel.value.data!.kyc == 0) {
                ToastHelper().showErrorToast(
                  localization.drawerKycVerification,
                );
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerExchange) {
              if (settingsService.getSetting("kyc_exchange") == "0" &&
                  homeController.userModel.value.data!.kyc == 0) {
                ToastHelper().showErrorToast(
                  localization.drawerKycVerification,
                );
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerWithdraw) {
              if (settingsService.getSetting("kyc_withdraw") == "0" &&
                  homeController.userModel.value.data!.kyc == 0) {
                ToastHelper().showErrorToast(
                  localization.drawerKycVerification,
                );
              } else {
                navigateTo();
              }
            } else {
              navigateTo();
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Row(
              children: [
                SvgPicture.asset(
                  item["icon"],
                  colorFilter: ColorFilter.mode(
                    AppColors.lightTextPrimary.withValues(alpha: 0.44),
                    BlendMode.srcIn,
                  ),
                  width: 20,
                ),
                SizedBox(width: 14),
                Text(
                  item["navigation"],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isLastItem) SizedBox(height: 20),
      ],
    );
  }
}
