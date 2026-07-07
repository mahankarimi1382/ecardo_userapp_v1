import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class SetUpPasswordController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;

  // Password
  final RxBool isPasswordFocused = false.obs;
  final RxBool isPasswordVisible = true.obs;
  final FocusNode passwordFocusNode = FocusNode();
  final passwordController = TextEditingController();

  // Confirm Password
  final RxBool isConfirmPasswordFocused = false.obs;
  final RxBool isConfirmPasswordVisible = true.obs;
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final confirmPasswordController = TextEditingController();

  // Terms & Condition
  final RxBool isTermsAndConditionChecked = false.obs;

  @override
  void onInit() {
    super.onInit();
    passwordFocusNode.addListener(_handlePasswordFocusChange);
    confirmPasswordFocusNode.addListener(_handleConfirmPasswordFocusChange);
  }

  @override
  void onClose() {
    passwordFocusNode.removeListener(_handlePasswordFocusChange);
    confirmPasswordFocusNode.removeListener(_handleConfirmPasswordFocusChange);
    passwordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  // Password focus change handler
  void _handlePasswordFocusChange() {
    isPasswordFocused.value = passwordFocusNode.hasFocus;
  }

  // Confirm Password focus change handler
  void _handleConfirmPasswordFocusChange() {
    isConfirmPasswordFocused.value = confirmPasswordFocusNode.hasFocus;
  }

  // Set Up Password
  Future<void> setUpPassword() async {
    isLoading.value = true;
    try {
      final savedEmail = await SettingsService.getLoggedInUserEmail();
      final isEmailVerified = await SettingsService.getEmailVerified();
      final Map<String, dynamic> requestBody = {
        "email": savedEmail.toString(),
        "password": passwordController.text,
        "password_confirmation": confirmPasswordController.text,
        "i_agree": isTermsAndConditionChecked.value ? "1" : "0",
        "is_email_verified": isEmailVerified,
      };
      final response = await Get.find<NetworkService>().register(
        data: requestBody,
      );
      if (response.status == Status.completed) {
        await Get.find<SettingsService>().saveSetUpPassword(true);
        await Get.find<SettingsService>().saveBiometricEnableOrDisable(false);
        Get.toNamed(
          BaseRoute.signUpStatus,
          arguments: {"is_password_set_up": true},
        );
        resetFields();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ setUpPassword() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset Fields
  void resetFields() {
    passwordController.clear();
    confirmPasswordController.clear();
    isPasswordVisible.value = true;
    isConfirmPasswordVisible.value = true;
    isPasswordFocused.value = false;
    isConfirmPasswordFocused.value = false;
    isTermsAndConditionChecked.value = false;
  }
}
