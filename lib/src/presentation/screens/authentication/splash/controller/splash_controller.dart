import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_helper.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';
import 'package:ecardo_user/src/common/services/permission_flow_service.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

class SplashController extends GetxController {
  /// AUTH-BIO (primary directive): maximum time the splash flow waits for
  /// the system biometric prompt before falling back to the sign-in screen.
  /// The OS itself dismisses the Android prompt after ~30s of inactivity,
  /// so this only bounds the pathological cases (plugin hang / ignored iOS
  /// prompt). A late prompt completion after the timeout is ignored and the
  /// user simply signs in manually — sign-in is always reachable.
  static const Duration _biometricPromptTimeout = Duration(seconds: 30);

  /// WAVE-REVIEW (بازبینی مالک): نتیجه گیت بیومتریک — وقتی پرامپت آغاز شد و
  /// کاربر لغو/شکست خورد، جلسه باید قفل بماند (ورود با رمز)، نه این‌که با
  /// توکن ذخیره‌شده وارد داشبورد شود.
  static const String _bioNotStarted = 'not_started';
  static const String _bioSuccess = 'success';
  static const String _bioFailed = 'failed';

  Future<void> navigateBasedOnAuth() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none) ||
        connectivityResult.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != BaseRoute.noInternetConnection) {
          Get.offAllNamed(BaseRoute.noInternetConnection);
        }
      });
      return;
    }

    final loginState = await SettingsService.getLoginCurrentState();
    final isLoggedIn = loginState != null && loginState.isNotEmpty;

    // AUTH-BIO: the biometric gate moved here from sign_in_screen. If the
    // user enabled biometrics and is logged in, the system prompt is shown
    // automatically (no touch) and navigation WAITS for its result.
    final bioOutcome = await _tryAutoBiometricLogin();

    if (bioOutcome == _bioFailed) {
      // WAVE-REVIEW: کاربر پرامپت بیومتریک را لغو کرد یا شکست خورد —
      // جلسه قفل می‌ماند؛ ورود فقط با re-auth (رمز/دوباره بیومتریک).
      Get.offAllNamed(BaseRoute.signIn);
      return;
    }

    if (bioOutcome != _bioSuccess) {
      try {
        final tokenService = Get.find<TokenService>();
        await tokenService.loadAccessToken();
        final token = tokenService.accessToken.value;
        final hasToken = token != null && token.isNotEmpty;
        if (isLoggedIn && hasToken) {
          // Fast probe (3s). On timeout/network: enter dashboard if session
          // flag exists; final validity is re-checked in-app.
          try {
            final res = await Get.find<NetworkService>()
                .get(endpoint: ApiPath.userEndpoint)
                .timeout(const Duration(seconds: 3));
            if (res.status == Status.completed) {
              Get.offAllNamed(BaseRoute.navigation);
            } else {
              await _showSessionExpiredAndGoSignIn();
            }
          } on TimeoutException {
            // Weak network: prefer dashboard over blocking splash.
            Get.offAllNamed(BaseRoute.navigation);
          } catch (_) {
            await _showSessionExpiredAndGoSignIn();
          }
        } else if (isLoggedIn) {
          Get.offNamed(BaseRoute.signIn);
        } else {
          Get.offNamed(BaseRoute.welcome);
        }
      } catch (_) {
        if (isLoggedIn) {
          Get.offNamed(BaseRoute.signIn);
        } else {
          Get.offNamed(BaseRoute.welcome);
        }
      }
    }

    // v1.0.26 (UPD-5): surface any pending update right after landing.
    // Previously this helper existed but was NEVER called, so the live
    // force_update=1 flag had no client-side effect for users who never
    // opened Settings → Check for Updates. Forced updates bypass the
    // auto-update toggle and the already-prompted gate inside the helper.
    Future.delayed(const Duration(milliseconds: 600), () {
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        AppUpdateHelper.maybeAutoPromptForUpdate(ctx);
      }
    });

    // NOTIF-FIX: the notification permission prompt used to live ONLY in
    // the manual sign-in flow — users who auto-unlock (biometric/token) or
    // skip login never saw it, so Android 13+ devices silently received
    // zero pushes. Ask once per install after landing, without blocking
    // navigation. Granted/denied state is remembered by the OS; the service
    // also syncs the FCM token to the backend when newly granted.
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (Get.isRegistered<PermissionFlowService>()) {
        try {
          Get.find<PermissionFlowService>().requestLaunchEssentials(Get.context);
        } catch (e) {
          debugPrint('NOTIF-FIX: launch permission prompt failed: $e');
        }
      }
    });
  }

  /// AUTH-BIO: automatic biometric unlock right after splash.
  ///
  /// Gate conditions (ALL must hold, otherwise we fall through silently):
  ///   1. A `logged_in` session exists (`login_current_state` — same flag
  ///      the splash flow has always used, semantics fixed by A-4 so it is
  ///      only written after a successful login).
  ///   2. The user previously enabled biometrics
  ///      (`SettingsService.current_biometric` — the exact flag written by
  ///      the existing "enable biometric" toggle in the end drawer).
  ///   3. The saved credentials used by the old sign-in icon exist
  ///      (`current_email` + `current_password`).
  ///   4. Biometric hardware is available AND has enrolled credentials
  ///      (checked before any prompt — first run after an update, disabled
  ///      sensors or un-enrolled devices fall through gracefully and the
  ///      user is NEVER locked out).
  ///
  /// On success the splash route is replaced by sign-in (so the back stack
  /// matches the manual login flow, e.g. for 2FA) and the EXACT login chain
  /// used by the sign-in button is reused:
  /// submitSignIn → login API → FCM registration → fetchUser → home /
  /// 2FA / sign-up status.
  ///
  /// Returns [_bioSuccess] when the login chain has been started (it then
  /// owns all further navigation), [_bioFailed] when the prompt was shown
  /// but the user cancelled/failed (session stays locked → sign-in), and
  /// [_bioNotStarted] when the biometric path did not apply (fall through
  /// to normal routing).
  Future<String> _tryAutoBiometricLogin() async {
    try {
      final loginState = await SettingsService.getLoginCurrentState();
      if (loginState == null || loginState.isEmpty) return _bioNotStarted;

      final biometricEnabled =
          await SettingsService.getBiometricEnableOrDisable() ?? false;
      if (!biometricEnabled) return _bioNotStarted;

      final savedEmail = await SettingsService.getLoggedInUserEmail();
      if (savedEmail == null || savedEmail.isEmpty) return _bioNotStarted;

      // 1.0.51: prefer bearer token — no password needed for unlock.
      final tokenService = Get.find<TokenService>();
      await tokenService.loadAccessToken();
      final token = tokenService.accessToken.value;
      final hasToken = token != null && token.isNotEmpty;

      final biometricAuth = BiometricAuthService();
      if (!await biometricAuth.isBiometricAvailable()) {
        debugPrint('AUTH-BIO: biometrics unavailable — falling back to sign-in');
        return _bioNotStarted;
      }

      final success = await biometricAuth
          .authenticateWithBiometrics()
          .timeout(_biometricPromptTimeout, onTimeout: () => false);
      if (!success) {
        // WAVE-REVIEW: لغو/شکست پرامپت = جلسه قفل می‌ماند (نه ورود با توکن).
        debugPrint('AUTH-BIO: biometric auth failed/cancelled — session locked');
        return _bioFailed;
      }

      if (hasToken) {
        // Token path: refresh profile and enter the app (no password re-login).
        try {
          await FirebaseMessagingService.instance().registerTokenWithBackend();
        } catch (_) {}
        try {
          final response = await Get.find<NetworkService>().get(
            endpoint: ApiPath.userEndpoint,
          );
          if (response.status == Status.completed && response.data != null) {
            // Drop any legacy stored password after successful token unlock.
            await Get.find<SettingsService>().clearLoggedInUserPassword();
            final user = UserModel.fromJson(response.data!);
            final completed = user.data?.boardingSteps?.completed == true;
            if (completed) {
              Get.offAllNamed(BaseRoute.navigation);
            } else {
              Get.offNamed(
                BaseRoute.signUpStatus,
                arguments: {"is_login_state": true},
              );
            }
            return _bioSuccess;
          }
        } catch (e) {
          debugPrint('AUTH-BIO: token unlock failed: $e');
        }
        // Token rejected — session is not usable, force password sign-in.
        await _showSessionExpiredAndGoSignIn();
        return _bioSuccess;
      }

      // Legacy one-shot: password still on device from older builds.
      final savedPassword = await SettingsService.getLoggedInUserPassword();
      if (savedPassword == null || savedPassword.isEmpty) {
        return _bioFailed;
      }

      Get.offNamed(BaseRoute.signIn);
      final controller = Get.put(SignInController());
      controller.biometricEmail.value = savedEmail;
      controller.biometricPassword.value = savedPassword;
      await controller.submitSignIn(useBiometric: true);
      // After this login, password is cleared by SignInController (1.0.51).
      return _bioSuccess;
    } catch (e, s) {
      debugPrint('AUTH-BIO: unexpected error: $e');
      debugPrint('$s');
      return _bioNotStarted;
    }
  }

  Future<void> _showSessionExpiredAndGoSignIn() async {
    try {
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        // WAVE-1: was hardcoded Persian — localized for all four locales.
        final l10n = AppLocalizations.of(ctx);
        await Get.dialog(
          AlertDialog(
            title: Text(
              l10n?.unauthorizedDialogTitle ??
                  l10nPick(ctx, en: 'Session expired', fa: 'نشست منقضی شد'),
            ),
            content: Text(
              l10nPick(
                ctx,
                en: 'Please sign in again to continue.',
                fa: 'برای ادامه، دوباره وارد حساب شوید.',
                ar: 'يرجى تسجيل الدخول مرة أخرى للمتابعة.',
                zh: '请重新登录以继续。',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  l10nPick(
                    ctx,
                    en: 'Sign in',
                    fa: 'ورود مجدد',
                    ar: 'تسجيل الدخول',
                    zh: '重新登录',
                  ),
                ),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
    } catch (_) {}
    Get.offAllNamed(BaseRoute.signIn);
  }
}
