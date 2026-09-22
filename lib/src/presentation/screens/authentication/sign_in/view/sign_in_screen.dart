import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/common_required_label_and_dynamic_field.dart';
import 'package:ecardo_user/src/common/widgets/input_field/common_auth_text_input_field.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final SignInController controller = Get.find();
  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _enterCtrl.forward();
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    super.dispose();
  }

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
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF121212)
            : AppColors.lightBackground,
        body: Stack(
          children: [
            FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: SingleChildScrollView(
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
                              Obx(() {
                                if (controller.emailError.value.isEmpty) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsets.only(top: 6.h, bottom: 4.h),
                                  child: Align(
                                    alignment: AlignmentDirectional.centerStart,
                                    child: Text(
                                      controller.emailError.value,
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                              SizedBox(height: 12.h),
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
                        Obx(() {
                          if (controller.passwordError.value.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: Text(
                                controller.passwordError.value,
                                style: TextStyle(
                                  color: AppColors.error,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 24.h),
                        Obx(
                          () => CommonButton(
                            isLoading: controller.isLoading.value,
                            onPressed: controller.isLoading.value
                                ? null
                                : () async {
                                    await controller.submitSignIn();
                                  },
                            width: double.infinity,
                            text: localizations.signInButton,
                          ),
                        ),
                        // Biometric quick-login — hidden when unsupported / revoked.
                        Obx(() {
                          if (!controller.showBiometricButton.value) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 14.h),
                            child: OutlinedButton.icon(
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () => controller.signInWithBiometricTap(),
                              icon: Icon(
                                Icons.fingerprint_rounded,
                                size: 26.sp,
                                color: AppColors.lightPrimary,
                              ),
                              label: Text(
                                'ورود با اثرانگشت / چهره',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.sp,
                                  color: AppColors.lightPrimary,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                minimumSize: Size(double.infinity, 48.h),
                                side: BorderSide(
                                  color: AppColors.lightPrimary.withValues(
                                    alpha: 0.45,
                                  ),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          );
                        }),
                        SizedBox(height: 16.h),
                        _TelegramSignInButton(localizations: localizations),
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
                                // T15-fix (auth-hardening): a MISSING key used
                                // to be treated as "0", so any user whose
                                // settings fetch failed or was still in flight
                                // (flaky network / slow edge) got a false
                                // "Registration is disabled" toast and was
                                // blocked from sign-up. An absent key now
                                // falls through to the sign-up screen — the
                                // backend remains the single source of truth
                                // and still answers 403 "Registration is
                                // disabled" when account_creation is off.
                                final String? isCreateAccount =
                                    Get.find<SettingsService>().getSetting(
                                      "account_creation",
                                    );
                                if (isCreateAccount == null ||
                                    isCreateAccount == "1") {
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
                      ],
                    ),
                  ),
                ],
              ),
            ),
              ),
            ),
            // Button already shows spinner — keep overlay only for biometric path depth.
            Obx(
              () => Visibility(
                visible: controller.isLoading.value &&
                    controller.showBiometricButton.value,
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

class _TelegramSignInButton extends StatelessWidget {
  final AppLocalizations localizations;
  const _TelegramSignInButton({required this.localizations});

  @override
  Widget build(BuildContext context) {
    // Soft-entry only: password login remains the primary path.
    // When the backend sets telegram_login=1 and ships a URL/token API,
    // this button can be wired without changing the main form.
    return OutlinedButton.icon(
      onPressed: () {
        final settings = Get.isRegistered<SettingsService>()
            ? Get.find<SettingsService>()
            : null;
        final enabled = settings?.getSetting('telegram_login') == '1';
        if (!enabled) {
          ToastHelper().showErrorToast(
            localizations.signInTelegramUnavailable,
          );
          return;
        }
        ToastHelper().showErrorToast(
          localizations.signInTelegramUnavailable,
        );
      },
      icon: const Icon(Icons.send_rounded, size: 20),
      label: Text(
        localizations.signInWithTelegram,
        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.sp),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 48.h),
        side: BorderSide(color: AppColors.lightBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
