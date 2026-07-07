import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

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

  // Password Controller
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

  // Fetch User
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

  // Get QR Code
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

  // Enable Two Factor
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

  // Disable Two factor
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

  // Submit Generate Passcode
  Future<void> submitGeneratePasscode() async {
    if (!validateAddPasscodeStep()) {
      return;
    }
    Get.back();
    isGeneratePasscodeLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.passcodeActiveEndpoint,
        data: {
          "passcode": passcodeController.text,
          "passcode_confirmation": confirmPasscodeController.text,
        },
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        passcodeController.clear();
        confirmPasscodeController.clear();
        await fetchUser();
        await Get.find<HomeController>().fetchUser();
      }
    } finally {
      isGeneratePasscodeLoading.value = false;
      passcodeController.clear();
      confirmPasscodeController.clear();
    }
  }

  // Submit Change Passcode
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
          "old_passcode": oldPasscodeController.text,
          "passcode": newPasscodeController.text,
          "passcode_confirmation": changedConfirmPasscodeController.text,
        },
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        oldPasscodeController.clear();
        newPasscodeController.clear();
        changedConfirmPasscodeController.clear();
        await fetchUser();
        await Get.find<HomeController>().fetchUser();
      }
    } finally {
      isChangePasscodeLoading.value = false;
      oldPasscodeController.clear();
      newPasscodeController.clear();
      changedConfirmPasscodeController.clear();
    }
  }

  // Submit Disable Passcode
  Future<void> submitDisablePasscode() async {
    if (!validateDisablePasscodeStep()) {
      return;
    }
    Get.back();
    isDisablePasscodeLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.disablePasscodeEndpoint,
        data: {"password": passwordController.text},
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        passwordController.clear();
        await fetchUser();
        await Get.find<HomeController>().fetchUser();
      }
    } finally {
      isDisablePasscodeLoading.value = false;
      passwordController.clear();
    }
  }

  // Validate Disable Password Step
  bool validateDisablePasscodeStep() {
    // Validate Password
    if (passwordController.text.isEmpty) {
      ToastHelper().showErrorToast("Please enter a password");
      return false;
    }

    return true;
  }

  // Validate Change Passcode Step
  bool validateChangePasscodeStep() {
    // Validate Old Passcode
    if (oldPasscodeController.text.isEmpty) {
      ToastHelper().showErrorToast("Please enter a old passcode");
      return false;
    }

    // Validate New Passcode
    if (newPasscodeController.text.isEmpty) {
      ToastHelper().showErrorToast("Please enter a new passcode");
      return false;
    }

    // Validate Confirm Passcode
    if (changedConfirmPasscodeController.text.isEmpty) {
      ToastHelper().showErrorToast("Please enter a confirm passcode");
      return false;
    }

    // Validate New Passcode and Confirm Passcode
    if (newPasscodeController.text != changedConfirmPasscodeController.text) {
      ToastHelper().showErrorToast(
        "New Passcode and confirm passcode do not match",
      );
      return false;
    }

    return true;
  }

  // Validate Add Passcode Step
  bool validateAddPasscodeStep() {
    // Validate Passcode
    if (passcodeController.text.isEmpty) {
      ToastHelper().showErrorToast("Please enter a passcode");
      return false;
    }

    // Validate Confirm Passcode
    if (confirmPasscodeController.text.isEmpty) {
      ToastHelper().showErrorToast("Please enter a confirm passcode");
      return false;
    }

    // Validate Passcode and Confirm Passcode
    if (passcodeController.text != confirmPasscodeController.text) {
      ToastHelper().showErrorToast(
        "Passcode and confirm passcode do not match",
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
