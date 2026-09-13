import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_helper.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

class SplashController extends GetxController {
  Future<void> navigateBasedOnAuth() async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult.contains(ConnectivityResult.none) ||
        connectivityResult.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Get.currentRoute != BaseRoute.noInternetConnection) {
          Get.offAllNamed(BaseRoute.noInternetConnection);
        }
      });
      return;
    }

    final loginState = await SettingsService.getLoginCurrentState();

    if (loginState != null && loginState.isNotEmpty) {
      Get.offNamed(BaseRoute.signIn);
    } else {
      Get.offNamed(BaseRoute.welcome);
    }

    // v1.0.26 (UPD-5): surface any pending update right after landing.
    // Previously this helper existed but was NEVER called, so the live
    // force_update=1 flag had no client-side effect for users who never
    // opened Settings → Check for Updates. Forced updates bypass the
    // auto-update toggle and the already-prompted gate inside the helper.
    Future.delayed(const Duration(milliseconds: 600), () {
      final ctx = Get.context;
      if (ctx != null) {
        AppUpdateHelper.maybeAutoPromptForUpdate(ctx);
      }
    });
  }
}
