import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/settings_model.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends GetxService {
  final RxBool isSettingsLoading = false.obs;
  final RxBool isSettingsDataLoad = false.obs;
  AppLocalizations? get localization {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  // Key Variable
  static const String currentEmailKey = 'current_email';
  static const String logInCurrentStateKey = "login_current_state";
  static const String currentBiometricKey = 'current_biometric';
  static const String currentEmailVerifiedKey = 'current_email_verified';
  static const String currentSetUpPasswordKey = 'current_set_up_password';
  static const String currentBonusShowKey = 'current_bonus_pop_up_shown';
  static const String currentPasswordKey = 'current_password';
  static const String currentLanguageLocaleKey = 'current_locale';
  static const String currentFcmTokenKey = 'current_fcm_token';

  // Current Value Variable
  final Rx<String?> currentLanguageLocale = Rx<String?>(null);
  final Rx<String?> currentEmail = Rx<String?>(null);
  final Rx<String?> currentPassword = Rx<String?>(null);
  final Rx<String?> logInCurrentState = Rx<String?>(null);
  final Rx<bool?> currentBiometric = Rx<bool?>(null);
  final Rx<bool?> currentEmailVerified = Rx<bool?>(null);
  final Rx<bool?> currentSetUpPassword = Rx<bool?>(null);
  final Rx<bool?> currentBonusShow = Rx<bool?>(null);
  final Rx<String?> currentFcmToken = Rx<String?>(null);
  final RxMap<String, String> appSettings = <String, String>{}.obs;

  // Saved FCM Token Current State Function
  Future<bool> saveFcmToken(String fcmToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentFcmToken.value = fcmToken;
    return await prefs.setString(currentFcmTokenKey, fcmToken);
  }

  // Get FCM Token Current State Function
  static Future<String?> getFcmToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentFcmTokenKey);
  }

  // Saved Language Locale Current State Function
  Future<bool> saveLanguageLocaleCurrentState(String locale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentLanguageLocale.value = locale;
    return await prefs.setString(currentLanguageLocaleKey, locale);
  }

  // Get Language Locale Current State Function
  static Future<String?> getLanguageLocaleCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentLanguageLocaleKey);
  }

  // Saved User Login Current State Function
  Future<bool> saveLoginCurrentState(String loginState) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    logInCurrentState.value = loginState;
    return await prefs.setString(logInCurrentStateKey, loginState);
  }

  // Get User Login Current State Function
  static Future<String?> getLoginCurrentState() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(logInCurrentStateKey);
  }

  // Saved User Email Function
  Future<bool> saveLoggedInUserEmail(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentEmail.value = email;
    return await prefs.setString(currentEmailKey, email);
  }

  // Get User Email Function
  static Future<String?> getLoggedInUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(currentEmailKey);
  }

  // Saved Logged In User Password (SECURE — v1.0.4+5)
  // Migrated from SharedPreferences to flutter_secure_storage
  // to prevent plaintext password leaks on rooted devices.
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Future<bool> saveLoggedInUserPassword(String password) async {
    try {
      await _secureStorage.write(key: currentPasswordKey, value: password);
      currentPassword.value = password;
      // Also clear any legacy SharedPreferences entry
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(currentPasswordKey);
      return true;
    } catch (e) {
      debugPrint('Failed to save password securely: $e');
      return false;
    }
  }

  // Get Logged In User Password
  static Future<String?> getLoggedInUserPassword() async {
    try {
      final pwd = await _secureStorage.read(key: currentPasswordKey);
      if (pwd != null) return pwd;
      // Migrate from legacy storage if secure storage is empty
      final prefs = await SharedPreferences.getInstance();
      final legacy = prefs.getString(currentPasswordKey);
      if (legacy != null) {
        await _secureStorage.write(key: currentPasswordKey, value: legacy);
        await prefs.remove(currentPasswordKey);
        return legacy;
      }
      return null;
    } catch (e) {
      debugPrint('Failed to read password: $e');
      return null;
    }
  }

  // Saved Biometric Enable Or Disable
  Future<bool> saveBiometricEnableOrDisable(bool biometric) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentBiometric.value = biometric;
    return await prefs.setBool(currentBiometricKey, biometric);
  }

  // Get Biometric Enable Or Disable
  static Future<bool?> getBiometricEnableOrDisable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(currentBiometricKey);
  }

  // Saved Email Verified State
  Future<bool> saveEmailVerified(bool isEmailVerified) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentEmailVerified.value = isEmailVerified;
    return await prefs.setBool(currentEmailVerifiedKey, isEmailVerified);
  }

  // Get Email Verified State
  static Future<bool?> getEmailVerified() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(currentEmailVerifiedKey);
  }

  // Saved Set Up Password State
  Future<bool> saveSetUpPassword(bool isSetUpPassword) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    currentSetUpPassword.value = isSetUpPassword;
    return await prefs.setBool(currentSetUpPasswordKey, isSetUpPassword);
  }

  // Get Set Up Password State
  static Future<bool?> getSetUpPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(currentSetUpPasswordKey);
  }

  // Saved Bonus Pop Up Show (User Specific)
  Future<bool> saveBonusPopUpShow(String email, bool bonus) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = '${currentBonusShowKey}_$email';
    currentBonusShow.value = bonus;
    return await prefs.setBool(key, bonus);
  }

  // Get Bonus Pop Up Show (User Specific)
  static Future<bool?> getBonusPopUpShow(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '${currentBonusShowKey}_$email';
    return prefs.getBool(key);
  }

  // Fetch Settings from API
  Future<void> fetchSettings() async {
    isSettingsLoading.value = true;

    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getSettingsEndpoint,
      );

      if (response.status == Status.completed) {
        final settingsModel = SettingsModel.fromJson(response.data!);
        appSettings.clear();
        settingsModel.data?.forEach((item) {
          if (item.name != null && item.value != null) {
            appSettings[item.name!] = item.value!;
          }
        });
        isSettingsDataLoad.value = true;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchSettings() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isSettingsLoading.value = false;
    }
  }

  // Get a specific setting by key
  String? getSetting(String key) => appSettings[key];
}
