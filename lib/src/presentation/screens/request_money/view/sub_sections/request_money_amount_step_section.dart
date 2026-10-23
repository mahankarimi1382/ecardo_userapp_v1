import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/request_money/controller/request_money_controller.dart';
import 'package:ecardo_user/src/presentation/screens/transfer/view/widgets/transfer_amount_input_card.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final siteCurrency =
        Get.find<SettingsService>().getSetting("site_currency") ?? 'USD';
    final siteDecimals =
        Get.find<SettingsService>().getSetting("site_currency_decimals") ?? '2';

    return Obx(() {
      final currentWallet = controller.wallet.value;
      final decimals = DynamicDecimalsHelper().getDynamicDecimals(
        currencyCode: currentWallet?.code ?? 'USD',
        siteCurrencyCode: siteCurrency,
        siteCurrencyDecimals: siteDecimals,
        isCrypto: currentWallet?.isCrypto ?? false,
      );

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.sm),

          // 1. Recipient UID Input Field with QR Scanner
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
                      backgroundColor: isDark
                          ? colorScheme.surfaceContainerHigh.withValues(
                              alpha: 0.4,
                            )
                          : colorScheme.surface,
                      hintText: "Enter Recipient UID",
                      controller: controller.recipientUidController,
                      keyboardType: TextInputType.number,
                      suffixIcon:
                          controller.recipientUidController.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                size: 18,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                              onPressed: () {
                                controller.recipientUidController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // QR Scanner button
                InkWell(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  onTap: () async {
                    HapticFeedback.lightImpact();
                    final scannedCode = await Get.to(
                      () => const QrScannerScreen(),
                    );

                    if (scannedCode != null) {
                      final clean = scannedCode.trim();
                      final uidMatch = RegExp(
                        r'^(?:UID\s*:\s*)?(\d+)$',
                        caseSensitive: false,
                      ).firstMatch(clean);

                      if (uidMatch != null) {
                        controller.recipientUidController.text = uidMatch.group(
                          1,
                        )!;
                        setState(() {});
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
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      PngAssets.commonScannerIcon,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Standardized FinTech Hero Amount Input Card (Zero-decimal Toman strictly enforced)
          TransferAmountInputCard(
            controller: controller.requestAmountController,
            focusNode: controller.requestAmountFocusNode,
            wallet: null,
            customCurrencyCode: currentWallet?.code,
            customCurrencySymbol: currentWallet?.symbol,
            customBalanceText: currentWallet?.formattedBalance,
            customTitle:
                localization.requestMoneyAmountStepSectionRequestAmount,
            decimals: decimals,
            showFeePill: false,
            onPercentageSelected: (fraction) {
              controller.setPercentage(fraction);
              setState(() {});
            },
            onClear: () {
              controller.requestAmountController.clear();
              setState(() {});
            },
          ),

          // Limits text
          if (controller.requestMoneyWalletsList.isNotEmpty &&
              currentWallet?.requestMoneyLimit != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Padding(
              padding: const EdgeInsetsDirectional.only(
                start: AppSpacing.xs,
              ),
              child: Text(
                "${localization.requestMoneyAmountStepSectionMin} ${double.tryParse(currentWallet?.requestMoneyLimit?.min ?? '0')?.toStringAsFixed(decimals) ?? '0'} "
                "${currentWallet?.code ?? ''} | ${localization.requestMoneyAmountStepSectionMax} "
                "${double.tryParse(currentWallet?.requestMoneyLimit?.max ?? '0')?.toStringAsFixed(decimals) ?? '0'} "
                "${currentWallet?.code ?? ''}",
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
          ],

          const SizedBox(height: AppSpacing.lg),

          // 3. Optional Requester Note Field
          CommonRequiredLabelAndDynamicField(
            labelText: localization.requestMoneyAmountStepSectionNote,
            dynamicField: Obx(
              () => CommonTextInputField(
                isFocused: controller.isNoteFocused.value,
                focusNode: controller.noteFocusNode,
                borderRadius: AppSpacing.radiusLg,
                backgroundColor: isDark
                    ? colorScheme.surfaceContainerHigh.withValues(alpha: 0.4)
                    : colorScheme.surface,
                hintText: "",
                controller: controller.noteController,
                keyboardType: TextInputType.text,
                maxLine: 3,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // 4. Action Button with Debounce and Explicit Loading State
          CommonButton(
            borderRadius: AppSpacing.radiusLg,
            width: double.infinity,
            height: 52,
            isLoading: controller.isRequestMoneyLoading.value,
            text: localization.requestMoneyAmountStepSectionRequestMoneyButton,
            onPressed: () {
              HapticFeedback.lightImpact();
              controller.nextStepWithValidation();
            },
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      );
    });
  }
}
