import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// BiometricAuthService — احراز هویت بیومتریک با محدودیت تلاش
///
/// v1.0.5 بهبودها:
///   - محدودیت ۳ تلاش → fallback به PIN/password
///   - logging تلاش‌های ناموفق
///   - پیام‌های فارسی بهتر
class BiometricAuthService {
  /// v1.0.24: localizations are resolved lazily — the service may be
  /// constructed before a Navigator context exists, and `Get.context!` used
  /// to throw on construction. Fall back to English literals when l10n is
  /// unreachable.
  AppLocalizations? get _localization {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  final LocalAuthentication auth = LocalAuthentication();

  /// حداکثر تعداد تلاش بیومتریک قبل از fallback
  static const int maxAttempts = 3;

  /// تعداد تلاش‌های فعلی
  /// phase2-fix: shared across instances — splash and settings each used to
  /// construct a fresh instance, resetting the counter and silently
  /// disabling the 3-attempt limit.
  static int _currentAttempts = 0;

  /// احراز هویت با بیومتریک
  /// برمی‌گرداند:
  ///   true — موفق
  ///   false — ناموفق (حداکثر تلاش reached یا خطا)
  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      final available = await auth.getAvailableBiometrics();

      if (!isSupported) {
        ToastHelper().showErrorToast(
          _localization?.biometricNotAvailable ??
              'Biometric authentication is not available on this device',
        );
        return false;
      }

      if (canCheck && available.isEmpty) {
        ToastHelper().showErrorToast(
          _localization?.biometricNotEnrolled ??
              'No biometric enrolled. Please set up fingerprint',
        );
        return false;
      }

      if (!canCheck) {
        ToastHelper().showErrorToast(
          _localization?.biometricNotAvailable ??
              'Biometric authentication is not available on this device',
        );
        return false;
      }

      // شروع احراز هویت
      final success = await auth.authenticate(
        localizedReason: _localization?.biometricReason ??
            'Authenticate to sign in to eCardo',
        biometricOnly: true,
      );

      if (success) {
        _currentAttempts = 0; // reset در موفقیت
        return true;
      } else {
        _currentAttempts++;
        final remaining = maxAttempts - _currentAttempts;

        if (remaining > 0) {
          ToastHelper().showErrorToast(
            _localization?.biometricFailedAttempts(remaining) ??
                'Biometric authentication failed. $remaining attempts remaining',
          );
          return false;
        } else {
          // حداکثر تلاش رسید — fallback
          ToastHelper().showErrorToast(
            _localization?.biometricMaxAttempts ??
                'Maximum biometric attempts reached. Please sign in with your password',
          );
          _currentAttempts = 0;
          return false;
        }
      }
    } catch (e) {
      _currentAttempts++;
      ToastHelper().showErrorToast(
        _localization?.biometricGenericError ??
            'Biometric authentication failed',
      );
      return false;
    }
  }

  /// بررسی دسترسی بیومتریک
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final availableBiometrics = await auth.getAvailableBiometrics();
      return canCheckBiometrics && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// reset تعداد تلاش‌ها (هنگام logout)
  void resetAttempts() {
    _currentAttempts = 0;
  }

  /// تعداد تلاش‌های باقی‌مانده
  int get remainingAttempts => maxAttempts - _currentAttempts;
}
