import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/digit_normalization_formatter.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_language_pill.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/two_factor_auth_controller.dart';

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;
    final secondaryTextColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextTertiary;

    final accentColor = isDark
        ? AppColors.darkAccent
        : AppColors.brandViolet;

    final cardBg = isDark
        ? AppColors.darkSurface.withValues(alpha: 0.94)
        : AppColors.white.withValues(alpha: 0.96);
    final cardBorder = isDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: AmbientAuthBackground(
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Top Navigation & Language Pill
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Semantics(
                            button: true,
                            label: 'Back',
                            child: IconButton(
                              tooltip: 'Back',
                              onPressed: () => Get.back(),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded,
                                size: 20.sp,
                                color: primaryTextColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(
                                    alpha: isDark ? 0.16 : 0.25,
                                  ),
                                  blurRadius: 18,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              PngAssets.appLogo,
                              fit: BoxFit.contain,
                              height: 30.h,
                            ),
                          ),
                          const AuthLanguagePill(),
                        ],
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Header Title
                    Text(
                      localizations.twoFactorAuthTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w900,
                        fontSize: 26.sp,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        localizations.twoFactorAuthSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                          color: secondaryTextColor,
                          letterSpacing: 0,
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Glassmorphic Card Container
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 18.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 24.h,
                        ),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(28.r),
                          border: Border.all(
                            color: cardBorder,
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withValues(
                                alpha: isDark ? 0.35 : 0.08,
                              ),
                              blurRadius: 32,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              localizations.twoFactorAuthEnterOtp,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16.sp,
                                color: primaryTextColor,
                                letterSpacing: 0,
                              ),
                            ),
                            SizedBox(height: 24.h),

                            // PIN Code Input Field with Persian/Arabic normalization
                            Semantics(
                              label: localizations.twoFactorAuthEnterOtp,
                              textField: true,
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: PinCodeTextField(
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    const DigitNormalizationFormatter(
                                      maxLength: 6,
                                    ),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  autoFocus: true,
                                  cursorColor: accentColor,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18.sp,
                                    color: primaryTextColor,
                                    letterSpacing: 0,
                                  ),
                                  controller: controller.pinCodeController,
                                  pinTheme: PinTheme(
                                    borderWidth: 1.5.w,
                                    activeBorderWidth: 1.5.w,
                                    disabledBorderWidth: 1.5.w,
                                    inactiveBorderWidth: 1.5.w,
                                    shape: PinCodeFieldShape.box,
                                    fieldHeight: 50.h,
                                    fieldWidth: 44.w,
                                    activeColor: accentColor,
                                    activeFillColor: isDark
                                        ? AppColors.white.withValues(
                                            alpha: 0.06,
                                          )
                                        : AppColors.lightSurfaceVariant,
                                    inactiveColor: isDark
                                        ? AppColors.white.withValues(
                                            alpha: 0.15,
                                          )
                                        : AppColors.lightBorder,
                                    inactiveFillColor: isDark
                                        ? AppColors.white.withValues(
                                            alpha: 0.03,
                                          )
                                        : AppColors.transparent,
                                    selectedColor: accentColor,
                                    selectedFillColor: isDark
                                        ? accentColor.withValues(alpha: 0.12)
                                        : AppColors.brandVioletContainer,
                                    selectedBorderWidth: 1.5.w,
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  appContext: context,
                                  length: 6,
                                  onCompleted: (_) async {
                                    if (controller
                                            .pinCodeController
                                            .text
                                            .length ==
                                        6) {
                                      await controller.submitTwoFaVerification();
                                    }
                                  },
                                ),
                              ),
                            ),

                            SizedBox(height: 28.h),

                            // Submit Verification Button
                            CommonButton(
                              height: 52.h,
                              borderRadius: 16.r,
                              onPressed: () async {
                                if (controller
                                        .pinCodeController
                                        .text
                                        .length ==
                                    6) {
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

                            SizedBox(height: 20.h),

                            // Back to Sign In Link with Accessible Touch Target
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  localizations.twoFactorAuthBackTo,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0,
                                    fontSize: 14.sp,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                  onTap: () {
                                    Get.offNamed(BaseRoute.signIn);
                                  },
                                  child: Container(
                                    constraints: BoxConstraints(
                                      minHeight: 48.h,
                                      minWidth: 48.w,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      localizations.twoFactorAuthSignIn,
                                      style: TextStyle(
                                        letterSpacing: 0,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14.sp,
                                        color: accentColor,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
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
