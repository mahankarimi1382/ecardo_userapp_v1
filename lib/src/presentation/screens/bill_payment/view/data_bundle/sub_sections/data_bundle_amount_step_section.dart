import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/controller/data_bundle_controller.dart';
import 'package:qunzo_user/src/presentation/screens/bill_payment/model/pay_bill_service_model.dart';

class DataBundleAmountStepSection extends StatelessWidget {
  const DataBundleAmountStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final DataBundleController controller = Get.find();
    final localization = AppLocalizations.of(context);

    return Expanded(
      child: Container(
        margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(30.r),
            topEnd: Radius.circular(30.r),
          ),
          color: AppColors.white,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              spreadRadius: 0,
              blurRadius: 40,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return CommonLoading();
          }
          return SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 24.h),
                CommonRequiredLabelAndDynamicField(
                  labelText: localization!.dataBundleCountryLabel,
                  isLabelRequired: true,
                  dynamicField: Obx(
                    () => CommonTextInputField(
                      suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                      focusNode: controller.countryFocusNode,
                      isFocused: controller.isCountryFocused.value,
                      backgroundColor: AppColors.lightBackground,
                      onTap: () {
                        Get.bottomSheet(
                          CommonDropdownBottomSheet(
                            isShowTitle: true,
                            title: localization.dataBundleCountrySelectTitle,
                            isUnselectedValue: true,
                            onValueUnSelected: () {
                              controller.amountController.clear();
                              controller.amountText.value = "";
                              controller.serviceController.clear();
                              controller.serviceData.value = null;
                              controller.payBillServiceList.clear();
                              controller.dynamicFieldControllers.clear();
                            },
                            onValueSelected: (value) async {
                              controller.amountController.clear();
                              controller.amountText.value = "";
                              controller.serviceController.clear();
                              controller.serviceData.value = null;
                              controller.payBillServiceList.clear();
                              controller.dynamicFieldControllers.clear();
                              await controller.fetchPayBillServices();
                            },
                            selectedValue: controller
                                .billCountriesModel
                                .value
                                .data!
                                .map((item) => item)
                                .toList(),
                            dropdownItems: controller
                                .billCountriesModel
                                .value
                                .data!
                                .map((item) => item)
                                .toList(),
                            selectedItem: controller.countryController.text,
                            textController: controller.countryController,
                            bottomSheetHeight: 400.h,
                            currentlySelectedValue:
                                controller.countryController.text,
                            notFoundText:
                                localization.dataBundleCountryNotFound,
                          ),
                        );
                      },
                      hintText: localization.dataBundleCountryHint,
                      controller: controller.countryController,
                      suffixIconColor: AppColors.lightTextTertiary,
                      readOnly: true,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                CommonRequiredLabelAndDynamicField(
                  labelText: localization.dataBundleServiceLabel,
                  isLabelRequired: true,
                  dynamicField: Obx(
                    () => CommonTextInputField(
                      suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                      focusNode: controller.serviceFocusNode,
                      isFocused: controller.isServiceFocused.value,
                      backgroundColor: AppColors.lightBackground,
                      onTap: () {
                        Get.bottomSheet(
                          CommonDropdownBottomSheetThree<PayBillServiceData>(
                            items: controller.payBillServiceList,
                            selectedItem: controller.serviceData.value,
                            bottomSheetHeight: 400.h,
                            isShowTitle: true,
                            title: localization.dataBundleServiceSelectTitle,
                            notFoundText:
                                localization.dataBundleServiceNotFound,
                            getDisplayText: (service) => service.name ?? "",
                            areItemsEqual: (s1, s2) => s1.id == s2.id,
                            onItemSelected: (selectedService) {
                              controller.amountController.clear();
                              controller.amountText.value = "";
                              controller.serviceData.value = selectedService;
                              controller.serviceController.text =
                                  selectedService.name ?? "";
                              controller.setupDynamicFields(
                                selectedService.fields,
                              );
                            },
                            onItemUnSelected: () {
                              controller.amountController.clear();
                              controller.amountText.value = "";
                              controller.serviceData.value = null;
                              controller.serviceController.clear();
                              controller.dynamicFieldControllers.clear();
                            },
                          ),
                        );
                      },
                      hintText: localization.dataBundleServiceHint,
                      controller: controller.serviceController,
                      suffixIconColor: AppColors.lightTextTertiary,
                      readOnly: true,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    final service = controller.serviceData.value;
                    if (service != null &&
                        service.amount != null &&
                        service.amount! > 0) {
                      controller.amountController.text = service.amount!
                          .toInt()
                          .toString();
                      controller.amountText.value =
                          controller.amountController.text;
                    }
                  });
                  final service = controller.serviceData.value;
                  final currency = service?.currency ?? "";
                  final bool isPredefinedAmount =
                      service?.amount != null && service!.amount! > 0;
                  return CommonRequiredLabelAndDynamicField(
                    labelText: localization.dataBundleAmountLabel,
                    isLabelRequired: true,
                    dynamicField: CommonTextInputField(
                      onChanged: (value) {
                        controller.amountText.value =
                            controller.amountController.text;
                      },
                      readOnly: isPredefinedAmount,
                      keyboardType: TextInputType.number,
                      focusNode: controller.amountFocusNode,
                      isFocused: controller.isAmountFocused.value,
                      backgroundColor: AppColors.lightBackground,
                      hintText: "",
                      controller: controller.amountController,
                      isSuffixIconCompact: false,
                      suffixIcon: Center(
                        child: Text(
                          currency,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: AppColors.lightTextPrimary.withValues(
                              alpha: 0.40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: 16.h),
                Obx(() {
                  if (controller.dynamicFieldControllers.isNotEmpty) {
                    return Column(
                      children: controller.dynamicFieldControllers.entries.map((
                        entry,
                      ) {
                        return CommonRequiredLabelAndDynamicField(
                          labelText: entry.key,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.dynamicFieldsFocusNode,
                              isFocused: controller.isDynamicFieldFocused.value,
                              backgroundColor: AppColors.lightBackground,
                              controller: entry.value,
                              hintText: "",
                              keyboardType: TextInputType.text,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return SizedBox.shrink();
                  }
                }),
                SizedBox(height: 30.h),
                CommonButton(
                  text: localization.dataBundlePayButton,
                  onPressed: () {
                    controller.nextStepWithValidation();
                  },
                ),
                SizedBox(height: 30.h),
              ],
            ),
          );
        }),
      ),
    );
  }
}
