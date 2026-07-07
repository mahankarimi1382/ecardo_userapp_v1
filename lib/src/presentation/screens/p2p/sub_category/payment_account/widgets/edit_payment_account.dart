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
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/edit_payment_account_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';

class EditPaymentAccount extends StatefulWidget {
  final PaymentAccount account;

  const EditPaymentAccount({super.key, required this.account});

  @override
  State<EditPaymentAccount> createState() => _EditPaymentAccountState();
}

class _EditPaymentAccountState extends State<EditPaymentAccount> {
  final EditPaymentAccountController controller = Get.put(
    EditPaymentAccountController(),
  );
  final PaymentAccountController paymentAccountController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.dynamicFieldControllers.clear();
      controller.selectedImages.clear();
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
                localization.p2pEditPaymentAccount,
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
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),
                              ...controller.dynamicFieldControllers.entries.map(
                                (entry) {
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
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        CommonButton(
                          onPressed: () => controller.updatePaymentAccount(
                            accountId: widget.account.id.toString(),
                          ),
                          width: double.infinity,
                          text: localization.p2pUpdateAccount,
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: paymentAccountController.onCancelEdit,
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
            visible: controller.isLoading.value,
            child: const CommonLoading(),
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
          height: 120,
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
              : hasExistingValue
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    existingValue,
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
                      return const CommonLoading();
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
