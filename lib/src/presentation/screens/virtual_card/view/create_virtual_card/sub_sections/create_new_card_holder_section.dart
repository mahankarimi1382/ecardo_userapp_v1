import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';

class CreateNewCardHolderSection extends StatelessWidget {
  const CreateNewCardHolderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateVirtualCardController controller = Get.find();
    final localization = AppLocalizations.of(context);

    return Column(
      children: [
        CommonRequiredLabelAndDynamicField(
          labelText: localization!.createCardHolderLabelName,
          dynamicField: Obx(
            () => CommonTextInputField(
              hintText: "",
              focusNode: controller.nameFocusNode,
              isFocused: controller.isNameFocused.value,
              controller: controller.nameController,
              keyboardType: TextInputType.name,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.createCardHolderLabelEmail,
          dynamicField: Obx(
            () => CommonTextInputField(
              hintText: "",
              focusNode: controller.emailFocusNode,
              isFocused: controller.isEmailFocused.value,
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.createCardHolderLabelPhoneNumber,
          dynamicField: Obx(
            () => CommonTextInputField(
              hintText: "",
              focusNode: controller.phoneNumberFocusNode,
              isFocused: controller.isPhoneNumberFocused.value,
              controller: controller.phoneNumberController,
              keyboardType: TextInputType.phone,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.createCardHolderLabelCountry,
          isLabelRequired: false,
          dynamicField: Obx(
            () => CommonTextInputField(
              focusNode: controller.countryFocusNode,
              isFocused: controller.isCountryFocused.value,
              onTap: () {
                Get.bottomSheet(
                  CommonDropdownBottomSheet(
                    title: localization.createCardHolderDropdownCountryTitle,
                    isShowTitle: true,
                    showSearch: true,
                    notFoundText:
                        localization.createCardHolderDropdownCountryNotFound,
                    onValueSelected: (value) {
                      int index = controller.countryList.indexWhere(
                        (item) => item.name == value,
                      );

                      if (index != -1) {
                        final selectedCountry = controller.countryList[index];
                        controller.selectedCountry.value = selectedCountry;
                      }
                    },
                    selectedValue: controller.countryList
                        .map((item) => item.name.toString())
                        .toList(),
                    dropdownItems: controller.countryList
                        .map((item) => item.name.toString())
                        .toList(),
                    selectedItem: controller.countryController.text,
                    textController: controller.countryController,
                    currentlySelectedValue: controller.countryController.text,
                    bottomSheetHeight: 500,
                  ),
                );
              },
              hintText: "",
              controller: controller.countryController,
              suffixIconColor: AppColors.lightTextTertiary,
              readOnly: true,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.createCardHolderLabelCity,
          dynamicField: Obx(
            () => CommonTextInputField(
              hintText: "",
              focusNode: controller.cityFocusNode,
              isFocused: controller.isCityFocused.value,
              controller: controller.cityController,
              keyboardType: TextInputType.text,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.createCardHolderLabelState,
          dynamicField: Obx(
            () => CommonTextInputField(
              hintText: "",
              focusNode: controller.stateFocusNode,
              isFocused: controller.isStateFocused.value,
              controller: controller.stateController,
              keyboardType: TextInputType.text,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.createCardHolderLabelPostalCode,
          dynamicField: Obx(
            () => CommonTextInputField(
              hintText: "",
              focusNode: controller.postalCodeFocusNode,
              isFocused: controller.isPostalCodeFocused.value,
              controller: controller.postalCodeController,
              keyboardType: TextInputType.number,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        CommonRequiredLabelAndDynamicField(
          labelText: localization.createCardHolderLabelAddress,
          dynamicField: Obx(
            () => CommonTextInputField(
              hintText: "",
              focusNode: controller.addressFocusNode,
              isFocused: controller.isAddressFocused.value,
              controller: controller.addressController,
              keyboardType: TextInputType.streetAddress,
              maxLine: 4,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => CommonButton(
            text: localization.createCardHolderButtonCreate,
            isLoading: controller.isCreateVirtualCardLoading.value,
            onPressed: () => controller.createVirtualCard(),
          ),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}
