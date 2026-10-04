import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/app_spacing.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_text_input_filed.dart';
import 'package:ecardo_user/src/presentation/screens/settings/controller/change_password_controller.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.white;
    final primaryTextColor = isDark ? AppColors.warmWhite : AppColors.deepBlack;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: AppSpacing.cardGap),
              CommonAppBar(title: localization.changePasswordScreenTitle),
              SizedBox(height: AppSpacing.lg),
              Expanded(
                child: Container(
                  margin: const EdgeInsetsDirectional.symmetric(horizontal: 16),
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadiusDirectional.only(
                      topStart: Radius.circular(24),
                      topEnd: Radius.circular(24),
                    ),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: AppSpacing.md),
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
                              textStyle: AppTextStyles.bodyMedium.copyWith(
                                color: primaryTextColor,
                              ),
                              obscureText:
                                  controller.isCurrentPasswordVisible.value,
                              onChanged: (value) {
                                controller.isCurrentPasswordFocused.value =
                                    value.isNotEmpty;
                              },
                              isFocused:
                                  controller.isCurrentPasswordFocused.value,
                              isSuffixIconOnTap: true,
                              suffixIconOnTap: () {
                                HapticFeedback.lightImpact();
                                controller.isCurrentPasswordVisible.value =
                                    !controller.isCurrentPasswordVisible.value;
                              },
                              suffixIconWidth: 24,
                              suffixIconHeight: 24,
                              suffixIcon: Image(
                                image: AssetImage(
                                  controller.isCurrentPasswordVisible.value
                                      ? PngAssets.eyeCommonIcon
                                      : PngAssets.eyeHideCommonIcon,
                                ),
                                color: controller.isCurrentPasswordFocused.value
                                    ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                                    : (isDark
                                        ? AppColors.softGray
                                        : AppColors.lightTextPrimary.withValues(alpha: 0.44)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
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
                              textStyle: AppTextStyles.bodyMedium.copyWith(
                                color: primaryTextColor,
                              ),
                              obscureText:
                                  controller.isNewPasswordVisible.value,
                              onChanged: (value) {
                                controller.isNewPasswordFocused.value =
                                    value.isNotEmpty;
                              },
                              isFocused: controller.isNewPasswordFocused.value,
                              isSuffixIconOnTap: true,
                              suffixIconOnTap: () {
                                HapticFeedback.lightImpact();
                                controller.isNewPasswordVisible.value =
                                    !controller.isNewPasswordVisible.value;
                              },
                              suffixIconWidth: 24,
                              suffixIconHeight: 24,
                              suffixIcon: Image(
                                image: AssetImage(
                                  controller.isNewPasswordVisible.value
                                      ? PngAssets.eyeCommonIcon
                                      : PngAssets.eyeHideCommonIcon,
                                ),
                                color: controller.isNewPasswordFocused.value
                                    ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                                    : (isDark
                                        ? AppColors.softGray
                                        : AppColors.lightTextPrimary.withValues(alpha: 0.44)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.lg),
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
                              textStyle: AppTextStyles.bodyMedium.copyWith(
                                color: primaryTextColor,
                              ),
                              obscureText:
                                  controller.isConfirmPasswordVisible.value,
                              onChanged: (value) {
                                controller.isConfirmPasswordFocused.value =
                                    value.isNotEmpty;
                              },
                              isFocused:
                                  controller.isConfirmPasswordFocused.value,
                              isSuffixIconOnTap: true,
                              suffixIconOnTap: () {
                                HapticFeedback.lightImpact();
                                controller.isConfirmPasswordVisible.value =
                                    !controller.isConfirmPasswordVisible.value;
                              },
                              suffixIconWidth: 24,
                              suffixIconHeight: 24,
                              suffixIcon: Image(
                                image: AssetImage(
                                  controller.isConfirmPasswordVisible.value
                                      ? PngAssets.eyeCommonIcon
                                      : PngAssets.eyeHideCommonIcon,
                                ),
                                color: controller.isConfirmPasswordFocused.value
                                    ? (isDark ? AppColors.mainSoftBlue : AppColors.lightPrimary)
                                    : (isDark
                                        ? AppColors.softGray
                                        : AppColors.lightTextPrimary.withValues(alpha: 0.44)),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxl),
                        CommonButton(
                          onPressed: () async {
                            HapticFeedback.mediumImpact();
                            if (!controller.validatePassword()) {
                              return;
                            }
                            await controller.changePassword();
                          },
                          width: double.infinity,
                          text: localization.changePasswordSaveChangesButton,
                        ),
                        SizedBox(height: AppSpacing.bottomSafe(context, 30)),
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
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
