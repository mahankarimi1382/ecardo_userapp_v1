import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';

/// Biometric auth via local_auth (project SDK uses `biometricOnly:` named arg).
class BiometricAuthService {
  AppLocalizations? get _localization {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  final LocalAuthentication auth = LocalAuthentication();

  static const int maxAttempts = 3;
  static int _currentAttempts = 0;

  Future<bool> isSupported() => isBiometricAvailable();

  Future<bool> isEnabled() async {
    final v = await SettingsService.getBiometricEnableOrDisable();
    return v == true;
  }

  Future<bool> canAuthenticate() async {
    try {
      if (kIsWeb) return false;
      final canCheck = await auth.canCheckBiometrics;
      final supported = await auth.isDeviceSupported();
      final available = await auth.getAvailableBiometrics();
      return supported && canCheck && available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> enable() async {
    if (!await canAuthenticate()) {
      ToastHelper().showErrorToast(
        _localization?.biometricNotAvailable ??
            'این دستگاه از بیومتریک پشتیبانی نمی‌کند',
      );
      return false;
    }
    final ok = await authenticate(
      reason: 'برای فعال‌سازی ورود بیومتریک تأیید کنید',
    );
    if (!ok) return false;
    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().saveBiometricEnableOrDisable(true);
    }
    return true;
  }

  Future<bool> disable({bool requireAuth = true}) async {
    if (requireAuth) {
      final ok = await authenticate(
        reason: 'برای غیرفعال‌سازی ورود بیومتریک تأیید کنید',
      );
      if (!ok) return false;
    }
    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().saveBiometricEnableOrDisable(false);
    }
    return true;
  }

  Future<bool> authenticate({String? reason}) async {
    return authenticateWithBiometrics(reason: reason);
  }

  Future<bool> authenticateWithBiometrics({String? reason}) async {
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
        // OS biometrics removed — clear preference
        if (await isEnabled() && Get.isRegistered<SettingsService>()) {
          await Get.find<SettingsService>().saveBiometricEnableOrDisable(false);
        }
        return false;
      }

      if (!canCheck) {
        ToastHelper().showErrorToast(
          _localization?.biometricNotAvailable ??
              'Biometric authentication is not available on this device',
        );
        return false;
      }

      final success = await auth.authenticate(
        localizedReason: reason ??
            _localization?.biometricReason ??
            'Authenticate to sign in to eCardo',
        biometricOnly: true,
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
        return false;
      }
      ToastHelper().showErrorToast(
        _localization?.biometricMaxAttempts ??
            'Maximum biometric attempts reached. Please sign in with your password',
      );
      _currentAttempts = 0;
      return false;
    } catch (e) {
      _currentAttempts++;
      ToastHelper().showErrorToast(
        _localization?.biometricGenericError ??
            'Biometric authentication failed',
      );
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final availableBiometrics = await auth.getAvailableBiometrics();
      return canCheckBiometrics && availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  void resetAttempts() {
    _currentAttempts = 0;
  }

  int get remainingAttempts => maxAttempts - _currentAttempts;
}
