import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/constants/app_colors.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/common/services/biometric_auth_service.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/common/widgets/button/common_button.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/home/model/dashboard_model.dart';
import 'package:qunzo_user/src/presentation/screens/transactions/model/transactions_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';

class HomeController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isUserLoading = false.obs;
  final RxBool isBiometricEnable = false.obs;
  GlobalKey<ScaffoldState>? _scaffoldKey;
  final RxBool isSignOutLoading = false.obs;
  final Rx<DashboardModel> dashboardModel = DashboardModel().obs;
  final Rx<UserModel> userModel = UserModel().obs;
  final RxList<Wallets> walletsList = <Wallets>[].obs;
  final Rx<TransactionsModel> transactionsModel = TransactionsModel().obs;
  final RxInt selectedIndex = 0.obs;
  final RxBool isSettingsInitialized = false.obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // End Drawer Variable
  final RxBool isSwitchMode = false.obs;

  // Transaction Report Chart Variable
  final RxString selectedYear = ''.obs;
  final RxString selectedMonth = ''.obs;
  final RxString selectedCrypto = ''.obs;

  // End Drawer Language Variable
  final RxString language = "".obs;
  final languageController = TextEditingController();

  void setScaffoldKey(GlobalKey<ScaffoldState> key) {
    _scaffoldKey = key;
  }

  void openEndDrawer() {
    _scaffoldKey!.currentState!.openEndDrawer();
  }

  void openDrawer() {
    _scaffoldKey!.currentState!.openDrawer();
  }

  @override
  void onInit() {
    super.onInit();
    loadData();
    loadBiometricStatus();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    if (Get.find<SettingsService>().getSetting("language_switcher") == "1") {
      _setInitialLanguage();
    }
    await fetchDashboard();
    await fetchWallets();
    await fetchTransactions();
    await fetchUser();
    isLoading.value = false;
  }

  // Load Biometric Status
  Future<void> loadBiometricStatus() async {
    final savedBiometric = await SettingsService.getBiometricEnableOrDisable();
    isBiometricEnable.value = savedBiometric ?? false;
  }

  Future<void> _setInitialLanguage() async {
    final savedLocale = await SettingsService.getLanguageLocaleCurrentState();

    if (savedLocale != null) {
      if (savedLocale == "en") {
        language.value = "English";
        languageController.text = "English";
      } else if (savedLocale == "ar") {
        language.value = "Arabic";
        languageController.text = "Arabic";
      }
    } else {
      language.value = "English";
      languageController.text = "English";
      await Get.find<SettingsService>().saveLanguageLocaleCurrentState("en");
    }
  }

  // Language Switching Method
  Future<void> changeLanguage(String languageName) async {
    try {
      language.value = languageName;
      languageController.text = languageName;

      String localeCode;
      if (languageName == "English") {
        localeCode = "en";
      } else if (languageName == "Arabic") {
        localeCode = "ar";
      } else {
        localeCode = "en";
      }

      await Get.find<SettingsService>().saveLanguageLocaleCurrentState(
        localeCode,
      );

      Get.updateLocale(Locale(localeCode));
    } catch (e, stackTrace) {
      debugPrint('❌ changeLanguage() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.homeLanguageChangeFailed);
    }
  }

  // Toggle Biometric
  Future<void> toggleBiometric() async {
    final LocalAuthentication auth = LocalAuthentication();
    final biometricAuthService = BiometricAuthService();
    final isSupported = await auth.isDeviceSupported();
    final isAvailable = await biometricAuthService.isBiometricAvailable();

    if (!isSupported) {
      ToastHelper().showErrorToast(
        localization.homeBiometricDeviceNotSupported,
      );
      return;
    }
    if (!isAvailable) {
      _showBiometricNotAvailableDialog();
      return;
    }

    final isAuthenticated = await biometricAuthService
        .authenticateWithBiometrics();

    if (isAuthenticated) {
      isBiometricEnable.value = !isBiometricEnable.value;
      await Get.find<SettingsService>().saveBiometricEnableOrDisable(
        isBiometricEnable.value,
      );
      ToastHelper().showSuccessToast(
        isBiometricEnable.value
            ? localization.homeBiometricEnabledSuccess
            : localization.homeBiometricDisabledSuccess,
      );
    } else {
      ToastHelper().showErrorToast(
        localization.homeBiometricAuthenticationFailed,
      );
    }
  }

  // Fetch Dashboard Function
  Future<void> fetchDashboard() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.dashboardEndpoint,
      );
      if (response.status == Status.completed) {
        dashboardModel.value = DashboardModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchDashboard() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  Future<void> loadUser() async {
    isUserLoading.value = true;
    await fetchUser();
    isUserLoading.value = false;
  }

  // Fetch User
  Future<void> fetchUser() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed) {
        userModel.value = UserModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Fetch Wallets
  Future<void> fetchWallets() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsList.clear();
        walletsList.value = walletsModel.data!.wallets ?? [];
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Fetch Transactions
  Future<void> fetchTransactions() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.transactionsEndpoint}?per_page=5",
      );

      if (response.status == Status.completed) {
        transactionsModel.value = TransactionsModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchTransactions() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Logout Function
  Future<void> submitLogout() async {
    isSignOutLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.logoutEndpoint,
      );
      isSignOutLoading.value = false;
      if (response.status == Status.completed) {
        await Get.find<TokenService>().clearToken();
        Get.offAllNamed(BaseRoute.signIn);
        Fluttertoast.showToast(
          msg: response.data?["message"],
          backgroundColor: AppColors.success,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitLogout() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isSignOutLoading.value = false;
    }
  }

  void _showBiometricNotAvailableDialog() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: 20.0,
          vertical: 24.0,
        ),
        decoration: BoxDecoration(
          color: AppColors.lightPrimary,
          borderRadius: const BorderRadiusDirectional.only(
            topStart: Radius.circular(24.0),
            topEnd: Radius.circular(24.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            Icon(Icons.fingerprint, size: 60, color: AppColors.lightPrimary),
            const SizedBox(height: 12),

            Text(
              localization.homeBiometricNotFoundTitle,
              style: TextStyle(
                letterSpacing: 0,
                fontSize: 24.0,
                fontWeight: FontWeight.w900,
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10.0),

            Text(
              localization.homeBiometricNotFoundDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
                fontSize: 16.0,
                height: 1.5,
                color: AppColors.lightTextTertiary,
              ),
            ),
            const SizedBox(height: 24.0),
            CommonButton(
              width: double.infinity,

              text: localization.homeBiometricOpenSettings,
              onPressed: () => _openSecuritySettings(),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  void _openSecuritySettings() {
    if (Platform.isAndroid) {
      final intent = AndroidIntent(
        action: 'android.settings.SECURITY_SETTINGS',
      );
      intent.launch();
    } else if (Platform.isIOS) {
      ToastHelper().showWarningToast(localization.homeIosBiometricSetup);
    }
  }
}
