import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

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
  // phase2-fix: the countdown now only gates the Resend action — the OTP
  // field used to be wiped AND locked after 30 seconds, making the emailed
  // code impossible to type on slow delivery.
  void startTimer() {
    countdown.value = 30;
    isPinEnabled.value = true;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
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
