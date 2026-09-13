import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';

class TwoFactorAuthController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;

  // Pin Code
  final pinCodeController = TextEditingController();

  // Two Factor Auth Verification Function
  Future<void> submitTwoFaVerification() async {
    isLoading.value = true;
    try {
      final Map<String, dynamic> requestBody = {"code": pinCodeController.text};
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.twoFaEndpoint,
        data: requestBody,
      );
      if (response.status == Status.completed) {
        // v1.0.24: mirror sign_in — users who have NOT completed onboarding
        // must be routed to the sign-up status flow, not straight home.
        final bool onboardingCompleted = Get.isRegistered<SignInController>()
            ? (Get.find<SignInController>()
                    .userModel
                    .value
                    .data
                    ?.boardingSteps
                    ?.completed ==
                true)
            : false;
        if (onboardingCompleted) {
          Get.offAllNamed(BaseRoute.navigation);
        } else {
          Get.toNamed(
            BaseRoute.signUpStatus,
            arguments: {"is_login_state": true},
          );
        }
        pinCodeController.clear();
        ToastHelper().showSuccessToast(response.data!["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitTwoFaVerification() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
