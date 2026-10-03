// ============================================================================
// AppUpdateController
// ----------------------------------------------------------------------------
// Full state-managed controller for the in-app self-update flow.
//
// Responsibilities:
//   1. Fetch the latest version metadata from /api/app-version (primary)
//      with fallback to backend SettingsService.
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

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';
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

  /// Optional APK sha256 hex from backend (`app_apk_sha256`). When non-empty,
  /// the downloaded file is verified before handing off to the installer.
  final String settingKeySha256;

  /// Dedicated app-version endpoint URL (default /api/app-version).
  final String appVersionEndpoint;

  const AppUpdateConfig({
    required this.autoUpdatePrefsKey,
    required this.lastPromptedVersionPrefsKey,
    required this.apkFileName,
    required this.settingKeyVersion,
    required this.settingKeyUpdateLink,
    required this.settingKeyForceUpdate,
    this.settingKeySha256 = 'app_apk_sha256',
    this.appVersionEndpoint = 'https://ecardo.ir/api/app-version',
  });

  /// Default configuration for the eCardo **user** app.
  static const AppUpdateConfig user = AppUpdateConfig(
    autoUpdatePrefsKey: 'auto_update_enabled_user',
    lastPromptedVersionPrefsKey: 'last_prompted_version_user',
    apkFileName: 'ecardo_user_update.apk',
    settingKeyVersion: 'app_version',
    settingKeyUpdateLink: 'app_update_link',
    settingKeyForceUpdate: 'app_force_update',
    appVersionEndpoint: 'https://ecardo.ir/api/app-version',
  );

  /// Configuration for the eCardo **merchant** app.
  static const AppUpdateConfig merchant = AppUpdateConfig(
    autoUpdatePrefsKey: 'auto_update_enabled_merchant',
    lastPromptedVersionPrefsKey: 'last_prompted_version_merchant',
    apkFileName: 'ecardo_merchant_update.apk',
    settingKeyVersion: 'app_version',
    settingKeyUpdateLink: 'app_update_link',
    settingKeyForceUpdate: 'app_force_update',
    appVersionEndpoint: 'https://ecardo.ir/api/app-version',
  );

  /// Configuration for the eCardo **agent** app.
  static const AppUpdateConfig agent = AppUpdateConfig(
    autoUpdatePrefsKey: 'auto_update_enabled_agent',
    lastPromptedVersionPrefsKey: 'last_prompted_version_agent',
    apkFileName: 'ecardo_agent_update.apk',
    settingKeyVersion: 'app_version',
    settingKeyUpdateLink: 'app_update_link',
    settingKeyForceUpdate: 'app_force_update',
    appVersionEndpoint: 'https://ecardo.ir/api/app-version',
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
  final RxString updateUrl = ''.obs;
  final RxString serverSha256 = ''.obs;
  final RxBool forceUpdate = false.obs;
  final RxBool autoUpdateEnabled = true.obs;
  final RxString errorMessage = ''.obs;
  final Rx<DateTime?> lastCheckedAt = Rx<DateTime?>(null);

  /// v1.1 (UPD-NOTES): release notes / what's-new text for the pending
  /// version. Populated from (in priority order):
  ///   1. the `notes` (or `changelog`/`whats_new`) field of the FCM
  ///      `app_update` data message,
  ///   2. the `app_update_notes` settings key pushed by the backend,
  ///   3. empty — the UI then shows a localized generic
  ///      "bug fixes & improvements" line.
  final RxString latestNotes = ''.obs;

  // ----- Internal -----
  CancelToken? _cancelToken;

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

  /// Helper to fetch metadata directly from /api/app-version.
  Future<Map<String, dynamic>?> _fetchAppVersionApi() async {
    try {
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 12),
          receiveTimeout: const Duration(seconds: 12),
          headers: const {'Accept': 'application/json'},
          validateStatus: (s) => s != null && s >= 200 && s < 400,
        ),
      );
      final resp = await dio.get(config.appVersionEndpoint);
      if (resp.statusCode == 200 && resp.data is Map) {
        final data = resp.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        } else if (data is Map) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (e) {
      debugPrint('Failed to query /api/app-version: $e');
    }
    return null;
  }

  /// Returns true if the server has a newer version than the running app.
  Future<bool> isNewVersionAvailable() async {
    String server = '';
    String link = '';

    final apiData = await _fetchAppVersionApi();
    if (apiData != null) {
      server = (apiData['version'] ?? '').toString().trim();
      link = (apiData['update_url'] ?? '').toString().trim();
      if (apiData['sha256'] != null) {
        serverSha256.value = apiData['sha256'].toString().trim();
      }
    }

    if (server.isEmpty || link.isEmpty) {
      final settings = Get.find<SettingsService>();
      server = settings.getSetting(config.settingKeyVersion) ?? '';
      link = settings.getSetting(config.settingKeyUpdateLink) ?? '';
    }

    if (server.isEmpty || link.isEmpty) return false;

    updateUrl.value = link;
    serverVersion.value = server;

    final info = await PackageInfo.fromPlatform();
    return _isVersionNewer(server, info.version);
  }

  /// v1.1 (UPD-NOTES): called by FirebaseMessagingService when an
  /// `app_update` data message arrives.
  void setPushedUpdateNotes({required String version, String? notes}) {
    if (version.isNotEmpty) serverVersion.value = version;
    latestNotes.value = (notes ?? '').trim();
  }

  /// v1.1 (UPD-NOTES): resolves the best available release-notes text.
  String resolveNotes(String version) {
    if (latestNotes.value.isNotEmpty) return latestNotes.value;
    try {
      final settings = Get.find<SettingsService>();
      return (settings.getSetting('app_update_notes') ?? '').trim();
    } catch (_) {
      return '';
    }
  }

  /// Manual check triggered by the user from the settings screen.
  Future<void> checkForUpdate({
    bool showSnackbarWhenUpToDate = true,
  }) async {
    if (phase.value == AppUpdatePhase.checking ||
        phase.value == AppUpdatePhase.downloading) {
      return; // Already busy.
    }

    final localization = localizationOrNull;
    phase.value = AppUpdatePhase.checking;
    errorMessage.value = '';
    lastCheckedAt.value = DateTime.now();

    try {
      String server = '';
      String link = '';
      bool force = false;
      String expectedSha = '';

      // 1. Primary: dedicated /api/app-version endpoint
      final apiData = await _fetchAppVersionApi();
      if (apiData != null) {
        server = (apiData['version'] ?? '').toString().trim();
        link = (apiData['update_url'] ?? '').toString().trim();
        force = apiData['force_update'] == true ||
            apiData['force_update'] == 1 ||
            apiData['force_update'] == '1';
        expectedSha = (apiData['sha256'] ?? '').toString().trim();
      }

      // 2. Fallback: general settings service
      if (server.isEmpty || link.isEmpty) {
        final settings = Get.find<SettingsService>();
        await settings.fetchSettings();
        server = (settings.getSetting(config.settingKeyVersion) ?? '').trim();
        link = (settings.getSetting(config.settingKeyUpdateLink) ?? '').trim();
        force = settings.getSetting(config.settingKeyForceUpdate) == '1';
        expectedSha = (settings.getSetting(config.settingKeySha256) ?? '').trim();
      }

      serverVersion.value = server;
      forceUpdate.value = force;
      updateUrl.value = link;
      serverSha256.value = expectedSha;

      if (server.isEmpty || link.isEmpty) {
        phase.value = AppUpdatePhase.upToDate;
        if (showSnackbarWhenUpToDate) {
          _toast(
            localization?.updateUpToDate ?? 'You are on the latest version.',
          );
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
          _toast(
            localization?.updateUpToDateWithVersion(info.version) ??
                'App is up to date (${info.version})',
          );
        }
      }
    } catch (e) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value = 'Could not check for updates: $e';
    }
  }

  /// Starts the download → install flow.
  Future<void> startDownloadAndInstall() async {
    if (phase.value == AppUpdatePhase.downloading) return;

    String url = updateUrl.value.trim();
    if (url.isEmpty) {
      final settings = Get.find<SettingsService>();
      url = (settings.getSetting(config.settingKeyUpdateLink) ?? '').trim();
    }
    if (url.isEmpty) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value = 'Download URL is not configured.';
      return;
    }

    // ----- Permissions (Install unknown apps) -----
    final granted = await _ensureInstallPermission();
    if (!granted) {
      phase.value = AppUpdatePhase.error;
      errorMessage.value =
          'Install permission is required to update the application.';
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

      _cancelToken = CancelToken();
      final dio = Dio(
        BaseOptions(
          connectTimeout: const Duration(seconds: 45),
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(seconds: 45),
          followRedirects: true,
          maxRedirects: 8,
          headers: const {
            'Accept': '*/*',
            'User-Agent':
                'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 '
                '(KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 '
                'eCardoUserApp/1.0',
          },
          validateStatus: (s) => s != null && s >= 200 && s < 400,
        ),
      );

      // Attempt primary download; on failure, fall back to domestic mirror
      try {
        await dio.download(
          url,
          filePath,
          cancelToken: _cancelToken,
          deleteOnError: true,
          onReceiveProgress: (received, total) {
            if (total <= 0) return;
            final percent = (received / total * 100).clamp(0, 100).toInt();
            progressPercent.value = percent;
            downloadedBytesLabel.value = _formatBytes(received);
            totalBytesLabel.value = _formatBytes(total);
          },
        );
      } catch (primaryError) {
        const domesticMirror = 'https://ecardo.ir/apk/user/user-release.apk';
        if (url != domesticMirror && _cancelToken?.isCancelled != true) {
          debugPrint('Primary download failed ($primaryError), falling back to mirror: $domesticMirror');
          progressPercent.value = 0;
          await dio.download(
            domesticMirror,
            filePath,
            cancelToken: _cancelToken,
            deleteOnError: true,
            onReceiveProgress: (received, total) {
              if (total <= 0) return;
              final percent = (received / total * 100).clamp(0, 100).toInt();
              progressPercent.value = percent;
              downloadedBytesLabel.value = _formatBytes(received);
              totalBytesLabel.value = _formatBytes(total);
            },
          );
        } else {
          rethrow;
        }
      }

      // ----- Integrity check -----
      // SECURITY: this used to be skipped entirely whenever the server had
      // published no digest, which is exactly the case an attacker controls
      // (a stripped or hijacked /api/settings response). An unverified APK is
      // then handed to the package installer, so a wrong digest now fails
      // closed instead of installing whatever was downloaded.
      final expectedSha = (serverSha256.value.isNotEmpty
              ? serverSha256.value
              : (Get.find<SettingsService>().getSetting(config.settingKeySha256) ?? ''))
          .trim()
          .toLowerCase();

      if (expectedSha.isEmpty) {
        phase.value = AppUpdatePhase.error;
        errorMessage.value =
            'Update is missing a security checksum. Please try again later.';
        return;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        phase.value = AppUpdatePhase.error;
        errorMessage.value = 'Downloaded update file is missing.';
        return;
      }
      final digest = await sha256.bind(file.openRead()).first;
      final actual = digest.toString().toLowerCase();
      if (actual != expectedSha) {
        try {
          await file.delete();
        } catch (_) {}
        phase.value = AppUpdatePhase.error;
        errorMessage.value = 'Update file integrity check failed. Please try again.';
        return;
      }

      // ----- Hand off to system installer with explicit APK MIME type -----
      phase.value = AppUpdatePhase.installing;
      final result = await OpenFilex.open(
        filePath,
        type: 'application/vnd.android.package-archive',
      );
      if (result.type != ResultType.done) {
        phase.value = AppUpdatePhase.error;
        errorMessage.value = 'Failed to open APK: ${result.message}';
        return;
      }
    } on DioException catch (e) {
      phase.value = AppUpdatePhase.error;
      final code = e.response?.statusCode;
      final type = e.type.name;
      if (e.type == DioExceptionType.cancel) {
        errorMessage.value = 'Download cancelled.';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        errorMessage.value =
            'Download timed out. Check your connection and try again.';
      } else if (code == 404) {
        errorMessage.value =
            'Update file not found (404). The release link may be wrong.';
      } else if (code == 403 || code == 401) {
        errorMessage.value =
            'Download blocked (auth). Use the public release URL.';
      } else {
        errorMessage.value =
            'Download failed (${code ?? type}). ${e.message ?? ''}'.trim();
      }
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

  /// Resets the controller to its idle state.
  void reset() {
    phase.value = AppUpdatePhase.idle;
    progressPercent.value = 0;
    downloadedBytesLabel.value = '';
    totalBytesLabel.value = '';
    errorMessage.value = '';
  }

  /// Records that the user has been prompted about [version].
  Future<void> markVersionAsPrompted(String version) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(config.lastPromptedVersionPrefsKey, version);
  }

  /// Returns true if the controller should auto-prompt about [version].
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

  /// Requests the install permission on Android 8.0+.
  /// Note: Storage permission is NOT required on Android to download into
  /// getApplicationDocumentsDirectory(), and requesting it on Android 13+
  /// fails because READ/WRITE_EXTERNAL_STORAGE are deprecated.
  Future<bool> _ensureInstallPermission() async {
    if (Platform.isAndroid) {
      try {
        final status = await Permission.requestInstallPackages.status;
        if (!status.isGranted) {
          await Permission.requestInstallPackages.request();
        }
      } catch (e) {
        debugPrint('Install packages permission check: $e');
      }
    }
    return true;
  }

  /// Returns true if [server] is strictly newer than [current] using
  /// semver-style numeric comparison.
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
    final localization = localizationOrNull;
    Get.snackbar(
      localization?.updateSystemTitle ?? 'System',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.lightPrimary,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  AppLocalizations? get localizationOrNull {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }
}
