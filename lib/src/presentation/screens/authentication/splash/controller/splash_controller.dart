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
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

class SplashController extends GetxController {
  /// AUTH-BIO (primary directive): maximum time the splash flow waits for
  /// the system biometric prompt before falling back to the sign-in screen.
  /// The OS itself dismisses the Android prompt after ~30s of inactivity,
  /// so this only bounds the pathological cases (plugin hang / ignored iOS
  /// prompt). A late prompt completion after the timeout is ignored and the
  /// user simply signs in manually — sign-in is always reachable.
  static const Duration _biometricPromptTimeout = Duration(seconds: 30);

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
    final biometricLoginStarted = await _tryAutoBiometricLogin();

    if (!biometricLoginStarted) {
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
  /// Returns true only when the login chain has been started (it then owns
  /// all further navigation); false means "fall through to normal routing".
  Future<bool> _tryAutoBiometricLogin() async {
    try {
      final loginState = await SettingsService.getLoginCurrentState();
      if (loginState == null || loginState.isEmpty) return false;

      final biometricEnabled =
          await SettingsService.getBiometricEnableOrDisable() ?? false;
      if (!biometricEnabled) return false;

      final savedEmail = await SettingsService.getLoggedInUserEmail();
      if (savedEmail == null || savedEmail.isEmpty) return false;

      // 1.0.51: prefer bearer token — no password needed for unlock.
      final tokenService = Get.find<TokenService>();
      await tokenService.loadAccessToken();
      final token = tokenService.accessToken.value;
      final hasToken = token != null && token.isNotEmpty;

      final biometricAuth = BiometricAuthService();
      if (!await biometricAuth.isBiometricAvailable()) {
        debugPrint('AUTH-BIO: biometrics unavailable — falling back to sign-in');
        return false;
      }

      final success = await biometricAuth
          .authenticateWithBiometrics()
          .timeout(_biometricPromptTimeout, onTimeout: () => false);
      if (!success) {
        debugPrint('AUTH-BIO: biometric auth failed/cancelled — sign-in fallback');
        return false;
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
            return true;
          }
        } catch (e) {
          debugPrint('AUTH-BIO: token unlock failed: $e');
        }
        // Token rejected — force password sign-in.
        return false;
      }

      // Legacy one-shot: password still on device from older builds.
      final savedPassword = await SettingsService.getLoggedInUserPassword();
      if (savedPassword == null || savedPassword.isEmpty) {
        return false;
      }

      Get.offNamed(BaseRoute.signIn);
      final controller = Get.put(SignInController());
      controller.biometricEmail.value = savedEmail;
      controller.biometricPassword.value = savedPassword;
      await controller.submitSignIn(useBiometric: true);
      // After this login, password is cleared by SignInController (1.0.51).
      return true;
    } catch (e, s) {
      debugPrint('AUTH-BIO: unexpected error: $e');
      debugPrint('$s');
      return false;
    }
  }

  Future<void> _showSessionExpiredAndGoSignIn() async {
    try {
      final ctx = Get.context;
      if (ctx != null && ctx.mounted) {
        await Get.dialog(
          AlertDialog(
            title: const Text('نشست منقضی شد'),
            content: const Text('برای ادامه، دوباره وارد حساب شوید.'),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: const Text('ورود مجدد'),
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
