import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart' as image_picker;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/edit_withdraw_account_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class EditWithdrawAccount extends StatefulWidget {
  final Accounts account;

  const EditWithdrawAccount({super.key, required this.account});

  @override
  State<EditWithdrawAccount> createState() => _EditWithdrawAccountState();
}

class _EditWithdrawAccountState extends State<EditWithdrawAccount> {
  final EditWithdrawAccountController controller = Get.find();

  @override
  void initState() {
    super.initState();
    controller.initializeFields(widget.account);
  }

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localization.editWithdrawAccountTitle,
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Container(
                  padding: const EdgeInsetsDirectional.only(
                    start: AppSpacing.page,
                    end: AppSpacing.page,
                    top: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(AppSpacing.radiusXl),
                      topEnd: Radius.circular(AppSpacing.radiusXl),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? AppColors.darkShadow
                            : AppColors.lightShadow,
                        blurRadius: AppSpacing.lg,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
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
                              borderRadius: AppSpacing.radiusLg,
                              backgroundColor: AppColors.transparent,
                            ),
                          ),
                        ),
                        Obx(
                          () => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.lg),
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
                                              isDark: isDark,
                                            )
                                          : CommonTextInputField(
                                              borderRadius:
                                                  AppSpacing.radiusLg,
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
                                    const SizedBox(height: AppSpacing.lg),
                                  ],
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxxl),
                        CommonButton(
                          borderRadius: AppSpacing.radiusLg,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            controller.updateWithdrawAccount(
                              accountId: widget.account.id.toString(),
                            );
                          },
                          width: double.infinity,
                          text: localization.editWithdrawAccountUpdateButton,
                        ),
                        const SizedBox(height: AppSpacing.huge),
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
    required bool isDark,
  }) {
    return Obx(() {
      final selectedImage = controller.selectedImages[fieldName];
      final hasExistingValue =
          existingValue != null &&
          existingValue.isNotEmpty &&
          existingValue.toLowerCase() != 'null';
      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          controller.pickImage(fieldName, image_picker.ImageSource.gallery);
        },
        child: Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: selectedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.file(
                    selectedImage,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                )
              : hasExistingValue == true
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  child: Image.network(
                    existingValue!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 40,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xl,
                    horizontal: AppSpacing.lg,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightBackground,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        PngAssets.commonUploadIcon,
                        width: AppSpacing.iconMd,
                        fit: BoxFit.contain,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        title,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
    });
  }
}
