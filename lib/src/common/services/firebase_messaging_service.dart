// ============================================================================
// firebase_messaging_service.dart
// ----------------------------------------------------------------------------
// FCM integration with three responsibilities:
//   1. Persist the device token (for server-side targeted push).
//   2. Subscribe to a global topic so the admin can broadcast an
//      "app update available" notification to every device without having
//      to keep a token registry in sync.
//   3. Route incoming "app_update" data messages to the in-app update UI.
//
// Topic convention:
//   - User app    → `app_updates_user`
//   - Merchant app → `app_updates_merchant`
//   - Agent app    → `app_updates_agent`
// The backend should publish an FCM data message to the relevant topic
// when the admin publishes a new version, with the following payload:
//
//   {
//     "data": {
//       "type": "app_update",
//       "version": "1.0.8",
//       "force": "0",            // "1" forces the update
//       "url": "https://ecardo.ir/storage/apks/user/...apk"
//     },
//     "android": { "priority": "high" }
//   }
//
// The backend should ALSO keep the `app_version`, `app_update_link` and
// `app_force_update` settings rows in sync — the data message is just the
// "ping" that wakes the client up; the client then re-fetches settings
// to get the canonical values.
// ============================================================================

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/local_notifications_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// The FCM topic this app instance subscribes to for app-update broadcasts.
/// Override via the constructor when reusing this service in the merchant
/// or agent apps.
class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  /// Allows the merchant / agent apps to override the topic name before
  /// calling [init]. The user app uses the default `app_updates_user`.
  static void configure({required String updateTopic}) {
    _instance._updateTopic = updateTopic;
  }

  String _updateTopic = 'app_updates_user';
  String get updateTopic => _updateTopic;

  LocalNotificationsService? _localNotificationsService;
  BuildContext? _lastContext;

  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    _localNotificationsService = localNotificationsService;

    await _requestPermission();
    await _handlePushNotificationsToken();
    await _subscribeToUpdateTopic();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  /// Optional: called by the root widget whenever the Navigator is rebuilt
  /// so that we always have a usable context to show dialogs against.
  void attachContext(BuildContext context) {
    _lastContext = context;
  }

  // ===========================================================================
  // Permission + token
  // ===========================================================================

  Future<void> _requestPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('Notification permission: ${settings.authorizationStatus}');
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    final token = await FirebaseMessaging.instance.getToken();

    if (token != null) {
      await Get.find<SettingsService>().saveFcmToken(token);
      if (kDebugMode) print('FCM Token: $token');
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await Get.find<SettingsService>().saveFcmToken(newToken);
      if (kDebugMode) print('FCM Token refreshed: $newToken');
    });
  }

  // ===========================================================================
  // Update topic subscription
  // ===========================================================================

  Future<void> _subscribeToUpdateTopic() async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(_updateTopic);
      if (kDebugMode) {
        print('Subscribed to FCM topic: $_updateTopic');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to subscribe to topic $_updateTopic: $e');
      }
    }
  }

  // ===========================================================================
  // Incoming message handlers
  // ===========================================================================

  void _onForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final type = data['type'];

    if (type == 'app_update') {
      _handleAppUpdateMessage(message);
      return;
    }

    // Default: show as local notification
    final notification = message.notification;
    if (notification != null) {
      _localNotificationsService?.showNotification(
        notification.title,
        notification.body,
        data.toString(),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification opened: ${message.data}');
    }

    final type = message.data['type'];
    if (type == 'app_update') {
      _openUpdateScreen();
    }
  }

  // ===========================================================================
  // App-update message handling
  // ===========================================================================

  /// Called when an `app_update` data message arrives while the app is in
  /// the foreground. We:
  ///   1. Re-fetch settings so the controller sees the canonical values.
  ///   2. Trigger the update controller's check flow.
  ///   3. Show a high-priority local notification (so the user notices even
  ///      if they're not currently looking at the app).
  void _handleAppUpdateMessage(RemoteMessage message) async {
    final version = message.data['version'] as String?;
    final force = (message.data['force'] as String?) == '1';

    // Show a local notification so the user is alerted even if the app is
    // in the foreground but the screen is off / another app is on top.
    _localNotificationsService?.showNotification(
      force ? 'Required update available' : 'New version available',
      version == null
          ? 'A new version of eCardo is available. Tap to update.'
          : 'eCardo v$version is available. Tap to update.',
      'app_update',
    );

    // Refresh settings so the controller reads the canonical version + URL.
    try {
      await Get.find<SettingsService>().fetchSettings();
    } catch (e) {
      if (kDebugMode) print('Failed to refresh settings: $e');
    }

    // Trigger the controller — this will transition to updateAvailable and
    // the auto-prompt logic will show the dialog (or, in force mode, the
    // non-dismissable dialog).
    if (Get.isRegistered<AppUpdateController>()) {
      final controller = Get.find<AppUpdateController>();
      await controller.checkForUpdate(showSnackbarWhenUpToDate: false);
    }
  }

  /// Deep-links the user to the update screen when they tap the
  /// notification (used for both foreground-tap and cold-start-from-tap).
  void _openUpdateScreen() {
    final ctx = _lastContext ?? Get.context;
    if (ctx == null) {
      if (kDebugMode) {
        print('Cannot open update screen — no context attached');
      }
      return;
    }
    if (!Get.isRegistered<AppUpdateController>()) return;
    Get.toNamed('/app_update_route');
  }
}
