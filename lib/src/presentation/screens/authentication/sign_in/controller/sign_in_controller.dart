import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/permission_flow_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/helper/network_error_helper.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/services/session_timeout_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/set_passcode_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/set_passcode/set_passcode_screen.dart';

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

  final RxBool isEmailFocused = false.obs;
  final FocusNode emailFocusNode = FocusNode();
  final TextEditingController emailController = TextEditingController();

  final RxBool isPasswordFocused = false.obs;
  final RxBool isPasswordVisible = true.obs;
  final FocusNode passwordFocusNode = FocusNode();
  final TextEditingController passwordController = TextEditingController();

  final RxString biometricEmail = "".obs;
  final RxString biometricPassword = "".obs;

  final RxString pendingTwoFaEmail = "".obs;
  final RxString pendingTwoFaPassword = "".obs;

  @override
  void onInit() {
    super.onInit();
    clearSignUpStatus();
    loadSavedEmail();
    loadBiometricStatus();
    refreshBiometricButton();
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
    await Get.find<SettingsService>().saveEmailVerified(false);
    await Get.find<SettingsService>().saveSetUpPassword(false);
  }

  Future<void> setLogInState() async {
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

  /// Route user after full auth: force passcode if missing, else home/onboarding.
  void _routeAfterAuth() {
    if (Get.isRegistered<SessionTimeoutService>()) {
      Get.find<SessionTimeoutService>().beginAuthenticatedSession();
    }
    final data = userModel.value.data;
    final completed = data?.boardingSteps?.completed == true;
    final hasPasscode = PasscodeHelper.userHasPasscode(data?.passcode);

    if (!hasPasscode) {
      if (Get.isRegistered<SetPasscodeController>()) {
        Get.delete<SetPasscodeController>();
      }
      Get.put(SetPasscodeController());
      Get.offAll(
        () => const SetPasscodeScreen(),
        arguments: {
          'next': completed ? BaseRoute.navigation : BaseRoute.signUpStatus,
          if (!completed) 'next_args': {"is_login_state": true},
        },
      );
      return;
    }

    if (completed) {
      Get.offAllNamed(BaseRoute.navigation);
      resetFields();
    } else {
      Get.toNamed(
        BaseRoute.signUpStatus,
        arguments: {"is_login_state": true},
      );
    }
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
    return NetworkErrorHelper.from(e).messageFa;
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
        _routeAfterAuth();
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
        // Biometric login is opt-in only. A successful password login must
        // never silently change the user's device-authentication preference.
        if (Get.isRegistered<PermissionFlowService>()) {
          await Get.find<PermissionFlowService>().requestNotification(
            context: Get.context,
            explain: true,
          );
        }

        try {
          await _offerSecuritySetup();
        } catch (_) {}
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

        if (userModel.value.data!.twoFa == true) {
          pendingTwoFaEmail.value =
              useBiometric ? biometricEmail.value : emailController.text;
          pendingTwoFaPassword.value =
              useBiometric ? biometricPassword.value : passwordController.text;
          Get.toNamed(BaseRoute.twoFactorAuth);
        } else {
          await Get.find<SettingsService>().saveLoggedInUserEmail(
            useBiometric ? biometricEmail.value : emailController.text,
          );
          await Get.find<SettingsService>().clearLoggedInUserPassword();
          await setLogInState();
          _routeAfterAuth();
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

  Future<void> _offerSecuritySetup() async {
    try {
      if (!Get.isRegistered<AppLockService>()) return;
      final lock = Get.find<AppLockService>();
      if (await lock.hasPinSet()) return;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (Get.context == null) return;
      final setPin = await Get.bottomSheet<bool>(
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'تنظیم PIN پشتیبان؟',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                const Text(
                  'اگر بیومتریک در دسترس نباشد، با PIN چهار رقمی وارد می‌شوید.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        child: const Text('بعداً'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        child: const Text('تنظیم PIN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.white,
      );
      if (setPin == true) {
        Get.snackbar(
          'PIN',
          'از تنظیمات → امنیت → تغییر PIN تنظیم کنید',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('offerSecuritySetup: $e');
    }
  }
}
