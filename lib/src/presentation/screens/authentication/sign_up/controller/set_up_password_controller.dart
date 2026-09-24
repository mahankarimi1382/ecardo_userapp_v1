import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/set_passcode_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/set_passcode/set_passcode_screen.dart';

class SetUpPasswordController extends GetxController {
  final RxBool isLoading = false.obs;

  final RxBool isPasswordFocused = false.obs;
  final RxBool isPasswordVisible = true.obs;
  final FocusNode passwordFocusNode = FocusNode();
  final passwordController = TextEditingController();

  final RxBool isConfirmPasswordFocused = false.obs;
  final RxBool isConfirmPasswordVisible = true.obs;
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final confirmPasswordController = TextEditingController();

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

  void _handlePasswordFocusChange() {
    isPasswordFocused.value = passwordFocusNode.hasFocus;
  }

  void _handleConfirmPasswordFocusChange() {
    isConfirmPasswordFocused.value = confirmPasswordFocusNode.hasFocus;
  }

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
        resetFields();
        // Mandatory 4-digit transaction passcode before onboarding continues.
        if (Get.isRegistered<SetPasscodeController>()) {
          Get.delete<SetPasscodeController>();
        }
        Get.put(SetPasscodeController());
        Get.off(
          () => const SetPasscodeScreen(),
          arguments: {
            'next': BaseRoute.signUpStatus,
            'next_args': {"is_password_set_up": true},
          },
        );
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
