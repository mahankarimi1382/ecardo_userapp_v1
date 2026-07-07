import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

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
    final localizatoin = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        top: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(30),
          topEnd: Radius.circular(30),
        ),
      ),
      child: Obx(
        () => controller.isLoading.value
            ? CommonLoading()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    CommonRequiredLabelAndDynamicField(
                      labelText:
                          localizatoin.withdrawAmountStepSectionWithdrawAccount,
                      isLabelRequired: true,
                      dynamicField: Obx(
                        () => CommonTextInputField(
                          suffixIcon: Obx(
                            () => Image(
                              image: const AssetImage(
                                PngAssets.arrowDownCommonIcon,
                              ),
                              color: controller.isWithdrawAccountFocused.value
                                  ? AppColors.lightPrimary
                                  : AppColors.lightTextTertiary,
                            ),
                          ),
                          backgroundColor: AppColors.transparent,
                          focusNode: controller.withdrawAccountFocusNode,
                          isFocused: controller.isWithdrawAccountFocused.value,
                          hintText: "",
                          readOnly: true,
                          controller: controller.withdrawAccountController,
                          onTap: () {
                            Get.bottomSheet(
                              CommonDropdownBottomSheetThree<Accounts>(
                                items: controller.withdrawAccountList,
                                selectedItem: controller.withdrawAccount.value,
                                bottomSheetHeight: 400,
                                isShowTitle: true,
                                title: localizatoin
                                    .withdrawAmountStepSectionWithdrawAccountTitle,
                                notFoundText: localizatoin
                                    .withdrawAmountStepSectionNoAccountsFound,
                                getDisplayText: (account) =>
                                    account.methodName ?? "",
                                areItemsEqual: (account1, account2) =>
                                    account1.id == account2.id,
                                getItemIcon: (account) => account.method?.icon,
                                getItemSubtitle: (account) =>
                                    "${localizatoin.withdrawAmountStepSectionCurrencyLabel} ${account.currency ?? ''}",
                                getItemDescription: (account) {
                                  if (account.method != null) {
                                    return "${localizatoin.withdrawAmountStepSectionMinDescription} ${account.method!.minWithdraw} | ${localizatoin.withdrawAmountStepSectionMaxDescription} ${account.method!.maxWithdraw}";
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
                    const SizedBox(height: 16),
                    CommonRequiredLabelAndDynamicField(
                      labelText: localizatoin.withdrawAmountStepSectionAmount,
                      isLabelRequired: true,
                      dynamicField: Obx(
                        () => CommonTextInputField(
                          focusNode: controller.amountFocusNode,
                          isFocused: controller.isAmountFocused.value,
                          isSuffixIconCompact: false,
                          suffixIcon:
                              (controller
                                      .withdrawAccount
                                      .value
                                      ?.currency
                                      ?.isNotEmpty ??
                                  false)
                              ? Center(
                                  child: Text(
                                    controller.withdrawAccount.value!.currency!,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: AppColors.lightTextPrimary
                                          .withValues(alpha: 0.40),
                                    ),
                                  ),
                                )
                              : null,
                          borderRadius: 16,
                          backgroundColor: AppColors.transparent,
                          hintText: "",
                          controller: controller.amountController,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                    Obx(() {
                      final withdrawAccount = controller.withdrawAccount.value;
                      final hasAccount =
                          withdrawAccount != null &&
                          controller.withdrawAccountController.text.isNotEmpty;

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

                      final min =
                          double.tryParse(
                            withdrawAccount.method?.minWithdraw ?? "0",
                          )?.toStringAsFixed(calculateDecimals) ??
                          "0.00";

                      final max =
                          double.tryParse(
                            withdrawAccount.method?.maxWithdraw ?? "0",
                          )?.toStringAsFixed(calculateDecimals) ??
                          "0.00";

                      return Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          "${localizatoin.withdrawAmountStepSectionMin} $min ${withdrawAccount.currency ?? ""} ${localizatoin.withdrawAmountStepSectionMax} $max ${withdrawAccount.currency ?? ""}",
                          style: const TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 40),
                    CommonButton(
                      borderRadius: 16,
                      width: double.infinity,

                      text: localizatoin
                          .withdrawAmountStepSectionWithdrawMoneyButton,
                      onPressed: () {
                        controller.nextStepWithValidation();
                      },
                    ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
      ),
    );
  }
}
