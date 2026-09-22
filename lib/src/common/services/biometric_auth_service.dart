import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/toast/toast_helper.dart';

/// Biometric auth (local_auth — lightweight, no extra native deps beyond plugin).
/// Preference flag is stored via [SettingsService] (SharedPreferences).
class BiometricAuthService {
  final LocalAuthentication auth = LocalAuthentication();
  final AppLocalizations? _localization =
      Get.context != null ? AppLocalizations.of(Get.context!) : null;

  static const int maxAttempts = 3;
  int _currentAttempts = 0;

  /// Device supports biometric hardware and has enrolled biometrics.
  Future<bool> isSupported() async {
    try {
      if (kIsWeb) return false;
      final canCheck = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();
      final available = await auth.getAvailableBiometrics();
      return (canCheck || supported) && available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Alias used by older call-sites.
  Future<bool> isBiometricAvailable() => isSupported();

  /// User preference: biometric login enabled.
  Future<bool> isEnabled() async {
    final v = await SettingsService.getBiometricEnableOrDisable();
    return v == true;
  }

  /// Can prompt now (supported + enrolled). If user revoked biometrics in OS,
  /// this becomes false — callers should hide login button and turn switch off.
  Future<bool> canAuthenticate() async {
    try {
      if (!await isSupported()) return false;
      return await auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Enable after successful biometric confirmation.
  Future<bool> enable() async {
    if (!await canAuthenticate()) {
      ToastHelper().showErrorToast(
        _localization?.biometricNotAvailable ??
            'این دستگاه از اثر انگشت/چهره پشتیبانی نمی‌کند',
      );
      return false;
    }
    final ok = await authenticate(
      reason: 'برای فعال‌سازی ورود بیومتریک تأیید کنید',
    );
    if (!ok) return false;
    await Get.find<SettingsService>().saveBiometricEnableOrDisable(true);
    return true;
  }

  /// Disable after biometric or password confirmation (caller may pass skipAuth).
  Future<bool> disable({bool requireAuth = true}) async {
    if (requireAuth) {
      final ok = await authenticate(
        reason: 'برای غیرفعال‌سازی ورود بیومتریک تأیید کنید',
      );
      if (!ok) return false;
    }
    await Get.find<SettingsService>().saveBiometricEnableOrDisable(false);
    return true;
  }

  /// Prompt biometric. Returns true on success.
  Future<bool> authenticate({String? reason}) async {
    try {
      if (_currentAttempts >= maxAttempts) {
        ToastHelper().showErrorToast(
          _localization?.biometricMaxAttempts ??
              'حداکثر تلاش بیومتریک تمام شد. با رمز وارد شوید',
        );
        _currentAttempts = 0;
        return false;
      }

      if (!await canAuthenticate()) {
        ToastHelper().showErrorToast(
          _localization?.biometricNotAvailable ??
              'Biometric authentication is not available on this device',
        );
        // Auto-disable preference if OS biometrics gone
        if (await isEnabled()) {
          await Get.find<SettingsService>().saveBiometricEnableOrDisable(false);
        }
        return false;
      }

      final success = await auth.authenticate(
        localizedReason: reason ??
            _localization?.biometricReason ??
            'Authenticate to sign in to eCardo',
        options: const AuthenticationOptions(biometricOnly: true),
      );

      if (success) {
        _currentAttempts = 0;
        return true;
      }

      _currentAttempts++;
      final remaining = maxAttempts - _currentAttempts;
      if (remaining > 0) {
        ToastHelper().showErrorToast(
          _localization?.biometricFailedAttempts(remaining) ??
              'Biometric authentication failed. $remaining attempts remaining',
        );
      } else {
        ToastHelper().showErrorToast(
          _localization?.biometricMaxAttempts ??
              'Maximum biometric attempts reached. Please sign in with your password',
        );
        _currentAttempts = 0;
      }
      return false;
    } catch (e) {
      _currentAttempts++;
      debugPrint('BIO: $e');
      ToastHelper().showErrorToast(
        _localization?.biometricGenericError ??
            'Biometric authentication failed',
      );
      return false;
    }
  }

  /// Backward-compatible name.
  Future<bool> authenticateWithBiometrics() => authenticate();

  void resetAttempts() => _currentAttempts = 0;

  int get remainingAttempts => maxAttempts - _currentAttempts;
}
