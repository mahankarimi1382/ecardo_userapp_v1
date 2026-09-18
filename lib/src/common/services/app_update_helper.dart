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
  ///
  /// On web, only a refresh dialog is shown. On mobile, when an update is
  /// available the user is taken to the FULL-SCREEN update flow — the same
  /// screen with the animated download progress they reach from the update
  /// notification — so there is exactly one update UX everywhere.
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
          final localization = AppLocalizations.of(context);
          Get.snackbar(
            localization?.updateSystemTitle ?? 'System',
            localization?.updateUpToDate ?? 'You are on the latest version.',
          );
        }
        return;
      }

      if (kIsWeb) {
        _showWebUpdateDialog(context, serverVersion, forceUpdate);
        return;
      }

      // Mobile path — the controller performs the check (so the screen lands
      // directly on the right phase) and the user is routed to the
      // full-screen update flow. With auto-update enabled the screen starts
      // the download by itself.
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

      // Fallback (controller not registered — should not happen since it is
      // registered permanently in main.dart): route to the screen anyway; it
      // reports the missing service instead of silently doing nothing.
      Get.toNamed(BaseRoute.appUpdate);
    } catch (e) {
      debugPrint('Update Check Error: $e');
    }
  }

  /// Called on app launch (e.g. from the splash or home screen) to
  /// optionally route the user to the full-screen update flow without
  /// nagging them twice for the same version.
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
  /// v1.0.35: opens the full-screen update flow instead of a dialog.
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
      Get.toNamed(BaseRoute.appUpdate);
      await controller.markVersionAsPrompted(server);
    } catch (e) {
      debugPrint('Auto-prompt update check error: $e');
    }
  }

  /// v1.0.26 (UPD-5): server-driven force update — the API answered 426
  /// (CheckAppVersion middleware). Routes to the non-dismissible full-screen
  /// update flow. A static guard keeps parallel 426 responses from stacking
  /// navigations; it stays set for the whole session because the user cannot
  /// use the app until they update anyway.
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
        // v1.0.24: localized title/buttons (were hardcoded English).
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
