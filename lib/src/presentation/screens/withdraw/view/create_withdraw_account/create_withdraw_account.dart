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
import 'package:qunzo_user/src/common/widgets/dropdown_bottom_sheet/common_dropdown_wallet_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/create_withdraw_account_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_method_model.dart';

class CreateWithdrawAccount extends StatefulWidget {
  const CreateWithdrawAccount({super.key});

  @override
  State<CreateWithdrawAccount> createState() => _CreateWithdrawAccountState();
}

class _CreateWithdrawAccountState extends State<CreateWithdrawAccount> {
  final CreateWithdrawAccountController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.clearFields();
    controller.fetchWallets();
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Stack(
      children: [
        Obx(() {
          if (controller.isLoading.value) {
            return const CommonLoading();
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localization.createWithdrawAccountTitle,
                  style: TextStyle(
                    letterSpacing: 0,
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 16),
                Expanded(
                  child: Container(
                    padding: EdgeInsetsDirectional.only(
                      start: 18,
                      end: 18,
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
                        children: [
                          SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization.createWithdrawAccountWallet,
                            isLabelRequired: true,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                suffixIcon: Obx(
                                  () => Image(
                                    image: const AssetImage(
                                      PngAssets.arrowDownCommonIcon,
                                    ),
                                    color: controller.isWalletFocused.value
                                        ? AppColors.lightPrimary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                                focusNode: controller.walletFocusNode,
                                isFocused: controller.isWalletFocused.value,
                                backgroundColor: AppColors.transparent,
                                onTap: () {
                                  Get.bottomSheet(
                                    CommonDropdownWalletBottomSheet(
                                      notFoundText: localization
                                          .createWithdrawAccountWalletsNotFound,
                                      dropdownItems: controller.walletsList,
                                      bottomSheetHeight: 450,
                                      currentlySelectedValue:
                                          controller.walletController.text,
                                      onItemSelected: (value) async {
                                        final selectedWallet = controller
                                            .walletsList
                                            .firstWhere((w) => w.name == value);
                                        controller.walletController.text =
                                            selectedWallet.name ?? "";
                                        controller.wallet.value =
                                            selectedWallet;
                                        await controller.fetchWithdrawMethods();
                                        controller.withdrawMethod.value =
                                            WithdrawMethodData();
                                        controller.withdrawMethodController
                                            .clear();
                                        controller.methodNameController.clear();
                                        controller.methodName.value = "";
                                        controller.dynamicFieldControllers
                                            .clear();
                                        controller.selectedImages.clear();
                                      },
                                    ),
                                  );
                                },
                                hintText: "",
                                controller: controller.walletController,
                                suffixIconColor: AppColors.lightTextTertiary,
                                readOnly: true,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          CommonRequiredLabelAndDynamicField(
                            labelText: localization
                                .createWithdrawAccountWithdrawMethod,
                            isLabelRequired: true,
                            dynamicField: Obx(
                              () => CommonTextInputField(
                                isFocused:
                                    controller.isWithdrawMethodFocused.value,
                                focusNode: controller.withdrawMethodFocusNode,
                                backgroundColor: AppColors.transparent,
                                suffixIcon: Obx(
                                  () => Image(
                                    image: const AssetImage(
                                      PngAssets.arrowDownCommonIcon,
                                    ),
                                    color:
                                        controller.isWithdrawMethodFocused.value
                                        ? AppColors.lightPrimary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                                onTap: () {
                                  Get.bottomSheet(
                                    CommonDropdownBottomSheet(
                                      title: localization
                                          .createWithdrawAccountWithdrawMethodTitle,
                                      isShowTitle: true,
                                      notFoundText: localization
                                          .createWithdrawAccountWithdrawMethodNotFound,
                                      dropdownItems: controller
                                          .withdrawMethodList
                                          .map((e) => e.name ?? '')
                                          .toList(),
                                      selectedValue: controller
                                          .withdrawMethodList
                                          .map((e) => e.name ?? '')
                                          .toList(),
                                      isUnselectedValue: true,
                                      selectedItem: controller
                                          .withdrawMethodController
                                          .text,
                                      currentlySelectedValue: controller
                                          .withdrawMethodController
                                          .text,
                                      textController:
                                          controller.withdrawMethodController,
                                      bottomSheetHeight: 400,
                                      onValueSelected: (value) {
                                        int index = controller
                                            .withdrawMethodList
                                            .indexWhere((e) => e.name == value);
                                        if (index != -1) {
                                          final selected = controller
                                              .withdrawMethodList[index];
                                          controller.withdrawMethod.value =
                                              selected;
                                          controller
                                                  .withdrawMethodController
                                                  .text =
                                              selected.name ?? '';
                                          controller.methodNameController.text =
                                              "${selected.name}-${selected.currency}";
                                          controller.methodName.value =
                                              "${selected.name}-${selected.currency}";
                                          controller.dynamicFieldControllers
                                              .clear();
                                          if (selected.fields != null) {
                                            for (var field
                                                in selected.fields!) {
                                              controller
                                                  .dynamicFieldControllers[field
                                                      .name ??
                                                  ''] = {
                                                'controller':
                                                    TextEditingController(),
                                                'validation':
                                                    field.validation ??
                                                    'nullable',
                                                'type': field.type ?? 'text',
                                              };
                                            }
                                          }
                                        }
                                      },
                                      onValueUnSelected: () {
                                        controller.withdrawMethod.value =
                                            WithdrawMethodData();
                                        controller.withdrawMethodController
                                            .clear();
                                        controller.dynamicFieldControllers
                                            .clear();
                                        controller.methodNameController.clear();
                                        controller.methodName.value = "";
                                        controller.selectedImages.clear();
                                      },
                                    ),
                                  );
                                },
                                hintText: "",
                                controller: controller.withdrawMethodController,
                                suffixIconColor: AppColors.lightTextTertiary,
                                readOnly: true,
                              ),
                            ),
                          ),

                          Obx(() {
                            return Visibility(
                              visible:
                                  controller.methodName.value.isNotEmpty &&
                                  controller
                                      .methodNameController
                                      .text
                                      .isNotEmpty,
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  CommonRequiredLabelAndDynamicField(
                                    labelText: localization
                                        .createWithdrawAccountMethodName,
                                    isLabelRequired: true,
                                    dynamicField: Obx(
                                      () => CommonTextInputField(
                                        focusNode:
                                            controller.methodNameFocusNode,
                                        isFocused: controller
                                            .isMethodNameFocused
                                            .value,
                                        backgroundColor: AppColors.transparent,
                                        controller:
                                            controller.methodNameController,
                                        hintText: "",
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                                ...controller.dynamicFieldControllers.entries.map((
                                  entry,
                                ) {
                                  final fieldName = entry.key;
                                  final fieldData = entry.value;

                                  final controller =
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
                                                    ? localization
                                                          .createWithdrawAccountFieldHint
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
                          const SizedBox(height: 40),
                          CommonButton(
                            onPressed: () => controller.createWithdrawAccount(),
                            width: double.infinity,

                            text:
                                localization.createWithdrawAccountCreateButton,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        Obx(() {
          return Visibility(
            visible:
                controller.isWithdrawMethodsLoading.value ||
                controller.isCreateWithdrawAccountLoading.value,
            child: const CommonLoading(),
          );
        }),
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
