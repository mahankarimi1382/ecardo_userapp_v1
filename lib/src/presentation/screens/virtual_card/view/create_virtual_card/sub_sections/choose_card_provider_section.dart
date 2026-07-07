import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_holder_model.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_provider_model.dart';

class ChooseCardProviderSection extends StatelessWidget {
  const ChooseCardProviderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateVirtualCardController controller = Get.find();
    final localization = AppLocalizations.of(context);

    return CommonRequiredLabelAndDynamicField(
      labelText: localization!.chooseCardProviderLabel,
      isLabelRequired: true,
      dynamicField: Column(
        children: [
          Obx(
            () => CommonTextInputField(
              suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
              focusNode: controller.cardProviderFocusNode,
              isFocused: controller.isCardProviderFocused.value,
              onTap: () {
                Get.bottomSheet(
                  CommonDropdownBottomSheet(
                    isShowTitle: true,
                    title: localization.chooseCardProviderDropdownNotFound,
                    notFoundText: localization.chooseCardProviderDropdownTitle,
                    onValueSelected: (value) async {
                      int index = controller.cardProvidersList.indexWhere(
                        (item) => item.name == value,
                      );

                      if (index != -1) {
                        final selectedCardProvider =
                            controller.cardProvidersList[index];
                        controller.selectedCardProvider.value =
                            selectedCardProvider;
                        controller.cardProviderController.text =
                            selectedCardProvider.name ?? "";
                        controller.cardHolderList.clear();
                        controller.cardHolderController.clear();
                        controller.selectedCardHolder.value = CardHolderData();
                        await controller.fetchCardHolders();
                      }
                    },

                    selectedValue: controller.cardProvidersList
                        .map((item) => item.name.toString())
                        .toList(),
                    dropdownItems: controller.cardProvidersList
                        .map((item) => item.name.toString())
                        .toList(),
                    isUnselectedValue: true,
                    onValueUnSelected: () {
                      controller.selectedCardProvider.value =
                          CardProviderData();
                      controller.cardProviderController.clear();
                      controller.cardHolderList.clear();
                      controller.cardHolderController.clear();
                      controller.selectedCardHolder.value = CardHolderData();
                    },

                    selectedItem: controller.cardProviderController.text,
                    textController: controller.cardProviderController,
                    currentlySelectedValue:
                        controller.cardProviderController.text,
                    bottomSheetHeight: 400.h,
                  ),
                );
              },
              hintText: "",
              controller: controller.cardProviderController,
              suffixIconColor: AppColors.lightTextTertiary,
              readOnly: true,
            ),
          ),
          SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.lightTextTertiary.withValues(alpha: 0.05),
            ),
            child: Text(
              "Issue Fee: ${Get.find<SettingsService>().getSetting("card_creation_charge")} ${Get.find<SettingsService>().getSetting("site_currency")}",
              textAlign: TextAlign.center,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 14,
                color: AppColors.error.withValues(alpha: 0.70),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
