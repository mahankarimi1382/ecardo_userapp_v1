import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
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
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/dashboard_sliver_header.dart';

/// Dashboard structure (v1.0.60):
/// CustomScrollView
///   1. SliverAppBar (floating+snap) — greeting header expands/collapses
///   2. SliverToBoxAdapter — TopHeader (UID + action buttons)
///   3. wallet / referral / services / transactions (unchanged sections)
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
        if (!mounted) return;
        showGiftDialog(signUpBonus: widget.signUpBonus!);
        await Get.find<SettingsService>().saveBonusPopUpShow(email, true);
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) {
        showExitApplicationAlertDialog();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColors.lightBackground,
          body: Stack(
            children: [
              Obx(() {
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
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      // --- collapsible greeting ---
                      SliverPersistentHeader(
                        pinned: false,
                        floating: true,
                        delegate: DashboardSliverHeaderDelegate(
                          topInset: MediaQuery.paddingOf(context).top,
                        ),
                      ),
                      // --- purple UID + action buttons (unchanged section) ---
                      const SliverToBoxAdapter(child: TopHeaderSection()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                      const SliverToBoxAdapter(child: MyWalletSection()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                      const SliverToBoxAdapter(child: ReferralStatsSection()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                      const SliverToBoxAdapter(child: OtherServicesSection()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                      const SliverToBoxAdapter(child: TravelServicesSection()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                      const SliverToBoxAdapter(
                        child: BusinessServicesSection(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                      const SliverToBoxAdapter(
                        child: RecentTransactionsSection(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                    ],
                  ),
                );
              }),
              Obx(
                () => Visibility(
                  visible: homeController.isSignOutLoading.value,
                  child: const CommonLoading(),
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
