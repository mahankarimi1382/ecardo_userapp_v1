import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/controller/create_virtual_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/virtual_card/model/card_holder_model.dart';

class ChooseCardHolderSection extends StatelessWidget {
  const ChooseCardHolderSection({super.key});

  @override
  Widget build(BuildContext context) {
    final CreateVirtualCardController controller = Get.find();
    final localization = AppLocalizations.of(context);

    return Column(
      children: [
        CommonRequiredLabelAndDynamicField(
          labelText: localization!.chooseCardHolderLabel,
          isLabelRequired: true,
          dynamicField: Obx(
            () => CommonTextInputField(
              suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
              focusNode: controller.cardHolderFocusNode,
              isFocused: controller.isCardHolderFocused.value,
              onTap: () {
                Get.bottomSheet(
                  CommonDropdownBottomSheetThree<CardHolderData>(
                    items: controller.cardHolderList,
                    selectedItem: controller.selectedCardHolder.value,
                    bottomSheetHeight: 400,
                    getDisplayText: (CardHolderData item) {
                      return "${item.name} - ${item.email}";
                    },
                    areItemsEqual:
                        (CardHolderData item1, CardHolderData item2) {
                          return item1.id == item2.id;
                        },
                    onItemSelected: (CardHolderData selectedItem) {
                      controller.selectedCardHolder.value = selectedItem;
                      controller.cardHolderController.text =
                          "${selectedItem.name} - ${selectedItem.email}";
                    },
                    onItemUnSelected: () {
                      controller.selectedCardHolder.value = null;
                      controller.cardHolderController.clear();
                    },
                    notFoundText: localization.chooseCardHolderDropdownNotFound,
                    title: localization.chooseCardHolderDropdownTitle,
                    isShowTitle: true,
                  ),
                );
              },
              hintText: "",
              controller: controller.cardHolderController,
              suffixIconColor: AppColors.lightTextTertiary,
              readOnly: true,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Obx(
          () => CommonButton(
            text: localization.chooseCardHolderButtonCreate,
            isLoading: controller.isCreateVirtualCardLoading.value,
            onPressed: () => controller.createVirtualCard(),
          ),
        ),
        SizedBox(height: 30.h),
      ],
    );
  }
}
