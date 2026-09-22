import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/business_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/home_skeleton_loader.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/travel_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/my_wallet_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/other_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/recent_transactions_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/referral_stats_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/sign_up_bonus_pop_up.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/top_header_section.dart';

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
                () {
                  if (homeController.isLoading.value) {
                    return const HomeSkeletonLoader();
                  }
                  if (homeController.loadError.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.cloud_off_rounded,
                                size: 48, color: AppColors.lightPrimary),
                            const SizedBox(height: 12),
                            Text(
                              homeController.loadError.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => homeController.loadData(),
                              icon: const Icon(Icons.refresh_rounded),
                              label: const Text('تلاش مجدد'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return RefreshIndicator(
                        color: AppColors.lightPrimary,
                        onRefresh: () => homeController.loadData(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TopHeaderSection(),
                              const SizedBox(height: 20),
                              MyWalletSection(),
                              SizedBox(height: 20),
                              // v1.0.38 (DASHBOARD): referral bonus/count
                              // came from the dashboard API but was never
                              // rendered — slim stat strip, hides itself
                              // when the server sends no referral data.
                              ReferralStatsSection(),
                              SizedBox(height: 20),
                              OtherServicesSection(),
                              SizedBox(height: 20),
                              // v1.0.46 (TRAVEL SERVICES): destination
                              // chips + the traveler services; built
                              // modules open their real screens.
                              TravelServicesSection(),
                              SizedBox(height: 20),
                              // v1.0.45 (BUSINESS SERVICES): remittance,
                              // money transfer, escrow + upcoming
                              // commercial modules.
                              BusinessServicesSection(),
                              const SizedBox(height: 20),
                              RecentTransactionsSection(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      );
                },
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
