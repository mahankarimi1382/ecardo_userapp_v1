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
import 'package:ecardo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/verify_passcode_bottom_sheet.dart';

class AddMoneyReviewStepSection extends StatelessWidget {
  const AddMoneyReviewStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final AddMoneyController controller = Get.find<AddMoneyController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localization.addMoneyReviewTitle,
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
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewAmount,
                      content:
                          "${controller.baseAmount.value.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals!)} ${controller.gatewayMethod.value!.currency}",
                      contentColor: AppColors.success,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewWalletName,
                      content: controller.wallet.value!.name!,
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewPaymentMethod,
                      content: controller.gatewayMethod.value!.formattedName!,
                      contentColor: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewCharge,
                      content:
                          "${controller.calculatedCharge.value.toStringAsFixed(controller.gatewayMethod.value!.currencyType! != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals!)} ${controller.gatewayMethod.value!.currency}",
                      contentColor: AppColors.warning,
                      isBadge: true,
                    ),
                  ),
                  _buildDivider(isDark),
                  Obx(
                    () => _buildReviewDynamicContent(
                      context,
                      isDark: isDark,
                      title: localization.addMoneyReviewTotal,
                      content:
                          "${controller.totalAmount.value.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals!)} ${controller.gatewayMethod.value!.currency}",
                      contentColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      isTotal: true,
                    ),
                  ),
                  if (controller.dynamicFieldControllers.isNotEmpty) ...[
                    _buildDivider(isDark),
                    ..._buildDynamicFieldsReview(context, controller, isDark),
                  ],
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
                    text: localization.addMoneyReviewBack,
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
                      isLoading: controller.isPaymentLoading.value,
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        if ((controller.userModel.value.data?.passcode ?? "0") ==
                            "0") {
                          _continueAddMoneyFlow(controller);
                          return;
                        }

                        final bool isPasscodeEnabled =
                            Get.find<SettingsService>().getSetting(
                              "deposit_passcode_status",
                            ) ==
                            "1";

                        if (isPasscodeEnabled) {
                          final verifiedPasscode = await Get.bottomSheet<String>(
                            const VerifyPasscodeBottomSheet(),
                          );
                          if (verifiedPasscode == null ||
                              verifiedPasscode.isEmpty) {
                            return;
                          }
                          _continueAddMoneyFlow(controller);
                        } else {
                          _continueAddMoneyFlow(controller);
                        }
                      },
                      width: double.infinity,
                      height: 52,
                      text: localization.addMoneyReviewConfirm,
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

  void _continueAddMoneyFlow(AddMoneyController controller) {
    if (controller.currentStep.value == 1) {
      if (controller.gatewayMethod.value!.type == "auto") {
        controller.submitAddMoneyAuto();
      } else {
        controller.submitAddMoneyManual();
      }
    } else {
      controller.nextStepWithValidation();
    }
  }

  List<Widget> _buildDynamicFieldsReview(
    BuildContext context,
    AddMoneyController controller,
    bool isDark,
  ) {
    final localization = AppLocalizations.of(context)!;
    List<Widget> widgets = [];
    final fields = controller.dynamicFieldControllers.entries.toList();

    for (int i = 0; i < fields.length; i++) {
      final entry = fields[i];
      final fieldName = entry.key;
      final fieldData = entry.value;
      final textController = fieldData['controller'] as TextEditingController;
      final type = fieldData['type'] as String;

      if (type == 'file') {
        final file = controller.selectedImages[fieldName];
        final fileName =
            file?.path.split('/').last ??
            localization.addMoneyReviewNoFileUploaded;

        widgets.add(
          _buildReviewDynamicContent(
            context,
            isDark: isDark,
            title: fieldName,
            content: fileName,
            contentColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        );
      } else {
        widgets.add(
          _buildReviewDynamicContent(
            context,
            isDark: isDark,
            title: fieldName,
            content: textController.text,
            contentColor: isDark
                ? AppColors.darkTextPrimary
                : AppColors.lightTextPrimary,
          ),
        );
      }

      if (i < fields.length - 1) {
        widgets.add(_buildDivider(isDark));
      }
    }

    return widgets;
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
