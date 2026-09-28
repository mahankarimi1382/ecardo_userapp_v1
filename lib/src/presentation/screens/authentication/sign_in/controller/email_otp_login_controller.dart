import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

/// WAVE-1: passwordless sign-in with a 6-digit email code.
///
/// Additive to the password path (which stays primary). After a successful
/// verify the token is already persisted by [NetworkService.verifyLoginOtp],
/// and the EXACT post-login chain of [SignInController.fetchUser] runs —
/// including the TOTP 2FA gate and the passcode/onboarding routing — so the
/// two entry paths can never drift apart.
class EmailOtpLoginController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool codeSent = false.obs;
  final RxString emailError = ''.obs;
  final RxInt countdown = 0.obs;
  Timer? _timer;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();

  String _pick({
    required String en,
    required String fa,
    String? ar,
    String? zh,
  }) {
    final ctx = Get.context;
    if (ctx == null) return en;
    return l10nPick(ctx, en: en, fa: fa, ar: ar, zh: zh);
  }

  @override
  void onClose() {
    _timer?.cancel();
    emailController.dispose();
    pinCodeController.dispose();
    super.onClose();
  }

  bool _validateEmail() {
    emailError.value = '';
    final email = emailController.text.trim();
    if (email.isEmpty) {
      emailError.value = _pick(
        en: 'Email is required',
        fa: 'ایمیل الزامی است',
        ar: 'البريد الإلكتروني مطلوب',
        zh: '请输入邮箱',
      );
      return false;
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailError.value = _pick(
        en: 'Enter a valid email address',
        fa: 'فرمت ایمیل صحیح نیست',
        ar: 'أدخل بريدًا إلكترونيًا صحيحًا',
        zh: '邮箱格式不正确',
      );
      return false;
    }
    return true;
  }

  Future<void> requestCode() async {
    if (!_validateEmail()) return;
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().requestLoginOtp(
        email: emailController.text.trim(),
      );
      if (response.status == Status.completed) {
        codeSent.value = true;
        _startTimer();
        ToastHelper().showSuccessToast(_pick(
          en: 'If the email belongs to an account, a login code has been sent',
          fa: 'اگر ایمیل متعلق به یک حساب باشد، کد ورود ارسال شد',
          ar: 'إذا كان البريد يخص حسابًا، فقد أُرسل رمز الدخول',
          zh: '如邮箱属于某个账户，登录验证码已发送',
        ));
      }
    } catch (e, s) {
      debugPrint('❌ requestCode() error: $e');
      debugPrint('📍 StackTrace: $s');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyCode() async {
    final code = pinCodeController.text.trim();
    if (code.length != 6) {
      ToastHelper().showErrorToast(_pick(
        en: 'Enter the 6-digit code',
        fa: 'کد ۶ رقمی را وارد کنید',
        ar: 'أدخل الرمز المكوّن من ٦ أرقام',
        zh: '请输入 6 位验证码',
      ));
      return;
    }
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().verifyLoginOtp(
        email: emailController.text.trim(),
        code: code,
      );
      if (response.status == Status.completed) {
        pinCodeController.clear();
        final signIn = Get.isRegistered<SignInController>()
            ? Get.find<SignInController>()
            : null;
        if (signIn != null) {
          // Stage the email for the 2FA screen, then reuse the shared
          // post-login chain (fetchUser handles 2FA / passcode / onboarding).
          signIn.pendingTwoFaEmail.value = emailController.text.trim();
          await signIn.fetchUser();
        } else {
          // Fallback: entered the OTP screen without the sign-in stack.
          await Get.find<SettingsService>().saveLoginCurrentState('logged_in');
          await Get.find<SettingsService>()
              .saveLoggedInUserEmail(emailController.text.trim());
          Get.offAllNamed(BaseRoute.navigation);
        }
      }
    } catch (e, s) {
      debugPrint('❌ verifyCode() error: $e');
      debugPrint('📍 StackTrace: $s');
      // UX-FIX (otp): a wrong/expired code must clear the boxes so the
      // user re-types cleanly instead of wondering why Verify is dead.
      pinCodeController.clear();
      ToastHelper().showErrorToast(_pick(
        en: 'The code is wrong or expired. Try again.',
        fa: 'کد اشتباه یا منقضی شده است. دوباره تلاش کنید.',
        ar: 'الرمز خاطئ أو منتهي. حاول مرة أخرى.',
        zh: '验证码错误或已过期，请重试。',
      ));
    } finally {
      isLoading.value = false;
    }
  }

  void _startTimer() {
    countdown.value = 45;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }
}
