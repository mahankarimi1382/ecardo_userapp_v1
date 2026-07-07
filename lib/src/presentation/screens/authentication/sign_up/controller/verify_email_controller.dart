import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';

class VerifyEmailController extends GetxController {
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

  // Validate Verify Email
  Future<void> validateVerifyEmail({required String email}) async {
    isLoading.value = true;
    try {
      final response = await NetworkService().globalPost(
        endpoint: ApiPath.validateVerifyEmailEndpoint,
        data: {"otp": pinCodeController.text, "email": email},
      );
      if (response.status == Status.completed) {
        await Get.find<SettingsService>().saveEmailVerified(true);
        Get.offNamed(BaseRoute.signUpStatus);
        pinCodeController.clear();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ validateVerifyEmail() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Resend Send Verify Email
  Future<void> sendVerifyEmail({required String email}) async {
    isLoading.value = true;
    try {
      final response = await NetworkService().globalPost(
        endpoint: ApiPath.verifyEmailEndpoint,
        data: {"email": email},
      );
      if (response.status == Status.completed) {
        resendOtp();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ sendVerifyEmail() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
