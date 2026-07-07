import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/controller/p2p_buy_ad_controller.dart';

import '../../../../app/constants/assets_path/svg/svg_assets.dart';

class P2pBuySellAdScreen extends StatelessWidget {
  final int adId;
  final bool isSellMode;

  const P2pBuySellAdScreen({
    super.key,
    required this.adId,
    this.isSellMode = false,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final controller = Get.put(
      P2pBuyAdController(adId: adId, isSellMode: isSellMode),
      tag: 'buy_sell_${isSellMode ? 'sell' : 'buy'}_$adId',
    );

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: Obx(() {
        if (controller.isPageLoading.value && controller.adData.value == null) {
          return const CommonLoading();
        }

        final ad = controller.adData.value;
        if (ad == null) {
          return Center(
            child: Text(
              localization.p2pNoAdDetailsFound,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
              ),
            ),
          );
        }

        final titleCode = ad.assetCurrency?.code ?? '';
        final priceText = ad.price ?? '-';
        final orderLimitText = ad.orderLimit ?? '-';
        final descriptionItems = _buildDescriptionItems(ad.description ?? '');
        final traderName = (ad.advertiser?.fullName?.trim().isNotEmpty ?? false)
            ? ad.advertiser!.fullName!
            : (ad.advertiser?.username ?? '--');
        final avatarText =
            (ad.advertiser?.avatarText?.trim().isNotEmpty ?? false)
            ? ad.advertiser!.avatarText!
            : traderName.substring(0, 1).toUpperCase();
        final isVerified = ad.advertiser?.isVerifiedTrader ?? false;

        return Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(
              title:
                  '${isSellMode ? localization.p2pSell : localization.p2pBuy} ${titleCode.isEmpty ? 'Ad' : titleCode}',
              isBackLogicApply: true,
              backLogicFunction: Get.back,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(18.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${localization.p2pPrice}: ',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          TextSpan(
                            text: priceText,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: isSellMode
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '${localization.p2pOrderLimit}: ',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          TextSpan(
                            text: orderLimitText,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(32.r),
                      ),
                      child: Column(
                        children: [
                          _buildAmountField(
                            title: isSellMode
                                ? localization.p2pYouSell
                                : localization.p2pYouPay,
                            controller: controller.payController,
                            suffixText: controller.primaryCode,
                            suffixSymbol: controller.primarySymbol,
                            onChanged: controller.onPayAmountChanged,
                          ),
                          SizedBox(height: 16.h),
                          _buildAmountField(
                            title: localization.p2pYouReceive,
                            controller: controller.receiveController,
                            suffixText: controller.secondaryCode,
                            suffixSymbol: controller.secondarySymbol,
                            onChanged: controller.onReceiveAmountChanged,
                          ),
                          SizedBox(height: 16.h),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: Text(
                              localization.p2pPaymentMethods,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontSize: 12.sp,
                                color: AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () => _openPaymentMethodDropdown(controller),
                            child: Container(
                              height: 48.h,
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              decoration: BoxDecoration(
                                color: AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: AppColors.lightTextPrimary.withValues(
                                    alpha: 0.14,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      if (controller
                                          .isPaymentMethodsLoading
                                          .value) {
                                        return Text(
                                          localization.p2pLoadingPaymentMethods,
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13.sp,
                                            color: AppColors.lightTextPrimary
                                                .withValues(alpha: 0.6),
                                          ),
                                        );
                                      }
                                      return Text(
                                        controller
                                                .selectedPaymentOption
                                                ?.label ??
                                            localization.p2pSelectPaymentMethod,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13.sp,
                                          color: AppColors.lightTextPrimary,
                                        ),
                                      );
                                    }),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 22.w,
                                    color: AppColors.lightTextPrimary
                                        .withValues(alpha: 0.6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      localization.p2pAdvertisersTerms,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Divider(
                      height: 1,
                      color: AppColors.lightTextPrimary.withValues(alpha: 0.14),
                    ),
                    SizedBox(height: 10.h),
                    ...descriptionItems.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 7.w,
                              height: 7.h,
                              margin: EdgeInsets.only(top: 7.h),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                            SizedBox(width: 7.w),
                            Expanded(
                              child: Text(
                                item,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13.sp,
                                  color: AppColors.lightTextPrimary.withValues(
                                    alpha: 0.80,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 30.w,
                                height: 30.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.lightTextPrimary.withValues(
                                    alpha: 0.70,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    avatarText,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Text(
                                traderName,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15.sp,
                                  color: AppColors.lightTextPrimary,
                                ),
                              ),
                              if (isVerified) ...[
                                SizedBox(width: 4.w),
                                SvgPicture.asset(
                                  SvgAssets.commonIdVerifiedBadgeIcon,
                                  width: 15.w,
                                  height: 15.h,
                                ),
                              ],
                            ],
                          ),
                          Divider(
                            height: 13.h,
                            color: AppColors.lightTextPrimary.withValues(
                              alpha: 0.14,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          _buildInfoRow(
                            localization.p2pAvailable,
                            ad.totalAmount ?? '--',
                          ),
                          SizedBox(height: 12.h),
                          _buildInfoRow(
                            localization.p2pPaymentTimeLimit,
                            ad.responseTime ?? '--',
                          ),
                          SizedBox(height: 12.h),
                          _buildInfoRow(
                            localization.p2pAvgReleaseTime,
                            ad.averageReleaseTime ?? '--',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Obx(
                      () => CommonButton(
                        text: controller.buttonText,
                        width: double.infinity,
                        isLoading: controller.isSubmittingOrder.value,
                        backgroundColor: controller.isSellMode
                            ? AppColors.error
                            : AppColors.success,
                        onPressed: controller.submitOrderAndOpenDetails,
                      ),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAmountField({
    required String title,
    required TextEditingController controller,
    required String suffixText,
    required String suffixSymbol,
    required void Function(String value) onChanged,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: onChanged,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 16.sp,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
              ),
              Container(
                width: 2,
                height: 16.h,
                color: AppColors.lightTextPrimary.withValues(alpha: 0.16),
              ),
              SizedBox(width: 7.w),
              Container(
                padding: EdgeInsets.all(4.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  suffixSymbol,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.sp,
                    color: AppColors.white,
                  ),
                ),
              ),
              SizedBox(width: 7.w),
              Text(
                suffixText.trim(),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.sp,
                  color: AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              fontSize: 13.sp,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.65),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            fontSize: 14.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  List<String> _buildDescriptionItems(String description) {
    final items = description
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
    if (items.isNotEmpty) return items;
    return ['No terms provided'];
  }

  void _openPaymentMethodDropdown(P2pBuyAdController controller) {
    final localization = AppLocalizations.of(Get.context!)!;
    if (controller.isPaymentMethodsLoading.value) return;
    final options = controller.paymentOptions;
    if (options.isEmpty) return;

    final labels = options.map((item) => item.label).toList();
    final selected = controller.selectedPaymentOption?.label ?? '';
    final textController = TextEditingController(text: selected);

    Get.bottomSheet(
      CommonDropdownBottomSheet(
        title: localization.p2pSelectPaymentMethod,
        isShowTitle: true,
        dropdownItems: labels,
        selectedValue: labels,
        selectedItem: selected,
        currentlySelectedValue: selected,
        textController: textController,
        bottomSheetHeight: 420.h,
        notFoundText: 'No payment method found',
        onValueSelected: (value) {
          final selectedValue = value.toString();
          AdPaymentOption? selectedOption;
          for (final item in options) {
            if (item.label == selectedValue) {
              selectedOption = item;
              break;
            }
          }
          if (selectedOption == null) return;
          controller.onPaymentMethodSelected(selectedOption.id);
        },
      ),
    );
  }
}
