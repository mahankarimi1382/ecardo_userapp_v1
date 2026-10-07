import 'dart:async';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/permission_flow_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/network_error_helper.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

class SignInController extends GetxController {
  // P-4 pattern: null-safe localization (mirrors app_update_controller).
  AppLocalizations? get localizationOrNull {
    final ctx = Get.context;
    if (ctx == null || !ctx.mounted) return null;
    return AppLocalizations.of(ctx);
  }

  // WAVE-1: locale-aware strings without ARB codegen (en/fa/ar/zh).
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

  final RxBool isLoading = false.obs;
  final RxBool isBiometricEnable = false.obs;
  final RxBool isPressed = false.obs;
  final RxString emailError = "".obs;
  final RxString passwordError = "".obs;
  final RxBool showBiometricButton = false.obs;
  final RxBool formVisible = false.obs;
  final Rx<UserModel> userModel = UserModel().obs;
  final SettingsService settingsService = Get.find<SettingsService>();

  /// Tracks when login() has succeeded and auth token is preserved in TokenService,
  /// but fetchUser() failed due to a transient network issue or timeout.
  final RxBool hasPendingProfileFetch = false.obs;

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

  /// UX-FIX (login): stale validation errors vanished only on next submit.
  /// Clearing them the moment the user edits the field feels alive.
  void onEmailChanged(String _) {
    hasPendingProfileFetch.value = false;
    if (emailError.value.isNotEmpty) emailError.value = '';
  }

  void onPasswordChanged(String _) {
    hasPendingProfileFetch.value = false;
    if (passwordError.value.isNotEmpty) passwordError.value = '';
  }

  void _handlePasswordFocusChange() {
    isPasswordFocused.value = passwordFocusNode.hasFocus;
  }

