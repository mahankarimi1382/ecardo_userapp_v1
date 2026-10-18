import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';

/// Smart navigation back helper that respects the navigation stack.
/// Pops back to the previous screen (e.g. Services, Details, or Dashboard)
/// and only falls back to BaseRoute.navigation if no previous route exists.
class SmartBackHelper {
  SmartBackHelper._();

  static void handleBack(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
    } else {
      Get.offAllNamed(BaseRoute.navigation);
    }
  }
}
