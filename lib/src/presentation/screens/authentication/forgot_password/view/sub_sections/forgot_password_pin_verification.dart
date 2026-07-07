import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/mask_email_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/forgot_password/controller/forgot_password_pin_verification_controller.dart';

class ForgotPasswordPinVerification extends StatefulWidget {
  const ForgotPasswordPinVerification({super.key});

  @override
  State<ForgotPasswordPinVerification> createState() =>
      _ForgotPasswordPinVerificationState();
}

class _ForgotPasswordPinVerificationState
    extends State<ForgotPasswordPinVerification> {
  final ForgotPasswordPinVerificationController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final String email = Get.arguments?['email'] ?? '';

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
                            localizations.forgotPasswordPinVerifyTitle,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  localizations.forgotPasswordPinOtpSent,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: AppColors.lightTextTertiary,
                                    letterSpacing: 0,
                                  ),
                                ),
                                Text(
                                  MaskEmailHelper.maskEmail(email),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: AppColors.lightPrimary,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
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
                      Column(
                        children: [
                          Text(
                            localizations.forgotPasswordPinEnterOtp,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16.sp,
                              color: AppColors.lightTextPrimary,
                              letterSpacing: 0,
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Obx(
                            () => Text(
                              "${localizations.forgotPasswordPinOtpCountdown} ${controller.countdown.value}s",
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14.sp,
                                color: AppColors.lightPrimary,
                                letterSpacing: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30.h),
                      Obx(
                        () => PinCodeTextField(
                          keyboardType: TextInputType.number,
                          enabled: controller.isPinEnabled.value,
                          cursorColor: AppColors.lightPrimary,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16.sp,
                            color: AppColors.lightTextPrimary,
                            letterSpacing: 0,
                          ),
                          controller: controller.pinCodeController,
                          enableActiveFill: controller.isPinEnabled.value,
                          pinTheme: PinTheme(
                            borderWidth: 1.5.w,
                            activeBorderWidth: 1.5.w,
                            disabledBorderWidth: 1.5.w,
                            inactiveBorderWidth: 1.5.w,
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 48.h,
                            fieldWidth: 45.w,
                            activeColor: AppColors.lightPrimary.withValues(
                              alpha: 0.60,
                            ),
                            activeFillColor: AppColors.transparent,
                            inactiveColor: AppColors.lightTextPrimary
                                .withValues(alpha: 0.20),
                            inactiveFillColor: AppColors.transparent,
                            selectedColor: AppColors.lightPrimary.withValues(
                              alpha: 0.60,
                            ),
                            selectedFillColor: AppColors.transparent,
                            disabledColor: AppColors.lightTextPrimary
                                .withValues(alpha: 0.05),
                            selectedBorderWidth: 1.5.w,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          appContext: context,
                          length: 6,
                        ),
                      ),

                      SizedBox(height: 30.h),
                      CommonButton(
                        onPressed: () async {
                          if (controller.pinCodeController.text.length == 6) {
                            await controller.submitResetVerifyOtp(email: email);
                          } else {
                            ToastHelper().showErrorToast(
                              localizations.forgotPasswordPinOtpRequired,
                            );
                          }
                        },
                        width: double.infinity,

                        text: localizations.forgotPasswordPinVerifyButton,
                      ),
                      SizedBox(height: 20.h),
                      Wrap(
                        children: [
                          Text(
                            localizations.forgotPasswordPinDidNotReceive,
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.lightTextTertiary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                controller.submitForgotPassword(email: email),
                            child: Text(
                              localizations.forgotPasswordPinResend,
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
