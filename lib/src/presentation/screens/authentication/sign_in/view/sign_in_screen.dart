import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';
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
import 'package:ecardo_user/src/helper/l10n_pick.dart';
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
        backgroundColor: AppColors.lightBackground,
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
                    height: 0.26.sh,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        PositionedDirectional(
                          top: 12.h,
                          end: 18.w,
                          child: const _LanguagePickerButton(),
                        ),
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
                              width: 160.w,
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
                    // UX-FIX (login): minHeight instead of fixed 70% — with
                    // the keyboard open a fixed 0.70.sh pushed the login
                    // button below the fold and the sheet clipped it.
                    constraints: BoxConstraints(minHeight: 0.62.sh),
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
                                    onChanged: controller.onEmailChanged,
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
                                    onChanged: controller.onPasswordChanged,
                                    isFocused:
                                        controller.isPasswordFocused.value,
                                    obscureText:
                                        controller.isPasswordVisible.value,
                                    keyboardType: TextInputType.visiblePassword,
                                    // UX-FIX (login): keyboard "done" now
                                    // submits the form instead of just
                                    // closing the keyboard.
                                    textInputAction: TextInputAction.done,
                                    onFieldSubmitted: (_) {
                                      if (!controller.isLoading.value) {
                                        controller.submitSignIn();
                                      }
                                    },
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
                                l10nPick(
                                  context,
                                  en: 'Sign in with fingerprint / face',
                                  fa: 'ورود با اثرانگشت / چهره',
                                  ar: 'تسجيل الدخول بالبصمة / الوجه',
                                  zh: '使用指纹 / 面容登录',
                                ),
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
                        SizedBox(height: 12.h),
                        // WAVE-1: passwordless entry via email code — no SMS
                        // dependency, so CN/RU/AR users can always sign in.
                        OutlinedButton.icon(
                          onPressed: () => Get.toNamed(BaseRoute.emailOtpLogin),
                          icon: Icon(
                            Icons.mail_outline_rounded,
                            size: 22.sp,
                            color: AppColors.lightPrimary,
                          ),
                          label: Text(
                            l10nPick(
                              context,
                              en: 'Sign in with email code',
                              fa: 'ورود با کد ایمیل',
                              ar: 'تسجيل الدخول برمز البريد',
                              zh: '使用邮箱验证码登录',
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                              color: AppColors.lightPrimary,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            minimumSize: Size(double.infinity, 48.h),
                            side: BorderSide(
                              color:
                                  AppColors.lightPrimary.withValues(alpha: 0.45),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        // Demo & Test Mode Entry Button (completely hidden when disabled by Admin kill-switch)
                        Obx(() {
                          if (Get.isRegistered<DemoAccountService>() &&
                              !DemoAccountService.to.isDemoAllowedByAdmin.value) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: EdgeInsets.only(top: 14.h),
                            child: const _DemoAccountSignInButton(),
                          );
                        }),
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


class _LanguagePickerButton extends StatelessWidget {
  const _LanguagePickerButton();

  @override
  Widget build(BuildContext context) {
    final currentCode = Localizations.localeOf(context).languageCode;
    final currentName = LocaleThemeService.nativeName(currentCode);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLanguageModal(context),
        borderRadius: BorderRadius.circular(20.r),
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: AppColors.lightPrimary.withValues(alpha: 0.35),
              width: 1.2.w,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 10.r,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 16.sp,
                color: AppColors.lightPrimary,
              ),
              SizedBox(width: 5.w),
              Text(
                currentName,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16.sp,
                color: AppColors.lightTextTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageModal(BuildContext context) {
    final currentCode = Localizations.localeOf(context).languageCode;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.lightBorder,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                l10nPick(
                  context,
                  en: 'Select language',
                  fa: 'انتخاب زبان',
                  ar: 'اختر اللغة',
                  zh: '选择语言',
                ),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              SizedBox(height: 12.h),
              for (final c in LocaleThemeService.supported)
                ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
                  title: Text(
                    LocaleThemeService.nativeName(c),
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: c == currentCode ? FontWeight.w800 : FontWeight.w600,
                      color: c == currentCode
                          ? AppColors.lightPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  trailing: c == currentCode
                      ? Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.lightPrimary,
                          size: 20.sp,
                        )
                      : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (Get.isRegistered<LocaleThemeService>()) {
                      await Get.find<LocaleThemeService>().setLanguage(c);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoAccountSignInButton extends StatelessWidget {
  const _DemoAccountSignInButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: 0.12),
            const Color(0xFF8B5CF6).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
          width: 1.2.w,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () async {
            if (Get.isRegistered<DemoAccountService>()) {
              await DemoAccountService.to.activateDemoMode();
            }
          },
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 20,
                    color: Color(0xFF6366F1),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10nPick(
                          context,
                          en: 'Quick Live Demo (Test Account)',
                          fa: 'ورود سریع با اکانت تست (حالت دمو زنده)',
                          ar: 'تجربة حية سريعة (حساب تجريبي)',
                          zh: '一键体验 (实时演示账户)',
                        ),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.sp,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                      Text(
                        l10nPick(
                          context,
                          en: 'Zero-network interactive test of all 24 services',
                          fa: 'تست زنده و تعاملی کلیه ۲۴ سرویس با بالانس فعال',
                          ar: 'اختبار تفاعلي فوري لجميع الخدمات الـ24',
                          zh: '免网络直接交互测试全部24项服务与余额',
                        ),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
