import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/widgets/no_data_found.dart';

import '../controller/p2p_controller.dart';
import '../sub_category/apply_verification/view/apply_verification_screen.dart';
import '../sub_category/create_ad/view/create_ad_screen.dart';
import '../sub_category/my_ads/controller/my_ads_controller.dart';
import '../sub_category/my_ads/view/my_ads_screen.dart';
import '../sub_category/my_ads/widgets/my_ads_filter_bottom_sheet.dart';
import '../sub_category/my_order/controller/my_order_controller.dart';
import '../sub_category/my_order/widgets/my_order_filter_bottom_sheet.dart';
import '../sub_category/my_order/view/my_order_screen.dart';
import '../sub_category/payment_account/controller/payment_account_controller.dart';
import '../sub_category/payment_account/widgets/payment_account_filter_bottom_sheet.dart';
import '../sub_category/payment_account/view/payment_account_screen.dart';
import '../widgets/p2p_ad_card.dart';

class P2pViewScreen extends GetView<P2pController> {
  const P2pViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: AppSpacing.lg.h),
          Obx(
            () => CommonAppBar(
              title: controller.selectedTopTabIndex.value == 1
                  ? localization.p2pMyOrder
                  : controller.selectedTopTabIndex.value == 2
                  ? localization.p2pPaymentAccount
                  : controller.selectedTopTabIndex.value == 3
                  ? localization.p2pMyAds
                  : controller.selectedTopTabIndex.value == 4
                  ? localization.p2pCreateAd
                  : controller.selectedTopTabIndex.value == 5
                  ? localization.p2pApplyVerification
                  : localization.drawerP2pTrading,
              isBackLogicApply: true,
              backLogicFunction: controller.onP2pBackPressed,
              rightSideIcon:
                  _showFilterIconByTab(controller.selectedTopTabIndex.value)
                  ? PngAssets.commonFilterIcon
                  : null,
              onPressed:
                  _showFilterIconByTab(controller.selectedTopTabIndex.value)
                  ? _onFilterTap
                  : null,
            ),
          ),
          SizedBox(height: AppSpacing.md.h),
          _buildTopTabBar(isDark),
          SizedBox(height: AppSpacing.lg.h),
          Expanded(child: _buildTabContent(context, isDark)),
        ],
      ),
    );
  }

  Widget _buildTopTabBar(bool isDark) {
    return Obx(() {
      final selectedIndex = controller.selectedTopTabIndex.value;

      return SizedBox(
        height: 32.h,
        child: ListView.separated(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                controller.onTopTabSelected(index);
              },
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                      : (isDark ? AppColors.darkSurface : AppColors.white),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull.r),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                child: Center(
                  child: Text(
                    _localizedTopTabTitle(localization, index),
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5.sp,
                      color: isSelected
                          ? (isDark ? AppColors.deepBlack : AppColors.white)
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(width: AppSpacing.sm.w);
          },
          itemCount: controller.topTabs.length,
        ),
      );
    });
  }

  Widget _buildTradeAndAssetRow(BuildContext context, bool isDark) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Expanded(child: _buildBuySellToggle(isDark)),
          SizedBox(width: AppSpacing.md.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                _openCommonDropdown(
                  context: context,
                  title: localization.p2pSelectAsset,
                  notFoundText: localization.p2pNoAssetsFound,
                  items: controller.assetOptions,
                  textController: controller.assetController,
                  onValueSelected: controller.onAssetSelected,
                );
              },
              child: Container(
                height: 44.h,
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
                        controller.selectedAsset.value,
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
                      color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuySellToggle(bool isDark) {
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Obx(
      () => Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTradeToggleButton(
                title: localization.p2pBuy,
                isSelected: controller.selectedTradeTypeIndex.value == 0,
                selectedColor: AppColors.success,
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.onTradeTypeChanged(0);
                },
              ),
            ),
            Expanded(
              child: _buildTradeToggleButton(
                title: localization.p2pSell,
                isSelected: controller.selectedTradeTypeIndex.value == 1,
                selectedColor: AppColors.error,
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.onTradeTypeChanged(1);
                },
              ),
            ),
          ],
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

  AppLocalizations get localization => AppLocalizations.of(Get.context!)!;

  Widget _buildTradeToggleButton({
    required String title,
    required bool isSelected,
    required Color selectedColor,
    required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 34.h,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : AppColors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 13.5.sp,
              color: isSelected ? AppColors.white : AppColors.softGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context, bool isDark) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterChip(
            prefix: Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDA44),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Obx(
                () => Center(
                  child: Text(
                    controller.selectedFiatSymbol.value,
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
            label: controller.selectedFiat,
            textPrimary: textPrimary,
            onTap: () {
              HapticFeedback.lightImpact();
              _openCommonDropdown(
                context: context,
                title: localization.p2pSelectFiat,
                notFoundText: localization.p2pNoFiatCurrenciesFound,
                items: controller.fiatOptions,
                textController: controller.fiatController,
                onValueSelected: controller.onFiatSelected,
              );
            },
          ),
          SizedBox(width: 20.w),
          _buildFilterChip(
            label: controller.selectedAmount,
            textPrimary: textPrimary,
            onTap: () {
              HapticFeedback.lightImpact();
              _openAmountFilterBottomSheet(isDark);
            },
          ),
          SizedBox(width: 20.w),
          _buildFilterChip(
            label: controller.selectedPayment,
            textPrimary: textPrimary,
            onTap: () {
              HapticFeedback.lightImpact();
              _openPaymentMethodFilterBottomSheet(isDark);
            },
          ),
        ],
      ),
    );
  }

  /// Offer Filter Chips for quick segmentation (Verified, High Completion, Instant)
  Widget _buildOfferQuickFilterChips(BuildContext context, bool isDark) {
    final filters = [
      {'label': l10nPick(context, en: 'All Offers', fa: 'همه پیشنهادها'), 'icon': Icons.tune_rounded},
      {'label': l10nPick(context, en: 'Verified ⭐', fa: 'فروشندگان معتبر ⭐'), 'icon': Icons.verified_user_rounded},
      {'label': l10nPick(context, en: 'Completion >95%', fa: 'تکمیل بالای ۹۵٪'), 'icon': Icons.thumb_up_alt_rounded},
      {'label': l10nPick(context, en: 'Fast Payout (≤15m)', fa: 'آزادسازی فوری'), 'icon': Icons.bolt_rounded},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        children: filters.map((f) {
          return Padding(
            padding: EdgeInsetsDirectional.only(end: 8.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    f['icon'] as IconData,
                    size: 13.r,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    f['label'] as String,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabContent(BuildContext context, bool isDark) {
    return Obx(() {
      final tabIndex = controller.selectedTopTabIndex.value;

      if (tabIndex == 0) {
        return _buildP2pTradingPage(context, isDark);
      }
      if (tabIndex == 2) {
        return const PaymentAccountScreen();
      }
      if (tabIndex == 1) {
        return const MyOrderScreen();
      }
      if (tabIndex == 3) {
        return const MyAdsScreen();
      }
      if (tabIndex == 4) {
        return const CreateAdScreen();
      }
      return const ApplyVerificationScreen();
    });
  }

  Widget _buildP2pTradingPage(BuildContext context, bool isDark) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTradeAndAssetRow(context, isDark),
          SizedBox(height: AppSpacing.md.h),
          _buildFilterRow(context, isDark),
          SizedBox(height: AppSpacing.sm.h),
          _buildOfferQuickFilterChips(context, isDark),
          SizedBox(height: AppSpacing.sm.h),
          Divider(
            height: 1,
            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
          ),

          // 4-States Handling (Loading, Error, Empty, Content)
          if ((controller.isMarketplaceLoading.value && controller.p2pAds.isEmpty) ||
              controller.isCurrenciesLoading.value) ...[
            Expanded(child: _buildP2pShimmer(isDark)),
          ] else if (controller.p2pAds.isEmpty) ...[
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.all(AppSpacing.xxl.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      NoDataFound(),
                      SizedBox(height: AppSpacing.md.h),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                          foregroundColor: isDark ? AppColors.deepBlack : AppColors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r)),
                        ),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          controller.fetchMarketplaceAds(isRefresh: true);
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(
                          l10nPick(context, en: 'Refresh Offers', fa: 'تازه‌سازی آگهی‌ها'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification.metrics.extentAfter < 200 &&
                      controller.hasMoreMarketplaceData.value &&
                      !controller.isMarketplacePaginationLoading.value) {
                    controller.loadMoreMarketplaceAds();
                  }
                  return false;
                },
                child: RefreshIndicator(
                  color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  onRefresh: () =>
                      controller.fetchMarketplaceAds(isRefresh: true),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsetsDirectional.only(
                      top: 12.h,
                      start: 18.w,
                      end: 18.w,
                      bottom: 20.h,
                    ),
                    itemBuilder: (context, index) {
                      if (index == controller.p2pAds.length) {
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                              size: 28.sp,
                            ),
                          ),
                        );
                      }
                      return P2pAdCard(item: controller.p2pAds[index]);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: AppSpacing.cardGap.h);
                    },
                    itemCount:
                        controller.p2pAds.length +
                        (controller.isMarketplacePaginationLoading.value
                            ? 1
                            : 0),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildP2pShimmer(bool isDark) {
    final baseColor = isDark ? AppColors.darkSurfaceVariant : Colors.grey.shade300;
    final highlightColor = isDark ? AppColors.darkSurface : Colors.grey.shade100;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
        itemCount: 4,
        separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
        itemBuilder: (_, _) => Container(
          height: 140.h,
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    Widget? prefix,
    required RxString label,
    required Color textPrimary,
    required GestureTapCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
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

  void _openAmountFilterBottomSheet(bool isDark) {
    final amountTextController = TextEditingController(
      text: controller.selectedAmountValue.value,
    );
    final localization = AppLocalizations.of(Get.context!)!;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

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
                  color: isDark ? AppColors.darkBorder : AppColors.lightTextPrimary.withValues(alpha: 0.2),
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
                GestureDetector(
                  onTap: Get.back,
                  child: Icon(
                    Icons.close_rounded,
                    size: 24.w,
                    color: textPrimary,
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
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightTextPrimary.withValues(alpha: 0.13),
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
                    color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
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
            CommonButton(
              text: localization.addMoneyFilterButton,
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              textColor: isDark ? AppColors.deepBlack : AppColors.white,
              onPressed: () {
                HapticFeedback.lightImpact();
                controller.applyAmountFilter(amountTextController.text);
                Get.back();
              },
              width: double.infinity,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _openPaymentMethodFilterBottomSheet(bool isDark) async {
    final localization = AppLocalizations.of(Get.context!)!;
    if (controller.isOpeningPaymentMethodFilterSheet.value ||
        controller.isPaymentMethodsLoading.value ||
        (Get.isBottomSheetOpen ?? false)) {
      return;
    }

    controller.isOpeningPaymentMethodFilterSheet.value = true;
    await controller.fetchPaymentMethodsByFiat();

    if (Get.isBottomSheetOpen ?? false) {
      controller.isOpeningPaymentMethodFilterSheet.value = false;
      return;
    }

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

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
                  color: isDark ? AppColors.darkBorder : AppColors.lightTextPrimary.withValues(alpha: 0.2),
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
                    GestureDetector(
                      onTap: Get.back,
                      child: Icon(
                        Icons.close_rounded,
                        size: 24.w,
                        color: textPrimary,
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
                  if (controller.isPaymentMethodsLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                      ),
                    );
                  }

                  if (controller.availablePaymentAccounts.isEmpty) {
                    return Center(
                      child: Text(
                        localization.p2pNoPaymentMethodFound,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.softGray,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(18.w),
                    itemCount: controller.availablePaymentAccounts.length,
                    separatorBuilder: (_, _) => SizedBox(height: AppSpacing.cardGap.h),
                    itemBuilder: (context, index) {
                      final account =
                          controller.availablePaymentAccounts[index];
                      final paymentMethodId =
                          account.paymentMethod?.id ?? account.id;
                      final isSelected =
                          paymentMethodId != null &&
                          controller.selectedPaymentMethodIds.contains(
                            paymentMethodId,
                          );

                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          controller.togglePaymentMethodFilter(account);
                          setSheetState(() {});
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.darkPrimary.withValues(alpha: 0.15) : AppColors.lightPrimary.withValues(alpha: 0.10))
                                : (isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
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
                                    : Icons.radio_button_unchecked_rounded,
                                size: 20.w,
                                color: isSelected
                                    ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.softGray),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(18.w, 0, 18.w, 20.h),
                child: CommonButton(
                  text: localization.addMoneyFilterButton,
                  backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                  textColor: isDark ? AppColors.deepBlack : AppColors.white,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    controller.applyPaymentMethodFilter();
                    Get.back();
                  },
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
    controller.isOpeningPaymentMethodFilterSheet.value = false;
  }

  bool _showFilterIconByTab(int tabIndex) {
    return tabIndex == 1 || tabIndex == 2 || tabIndex == 3;
  }

  void _onFilterTap() {
    HapticFeedback.lightImpact();
    final tabIndex = controller.selectedTopTabIndex.value;
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

  MyAdsController _getMyAdsController() {
    if (Get.isRegistered<MyAdsController>()) {
      return Get.find<MyAdsController>();
    }
    return Get.put(MyAdsController());
  }

  MyOrderController _getMyOrderController() {
    if (Get.isRegistered<MyOrderController>()) {
      return Get.find<MyOrderController>();
    }
    return Get.put(MyOrderController());
  }

  PaymentAccountController _getPaymentAccountController() {
    if (Get.isRegistered<PaymentAccountController>()) {
      return Get.find<PaymentAccountController>();
    }
    return Get.put(PaymentAccountController());
  }
}
