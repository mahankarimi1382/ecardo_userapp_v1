import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_glass_card.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class RequestMoneyReviewStepSection extends StatelessWidget {
  const RequestMoneyReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestMoneyController controller = Get.find();
    final settingsService = Get.find<SettingsService>();
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.wallet.value!.code!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: controller.wallet.value!.isCrypto!,
    );

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.requestMoneyReviewStepSectionTitle,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Glassmorphic review card
            EcardoGlassCard(
              variant: EcardoGlassVariant.standard,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Column(
                children: [
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.requestMoneyReviewStepSectionAmount,
                      content:
                          "${(double.tryParse(controller.requestAmountController.text) ?? 0.0).toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code!}",
                      contentColor: AppColors.success,
                      isTotal: true,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title:
                          localization.requestMoneyReviewStepSectionWalletName,
                      content: controller.wallet.value!.name!,
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  _buildDivider(isDark),
                  _buildReviewDynamicContent(
                    context,
                    isDark: isDark,
                    title:
                        localization.requestMoneyReviewStepSectionRecipientUid,
                    content: controller.recipientUidController.text,
                    contentColor: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),

            Row(
              children: [
                Expanded(
                  child: CommonIconButton(
                    backgroundColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightPrimary.withValues(alpha: 0.04),
                    borderWidth: 1.5,
                    borderColor: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightPrimary.withValues(alpha: 0.30),
                    width: double.infinity,
                    height: 52,
                    text: localization.requestMoneyReviewStepSectionBackButton,
                    icon: PngAssets.reviewArrowBackCommonIcon,
                    iconWidth: 18,
                    iconHeight: 18,
                    iconAndTextSpace: AppSpacing.sm,
                    iconColor: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    textColor: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      controller.currentStep.value = 0;
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Obx(
                    () => CommonIconButton(
                      isLoading: controller.isRequestMoneyLoading.value,
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        if (controller.currentStep.value == 1) {
                          if ((controller.userModel.value.data?.passcode ?? "0") ==
                              "0") {
                            controller.requestMoney();
                            return;
                          }

                          final bool isPasscodeEnabled =
                              Get.find<SettingsService>().getSetting(
                                "request_money_accept_passcode_status",
                              ) ==
                              "1";

                          if (isPasscodeEnabled) {
                            final bool? isVerified = await Get.bottomSheet<bool>(
                              const VerifyPasscodeBottomSheet(),
                            );
                            if (isVerified != true) return;
                            controller.requestMoney();
                          } else {
                            controller.requestMoney();
                          }
                        } else {
                          controller.nextStepWithValidation();
                        }
                      },
                      width: double.infinity,
                      height: 52,
                      text:
                          localization.requestMoneyReviewStepSectionConfirmButton,
                      icon: PngAssets.reviewArrowRightCommonIcon,
                      iconWidth: 18,
                      iconHeight: 18,
                      iconAndTextSpace: AppSpacing.sm,
                      isIconRight: true,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }

  static Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
      ),
    );
  }

  static Widget _buildReviewDynamicContent(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String content,
    required Color contentColor,
    bool isTotal = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
              fontSize: isTotal ? 16 : 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: isTotal ? FontWeight.w900 : FontWeight.w700,
                fontSize: isTotal ? 17 : 15,
                color: contentColor,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
