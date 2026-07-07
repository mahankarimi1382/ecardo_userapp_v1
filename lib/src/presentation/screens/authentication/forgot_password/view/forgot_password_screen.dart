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
import 'package:qunzo_user/src/presentation/screens/authentication/forgot_password/controller/forgot_password_controller.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final ForgotPasswordController controller =
        Get.find<ForgotPasswordController>();

    return Scaffold(
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
                            localizations.forgotPasswordTitle,
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
                              localizations.forgotPasswordSubtitle,
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
                        labelText: localizations.forgotPasswordEmail,
                        isLabelRequired: true,
                        dynamicField: Obx(
                          () => CommonAuthTextInputField(
                            autofillHints: const [AutofillHints.email],
                            controller: controller.emailController,
                            focusNode: controller.emailFocusNode,
                            isFocused: controller.isEmailFocused.value,
                            keyboardType: TextInputType.emailAddress,
                            suffixIcon: Obx(
                              () => Padding(
                                padding: EdgeInsetsDirectional.only(
                                  start: 6.w,
                                  top: 14.h,
                                  bottom: 14.h,
                                ),
                                child: Image(
                                  image: const AssetImage(
                                    PngAssets.commonMailIcon,
                                  ),
                                  color: controller.isEmailFocused.value
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
                        onPressed: () {
                          if (controller.emailController.text.isEmpty) {
                            ToastHelper().showErrorToast(
                              localizations.forgotPasswordEmailRequired,
                            );
                          } else {
                            controller.submitForgotPassword();
                          }
                        },
                        width: double.infinity,

                        text: localizations.forgotPasswordButton,
                      ),
                      SizedBox(height: 20.h),
                      Wrap(
                        children: [
                          Text(
                            localizations.forgotPasswordBackTo,
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
                              localizations.forgotPasswordSignIn,
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
