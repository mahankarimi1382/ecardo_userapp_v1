import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';

class OtherServicesSection extends StatefulWidget {
  const OtherServicesSection({super.key});

  @override
  State<OtherServicesSection> createState() => _OtherServicesSectionState();
}

class _OtherServicesSectionState extends State<OtherServicesSection> {
  final HomeController homeController = Get.find();
  final SettingsService settings = Get.find();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _handleKycNavigation({
    required String settingKey,
    required String route,
  }) {
    final localization = AppLocalizations.of(context)!;
    final kycEnabled = settings.getSetting(settingKey) != "0";
    final userKyc = homeController.userModel.value.data?.kyc ?? 0;

    if (!kycEnabled && userKyc == 0) {
      ToastHelper().showErrorToast(localization.otherServicesKycVerification);
      return;
    }

    if (route.isNotEmpty) Get.toNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    final List<Map<String, String>> serviceList = [
      {
        "title": localization.otherServicesQrCode,
        "icon": PngAssets.qrCodeService,
        "navigate": BaseRoute.qrCode,
      },
      {
        "title": localization.otherServicesAddMoney,
        "icon": PngAssets.addMoneyService,
        "navigate": BaseRoute.addMoney,
      },
      if (settings.getSetting("agent_system") == "1")
        {
          "title": localization.otherServicesCashOut,
          "icon": PngAssets.cashOutService,
          "navigate": BaseRoute.cashOut,
        },
      if (settings.getSetting("merchant_system") == "1")
        {
          "title": localization.otherServicesMakePayment,
          "icon": PngAssets.makePaymentService,
          "navigate": BaseRoute.makePayment,
        },
      {
        "title": localization.otherServicesTransactions,
        "icon": PngAssets.transactionService,
        "navigate": BaseRoute.transactions,
      },
      {
        "title": localization.otherServicesPaymentLinks,
        "icon": PngAssets.paymentLinksService,
        "navigate": BaseRoute.paymentLinks,
      },
      {
        "title": localization.otherServicesRequestMoney,
        "icon": PngAssets.requestMoneyService,
        "navigate": BaseRoute.requestMoney,
      },
      {
        "title": localization.otherServicesGift,
        "icon": PngAssets.giftService,
        "navigate": BaseRoute.giftCode,
      },
      {
        "title": localization.otherServicesWallets,
        "icon": PngAssets.walletsService,
        "navigate": BaseRoute.wallets,
      },
      {
        "title": localization.otherServicesWithdraw,
        "icon": PngAssets.withdrawService,
        "navigate": BaseRoute.withdraw,
      },
      {
        "title": localization.otherServicesExchange,
        "icon": PngAssets.exchangeService,
        "navigate": BaseRoute.exchange,
      },
      {
        "title": localization.otherServicesTransfer,
        "icon": PngAssets.transferService,
        "navigate": BaseRoute.transfer,
      },
      {
        "title": localization.otherServicesInvite,
        "icon": PngAssets.inviteService,
        "navigate": BaseRoute.referral,
      },
      {
        "title": localization.otherServicesBillPayment,
        "icon": PngAssets.billPaymentService,
        "navigate": BaseRoute.billPayment,
      },
      if (homeController.userModel.value.data?.addons?.virtualCards == true)
        {
          "title": localization.otherServicesVirtualCard,
          "icon": PngAssets.virtualCardService,
          "navigate": BaseRoute.virtualCard,
        },
      if (homeController.userModel.value.data?.addons?.giftCards == true)
        {
          "title": localization.otherServicesGiftCards,
          "icon": PngAssets.giftCardsService,
          "navigate": BaseRoute.giftCard,
        },
      if (homeController.userModel.value.data?.addons?.p2pTrading == true)
        {
          "title": localization.otherServicesP2pTrading,
          "icon": PngAssets.p2pTradingService,
          "navigate": BaseRoute.p2pTrading,
        },
    ];

    final int itemsPerPage = 8;
    final int pageCount = (serviceList.length / itemsPerPage).ceil();

    final pages = List.generate(pageCount, (index) {
      final start = index * itemsPerPage;
      final end = (start + itemsPerPage < serviceList.length)
          ? start + itemsPerPage
          : serviceList.length;
      return serviceList.sublist(start, end);
    });

    final rows = ((pages.first.length) / 4).ceil();
    final double dynamicHeight = rows * 90.0;

    return Column(
      children: [
        SectionHeader(
          sectionName: localization.otherServicesTitle,
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
          child: Column(
            children: [
              SizedBox(
                height: dynamicHeight,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: pages.length,
                  onPageChanged: (index) =>
                      setState(() => _currentPage = index),
                  itemBuilder: (context, pageIndex) {
                    final pageItems = pages[pageIndex];
                    return GridView.builder(
                      itemCount: pageItems.length,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1,
                          ),
                      itemBuilder: (context, index) {
                        final item = pageItems[index];
                        final title = item["title"]!;
                        final route = item["navigate"] ?? '';

                        return InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            switch (title) {
                              case "Gift":
                                if (settings.getSetting("user_gift") == "1") {
                                  _handleKycNavigation(
                                    settingKey: "kyc_gift",
                                    route: route,
                                  );
                                } else {
                                  ToastHelper().showErrorToast(
                                    localization
                                        .otherServicesUserGiftNotEnabled,
                                  );
                                }
                                break;

                              case "Add Money":
                                if (settings.getSetting("user_deposit") ==
                                    "1") {
                                  _handleKycNavigation(
                                    settingKey: "kyc_deposit",
                                    route: route,
                                  );
                                } else {
                                  ToastHelper().showErrorToast(
                                    localization
                                        .otherServicesUserDepositNotEnabled,
                                  );
                                }
                                break;

                              default:
                                if (route.isNotEmpty) Get.toNamed(route);
                                break;
                            }
                          },
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(item["icon"]!, width: 35),
                              const SizedBox(height: 8),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(
                                    0xFF2D2D2D,
                                  ).withValues(alpha: 0.60),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        if (serviceList.length > 8) ...[
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                height: 6,
                width: _currentPage == index ? 16 : 6,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.lightPrimary
                      : AppColors.lightPrimary.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
