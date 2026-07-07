import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_auth_text_input_field.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/controller/set_up_password_controller.dart';
import 'package:qunzo_user/src/presentation/widgets/web_view_dynamic.dart';

class SetUpPasswordScreen extends StatefulWidget {
  const SetUpPasswordScreen({super.key});

  @override
  State<SetUpPasswordScreen> createState() => _SetUpPasswordScreenState();
}

class _SetUpPasswordScreenState extends State<SetUpPasswordScreen> {
  final SetUpPasswordController controller = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
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
                            localizations.setupPasswordTitle,
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
                            padding: EdgeInsetsDirectional.symmetric(horizontal: 18.w),
                            child: Text(
                              localizations.setupPasswordSubtitle,
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
                        labelText: localizations.setupPasswordPassword,
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
                        labelText: localizations.setupPasswordConfirmPassword,
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
                      SizedBox(height: 5.h),
                      Row(
                        children: [
                          Obx(
                            () => Checkbox(
                              checkColor: AppColors.white,
                              side: BorderSide(
                                color: AppColors.lightTextTertiary,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              activeColor: AppColors.lightPrimary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                              value:
                                  controller.isTermsAndConditionChecked.value,
                              onChanged: (bool? value) {
                                Future.microtask(() {
                                  controller.isTermsAndConditionChecked.value =
                                      value!;
                                });
                              },
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  controller.isTermsAndConditionChecked.value =
                                      !controller
                                          .isTermsAndConditionChecked
                                          .value;
                                },
                                child: Text(
                                  localizations.setupPasswordAgreeTerms,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0,
                                    fontSize: 14.sp,
                                    color: AppColors.lightTextPrimary,
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.to(
                                    () => WebViewDynamic(
                                      dynamicUrl:
                                          "${ApiPath.baseUrl}${ApiPath.termsAndConditionsEndpoint}",
                                    ),
                                  );
                                },
                                child: Text(
                                  localizations.setupPasswordTermsConditions,
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
                      SizedBox(height: 40.h),
                      CommonButton(
                        onPressed: () async {
                          if (controller.passwordController.text.isEmpty) {
                            ToastHelper().showErrorToast(
                              localizations.setupPasswordValidationRequired,
                            );
                          } else if (controller
                                  .passwordController
                                  .text
                                  .isNotEmpty &&
                              controller.passwordController.text.length < 8) {
                            ToastHelper().showErrorToast(
                              localizations.setupPasswordValidationMinLength,
                            );
                          } else if (controller
                              .confirmPasswordController
                              .text
                              .isEmpty) {
                            ToastHelper().showErrorToast(
                              localizations
                                  .setupPasswordValidationConfirmRequired,
                            );
                          } else if (controller.passwordController.text !=
                              controller.confirmPasswordController.text) {
                            ToastHelper().showErrorToast(
                              localizations.setupPasswordValidationMismatch,
                            );
                          } else if (!controller
                              .isTermsAndConditionChecked
                              .value) {
                            ToastHelper().showErrorToast(
                              localizations
                                  .setupPasswordValidationTermsRequired,
                            );
                          } else {
                            controller.setUpPassword();
                          }
                        },
                        width: double.infinity,

                        text: localizations.setupPasswordButton,
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
              child: CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
