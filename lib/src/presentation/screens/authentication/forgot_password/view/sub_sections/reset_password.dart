import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_auth_text_input_field.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/forgot_password/controller/reset_password_controller.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final ResetPasswordController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final String email = Get.arguments?['email'] ?? '';
    final String otp = Get.arguments?['otp'] ?? '';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const CommonDefaultAppBar(),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 0.30.sh,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Image.asset(
                            PngAssets.splashFrame,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            PngAssets.appLogo,
                            fit: BoxFit.contain,
                            width: 105.w,
                          ),
                          SizedBox(height: 20.h),
                          Text(
                            localizations.resetPasswordTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w900,
                              fontSize: 24.sp,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 18.w,
                            ),
                            child: Text(
                              localizations.resetPasswordSubtitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: AppColors.lightTextTertiary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 0.70.sh,
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                  padding: EdgeInsetsDirectional.only(
                    top: 3.h,
                    start: 18.w,
                    end: 18.w,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(30.r),
                      topEnd: Radius.circular(30.r),
                    ),
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 0),
                        blurRadius: 40.r,
                        color: AppColors.black.withValues(alpha: 0.06),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      CommonRequiredLabelAndDynamicField(
                        labelText: localizations.resetPasswordPassword,
                        isLabelRequired: true,
                        dynamicField: Obx(
                          () => CommonAuthTextInputField(
                            controller: controller.passwordController,
                            focusNode: controller.passwordFocusNode,
                            isFocused: controller.isPasswordFocused.value,
                            obscureText: controller.isPasswordVisible.value,
                            keyboardType: TextInputType.visiblePassword,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.isPasswordVisible.toggle();
                              },
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 6.w,
                                  top: 14.h,
                                  bottom: 14.h,
                                ),
                                child: Image(
                                  image: AssetImage(
                                    controller.isPasswordVisible.value
                                        ? PngAssets.eyeCommonIcon
                                        : PngAssets.eyeHideCommonIcon,
                                  ),
                                  color: controller.isPasswordFocused.value
                                      ? AppColors.lightPrimary
                                      : AppColors.lightTextPrimary.withValues(
                                          alpha: 0.44,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      CommonRequiredLabelAndDynamicField(
                        labelText: localizations.resetPasswordConfirmPassword,
                        isLabelRequired: true,
                        dynamicField: Obx(
                          () => CommonAuthTextInputField(
                            controller: controller.confirmPasswordController,
                            focusNode: controller.confirmPasswordFocusNode,
                            isFocused:
                                controller.isConfirmPasswordFocused.value,
                            obscureText:
                                controller.isConfirmPasswordVisible.value,
                            keyboardType: TextInputType.visiblePassword,
                            suffixIcon: GestureDetector(
                              onTap: () {
                                controller.isConfirmPasswordVisible.toggle();
                              },
                              child: Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 6.w,
                                  top: 14.h,
                                  bottom: 14.h,
                                ),
                                child: Image(
                                  image: AssetImage(
                                    controller.isConfirmPasswordVisible.value
                                        ? PngAssets.eyeCommonIcon
                                        : PngAssets.eyeHideCommonIcon,
                                  ),
                                  color:
                                      controller.isConfirmPasswordFocused.value
                                      ? AppColors.lightPrimary
                                      : AppColors.lightTextPrimary.withValues(
                                          alpha: 0.44,
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),
                      CommonButton(
                        onPressed: () async {
                          if (controller.passwordController.text.isEmpty) {
                            ToastHelper().showErrorToast(
                              localizations.resetPasswordValidationRequired,
                            );
                            return;
                          } else if (controller
                                  .passwordController
                                  .text
                                  .isNotEmpty &&
                              controller.passwordController.text.length < 8) {
                            ToastHelper().showErrorToast(
                              localizations.resetPasswordValidationMinLength,
                            );
                            return;
                          } else if (controller
                              .confirmPasswordController
                              .text
                              .isEmpty) {
                            ToastHelper().showErrorToast(
                              localizations
                                  .resetPasswordValidationConfirmRequired,
                            );
                            return;
                          } else if (controller.passwordController.text !=
                              controller.confirmPasswordController.text) {
                            ToastHelper().showErrorToast(
                              localizations.resetPasswordValidationMismatch,
                            );
                            return;
                          } else {
                            await controller.submitResetPassword(
                              email: email,
                              otp: otp,
                            );
                          }
                        },
                        width: double.infinity,

                        text: localizations.resetPasswordButton,
                      ),
                      SizedBox(height: 20.h),
                      Wrap(
                        children: [
                          Text(
                            localizations.resetPasswordAlreadyHaveAccount,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.lightTextTertiary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Get.offNamed(BaseRoute.signIn);
                            },
                            child: Text(
                              localizations.resetPasswordSignIn,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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
      ),
    );
  }
}
