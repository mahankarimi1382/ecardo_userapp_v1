import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:qunzo_user/src/presentation/screens/settings/controller/change_password_controller.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final ChangePasswordController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16),
              CommonAppBar(title: localization.changePasswordScreenTitle),
              SizedBox(height: 30),
              Expanded(
                child: Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
                  padding: EdgeInsetsDirectional.only(
                    start: 20,
                    end: 20,
                    bottom: 24,
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
                          labelText: localization.changePasswordCurrentPassword,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.currentPasswordFocusNode,
                              controller: controller.currentPasswordController,
                              backgroundColor: AppColors.transparent,
                              keyboardType: TextInputType.text,
                              hintText: "",
                              obscureText:
                                  controller.isCurrentPasswordVisible.value,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  controller.isCurrentPasswordFocused.value =
                                      true;
                                } else {
                                  controller.isCurrentPasswordFocused.value =
                                      false;
                                }
                              },
                              isFocused:
                                  controller.isCurrentPasswordFocused.value,
                              isSuffixIconOnTap: true,
                              suffixIconOnTap: () {
                                controller.isCurrentPasswordVisible.value =
                                    !controller.isCurrentPasswordVisible.value;
                              },
                              suffixIconWidth: 25,
                              suffixIconHeight: 25,
                              suffixIcon: Image(
                                image: AssetImage(
                                  controller.isCurrentPasswordVisible.value
                                      ? PngAssets.eyeCommonIcon
                                      : PngAssets.eyeHideCommonIcon,
                                ),
                                color: controller.isCurrentPasswordFocused.value
                                    ? AppColors.lightPrimary
                                    : AppColors.lightTextPrimary.withValues(
                                        alpha: 0.44,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localization.changePasswordNewPassword,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.newPasswordFocusNode,
                              controller: controller.newPasswordController,
                              backgroundColor: AppColors.transparent,
                              keyboardType: TextInputType.text,
                              hintText: "",
                              obscureText:
                                  controller.isNewPasswordVisible.value,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  controller.isNewPasswordFocused.value = true;
                                } else {
                                  controller.isNewPasswordFocused.value = false;
                                }
                              },
                              isFocused: controller.isNewPasswordFocused.value,
                              isSuffixIconOnTap: true,
                              suffixIconOnTap: () {
                                controller.isNewPasswordVisible.value =
                                    !controller.isNewPasswordVisible.value;
                              },
                              suffixIconWidth: 25,
                              suffixIconHeight: 25,
                              suffixIcon: Image(
                                image: AssetImage(
                                  controller.isNewPasswordVisible.value
                                      ? PngAssets.eyeCommonIcon
                                      : PngAssets.eyeHideCommonIcon,
                                ),
                                color: controller.isNewPasswordFocused.value
                                    ? AppColors.lightPrimary
                                    : AppColors.lightTextPrimary.withValues(
                                        alpha: 0.44,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        CommonRequiredLabelAndDynamicField(
                          labelText: localization.changePasswordConfirmPassword,
                          isLabelRequired: true,
                          dynamicField: Obx(
                            () => CommonTextInputField(
                              focusNode: controller.confirmPasswordFocusNode,
                              controller: controller.confirmPasswordController,
                              backgroundColor: AppColors.transparent,
                              keyboardType: TextInputType.text,
                              hintText: "",
                              obscureText:
                                  controller.isConfirmPasswordVisible.value,
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  controller.isConfirmPasswordFocused.value =
                                      true;
                                } else {
                                  controller.isConfirmPasswordFocused.value =
                                      false;
                                }
                              },
                              isFocused:
                                  controller.isConfirmPasswordFocused.value,

                              isSuffixIconOnTap: true,
                              suffixIconOnTap: () {
                                controller.isConfirmPasswordVisible.value =
                                    !controller.isConfirmPasswordVisible.value;
                              },
                              suffixIconWidth: 25,
                              suffixIconHeight: 25,
                              suffixIcon: Image(
                                image: AssetImage(
                                  controller.isConfirmPasswordVisible.value
                                      ? PngAssets.eyeCommonIcon
                                      : PngAssets.eyeHideCommonIcon,
                                ),
                                color: controller.isConfirmPasswordFocused.value
                                    ? AppColors.lightPrimary
                                    : AppColors.lightTextPrimary.withValues(
                                        alpha: 0.44,
                                      ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40),
                        CommonButton(
                          onPressed: () async {
                            if (!controller.validatePassword()) {
                              return;
                            }

                            await controller.changePassword();
                          },
                          width: double.infinity,

                          text: localization.changePasswordSaveChangesButton,
                        ),
                        SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Obx(
            () => Visibility(
              visible: controller.isLoading.value,
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
