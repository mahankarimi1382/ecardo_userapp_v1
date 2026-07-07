import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/payment_links/controller/payment_links_controller.dart';

import '../../../../../../l10n/app_localizations.dart';
import '../../../../../app/constants/assets_path/png/png_assets.dart';
import '../../../../../common/widgets/button/common_button.dart';
import '../../../../../common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';

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
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsetsDirectional.only(
        start: 20,
        end: 20,
        bottom: 24,
        top: 2,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(30),
          topEnd: Radius.circular(30),
        ),
      ),
      child: Obx(() {
        if (controller.isLoading.value) {
          return CommonLoading();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            CommonRequiredLabelAndDynamicField(
              labelText: localizations.paymentLinksAmountSectionTitle,
              isLabelRequired: false,
              dynamicField: Obx(
                () => CommonTextInputField(
                  focusNode: controller.amountFocusNode,
                  isFocused: controller.isAmountFocused.value,
                  backgroundColor: AppColors.transparent,
                  hintText: "",
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                ),
              ),
            ),
            SizedBox(height: 16),
            CommonRequiredLabelAndDynamicField(
              labelText: localizations.paymentLinksCurrencyLabel,
              isLabelRequired: true,
              dynamicField: CommonTextInputField(
                suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                suffixIconColor: AppColors.lightTextTertiary,
                focusNode: controller.currencyFocusNode,
                isFocused: controller.isCurrencyFocused.value,
                backgroundColor: AppColors.transparent,
                controller: controller.currencyController,
                onTap: () {
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
            SizedBox(height: 16),
            CommonRequiredLabelAndDynamicField(
              labelText: localizations.paymentLinksNoteLabel,
              isLabelRequired: false,
              dynamicField: Obx(
                () => CommonTextInputField(
                  focusNode: controller.noteFocusNode,
                  isFocused: controller.isNoteFocused.value,
                  backgroundColor: AppColors.transparent,
                  hintText: "",
                  controller: controller.noteController,
                  keyboardType: TextInputType.text,
                  maxLine: 3,
                ),
              ),
            ),
            SizedBox(height: 40),
            Obx(
              () => CommonButton(
                borderRadius: 16,
                width: double.infinity,
                isLoading: controller.isCreatePaymentLinkLoading.value,
                text: localizations.paymentLinksCreateLinkButton,
                onPressed: () => controller.createLink(),
              ),
            ),
            SizedBox(height: 50),
          ],
        );
      }),
    );
  }
}
