import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';

import '../../../../../../../../app/constants/app_colors.dart';
import '../../../../../../../../app/constants/assets_path/png/png_assets.dart';
import '../../../../../../../../common/widgets/button/common_button.dart';
import '../../../../../../../../common/widgets/common_required_label_and_dynamic_field.dart';
import '../../../../../../../../common/widgets/input_field/common_text_input_filed.dart';

class StripeCardTopUpBottomSheet extends StatelessWidget {
  final String cardId;
  const StripeCardTopUpBottomSheet({super.key, required this.cardId});

  @override
  Widget build(BuildContext context) {
    final VirtualCardDetailsController controller = Get.find();
    final SettingsService settingsService = Get.find();
    final localization = AppLocalizations.of(context);
    final String decimals = settingsService.getSetting(
      "site_currency_decimals",
    )!;
    final String currency = settingsService.getSetting("site_currency")!;
    final String minimumTopup = settingsService.getSetting("min_card_topup")!;
    final String maximumTopup = settingsService.getSetting("max_card_topup")!;

    return AnimatedContainer(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(24.r),
          topEnd: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 35.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30.r),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            localization!.cardTopUpTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16.sp,
              color: AppColors.lightTextPrimary,
              letterSpacing: 0,
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            height: 1.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.white,
                  Colors.grey.shade400,
                  AppColors.white,
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset(PngAssets.cardTopUpImage),
                      Column(
                        children: [
                          Text(
                            localization.cardTopUpMainWalletBalance,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                              color: AppColors.white,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 5.h),
                          Text(
                            "${Get.find<SettingsService>().getSetting("currency_symbol")}${Get.find<HomeController>().userModel.value.data!.balance} ${Get.find<SettingsService>().getSetting("site_currency")}",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18.sp,
                              color: AppColors.white,
                              letterSpacing: 0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  CommonRequiredLabelAndDynamicField(
                    labelText: localization.cardTopUpLabelAmount,
                    isLabelRequired: true,
                    dynamicField: Obx(
                      () => CommonTextInputField(
                        backgroundColor: AppColors.lightBackground,
                        controller: controller.amountController,
                        focusNode: controller.amountFocusNode,
                        isFocused: controller.isAmountFocused.value,
                        hintText: "",
                        onChanged: (_) {
                          controller.update();
                          controller.reviewCalculate();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      localization.cardTopUpAmountLimits(
                        currency,
                        double.tryParse(
                          maximumTopup,
                        )!.toStringAsFixed(int.parse(decimals)),
                        double.tryParse(
                          minimumTopup,
                        )!.toStringAsFixed(int.parse(decimals)),
                      ),
                      style: const TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      SizedBox(height: 30.h),
                      _buildReviewSection(context, controller),
                    ],
                  ),
                  SizedBox(height: 30.h),
                  Obx(
                    () => CommonButton(
                      isLoading: controller.isCardBalanceTopUpLoading.value,
                      text: localization.cardTopUpButtonTopupNow,
                      onPressed: () =>
                          controller.cardBalanceTopUp(cardId: cardId),
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewSection(
    BuildContext context,
    VirtualCardDetailsController controller,
  ) {
    final localization = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: AppColors.lightBackground,
      ),
      child: Column(
        children: [
          Obx(
            () => _buildReviewDynamicContent(
              context,
              title: localization!.cardTopUpReviewTopupAmount,
              content: controller.amount.value.isNotEmpty
                  ? "${controller.baseAmount.value} ${Get.find<SettingsService>().getSetting("site_currency")}"
                  : "",
              contentColor: AppColors.success,
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 0, color: AppColors.black.withValues(alpha: 0.10)),
          const SizedBox(height: 20),
          Obx(
            () => _buildReviewDynamicContent(
              context,
              title: localization!.cardTopUpReviewTopupCharge,
              content: controller.amount.value.isNotEmpty
                  ? "${controller.calculatedCharge.value} ${Get.find<SettingsService>().getSetting("site_currency")}"
                  : "",
              contentColor: AppColors.error,
            ),
          ),
          const SizedBox(height: 20),
          Divider(height: 0, color: AppColors.black.withValues(alpha: 0.10)),
          const SizedBox(height: 20),
          Obx(
            () => _buildReviewDynamicContent(
              context,
              title: localization!.cardTopUpReviewTotalTopupBalance,
              content: controller.amount.value.isNotEmpty
                  ? "${controller.totalAmount.value} ${Get.find<SettingsService>().getSetting("site_currency")}"
                  : "",
              contentColor: AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildReviewDynamicContent(
    BuildContext context, {
    required String title,
    required String content,
    required Color contentColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.lightTextPrimary.withValues(alpha: 0.60),
            ),
          ),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: contentColor,
              ),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
