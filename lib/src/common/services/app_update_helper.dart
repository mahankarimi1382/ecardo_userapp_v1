// ============================================================================
// app_update_helper.dart
// ----------------------------------------------------------------------------
// High-level entry point for the in-app self-update flow.
//
// Two entry points are exposed:
//   - [checkForUpdate]: legacy imperative API used by the settings screen.
//   - [maybeAutoPromptForUpdate]: called on app launch to optionally show
//     the update dialog without bothering the user twice for the same
//     version.
//
// Both delegate to [AppUpdateController] for the actual work. The dialog UI
// itself is intentionally kept here (rather than in the controller) because
// it's a presentational concern.
// ============================================================================

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

class AppUpdateHelper {
  /// Imperative check triggered by the user (settings "Check for Updates").
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool showMessageIfNoUpdate = false,
  }) async {
    try {
      if (kIsWeb) {
        final settings = Get.find<SettingsService>();
        String serverVersion = settings.getSetting('app_version') ?? '';
        bool forceUpdate = settings.getSetting('app_force_update') == '1';
        _showWebUpdateDialog(context, serverVersion, forceUpdate);
        return;
      }

      if (Get.isRegistered<AppUpdateController>()) {
        final controller = Get.find<AppUpdateController>();
        await controller.checkForUpdate(
          showSnackbarWhenUpToDate: showMessageIfNoUpdate,
        );
        if (controller.phase.value == AppUpdatePhase.updateAvailable &&
            context.mounted) {
          Get.toNamed(BaseRoute.appUpdate);
        }
        return;
      }

      Get.toNamed(BaseRoute.appUpdate);
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
  }

  /// Called on app launch to optionally route the user to the update flow.
  static Future<void> maybeAutoPromptForUpdate(BuildContext context) async {
    if (kIsWeb) return;
    if (!Get.isRegistered<AppUpdateController>()) return;

    final controller = Get.find<AppUpdateController>();

    try {
      final available = await controller.isNewVersionAvailable();
      if (!available) return;

      final force = controller.forceUpdate.value;
      final server = controller.serverVersion.value;

      if (!force) {
        if (!controller.autoUpdateEnabled.value) return;

        final shouldPrompt = await controller.shouldAutoPrompt(server);
        if (!shouldPrompt) return;
      }

      if (!context.mounted) return;
      Get.toNamed(BaseRoute.appUpdate);
      await controller.markVersionAsPrompted(server);
    } catch (e) {
      debugPrint('Auto-prompt update check error: $e');
    }
  }

  /// v1.0.26 (UPD-5): server-driven force update — the API answered 426
  /// (CheckAppVersion middleware). Routes to the non-dismissible full-screen
  /// update flow.
  static bool _serverForcedDialogShown = false;

  static void handleServerForcedUpdate(Map<String, dynamic>? body) {
    if (kIsWeb) return;
    if (_serverForcedDialogShown) return;
    if (!Get.isRegistered<AppUpdateController>()) return;

    try {
      final settings = Get.find<SettingsService>();
      final latest = (body?['latest_version'] ??
              settings.getSetting('app_version') ??
              '')
          .toString().trim();
      final link = (body?['update_url'] ??
              settings.getSetting('app_update_link') ??
              '')
          .toString().trim();

      if (latest.isEmpty && link.isEmpty) return;

      final controller = Get.find<AppUpdateController>();
      if (latest.isNotEmpty) controller.serverVersion.value = latest;
      if (link.isNotEmpty) controller.updateUrl.value = link;
      controller.forceUpdate.value = true;

      _serverForcedDialogShown = true;
      Get.toNamed(BaseRoute.appUpdate);
    } catch (e) {
      debugPrint('Server forced-update handling failed: $e');
    }
  }

  // ===========================================================================
  // Dialog UI (web only — mobile goes to the full-screen update flow)
  // ===========================================================================

  static void _showWebUpdateDialog(
    BuildContext context,
    String version,
    bool forceUpdate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) {
        final localization = AppLocalizations.of(ctx);
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text(
              localization?.updateAvailableTitle(version) ??
                  'New Update Available ($version)',
            ),
            content: Text(
              localization?.updateWebBody ??
                  'A new version is available. Please refresh the page to '
                      'get the latest version.',
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(localization?.updateLater ?? 'Later'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                ),
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/');
                },
                child: Text(
                  localization?.updateWebRefresh ?? 'Refresh Page',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
