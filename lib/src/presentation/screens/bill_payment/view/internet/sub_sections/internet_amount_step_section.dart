import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet_three.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/controller/internet_controller.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/model/pay_bill_service_model.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/widgets/contact_picker_bottom_sheet.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/widgets/operator_selector_widget.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/widgets/quick_amount_selector_widget.dart';

class InternetAmountStepSection extends StatelessWidget {
  const InternetAmountStepSection({super.key});

  @override
  Widget build(BuildContext context) {
    final InternetController controller = Get.find();
    final localization = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final containerBg = isDark ? AppColors.darkSurface : AppColors.white;
    final inputBg = isDark ? AppColors.darkSurfaceVariant : AppColors.lightBackground;

    return Expanded(
      child: Container(
        margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.only(
            topStart: Radius.circular(30.r),
            topEnd: Radius.circular(30.r),
          ),
          color: containerBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.06),
              spreadRadius: 0,
              blurRadius: 35,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CommonLoading();
          }
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),

                // 1. Internet Provider / Operator Selector
                Obx(
                  () => OperatorSelectorWidget(
                    title: 'انتخاب ارائه‌دهنده اینترنت / Provider',
                    selectedOperatorId: controller.selectedOperatorId.value,
                    onOperatorSelected: (op) {
                      controller.selectedOperatorId.value = op.id;
                      controller.selectedOperatorName.value = op.nameFa;

                      final match = controller.payBillServiceList.firstWhereOrNull((s) {
                        final name = (s.name ?? '').toLowerCase();
                        return name.contains(op.id) ||
                            name.contains(op.nameFa) ||
                            name.contains(op.nameEn.toLowerCase());
                      });

                      if (match != null) {
                        controller.amountController.clear();
                        controller.amountText.value = '';
                        controller.serviceData.value = match;
                        controller.serviceController.text = match.name ?? '';
                        controller.setupDynamicFields(match.fields);
                      }
                    },
                  ),
                ),

                SizedBox(height: 18.h),

