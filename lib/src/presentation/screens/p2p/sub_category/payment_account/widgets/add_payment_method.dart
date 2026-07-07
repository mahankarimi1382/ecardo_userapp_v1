import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/add_payment_method_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';

class AddPaymentMethod extends StatefulWidget {
  const AddPaymentMethod({super.key});

  @override
  State<AddPaymentMethod> createState() => _AddPaymentMethodState();
}

class _AddPaymentMethodState extends State<AddPaymentMethod> {
  final AddPaymentMethodController controller = Get.put(
    AddPaymentMethodController(),
  );
  final PaymentAccountController paymentAccountController = Get.find();

  @override
  void initState() {
    super.initState();
    controller.clearFields();
    controller.fetchPaymentMethods();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.p2pAddPaymentMethod,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: 18,
                    end: 18,
                    top: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localization.p2pPaymentMethod,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.paymentMethodFocusNode,
                              isFocused:
                                  controller.isPaymentMethodFocused.value,
                              controller: controller.paymentMethodController,
                              hintText: '',
                              readOnly: true,
                              backgroundColor: AppColors.transparent,
                              suffixIcon: Image(
                                image: const AssetImage(
                                  PngAssets.arrowDownCommonIcon,
                                ),
                                color: controller.isPaymentMethodFocused.value
                                    ? AppColors.lightPrimary
                                    : AppColors.lightTextTertiary,
                              ),
                              onTap: () {
                                Get.bottomSheet(
                                  CommonDropdownBottomSheet(
                                    title: localization.p2pSelectPaymentMethod,
                                    isShowTitle: true,
                                    notFoundText:
                                        localization.p2pNoPaymentMethodFound,
                                    dropdownItems: controller.paymentMethodList
                                        .map((e) => e.name ?? '')
                                        .toList(),
                                    selectedValue: controller.paymentMethodList
                                        .map((e) => e.name ?? '')
                                        .toList(),
                                    selectedItem:
                                        controller.paymentMethodController.text,
                                    currentlySelectedValue:
                                        controller.paymentMethodController.text,
                                    textController:
                                        controller.paymentMethodController,
                                    bottomSheetHeight: 420,
                                    onValueSelected: (value) {
                                      final selectedIndex = controller
                                          .paymentMethodList
                                          .indexWhere((e) => e.name == value);
                                      if (selectedIndex != -1) {
                                        controller.onPaymentMethodSelected(
                                          controller
                                              .paymentMethodList[selectedIndex],
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        Obx(() {
                          if (controller.dynamicFieldControllers.isEmpty) {
                            return const SizedBox.shrink();
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              ...controller.dynamicFieldControllers.entries.map((
                                entry,
                              ) {
                                final fieldName = entry.key;
                                final fieldData = entry.value;
                                final fieldController =
                                    fieldData['controller']
                                        as TextEditingController;
                                final validation =
                                    fieldData['validation'] as String;
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
                                              backgroundColor:
                                                  AppColors.transparent,
                                              hintText: isTextArea
                                                  ? 'Enter $fieldName'
                                                  : 'Enter $fieldName',
                                              controller: fieldController,
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
                        const SizedBox(height: 40),
                        CommonButton(
                          onPressed: controller.createPaymentAccount,
                          width: double.infinity,
                          text: localization.p2pSubmit,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: paymentAccountController.onCancelAdd,
                          child: Container(
                            width: double.infinity,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.error.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                localization.p2pCancel,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Visibility(
            visible:
                controller.isMethodsLoading.value ||
                controller.isSubmitLoading.value,
            child: const CommonLoading(),
          ),
        ),
      ],
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
