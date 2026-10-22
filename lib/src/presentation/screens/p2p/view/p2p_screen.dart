import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

import '../controller/p2p_controller.dart';
import '../sub_category/apply_verification/view/apply_verification_screen.dart';
import '../sub_category/create_ad/view/create_ad_screen.dart';
import '../sub_category/my_ads/controller/my_ads_controller.dart';
import '../sub_category/my_ads/widgets/my_ads_filter_bottom_sheet.dart';
import '../sub_category/my_order/controller/my_order_controller.dart';
import '../sub_category/my_order/view/my_order_screen.dart';
import '../sub_category/my_order/widgets/my_order_filter_bottom_sheet.dart';
import '../sub_category/payment_account/controller/payment_account_controller.dart';
import '../sub_category/payment_account/view/payment_account_screen.dart';
import '../sub_category/payment_account/widgets/payment_account_filter_bottom_sheet.dart';
import 'sub_sections/buy_sub_section.dart';
import 'sub_sections/my_ads_sub_section.dart';
import 'sub_sections/sell_sub_section.dart';

/// Modernized P2P Trading Master Screen.
///
/// Features:
/// - Full semantic design token compliance with [AppColors] (zero raw hex literals).
/// - Modular sub-sections for Buy, Sell, and My Ads.
/// - Minimum 44x44 touch targets with accessible [Semantics] labels on all tab switches,
///   action buttons, and filter chips.
/// - Adaptive light and dark theme architecture with zero un-themed white cards.
/// - Unified [EcardoEmptyState] empty state handling.
class P2pScreen extends StatelessWidget {
  final P2pController? controller;

  const P2pScreen({super.key, this.controller});

