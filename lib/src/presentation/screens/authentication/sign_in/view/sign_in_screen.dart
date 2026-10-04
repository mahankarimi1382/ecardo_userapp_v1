import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/bottom_sheet/common_alert_bottom_sheet.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/mask_email_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/ambient_auth_background.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/auth_language_pill.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/shared/creative_floating_text_field.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/email_otp_login_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with TickerProviderStateMixin {
  late final SignInController controller;
  late final EmailOtpLoginController otpController;

  late final AnimationController _enterCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Biometric pulse animation
  late final AnimationController _bioPulseCtrl;
  late final Animation<double> _bioPulseScale;
  late final Animation<double> _bioGlowOpacity;

  // 0: Password Tab, 1: One-Time Code (OTP) Tab
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SignInController>()
        ? Get.find<SignInController>()
        : Get.put(SignInController());
    otpController = Get.isRegistered<EmailOtpLoginController>()
        ? Get.find<EmailOtpLoginController>()
        : Get.put(EmailOtpLoginController());

    _enterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fade = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));
    _enterCtrl.forward();

    _bioPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bioPulseScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _bioPulseCtrl, curve: Curves.easeInOut),
    );
    _bioGlowOpacity = Tween<double>(begin: 0.25, end: 0.65).animate(
      CurvedAnimation(parent: _bioPulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _enterCtrl.dispose();
    _bioPulseCtrl.dispose();
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, _) {
        showExitApplicationAlertDialog();
      },
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF090D1A) : AppColors.lightBackground,
        appBar: const CommonDefaultAppBar(),
        body: AmbientAuthBackground(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          // Top Ambient Brand Header
                          _buildTopHeader(context, isDark, localizations),

                          SizedBox(height: 12.h),

                          // Modern Flagship Auth Card Container
                          _buildAuthCard(
                            context,
                            isDark: isDark,
                            primaryTextColor: primaryTextColor,
                            secondaryTextColor: secondaryTextColor,
                            localizations: localizations,
                          ),

                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Full Screen Loading Overlay (when biometric or general submission in flight)
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
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    bool isDark,
    AppLocalizations localizations,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo with radiant aura
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: (isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.mainSoftBlue)
                          .withValues(alpha: isDark ? 0.18 : 0.28),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  PngAssets.appLogo,
                  fit: BoxFit.contain,
                  height: 32.h,
                ),
              ),

              // Language selector pill
              const AuthLanguagePill(),
            ],
          ),
          SizedBox(height: 18.h),
          Text(
            localizations.signInWelcomeBack,
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: -0.5,
              fontWeight: FontWeight.w900,
              fontSize: 26.sp,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            localizations.signInSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w500,
              fontSize: 14.sp,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard(
    BuildContext context, {
    required bool isDark,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required AppLocalizations localizations,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 480),
      child: EcardoGlassCard(
        variant: EcardoGlassVariant.frosted,
        interactive: false,
        margin: EdgeInsets.symmetric(horizontal: 18.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 22.h),
        borderRadius: 28.r,
        child: Column(
          children: [
            // Quick Demo Account Banner in dev/evaluator mode
            Builder(
              builder: (context) {
                if (!DemoAccountService.isDemoAvailableInThisBuild ||
                    !Get.isRegistered<DemoAccountService>()) {
                  return const SizedBox.shrink();
                }
                return Obx(() {
                  if (DemoAccountService.to.isDemoBlockedByAdmin) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: const _DemoAccountSignInButton(),
                  );
                });
              },
            ),

            // OTP / Password Login Toggle Tab
            _buildLoginModeToggle(context, isDark: isDark),

            SizedBox(height: 20.h),

            // Tab View Body: 0 = Password Form, 1 = One-Time Password Form
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.04),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: _selectedTab == 0
                  ? _buildPasswordForm(context, isDark, localizations)
                  : _buildOtpForm(context, isDark, localizations),
            ),

            // Instant Pulsing Biometric Button
            Obx(() {
              if (!controller.showBiometricButton.value) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: _buildBiometricSection(context, isDark),
              );
            }),

            SizedBox(height: 16.h),

            // Telegram Login Option
            _TelegramSignInButton(localizations: localizations),

            SizedBox(height: 22.h),

            // Register / Create Account Footer
            _buildCreateAccountPrompt(context, isDark, localizations),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginModeToggle(BuildContext context, {required bool isDark}) {
    final trackBg = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF1F5F9);
    final activeBg = isDark ? const Color(0xFF1E293B) : AppColors.white;
    final activeText =
        isDark ? const Color(0xFF38BDF8) : AppColors.lightTextPrimary;
    final inactiveText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextTertiary;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: trackBg,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : AppColors.lightBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTab != 0) {
                  setState(() => _selectedTab = 0);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _selectedTab == 0 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: _selectedTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.06,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 17.sp,
                      color: _selectedTab == 0 ? activeText : inactiveText,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Password',
                          fa: 'رمز عبور',
                          ar: 'كلمة المرور',
                          zh: '密码登录',
                          tr: 'Şifre',
                          ru: 'Пароль',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: _selectedTab == 0
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: _selectedTab == 0 ? activeText : inactiveText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_selectedTab != 1) {
                  setState(() => _selectedTab = 1);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: EdgeInsets.symmetric(vertical: 10.h),
                decoration: BoxDecoration(
                  color: _selectedTab == 1 ? activeBg : Colors.transparent,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: _selectedTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isDark ? 0.25 : 0.06,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.mark_email_read_outlined,
                      size: 17.sp,
                      color: _selectedTab == 1 ? activeText : inactiveText,
                    ),
                    SizedBox(width: 6.w),
                    Flexible(
                      child: Text(
                        l10nPick(
                          context,
                          en: 'One-Time Code (OTP)',
                          fa: 'کد یک‌بارمصرف',
                          ar: 'رمز الدخول (OTP)',
                          zh: '验证码登录',
                          tr: 'Tek Seferlik Kod',
                          ru: 'Код из почты',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: _selectedTab == 1
                              ? FontWeight.w900
                              : FontWeight.w600,
                          color: _selectedTab == 1 ? activeText : inactiveText,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordForm(
    BuildContext context,
    bool isDark,
    AppLocalizations localizations,
  ) {
    return AutofillGroup(
      child: Column(
        key: const ValueKey('password_form'),
        children: [
          // Floating Label Email Field
          Obx(
            () => CreativeFloatingTextField(
              label: localizations.signInEmail,
              isRequired: true,
              controller: controller.emailController,
              focusNode: controller.emailFocusNode,
              isFocused: controller.isEmailFocused.value,
              onChanged: controller.onEmailChanged,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              errorText: controller.emailError.value.isNotEmpty
                  ? controller.emailError.value
                  : null,
              prefixIcon: Icon(
                Icons.mail_outline_rounded,
                size: 20.sp,
                color: controller.isEmailFocused.value
                    ? (isDark ? const Color(0xFF38BDF8) : AppColors.deepBlack)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary),
              ),
            ),
          ),

          SizedBox(height: 14.h),

          // Floating Label Password Field
          Obx(
            () => CreativeFloatingTextField(
              label: localizations.signInPassword,
              isRequired: true,
              controller: controller.passwordController,
              focusNode: controller.passwordFocusNode,
              isFocused: controller.isPasswordFocused.value,
              onChanged: controller.onPasswordChanged,
              obscureText: controller.isPasswordVisible.value,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!controller.isLoading.value) {
                  controller.submitSignIn();
                }
              },
              autofillHints: const [AutofillHints.password],
              errorText: controller.passwordError.value.isNotEmpty
                  ? controller.passwordError.value
                  : null,
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 20.sp,
                color: controller.isPasswordFocused.value
                    ? (isDark ? const Color(0xFF38BDF8) : AppColors.deepBlack)
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary),
              ),
              suffixIcon: IconButton(
                onPressed: () => controller.isPasswordVisible.toggle(),
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

          SizedBox(height: 10.h),

          // Forgot Password Link
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: GestureDetector(
              onTap: () => Get.toNamed(BaseRoute.forgotPassword),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                child: Text(
                  localizations.signInForgotPassword,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5.sp,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : AppColors.lightPrimary,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(height: 18.h),

          // Primary Sign In Button
          Obx(
            () => CommonButton(
              height: 52.h,
              borderRadius: 16.r,
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
        ],
      ),
    );
  }

  Widget _buildOtpForm(
    BuildContext context,
    bool isDark,
    AppLocalizations localizations,
  ) {
    return Column(
      key: const ValueKey('otp_form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          if (!otpController.codeSent.value) {
            // Stage 1: Enter email for OTP
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10nPick(
                    context,
                    en: 'Passwordless Sign In',
                    fa: 'ورود بدون رمز عبور',
                    ar: 'دخول بدون كلمة مرور',
                    zh: '免密登录',
                    tr: 'Şifresiz Giriş',
                    ru: 'Вход без пароля',
                  ),
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  l10nPick(
                    context,
                    en: 'We will send a 6-digit security code directly to your email address.',
                    fa: 'یک کد امنیتی ۶ رقمی مستقیماً به آدرس ایمیل شما ارسال خواهد شد.',
                    ar: 'سنرسل رمز أمان مكوّن من ٦ أرقام مباشرة إلى بريدك الإلكتروني.',
                    zh: '我们将直接向您的邮箱发送一个6位安全验证码。',
                    tr: 'E-posta adresinize 6 haneli güvenlik kodu göndereceğiz.',
                    ru: 'Мы отправим 6-значный код безопасности на вашу почту.',
                  ),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary,
                    height: 1.35,
                  ),
                ),
                SizedBox(height: 14.h),
                CreativeFloatingTextField(
                  label: localizations.signInEmail,
                  isRequired: true,
                  controller: otpController.emailController,
                  keyboardType: TextInputType.emailAddress,
                  autofillHints: const [AutofillHints.email],
                  prefixIcon: Icon(
                    Icons.mail_outline_rounded,
                    size: 20.sp,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextTertiary,
                  ),
                  errorText: otpController.emailError.value.isNotEmpty
                      ? otpController.emailError.value
                      : null,
                ),
                SizedBox(height: 18.h),
                CommonButton(
                  height: 52.h,
                  borderRadius: 16.r,
                  isLoading: otpController.isLoading.value,
                  onPressed: otpController.isLoading.value
                      ? null
                      : () => otpController.requestCode(),
                  width: double.infinity,
                  text: l10nPick(
                    context,
                    en: 'Send Login Code',
                    fa: 'ارسال کد ورود',
                    ar: 'إرسال رمز الدخول',
                    zh: '发送登录验证码',
                    tr: 'Giriş Kodunu Gönder',
                    ru: 'Отправить код',
                  ),
                ),
              ],
            );
          } else {
            // Stage 2: Code Sent, enter 6-digit pin
            final masked = MaskEmailHelper.maskEmail(
              otpController.emailController.text.trim(),
            );
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10nPick(
                        context,
                        en: 'Enter 6-Digit Code',
                        fa: 'کد ۶ رقمی را وارد کنید',
                        ar: 'أدخل الرمز المكوّن من ٦ أرقام',
                        zh: '输入6位验证码',
                        tr: '6 Haneli Kodu Girin',
                        ru: 'Введите 6-значный код',
                      ),
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        otpController.codeSent.value = false;
                      },
                      child: Text(
                        l10nPick(
                          context,
                          en: 'Change email',
                          fa: 'تغییر ایمیل',
                          ar: 'تغيير البريد',
                          zh: '更换邮箱',
                          tr: 'E-postayı değiştir',
                          ru: 'Изменить почту',
                        ),
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFF38BDF8)
                              : AppColors.lightPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '${l10nPick(
                    context,
                    en: 'Code sent to:',
                    fa: 'کد ارسال شد به:',
                    ar: 'أُرسل الرمز إلى:',
                    zh: '验证码已发送至:',
                    tr: 'Kod gönderildi:',
                    ru: 'Код отправлен на:',
                  )} $masked',
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFF38BDF8)
                        : AppColors.lightPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: otpController.pinCodeController,
                  keyboardType: TextInputType.number,
                  cursorColor: isDark
                      ? const Color(0xFF38BDF8)
                      : AppColors.lightPrimary,
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(14.r),
                    fieldHeight: 48.h,
                    fieldWidth: 42.w,
                    activeColor: isDark
                        ? const Color(0xFF38BDF8)
                        : AppColors.lightPrimary,
                    inactiveColor: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : AppColors.lightBorder,
                    selectedColor: isDark
                        ? const Color(0xFF38BDF8)
                        : AppColors.lightPrimary,
                    activeFillColor: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : const Color(0xFFF8FAFC),
                    inactiveFillColor: Colors.transparent,
                    selectedFillColor: isDark
                        ? const Color(0xFF38BDF8).withValues(alpha: 0.1)
                        : AppColors.lightSecondaryContainer,
                  ),
                  enableActiveFill: true,
                  onCompleted: (_) {
                    otpController.verifyCode();
                  },
                ),
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      otpController.countdown.value > 0
                          ? "${l10nPick(
                              context,
                              en: 'Resend in',
                              fa: 'ارسال مجدد تا',
                              ar: 'إعادة الإرسال خلال',
                              zh: '重新发送倒计时',
                              tr: 'Kalan süre',
                              ru: 'Повтор через',
                            )} ${otpController.countdown.value}s"
                          : '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                    if (otpController.countdown.value == 0)
                      GestureDetector(
                        onTap: () => otpController.requestCode(),
                        child: Text(
                          l10nPick(
                            context,
                            en: 'Resend Code',
                            fa: 'ارسال دوباره کد',
                            ar: 'إعادة إرسال الرمز',
                            zh: '重新发送验证码',
                            tr: 'Kodu Tekrar Gönder',
                            ru: 'Отправить повторно',
                          ),
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? const Color(0xFF38BDF8)
                                : AppColors.lightPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 18.h),
                CommonButton(
                  height: 52.h,
                  borderRadius: 16.r,
                  isLoading: otpController.isLoading.value,
                  onPressed: otpController.isLoading.value
                      ? null
                      : () => otpController.verifyCode(),
                  width: double.infinity,
                  text: l10nPick(
                    context,
                    en: 'Verify & Sign In',
                    fa: 'تأیید و ورود',
                    ar: 'التحقق وتسجيل الدخول',
                    zh: '验证并登录',
                    tr: 'Doğrula ve Giriş Yap',
                    ru: 'Подтвердить и войти',
                  ),
                ),
              ],
            );
          }
        }),
      ],
    );
  }

  Widget _buildBiometricSection(BuildContext context, bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1E293B).withValues(alpha: 0.6)
            : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: (isDark ? const Color(0xFF38BDF8) : AppColors.deepBlack)
              .withValues(alpha: 0.20),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          // Large Pulsing Biometric Glyph
          ScaleTransition(
            scale: _bioPulseScale,
            child: AnimatedBuilder(
              animation: _bioGlowOpacity,
              builder: (context, child) {
                return Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? const [Color(0xFF38BDF8), Color(0xFF6366F1)]
                          : const [AppColors.deepBlack, Color(0xFF3F3F46)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isDark
                                ? const Color(0xFF38BDF8)
                                : AppColors.deepBlack)
                            .withValues(alpha: _bioGlowOpacity.value),
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: child,
                );
              },
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: controller.isLoading.value
                    ? null
                    : () => controller.signInWithBiometricTap(),
                icon: Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: 30.sp,
                ),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: InkWell(
              onTap: controller.isLoading.value
                  ? null
                  : () => controller.signInWithBiometricTap(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10nPick(
                      context,
                      en: 'Instant Biometric Sign In',
                      fa: 'ورود سریع بیومتریک',
                      ar: 'تسجيل الدخول الحيوي الفوري',
                      zh: '即时生物识别登录',
                      tr: 'Anında Biyometrik Giriş',
                      ru: 'Вход по биометрии',
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w900,
                      color: isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    l10nPick(
                      context,
                      en: 'One tap with Fingerprint or Face ID',
                      fa: 'یک لمس با اثرانگشت یا تشخیص چهره',
                      ar: 'نقرة واحدة بالبصمة أو بصمة الوجه',
                      zh: '一触即达：支持指纹或面容ID',
                      tr: 'Parmak izi veya Yüz Tanıma ile tek dokunuş',
                      ru: 'Одно касание пальцем или Face ID',
                    ),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextTertiary,
            size: 24.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildCreateAccountPrompt(
    BuildContext context,
    bool isDark,
    AppLocalizations localizations,
  ) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          localizations.signInNotRegistered,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextTertiary,
          ),
        ),
        SizedBox(width: 4.w),
        GestureDetector(
          onTap: () {
            final String? isCreateAccount =
                Get.find<SettingsService>().getSetting(
              "account_creation",
            );
            if (isCreateAccount == null || isCreateAccount == "1") {
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
              fontWeight: FontWeight.w900,
              fontSize: 14.sp,
              color: isDark ? const Color(0xFF38BDF8) : AppColors.lightPrimary,
            ),
          ),
        ),
      ],
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      icon: Icon(
        Icons.send_rounded,
        size: 19.sp,
        color: const Color(0xFF2AABEE), // Telegram brand blue
      ),
      label: Text(
        localizations.signInWithTelegram,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14.sp,
          color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
        ),
      ),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, 48.h),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.15)
              : AppColors.lightBorder,
          width: 1.2,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      ),
    );
  }
}

