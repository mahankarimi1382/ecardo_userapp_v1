import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/permission_flow_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

class SignInController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isBiometricEnable = false.obs;
  final RxBool isPressed = false.obs;
  final RxString emailError = "".obs;
  final RxString passwordError = "".obs;
  final RxBool showBiometricButton = false.obs;
  final RxBool formVisible = false.obs;
  final Rx<UserModel> userModel = UserModel().obs;
  final SettingsService settingsService = Get.find<SettingsService>();

  // Email
  final RxBool isEmailFocused = false.obs;
  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();

  // Password
  final RxBool isPasswordFocused = false.obs;
  final RxBool isPasswordVisible = true.obs;
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController passwordController = TextEditingController();

  // Biometric
  final RxString biometricEmail = "".obs;
  final RxString biometricPassword = "".obs;

  // AUTH-BIO follow-up (wave Task-10, QA-VALIDATE finding): credentials
  // staged for persistence AFTER a successful 2FA verification. The non-2FA
  // branch saves them immediately; 2FA users must get the same treatment or
  // the splash biometric gate can never be satisfied for them.
  final RxString pendingTwoFaEmail = "".obs;
  final RxString pendingTwoFaPassword = "".obs;

  @override
  void onInit() {
    super.onInit();
    clearSignUpStatus();
    // AUTH-BIO (A-4): `logged_in` used to be persisted HERE — before the
    // user actually signed in — which corrupted the state semantics (splash
    // sent every visitor back to sign-in forever). Persistence now happens
    // in fetchUser() only after the full auth chain succeeds (and after the
    // 2FA verification for 2FA users — see TwoFactorAuthController).
    loadSavedEmail();
    loadBiometricStatus();
    refreshBiometricButton();
    // Stagger form entrance animation flag
    Future.delayed(const Duration(milliseconds: 80), () {
      formVisible.value = true;
    });

    emailFocusNode.addListener(_handleEmailFocusChange);
    passwordFocusNode.addListener(_handlePasswordFocusChange);
  }

  @override
  void onClose() {
    emailFocusNode.removeListener(_handleEmailFocusChange);
    passwordFocusNode.removeListener(_handlePasswordFocusChange);
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  Future<void> clearSignUpStatus() async {
    // phase2-fix: visiting the sign-in screen must NOT wipe a valid session
    // token (it used to — any navigation here logged the user out).
    await Get.find<SettingsService>().saveEmailVerified(false);
    await Get.find<SettingsService>().saveSetUpPassword(false);
  }

  Future<void> setLogInState() async {
    // AUTH-BIO (A-4): called only after the full auth chain succeeds
    // (fetchUser / 2FA verification), never at controller init.
    await settingsService.saveLoginCurrentState("logged_in");
  }

  Future<void> loadBiometricStatus() async {
    final saved = await SettingsService.getBiometricEnableOrDisable();
    isBiometricEnable.value = saved ?? false;
  }

  Future<void> loadSavedEmail() async {
    final savedEmail = await SettingsService.getLoggedInUserEmail();
    if (savedEmail != null && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
    }
  }

  void _handleEmailFocusChange() {
    isEmailFocused.value = emailFocusNode.hasFocus;
  }

  void _handlePasswordFocusChange() {
    isPasswordFocused.value = passwordFocusNode.hasFocus;
  }


  Future<void> refreshBiometricButton() async {
    try {
      final bio = BiometricAuthService();
      final available = await bio.isBiometricAvailable();
      final enabledPref = await SettingsService.getBiometricEnableOrDisable();
      final enabled = enabledPref == true ||
          settingsService.currentBiometric.value == true;
      final email = await SettingsService.getLoggedInUserEmail();
      final token = Get.isRegistered<TokenService>()
          ? Get.find<TokenService>().accessToken.value
          : null;
      final hasSession = (email != null && email.isNotEmpty) ||
          (token != null && token.isNotEmpty);
      // Hide (not disable) when unsupported or OS biometrics cancelled.
      showBiometricButton.value = available && enabled && hasSession;
    } catch (_) {
      showBiometricButton.value = false;
    }
  }

  bool validateForm() {
    emailError.value = '';
    passwordError.value = '';
    final email = emailController.text.trim();
    final pass = passwordController.text;
    var ok = true;
    if (email.isEmpty) {
      emailError.value = 'ایمیل یا نام کاربری الزامی است';
      ok = false;
    } else if (!email.contains('@') && email.length < 3) {
      emailError.value = 'مقدار وارد شده معتبر نیست';
      ok = false;
    } else if (email.contains('@') &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailError.value = 'فرمت ایمیل صحیح نیست';
      ok = false;
    }
    if (pass.isEmpty) {
      passwordError.value = 'رمز عبور الزامی است';
      ok = false;
    } else if (pass.length < 4) {
      passwordError.value = 'رمز عبور خیلی کوتاه است';
      ok = false;
    }
    return ok;
  }

  String _friendlyNetworkError(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        return 'زمان اتصال تمام شد. اینترنت را بررسی کنید.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'اتصال به اینترنت برقرار نیست.';
      }
      final code = e.response?.statusCode;
      if (code == 401 || code == 422) {
        return 'ایمیل یا رمز عبور نادرست است.';
      }
      if (code != null && code >= 500) {
        return 'خطای سرور. کمی بعد دوباره تلاش کنید.';
      }
    }
    final s = e.toString().toLowerCase();
    if (s.contains('socket') || s.contains('network') || s.contains('failed host')) {
      return 'اتصال به اینترنت برقرار نیست.';
    }
    return AppLocalizations.of(Get.context!)?.allControllerLoadError ??
        'خطایی رخ داد. دوباره تلاش کنید.';
  }

  Future<void> signInWithBiometricTap() async {
    final bio = BiometricAuthService();
    if (!await bio.isBiometricAvailable()) {
      showBiometricButton.value = false;
      return;
    }
    final ok = await bio.authenticateWithBiometrics();
    if (!ok) return;

    isLoading.value = true;
    try {
      final token = Get.find<TokenService>().accessToken.value;
      if (token == null || token.isEmpty) {
        ToastHelper().showErrorToast(
          'نشست منقضی شده. با ایمیل و رمز وارد شوید.',
        );
        showBiometricButton.value = false;
        return;
      }
      try {
        await FirebaseMessagingService.instance().registerTokenWithBackend();
      } catch (_) {}
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        userModel.value = UserModel.fromJson(response.data!);
        await setLogInState();
        final completed = userModel.value.data?.boardingSteps?.completed == true;
        if (completed) {
          Get.offAllNamed(BaseRoute.navigation);
        } else {
          Get.toNamed(
            BaseRoute.signUpStatus,
            arguments: {"is_login_state": true},
          );
        }
      } else {
        ToastHelper().showErrorToast('ورود با بیومتریک ناموفق بود.');
      }
    } catch (e) {
      ToastHelper().showErrorToast(_friendlyNetworkError(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitSignIn({bool useBiometric = false}) async {
    if (!useBiometric && !validateForm()) return;

    isLoading.value = true;

    final String email = useBiometric
        ? biometricEmail.value.trim()
        : emailController.text.trim();

    final String password = useBiometric
        ? biometricPassword.value.trim()
        : passwordController.text.trim();

    try {
      final response = await Get.find<NetworkService>().login(
        email: email,
        password: password,
      );

      if (response.status == Status.completed) {
        // Enable biometric for next visits when device supports it.
        try {
          final bio = BiometricAuthService();
          if (await bio.isBiometricAvailable()) {
            await settingsService.saveBiometricEnableOrDisable(true);
          }
        } catch (_) {}
        if (Get.isRegistered<PermissionFlowService>()) {
          await Get.find<PermissionFlowService>().requestNotification(
            context: Get.context,
            explain: true,
          );
        }
        await postFcmNotification(
          email: email,
          password: password,
          useBiometric: useBiometric,
        );
        await refreshBiometricButton();
      }
    } catch (e, s) {
      debugPrint('❌ submitSignIn() error: $e');
      debugPrint('📍 StackTrace: $s');
      ToastHelper().showErrorToast(_friendlyNetworkError(e));
    } finally {
      isLoading.value = false;
      if (useBiometric) {
        biometricPassword.value = '';
      }
    }
  }

  Future<void> fetchUser({bool useBiometric = false}) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );

      if (response.status == Status.completed) {
        userModel.value = UserModel.fromJson(response.data!);

        // v1.0.24 (2FA bypass fix): when the user has 2FA enabled the client
        // MUST route to the verification screen. The previous condition
        // additionally required the local `fa_verification` setting to be
        // exactly "1" — if that setting was missing/“0” the check was
        // silently skipped and the app continued to the account even for
        // 2FA-protected users. Server-side TwoFaCheck remains the real gate.
        if (userModel.value.data!.twoFa == true) {
          // AUTH-BIO follow-up: stash the would-be-saved credentials so
          // TwoFactorAuthController persists them once the full auth chain
          // completes (same expressions as the non-2FA branch below).
          pendingTwoFaEmail.value =
              useBiometric ? biometricEmail.value : emailController.text;
          pendingTwoFaPassword.value =
              useBiometric ? biometricPassword.value : passwordController.text;
          Get.toNamed(BaseRoute.twoFactorAuth);
        } else {
          await Get.find<SettingsService>().saveLoggedInUserEmail(
            useBiometric ? biometricEmail.value : emailController.text,
          );
          // 1.0.51: never persist password for biometric re-entry — token only.
          await Get.find<SettingsService>().clearLoggedInUserPassword();

          // AUTH-BIO (A-4): persist `logged_in` only after the full auth
          // chain (login → FCM registration → fetchUser) has succeeded.
          await setLogInState();

          if (userModel.value.data!.boardingSteps?.completed == true) {
            Get.offAllNamed(BaseRoute.navigation);
            resetFields();
          } else {
            Get.toNamed(
              BaseRoute.signUpStatus,
              arguments: {"is_login_state": true},
            );
          }
        }
      }
    } catch (e, s) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $s');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> postFcmNotification({
    required String email,
    required String password,
    required bool useBiometric,
  }) async {
    try {
      // AUTH-BIO (A-3): single source of truth for the getSetupFcm device
      // registration (shared with the token-refresh path in
      // FirebaseMessagingService). Same endpoint, same payload shape.
      await FirebaseMessagingService.instance().registerTokenWithBackend();
    } catch (e, s) {
      debugPrint('❌ postFcmNotification() error: $e');
      debugPrint('📍 StackTrace: $s');
    } finally {
      await fetchUser(useBiometric: useBiometric);
    }
  }

  void resetFields() {
    emailController.clear();
    passwordController.clear();
    isEmailFocused.value = false;
    isPasswordFocused.value = false;
  }
}
