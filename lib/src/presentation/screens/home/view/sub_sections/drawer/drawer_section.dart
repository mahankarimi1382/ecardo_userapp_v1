import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/constants/assets_path/svg/svg_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

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

      // v1.0.4+5: ALL modules visible — license gate at action time, not navigation
      // Each item has "setting" key: "always" = always enabled, other = check setting
      // Disabled items show greyed with lock icon; tapping shows license dialog
      final List<Map<String, dynamic>> allItems = [
        {
          "icon": SvgAssets.addMoneyDrawerIcon,
          "navigation": localization.drawerAddMoney,
          "navigate": BaseRoute.addMoney,
          "setting": "user_deposit",
        },
        {
          "icon": SvgAssets.cashOutDrawerIcon,
          "navigation": localization.drawerCashOut,
          "navigate": BaseRoute.cashOut,
          "setting": "user_cashout",
        },
        {
          "icon": SvgAssets.billPaymentDrawerIcon,
          "navigation": localization.drawerBillPayments,
          "navigate": BaseRoute.billPayment,
          "setting": "always",
        },
        {
          "icon": SvgAssets.billPaymentDrawerIcon,
          "navigation": localization.drawerRemittance,
          "navigate": BaseRoute.remittance,
          "setting": "always",
        },
        {
          "icon": SvgAssets.virtualCardDrawerIcon,
          "navigation": localization.drawerVirtualCards,
          "navigate": BaseRoute.virtualCard,
          "setting": "always",
          "addon": "virtualCards",
        },
        {
          "icon": SvgAssets.paymentLinksDrawerIcon,
          "navigation": localization.drawerPaymentLinks,
          "navigate": BaseRoute.paymentLinks,
          "setting": "always",
        },
        {
          "icon": SvgAssets.makePaymentDrawerIcon,
          "navigation": localization.drawerMakePayment,
          "navigate": BaseRoute.makePayment,
          "setting": "user_payment",
        },
        {
          "icon": SvgAssets.transferDrawerIcon,
          "navigation": localization.drawerTransfer,
          "navigate": BaseRoute.transfer,
          "setting": "user_transfer",
        },
        {
          "icon": SvgAssets.withdrawDrawerIcon,
          "navigation": localization.drawerWithdraw,
          "navigate": BaseRoute.withdraw,
          "setting": "user_withdraw",
        },
        {
          "icon": SvgAssets.exchangeDrawerIcon,
          "navigation": localization.drawerExchange,
          "navigate": BaseRoute.exchange,
          "setting": "user_exchange",
        },
        {
          "icon": SvgAssets.invitingDrawerIcon,
          "navigation": localization.drawerInviting,
          "navigate": BaseRoute.referral,
          "setting": "sign_up_referral",
        },
        {
          "icon": SvgAssets.giftCardDrawerIcon,
          "navigation": localization.drawerGiftCard,
          "navigate": BaseRoute.giftCard,
          "setting": "always",
          "addon": "giftCards",
        },
        {
          "icon": SvgAssets.p2pDrawerIcon,
          "navigation": localization.drawerP2pTrading,
          "navigate": BaseRoute.p2pTrading,
          "setting": "always",
          "addon": "p2pTrading",
        },
      ];

      // Add all items — ALL visible, license check at tap time
      for (var item in allItems) {
        // Determine if this item is enabled
        final settingKey = item["setting"] as String;
        final addonKey = item["addon"] as String?;
        bool isEnabled = true;

        if (settingKey != "always") {
          isEnabled = settingsService.getSetting(settingKey) == "1";
        }

        if (addonKey != null) {
          final addonEnabled = addonKey == "virtualCards"
              ? hasVirtualCard
              : addonKey == "giftCards"
                  ? hasGiftCard
                  : addonKey == "p2pTrading"
                      ? hasP2p
                      : true;
          isEnabled = isEnabled && addonEnabled;
        }

        item["isEnabled"] = isEnabled;
        navigationItemList.add(item);
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
            final isEnabled = item["isEnabled"] as bool? ?? true;

            // v1.0.4+5: License gate — if module is disabled, show dialog
            if (!isEnabled) {
              Get.back();
              Get.dialog(
                AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: Row(children: [
                    Icon(Icons.lock_outline, color: AppColors.warning, size: 24),
                    SizedBox(width: 8),
                    Text('License Required', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  ]),
                  content: Text(
                    'The "$nav" feature is not available on your current plan.\n\nPlease contact support to activate this module.',
                    style: TextStyle(fontSize: 14, color: AppColors.lightTextPrimary),
                  ),
                  actions: [
                    TextButton(onPressed: () => Get.back(), child: Text('Close')),
                    ElevatedButton(
                      onPressed: () { Get.back(); Get.toNamed(BaseRoute.supportTickets); },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary),
                      child: Text('Contact Support', style: TextStyle(color: AppColors.white)),
                    ),
                  ],
                ),
              );
              return;
            }

            void navigateTo() {
              if (navigate.isNotEmpty) {
                Get.back();
                Get.toNamed(navigate);
              }
            }

            // KYC gate — check KYC before navigating to financial modules
            final userKyc = homeController.userModel.value.data?.kyc ?? 0;

            if (nav == localization.drawerTransfer) {
              if (settingsService.getSetting("kyc_fund_transfer") == "0" && userKyc == 0) {
                ToastHelper().showErrorToast(localization.drawerKycVerification);
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerRemittance) {
              // v1.0.5: Check KYC level for Remittance
              try {
                final kycController = Get.find<KycLevelController>();
                if (!kycController.hasFeature('remittance')) {
                  Get.back();
                  Get.dialog(_KycLevelRequiredDialog(
                    requiredLevel: 3,
                    currentLevel: kycController.currentLevel,
                    featureName: nav,
                  ));
                  return;
                }
              } catch (_) {
                // اگر controller ثبت نشده، عبور کن
              }
              navigateTo();
            } else if (nav == localization.drawerDashboard) {
              Get.back();
            } else if (nav == localization.drawerMyWallets) {
              if (settingsService.getSetting("kyc_wallet") == "0" && userKyc == 0) {
                ToastHelper().showErrorToast(localization.drawerKycVerification);
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerAddMoney) {
              if (settingsService.getSetting("kyc_deposit") == "0" && userKyc == 0) {
                ToastHelper().showErrorToast(localization.drawerKycVerification);
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerCashOut) {
              if (settingsService.getSetting("kyc_cashout") == "0" && userKyc == 0) {
                ToastHelper().showErrorToast(localization.drawerKycVerification);
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerMakePayment) {
              if (settingsService.getSetting("kyc_payment") == "0" && userKyc == 0) {
                ToastHelper().showErrorToast(localization.drawerKycVerification);
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerExchange) {
              if (settingsService.getSetting("kyc_exchange") == "0" && userKyc == 0) {
                ToastHelper().showErrorToast(localization.drawerKycVerification);
              } else {
                navigateTo();
              }
            } else if (nav == localization.drawerWithdraw) {
              if (settingsService.getSetting("kyc_withdraw") == "0" && userKyc == 0) {
                ToastHelper().showErrorToast(localization.drawerKycVerification);
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
                    (item["isEnabled"] as bool? ?? true)
                        ? AppColors.lightTextPrimary.withValues(alpha: 0.44)
                        : AppColors.lightTextHint.withValues(alpha: 0.3),
                    BlendMode.srcIn,
                  ),
                  width: 20,
                ),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    item["navigation"],
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: (item["isEnabled"] as bool? ?? true)
                          ? AppColors.lightTextTertiary
                          : AppColors.lightTextHint,
                    ),
                  ),
                ),
                // Show lock icon for disabled modules
                if (!(item["isEnabled"] as bool? ?? true))
                  Icon(Icons.lock_outline, size: 14, color: AppColors.lightTextHint),
              ],
            ),
          ),
        ),
        if (isLastItem) SizedBox(height: 20),
      ],
    );
  }
}

// v1.0.5: دیالوگ سطح KYC لازم برای ماژول‌های قفل‌شده
class _KycLevelRequiredDialog extends StatelessWidget {
  final int requiredLevel;
  final int currentLevel;
  final String featureName;

  const _KycLevelRequiredDialog({
    required this.requiredLevel,
    required this.currentLevel,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.shield_outlined, color: AppColors.warning, size: 28),
          SizedBox(width: 8),
          Expanded(child: Text('ارتقای سطح احراز هویت', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('برای دسترسی به «$featureName» باید به سطح $requiredLevel احراز هویت برسید.', style: TextStyle(fontSize: 14, color: AppColors.lightTextPrimary)),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.lightBackground, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('سطح فعلی:', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
              Text('سطح $currentLevel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.warning)),
            ]),
          ),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.lightPrimaryContainer, borderRadius: BorderRadius.circular(8)),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('سطح لازم:', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
              Text('سطح $requiredLevel', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.lightPrimary)),
            ]),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('بستن')),
        ElevatedButton(
          onPressed: () { Get.back(); Get.toNamed(BaseRoute.idVerification); },
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.lightPrimary, foregroundColor: AppColors.white),
          child: Text('شروع احراز هویت'),
        ),
      ],
    );
  }
}
