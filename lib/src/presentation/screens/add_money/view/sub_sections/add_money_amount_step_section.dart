import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/controller/add_money_controller.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/model/gateway_methods_model.dart';

class AddMoneyAmountStepSection extends StatefulWidget {
  const AddMoneyAmountStepSection({super.key});

  @override
  State<AddMoneyAmountStepSection> createState() =>
      _AddMoneyAmountStepSectionState();
}

class _AddMoneyAmountStepSectionState extends State<AddMoneyAmountStepSection> {
  final AddMoneyController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Expanded(
      child: Container(
        padding: EdgeInsetsDirectional.only(
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
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.addMoneyGateway,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.gatewayFocusNode,
                    isFocused: controller.isGatewayFocused.value,
                    suffixIcon: Image.asset(PngAssets.arrowDownCommonIcon),
                    borderRadius: 16,
                    backgroundColor: AppColors.transparent,
                    onTap: () {
                      Get.bottomSheet(
                        CommonDropdownBottomSheet(
                          isShowTitle: true,
                          title: localization.addMoneyGateway,
                          notFoundText: localization.addMoneyGatewayNotFound,
                          onValueSelected: (value) async {
                            int index = controller.gatewayMethodsList
                                .indexWhere(
                                  (item) => item.formattedName == value,
                                );

                            if (index != -1) {
                              final selectedGateway =
                                  controller.gatewayMethodsList[index];
                              controller.gatewayMethod.value = selectedGateway;
                              controller.gatewayController.text =
                                  selectedGateway.formattedName ?? "";
                              controller.dynamicFieldControllers.clear();
                              if (selectedGateway.fieldOptions != null) {
                                for (var field
                                    in selectedGateway.fieldOptions!) {
                                  controller.dynamicFieldControllers[field
                                          .name ??
                                      ''] = {
                                    'controller': TextEditingController(),
                                    'validation':
                                        field.validation ?? 'nullable',
                                    'type': field.type ?? 'text',
                                  };
                                }
                              }
                            }
                          },

                          selectedValue: controller.gatewayMethodsList
                              .map((item) => item.formattedName.toString())
                              .toList(),
                          dropdownItems: controller.gatewayMethodsList
                              .map((item) => item.formattedName.toString())
                              .toList(),
                          isUnselectedValue: true,
                          onValueUnSelected: () {
                            controller.gatewayMethod.value =
                                GatewayMethodsData();
                            controller.gatewayController.clear();
                            controller.dynamicFieldControllers.clear();
                            controller.selectedImages.clear();
                          },

                          selectedItem: controller.gatewayController.text,
                          textController: controller.gatewayController,
                          currentlySelectedValue:
                              controller.gatewayController.text,
                          bottomSheetHeight: 400,
                        ),
                      );
                    },
                    hintText: localization.addMoneySelectGateway,
                    controller: controller.gatewayController,
                    suffixIconColor: AppColors.lightTextTertiary,
                    readOnly: true,
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible:
                      controller.gatewayMethod.value?.formattedName != null &&
                      controller.gatewayMethod.value!.formattedName!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      "${localization.addMoneyCharge} ${double.tryParse(controller.gatewayMethod.value!.charge ?? '0')?.toStringAsFixed(controller.gatewayMethod.value!.currencyType != "crypto" ? 2 : controller.gatewayMethod.value!.currencyDecimals ?? 2) ?? '0.00'} ${controller.gatewayMethod.value!.chargeType == "percentage" ? "%" : controller.wallet.value?.code ?? ''}",
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              CommonRequiredLabelAndDynamicField(
                labelText: localization.addMoneyAmount,
                isLabelRequired: true,
                dynamicField: Obx(
                  () => CommonTextInputField(
                    focusNode: controller.amountFocusNode,
                    isFocused: controller.isAmountFocused.value,
                    isSuffixIconCompact: false,
                    suffixIcon: Center(
                      child: Text(
                        controller.wallet.value!.code!,
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
                    borderRadius: 16,
                    backgroundColor: AppColors.transparent,
                    hintText: "",
                    controller: controller.amountController,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible:
                      controller.gatewayMethod.value?.formattedName != null &&
                      controller.gatewayMethod.value!.formattedName!.isNotEmpty,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      "${localization.addMoneyMin} ${double.tryParse(controller.gatewayMethod.value!.minimumDeposit ?? '0')?.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals ?? 2) ?? '0.00'} ${controller.gatewayMethod.value!.currency} ${localization.addMoneyMax} ${double.tryParse(controller.gatewayMethod.value!.maximumDeposit ?? '0')?.toStringAsFixed(controller.gatewayMethod.value!.currencyDecimals ?? 2) ?? '0.00'} ${controller.gatewayMethod.value!.currency}",
                      style: TextStyle(
                        letterSpacing: 0,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),

              Obx(() {
                final gateway = controller.gatewayMethod.value;
                final hasInstructions =
                    gateway?.instructions?.isNotEmpty == true;

                if (!hasInstructions) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: AppColors.lightPrimary.withValues(alpha: 0.10),
                      ),
                      child: HtmlWidget(
                        gateway!.instructions!,
                        textStyle: const TextStyle(
                          letterSpacing: 0,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                );
              }),
              Obx(() {
                if (controller.dynamicFieldControllers.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    ...controller.dynamicFieldControllers.entries.map((entry) {
                      final fieldName = entry.key;
                      final fieldData = entry.value;

                      final controller =
                          fieldData['controller'] as TextEditingController;
                      final validation = fieldData['validation'] as String;
                      final type = fieldData['type'] as String;
                      final isRequired = validation == 'required';
                      final isTextArea = type == 'textarea';
                      final isFile = type == 'file';

                      return Column(
                        children: [
                          CommonRequiredLabelAndDynamicField(
                            labelText: fieldName,
                            isLabelRequired: isRequired,
                            dynamicField: isFile
                                ? _buildUploadSection(
                                    title: fieldName,
                                    fieldName: fieldName,
                                  )
                                : CommonTextInputField(
                                    borderRadius: 16,
                                    backgroundColor: AppColors.transparent,
                                    hintText: isTextArea
                                        ? localization.addMoneyWriteHere
                                        : '',
                                    controller: controller,
                                    maxLine: isTextArea ? 5 : 1,
                                    keyboardType: isTextArea
                                        ? TextInputType.multiline
                                        : TextInputType.text,
                                  ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    }),
                  ],
                );
              }),
              SizedBox(
                height: controller.dynamicFieldControllers.isEmpty ? 40 : 30,
              ),
              CommonButton(
                borderRadius: 16,
                width: double.infinity,
                text: localization.addMoneyAddMoneyButton,
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

  Widget _buildUploadSection({
    required String title,
    required String fieldName,
  }) {
    return Obx(() {
      final selectedImage = controller.selectedImages[fieldName];

      return GestureDetector(
        onTap: () {
          controller.pickImage(fieldName, image_picker.ImageSource.gallery);
        },
        child: SizedBox(
          width: double.infinity,
          height: selectedImage != null ? 120 : null,
          child: selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(selectedImage, fit: BoxFit.cover),
                )
              : Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      PngAssets.attachFileTwo,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          PngAssets.commonUploadIcon,
                          width: 20,
                          fit: BoxFit.contain,
                          color: AppColors.lightTextTertiary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          style: TextStyle(
                            letterSpacing: 0,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppColors.lightTextTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ),
      );
    });
  }
}
