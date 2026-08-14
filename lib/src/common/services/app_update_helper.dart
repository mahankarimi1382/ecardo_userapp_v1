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
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// Conditional import — only mobile platforms can actually download APKs.
import 'mobile_update_helper.dart' if (dart.library.html) 'mobile_update_helper_web.dart';

class AppUpdateHelper {
  /// Imperative check triggered by the user (settings "Check for Updates").
  ///
  /// On web, only a refresh dialog is shown. On mobile, this either shows
  /// an "update available" dialog (with Download & Update button) or a
  /// snackbar telling the user they're already on the latest version.
  static Future<void> checkForUpdate(
    BuildContext context, {
    bool showMessageIfNoUpdate = false,
  }) async {
    try {
      final settings = Get.find<SettingsService>();
      String serverVersion =
          settings.getSetting('app_version') ?? '';
      String updateLink = settings.getSetting('app_update_link') ?? '';
      bool forceUpdate = settings.getSetting('app_force_update') == '1';

      if (serverVersion.isEmpty || updateLink.isEmpty) {
        if (showMessageIfNoUpdate) {
          Get.snackbar('System', 'You are on the latest version.');
        }
        return;
      }

      if (kIsWeb) {
        _showWebUpdateDialog(context, serverVersion, forceUpdate);
        return;
      }

      // Mobile path — prefer the new controller when it is registered so the
      // settings screen can transition to the full-screen update flow.
      if (Get.isRegistered<AppUpdateController>()) {
        final controller = Get.find<AppUpdateController>();
        await controller.checkForUpdate(
          showSnackbarWhenUpToDate: showMessageIfNoUpdate,
        );
        if (controller.phase.value == AppUpdatePhase.updateAvailable) {
          _showMobileUpdateDialog(
            context,
            controller.serverVersion.value,
            updateLink,
            forceUpdate,
          );
        }
        return;
      }

      // Fallback: legacy dialog that calls downloadAndInstallApk directly.
      _showMobileUpdateDialog(
        context,
        serverVersion,
        updateLink,
        forceUpdate,
      );
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
  }

  /// Called on app launch (e.g. from the splash or home screen) to
  /// optionally show the update dialog without nagging the user twice for
  /// the same version.
  ///
  /// Skipped entirely when:
  ///   - the platform is web
  ///   - the user has disabled auto-update
  ///   - the user has already been prompted about this version
  ///   - the running version is already up to date
  static Future<void> maybeAutoPromptForUpdate(BuildContext context) async {
    if (kIsWeb) return;
    if (!Get.isRegistered<AppUpdateController>()) return;

    final controller = Get.find<AppUpdateController>();
    if (!controller.autoUpdateEnabled.value) return;

    try {
      final settings = Get.find<SettingsService>();
      final server = settings.getSetting('app_version') ?? '';
      final link = settings.getSetting('app_update_link') ?? '';
      if (server.isEmpty || link.isEmpty) return;

      final available = await controller.isNewVersionAvailable();
      if (!available) return;

      final shouldPrompt = await controller.shouldAutoPrompt(server);
      if (!shouldPrompt) return;

      final force =
          settings.getSetting('app_force_update') == '1';
      _showMobileUpdateDialog(context, server, link, force);
      await controller.markVersionAsPrompted(server);
    } catch (e) {
      debugPrint('Auto-prompt update check error: $e');
    }
  }

  // ===========================================================================
  // Dialog UI
  // ===========================================================================

  static void _showMobileUpdateDialog(
    BuildContext context,
    String version,
    String url,
    bool forceUpdate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text('New Update Available ($version)'),
            content: const Text(
              'A new version of the application is available. '
              'Please update to continue.',
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  downloadAndInstallApk(url);
                },
                child: const Text(
                  'Download & Update',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static void _showWebUpdateDialog(
    BuildContext context,
    String version,
    bool forceUpdate,
  ) {
    showDialog(
      context: context,
      barrierDismissible: !forceUpdate,
      builder: (ctx) {
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text('New Update Available ($version)'),
            content: const Text(
              'A new version is available. Please refresh the page to get '
              'the latest version.',
            ),
            actions: [
              if (!forceUpdate)
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Later'),
                ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.lightPrimary,
                ),
                onPressed: () {
                  Get.back();
                  Get.offAllNamed('/');
                },
                child: const Text(
                  'Refresh Page',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
