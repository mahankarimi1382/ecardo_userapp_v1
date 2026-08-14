// ============================================================================
// AppUpdateController
// ----------------------------------------------------------------------------
// Full state-managed controller for the in-app self-update flow.
//
// Responsibilities:
//   1. Fetch the latest version metadata from the backend SettingsService.
//   2. Compare the running version against the server version (semver-aware).
//   3. Stream download progress (percent + downloaded/total bytes).
//   4. Hand off the downloaded APK to the system Package Installer.
//   5. Persist the user's "auto-update" toggle preference.
//
// State machine:
//   idle -> checking -> updateAvailable / upToDate / error
//   updateAvailable -> downloading (progress 0..100) -> installing -> idle/error
//
// This controller is app-agnostic — pass an [AppUpdateConfig] when registering
// it so the same code can drive the user, merchant and agent apps.
// ============================================================================

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// Phases the update flow can be in. Exposed so the UI can switch on a single
/// enum instead of inspecting multiple booleans.
enum AppUpdatePhase {
  /// Nothing in flight.
  idle,

  /// Talking to the server / comparing versions.
  checking,

  /// Server says a newer version exists; waiting for the user to confirm.
  updateAvailable,

  /// No newer version — used for the manual "check for updates" path.
  upToDate,

  /// APK is being downloaded; progress is exposed via [progressPercent].
  downloading,

  /// Download finished, system Package Installer has been launched.
  installing,

  /// Something went wrong; [errorMessage] is populated.
  error,
}

/// Per-app configuration. Allows the same controller to be reused for the
/// user, merchant and agent apps without hard-coding package names.
class AppUpdateConfig {
  /// SharedPreferences key under which the "auto-update enabled" boolean is
  /// persisted. Must be unique per app to avoid one app toggling the others.
  final String autoUpdatePrefsKey;

  /// SharedPreferences key used to remember which server version the user
  /// has already been prompted about, so we don't nag them on every launch.
  final String lastPromptedVersionPrefsKey;

  /// File name used for the downloaded APK inside the app's documents dir.
  final String apkFileName;

  /// SharedPreferences key that the backend populates with the latest
  /// version string (e.g. "1.0.8").
  final String settingKeyVersion;

  /// SharedPreferences key that the backend populates with the download URL.
  final String settingKeyUpdateLink;

  /// SharedPreferences key that the backend populates with "1" to force.
  final String settingKeyForceUpdate;

  const AppUpdateConfig({
    required this.autoUpdatePrefsKey,
    required this.lastPromptedVersionPrefsKey,
    required this.apkFileName,
    required this.settingKeyVersion,
    required this.settingKeyUpdateLink,
    required this.settingKeyForceUpdate,
  });

  /// Default configuration for the eCardo **user** app.
  static const AppUpdateConfig user = AppUpdateConfig(
    autoUpdatePrefsKey: 'auto_update_enabled_user',
    lastPromptedVersionPrefsKey: 'last_prompted_version_user',
    apkFileName: 'ecardo_user_update.apk',
    settingKeyVersion: 'app_version',
    settingKeyUpdateLink: 'app_update_link',
    settingKeyForceUpdate: 'app_force_update',
  );

  /// Configuration for the eCardo **merchant** app.
  static const AppUpdateConfig merchant = AppUpdateConfig(
    autoUpdatePrefsKey: 'auto_update_enabled_merchant',
    lastPromptedVersionPrefsKey: 'last_prompted_version_merchant',
    apkFileName: 'ecardo_merchant_update.apk',
    settingKeyVersion: 'app_version',
    settingKeyUpdateLink: 'app_update_link',
    settingKeyForceUpdate: 'app_force_update',
  );

  /// Configuration for the eCardo **agent** app.
  static const AppUpdateConfig agent = AppUpdateConfig(
    autoUpdatePrefsKey: 'auto_update_enabled_agent',
    lastPromptedVersionPrefsKey: 'last_prompted_version_agent',
    apkFileName: 'ecardo_agent_update.apk',
    settingKeyVersion: 'app_version',
    settingKeyUpdateLink: 'app_update_link',
    settingKeyForceUpdate: 'app_force_update',
  );
}

class AppUpdateController extends GetxController {
  AppUpdateController({required this.config});

  final AppUpdateConfig config;

