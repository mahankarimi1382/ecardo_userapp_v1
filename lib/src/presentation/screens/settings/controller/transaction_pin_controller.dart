import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';

/// System B — Transaction PIN (رمز انتقال وجه).
/// Never mixes with Google 2FA or App Lock PIN.
class TransactionPinController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isBusy = false.obs;
  final RxBool hasPasscode = false.obs;

  // Set
  final passcodeController = TextEditingController();
  final confirmController = TextEditingController();
  final FocusNode passcodeFocus = FocusNode();
  final FocusNode confirmFocus = FocusNode();
  final RxBool isPasscodeFocused = false.obs;
  final RxBool isConfirmFocused = false.obs;

  // Change
  final oldController = TextEditingController();
  final newController = TextEditingController();
  final changeConfirmController = TextEditingController();
  final FocusNode oldFocus = FocusNode();
  final FocusNode newFocus = FocusNode();
  final FocusNode changeConfirmFocus = FocusNode();
  final RxBool isOldFocused = false.obs;
  final RxBool isNewFocused = false.obs;
  final RxBool isChangeConfirmFocused = false.obs;

  // Disable — account password only (server contract)
  final passwordController = TextEditingController();
  final FocusNode passwordFocus = FocusNode();
  final RxBool isPasswordFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    passcodeFocus.addListener(() => isPasscodeFocused.value = passcodeFocus.hasFocus);
    confirmFocus.addListener(() => isConfirmFocused.value = confirmFocus.hasFocus);
    oldFocus.addListener(() => isOldFocused.value = oldFocus.hasFocus);
    newFocus.addListener(() => isNewFocused.value = newFocus.hasFocus);
    changeConfirmFocus.addListener(
      () => isChangeConfirmFocused.value = changeConfirmFocus.hasFocus,
    );
    passwordFocus.addListener(() => isPasswordFocused.value = passwordFocus.hasFocus);
    fetchStatus();
  }

  Future<void> fetchStatus() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.passcodeStatusEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final map = Map<String, dynamic>.from(response.data!);
        PasscodeHelper.applyStatus(map);
        hasPasscode.value = PasscodeHelper.hasPasscodeFromStatus ?? false;
      }
    } catch (e, st) {
      debugPrint('TransactionPinController.fetchStatus: $e\n$st');
      // Fallback: user model passcode sentinel
      if (Get.isRegistered<HomeController>()) {
        final stored =
            Get.find<HomeController>().userModel.value.data?.passcode;
        hasPasscode.value = PasscodeHelper.userHasPasscode(stored);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitSet() async {
    final loc = AppLocalizations.of(Get.context!)!;
    final code = PasscodeHelper.normalize(passcodeController.text);
    final confirm = PasscodeHelper.normalize(confirmController.text);
    if (!PasscodeHelper.isValidFormat(code)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterPasscode);
      return;
    }
    if (code != confirm) {
      ToastHelper().showErrorToast(loc.twoFactorValidationPasscodesDoNotMatch);
      return;
    }
    isBusy.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.passcodeActiveEndpoint,
        data: {'passcode': code, 'passcode_confirmation': confirm},
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(
          response.data?['message']?.toString() ?? 'OK',
        );
        passcodeController.clear();
        confirmController.clear();
        PasscodeHelper.hasPasscodeFromStatus = true;
        hasPasscode.value = true;
        await _refreshHome();
        Get.back();
      }
    } catch (e, st) {
      debugPrint('submitSet: $e\n$st');
      ToastHelper().showErrorToast(loc.allControllerLoadError);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> submitChange() async {
    final loc = AppLocalizations.of(Get.context!)!;
    final old = PasscodeHelper.normalize(oldController.text);
    final neu = PasscodeHelper.normalize(newController.text);
    final conf = PasscodeHelper.normalize(changeConfirmController.text);
    if (!PasscodeHelper.isValidFormat(old) ||
        !PasscodeHelper.isValidFormat(neu) ||
        !PasscodeHelper.isValidFormat(conf)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterPasscode);
      return;
    }
    if (neu != conf) {
      ToastHelper().showErrorToast(
        loc.twoFactorValidationNewPasscodesDoNotMatch,
      );
      return;
    }
    isBusy.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.changePasscodeEndpoint,
        data: {
          'old_passcode': old,
          'passcode': neu,
          'passcode_confirmation': conf,
        },
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(
          response.data?['message']?.toString() ?? 'OK',
        );
        oldController.clear();
        newController.clear();
        changeConfirmController.clear();
        await fetchStatus();
        await _refreshHome();
        Get.back();
      }
    } catch (e, st) {
      debugPrint('submitChange: $e\n$st');
      ToastHelper().showErrorToast(loc.allControllerLoadError);
    } finally {
      isBusy.value = false;
    }
  }

  /// Disable requires account **password**, never the PIN itself.
  Future<void> submitDisable() async {
    final loc = AppLocalizations.of(Get.context!)!;
    final password = passwordController.text;
    if (password.isEmpty) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterPassword);
      return;
    }
    isBusy.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.disablePasscodeEndpoint,
        data: {'password': password},
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(
          response.data?['message']?.toString() ?? 'OK',
        );
        passwordController.clear();
        PasscodeHelper.hasPasscodeFromStatus = false;
        hasPasscode.value = false;
        await _refreshHome();
        Get.back();
      }
    } catch (e, st) {
      debugPrint('submitDisable: $e\n$st');
      ToastHelper().showErrorToast(loc.allControllerLoadError);
    } finally {
      isBusy.value = false;
    }
  }

  Future<void> _refreshHome() async {
    if (Get.isRegistered<HomeController>()) {
      await Get.find<HomeController>().fetchUser();
    }
  }

  @override
  void onClose() {
    passcodeController.dispose();
    confirmController.dispose();
    passcodeFocus.dispose();
    confirmFocus.dispose();
    oldController.dispose();
    newController.dispose();
    changeConfirmController.dispose();
    oldFocus.dispose();
    newFocus.dispose();
    changeConfirmFocus.dispose();
    passwordController.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}
