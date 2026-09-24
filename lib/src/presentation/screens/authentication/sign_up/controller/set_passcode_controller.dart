import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

/// Mandatory transaction passcode setup (exactly 4 digits).
/// Used right after password setup and when an existing user has none.
class SetPasscodeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPasscodeFocused = false.obs;
  final RxBool isConfirmFocused = false.obs;

  final FocusNode passcodeFocusNode = FocusNode();
  final FocusNode confirmFocusNode = FocusNode();
  final passcodeController = TextEditingController();
  final confirmController = TextEditingController();

  /// Where to go after success. Defaults to sign-up status (onboarding).
  String get nextRoute {
    final args = Get.arguments;
    if (args is Map && args['next'] is String) {
      return args['next'] as String;
    }
    return BaseRoute.signUpStatus;
  }

  Map<String, dynamic>? get nextArgs {
    final args = Get.arguments;
    if (args is Map && args['next_args'] is Map) {
      return Map<String, dynamic>.from(args['next_args'] as Map);
    }
    if (nextRoute == BaseRoute.signUpStatus) {
      return {"is_password_set_up": true};
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    passcodeFocusNode.addListener(() {
      isPasscodeFocused.value = passcodeFocusNode.hasFocus;
    });
    confirmFocusNode.addListener(() {
      isConfirmFocused.value = confirmFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    passcodeFocusNode.dispose();
    confirmFocusNode.dispose();
    passcodeController.dispose();
    confirmController.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    final loc = AppLocalizations.of(Get.context!)!;
    final code = PasscodeHelper.normalize(passcodeController.text);
    final confirm = PasscodeHelper.normalize(confirmController.text);

    if (!PasscodeHelper.isValidFormat(code)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterPasscode);
      return;
    }
    if (!PasscodeHelper.isValidFormat(confirm)) {
      ToastHelper().showErrorToast(loc.twoFactorValidationEnterConfirmPasscode);
      return;
    }
    if (code != confirm) {
      ToastHelper().showErrorToast(loc.twoFactorValidationPasscodesDoNotMatch);
      return;
    }

    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.passcodeActiveEndpoint,
        data: {
          'passcode': code,
          'passcode_confirmation': confirm,
        },
      );
      if (response.status == Status.completed) {
        final msg = response.data?['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          ToastHelper().showSuccessToast(msg);
        }
        final route = nextRoute;
        final args = nextArgs;
        if (route == BaseRoute.navigation) {
          Get.offAllNamed(route);
        } else {
          Get.offNamed(route, arguments: args);
        }
      }
    } catch (e, st) {
      debugPrint('❌ SetPasscodeController.submit: $e');
      debugPrint('$st');
      ToastHelper().showErrorToast(loc.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }
}