                // 2. Country Selection
                CommonRequiredLabelAndDynamicField(
                  labelText: localization!.internetCountryLabel,
                  isLabelRequired: true,
                  dynamicField: Obx(
                    () => CommonTextInputField(
                      suffixIcon: Image.asset(
                        PngAssets.arrowDownCommonIcon,
                        color: isDark ? AppColors.darkTextSecondary : null,
                      ),
                      focusNode: controller.countryFocusNode,
                      isFocused: controller.isCountryFocused.value,
                      backgroundColor: inputBg,
                      onTap: () {
                        Get.bottomSheet(
                          CommonDropdownBottomSheet(
                            isShowTitle: true,
                            title: localization.internetCountrySelectTitle,
                            isUnselectedValue: true,
                            onValueUnSelected: () {
                              controller.amountController.clear();
                              controller.amountText.value = '';
                              controller.serviceController.clear();
                              controller.serviceData.value = null;
                              controller.payBillServiceList.clear();
                              controller.dynamicFieldControllers.clear();
                            },
                            onValueSelected: (value) async {
                              controller.amountController.clear();
                              controller.amountText.value = '';
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
                            notFoundText: localization.internetCountryNotFound,
                          ),
                        );
                      },
                      hintText: localization.internetCountryHint,
                      controller: controller.countryController,
                      suffixIconColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                      readOnly: true,
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // 3. Service / Package Selection
                CommonRequiredLabelAndDynamicField(
                  labelText: localization.internetServiceLabel,
                  isLabelRequired: true,
                  dynamicField: Obx(
                    () => CommonTextInputField(
                      suffixIcon: Image.asset(
                        PngAssets.arrowDownCommonIcon,
                        color: isDark ? AppColors.darkTextSecondary : null,
                      ),
                      focusNode: controller.serviceFocusNode,
                      isFocused: controller.isServiceFocused.value,
                      backgroundColor: inputBg,
                      onTap: () {
                        Get.bottomSheet(
                          CommonDropdownBottomSheetThree<PayBillServiceData>(
                            items: controller.payBillServiceList,
                            selectedItem: controller.serviceData.value,
                            bottomSheetHeight: 400.h,
                            isShowTitle: true,
                            title: localization.internetServiceSelectTitle,
                            notFoundText: localization.internetServiceNotFound,
                            getDisplayText: (service) => service.name ?? '',
                            areItemsEqual: (s1, s2) => s1.id == s2.id,
                            onItemSelected: (selectedService) {
                              controller.amountController.clear();
                              controller.amountText.value = '';
                              controller.serviceData.value = selectedService;
                              controller.serviceController.text =
                                  selectedService.name ?? '';
                              controller.setupDynamicFields(
                                selectedService.fields,
                              );
                            },
                            onItemUnSelected: () {
                              controller.amountController.clear();
                              controller.amountText.value = '';
                              controller.serviceData.value = null;
                              controller.serviceController.clear();
                              controller.dynamicFieldControllers.clear();
                            },
                          ),
                        );
                      },
                      hintText: localization.internetServiceHint,
                      controller: controller.serviceController,
                      suffixIconColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary,
                      readOnly: true,
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // 4. Dynamic Fields (with Contact / Number Picker)
                Obx(() {
                  if (controller.dynamicFieldControllers.isNotEmpty) {
                    return Column(
                      children: controller.dynamicFieldControllers.entries.map((
                        entry,
                      ) {
                        final isPhoneField = entry.key.toLowerCase().contains('phone') ||
                            entry.key.toLowerCase().contains('mobile') ||
                            entry.key.contains('موبایل') ||
                            entry.key.contains('شماره') ||
                            controller.dynamicFieldControllers.keys.first == entry.key;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 14.h),
                          child: CommonRequiredLabelAndDynamicField(
                            labelText: entry.key,
                            isLabelRequired: true,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                focusNode: controller.dynamicFieldsFocusNode,
                                isFocused: controller.isDynamicFieldFocused.value,
                                backgroundColor: inputBg,
                                controller: entry.value,
                                hintText: '',
                                keyboardType: isPhoneField ? TextInputType.phone : TextInputType.text,
                                onChanged: (val) {
                                  controller.targetAccountNumber.value = val;
                                },
                                suffixIcon: isPhoneField
                                    ? GestureDetector(
                                        onTap: () {
                                          ContactPickerBottomSheet.show(
                                            context,
                                            onContactSelected: (name, phone, opId) {
                                              entry.value.text = phone;
                                              controller.targetAccountNumber.value = phone;
                                            },
                                          );
                                        },
                                        child: Container(
                                          margin: EdgeInsets.all(8.w),
                                          padding: EdgeInsets.all(6.w),
                                          decoration: BoxDecoration(
                                            color: (isDark ? AppColors.mainSoftBlue : AppColors.deepBlack)
                                                .withValues(alpha: 0.12),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.contacts_rounded,
                                            size: 18.w,
                                            color: isDark ? AppColors.mainSoftBlue : AppColors.deepBlack,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                }),

                // 5. Quick Amount Selector
                Obx(
                  () => QuickAmountSelectorWidget(
                    selectedAmount: controller.amountText.value,
                    onAmountSelected: (amountToman, amountRials) {
                      final service = controller.serviceData.value;
                      final isCurrencyRials = service?.currency?.toLowerCase().contains('rial') ?? false;

                      final targetAmount = isCurrencyRials ? amountRials : amountToman;
                      controller.amountController.text = targetAmount.toString();
                      controller.amountText.value = targetAmount.toString();
                    },
                  ),
                ),

                SizedBox(height: 14.h),

                // 6. Custom Amount
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
                  final currency = service?.currency ?? 'تومان';
                  final bool isPredefinedAmount =
                      service?.amount != null && service!.amount! > 0;
                  return CommonRequiredLabelAndDynamicField(
                    labelText: localization.internetAmountLabel,
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
                      backgroundColor: inputBg,
                      hintText: '',
                      controller: controller.amountController,
                      isSuffixIconCompact: false,
                      suffixIcon: Center(
                        child: Text(
                          currency,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.sp,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextPrimary.withValues(alpha: 0.50),
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                SizedBox(height: 26.h),

                // 7. Pay Button
                CommonButton(
                  text: localization.internetPayButton,
                  onPressed: () {
                    if (controller.targetAccountNumber.value.isEmpty &&
                        controller.dynamicFieldControllers.isNotEmpty) {
                      controller.targetAccountNumber.value =
                          controller.dynamicFieldControllers.values.first.text;
                    }
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
