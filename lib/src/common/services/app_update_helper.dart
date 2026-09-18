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
        if (!context.mounted) return;
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
  ///   - the update is optional and the user has disabled auto-update
  ///   - the update is optional and the user has already been prompted
  ///   - the running version is already up to date
  ///
  /// v1.0.26 (UPD-5): FORCED updates bypass the auto-update toggle and the
  /// already-prompted gate — the admin explicitly required every old client
  /// to be prompted, and the server 426-gate blocks their API calls anyway.
  static Future<void> maybeAutoPromptForUpdate(BuildContext context) async {
    if (kIsWeb) return;
    if (!Get.isRegistered<AppUpdateController>()) return;

    final controller = Get.find<AppUpdateController>();

    try {
      final settings = Get.find<SettingsService>();
      final server = settings.getSetting('app_version') ?? '';
      final link = settings.getSetting('app_update_link') ?? '';
      if (server.isEmpty || link.isEmpty) return;

      final force = settings.getSetting('app_force_update') == '1';

      final available = await controller.isNewVersionAvailable();
      if (!available) return;

      if (!force) {
        if (!controller.autoUpdateEnabled.value) return;

        final shouldPrompt = await controller.shouldAutoPrompt(server);
        if (!shouldPrompt) return;
      }

      if (!context.mounted) return;
      _showMobileUpdateDialog(context, server, link, force);
      await controller.markVersionAsPrompted(server);
    } catch (e) {
      debugPrint('Auto-prompt update check error: $e');
    }
  }

  /// v1.0.26 (UPD-5): server-driven force update — the API answered 426
  /// (CheckAppVersion middleware). Shows the non-dismissible update dialog
  /// with the settings download link. A static guard keeps parallel 426
  /// responses from stacking dialogs; it stays set for the whole session
  /// because the user cannot use the app until they update anyway.
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
          .toString();
      final link = settings.getSetting('app_update_link') ?? '';
      if (latest.isEmpty || link.isEmpty) return;

      final controller = Get.find<AppUpdateController>();
      controller.serverVersion.value = latest;
      controller.forceUpdate.value = true;

      _serverForcedDialogShown = true;
      _showMobileUpdateDialog(Get.context!, latest, link, true);
    } catch (e) {
      debugPrint('Server forced-update handling failed: $e');
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
        // v1.0.24: localized title/buttons (were hardcoded English).
        final localization = AppLocalizations.of(ctx);
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text(
              localization?.updateAvailableTitle(version) ??
                  'New Update Available ($version)',
            ),
            content: const Text(
              'A new version of the application is available. '
              'Please update to continue.',
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
        // v1.0.24: localized title/buttons (were hardcoded English).
        final localization = AppLocalizations.of(ctx);
        return PopScope(
          canPop: !forceUpdate,
          child: AlertDialog(
            title: Text(
              localization?.updateAvailableTitle(version) ??
                  'New Update Available ($version)',
            ),
            content: const Text(
              'A new version is available. Please refresh the page to get '
              'the latest version.',
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
