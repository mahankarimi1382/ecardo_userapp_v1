import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

class VerifyPasscodeController extends GetxController {
  final RxBool isPasscodeVerifyLoading = false.obs;
  final RxBool isPasscodeFocused = false.obs;
  AppLocalizations? get localization =>
      Get.context == null ? null : AppLocalizations.of(Get.context!);

  final FocusNode passcodeFocusNode = FocusNode();
  final TextEditingController passcodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    passcodeFocusNode.addListener(() {
      isPasscodeFocused.value = passcodeFocusNode.hasFocus;
    });
  }

  /// Returns true when server accepts the passcode.
  /// Caller must capture the passcode string BEFORE this clears the field.
  Future<bool> submitPasscodeVerify() async {
    final code = PasscodeHelper.normalize(passcodeController.text);
    if (!PasscodeHelper.isValidFormat(code)) {
      ToastHelper().showErrorToast(
        localization!.verifyPasscodeValidationEnterPasscode,
      );
      return false;
    }

    isPasscodeVerifyLoading.value = true;

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.verifyPasscodeEndpoint,
        data: {"passcode": code},
      );

      if (response.status == Status.completed) {
        passcodeController.clear();
        return true;
      }
      return false;
    } catch (e, stackTrace) {
      debugPrint('❌ submitPasscodeVerify() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
      return false;
    } finally {
      isPasscodeVerifyLoading.value = false;
    }
  }

  @override
  void onClose() {
    passcodeFocusNode.dispose();
    passcodeController.dispose();
    super.onClose();
  }
}
