import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_language_pill.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_step_progress_bar.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/creative_floating_text_field.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/password_strength_meter.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/terms_privacy_dialog.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/set_up_password_controller.dart';

class SetUpPasswordScreen extends StatefulWidget {
  const SetUpPasswordScreen({super.key});

  @override
  State<SetUpPasswordScreen> createState() => _SetUpPasswordScreenState();
}

class _SetUpPasswordScreenState extends State<SetUpPasswordScreen> {
  late final SetUpPasswordController controller;
  String _currentPassword = '';
  String _currentConfirmPassword = '';

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SetUpPasswordController>()
        ? Get.find<SetUpPasswordController>()
        : Get.put(SetUpPasswordController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.resetFields();
    });

    controller.passwordController.addListener(_onPasswordChanged);
    controller.confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  void _onPasswordChanged() {
    if (mounted) {
      setState(() {
        _currentPassword = controller.passwordController.text;
      });
    }
  }

  void _onConfirmPasswordChanged() {
    if (mounted) {
      setState(() {
        _currentConfirmPassword = controller.confirmPasswordController.text;
      });
    }
  }

  @override
  void dispose() {
    controller.passwordController.removeListener(_onPasswordChanged);
    controller.confirmPasswordController.removeListener(_onConfirmPasswordChanged);
    super.dispose();
  }

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
        ? const Color(0xFF131A2B).withValues(alpha: 0.94)
        : AppColors.white.withValues(alpha: 0.96);
    final cardBorder = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF090D1A) : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: AmbientAuthBackground(
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // Top Bar with Logo & Language Pill
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              size: 20.sp,
                              color: primaryTextColor,
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
                                  color: (isDark
                                          ? const Color(0xFF38BDF8)
                                          : AppColors.mainSoftBlue)
                                      .withValues(alpha: isDark ? 0.16 : 0.25),
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

                    SizedBox(height: 8.h),

                    // Multi-Step Progress Bar (Step 3: Security Setup Active)
                    const AuthStepProgressBar(currentStep: 3),

                    SizedBox(height: 12.h),

                    // Title & Subtitle
                    Text(
                      localizations.setupPasswordTitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        letterSpacing: -0.5,
                        fontWeight: FontWeight.w900,
                        fontSize: 24.sp,
                        color: primaryTextColor,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        localizations.setupPasswordSubtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          letterSpacing: 0,
                          fontWeight: FontWeight.w500,
                          fontSize: 14.sp,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Card Form Container
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
                          border: Border.all(color: cardBorder, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(
                                alpha: isDark ? 0.35 : 0.08,
                              ),
                              blurRadius: 32,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Floating Label Password Field
                            Obx(
                              () => CreativeFloatingTextField(
                                label: localizations.setupPasswordPassword,
                                isRequired: true,
                                controller: controller.passwordController,
                                focusNode: controller.passwordFocusNode,
                                isFocused: controller.isPasswordFocused.value,
                                obscureText: controller.isPasswordVisible.value,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.next,
                                prefixIcon: Icon(
                                  Icons.lock_outline_rounded,
                                  size: 20.sp,
                                  color: controller.isPasswordFocused.value
                                      ? (isDark
                                          ? const Color(0xFF38BDF8)
                                          : AppColors.deepBlack)
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextTertiary),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.isPasswordVisible.toggle();
                                  },
                                  icon: Icon(
                                    controller.isPasswordVisible.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20.sp,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),

                            // Real-time Animated Password Strength Meter
                            PasswordStrengthMeter(
                              password: _currentPassword,
                              confirmPassword: _currentConfirmPassword,
                            ),

                            SizedBox(height: 16.h),

                            // Floating Label Confirm Password Field
                            Obx(
                              () => CreativeFloatingTextField(
                                label: localizations.setupPasswordConfirmPassword,
                                isRequired: true,
                                controller:
                                    controller.confirmPasswordController,
                                focusNode: controller.confirmPasswordFocusNode,
                                isFocused:
                                    controller.isConfirmPasswordFocused.value,
                                obscureText:
                                    controller.isConfirmPasswordVisible.value,
                                keyboardType: TextInputType.visiblePassword,
                                textInputAction: TextInputAction.done,
                                prefixIcon: Icon(
                                  Icons.shield_outlined,
                                  size: 20.sp,
                                  color: controller
                                          .isConfirmPasswordFocused.value
                                      ? (isDark
                                          ? const Color(0xFF38BDF8)
                                          : AppColors.deepBlack)
                                      : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextTertiary),
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    controller.isConfirmPasswordVisible
                                        .toggle();
                                  },
                                  icon: Icon(
                                    controller.isConfirmPasswordVisible.value
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20.sp,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextTertiary,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 16.h),

                            // Terms and Privacy Checkbox with Interactive Link Dialog
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.04)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : AppColors.lightBorder
                                          .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Obx(
                                    () => Checkbox(
                                      checkColor: Colors.white,
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.4)
                                            : AppColors.lightTextTertiary,
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(6.r),
                                      ),
                                      activeColor: isDark
                                          ? const Color(0xFF38BDF8)
                                          : AppColors.deepBlack,
                                      materialTapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                      visualDensity: VisualDensity.compact,
                                      value: controller
                                          .isTermsAndConditionChecked.value,
                                      onChanged: (bool? value) {
                                        controller.isTermsAndConditionChecked
                                            .value = value ?? false;
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: Wrap(
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            controller.isTermsAndConditionChecked
                                                .toggle();
                                          },
                                          child: Text(
                                            localizations
                                                .setupPasswordAgreeTerms,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 0,
                                              fontSize: 13.sp,
                                              color: primaryTextColor,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            TermsPrivacyDialog.show(
                                              context,
                                              onAccept: () {
                                                controller
                                                    .isTermsAndConditionChecked
                                                    .value = true;
                                              },
                                            );
                                          },
                                          child: Text(
                                            localizations
                                                .setupPasswordTermsConditions,
                                            style: TextStyle(
                                              letterSpacing: 0,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 13.sp,
                                              color: isDark
                                                  ? const Color(0xFF38BDF8)
                                                  : AppColors.lightPrimary,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.info_outline_rounded,
                                      size: 18.sp,
                                      color: isDark
                                          ? const Color(0xFF38BDF8)
                                          : AppColors.lightPrimary,
                                    ),
                                    onPressed: () {
                                      TermsPrivacyDialog.show(
                                        context,
                                        onAccept: () {
                                          controller
                                              .isTermsAndConditionChecked
                                              .value = true;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 28.h),

                            // Complete Setup Button
                            CommonButton(
                              height: 52.h,
                              borderRadius: 16.r,
                              onPressed: () async {
                                if (controller
                                    .passwordController.text.isEmpty) {
                                  ToastHelper().showErrorToast(
                                    localizations
                                        .setupPasswordValidationRequired,
                                  );
                                } else if (controller
                                        .passwordController.text.length <
                                    8) {
                                  ToastHelper().showErrorToast(
                                    localizations
                                        .setupPasswordValidationMinLength,
                                  );
                                } else if (controller
                                    .confirmPasswordController.text.isEmpty) {
                                  ToastHelper().showErrorToast(
                                    localizations
                                        .setupPasswordValidationConfirmRequired,
                                  );
                                } else if (controller.passwordController.text !=
                                    controller
                                        .confirmPasswordController.text) {
                                  ToastHelper().showErrorToast(
                                    localizations
                                        .setupPasswordValidationMismatch,
                                  );
                                } else if (!controller
                                    .isTermsAndConditionChecked.value) {
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
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Loading Overlay
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
