import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class ForgotPasswordController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // Email
  final RxBool isEmailFocused = false.obs;
  final FocusNode emailFocusNode = FocusNode();
  final emailController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    emailFocusNode.addListener(_handleEmailFocusChange);
  }

  @override
  void onClose() {
    emailFocusNode.removeListener(_handleEmailFocusChange);
    emailFocusNode.dispose();
    super.onClose();
  }

  // Email focus change handler
  void _handleEmailFocusChange() {
    isEmailFocused.value = emailFocusNode.hasFocus;
  }

  // Forgot Password Function
  Future<void> submitForgotPassword() async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "email": emailController.text.trim(),
      };
      final response = await Get.find<NetworkService>().globalPost(
        endpoint: ApiPath.forgotPasswordEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        Get.offNamed(
          BaseRoute.forgotPasswordPinVerification,
          arguments: {"email": emailController.text},
        );
        emailController.clear();
        ToastHelper().showSuccessToast(response.data?["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitForgotPassword() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }
}
