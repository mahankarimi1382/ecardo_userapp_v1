// ============================================================================
// mobile_update_helper.dart
// ----------------------------------------------------------------------------
// Thin backward-compatible shim around [AppUpdateController].
//
// Older call sites (e.g. `app_update_helper.dart`) call
// `downloadAndInstallApk(url)` and expect a simple Future<void>. This shim
// preserves that contract while delegating to the new state-managed
// controller so all UI code can be migrated incrementally.
// ============================================================================

import 'package:get/get.dart';

import 'package:ecardo_user/src/common/services/app_update_controller.dart';

/// Downloads and installs the APK at [url].
///
/// Delegates to [AppUpdateController.startDownloadAndInstall] when the
/// controller is registered, otherwise falls back to a no-op + snackbar
/// so the app does not crash if the controller was not wired up.
Future<void> downloadAndInstallApk(String url) async {
  try {
    if (!Get.isRegistered<AppUpdateController>()) {
      Get.snackbar(
        'Update',
        'Update service is not initialized. Please restart the app.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    final controller = Get.find<AppUpdateController>();
    await controller.startDownloadAndInstall();
  } catch (e) {
    Get.snackbar(
      'Download Error',
      'Could not start the update: $e',
      snackPosition: SnackPosition.BOTTOM,
    );
    rethrow;
  }
}
