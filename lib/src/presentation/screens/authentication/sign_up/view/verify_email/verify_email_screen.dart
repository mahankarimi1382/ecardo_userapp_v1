import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/digit_normalization_formatter.dart';
import 'package:ecardo_user/src/helper/mask_email_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_language_pill.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_step_progress_bar.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/verify_email_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  late final VerifyEmailController controller;
  String? email;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<VerifyEmailController>()
        ? Get.find<VerifyEmailController>()
        : Get.put(VerifyEmailController());
    loadSavedEmail();
  }

  Future<void> loadSavedEmail() async {
    final savedEmail = await SettingsService.getLoggedInUserEmail();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      setState(() {
        email = savedEmail;
      });
    }
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
        ? AppColors.darkSurface.withValues(alpha: 0.94)
        : AppColors.white.withValues(alpha: 0.96);
    final cardBorder = isDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.lightBorder.withValues(alpha: 0.7);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: const CommonDefaultAppBar(),
      body: AmbientAuthBackground(
        child: Stack(
          children: [
            email == null
                ? const CommonLoading()
                : SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Top Bar
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
                                        color: (isDark
                                                ? AppColors.darkAccent
                                                : AppColors.brandViolet)
                                            .withValues(
                                                alpha: isDark ? 0.16 : 0.25),
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

                          // Multi-Step Progress Bar (Step 2 Active)
                          const AuthStepProgressBar(currentStep: 2),

                          SizedBox(height: 12.h),

                          // Title & Masked Email Chip
                          Text(
                            localizations.verifyEmailTitle,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: -0.5,
                              fontWeight: FontWeight.w900,
                              fontSize: 24.sp,
                              color: primaryTextColor,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkAccent.withValues(alpha: 0.12)
                                  : AppColors.brandVioletContainer,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkAccent.withValues(alpha: 0.35)
                                    : AppColors.brandViolet.withValues(alpha: 0.35),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.mark_email_read_outlined,
                                  size: 16.sp,
                                  color: isDark
                                      ? AppColors.darkAccent
                                      : AppColors.brandViolet,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '${localizations.verifyEmailOtpSent} ${MaskEmailHelper.maskEmail(email!)}',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkAccent
                                        : AppColors.brandViolet,
                                    letterSpacing: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 24.h),

                          // Form Card Container
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
                                    localizations.verifyEmailEnterOtp,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16.sp,
                                      color: primaryTextColor,
                                      letterSpacing: 0,
                                    ),
                                  ),
                                  SizedBox(height: 8.h),
                                  Obx(
                                    () => Text(
                                      controller.countdown.value > 0
                                          ? "${localizations.verifyEmailResendAvailable} ${controller.countdown.value}s"
                                          : localizations
                                              .verifyEmailRequestNewOtp,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5.sp,
                                        color: isDark
                                            ? AppColors.darkAccent
                                            : AppColors.brandViolet,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 24.h),

                                  // PIN Code Input
                                  Obx(
                                    () => Semantics(
                                      label: localizations.verifyEmailEnterOtp,
                                      textField: true,
                                      child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: PinCodeTextField(
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            const DigitNormalizationFormatter(maxLength: 6),
                                            FilteringTextInputFormatter.digitsOnly,
                                          ],
                                          cursorColor: isDark
                                              ? AppColors.darkAccent
                                              : AppColors.brandViolet,
                                          textStyle: TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18.sp,
                                            color: primaryTextColor,
                                            letterSpacing: 0,
                                          ),
                                          controller: controller.pinCodeController,
                                          enableActiveFill:
                                              controller.isPinEnabled.value,
                                          pinTheme: PinTheme(
                                            borderWidth: 1.5.w,
                                            activeBorderWidth: 1.5.w,
                                            disabledBorderWidth: 1.5.w,
                                            inactiveBorderWidth: 1.5.w,
                                            shape: PinCodeFieldShape.box,
                                            fieldHeight: 50.h,
                                            fieldWidth: 44.w,
                                            activeColor: isDark
                                                ? AppColors.darkAccent
                                                : AppColors.brandViolet,
                                            activeFillColor: isDark
                                                ? AppColors.white.withValues(alpha: 0.06)
                                                : AppColors.lightSurfaceVariant,
                                            inactiveColor: isDark
                                                ? AppColors.white.withValues(alpha: 0.15)
                                                : AppColors.lightBorder,
                                            inactiveFillColor: isDark
                                                ? AppColors.white.withValues(alpha: 0.03)
                                                : AppColors.transparent,
                                            selectedColor: isDark
                                                ? AppColors.darkAccent
                                                : AppColors.brandViolet,
                                            selectedFillColor: isDark
                                                ? AppColors.darkAccent
                                                    .withValues(alpha: 0.12)
                                                : AppColors.brandVioletContainer,
                                            selectedBorderWidth: 1.5.w,
                                            borderRadius:
                                                BorderRadius.circular(14.r),
                                          ),
                                          appContext: context,
                                          length: 6,
                                          onCompleted: (_) async {
                                            if (email != null &&
                                                controller.pinCodeController.text
                                                        .length ==
                                                    6) {
                                              await controller.validateVerifyEmail(
                                                email: email!,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 28.h),

                                  // Submit Verification Button
                                  CommonButton(
                                    height: 52.h,
                                    borderRadius: 16.r,
                                    onPressed: () async {
                                      if (controller.pinCodeController.text
                                              .length ==
                                          6) {
                                        await controller.validateVerifyEmail(
                                          email: email!,
                                        );
                                      } else {
                                        ToastHelper().showErrorToast(
                                          localizations.verifyEmailOtpRequired,
                                        );
                                      }
                                    },
                                    width: double.infinity,
                                    text: localizations.verifyEmailTitle,
                                  ),

                                  SizedBox(height: 20.h),

                                  // Resend Section
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        localizations.verifyEmailDidNotReceive,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14.sp,
                                          color: secondaryTextColor,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Obx(
                                        () => GestureDetector(
                                          onTap: () {
                                            if (controller.countdown.value ==
                                                0) {
                                              controller.sendVerifyEmail(
                                                email: email!,
                                              );
                                            }
                                          },
                                          child: Semantics(
                                            button: true,
                                            enabled: controller.countdown.value == 0,
                                            label: localizations.verifyEmailResend,
                                            child: Container(
                                              constraints: BoxConstraints(
                                                minHeight: 44.h,
                                                minWidth: 44.w,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                localizations.verifyEmailResend,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 14.sp,
                                                  color: controller
                                                              .countdown.value >
                                                          0
                                                      ? secondaryTextColor
                                                      : (isDark
                                                          ? AppColors.darkAccent
                                                          : AppColors.brandViolet),
                                                ),
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
