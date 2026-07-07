import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/edit_withdraw_account_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class EditWithdrawAccount extends StatefulWidget {
  final Accounts account;

  const EditWithdrawAccount({super.key, required this.account});

  @override
  State<EditWithdrawAccount> createState() => _EditWithdrawAccountState();
}

class _EditWithdrawAccountState extends State<EditWithdrawAccount> {
  final EditWithdrawAccountController controller = Get.put(
    EditWithdrawAccountController(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.methodNameController.clear();
      controller.dynamicFieldControllers.clear();
      controller.selectedImages.clear();
      controller.isMethodNameFocused.value = false;
      controller.initializeFields(widget.account);
    });
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
                localization.editWithdrawAccountTitle,
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
                          labelText: localization.editWithdrawAccountMethodName,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.methodNameFocusNode,
                              isFocused: controller.isMethodNameFocused.value,
                              controller: controller.methodNameController,
                              hintText: localization
                                  .editWithdrawAccountMethodNameHint,
                              backgroundColor: AppColors.transparent,
                            ),
                          ),
                        ),
                        Obx(
                          () => Column(
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
                                final existingValue =
                                    fieldData['value'] as String;

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
                                              existingValue: existingValue,
                                            )
                                          : CommonTextInputField(
                                              backgroundColor:
                                                  AppColors.transparent,
                                              hintText: isTextArea
                                                  ? localization
                                                        .editWithdrawAccountFieldHint
                                                  : '${localization.editWithdrawAccountGenericFieldHint} $fieldName',
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
                          ),
                        ),
                        SizedBox(height: 40),
                        CommonButton(
                          onPressed: () => controller.updateWithdrawAccount(
                            accountId: widget.account.id.toString(),
                          ),
                          width: double.infinity,

                          text: localization.editWithdrawAccountUpdateButton,
                        ),
                        SizedBox(height: 40),
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
            visible: controller.isLoading.value,
            child: CommonLoading(),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection({
    required String title,
    required String fieldName,
    String? existingValue,
  }) {
    return Obx(() {
      final selectedImage = controller.selectedImages[fieldName];
      final hasExistingValue =
          existingValue != null &&
          existingValue.isNotEmpty &&
          existingValue.toLowerCase() != 'null';
      return GestureDetector(
        onTap: () {
          controller.pickImage(fieldName, image_picker.ImageSource.gallery);
        },
        child: Container(
          width: double.infinity,
          height: selectedImage != null || hasExistingValue == true ? 120 : 120,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    selectedImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : hasExistingValue == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    existingValue!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: AppColors.lightTextTertiary,
                      ),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return CommonLoading();
                    },
                  ),
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
