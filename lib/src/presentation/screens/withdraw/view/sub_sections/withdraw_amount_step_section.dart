import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class WithdrawAmountStepSection extends StatefulWidget {
  const WithdrawAmountStepSection({super.key});

  @override
  State<WithdrawAmountStepSection> createState() =>
      _WithdrawAmountStepSectionState();
}

class _WithdrawAmountStepSectionState extends State<WithdrawAmountStepSection> {
  final WithdrawController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.page,
        end: AppSpacing.page,
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
      child: Obx(
        () => controller.isLoading.value
            ? const CommonLoading()
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    CommonRequiredLabelAndDynamicField(
                      labelText:
                          localizations.withdrawAmountStepSectionWithdrawAccount,
                      isLabelRequired: true,
                      dynamicField: Obx(
                        () => CommonTextInputField(
                          suffixIcon: Obx(
                            () => Image(
                              image: const AssetImage(
                                PngAssets.arrowDownCommonIcon,
                              ),
                              color: controller.isWithdrawAccountFocused.value
                                  ? (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary)
                                  : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextTertiary),
                            ),
                          ),
                          backgroundColor: AppColors.transparent,
                          focusNode: controller.withdrawAccountFocusNode,
                          isFocused: controller.isWithdrawAccountFocused.value,
                          borderRadius: AppSpacing.radiusLg,
                          hintText: "",
                          readOnly: true,
                          controller: controller.withdrawAccountController,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Get.bottomSheet(
                              CommonDropdownBottomSheetThree<Accounts>(
                                items: controller.withdrawAccountList,
                                selectedItem: controller.withdrawAccount.value,
                                bottomSheetHeight: 400,
                                isShowTitle: true,
                                title: localizations
                                    .withdrawAmountStepSectionWithdrawAccountTitle,
                                notFoundText: localizations
                                    .withdrawAmountStepSectionNoAccountsFound,
                                getDisplayText: (account) =>
                                    account.methodName ?? "",
                                areItemsEqual: (account1, account2) =>
                                    account1.id == account2.id,
                                getItemIcon: (account) => account.method?.icon,
                                getItemSubtitle: (account) =>
                                    "${localizations.withdrawAmountStepSectionCurrencyLabel} ${account.currency ?? ''}",
                                getItemDescription: (account) {
                                  if (account.method != null) {
                                    return "${localizations.withdrawAmountStepSectionMinDescription} ${account.method!.minWithdraw} | ${localizations.withdrawAmountStepSectionMaxDescription} ${account.method!.maxWithdraw}";
                                  }
                                  return null;
                                },
                                onItemSelected: (selectedAccount) {
                                  controller.withdrawAccount.value =
                                      selectedAccount;
                                  controller.withdrawAccountController.text =
                                      selectedAccount.methodName ?? "";
                                },
                                onItemUnSelected: () {
                                  controller.withdrawAccount.value = Accounts();
                                  controller.withdrawAccountController.clear();
                                },
                              ),
                            );
                          },
                        ),
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
                            : AppColors.lightSecondaryContainer
                                .withValues(alpha: 0.35),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonRequiredLabelAndDynamicField(
                            labelText:
                                localizations.withdrawAmountStepSectionAmount,
                            isLabelRequired: true,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                focusNode: controller.amountFocusNode,
                                isFocused: controller.isAmountFocused.value,
                                isSuffixIconCompact: false,
                                suffixIcon: (controller
                                            .withdrawAccount
                                            .value
                                            ?.currency
                                            ?.isNotEmpty ??
                                        false)
                                    ? Container(
                                        margin:
                                            const EdgeInsetsDirectional.only(
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
                                          controller.withdrawAccount.value!
                                                  .currency ??
                                              "",
                                          style: TextStyle(
                                            letterSpacing: 0.5,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                            color: isDark
                                                ? AppColors.darkPrimary
                                                : AppColors.lightPrimary,
                                          ),
                                        ),
                                      )
                                    : null,
                                borderRadius: AppSpacing.radiusLg,
                                backgroundColor: AppColors.transparent,
                                hintText: "0.00",
                                controller: controller.amountController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  AmountInputFormatter(maxDecimals: 8),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Obx(() {
                            final withdrawAccount =
                                controller.withdrawAccount.value;
                            final currency = withdrawAccount?.currency;
                            return QuickAmountSelector(
                              textController: controller.amountController,
                              availableBalance: 1000.0,
                              isCrypto:
                                  withdrawAccount?.method?.isCrypto ?? false,
                              currencyCode: currency,
                              height: 32.0,
                              chipSpacing: AppSpacing.sm,
                            );
                          }),
                        ],
                      ),
                    ),

                    Obx(() {
                      final withdrawAccount = controller.withdrawAccount.value;
                      final hasAccount = withdrawAccount != null &&
                          controller
                              .withdrawAccountController.text.isNotEmpty;

                      if (!hasAccount) {
                        return const SizedBox.shrink();
                      }

                      final calculateDecimals = DynamicDecimalsHelper()
                          .getDynamicDecimals(
                            currencyCode: withdrawAccount.currency ?? "",
                            siteCurrencyCode:
                                Get.find<SettingsService>().getSetting(
                                  "site_currency",
                                ) ??
                                "",
                            siteCurrencyDecimals:
                                Get.find<SettingsService>().getSetting(
                                  "site_currency_decimals",
                                ) ??
                                "2",
                            isCrypto: withdrawAccount.method?.isCrypto ?? false,
                          );

                      final min = double.tryParse(
                            withdrawAccount.method?.minWithdraw ?? "0",
                          )?.toStringAsFixed(calculateDecimals) ??
                          "0.00";

                      final max = double.tryParse(
                            withdrawAccount.method?.maxWithdraw ?? "0",
                          )?.toStringAsFixed(calculateDecimals) ??
                          "0.00";

                      return Padding(
                        padding: const EdgeInsetsDirectional.only(
                          top: AppSpacing.xs,
                          start: AppSpacing.xs,
                        ),
                        child: Text(
                          "${localizations.withdrawAmountStepSectionMin} $min ${withdrawAccount.currency ?? ""} | ${localizations.withdrawAmountStepSectionMax} $max ${withdrawAccount.currency ?? ""}",
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: AppSpacing.xxxl),
                    CommonButton(
                      borderRadius: AppSpacing.radiusLg,
                      width: double.infinity,
                      text: localizations
                          .withdrawAmountStepSectionWithdrawMoneyButton,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        controller.nextStepWithValidation();
                      },
                    ),
                    const SizedBox(height: AppSpacing.huge),
                  ],
                ),
              ),
      ),
    );
  }
}
