import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class ForgotPasswordPinVerificationController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPinEnabled = true.obs;
  final RxInt countdown = 30.obs;
  Timer? _timer;

  // Pin Code
  final pinCodeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  // Start Timer
  void startTimer() {
    countdown.value = 30;
    isPinEnabled.value = true;
    pinCodeController.clear();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        pinCodeController.clear();
        isPinEnabled.value = false;
        _timer?.cancel();
      }
    });
  }

  // Resend OTP
  void resendOtp() {
    pinCodeController.clear();
    startTimer();
  }

  // Reset Verify OTP Function
  Future<void> submitResetVerifyOtp({required String email}) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {
        "otp": pinCodeController.text,
        "email": email,
      };
      final response = await Get.find<NetworkService>().globalPost(
        endpoint: ApiPath.resetVerifyOtpEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        Get.offNamed(
          BaseRoute.resetPassword,
          arguments: {"email": email, "otp": pinCodeController.text},
        );
        ToastHelper().showSuccessToast(response.data!["message"]);
        pinCodeController.clear();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitResetVerifyOtp() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Forgot Password Function
  Future<void> submitForgotPassword({required String email}) async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {"email": email};
      final response = await Get.find<NetworkService>().globalPost(
        endpoint: ApiPath.forgotPasswordEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        resendOtp();
        ToastHelper().showSuccessToast(response.data?["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitForgotPassword() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
