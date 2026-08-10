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
  final localization = AppLocalizations.of(Get.context!);
  final LocalAuthentication auth = LocalAuthentication();

  /// حداکثر تعداد تلاش بیومتریک قبل از fallback
  static const int maxAttempts = 3;

  /// تعداد تلاش‌های فعلی
  int _currentAttempts = 0;

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
        ToastHelper().showErrorToast('دستگاه شما از احراز هویت بیومتریک پشتیبانی نمی‌کند.');
        return false;
      }

      if (canCheck && available.isEmpty) {
        ToastHelper().showErrorToast('هیچ بیومتریک ثبت نشده است. لطفاً ابتدا اثر انگشت یا چهره را در تنظیمات دستگاه ثبت کنید.');
        return false;
      }

      if (!canCheck) {
        ToastHelper().showErrorToast('احراز هویت بیومتریک در دسترس نیست.');
        return false;
      }

      // شروع احراز هویت
      final success = await auth.authenticate(
        localizedReason: 'برای ورود به eCardo احراز هویت کنید',
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
            'احراز هویت ناموفق بود. $remaining تلاش باقی مانده است.',
          );
          return false;
        } else {
          // حداکثر تلاش رسید — fallback
          ToastHelper().showErrorToast(
            'حداکثر تلاش بیومتریک reached. لطفاً با رمز عبور وارد شوید.',
          );
          _currentAttempts = 0;
          return false;
        }
      }
    } catch (e) {
      _currentAttempts++;
      ToastHelper().showErrorToast('خطا در احراز هویت بیومتریک. لطفاً دوباره تلاش کنید.');
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
