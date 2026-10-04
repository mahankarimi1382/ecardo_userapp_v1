import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/widgets/qr_scanner_screen.dart';

class RequestMoneyAmountStepSection extends StatefulWidget {
  const RequestMoneyAmountStepSection({super.key});

  @override
  State<RequestMoneyAmountStepSection> createState() =>
      _RequestMoneyAmountStepSectionState();
}

class _RequestMoneyAmountStepSectionState
    extends State<RequestMoneyAmountStepSection> {
  final RequestMoneyController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.page,
        end: AppSpacing.page,
        bottom: AppSpacing.xxl,
        top: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadiusDirectional.only(
          topStart: Radius.circular(AppSpacing.radiusXl),
          topEnd: Radius.circular(AppSpacing.radiusXl),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.darkShadow : AppColors.lightShadow,
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.lg),
          CommonRequiredLabelAndDynamicField(
            labelText: localization.requestMoneyAmountStepSectionRecipientId,
            isLabelRequired: true,
            dynamicField: Row(
              children: [
                Expanded(
                  child: Obx(
                    () => CommonTextInputField(
                      focusNode: controller.recipientUidFocusNode,
                      isFocused: controller.isRecipientUidFocused.value,
                      borderRadius: AppSpacing.radiusLg,
                      backgroundColor: AppColors.transparent,
                      hintText: "",
                      controller: controller.recipientUidController,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final scannedCode = await Get.to(
                      () => const QrScannerScreen(),
                    );

                    if (scannedCode != null) {
                      if (scannedCode.startsWith("UID:")) {
                        final midValue = scannedCode
                            .replaceAll("UID:", "")
                            .trim();

                        final isNumeric = RegExp(r'^\d+$').hasMatch(midValue);

                        if (isNumeric) {
                          controller.recipientUidController.text = midValue;
                        } else {
                          ToastHelper().showErrorToast(
                            localization
                                .requestMoneyAmountStepSectionInvalidQrCodeDigits,
                          );
                        }
                      } else {
                        ToastHelper().showErrorToast(
                          localization
                              .requestMoneyAmountStepSectionInvalidQrCodePrefix,
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusLg,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? AppColors.darkShadow
                              : AppColors.lightShadow,
                          blurRadius: AppSpacing.sm,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      PngAssets.commonScannerIcon,
                      color: isDark ? AppColors.deepBlack : AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Amount Hero Card with Currency Badge and Quick Amount Chips
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurfaceVariant.withValues(alpha: 0.5)
                  : AppColors.lightSecondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CommonRequiredLabelAndDynamicField(
                  labelText:
                      localization.requestMoneyAmountStepSectionRequestAmount,
                  isLabelRequired: true,
                  dynamicField: Obx(
                    () => CommonTextInputField(
                      focusNode: controller.requestAmountFocusNode,
                      isFocused: controller.isRequestAmountFocused.value,
                      isSuffixIconCompact: false,
                      suffixIcon: Container(
                        margin: const EdgeInsetsDirectional.only(
                          end: AppSpacing.sm,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkPrimary.withValues(alpha: 0.15)
                              : AppColors.lightPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: Text(
                          controller.wallet.value?.code ?? '',
                          style: TextStyle(
                            letterSpacing: 0.5,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkPrimary
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                      borderRadius: AppSpacing.radiusLg,
                      backgroundColor: AppColors.transparent,
                      hintText: "0.00",
                      controller: controller.requestAmountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        AmountInputFormatter(maxDecimals: 8),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Obx(() {
                  final wallet = controller.wallet.value;
                  final balance = double.tryParse(wallet?.balance ?? '0') ?? 0.0;
                  return QuickAmountSelector(
                    textController: controller.requestAmountController,
                    availableBalance: balance > 0 ? balance : 1000.0,
                    isCrypto: wallet?.isCrypto ?? false,
                    currencyCode: wallet?.code,
                    height: 32.0,
                    chipSpacing: AppSpacing.sm,
                  );
                }),
              ],
            ),
          ),

          Obx(
            () => Visibility(
              visible: controller.requestMoneyWalletsList.isNotEmpty &&
                  controller.wallet.value?.requestMoneyLimit != null,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  top: AppSpacing.xs,
                  start: AppSpacing.xs,
                ),
                child: Text(
                  "${localization.requestMoneyAmountStepSectionMin} ${controller.wallet.value?.requestMoneyLimit?.min ?? ''} ${controller.wallet.value?.code ?? ''} | ${localization.requestMoneyAmountStepSectionMax} ${controller.wallet.value?.requestMoneyLimit?.max ?? ''} ${controller.wallet.value?.code ?? ''}",
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          CommonRequiredLabelAndDynamicField(
            labelText: localization.requestMoneyAmountStepSectionNote,
            dynamicField: Obx(
              () => CommonTextInputField(
                isFocused: controller.isNoteFocused.value,
                focusNode: controller.noteFocusNode,
                borderRadius: AppSpacing.radiusLg,
                backgroundColor: AppColors.transparent,
                hintText: "",
                controller: controller.noteController,
                keyboardType: TextInputType.text,
                maxLine: 3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          CommonButton(
            borderRadius: AppSpacing.radiusLg,
            width: double.infinity,
            text: localization.requestMoneyAmountStepSectionRequestMoneyButton,
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.nextStepWithValidation();
            },
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}
