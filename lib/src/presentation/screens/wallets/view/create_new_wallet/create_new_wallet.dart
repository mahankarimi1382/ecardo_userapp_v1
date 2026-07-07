import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/controller/create_new_wallet_controller.dart';

class CreateNewWallet extends StatelessWidget {
  const CreateNewWallet({super.key});

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final CreateNewWalletController controller = Get.find();

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              CommonAppBar(title: localization.createNewWalletScreenTitle),
              SizedBox(height: 30),
              Expanded(
                child: Obx(
                  () => Container(
                    margin: EdgeInsets.symmetric(horizontal: 18),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                    ),
                    child: controller.isLoading.value
                        ? CommonLoading(isColorShow: false)
                        : Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              children: [
                                SizedBox(height: 30),
                                CommonRequiredLabelAndDynamicField(
                                  labelText:
                                      localization.createNewWalletCurrency,
                                  isLabelRequired: true,
                                  dynamicField: CommonTextInputField(
                                    suffixIcon: Image.asset(
                                      PngAssets.arrowDownCommonIcon,
                                    ),
                                    suffixIconColor:
                                        AppColors.lightTextTertiary,
                                    focusNode: controller.currencyFocusNode,
                                    isFocused:
                                        controller.isCurrencyFocused.value,
                                    backgroundColor: AppColors.transparent,
                                    controller: controller.currencyController,
                                    onTap: () {
                                      Get.bottomSheet(
                                        CommonDropdownBottomSheet(
                                          title: localization
                                              .createNewWalletCurrency,
                                          isShowTitle: true,
                                          notFoundText: localization
                                              .createNewWalletCurrencyNotFound,
                                          onValueSelected: (value) {
                                            int index = controller
                                                .currenciesList
                                                .indexWhere(
                                                  (item) =>
                                                      item.fullName == value,
                                                );

                                            if (index != -1) {
                                              final selectedCurrency =
                                                  controller
                                                      .currenciesList[index];
                                              controller.currency.value =
                                                  selectedCurrency;
                                              controller
                                                      .currencyController
                                                      .text =
                                                  selectedCurrency.fullName ??
                                                  "";
                                            }
                                          },
                                          selectedValue: controller
                                              .currenciesList
                                              .map((item) => item.fullName!)
                                              .toList(),
                                          dropdownItems: controller
                                              .currenciesList
                                              .map((item) => item.fullName!)
                                              .toList(),
                                          selectedItem: controller
                                              .currencyController
                                              .text,
                                          textController:
                                              controller.currencyController,
                                          currentlySelectedValue: controller
                                              .currencyController
                                              .text,
                                          bottomSheetHeight: 400,
                                        ),
                                      );
                                    },
                                    readOnly: true,
                                    hintText: localization
                                        .createNewWalletSelectCurrency,
                                  ),
                                ),
                                SizedBox(height: 40),
                                CommonButton(
                                  onPressed: () => controller.createWallet(),
                                  width: double.infinity,

                                  text:
                                      localization.createNewWalletCreateButton,
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isCreateWalletLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
