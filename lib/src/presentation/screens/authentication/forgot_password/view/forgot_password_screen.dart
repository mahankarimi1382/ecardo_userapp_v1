import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_auth_text_input_field.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/forgot_password/controller/forgot_password_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary;

    final cardBg = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.94)
        : AppColors.white.withValues(alpha: 0.96);
    final cardBorder = isDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder.withValues(alpha: 0.7);

    final ForgotPasswordController controller =
        Get.find<ForgotPasswordController>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: AmbientAuthBackground(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(
                    height: 0.30.sh,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (!isDark)
                          Positioned.fill(
                            child: ImageFiltered(
                              imageFilter:
                                  ImageFilter.blur(sigmaX: 20, sigmaY: 20),
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
                              width: 155.w,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              localizations.forgotPasswordTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w900,
                                fontSize: 24.sp,
                                color: primaryTextColor,
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
                                  color: secondaryTextColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minHeight: 0.70.sh),
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
                      color: cardBg,
                      border: isDark
                          ? Border.all(color: cardBorder, width: 1.2)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 0),
                          blurRadius: 40.r,
                          color: AppColors.black.withValues(
                            alpha: isDark ? 0.35 : 0.06,
                          ),
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
                            () => Semantics(
                              label: localizations.forgotPasswordEmail,
                              textField: true,
                              child: CommonAuthTextInputField(
                                autofillHints: const [AutofillHints.email],
                                controller: controller.emailController,
                                focusNode: controller.emailFocusNode,
                                isFocused: controller.isEmailFocused.value,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (controller
                                          .emailController.text.isNotEmpty &&
                                      !controller.isLoading.value) {
                                    controller.submitForgotPassword();
                                  }
                                },
                                textStyle: TextStyle(
                                  fontSize: 15.sp,
                                  color: primaryTextColor,
                                  letterSpacing: 0,
                                  height: 1.1,
                                  fontWeight: FontWeight.w600,
                                ),
                                hintStyle: TextStyle(
                                  color: secondaryTextColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15.sp,
                                ),
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
                                          ? (isDark
                                              ? AppColors.darkAccent
                                              : AppColors.brandViolet)
                                          : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextPrimary)
                                              .withValues(alpha: 0.44),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 40.h),
                        CommonButton(
                          height: 52.h,
                          borderRadius: 16.r,
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
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              localizations.forgotPasswordBackTo,
                              style: TextStyle(
                                letterSpacing: 0,
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: secondaryTextColor,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            GestureDetector(
                              onTap: () {
                                Get.offNamed(BaseRoute.signIn);
                              },
                              child: Semantics(
                                button: true,
                                label: localizations.forgotPasswordSignIn,
                                child: Container(
                                  constraints: BoxConstraints(
                                    minHeight: 44.h,
                                    minWidth: 44.w,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    localizations.forgotPasswordSignIn,
                                    style: TextStyle(
                                      letterSpacing: 0,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      color: isDark
                                          ? AppColors.darkAccent
                                          : AppColors.brandViolet,
                                    ),
                                  ),
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
      ),
    );
  }
}
