import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';

class PaymentLinksAmountStepSection extends StatefulWidget {
  const PaymentLinksAmountStepSection({super.key});

  @override
  State<PaymentLinksAmountStepSection> createState() =>
      _PaymentLinksAmountStepSectionState();
}

class _PaymentLinksAmountStepSectionState
    extends State<PaymentLinksAmountStepSection> {
  final PaymentLinksController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.clearFields();
    controller.fetchCurrencies();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
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
      child: Obx(() {
        if (controller.isLoading.value) {
          return const CommonLoading();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    labelText: localizations.paymentLinksAmountSectionTitle,
                    isLabelRequired: false,
                    dynamicField: Obx(
                      () => CommonTextInputField(
                        focusNode: controller.amountFocusNode,
                        isFocused: controller.isAmountFocused.value,
                        isSuffixIconCompact: false,
                        suffixIcon: Obx(() {
                          final code = controller.currency.value?.code ??
                              Get.find<SettingsService>()
                                  .getSetting("site_currency") ??
                              "USD";
                          return Container(
                            margin: const EdgeInsetsDirectional.only(
                              end: AppSpacing.sm,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkPrimary
                                      .withValues(alpha: 0.15)
                                  : AppColors.lightPrimary
                                      .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: Text(
                              code,
                              style: TextStyle(
                                letterSpacing: 0.5,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary,
                              ),
                            ),
                          );
                        }),
                        borderRadius: AppSpacing.radiusLg,
                        backgroundColor: AppColors.transparent,
                        hintText: "0.00",
                        controller: controller.amountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Obx(() {
                    final curr = controller.currency.value;
                    return QuickAmountSelector(
                      textController: controller.amountController,
                      availableBalance: 1000.0,
                      isCrypto: curr?.type?.toLowerCase() == 'crypto',
                      currencyCode: curr?.code,
                      height: 32.0,
                      chipSpacing: AppSpacing.sm,
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            CommonRequiredLabelAndDynamicField(
              labelText: localizations.paymentLinksCurrencyLabel,
              isLabelRequired: true,
              dynamicField: CommonTextInputField(
                suffixIcon: Image.asset(
                  PngAssets.arrowDownCommonIcon,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextTertiary,
                ),
                suffixIconColor: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextTertiary,
                focusNode: controller.currencyFocusNode,
                isFocused: controller.isCurrencyFocused.value,
                borderRadius: AppSpacing.radiusLg,
                backgroundColor: AppColors.transparent,
                controller: controller.currencyController,
                onTap: () {
                  HapticFeedback.lightImpact();
                  List<String> dropdownList = [
                    Get.find<SettingsService>()
                        .getSetting("site_currency")
                        .toString(),
                    ...controller.currenciesList.map((item) => item.fullName!),
                  ];

                  Get.bottomSheet(
                    CommonDropdownBottomSheet(
                      title: localizations.paymentLinksCurrencyDropdownTitle,
                      isShowTitle: true,
                      notFoundText: localizations.paymentLinksCurrencyNotFound,
                      onValueSelected: (value) {
                        if (value ==
                            Get.find<SettingsService>()
                                .getSetting("site_currency")
                                .toString()) {
                          controller.currencyController.text =
                              Get.find<SettingsService>()
                                  .getSetting("site_currency")
                                  .toString();
                          return;
                        }

                        int index = controller.currenciesList.indexWhere(
                          (item) => item.fullName == value,
                        );

                        if (index != -1) {
                          final selectedCurrency =
                              controller.currenciesList[index];
                          controller.currency.value = selectedCurrency;
                          controller.currencyController.text =
                              selectedCurrency.fullName ?? "";
                        }
                      },
                      selectedValue: dropdownList,
                      dropdownItems: dropdownList,
                      selectedItem: controller.currencyController.text,
                      textController: controller.currencyController,
                      currentlySelectedValue:
                          controller.currencyController.text,
                      bottomSheetHeight: 400,
                    ),
                  );
                },
                readOnly: true,
                hintText: localizations.paymentLinksCurrencyHint,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            CommonRequiredLabelAndDynamicField(
              labelText: localizations.paymentLinksNoteLabel,
              isLabelRequired: false,
              dynamicField: Obx(
                () => CommonTextInputField(
                  focusNode: controller.noteFocusNode,
                  isFocused: controller.isNoteFocused.value,
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
            Obx(
              () => CommonButton(
                borderRadius: AppSpacing.radiusLg,
                width: double.infinity,
                isLoading: controller.isCreatePaymentLinkLoading.value,
                text: localizations.paymentLinksCreateLinkButton,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  controller.createLink();
                },
              ),
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        );
      }),
    );
  }
}
