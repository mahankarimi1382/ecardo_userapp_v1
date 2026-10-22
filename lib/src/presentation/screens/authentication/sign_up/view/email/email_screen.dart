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
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_language_pill.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_step_progress_bar.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/creative_floating_text_field.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/email_controller.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  late final EmailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EmailController>()
        ? Get.find<EmailController>()
        : Get.put(EmailController());
    controller.clearSignUpStatus();
  }

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
                    // Top Bar with Logo & Language Pill
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
                                  color:
                                      (isDark
                                              ? AppColors.darkAccent
                                              : AppColors.brandViolet)
                                          .withValues(
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

                    SizedBox(height: 8.h),

                    // Multi-Step Progress Bar (Step 1 Active)
                    const AuthStepProgressBar(currentStep: 1),

                    SizedBox(height: 12.h),

                    // Title & Subtitle
                    Text(
                      localizations.emailScreenCreateAccount,
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
                        localizations.emailScreenSubtitle,
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

                    // Form Container Card
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
                            // Clean Floating Label Email Input
                            Obx(
                              () => Semantics(
                                label: localizations.emailScreenEmail,
                                textField: true,
                                child: CreativeFloatingTextField(
                                  label: localizations.emailScreenEmail,
                                  isRequired: true,
                                  controller: controller.emailController,
                                  focusNode: controller.emailFocusNode,
                                  isFocused: controller.isEmailFocused.value,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) {
                                    if (controller
                                            .emailController
                                            .text
                                            .isNotEmpty &&
                                        !controller.isLoading.value) {
                                      controller.sendVerifyEmail();
                                    }
                                  },
                                  autofillHints: const [AutofillHints.email],
                                  prefixIcon: Icon(
                                    Icons.mail_outline_rounded,
                                    size: 20.sp,
                                    color: controller.isEmailFocused.value
                                        ? (isDark
                                              ? AppColors.darkAccent
                                              : AppColors.brandViolet)
                                        : (isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextTertiary),
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(height: 28.h),

                            // Continue Button with glowing gradient
                            CommonButton(
                              height: 52.h,
                              borderRadius: 16.r,
                              onPressed: () {
                                if (controller
                                    .emailController
                                    .text
                                    .isNotEmpty) {
                                  controller.sendVerifyEmail();
                                } else {
                                  ToastHelper().showErrorToast(
                                    localizations.emailScreenEmailRequired,
                                  );
                                }
                              },
                              width: double.infinity,
                              text: localizations.emailScreenContinue,
                            ),

                            SizedBox(height: 20.h),

                            // Already have an account row
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  localizations.emailScreenAlreadyHaveAccount,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14.sp,
                                    color: secondaryTextColor,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(BaseRoute.signIn);
                                  },
                                  child: Semantics(
                                    button: true,
                                    label: localizations.emailScreenSignIn,
                                    child: Container(
                                      constraints: BoxConstraints(
                                        minHeight: 44.h,
                                        minWidth: 44.w,
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        localizations.emailScreenSignIn,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w900,
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
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),

            // Loading overlay
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
