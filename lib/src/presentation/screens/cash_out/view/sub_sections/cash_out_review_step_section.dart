import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_icon_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_glass_card.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/presentation/screens/cash_out/controller/cash_out_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class CashOutReviewStepSection extends StatelessWidget {
  const CashOutReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final CashOutController controller = Get.find();
    final SettingsService settingsService = Get.find();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: controller.wallet.value!.code!,
      siteCurrencyCode: settingsService.getSetting("site_currency")!,
      siteCurrencyDecimals: settingsService.getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: controller.wallet.value!.isCrypto!,
    );

    return Obx(() {
      if (controller.isCashoutConfigLoading.value) {
        return const CommonLoading();
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.cashOutReviewTitle,
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

              // Glassmorphic review card with fee breakdown
              EcardoGlassCard(
                variant: EcardoGlassVariant.standard,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Column(
                  children: [
                    _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localizations.cashOutReviewAmount,
                      content:
                          "${(double.tryParse(controller.amountController.text) ?? 0.0).toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                      contentColor: AppColors.success,
                    ),
                    _buildDivider(isDark),
                    Obx(
                      () => _buildReviewDynamicContent(
                        context,
                        isDark: isDark,
                        title: localizations.cashOutReviewWallet,
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
                      title: localizations.cashOutReviewAgentAccount,
                      content: controller.agentAidController.text,
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                    _buildDivider(isDark),
                    Obx(
                      () => _buildReviewDynamicContent(
                        context,
                        isDark: isDark,
                        title: localizations.cashOutReviewCharge,
                        content: controller.chargeLoadFailed.value
                            ? '—'
                            : "${controller.charge.value.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                        contentColor: AppColors.warning,
                        isBadge: true,
                      ),
                    ),
                    _buildDivider(isDark),
                    Obx(
                      () => _buildReviewDynamicContent(
                        context,
                        isDark: isDark,
                        title: localizations.cashOutReviewTotalAmount,
                        content: controller.chargeLoadFailed.value
                            ? '—'
                            : "${controller.totalAmount.value.toStringAsFixed(calculateDecimals)} ${controller.wallet.value!.code}",
                        contentColor: isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary,
                        isTotal: true,
                      ),
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
                      text: localizations.cashOutReviewBack,
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
                        isLoading: controller.isCashOutLoading.value,
                        onPressed: () async {
                          HapticFeedback.lightImpact();
                          final verified = await Get.bottomSheet<String>(
                            const VerifyPasscodeBottomSheet(),
                          );
                          if (verified == null ||
                              !PasscodeHelper.isValidFormat(verified)) {
                            return;
                          }
                          await controller.cashOut(passcode: verified);
                        },
                        width: double.infinity,
                        height: 52,
                        text: localizations.cashOutReviewConfirm,
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
    });
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
    bool isBadge = false,
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
            child: isBadge
                ? Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: contentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusXs,
                        ),
                      ),
                      child: Text(
                        content,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: contentColor,
                        ),
                      ),
                    ),
                  )
                : Text(
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