class _DemoAccountSignInButton extends StatelessWidget {
  const _DemoAccountSignInButton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF6366F1).withValues(alpha: isDark ? 0.20 : 0.12),
            const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.16 : 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () async {
            if (!DemoAccountService.isDemoAvailableInThisBuild ||
                !Get.isRegistered<DemoAccountService>() ||
                DemoAccountService.to.isDemoBlockedByAdmin) {
              return;
            }
            await DemoAccountService.to.activateDemoMode();
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.bolt_rounded,
                    color: const Color(0xFF818CF8),
                    size: 20.sp,
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
                          en: 'Quick Evaluator Demo Mode',
                          fa: 'ورود سریع حالت دمو برای ارزیابی',
                          ar: 'وضع التقييم التجريبي السريع',
                          zh: '评估员快速体验演示',
                          tr: 'Hızlı Değerlendirici Demo Modu',
                          ru: 'Быстрый демо-режим',
                        ),
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10nPick(
                          context,
                          en: '1-tap sign in to test all fintech features',
                          fa: 'ورود یک‌کلیکه برای تست تمام امکانات',
                          ar: 'دخول بنقرة واحدة لتجربة المزايا',
                          zh: '一键登录测试全套金融功能',
                          tr: 'Tüm özellikleri test etmek için tek tıkla giriş',
                          ru: 'Вход в 1 клик для тестирования всех функций',
                        ),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.sp,
                  color: const Color(0xFF818CF8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
