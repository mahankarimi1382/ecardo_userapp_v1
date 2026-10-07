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
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/services_entry_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/home_skeleton_loader.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/my_wallet_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/referral_stats_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/sign_up_bonus_pop_up.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/top_header_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/dashboard_sliver_header.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/balance_hero_section.dart';

/// Dashboard structure (v1.0.146 UX pass):
/// CustomScrollView
///   1. SliverAppBar (floating+snap) — greeting header expands/collapses
///   2. SliverToBoxAdapter — TopHeader (UID + action buttons)
///   3. Balance Hero, Wallets, Referral stats
///   4. Compact "All Services" entry card
///
/// SERVICES HUB MOVE: the three service grids (financial / travel /
/// business) and the recent-transactions card no longer live here — they
/// moved to the dedicated ServicesScreen (BaseRoute.services) so the home
/// screen stays clean and fast.
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        showExitApplicationAlertDialog();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor:
              isDark ? AppColors.darkBackground : AppColors.lightBackground,
          systemNavigationBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
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
                          Icon(
                            Icons.cloud_off_rounded,
                            size: 48,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            homeController.loadError.value,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => homeController.loadData(),
                            icon: const Icon(Icons.refresh_rounded),
                            style: TextButton.styleFrom(
                              foregroundColor: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                            label: Text(
                              l10nPick(
                                context,
                                en: 'Retry',
                                fa: 'تلاش مجدد',
                                ar: 'إعادة المحاولة',
                                zh: '重试',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  color: theme.colorScheme.primary,
                  backgroundColor:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
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
                      // --- TopHeader (UID only) ---
                      const SliverToBoxAdapter(child: TopHeaderSection()),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: AppSpacing.sectionGap),
                      ),
                      // --- Balance Hero (replaces old action buttons) ---
                      const SliverToBoxAdapter(child: BalanceHeroSection()),
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
                      // SERVICES HUB MOVE: entry card to the dedicated
                      // All-Services page (financial / travel / business
                      // grids + recent transactions live there now).
                      const SliverToBoxAdapter(
                        child: ServicesEntrySection(),
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
