import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/app_bar/common_default_app_bar.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/common/widgets/common_loading.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/mask_email_helper.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/email_otp_login_controller.dart';

/// WAVE-1: passwordless sign-in with a 6-digit email code — an entry path
/// that needs no SMS, so Chinese/Russian/Arab users can always get in.
/// Strings go through l10nPick (no ARB codegen needed on the server).
class EmailOtpLoginScreen extends StatelessWidget {
  const EmailOtpLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    String pick({
      required String en,
      required String fa,
      String? ar,
      String? zh,
    }) =>
        l10nPick(context, en: en, fa: fa, ar: ar, zh: zh);

    return Scaffold(
      appBar: CommonDefaultAppBar(),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 24.h),
              child: Obx(() {
                final controller = Get.find<EmailOtpLoginController>();
                return controller.codeSent.value
                    ? _codeStage(context, controller, localizations, pick)
                    : _emailStage(context, controller, localizations, pick);
              }),
            ),
          ),
          Obx(() {
            final controller = Get.find<EmailOtpLoginController>();
            return Visibility(
              visible: controller.isLoading.value,
              child: const CommonLoading(),
            );
          }),
        ],
      ),
    );
  }

  // ----------------------------- stage 1: email ----------------------------

  Widget _emailStage(
    BuildContext context,
    EmailOtpLoginController controller,
    AppLocalizations? localizations,
    String Function({required String en, required String fa, String? ar, String? zh})
        pick,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pick(
            en: 'Sign in with email code',
            fa: 'ورود با کد ایمیل',
            ar: 'تسجيل الدخول برمز البريد',
            zh: '使用邮箱验证码登录',
          ),
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w900,
            fontSize: 22.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          pick(
            en: 'We send a 6-digit code to your email — no password needed.',
            fa: 'کد ۶ رقمی به ایمیل شما ارسال می‌شود — بدون نیاز به رمز عبور.',
            ar: 'نرسل رمزًا من ٦ أرقام إلى بريدك — دون الحاجة إلى كلمة مرور.',
            zh: '我们将向您的邮箱发送 6 位验证码——无需密码。',
          ),
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.lightTextTertiary,
          ),
        ),
        SizedBox(height: 24.h),
        TextField(
          controller: controller.emailController,
          keyboardType: TextInputType.emailAddress,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextPrimary,
          ),
          decoration: InputDecoration(
            hintText: pick(
              en: 'Email address',
              fa: 'آدرس ایمیل',
              ar: 'البريد الإلكتروني',
              zh: '邮箱地址',
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
        Obx(() {
          if (controller.emailError.value.isEmpty) {
            return const SizedBox.shrink();
          }
          return Padding(
            padding: EdgeInsets.only(top: 8.h),
            child: Text(
              controller.emailError.value,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }),
        SizedBox(height: 20.h),
        Obx(
          () => CommonButton(
            isLoading: controller.isLoading.value,
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    await controller.requestCode();
                  },
            width: double.infinity,
            text: pick(
              en: 'Send code',
              fa: 'ارسال کد',
              ar: 'إرسال الرمز',
              zh: '发送验证码',
            ),
          ),
        ),
        SizedBox(height: 12.h),
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            pick(
              en: 'Sign in with password instead',
              fa: 'ورود با رمز عبور',
              ar: 'تسجيل الدخول بكلمة المرور',
              zh: '使用密码登录',
            ),
            style: TextStyle(
              letterSpacing: 0,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              color: AppColors.lightPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ----------------------------- stage 2: code -----------------------------

  Widget _codeStage(
    BuildContext context,
    EmailOtpLoginController controller,
    AppLocalizations? localizations,
    String Function({required String en, required String fa, String? ar, String? zh})
        pick,
  ) {
    final email = controller.emailController.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pick(
            en: 'Enter the code',
            fa: 'کد را وارد کنید',
            ar: 'أدخل الرمز',
            zh: '输入验证码',
          ),
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w900,
            fontSize: 22.sp,
            color: AppColors.lightTextPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          pick(
            en: 'Code sent to ',
            fa: 'کد به این آدرس ارسال شد: ',
            ar: 'أُرسل الرمز إلى ',
            zh: '验证码已发送至 ',
          ) +
              MaskEmailHelper.maskEmail(email),
          style: TextStyle(
            letterSpacing: 0,
            fontWeight: FontWeight.w600,
            fontSize: 14.sp,
            color: AppColors.lightTextTertiary,
          ),
        ),
        SizedBox(height: 24.h),
        PinCodeTextField(
          keyboardType: TextInputType.number,
          cursorColor: AppColors.lightPrimary,
          textStyle: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16.sp,
            color: AppColors.lightTextPrimary,
            letterSpacing: 0,
          ),
          controller: controller.pinCodeController,
          pinTheme: PinTheme(
            borderWidth: 1.5.w,
            activeBorderWidth: 1.5.w,
            inactiveBorderWidth: 1.5.w,
            shape: PinCodeFieldShape.box,
            fieldHeight: 48.h,
            fieldWidth: 45.w,
            activeColor: AppColors.lightPrimary.withValues(alpha: 0.60),
            activeFillColor: AppColors.transparent,
            inactiveColor: AppColors.lightTextPrimary.withValues(alpha: 0.20),
            inactiveFillColor: AppColors.transparent,
            selectedColor: AppColors.lightPrimary.withValues(alpha: 0.60),
            selectedFillColor: AppColors.transparent,
            selectedBorderWidth: 1.5.w,
            borderRadius: BorderRadius.circular(16.r),
          ),
          appContext: context,
          length: 6,
        ),
        SizedBox(height: 20.h),
        Obx(
          () => CommonButton(
            isLoading: controller.isLoading.value,
            onPressed: controller.isLoading.value
                ? null
                : () async {
                    await controller.verifyCode();
                  },
            width: double.infinity,
            text: pick(
              en: 'Verify & sign in',
              fa: 'تأیید و ورود',
              ar: 'تحقق وتسجيل الدخول',
              zh: '验证并登录',
            ),
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: Obx(
            () => GestureDetector(
              onTap: () {
                if (controller.countdown.value == 0) {
                  controller.requestCode();
                }
              },
              child: Text(
                controller.countdown.value > 0
                    ? '${pick(en: 'Resend available in', fa: 'ارسال مجدد تا', ar: 'إعادة الإرسال بعد', zh: '重新发送倒计时')} ${controller.countdown.value}s'
                    : pick(
                        en: 'Resend code',
                        fa: 'ارسال مجدد کد',
                        ar: 'إعادة إرسال الرمز',
                        zh: '重新发送验证码',
                      ),
                style: TextStyle(
                  letterSpacing: 0,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: controller.countdown.value == 0
                      ? AppColors.lightPrimary
                      : AppColors.lightTextTertiary,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: TextButton(
            onPressed: () {
              controller.codeSent.value = false;
              controller.pinCodeController.clear();
            },
            child: Text(
              pick(
                en: 'Change email address',
                fa: 'تغییر آدرس ایمیل',
                ar: 'تغيير عنوان البريد',
                zh: '更改邮箱地址',
              ),
              style: TextStyle(
                letterSpacing: 0,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: AppColors.lightTextTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