  /// Route user after full auth: home when onboarding is done, else onboarding.
  /// Transaction passcode is no longer forced after login — it stays optional
  /// and is managed from Settings → Transaction PIN.
  void _routeAfterAuth() {
    final data = userModel.value.data;
    final completed = data?.boardingSteps?.completed == true;

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
      emailError.value = _pick(
        en: 'Email or username is required',
        fa: 'ایمیل یا نام کاربری الزامی است',
        ar: 'البريد الإلكتروني أو اسم المستخدم مطلوب',
        zh: '请输入邮箱或用户名',
      );
      ok = false;
    } else if (!email.contains('@') && email.length < 3) {
      emailError.value = _pick(
        en: 'The entered value is not valid',
        fa: 'مقدار وارد شده معتبر نیست',
        ar: 'القيمة المدخلة غير صالحة',
        zh: '输入的值无效',
      );
      ok = false;
    } else if (email.contains('@') &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      emailError.value = _pick(
        en: 'Email format is not valid',
        fa: 'فرمت ایمیل صحیح نیست',
        ar: 'تنسيق البريد الإلكتروني غير صحيح',
        zh: '邮箱格式不正确',
      );
      ok = false;
    }
    if (pass.isEmpty) {
      passwordError.value = _pick(
        en: 'Password is required',
        fa: 'رمز عبور الزامی است',
        ar: 'كلمة المرور مطلوبة',
        zh: '请输入密码',
      );
      ok = false;
    } else if (pass.length < 4) {
      passwordError.value = _pick(
        en: 'Password is too short',
        fa: 'رمز عبور خیلی کوتاه است',
        ar: 'كلمة المرور قصيرة جدًا',
        zh: '密码太短',
      );
      ok = false;
    }
    return ok;
  }

  String _friendlyNetworkError(Object e) {
    // WAVE-1: message is locale-aware now (was Persian-only `messageFa`).
    return NetworkErrorHelper.from(e).message;
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
          _pick(
            en: 'Session expired. Sign in with your email and password.',
            fa: 'نشست منقضی شده. با ایمیل و رمز وارد شوید.',
            ar: 'انتهت الجلسة. سجّل الدخول بالبريد وكلمة المرور.',
            zh: '会话已过期，请使用邮箱和密码登录。',
          ),
        );
        showBiometricButton.value = false;
        return;
      }
      try {
        unawaited(FirebaseMessagingService.instance().registerTokenWithBackend());
      } catch (_) {}
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        userModel.value = UserModel.fromJson(response.data!);
        await setLogInState();
        _routeAfterAuth();
      } else {
        ToastHelper().showErrorToast(_pick(
          en: 'Biometric sign-in failed.',
          fa: 'ورود با بیومتریک ناموفق بود.',
          ar: 'فشل تسجيل الدخول بالخصائص الحيوية.',
          zh: '生物识别登录失败。',
        ));
      }
    } catch (e) {
      ToastHelper().showErrorToast(_friendlyNetworkError(e));
    } finally {
      isLoading.value = false;
    }
  }

  void _triggerPostLoginBackgroundTasks() {
    unawaited(FirebaseMessagingService.instance().registerTokenWithBackend());
    unawaited(refreshBiometricButton());
    if (Get.isRegistered<PermissionFlowService>()) {
      unawaited(Get.find<PermissionFlowService>().requestNotification(
        context: Get.context,
        explain: true,
      ));
    }
  }

  /// Retries fetching user profile without requiring credentials re-entry.
  Future<void> retryFetchUserProfile({bool useBiometric = false}) async {
    isLoading.value = true;
    try {
      final success = await fetchUser(
        useBiometric: useBiometric,
        throwOnError: true,
      );
      if (success) {
        hasPendingProfileFetch.value = false;
        _triggerPostLoginBackgroundTasks();
      }
    } catch (e) {
      debugPrint('❌ retryFetchUserProfile error: $e');
      _handleFetchUserFailure(
        useBiometric: useBiometric,
        error: e,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _handleFetchUserFailure({
    bool useBiometric = false,
    required Object error,
  }) {
    // Provide a clear toast message allowing retry without re-entering credentials
    ToastHelper().showErrorToast(
      _pick(
        en: 'Network error loading profile. Tap Retry to continue.',
        fa: 'خطای شبکه در دریافت اطلاعات کاربری. برای ادامه، تلاش دوباره را بزنید.',
        ar: 'خطأ في الشبكة أثناء تحميل الملف الشخصي. اضغط إعادة المحاولة للمتابعة.',
        zh: '加载个人资料时发生网络错误。请点击重试以继续。',
      ),
    );

    // Show retry dialog so user can retry immediately without re-entering credentials
    if (Get.context != null) {
      Get.defaultDialog(
        title: _pick(
          en: 'Connection Error',
          fa: 'خطای ارتباط با سرور',
          ar: 'خطأ في الاتصال',
          zh: '网络连接错误',
        ),
        titleStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
        middleText: _pick(
          en: 'Signed in successfully, but loading your profile failed due to a network glitch. Tap Retry to continue without re-entering credentials.',
          fa: 'ورود با موفقیت انجام شد، اما دریافت اطلاعات به دلیل خطای شبکه ناموفق بود. برای ادامه بدون ورود مجدد مشخصات، تلاش مجدد را بزنید.',
          ar: 'تم تسجيل الدخول بنجاح، لكن تعذر تحميل الملف الشخصي بسبب خطأ في الشبكة. اضغط على إعادة المحاولة للمتابعة دون إعادة إدخال البيانات.',
          zh: '已成功登录，但由于网络问题加载资料失败。点击重试即可继续，无需重新输入凭据。',
        ),
        middleTextStyle: const TextStyle(fontSize: 13),
        textConfirm: _pick(
          en: 'Retry',
          fa: 'تلاش مجدد',
          ar: 'إعادة المحاولة',
          zh: '重试',
        ),
        textCancel: _pick(
          en: 'Cancel',
          fa: 'انصراف',
          ar: 'إلغاء',
          zh: '取消',
        ),
        buttonColor: AppColors.lightPrimary,
        confirmTextColor: Colors.white,
        barrierDismissible: true,
        onConfirm: () async {
          Get.back();
          await retryFetchUserProfile(useBiometric: useBiometric);
        },
      );
    }
  }

  Future<void> submitSignIn({bool useBiometric = false}) async {
    // If login already succeeded earlier (token received and saved into TokenService)
    // but fetchUser failed due to transient network glitch or timeout, retry fetching
    // the profile directly without re-entering credentials:
    if (hasPendingProfileFetch.value) {
      final token = Get.isRegistered<TokenService>()
          ? Get.find<TokenService>().accessToken.value
          : null;
      if (token != null && token.isNotEmpty) {
        await retryFetchUserProfile(useBiometric: useBiometric);
        return;
      }
    }

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
        try {
          final bio = BiometricAuthService();
          if (await bio.isBiometricAvailable()) {
            await settingsService.saveBiometricEnableOrDisable(true);
          }
        } catch (_) {}

        hasPendingProfileFetch.value = true;

        // Immediate user profile retrieval with automatic retry on transient error:
        bool fetchSuccess = false;
        try {
          fetchSuccess = await fetchUser(
            useBiometric: useBiometric,
            throwOnError: true,
          );
        } catch (initialError) {
          debugPrint(
            '⚠️ fetchUser() failed on first attempt: $initialError. Retrying once...',
          );
          // Transient network glitch or timeout: retry once automatically
          try {
            await Future.delayed(const Duration(milliseconds: 800));
            fetchSuccess = await fetchUser(
              useBiometric: useBiometric,
              throwOnError: true,
            );
          } catch (retryError) {
            debugPrint('❌ fetchUser() retry attempt failed: $retryError');
            fetchSuccess = false;
            _handleFetchUserFailure(
              useBiometric: useBiometric,
              error: retryError,
            );
          }
        }

        if (fetchSuccess) {
          hasPendingProfileFetch.value = false;
          _triggerPostLoginBackgroundTasks();
        }
      } else {
        _handleLoginFailure(response.message);
      }
    } catch (e, s) {
      debugPrint('❌ submitSignIn() error: $e');
      debugPrint('📍 StackTrace: $s');
      _handleLoginFailure(_friendlyNetworkError(e));
    } finally {
      isLoading.value = false;
      if (useBiometric) {
        biometricPassword.value = '';
      }
    }
  }

  void _handleLoginFailure(String? msg) {
    final lower = (msg ?? '').toLowerCase();
    final bool isUserNotFound = lower.contains('not found') ||
        lower.contains('یافت نشد') ||
        lower.contains('ثبت‌نام') ||
        lower.contains('ثبت نام') ||
        lower.contains('register') ||
        lower.contains('no account') ||
        lower.contains('credentials') ||
        lower.contains('does not exist');

    if (isUserNotFound) {
      Get.defaultDialog(
        title: _pick(
          en: 'Account Not Found',
          fa: 'حساب کاربری یافت نشد',
          ar: 'لم يتم العثور على حساب',
          zh: '未找到账户',
        ),
        middleText: _pick(
          en: 'No account was found with these credentials. Would you like to create a new account?',
          fa: 'حسابی با این مشخصات در اکاردو یافت نشد. آیا مایلید حساب کاربری جدیدی ایجاد کنید؟',
          ar: 'لا يوجد حساب بهذه البيانات. هل ترغب في تسجيل حساب جديد؟',
          zh: '未找到匹配的账户。是否现在注册新账户？',
        ),
        textConfirm: _pick(
          en: 'Sign Up',
          fa: 'ثبت‌نام در اکاردو',
          ar: 'تسجيل جديد',
          zh: '立即注册',
        ),
        textCancel: _pick(
          en: 'Cancel',
          fa: 'انصراف',
          ar: 'إلغاء',
          zh: '取消',
        ),
        buttonColor: AppColors.lightPrimary,
        confirmTextColor: Colors.white,
        onConfirm: () {
          Get.back();
          Get.toNamed(BaseRoute.email);
        },
      );
    } else if (msg != null && msg.isNotEmpty) {
      ToastHelper().showErrorToast(msg);
    }
  }

  Future<bool> fetchUser({
    bool useBiometric = false,
    bool throwOnError = false,
  }) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );

      if (response.status == Status.completed && response.data != null) {
        userModel.value = UserModel.fromJson(response.data!);

        if (userModel.value.data?.twoFa == true) {
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
        hasPendingProfileFetch.value = false;
        return true;
      } else {
        final errorMsg = response.message ??
            localizationOrNull?.allControllerLoadError ??
            _pick(
              en: 'Failed to load user profile.',
              fa: 'دریافت اطلاعات کاربری با خطا مواجه شد.',
              ar: 'فشل تحميل ملف المستخدم.',
              zh: '加载用户资料失败。',
            );
        throw Exception(errorMsg);
      }
    } catch (e, s) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $s');
      if (throwOnError) {
        rethrow;
      }
      // P-4: null-safe localization (was `AppLocalizations.of(Get.context!)!`).
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            _pick(
              en: 'Something went wrong. Please try again.',
              fa: 'خطایی رخ داد. دوباره تلاش کنید.',
            ),
      );
      return false;
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
    }
  }

  void resetFields() {
    emailController.clear();
    passwordController.clear();
    isEmailFocused.value = false;
    isPasswordFocused.value = false;
    hasPendingProfileFetch.value = false;
  }

  Future<void> offerSecuritySetup() async {
    try {
      if (!Get.isRegistered<AppLockService>()) return;
      final lock = Get.find<AppLockService>();
      if (await lock.hasPinSet()) return;
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (Get.context == null) return;
      // WAVE-1: was hardcoded Persian — localized for all four locales.
      final setPin = await Get.bottomSheet<bool>(
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _pick(
                    en: 'Set a backup PIN?',
                    fa: 'تنظیم PIN پشتیبان؟',
                    ar: 'تعيين رمز PIN احتياطي؟',
                    zh: '设置备用 PIN？',
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  _pick(
                    en: 'If biometrics are unavailable, you sign in with a 4-digit PIN.',
                    fa: 'اگر بیومتریک در دسترس نباشد، با PIN چهار رقمی وارد می‌شوید.',
                    ar: 'إذا لم تكن الخصائص الحيوية متاحة، ستدخل برمز PIN من أربعة أرقام.',
                    zh: '如果生物识别不可用，将使用 4 位 PIN 登录。',
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: false),
                        child: Text(_pick(
                          en: 'Later',
                          fa: 'بعداً',
                          ar: 'لاحقًا',
                          zh: '稍后',
                        )),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Get.back(result: true),
                        child: Text(_pick(
                          en: 'Set PIN',
                          fa: 'تنظیم PIN',
                          ar: 'تعيين PIN',
                          zh: '设置 PIN',
                        )),
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
          _pick(
            en: 'Set it later from Settings → Security → Change PIN',
            fa: 'از تنظیمات → امنیت → تغییر PIN تنظیم کنید',
            ar: 'عيّنها لاحقًا من الإعدادات ← الأمان ← تغيير PIN',
            zh: '稍后在“设置 → 安全 → 修改 PIN”中设置',
          ),
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('offerSecuritySetup: $e');
    }
  }
}
