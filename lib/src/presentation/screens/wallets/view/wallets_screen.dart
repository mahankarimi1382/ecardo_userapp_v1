import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/net_worth_banner.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/wallet_filter_chips.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/sub_sections/wallets_card_section.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final WalletsController walletsController = Get.find<WalletsController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          Get.offNamed(BaseRoute.navigation);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: const CommonDefaultAppBar(),
        floatingActionButton: Obx(() {
          if (walletsController.isLoading.value ||
              walletsController.isError.value ||
              walletsController.walletsList.isEmpty) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton.extended(
            onPressed: () {
              HapticFeedback.lightImpact();
              Get.toNamed(BaseRoute.createNewWallet);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: isDark ? AppColors.deepBlack : AppColors.warmWhite,
            elevation: 4,
            icon: const Icon(Icons.add_rounded, size: 20),
            label: Text(
              l10nPick(
                context,
                en: 'Add Wallet',
                fa: 'افزودن کیف پول',
                ar: 'إضافة محفظة',
                tr: 'Cüzdan Ekle',
                ru: 'Добавить кошелёк',
                zh: '添加钱包',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                letterSpacing: 0.2,
              ),
            ),
          );
        }),
        body: Column(
          children: [
            const SizedBox(height: AppSpacing.page),
            CommonAppBar(
              title: localization.walletsScreenTitle,
              isBackLogicApply: true,
              backLogicFunction: () async {
                Get.offNamed(BaseRoute.navigation);
              },
              rightSideWidget: Semantics(
                button: true,
                label: localization.walletListEmptyCreate,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Get.toNamed(BaseRoute.createNewWallet);
                  },
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 18),
                      child: Image.asset(
                        PngAssets.commonWalletAddIcon,
                        width: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() {
                if (walletsController.isLoading.value) {
                  return const _WalletsShimmerLoader();
                }

                if (walletsController.isError.value) {
                  return _WalletsErrorState(
                    onRetry: walletsController.fetchWallets,
                  );
                }

                final hasWallets = walletsController.walletsList.isNotEmpty;
                if (!hasWallets) {
                  return _WalletsEmptyState(
                    onRefresh: walletsController.fetchWallets,
                  );
                }

                return RefreshIndicator(
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                      isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  onRefresh: () => walletsController.fetchWallets(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.only(bottom: 88),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(height: 12),
                        NetWorthBanner(),
                        SizedBox(height: 16),
                        WalletFilterChips(),
                        SizedBox(height: 16),
                        WalletsCardSection(),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _WalletsShimmerLoader extends StatelessWidget {
  const _WalletsShimmerLoader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? const Color(0xFF262625) : Colors.grey.shade300;
    final highlightColor =
        isDark ? const Color(0xFF383836) : Colors.grey.shade100;
    final blockColor = isDark ? const Color(0xFF262625) : AppColors.white;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsetsDirectional.fromSTEB(
          AppSpacing.page,
          12,
          AppSpacing.page,
          24,
        ),
        children: [
          // Net Worth Banner Shimmer
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 16),
          // Filter Chips Shimmer
          Container(
            height: 42,
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const SizedBox(height: 16),
          // Hero Cards Shimmer
          Container(
            height: 215,
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 215,
            decoration: BoxDecoration(
              color: blockColor,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ],
      ),
    );
  }
}

class _WalletsErrorState extends StatelessWidget {
  final Future<void> Function() onRetry;

  const _WalletsErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onRefresh: onRetry,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: EcardoErrorView(
                    // Left off deliberately: the radar pulse repeats forever, so
                    // the tree never goes idle and `pumpAndSettle` times out.
                    animatePulse: false,
                    // The screen's existing "no connection" glyph. The component
                    // default is `wifi_off_rounded`, which reads as a different
                    // failure than the one this screen actually reports.
                    iconData: Icons.cloud_off_rounded,
                    title: localization.allControllerLoadError,
                    message: localization.noInternetConnectionMessage,
                    retryLabel:
                        localization.noInternetConnectionRetryButton,
                    onRetry: () {
                      HapticFeedback.lightImpact();
                      onRetry();
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WalletsEmptyState extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _WalletsEmptyState({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return RefreshIndicator(
      color: Theme.of(context).colorScheme.primary,
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: EcardoEmptyState(
                    // Left off deliberately: the breathing glow repeats forever, so
                    // the tree never goes idle and `pumpAndSettle` times out.
                    animateGlow: false,
                    iconData: Icons.account_balance_wallet_outlined,
                    iconColor:
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    glowColor:
                        isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    title: localization.walletListEmptyTitle,
                    description: localization.walletListEmptySubtitle,
                    // The component renders the primary CTA above the secondary,
                    // and only when both the label and the callback are non-null.
                    // "Create wallet" is the screen's established primary action
                    // (it is also the app bar's action), so it goes first.
                    primaryActionLabel: localization.walletListEmptyCreate,
                    onPrimaryAction: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(BaseRoute.createNewWallet);
                    },
                    secondaryActionLabel: localization.addMoneyTitle,
                    onSecondaryAction: () {
                      HapticFeedback.lightImpact();
                      Get.toNamed(BaseRoute.addMoney);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
