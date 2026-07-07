import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class VerifyPasscodeController extends GetxController {
  final RxBool isPasscodeVerifyLoading = false.obs;
  final RxBool isPasscodeFocused = false.obs;
  final localization = AppLocalizations.of(Get.context!);

  final FocusNode passcodeFocusNode = FocusNode();
  final TextEditingController passcodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    passcodeFocusNode.addListener(() {
      isPasscodeFocused.value = passcodeFocusNode.hasFocus;
    });
  }

  /// Submit Verify Passcode
  Future<bool> submitPasscodeVerify() async {
    if (passcodeController.text.trim().isEmpty) {
      ToastHelper().showErrorToast(
        localization!.verifyPasscodeValidationEnterPasscode,
      );
      return false;
    }

    isPasscodeVerifyLoading.value = true;

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.verifyPasscodeEndpoint,
        data: {"passcode": passcodeController.text.trim()},
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
