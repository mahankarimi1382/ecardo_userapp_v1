import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class ResetPasswordController extends GetxController {
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

  // Reset Password Function
  Future<void> submitResetPassword({
    required String email,
    required String otp,
  }) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "email": email,
        "otp": otp,
        "password": passwordController.text,
        "password_confirmation": confirmPasswordController.text,
      };
      final response = await Get.find<NetworkService>().globalPost(
        endpoint: ApiPath.resetPasswordEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        Get.offNamed(BaseRoute.signIn);
        passwordController.clear();
        confirmPasswordController.clear();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitResetPassword() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
