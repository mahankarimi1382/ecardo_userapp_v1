import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';

class BiometricAuthService {
  final localization = AppLocalizations.of(Get.context!);
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> authenticateWithBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();
      final available = await auth.getAvailableBiometrics();

      if (!isSupported) {
        ToastHelper().showErrorToast(localization!.biometricDeviceNotSupported);
        return false;
      }

      if (canCheck && available.isEmpty) {
        ToastHelper().showErrorToast(localization!.biometricNotEnrolled);
        return false;
      }

      if (!canCheck) {
        ToastHelper().showErrorToast(localization!.biometricUnavailable);
        return false;
      }

      return await auth.authenticate(
        localizedReason: localization!.biometricAuthReason,
        biometricOnly: true,
      );
    } catch (e) {
      ToastHelper().showErrorToast(localization!.biometricAuthenticationFailed);
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheckBiometrics = await auth.canCheckBiometrics;
      final availableBiometrics = await auth.getAvailableBiometrics();

      return canCheckBiometrics && availableBiometrics.isNotEmpty;
    } catch (e) {
      ToastHelper().showErrorToast(localization!.biometricCheckFailed);
      return false;
    }
  }
}
