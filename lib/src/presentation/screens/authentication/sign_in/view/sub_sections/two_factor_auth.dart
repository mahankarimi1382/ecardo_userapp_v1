import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/common/widgets/common_loading.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_in/controller/two_factor_auth_controller.dart';

class TwoFactorAuth extends StatefulWidget {
  const TwoFactorAuth({super.key});

  @override
  State<TwoFactorAuth> createState() => _TwoFactorAuthState();
}

class _TwoFactorAuthState extends State<TwoFactorAuth> {
  final TwoFactorAuthController controller =
      Get.find<TwoFactorAuthController>();

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        PngAssets.appLogo,
                        fit: BoxFit.contain,
                        width: 120,
                      ),
                      SizedBox(height: 20),
                      Text(
                        localizations.twoFactorAuthTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 28,
                          letterSpacing: 0,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 10),
                      Padding(
                        padding: EdgeInsetsDirectional.symmetric(
                          horizontal: 18,
                        ),
                        child: Text(
                          localizations.twoFactorAuthSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.lightTextTertiary,
                            letterSpacing: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Image.asset(
                      PngAssets.splashFrame,
                      height: 290,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsetsDirectional.symmetric(horizontal: 18),
                  padding: EdgeInsetsDirectional.only(
                    top: 3,
                    start: 18,
                    end: 18,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadiusDirectional.only(
                      topStart: Radius.circular(30),
                      topEnd: Radius.circular(30),
                    ),
                    color: AppColors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 0),
                        blurRadius: 40,
                        color: AppColors.black.withValues(alpha: 0.06),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        Text(
                          localizations.twoFactorAuthEnterOtp,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.lightTextPrimary,
                            letterSpacing: 0,
                          ),
                        ),
                        SizedBox(height: 20),
                        PinCodeTextField(
                          keyboardType: TextInputType.number,
                          cursorColor: AppColors.lightPrimary,
                          textStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            color: AppColors.lightTextPrimary,
                            letterSpacing: 0,
                          ),
                          controller: controller.pinCodeController,
                          pinTheme: PinTheme(
                            borderWidth: 1.5,
                            activeBorderWidth: 1.5,
                            disabledBorderWidth: 1.5,
                            inactiveBorderWidth: 1.5,
                            shape: PinCodeFieldShape.box,
                            fieldHeight: 52,
                            fieldWidth: 48,
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
                            selectedBorderWidth: 1.5,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          appContext: context,
                          length: 6,
                        ),

                        SizedBox(height: 30),
                        CommonButton(
                          onPressed: () async {
                            if (controller.pinCodeController.text.length == 6) {
                              await controller.submitTwoFaVerification();
                            } else {
                              ToastHelper().showErrorToast(
                                localizations.twoFactorAuthOtpRequired,
                              );
                            }
                          },
                          width: double.infinity,

                          text: localizations.twoFactorAuthVerifyButton,
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.twoFactorAuthBackTo,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0,
                                fontSize: 14,
                                color: AppColors.lightTextTertiary,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.offNamed(BaseRoute.signIn);
                              },
                              child: Text(
                                localizations.twoFactorAuthSignIn,
                                style: TextStyle(
                                  letterSpacing: 0,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.lightPrimary,
                                ),
                              ),
                            ),
                          ],
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
              child: const CommonLoading(),
            ),
          ),
        ],
      ),
    );
  }
}
