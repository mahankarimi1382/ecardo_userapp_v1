import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/widgets/no_data_found.dart';

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

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Column(
        children: [
          SizedBox(height: 16.h),
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
          SizedBox(height: 18.h),
          _buildTopTabBar(),
          SizedBox(height: 30.h),
          Expanded(child: _buildTabContent(context)),
        ],
      ),
    );
  }

  Widget _buildTopTabBar() {
    return Obx(() {
      final selectedIndex = controller.selectedTopTabIndex.value;

      return SizedBox(
        height: 30.h,
        child: ListView.separated(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final bool isSelected = selectedIndex == index;
            return GestureDetector(
              onTap: () => controller.onTopTabSelected(index),
              child: Container(
                padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.lightPrimary : AppColors.white,
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Center(
                  child: Text(
                    _localizedTopTabTitle(localization, index),
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                      color: isSelected
                          ? AppColors.white
                          : AppColors.lightTextPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            );
          },
          separatorBuilder: (context, index) {
            return SizedBox(width: 10.w);
          },
          itemCount: controller.topTabs.length,
        ),
      );
    });
  }

  Widget _buildTradeAndAssetRow(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        children: [
          Expanded(child: _buildBuySellToggle()),
          SizedBox(width: 14.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                _openCommonDropdown(
                  context: context,
                  title: localization.p2pSelectAsset,
                  items: controller.assetOptions,
                  textController: controller.assetController,
                  onValueSelected: controller.onAssetSelected,
                );
              },
              child: Container(
                height: 44.h,
                padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(
                    color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        controller.selectedAsset.value,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22.w,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.55),
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

  Widget _buildBuySellToggle() {
    return Obx(
      () => Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildTradeToggleButton(
                title: localization.p2pBuy,
                isSelected: controller.selectedTradeTypeIndex.value == 0,
                selectedColor: AppColors.success,
                onTap: () => controller.onTradeTypeChanged(0),
              ),
            ),
            Expanded(
              child: _buildTradeToggleButton(
                title: localization.p2pSell,
                isSelected: controller.selectedTradeTypeIndex.value == 1,
                selectedColor: AppColors.error,
                onTap: () => controller.onTradeTypeChanged(1),
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
        height: 32.h,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor : AppColors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: isSelected ? AppColors.white : AppColors.lightTextPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildFilterChip(
            prefix: Container(
              width: 18.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: const Color(0xFFFFDA44),
                borderRadius: BorderRadius.circular(5.r),
              ),
              child: Obx(
                () => Text(
                  controller.selectedFiatSymbol.value,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                  ),
                ),
              ),
            ),
            label: controller.selectedFiat,
            onTap: () {
              _openCommonDropdown(
                context: context,
                title: localization.p2pSelectFiat,
                items: controller.fiatOptions,
                textController: controller.fiatController,
                onValueSelected: controller.onFiatSelected,
              );
            },
          ),
          SizedBox(width: 24.w),
          _buildFilterChip(
            label: controller.selectedAmount,
            onTap: () {
              _openAmountFilterBottomSheet();
            },
          ),
          SizedBox(width: 24.w),
          _buildFilterChip(
            label: controller.selectedPayment,
            onTap: () {
              _openPaymentMethodFilterBottomSheet();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    return Obx(() {
      final tabIndex = controller.selectedTopTabIndex.value;

      if (tabIndex == 0) {
        return _buildP2pTradingPage(context);
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

  Widget _buildP2pTradingPage(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTradeAndAssetRow(context),
          SizedBox(height: 30.h),
          _buildFilterRow(context),
          SizedBox(height: 14.h),
          Divider(
            height: 1,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
          ),
          if (controller.isMarketplaceLoading.value &&
                  controller.p2pAds.isEmpty ||
              controller.isCurrenciesLoading.value) ...[
            const Expanded(child: CommonLoading()),
          ] else if (controller.p2pAds.isEmpty) ...[
            Expanded(child: NoDataFound()),
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
                  color: AppColors.lightPrimary,
                  onRefresh: () =>
                      controller.fetchMarketplaceAds(isRefresh: true),
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsetsDirectional.only(
                      top: 14.h,
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
                              color: AppColors.lightPrimary,
                              size: 32.sp,
                            ),
                          ),
                        );
                      }
                      return P2pAdCard(item: controller.p2pAds[index]);
                    },
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10.h);
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

  Widget _buildFilterChip({
    Widget? prefix,
    required RxString label,
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
                color: AppColors.lightTextPrimary.withValues(alpha: 0.80),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 20.w,
            color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
          ),
        ],
      ),
    );
  }

  void _openCommonDropdown({
    required BuildContext context,
    required String title,
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
        notFoundText: 'No options found',
        onValueSelected: (value) {
          onValueSelected(value.toString());
        },
      ),
    );
  }

  void _openAmountFilterBottomSheet() {
    final amountTextController = TextEditingController(
      text: controller.selectedAmountValue.value,
    );
    final localization = AppLocalizations.of(Get.context!)!;
    Get.bottomSheet(
      Container(
        margin: EdgeInsets.symmetric(horizontal: 12.w),
        padding: EdgeInsetsDirectional.fromSTEB(18.w, 12.h, 18.w, 22.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(20.r),
            topEnd: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 45.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  localization.p2pFilterAmount,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w800,
                    fontSize: 18.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                GestureDetector(
                  onTap: Get.back,
                  child: Icon(
                    Icons.close_rounded,
                    size: 24.w,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              localization.addMoneyAmount,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
                color: AppColors.lightTextPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 48.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.13),
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
                ),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ),
            SizedBox(height: 18.h),
            CommonButton(
              text: localization.addMoneyFilterButton,
              onPressed: () {
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

  Future<void> _openPaymentMethodFilterBottomSheet() async {
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

    await Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setSheetState) => Container(
          height: 500.h,
          margin: EdgeInsets.symmetric(horizontal: 12.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(20.r),
              topEnd: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 45.w,
                height: 6.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              SizedBox(height: 16.h),
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
                        fontSize: 18.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    GestureDetector(
                      onTap: Get.back,
                      child: Icon(
                        Icons.close_rounded,
                        size: 24.w,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              Divider(
                height: 1,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.10),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isPaymentMethodsLoading.value) {
                    return const Center(child: CommonLoading());
                  }

                  if (controller.availablePaymentAccounts.isEmpty) {
                    return Center(
                      child: Text(
                        'No payment method found',
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: AppColors.lightTextPrimary.withValues(
                            alpha: 0.56,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.all(18.w),
                    itemCount: controller.availablePaymentAccounts.length,
                    separatorBuilder: (_, _) => SizedBox(height: 10.h),
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
                                ? AppColors.lightPrimary.withValues(alpha: 0.10)
                                : AppColors.lightBackground,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.lightPrimary.withValues(
                                      alpha: 0.30,
                                    )
                                  : AppColors.lightTextPrimary.withValues(
                                      alpha: 0.10,
                                    ),
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
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                isSelected
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                size: 20.w,
                                color: isSelected
                                    ? AppColors.lightPrimary
                                    : AppColors.lightTextPrimary.withValues(
                                        alpha: 0.45,
                                      ),
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
                  onPressed: () {
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