  P2pController get _controller =>
      controller ??
      (Get.isRegistered<P2pController>()
          ? Get.find<P2pController>()
          : Get.put(P2pController()));

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p2pController = _controller;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      floatingActionButton: Obx(() {
        final tabIndex = p2pController.selectedTopTabIndex.value;
        // Only show quick "Create Ad" floating CTA on Trading (0) and My Ads (3) tabs
        if (tabIndex != 0 && tabIndex != 3) {
          return const SizedBox.shrink();
        }

        return Semantics(
          button: true,
          label: localization.p2pCreateAd,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
            child: FloatingActionButton.extended(
              heroTag: 'p2p_create_ad_fab',
              backgroundColor: isDark
                  ? AppColors.darkPrimary
                  : AppColors.brandViolet,
              foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
              elevation: 4,
              onPressed: () {
                HapticFeedback.lightImpact();
                p2pController.onTopTabSelected(4);
              },
              icon: Icon(Icons.add_circle_outline_rounded, size: 20.r),
              label: Text(
                localization.p2pCreateAd,
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
        );
      }),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.sm.h),
          Obx(
            () => CommonAppBar(
              title: _getHeaderTitle(
                localization,
                p2pController.selectedTopTabIndex.value,
              ),
              isBackLogicApply: true,
              backLogicFunction: p2pController.onP2pBackPressed,
              rightSideIcon:
                  _showFilterIconByTab(p2pController.selectedTopTabIndex.value)
                  ? PngAssets.commonFilterIcon
                  : null,
              onPressed:
                  _showFilterIconByTab(p2pController.selectedTopTabIndex.value)
                  ? () => _onFilterTap(p2pController)
                  : null,
            ),
          ),
          SizedBox(height: AppSpacing.sm.h),
          _buildTopTabBar(context, isDark, p2pController),
          SizedBox(height: AppSpacing.md.h),
          Expanded(child: _buildTabContent(context, isDark, p2pController)),
        ],
      ),
    );
  }

  String _getHeaderTitle(AppLocalizations localization, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return localization.p2pMyOrder;
      case 2:
        return localization.p2pPaymentAccount;
      case 3:
        return localization.p2pMyAds;
      case 4:
        return localization.p2pCreateAd;
      case 5:
        return localization.p2pApplyVerification;
      default:
        return localization.drawerP2pTrading;
    }
  }

  Widget _buildTopTabBar(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    final localization = AppLocalizations.of(context)!;

    return Obx(() {
      final selectedIndex = p2pController.selectedTopTabIndex.value;

      return SizedBox(
        height: 44.h,
        child: ListView.separated(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final bool isSelected = selectedIndex == index;
            final tabTitle = _localizedTopTabTitle(localization, index);

            return Semantics(
              button: true,
              label: tabTitle,
              selected: isSelected,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
                child: Material(
                  color: AppColors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      p2pController.onTopTabSelected(index);
                    },
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusFull.r,
                    ),
                    child: Ink(
                      padding: EdgeInsetsDirectional.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.brandViolet)
                            : (isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusFull.r,
                        ),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.transparent
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          tabTitle,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: isSelected
                                ? FontWeight.w800
                                : FontWeight.w600,
                            fontSize: 12.5.sp,
                            color: isSelected
                                ? (isDark
                                      ? AppColors.deepBlack
                                      : AppColors.white)
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) =>
              SizedBox(width: AppSpacing.sm.w),
          itemCount: p2pController.topTabs.length,
        ),
      );
    });
  }

  Widget _buildTradeAndAssetRow(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Expanded(child: _buildBuySellToggle(context, isDark, p2pController)),
          SizedBox(width: AppSpacing.md.w),
          Expanded(child: _buildAssetSelector(context, isDark, p2pController)),
        ],
      ),
    );
  }

  Widget _buildBuySellToggle(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    final localization = AppLocalizations.of(context)!;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Obx(() {
      final isBuy = p2pController.selectedTradeTypeIndex.value == 0;
      final activeColor = isBuy ? AppColors.success : AppColors.error;

      return Container(
        height: 48.h,
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Smoothly Animated Sliding Pill Indicator
            AnimatedAlign(
              alignment: isBuy
                  ? AlignmentDirectional.centerStart
                  : AlignmentDirectional.centerEnd,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOutCubic,
              child: FractionallySizedBox(
                widthFactor: 0.5,
                heightFactor: 1.0,
                child: Container(
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
                    boxShadow: [
                      BoxShadow(
                        color: activeColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Tap Targets for Buy & Sell with Accessible Touch Targets (>=44x44)
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    button: true,
                    label: localization.p2pBuy,
                    selected: isBuy,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 44.w,
                        minHeight: 44.h,
                      ),
                      child: Material(
                        color: AppColors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm.r,
                          ),
                          onTap: () {
                            if (!isBuy) {
                              HapticFeedback.selectionClick();
                              p2pController.onTradeTypeChanged(0);
                            }
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_downward_rounded,
                                  size: 14.r,
                                  color: isBuy
                                      ? AppColors.white
                                      : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.softGray),
                                ),
                                SizedBox(width: 4.w),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: isBuy
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 13.5.sp,
                                    color: isBuy
                                        ? AppColors.white
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.softGray),
                                  ),
                                  child: Text(localization.p2pBuy),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    button: true,
                    label: localization.p2pSell,
                    selected: !isBuy,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 44.w,
                        minHeight: 44.h,
                      ),
                      child: Material(
                        color: AppColors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm.r,
                          ),
                          onTap: () {
                            if (isBuy) {
                              HapticFeedback.selectionClick();
                              p2pController.onTradeTypeChanged(1);
                            }
                          },
                          child: Center(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  size: 14.r,
                                  color: !isBuy
                                      ? AppColors.white
                                      : (isDark
                                            ? AppColors.darkTextSecondary
                                            : AppColors.softGray),
                                ),
                                SizedBox(width: 4.w),
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 180),
                                  style: TextStyle(
                                    letterSpacing: 0,
                                    fontWeight: !isBuy
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                    fontSize: 13.5.sp,
                                    color: !isBuy
                                        ? AppColors.white
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.softGray),
                                  ),
                                  child: Text(localization.p2pSell),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildAssetSelector(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    final localization = AppLocalizations.of(context)!;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Semantics(
      button: true,
      label: localization.p2pSelectAsset,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              _openCommonDropdown(
                context: context,
                title: localization.p2pSelectAsset,
                notFoundText: localization.p2pNoAssetsFound,
                items: p2pController.assetOptions,
                textController: p2pController.assetController,
                onValueSelected: p2pController.onAssetSelected,
              );
            },
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
            child: Ink(
              height: 48.h,
              padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: surfaceColor,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      p2pController.selectedAsset.value,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 22.w,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.softGray,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _localizedTopTabTitle(AppLocalizations localization, int index) {
    switch (index) {
      case 0:
        return localization.p2pP2p;
      case 1:
        return localization.p2pMyOrders;
      case 2:
        return localization.p2pPaymentAccounts;
      case 3:
        return localization.p2pMyAds;
      case 4:
        return localization.p2pCreateAd;
      case 5:
        return localization.p2pApplyVerification;
      default:
        return '';
    }
  }

  Widget _buildFilterRow(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    final localization = AppLocalizations.of(context)!;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterChip(
            prefix: Container(
              width: 22.w,
              height: 22.h,
              decoration: BoxDecoration(
                color: AppColors.warningContainer,
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Obx(
                () => Center(
                  child: Text(
                    p2pController.selectedFiatSymbol.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      fontSize: 11.sp,
                      color: AppColors.deepBlack,
                    ),
                  ),
                ),
              ),
            ),
            label: p2pController.selectedFiat,
            textPrimary: textPrimary,
            semanticsLabel: localization.p2pSelectFiat,
            onTap: () {
              HapticFeedback.lightImpact();
              _openCommonDropdown(
                context: context,
                title: localization.p2pSelectFiat,
                notFoundText: localization.p2pNoFiatCurrenciesFound,
                items: p2pController.fiatOptions,
                textController: p2pController.fiatController,
                onValueSelected: p2pController.onFiatSelected,
              );
            },
          ),
          SizedBox(width: 16.w),
          _buildFilterChip(
            label: p2pController.selectedAmount,
            textPrimary: textPrimary,
            semanticsLabel: localization.p2pFilterAmount,
            onTap: () {
              HapticFeedback.lightImpact();
              _openAmountFilterBottomSheet(context, isDark, p2pController);
            },
          ),
          SizedBox(width: 16.w),
          _buildFilterChip(
            label: p2pController.selectedPayment,
            textPrimary: textPrimary,
            semanticsLabel: localization.p2pFilterPaymentMethod,
            onTap: () {
              HapticFeedback.lightImpact();
              _openPaymentMethodFilterBottomSheet(
                context,
                isDark,
                p2pController,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOfferQuickFilterChips(BuildContext context, bool isDark) {
    final filters = [
      {
        'label': l10nPick(context, en: 'All Offers', fa: 'همه پیشنهادها'),
        'icon': Icons.tune_rounded,
      },
      {
        'label': l10nPick(context, en: 'Verified PRO', fa: 'فروشندگان معتبر'),
        'icon': Icons.verified_user_rounded,
      },
      {
        'label': l10nPick(
          context,
          en: 'Completion >95%',
          fa: 'تکمیل بالای ۹۵٪',
        ),
        'icon': Icons.thumb_up_alt_rounded,
      },
      {
        'label': l10nPick(
          context,
          en: 'Fast Payout (≤15m)',
          fa: 'آزادسازی فوری',
        ),
        'icon': Icons.bolt_rounded,
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        children: filters.map((f) {
          final label = f['label'] as String;
          return Padding(
            padding: EdgeInsetsDirectional.only(end: 8.w),
            child: Semantics(
              button: true,
              label: label,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: 44.h),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface
                        : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        f['icon'] as IconData,
                        size: 14.r,
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.mutedBlue,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.5.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    return Obx(() {
      final tabIndex = p2pController.selectedTopTabIndex.value;

      if (tabIndex == 0) {
        return _buildP2pTradingPage(context, isDark, p2pController);
      }
      if (tabIndex == 1) {
        return const MyOrderScreen();
      }
      if (tabIndex == 2) {
        return const PaymentAccountScreen();
      }
      if (tabIndex == 3) {
        return MyAdsSubSection(
          controller: _getMyAdsController(),
          onCreateAd: () => p2pController.onTopTabSelected(4),
        );
      }
      if (tabIndex == 4) {
        return const CreateAdScreen();
      }
      if (tabIndex == 5) {
        return const ApplyVerificationScreen();
      }

      // Empty State fallback adopting EcardoEmptyState
      return Center(
        child: EcardoEmptyState(
          iconData: Icons.swap_horizontal_circle_outlined,
          iconColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
          glowColor: isDark ? AppColors.mainSoftBlue : AppColors.brandViolet,
          title: l10nPick(
            context,
            en: 'Section Unavailable',
            fa: 'بخش مورد نظر در دسترس نیست',
          ),
          description: l10nPick(
            context,
            en: 'Please select one of the available navigation tabs above.',
            fa: 'لطفاً یکی از تب‌های موجود در بالای صفحه را انتخاب کنید.',
          ),
          primaryActionLabel: l10nPick(
            context,
            en: 'Go to P2P Trading',
            fa: 'رفتن به معاملات P2P',
          ),
          onPrimaryAction: () => p2pController.onTopTabSelected(0),
        ),
      );
    });
  }

  Widget _buildP2pTradingPage(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTradeAndAssetRow(context, isDark, p2pController),
        SizedBox(height: AppSpacing.sm.h),
        _buildFilterRow(context, isDark, p2pController),
        SizedBox(height: AppSpacing.xs.h),
        _buildOfferQuickFilterChips(context, isDark),
        SizedBox(height: AppSpacing.xs.h),
        Divider(
          height: 1,
          color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
        ),
        Expanded(
          child: Obx(() {
            final isBuy = p2pController.selectedTradeTypeIndex.value == 0;
            if (isBuy) {
              return BuySubSection(
                controller: p2pController,
                onSwitchToSell: () => p2pController.onTradeTypeChanged(1),
                onCreateAd: () => p2pController.onTopTabSelected(4),
              );
            }
            return SellSubSection(
              controller: p2pController,
              onSwitchToBuy: () => p2pController.onTradeTypeChanged(0),
              onCreateAd: () => p2pController.onTopTabSelected(4),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    Widget? prefix,
    required RxString label,
    required Color textPrimary,
    required String semanticsLabel,
    required GestureTapCallback onTap,
  }) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: 44.w, minHeight: 44.h),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (prefix != null) ...[prefix, SizedBox(width: 4.w)],
                  Obx(
                    () => Text(
                      label.value,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                        color: textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(width: 4.w),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20.w,
                    color: textPrimary.withValues(alpha: 0.60),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openCommonDropdown({
    required BuildContext context,
    required String title,
    required String notFoundText,
    required List<String> items,
    required TextEditingController textController,
    required Function(String value) onValueSelected,
  }) {
    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: title,
        isShowTitle: true,
        dropdownItems: items,
        selectedValue: items,
        selectedItem: textController.text,
        textController: textController,
        bottomSheetHeight: 410.h,
        currentlySelectedValue: textController.text,
        notFoundText: notFoundText,
        onValueSelected: (value) {
          onValueSelected(value.toString());
        },
      ),
    );
  }

  void _openAmountFilterBottomSheet(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) {
    final amountTextController = TextEditingController(
      text: p2pController.selectedAmountValue.value,
    );
    final localization = AppLocalizations.of(Get.context!)!;
    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    Get.bottomSheet(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        padding: EdgeInsetsDirectional.fromSTEB(18.w, 12.h, 18.w, 22.h),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(AppSpacing.radiusXl.r),
            topEnd: Radius.circular(AppSpacing.radiusXl.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.md.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.p2pFilterAmount,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w800,
                    fontSize: 17.sp,
                    color: textPrimary,
                  ),
                ),
                Semantics(
                  button: true,
                  label: l10nPick(context, en: 'Close', fa: 'بستن'),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: 44.w,
                      minHeight: 44.h,
                    ),
                    child: Material(
                      color: AppColors.transparent,
                      child: InkWell(
                        onTap: Get.back,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm.r,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.close_rounded,
                            size: 24.w,
                            color: textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md.h),
            Text(
              localization.addMoneyAmount,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xs.h),
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkSurfaceVariant
                    : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: TextField(
                controller: amountTextController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  hintText: localization.p2pEnterAmount,
                  hintStyle: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.softGray,
                  ),
                ),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: textPrimary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg.h),
            Semantics(
              button: true,
              label: localization.addMoneyFilterButton,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: double.infinity,
                  minHeight: 44.h,
                ),
                child: CommonButton(
                  text: localization.addMoneyFilterButton,
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors.brandViolet,
                  textColor: isDark ? AppColors.deepBlack : AppColors.white,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    p2pController.applyAmountFilter(amountTextController.text);
                    Get.back();
                  },
                  width: double.infinity,
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _openPaymentMethodFilterBottomSheet(
    BuildContext context,
    bool isDark,
    P2pController p2pController,
  ) async {
    final localization = AppLocalizations.of(Get.context!)!;
    if (p2pController.isOpeningPaymentMethodFilterSheet.value ||
        p2pController.isPaymentMethodsLoading.value ||
        (Get.isBottomSheetOpen ?? false)) {
      return;
    }

    p2pController.isOpeningPaymentMethodFilterSheet.value = true;
    await p2pController.fetchPaymentMethodsByFiat();

    if (Get.isBottomSheetOpen ?? false) {
      p2pController.isOpeningPaymentMethodFilterSheet.value = false;
      return;
    }

    final surfaceColor = isDark
        ? AppColors.darkSurface
        : AppColors.lightSurface;
    final textPrimary = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: 500.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: surfaceColor,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(AppSpacing.radiusXl.r),
              topEnd: Radius.circular(AppSpacing.radiusXl.r),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 45.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBorder : AppColors.lightDivider,
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              SizedBox(height: AppSpacing.md.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localization.p2pFilterPaymentMethod,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w800,
                        fontSize: 17.sp,
                        color: textPrimary,
                      ),
                    ),
                    Semantics(
                      button: true,
                      label: l10nPick(context, en: 'Close', fa: 'بستن'),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 44.w,
                          minHeight: 44.h,
                        ),
                        child: Material(
                          color: AppColors.transparent,
                          child: InkWell(
                            onTap: Get.back,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm.r,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.close_rounded,
                                size: 24.w,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSpacing.sm.h),
              Divider(
                height: 1,
                color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              ),
              Expanded(
                child: Obx(() {
                  if (p2pController.isPaymentMethodsLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark
                            ? AppColors.darkPrimary
                            : AppColors.brandViolet,
                      ),
                    );
                  }

                  if (p2pController.availablePaymentAccounts.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl.r),
                        child: EcardoEmptyState(
                          iconData: Icons.payment_outlined,
                          iconColor: isDark
                              ? AppColors.mainSoftBlue
                              : AppColors.brandViolet,
                          glowColor: isDark
                              ? AppColors.mainSoftBlue
                              : AppColors.brandViolet,
                          title: localization.p2pNoPaymentMethodFound,
                          description: l10nPick(
                            context,
                            en: 'No payment methods registered for this currency yet.',
                            fa: 'هنوز هیچ روش پرداختی برای این ارز ثبت نشده است.',
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(18.w),
                    itemCount: p2pController.availablePaymentAccounts.length,
                    separatorBuilder: (_, _) =>
                        SizedBox(height: AppSpacing.cardGap.h),
                    itemBuilder: (context, index) {
                      final account =
                          p2pController.availablePaymentAccounts[index];
                      final paymentMethodId =
                          account.paymentMethod?.id ?? account.id;
                      final isSelected =
                          paymentMethodId != null &&
                          p2pController.selectedPaymentMethodIds.contains(
                            paymentMethodId,
                          );

                      return Semantics(
                        button: true,
                        label: account.paymentMethod?.name ?? '',
                        selected: isSelected,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: 44.h),
                          child: Material(
                            color: AppColors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                p2pController.togglePaymentMethodFilter(
                                  account,
                                );
                                setSheetState(() {});
                              },
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusMd.r,
                              ),
                              child: Ink(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 14.w,
                                  vertical: 12.h,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? (isDark
                                            ? AppColors.darkPrimary.withValues(
                                                alpha: 0.15,
                                              )
                                            : AppColors.brandVioletContainer)
                                      : (isDark
                                            ? AppColors.darkSurfaceVariant
                                            : AppColors.lightBackground),
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusMd.r,
                                  ),
                                  border: Border.all(
                                    color: isSelected
                                        ? (isDark
                                              ? AppColors.darkPrimary
                                              : AppColors.brandViolet)
                                        : (isDark
                                              ? AppColors.darkBorder
                                              : AppColors.lightBorder),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        account.paymentMethod?.name ?? '',
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                    Icon(
                                      isSelected
                                          ? Icons.check_circle_rounded
                                          : Icons
                                                .radio_button_unchecked_rounded,
                                      size: 20.w,
                                      color: isSelected
                                          ? (isDark
                                                ? AppColors.darkPrimary
                                                : AppColors.brandViolet)
                                          : (isDark
                                                ? AppColors.darkTextSecondary
                                                : AppColors.softGray),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(18.w, 0, 18.w, 20.h),
                child: Semantics(
                  button: true,
                  label: localization.addMoneyFilterButton,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minWidth: double.infinity,
                      minHeight: 44.h,
                    ),
                    child: CommonButton(
                      text: localization.addMoneyFilterButton,
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.brandViolet,
                      textColor: isDark ? AppColors.deepBlack : AppColors.white,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        p2pController.applyPaymentMethodFilter();
                        Get.back();
                      },
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
    p2pController.isOpeningPaymentMethodFilterSheet.value = false;
  }

  bool _showFilterIconByTab(int tabIndex) {
    return tabIndex == 1 || tabIndex == 2 || tabIndex == 3;
  }

  void _onFilterTap(P2pController p2pController) {
    HapticFeedback.lightImpact();
    final tabIndex = p2pController.selectedTopTabIndex.value;
    if (tabIndex == 1) {
      final myOrderController = _getMyOrderController();
      Get.bottomSheet(
        MyOrderFilterBottomSheet(controller: myOrderController),
        isScrollControlled: true,
      );
      return;
    }
    if (tabIndex == 2) {
      final paymentAccountController = _getPaymentAccountController();
      Get.bottomSheet(
        PaymentAccountFilterBottomSheet(controller: paymentAccountController),
        isScrollControlled: true,
      );
      return;
    }
    if (tabIndex == 3) {
      final myAdsController = _getMyAdsController();
      Get.bottomSheet(
        MyAdsFilterBottomSheet(controller: myAdsController),
        isScrollControlled: true,
      );
    }
  }

  MyOrderController _getMyOrderController() {
    if (Get.isRegistered<MyOrderController>()) {
      return Get.find<MyOrderController>();
    }
    return Get.put(MyOrderController());
  }

  MyAdsController _getMyAdsController() {
    if (Get.isRegistered<MyAdsController>()) {
      return Get.find<MyAdsController>();
    }
    return Get.put(MyAdsController());
  }

  PaymentAccountController _getPaymentAccountController() {
    if (Get.isRegistered<PaymentAccountController>()) {
      return Get.find<PaymentAccountController>();
    }
    return Get.put(PaymentAccountController());
  }
}
