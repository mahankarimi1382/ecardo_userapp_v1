import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/biometric_auth_service.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:qunzo_user/src/common/widgets/input_field/common_auth_text_input_field.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SignInController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        showExitApplicationAlertDialog();
      },
      child: Scaffold(
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
                            imageFilter: ImageFilter.blur(
                              sigmaX: 20,
                              sigmaY: 20,
                            ),
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
                              localizations.signInWelcomeBack,
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
                                localizations.signInSubtitle,
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
                        AutofillGroup(
                          child: Column(
                            children: [
                              CommonRequiredLabelAndDynamicField(
                                labelText: localizations.signInEmail,
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
                                              : AppColors.lightTextPrimary
                                                    .withValues(alpha: 0.44),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),
                              CommonRequiredLabelAndDynamicField(
                                labelText: localizations.signInPassword,
                                isLabelRequired: true,
                                dynamicField: Obx(
                                  () => CommonAuthTextInputField(
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    controller: controller.passwordController,
                                    focusNode: controller.passwordFocusNode,
                                    isFocused:
                                        controller.isPasswordFocused.value,
                                    obscureText:
                                        controller.isPasswordVisible.value,
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
                                          color:
                                              controller.isPasswordFocused.value
                                              ? AppColors.lightPrimary
                                              : AppColors.lightTextPrimary
                                                    .withValues(alpha: 0.44),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: GestureDetector(
                            onTap: () => Get.toNamed(BaseRoute.forgotPassword),
                            child: Text(
                              localizations.signInForgotPassword,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: AppColors.lightPrimary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        Obx(
                          () => CommonButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    if (controller
                                        .emailController
                                        .text
                                        .isEmpty) {
                                      ToastHelper().showErrorToast(
                                        localizations
                                            .signInValidationEmailRequired,
                                      );
                                    } else if (controller
                                        .passwordController
                                        .text
                                        .isEmpty) {
                                      ToastHelper().showErrorToast(
                                        localizations
                                            .signInValidationPasswordRequired,
                                      );
                                    } else {
                                      await controller.submitSignIn();
                                    }
                                  },
                            width: double.infinity,
                            text: localizations.signInButton,
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Wrap(
                          children: [
                            Text(
                              localizations.signInNotRegistered,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: AppColors.lightTextTertiary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final String isCreateAccount =
                                    Get.find<SettingsService>().getSetting(
                                      "account_creation",
                                    ) ??
                                    "0";
                                if (isCreateAccount == "1") {
                                  Get.toNamed(BaseRoute.email);
                                } else {
                                  ToastHelper().showErrorToast(
                                    localizations.signInRegistrationDisabled,
                                  );
                                }
                              },
                              child: Text(
                                localizations.signInCreateAccount,
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
                        SizedBox(height: 50.h),
                        Obx(
                          () => Material(
                            color: AppColors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(100.r),
                              onTap: () async {
                                controller.isPressed.value = true;
                                await Future.delayed(
                                  const Duration(milliseconds: 100),
                                );

                                final savedEmail =
                                    await SettingsService.getLoggedInUserEmail();
                                final savedPassword =
                                    await SettingsService.getLoggedInUserPassword();

                                if (savedEmail == null ||
                                    savedPassword == null) {
                                  ToastHelper().showErrorToast(
                                    localizations.signInBiometricErrorFirstTime,
                                  );
                                  controller.isPressed.value = false;
                                  return;
                                }

                                if (!controller.isBiometricEnable.value) {
                                  ToastHelper().showErrorToast(
                                    localizations
                                        .signInBiometricErrorNotEnabled,
                                  );
                                  controller.isPressed.value = false;
                                  return;
                                }

                                final bioAuth = BiometricAuthService();
                                bool success = await bioAuth
                                    .authenticateWithBiometrics();

                                if (success) {
                                  controller.biometricEmail.value = savedEmail;
                                  controller.biometricPassword.value =
                                      savedPassword;
                                  await controller.submitSignIn(
                                    useBiometric: true,
                                  );
                                }

                                controller.isPressed.value = false;
                              },
                              onTapCancel: () {
                                controller.isPressed.value = false;
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                padding: EdgeInsets.all(10.w),
                                width: 60.w,
                                height: 60.w,
                                transform: Matrix4.identity()
                                  ..scaleByDouble(
                                    controller.isPressed.value ? 0.95 : 1.0,
                                    controller.isPressed.value ? 0.95 : 1.0,
                                    controller.isPressed.value ? 0.95 : 1.0,
                                    1.0,
                                  ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100.r),
                                  border: Border.all(
                                    width: 1.5.w,
                                    color: AppColors.lightPrimary.withValues(
                                      alpha: 0.20,
                                    ),
                                  ),
                                ),
                                child: Image.asset(
                                  PngAssets.fingerprintCommonIcon,
                                  color: AppColors.lightPrimary,
                                ),
                              ),
                            ),
                          ),
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
      ),
    );
  }

  void showExitApplicationAlertDialog() {
    final localizations = AppLocalizations.of(context)!;

    Get.bottomSheet(
      CommonAlertBottomSheet(
        title: localizations.exitApplicationTitle,
        message: localizations.exitApplicationMessage,
        onConfirm: () => exit(0),
        onCancel: () => Get.back(),
      ),
    );
  }
}
