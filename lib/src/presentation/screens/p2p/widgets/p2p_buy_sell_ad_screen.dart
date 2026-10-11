import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_buy_ad_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/p2p_ad_card.dart';

/// World-Class P2P Buy/Sell Order Creation Screen (Binance / OKX standard)
/// Features:
/// - Price & Order Limit Hero Card with Emerald/Ruby theme
/// - Dual Amount Calculation Fields with "All / حداکثر" Quick Fill Button
/// - Payment Method Selector with matching badge styling
/// - Advertiser Security & Terms Card with Pro-Merchant Gold Badge
/// - Distinctive Action CTA with Micro-scale Tap Interaction & Haptics
/// - Complete Dark Mode & RTL Support
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = Get.put(
      P2pBuyAdController(adId: adId, isSellMode: isSellMode),
      tag: 'buy_sell_${isSellMode ? 'sell' : 'buy'}_$adId',
    );

    final emeraldGreen = const Color(0xFF10B981);
    final rubyRed = const Color(0xFFEF4444);
    final themeColor = isSellMode ? rubyRed : emeraldGreen;

    final cardBg = isDark ? AppColors.darkSurface : AppColors.white;
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                letterSpacing: 0,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: textSecondary,
              ),
            ),
          );
        }

        final titleCode = ad.assetCurrency?.code ?? 'USDT';
        final priceText = ad.price ?? '-';
        final orderLimitText = ad.orderLimit ?? '-';
        final descriptionItems = _buildDescriptionItems(ad.description ?? '');

        final traderName = (ad.advertiser?.fullName?.trim().isNotEmpty ?? false)
            ? ad.advertiser!.fullName!
            : (ad.advertiser?.username ?? '--');
        final avatarText = (ad.advertiser?.avatarText?.trim().isNotEmpty ?? false)
            ? ad.advertiser!.avatarText!
            : (traderName.isNotEmpty ? traderName.substring(0, 1).toUpperCase() : 'T');
        final isVerified = ad.advertiser?.isVerifiedTrader ?? false;

        return Column(
          children: [
            SizedBox(height: 16.h),
            CommonAppBar(
              title: '${isSellMode ? localization.p2pSell : localization.p2pBuy} $titleCode',
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
                    // 1. Price & Limit Hero Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localization.p2pPrice,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.sp,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                priceText,
                                style: TextStyle(
                                  letterSpacing: -0.2,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18.sp,
                                  color: themeColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Divider(
                            height: 1,
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localization.p2pOrderLimit,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12.5.sp,
                                  color: textSecondary,
                                ),
                              ),
                              Text(
                                orderLimitText,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.sp,
                                  color: textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // 2. Amount Input & Currency Calculator
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl.r),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Pay Field with "All / Max" Quick Fill Button
                          _buildAmountFieldWithMax(
                            context: context,
                            title: isSellMode ? localization.p2pYouSell : localization.p2pYouPay,
                            controller: controller.payController,
                            suffixText: controller.primaryCode,
                            suffixSymbol: controller.primarySymbol,
                            isDark: isDark,
                            themeColor: themeColor,
                            onChanged: controller.onPayAmountChanged,
                            onMaxTap: () {
                              final max = controller.maxOrderLimit;
                              if (max != null && max > 0) {
                                HapticFeedback.selectionClick();
                                controller.payController.text = max.toStringAsFixed(max.truncateToDouble() == max ? 0 : 2);
                                controller.onPayAmountChanged(controller.payController.text);
                              }
                            },
                          ),
                          SizedBox(height: 14.h),

                          // Receive Field
                          _buildAmountFieldWithMax(
                            context: context,
                            title: localization.p2pYouReceive,
                            controller: controller.receiveController,
                            suffixText: controller.secondaryCode,
                            suffixSymbol: controller.secondarySymbol,
                            isDark: isDark,
                            themeColor: themeColor,
                            onChanged: controller.onReceiveAmountChanged,
                          ),
                          SizedBox(height: 16.h),

                          // Payment Method Selector
                          Text(
                            localization.p2pPaymentMethods,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5.sp,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _openPaymentMethodDropdown(controller),
                            child: Container(
                              height: 48.h,
                              padding: EdgeInsets.symmetric(horizontal: 14.w),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                                border: Border.all(
                                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_rounded,
                                    size: 18.r,
                                    color: themeColor,
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Obx(() {
                                      if (controller.isPaymentMethodsLoading.value) {
                                        return Text(
                                          localization.p2pLoadingPaymentMethods,
                                          style: TextStyle(
                                            letterSpacing: 0,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13.sp,
                                            color: textSecondary,
                                          ),
                                        );
                                      }
                                      return Text(
                                        controller.selectedPaymentOption?.label ??
                                            localization.p2pSelectPaymentMethod,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13.sp,
                                          color: textPrimary,
                                        ),
                                      );
                                    }),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 20.r,
                                    color: textSecondary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // 3. Advertiser Terms Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localization.p2pAdvertisersTerms,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w800,
                              fontSize: 13.5.sp,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Divider(
                            height: 1,
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                          SizedBox(height: 10.h),
                          ...descriptionItems.map(
                            (item) => Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 6.r,
                                    height: 6.r,
                                    margin: EdgeInsets.only(top: 6.h),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: themeColor,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12.5.sp,
                                        color: textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 18.h),

                    // 4. Trader Reputation & Execution Card
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg.r),
                        border: Border.all(color: borderColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 34.r,
                                height: 34.r,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: isDark
                                        ? const [Color(0xFF312E81), Color(0xFF4338CA)]
                                        : const [Color(0xFF1E293B), Color(0xFF334155)],
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    avatarText,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10.w),
                              Expanded(
                                child: Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        traderName,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          letterSpacing: 0,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14.sp,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (isVerified) ...[
                                      SizedBox(width: 6.w),
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.5.h),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFFFB800), Color(0xFFF59E0B)],
                                          ),
                                          borderRadius: BorderRadius.circular(3.r),
                                        ),
                                        child: Text(
                                          'PRO',
                                          style: TextStyle(
                                            fontSize: 9.sp,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),
                          Divider(
                            height: 1,
                            color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
                          ),
                          SizedBox(height: 10.h),
                          _buildTraderMetaRow(
                            localization.p2pAvailable,
                            ad.totalAmount ?? '--',
                            textPrimary,
                            textSecondary,
                          ),
                          SizedBox(height: 8.h),
                          _buildTraderMetaRow(
                            localization.p2pPaymentTimeLimit,
                            ad.responseTime ?? '15m',
                            textPrimary,
                            textSecondary,
                          ),
                          SizedBox(height: 8.h),
                          _buildTraderMetaRow(
                            localization.p2pAvgReleaseTime,
                            ad.averageReleaseTime ?? '10m',
                            textPrimary,
                            textSecondary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24.h),

                    // 5. Distinctive Submit CTA Button with Micro-scale Tap
                    Obx(
                      () => MicroScaleTap(
                        onTap: controller.isSubmittingOrder.value
                            ? null
                            : () => controller.submitOrderAndOpenDetails(),
                        child: Container(
                          height: 48.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: themeColor,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
                            boxShadow: [
                              BoxShadow(
                                color: themeColor.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: controller.isSubmittingOrder.value
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    controller.buttonText,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildAmountFieldWithMax({
    required BuildContext context,
    required String title,
    required TextEditingController controller,
    required String suffixText,
    required String suffixSymbol,
    required bool isDark,
    required Color themeColor,
    required void Function(String value) onChanged,
    VoidCallback? onMaxTap,
  }) {
    final textPrimary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd.r),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.sp,
                  color: textSecondary,
                ),
              ),
              if (onMaxTap != null)
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onMaxTap,
                  child: Text(
                    l10nPick(context, en: 'Max', fa: 'حداکثر'),
                    style: TextStyle(
                      letterSpacing: 0,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.sp,
                      color: themeColor,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
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
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                    color: textPrimary,
                  ),
                ),
              ),
              Container(
                width: 1.5,
                height: 16.h,
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(4.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: themeColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  suffixSymbol,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 11.sp,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Text(
                suffixText.trim(),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w800,
                  fontSize: 13.sp,
                  color: textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTraderMetaRow(
    String title,
    String value,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w500,
            fontSize: 12.5.sp,
            color: textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w700,
            fontSize: 13.sp,
            color: textPrimary,
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
    return [
      AppLocalizations.of(Get.context!)?.p2pNoTermsProvided ??
          'No terms provided',
    ];
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
        notFoundText: localization.p2pNoPaymentMethodFound,
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
