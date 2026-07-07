import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/home/controller/home_controller.dart';

class ChangePasswordController extends GetxController {
  // Global
  final RxBool isLoading = false.obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // Current Password
  final RxBool isCurrentPasswordFocused = false.obs;
  final RxBool isCurrentPasswordVisible = true.obs;
  final FocusNode currentPasswordFocusNode = FocusNode();
  final currentPasswordController = TextEditingController();

  // New Password
  final RxBool isNewPasswordFocused = false.obs;
  final RxBool isNewPasswordVisible = true.obs;
  final FocusNode newPasswordFocusNode = FocusNode();
  final newPasswordController = TextEditingController();

  // Confirm Password
  final RxBool isConfirmPasswordFocused = false.obs;
  final RxBool isConfirmPasswordVisible = true.obs;
  final FocusNode confirmPasswordFocusNode = FocusNode();
  final confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    currentPasswordFocusNode.addListener(_handleCurrentPasswordFocusChange);
    newPasswordFocusNode.addListener(_handleNewPasswordFocusChange);
    confirmPasswordFocusNode.addListener(_handleConfirmPasswordFocusChange);
  }

  @override
  void onClose() {
    currentPasswordFocusNode.removeListener(_handleCurrentPasswordFocusChange);
    newPasswordFocusNode.removeListener(_handleNewPasswordFocusChange);
    confirmPasswordFocusNode.removeListener(_handleConfirmPasswordFocusChange);
    currentPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    confirmPasswordFocusNode.dispose();
    super.onClose();
  }

  // Current password focus change handler
  void _handleCurrentPasswordFocusChange() {
    isCurrentPasswordFocused.value = currentPasswordFocusNode.hasFocus;
  }

  // New password focus change handler
  void _handleNewPasswordFocusChange() {
    isNewPasswordFocused.value = newPasswordFocusNode.hasFocus;
  }

  // Confirm password focus change handler
  void _handleConfirmPasswordFocusChange() {
    isConfirmPasswordFocused.value = confirmPasswordFocusNode.hasFocus;
  }

  // Change Password
  Future<void> changePassword() async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "current_password": currentPasswordController.text,
        "password": newPasswordController.text,
        "password_confirmation": confirmPasswordController.text,
      };

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.changePasswordEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        Get.find<HomeController>().submitLogout();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ changePassword() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Validate Password
  bool validatePassword() {
    if (currentPasswordController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.changePasswordValidationEnterCurrentPassword,
      );
      return false;
    }

    if (newPasswordController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.changePasswordValidationEnterNewPassword,
      );
      return false;
    }

    if (newPasswordController.text.length < 8) {
      ToastHelper().showErrorToast(
        localization.changePasswordValidationPasswordMinLength,
      );
      return false;
    }

    if (confirmPasswordController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.changePasswordValidationEnterConfirmPassword,
      );
      return false;
    }

    if (confirmPasswordController.text != newPasswordController.text) {
      ToastHelper().showErrorToast(
        localization.changePasswordValidationPasswordsDoNotMatch,
      );
      return false;
    }

    return true;
  }
}
