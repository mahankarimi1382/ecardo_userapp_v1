import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/controller/gift_card_controller.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_categories_model.dart';
import 'package:qunzo_user/src/presentation/screens/gift_card/model/gift_card_country_model.dart';

class GiftCardFilterBottomSheet extends StatefulWidget {
  const GiftCardFilterBottomSheet({super.key});

  @override
  State<GiftCardFilterBottomSheet> createState() =>
      _GiftCardFilterBottomSheetState();
}

class _GiftCardFilterBottomSheetState extends State<GiftCardFilterBottomSheet> {
  final GiftCardController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      height: 420.h,
      margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadiusDirectional.only(
          topStart: Radius.circular(20.r),
          topEnd: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 40.r,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 12.h),
              Container(
                width: 40.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.lightTextPrimary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              SizedBox(height: 30.h),

              /// Gift Card Search
              CommonRequiredLabelAndDynamicField(
                labelText: localization.giftCardFilterGiftCardLabel,
                isLabelRequired: false,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    controller: controller.giftCardController,
                    focusNode: controller.giftCardFocusNode,
                    isFocused: controller.isGiftCardFocused.value,
                    keyboardType: TextInputType.text,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// Country Dropdown
              CommonRequiredLabelAndDynamicField(
                labelText: localization.giftCardFilterCountryLabel,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                    focusNode: controller.giftCardCountryFocusNode,
                    isFocused: controller.isGiftCardCountryFocused.value,
                    readOnly: true,
                    controller: controller.giftCardCountryController,
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownBottomSheet(
                          showSearch: true,
                          isShowTitle: true,
                          title: localization.giftCardFilterCountrySelectTitle,
                          isUnselectedValue: true,
                          onValueSelected: (value) {
                            if (value == localization.giftCardFilterAllOption) {
                              controller.selectedGiftCardCountry.value =
                                  GiftCardCountryData();
                              controller.giftCardCountryController.text =
                                  localization.giftCardFilterAllOption;
                              return;
                            }

                            final index = controller.giftCardCountryList
                                .indexWhere((item) => item.name == value);

                            if (index != -1) {
                              final selected =
                                  controller.giftCardCountryList[index];
                              controller.selectedGiftCardCountry.value =
                                  selected;
                              controller.giftCardCountryController.text =
                                  selected.name ?? "";
                            }
                          },
                          onValueUnSelected: () {
                            controller.selectedGiftCardCountry.value =
                                GiftCardCountryData();
                            controller.giftCardCountryController.text =
                                localization.giftCardFilterAllOption;
                          },
                          dropdownItems: [
                            localization.giftCardFilterAllOption,
                            ...controller.giftCardCountryList.map(
                              (e) => e.name.toString(),
                            ),
                          ],

                          selectedItem:
                              controller.giftCardCountryController.text,
                          textController: controller.giftCardCountryController,
                          bottomSheetHeight: 500.h,
                          currentlySelectedValue:
                              controller.giftCardCountryController.text,
                          notFoundText: localization.giftCardFilterCountryNotFound,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              /// Category Dropdown
              CommonRequiredLabelAndDynamicField(
                labelText: localization.giftCardFilterCategoryLabel,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    hintText: "",
                    suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                    focusNode: controller.giftCardCategoryFocusNode,
                    isFocused: controller.isGiftCardCategoryFocused.value,
                    readOnly: true,
                    controller: controller.giftCardCategoryController,
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownBottomSheet(
                          showSearch: true,
                          isShowTitle: true,
                          title: localization.giftCardFilterCategorySelectTitle,
                          isUnselectedValue: true,

                          onValueSelected: (value) {
                            if (value == localization.giftCardFilterAllOption) {
                              controller.selectedGiftCardCategory.value =
                                  GiftCardCategoriesData();
                              controller.giftCardCategoryController.text =
                                  localization.giftCardFilterAllOption;
                              return;
                            }

                            final index = controller.giftCardCategoryList
                                .indexWhere((item) => item.name == value);

                            if (index != -1) {
                              final selected =
                                  controller.giftCardCategoryList[index];
                              controller.selectedGiftCardCategory.value =
                                  selected;
                              controller.giftCardCategoryController.text =
                                  selected.name ?? "";
                            }
                          },

                          onValueUnSelected: () {
                            controller.selectedGiftCardCategory.value =
                                GiftCardCategoriesData();
                            controller.giftCardCategoryController.text =
                                localization.giftCardFilterAllOption;
                          },

                          dropdownItems: [
                            localization.giftCardFilterAllOption,
                            ...controller.giftCardCategoryList.map(
                              (e) => e.name.toString(),
                            ),
                          ],

                          selectedItem:
                              controller.giftCardCategoryController.text,
                          textController: controller.giftCardCategoryController,
                          bottomSheetHeight: 500.h,
                          currentlySelectedValue:
                              controller.giftCardCategoryController.text,
                          notFoundText:
                              localization.giftCardFilterCategoryNotFound,
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              /// Search Button
              CommonButton(
                width: double.infinity,
                text: localization.giftCardFilterSearchButton,
                onPressed: () {
                  controller.applyFilter();
                  Get.back();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