  // ----- Reactive state exposed to the UI -----
  final Rx<AppUpdatePhase> phase = AppUpdatePhase.idle.obs;
  final RxInt progressPercent = 0.obs;
  final RxString downloadedBytesLabel = ''.obs;
  final RxString totalBytesLabel = ''.obs;
  final RxString serverVersion = ''.obs;
  final RxString currentVersion = ''.obs;
  final RxBool forceUpdate = false.obs;
  final RxBool autoUpdateEnabled = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime?> lastCheckedAt = Rx<DateTime?>(null);

  // ----- Internal -----
  CancelToken? _cancelToken;
  String? _downloadedApkPath;

  @override
  void onInit() {
    super.onInit();
    _loadAutoUpdatePreference();
    _loadCurrentVersion();
  }

  // ===========================================================================
  // Public API
  // ===========================================================================

  /// Reads the persisted "auto-update enabled" flag.
  Future<bool> isAutoUpdateEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(config.autoUpdatePrefsKey) ?? true;
  }

  /// Persists the "auto-update enabled" flag.
  Future<void> setAutoUpdateEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(config.autoUpdatePrefsKey, enabled);
    autoUpdateEnabled.value = enabled;
  }

  /// Returns true if the server has a newer version than the running app.
  ///
  /// Side-effect free: does not change [phase]. Useful for callers that only
  /// need a yes/no answer (e.g. the splash screen deciding whether to show
  /// the update dialog).
  Future<bool> isNewVersionAvailable() async {
    final settings = Get.find<SettingsService>();
    final server = settings.getSetting(config.settingKeyVersion) ?? '';
    final link = settings.getSetting(config.settingKeyUpdateLink) ?? '';
    if (server.isEmpty || link.isEmpty) return false;

    final info = await PackageInfo.fromPlatform();
    return _isVersionNewer(server, info.version);
  }

  /// Manual check triggered by the user from the settings screen.
  ///
  /// [showSnackbarWhenUpToDate] controls whether a snackbar is shown when
  /// the app is already on the latest version. Defaults to true because the
  /// user explicitly asked for a check.
  Future<void> checkForUpdate({
    bool showSnackbarWhenUpToDate = true,
  }) async {
    if (phase.value == AppUpdatePhase.checking ||
        phase.value == AppUpdatePhase.downloading) {
      return; // Already busy.
    }

    phase.value = AppUpdatePhase.checking;
    errorMessage.value = '';
    lastCheckedAt.value = DateTime.now();

    try {
      final settings = Get.find<SettingsService>();
      // Always refresh settings from the server so the comparison reflects
      // what the admin just published, not what was cached from last launch.
      await settings.fetchSettings();

      final server = settings.getSetting(config.settingKeyVersion) ?? '';
      final link = settings.getSetting(config.settingKeyUpdateLink) ?? '';
      final force = settings.getSetting(config.settingKeyForceUpdate) == '1';

      serverVersion.value = server;
      forceUpdate.value = force;

      if (server.isEmpty || link.isEmpty) {
        phase.value = AppUpdatePhase.upToDate;
        if (showSnackbarWhenUpToDate) {
          _toast('You are on the latest version.');
        }
        return;
      }

      final info = await PackageInfo.fromPlatform();
      currentVersion.value = info.version;

      if (_isVersionNewer(server, info.version)) {
        phase.value = AppUpdatePhase.updateAvailable;
      } else {
        phase.value = AppUpdatePhase.upToDate;
        if (showSnackbarWhenUpToDate) {
          _toast('App is up to date (${info.version})');
        }
      }
    } catch (e) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value = 'Could not check for updates: $e';
    }
  }

  /// Starts the download → install flow. The UI should react to [phase]
  /// transitions: when [downloading] it shows a progress bar, when
  /// [installing] it shows an indeterminate spinner.
  Future<void> startDownloadAndInstall() async {
    if (phase.value == AppUpdatePhase.downloading) return;

    final settings = Get.find<SettingsService>();
    final url = settings.getSetting(config.settingKeyUpdateLink) ?? '';
    if (url.isEmpty) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value = 'Download URL is not configured.';
      return;
    }

    // ----- Permissions -----
    final granted = await _ensureInstallPermission();
    if (!granted) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value =
          'Storage / install permission is required to download the update.';
      return;
    }

    // ----- Download -----
    phase.value = AppUpdatePhase.downloading;
    progressPercent.value = 0;
    downloadedBytesLabel.value = '';
    totalBytesLabel.value = '';

    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/${config.apkFileName}';
      _downloadedApkPath = filePath;

      _cancelToken = CancelToken();
      final dio = Dio();
      await dio.download(
        url,
        filePath,
        cancelToken: _cancelToken,
        onReceiveProgress: (received, total) {
          if (total <= 0) return;
          final percent = (received / total * 100).clamp(0, 100).toInt();
          progressPercent.value = percent;
          downloadedBytesLabel.value = _formatBytes(received);
          totalBytesLabel.value = _formatBytes(total);
        },
      );

      // ----- Hand off to system installer -----
      phase.value = AppUpdatePhase.installing;
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        phase.value = AppUpdatePhase.error;
        errorMessage.value = 'Failed to open APK: ${result.message}';
        return;
      }

      // The user is now in the system installer UI. When they finish (either
      // install or cancel), Android brings our app back to the foreground
      // and our Activity resumes. We reset to idle so a future check works.
      // We do NOT immediately reset to idle because the user might still be
      // staring at the system installer; instead, we wait for the user to
      // come back and explicitly dismiss our screen.
    } on DioException catch (e) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value = 'Download failed: ${e.message ?? e.type.name}';
    } catch (e) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value = 'Download failed: $e';
    }
  }

  /// Cancels an in-flight download. No-op if nothing is downloading.
  Future<void> cancelDownload() async {
    if (_cancelToken != null && !_cancelToken!.isCancelled) {
      _cancelToken!.cancel('user_cancelled');
    }
    phase.value = AppUpdatePhase.idle;
    progressPercent.value = 0;
    downloadedBytesLabel.value = '';
    totalBytesLabel.value = '';
  }

  /// Resets the controller to its idle state. The UI calls this when the
  /// user dismisses the update screen.
  void reset() {
    phase.value = AppUpdatePhase.idle;
    progressPercent.value = 0;
    downloadedBytesLabel.value = '';
    totalBytesLabel.value = '';
    errorMessage.value = '';
  }

  /// Records that the user has been prompted about [version], so that
  /// [shouldAutoPrompt] returns false for the same version on subsequent
  /// launches. This prevents the dialog from reappearing every cold start.
  Future<void> markVersionAsPrompted(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(config.lastPromptedVersionPrefsKey, version);
  }

  /// Returns true if the controller should auto-prompt about [version]
  /// (i.e. the user has auto-update enabled and has not yet been prompted
  /// about this specific version).
  Future<bool> shouldAutoPrompt(String version) async {
    if (!autoUpdateEnabled.value) return false;
    final prefs = await SharedPreferences.getInstance();
    final lastPrompted =
        prefs.getString(config.lastPromptedVersionPrefsKey) ?? '';
    return lastPrompted != version;
  }

  // ===========================================================================
  // Internals
  // ===========================================================================

  Future<void> _loadAutoUpdatePreference() async {
    autoUpdateEnabled.value = await isAutoUpdateEnabled();
  }

  Future<void> _loadCurrentVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      currentVersion.value = info.version;
    } catch (_) {
      // Non-fatal — UI falls back to empty string.
    }
  }

  /// Requests the right storage/install permission depending on Android
  /// version. Returns true if the app is allowed to download AND install.
  Future<bool> _ensureInstallPermission() async {
    // Android 13+ does not need storage permission for the app's own
    // documents directory, but older versions do.
    final storage = await Permission.storage.request();
    final storageOk = storage.isGranted || storage.isLimited;

    // REQUEST_INSTALL_PACKAGES is its own permission on Android 8+.
    // permission_handler exposes it as `Permission.requestInstallPackages`,
    // but it may be `undefined` on iOS — guard with a try/catch.
    bool installOk = true;
    try {
      final install = await Permission.requestInstallPackages.request();
      installOk = install.isGranted || install.isLimited;
    } on UnimplementedError {
      // Older permission_handler or unsupported platform — ignore.
    }

    return storageOk && installOk;
  }

  /// Returns true if [server] is strictly newer than [current] using
  /// semver-style numeric comparison (1.0.10 > 1.0.9, even though
  /// lexicographic comparison would say otherwise).
  bool _isVersionNewer(String server, String current) {
    final serverParts =
        server.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final currentParts =
        current.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final maxLen =
        serverParts.length > currentParts.length
            ? serverParts.length
            : currentParts.length;
    for (var i = 0; i < maxLen; i++) {
      final s = i < serverParts.length ? serverParts[i] : 0;
      final c = i < currentParts.length ? currentParts[i] : 0;
      if (s > c) return true;
      if (s < c) return false;
    }
    return false;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  void _toast(String message) {
    Get.snackbar(
      'System',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.lightPrimary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }
}
