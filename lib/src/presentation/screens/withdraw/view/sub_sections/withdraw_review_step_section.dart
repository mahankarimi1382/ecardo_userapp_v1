import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:qunzo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class WithdrawReviewStepSection extends StatelessWidget {
  const WithdrawReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final WithdrawController controller = Get.find();

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.withdrawAccount.value!.currency!,
      siteCurrencyCode: Get.find<SettingsService>().getSetting(
        "site_currency",
      )!,
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: controller.withdrawAccount.value!.method!.isCrypto!,
    );

    return Obx(
      () => controller.isChargeConverterLoading.value
          ? Expanded(child: CommonLoading())
          : SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localization.withdrawReviewStepSectionTitle,
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          Obx(
                            () => _buildReviewDynamicContent(
                              context,
                              title:
                                  localization.withdrawReviewStepSectionAmount,
                              content:
                                  "${double.tryParse(controller.amountController.text)!.toStringAsFixed(calculateDecimals)} ${controller.withdrawAccount.value!.currency}",
                              contentColor: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => _buildReviewDynamicContent(
                              context,
                              title:
                                  localization.withdrawReviewStepSectionCharge,
                              content:
                                  "${controller.calculatedCharge.value.toStringAsFixed(calculateDecimals)} ${controller.withdrawAccount.value!.currency}",
                              contentColor: AppColors.error,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(
                            height: 0,
                            color: AppColors.black.withValues(alpha: 0.10),
                          ),
                          const SizedBox(height: 20),
                          Obx(
                            () => _buildReviewDynamicContent(
                              context,
                              title: localization
                                  .withdrawReviewStepSectionTotalAmount,
                              content:
                                  "${(controller.totalAmount).toStringAsFixed(calculateDecimals)} ${controller.withdrawAccount.value!.currency}",
                              contentColor: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    Row(
                      children: [
                        Expanded(
                          child: CommonIconButton(
                            backgroundColor: AppColors.lightPrimary.withValues(
                              alpha: 0.04,
                            ),
                            borderWidth: 2,
                            borderColor: AppColors.lightPrimary.withValues(
                              alpha: 0.50,
                            ),
                            width: double.infinity,
                            height: 52,
                            text: localization
                                .withdrawReviewStepSectionBackButton,
                            icon: PngAssets.reviewArrowBackCommonIcon,
                            iconWidth: 18,
                            iconHeight: 18,
                            iconAndTextSpace: 8,
                            iconColor: AppColors.lightTextPrimary,
                            textColor: AppColors.lightTextPrimary,
                            onPressed: () => controller.currentStep.value = 0,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: CommonIconButton(
                            onPressed: () async {
                              if (controller.userModel.value.data!.passcode ==
                                  "0") {
                                controller.submitWithdraw();
                                return;
                              }

                              final bool isPasscodeEnabled =
                                  Get.find<SettingsService>().getSetting(
                                    "withdraw_passcode_status",
                                  ) ==
                                  "1";

                              if (isPasscodeEnabled) {
                                final bool? isVerified =
                                    await Get.bottomSheet<bool>(
                                      VerifyPasscodeBottomSheet(),
                                    );
                                if (isVerified != true) return;
                                controller.submitWithdraw();
                              } else {
                                controller.submitWithdraw();
                              }
                            },
                            width: double.infinity,
                            height: 52,
                            text: localization
                                .withdrawReviewStepSectionConfirmButton,
                            icon: PngAssets.reviewArrowRightCommonIcon,
                            iconWidth: 18,
                            iconHeight: 18,
                            iconAndTextSpace: 8,
                            isIconRight: true,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
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
