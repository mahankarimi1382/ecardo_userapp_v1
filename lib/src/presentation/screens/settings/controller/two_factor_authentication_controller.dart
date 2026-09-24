import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

class TwoFactorAuthenticationController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final RxBool isEnableTwoFaLoading = false.obs;
  final RxBool isDisableTwoFaLoading = false.obs;
  final RxBool isGenerateQRCodeLoading = false.obs;
  final RxBool isGeneratePasscodeLoading = false.obs;
  final RxBool isChangePasscodeLoading = false.obs;
  final RxBool isDisablePasscodeLoading = false.obs;
  final Rx<UserModel> userModel = UserModel().obs;

  // QR Code
  final RxString qrCode = "".obs;

  // Enable Two FA Controller
  final RxBool isEnable2FaFocused = false.obs;
  final FocusNode enable2FaFocusNode = FocusNode();
  final enable2FaController = TextEditingController();

  // Disable Two FA Controller
  final RxBool isDisable2FaFocused = false.obs;
  final FocusNode disable2FaFocusNode = FocusNode();
  final disable2FaController = TextEditingController();

  // Passcode Controller
  final RxBool isPasscodeFocused = false.obs;
  final FocusNode passcodeFocusNode = FocusNode();
  final passcodeController = TextEditingController();

  // Confirm Passcode Controller
  final RxBool isConfirmPasscodeFocused = false.obs;
  final FocusNode confirmPasscodeFocusNode = FocusNode();
  final confirmPasscodeController = TextEditingController();

  // Old Passcode Controller
  final RxBool isOldPasscodeFocused = false.obs;
  final FocusNode oldPasscodeFocusNode = FocusNode();
  final oldPasscodeController = TextEditingController();

  // New Passcode Controller
  final RxBool isNewPasscodeFocused = false.obs;
  final FocusNode newPasscodeFocusNode = FocusNode();
  final newPasscodeController = TextEditingController();

  // Change Confirm Passcode Controller
  final RxBool isChangeConfirmPasscodeFocused = false.obs;
  final FocusNode changedConfirmPasscodeFocusNode = FocusNode();
  final changedConfirmPasscodeController = TextEditingController();

  // Password Controller (legacy disable path — UI no longer exposes disable)
  final RxBool isPasswordFocused = false.obs;
  final FocusNode passwordFocusNode = FocusNode();
  final passwordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    enable2FaFocusNode.addListener(() {
      isEnable2FaFocused.value = enable2FaFocusNode.hasFocus;
    });
    disable2FaFocusNode.addListener(() {
      isDisable2FaFocused.value = disable2FaFocusNode.hasFocus;
    });
    passcodeFocusNode.addListener(() {
      isPasscodeFocused.value = passcodeFocusNode.hasFocus;
    });
    confirmPasscodeFocusNode.addListener(() {
      isConfirmPasscodeFocused.value = confirmPasscodeFocusNode.hasFocus;
    });
    oldPasscodeFocusNode.addListener(() {
      isOldPasscodeFocused.value = oldPasscodeFocusNode.hasFocus;
    });
    newPasscodeFocusNode.addListener(() {
      isNewPasscodeFocused.value = newPasscodeFocusNode.hasFocus;
    });
    changedConfirmPasscodeFocusNode.addListener(() {
      isChangeConfirmPasscodeFocused.value =
          changedConfirmPasscodeFocusNode.hasFocus;
    });
    passwordFocusNode.addListener(() {
      isPasswordFocused.value = passwordFocusNode.hasFocus;
    });
  }

  Future<void> fetchUser() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.userEndpoint}?google2fa_secret=1",
      );
      if (response.status == Status.completed) {
        userModel.value = UserModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  Future<void> getQRCode() async {
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.twoFaGenerateQRCodeEndpoint,
      );
      if (response.status == Status.completed) {
        qrCode.value = "";
        qrCode.value = response.data?["data"]["qr_code"] ?? "";
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getQRCode() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {}
  }

  Future<void> loadGenerate2Fa() async {
    isGenerateQRCodeLoading.value = true;
    await getQRCode();
    await fetchUser();
    isGenerateQRCodeLoading.value = false;
  }

  Future<void> submitEnableTwoFa() async {
    isEnableTwoFaLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.enableTwoFaEndpoint,
        data: {"one_time_password": enable2FaController.text},
      );
      if (response.status == Status.completed) {
        await fetchUser();
        enable2FaController.clear();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitEnableTwoFa() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isEnableTwoFaLoading.value = false;
    }
  }

  Future<void> submitDisableTwoFa() async {
    isDisableTwoFaLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.disableTwoFaEndpoint,
        data: {"one_time_password": disable2FaController.text},
      );
      if (response.status == Status.completed) {
        await fetchUser();
        disable2FaController.clear();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitDisableTwoFa() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isDisableTwoFaLoading.value = false;
    }
  }

  Future<void> submitGeneratePasscode() async {
    if (!validateAddPasscodeStep()) {
      return;
    }
    Get.back();
    isGeneratePasscodeLoading.value = true;
    try {
      final code = PasscodeHelper.normalize(passcodeController.text);
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.passcodeActiveEndpoint,
        data: {
          "passcode": code,
          "passcode_confirmation": PasscodeHelper.normalize(
            confirmPasscodeController.text,
          ),
        },
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        passcodeController.clear();
        confirmPasscodeController.clear();
        await fetchUser();
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().fetchUser();
        }
      }
    } finally {
      isGeneratePasscodeLoading.value = false;
      passcodeController.clear();
      confirmPasscodeController.clear();
    }
  }

  Future<void> submitChangePasscode() async {
    if (!validateChangePasscodeStep()) {
      return;
    }
    Get.back();
    isChangePasscodeLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.changePasscodeEndpoint,
        data: {
          "old_passcode": PasscodeHelper.normalize(oldPasscodeController.text),
          "passcode": PasscodeHelper.normalize(newPasscodeController.text),
          "passcode_confirmation": PasscodeHelper.normalize(
            changedConfirmPasscodeController.text,
          ),
        },
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        oldPasscodeController.clear();
        newPasscodeController.clear();
        changedConfirmPasscodeController.clear();
        await fetchUser();
        if (Get.isRegistered<HomeController>()) {
          await Get.find<HomeController>().fetchUser();
        }
      }
    } finally {
      isChangePasscodeLoading.value = false;
      oldPasscodeController.clear();
      newPasscodeController.clear();
      changedConfirmPasscodeController.clear();
    }
  }

  /// Disable is intentionally not offered in the UI — passcode is mandatory.
  /// Method kept only for API completeness; do not wire to screens.
  Future<void> submitDisablePasscode() async {
    ToastHelper().showErrorToast(
      AppLocalizations.of(Get.context!)!.twoFactorValidationEnterPasscode,
    );
  }

  bool validateChangePasscodeStep() {
    final loc = AppLocalizations.of(Get.context!)!;
    if (oldPasscodeController.text.isEmpty) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterOldPasscode);
      return false;
    }
    if (!PasscodeHelper.isValidFormat(oldPasscodeController.text)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterOldPasscode);
      return false;
    }
    if (!PasscodeHelper.isValidFormat(newPasscodeController.text)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterNewPasscode);
      return false;
    }
    if (!PasscodeHelper.isValidFormat(changedConfirmPasscodeController.text)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterConfirmPasscode);
      return false;
    }
    if (newPasscodeController.text.trim() !=
        changedConfirmPasscodeController.text.trim()) {
      ToastHelper().showErrorToast(
        loc.twoFactorValidationNewPasscodesDoNotMatch,
      );
      return false;
    }
    return true;
  }

  bool validateAddPasscodeStep() {
    final loc = AppLocalizations.of(Get.context!)!;
    if (!PasscodeHelper.isValidFormat(passcodeController.text)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterPasscode);
      return false;
    }
    if (!PasscodeHelper.isValidFormat(confirmPasscodeController.text)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterConfirmPasscode);
      return false;
    }
    if (passcodeController.text.trim() !=
        confirmPasscodeController.text.trim()) {
      ToastHelper().showErrorToast(
        loc.twoFactorValidationPasscodesDoNotMatch,
      );
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    super.onClose();
    enable2FaFocusNode.dispose();
    enable2FaController.dispose();
    disable2FaFocusNode.dispose();
    disable2FaController.dispose();
    passcodeFocusNode.dispose();
    passcodeController.dispose();
    confirmPasscodeFocusNode.dispose();
    confirmPasscodeController.dispose();
    oldPasscodeFocusNode.dispose();
    oldPasscodeController.dispose();
    newPasscodeFocusNode.dispose();
    newPasscodeController.dispose();
    changedConfirmPasscodeFocusNode.dispose();
    changedConfirmPasscodeController.dispose();
    passwordFocusNode.dispose();
    passwordController.dispose();
  }
}
