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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/local_notifications_service.dart';
import 'package:ecardo_user/src/common/services/notification_history_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';

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

  /// Cold-start buffer: getInitialMessage / early notification taps can fire
  /// before the first Navigator frame exists. Their payloads park here and
  /// are routed by [attachContext] once the root widget attaches a context.
  Map<String, dynamic>? _pendingNotificationData;
  bool _pendingUpdateOpen = false;

  AppLocalizations? get localizationOrNull {
    final ctx = _lastContext ?? Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    _localNotificationsService = localNotificationsService;

    // AUTH-BIO (A-2): route local-notification taps through the same
    // payload→route mapping used for FCM push taps.
    localNotificationsService.setNotificationTapHandler(
      _onLocalNotificationTap,
    );

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
  /// Also drains whatever notification routing was parked during cold start.
  void attachContext(BuildContext context) {
    _lastContext = context;
    _processPendingRoutes();
  }

  void _processPendingRoutes() {
    if (_pendingUpdateOpen) {
      _pendingUpdateOpen = false;
      _openUpdateScreen();
      return;
    }
    final pending = _pendingNotificationData;
    if (pending != null) {
      _pendingNotificationData = null;
      _routeFromNotificationData(pending);
    }
  }

  // ===========================================================================
  // Permission + token
  // ===========================================================================

  Future<void> _requestPermission() async {
    // AUTH-BIO (A-1): Android 13+ needs an explicit POST_NOTIFICATIONS
    // runtime request. permission_handler (already the app's standard for
    // storage/install permissions) is the single user-facing gate here:
    //   - already granted/limited → no prompt needed.
    //   - permanently denied      → no prompt possible anymore.
    //   - anything else           → one permission_handler prompt; FCM's own
    //     requestPermission prompt is then skipped so the user never faces
    //     two consecutive system dialogs.
    try {
      var status = await Permission.notification.status;
      if (!status.isGranted &&
          !status.isLimited &&
          !status.isPermanentlyDenied) {
        status = await Permission.notification.request();
      }
      if (kDebugMode) {
        print('Notification permission (permission_handler): $status');
      }
      if (status.isGranted || status.isLimited) {
        // Sync FCM AuthorizationStatus so topic messages are delivered.
        await FirebaseMessaging.instance.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        return;
      }

      // Not granted: report the FCM-side status WITHOUT prompting again.
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      if (kDebugMode) {
        print('Notification permission: ${settings.authorizationStatus}');
      }
      return;
    } catch (e) {
      if (kDebugMode) {
        print(
          'permission_handler notification gate failed ($e) — falling back '
          'to FCM requestPermission',
        );
      }
    }

    // Fallback (plugin failure only): original FCM prompt path.
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

      // AUTH-BIO (A-3): push the fresh token to the backend immediately when
      // a session exists, reusing the SAME getSetupFcm call the login flow
      // performs. When logged out, skip silently — registration happens at
      // the next login.
      try {
        final loginState = await SettingsService.getLoginCurrentState();
        if (loginState != null && loginState.isNotEmpty) {
          await registerTokenWithBackend();
        } else if (kDebugMode) {
          print(
            'FCM token refresh: not logged in — skipping backend registration',
          );
        }
      } catch (e) {
        if (kDebugMode) {
          print('FCM token refresh: backend registration skipped: $e');
        }
      }
    });
  }

  /// AUTH-BIO (A-3): backend registration of the current FCM token — the
  /// SAME endpoint and payload shape the login path uses (device_id,
  /// device_type, fcm_token → getSetupFcm). SignInController delegates here
  /// after login and onTokenRefresh calls it directly, so there is a single
  /// source of truth for the payload.
  Future<void> registerTokenWithBackend() async {
    try {
      final deviceInfoPlugin = DeviceInfoPlugin();
      final savedFcmToken = await SettingsService.getFcmToken();

      String deviceId = '';
      String deviceType = '';

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceId = androidInfo.id;
        deviceType = 'android';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? '';
        deviceType = 'ios';
      } else {
        deviceId = 'unknown';
        deviceType = 'unknown';
      }

      await Get.find<NetworkService>().post(
        endpoint: ApiPath.getSetupFcm,
        data: {
          'device_id': deviceId,
          'device_type': deviceType,
          'fcm_token': savedFcmToken,
        },
      );
    } catch (e, s) {
      // Silent by design: a failed re-registration must never disturb the
      // user; the next login re-registers anyway.
      debugPrint('❌ registerTokenWithBackend() error: $e');
      debugPrint('📍 StackTrace: $s');
    }
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

    // v1.1 (KYC-ACTION): a KYC decision (approve / reject / manual level
    // promotion — every path) must refresh the badge + levels so the
    // drawer badge, roadmap and feature gates reflect the new state
    // immediately, without waiting for the next screen visit.
    if (type == 'kyc_action') {
      _refreshKycState();
    }

    // Persist history + tray notification + in-app banner.
    _persistAndBanner(message);
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification opened: ${message.data}');
    }

    // app_update keeps its dedicated handling (unchanged behaviour).
    if (message.data['type'] == 'app_update') {
      _openUpdateScreen();
      return;
    }

    // AUTH-BIO (A-2): route every other payload through the shared router.
    _routeFromNotificationData(message.data);
  }

  /// v1.1 (KYC-ACTION): refresh badge + levels + status after a kyc_action
  /// push (foreground) or tap. Best-effort: when the controller is not
  /// registered (logged-out, cold start before navigation) it silently
  /// does nothing — the KYC screens refetch on their own onInit anyway.
  void _refreshKycState() {
    try {
      if (Get.isRegistered<KycLevelController>()) {
        unawaited(Get.find<KycLevelController>().fetchStatus());
      }
    } catch (e) {
      if (kDebugMode) print('kyc_action refresh failed: $e');
    }
  }

  // ===========================================================================
  // Notification tap routing (AUTH-BIO / A-2)
  // ===========================================================================

  /// Single entry point for taps on LOCAL notifications. The payload is JSON
  /// for FCM-originated notifications and the bare string 'app_update' for
  /// the update notification.
  void _onLocalNotificationTap(String? payload) {
    Map<String, dynamic> data = const {};

    if (payload != null && payload.isNotEmpty) {
      try {
        final decoded = jsonDecode(payload);
        if (decoded is Map<String, dynamic>) {
          data = decoded;
        } else {
          data = {'type': payload};
        }
      } catch (_) {
        // Not JSON (e.g. the plain 'app_update' payload or a legacy
        // `data.toString()` payload): treat the whole string as the type.
        data = {'type': payload};
      }
    }

    _routeFromNotificationData(data);
  }

  /// Maps notification `data` to an existing route. Unknown/missing payloads
  /// fall back to home — this function must never throw.
  Future<void> _routeFromNotificationData(Map<String, dynamic> data) async {
    try {
      final type = data['type']?.toString();

      if (type == 'app_update') {
        _openUpdateScreen();
        return;
      }

      // v1.1 (KYC-ACTION): tapping the KYC decision notification refreshes
      // badge/status first, then lands on the KYC history screen.
      if (type == 'kyc_action') {
        _refreshKycState();
      }

      final target = _routeForNotificationType(type);
      if (target == null) return;

      // Never deep-link into account screens without a session — the auth
      // flow owns navigation in that case.
      final loginState = await SettingsService.getLoginCurrentState();
      if (loginState == null || loginState.isEmpty) {
        if (kDebugMode) {
          print('Notification tap ignored (no session): type=$type');
        }
        return;
      }

      final ctx = _lastContext ?? Get.context;
      if (ctx == null) {
        // Cold start straight from a notification tap: init() processes
        // getInitialMessage before runApp() has built a navigator. Park the
        // payload — attachContext() routes it on the first frame.
        _pendingNotificationData = data;
        if (kDebugMode) {
          print('Notification routing deferred until navigator is ready: type=$type');
        }
        return;
      }

      // Home is the default fallback — avoid stacking a second navigation
      // shell when we are already there.
      if (target == BaseRoute.navigation && Get.currentRoute == target) return;

      // Task-12 — remittance pushes carry `remittance_uuid`; the details
      // screen reads its argument via Get.arguments, so route WITH the
      // uuid. Unknown/missing uuid still navigates (screen handles null).
      if (type == 'remittance_status_changed') {
        final uuid = data['remittance_uuid']?.toString();
        Get.toNamed(BaseRoute.remittanceDetails, arguments: (uuid == null || uuid.isEmpty) ? null : uuid);
        return;
      }

      Get.toNamed(target);
    } catch (e) {
      // Unknown payload shapes or a failing route must never crash the app.
      debugPrint('❌ _routeFromNotificationData() error: $e');
    }
  }

  /// Type→route vocabulary mirrors what the backend actually sends for
  /// in-app notifications (see NotificationDynamicIcon.getNotificationIcon,
  /// which renders the same `type` values in the notifications list).
  String? _routeForNotificationType(String? type) {
    switch (type) {
      case 'app_update':
        return BaseRoute.appUpdate; // handled above, kept for completeness

      // Transaction / money-movement events → transactions history.
      case 'user_manual_deposit_approved':
      case 'user_manual_deposit_rejected':
      case 'user_invoice_payment':
      case 'user_request_money':
      case 'user_request_money_accepted':
      case 'user_receive_money':
      case 'user_cash_in':
      case 'user_gift_redeemed':
      case 'user_referral_join':
      case 'withdraw_approved':
      case 'withdraw_rejected':
        return BaseRoute.transactions;

      // Support tickets → tickets list.
      case 'user_ticket_reply':
      case 'user_ticket_closed':
        return BaseRoute.supportTickets;

      // KYC decisions → KYC history.
      case 'kyc_action':
        return BaseRoute.kycHistory;

      // Task-12 — remittance status changes → remittance details (the
      // uuid is passed by the caller from data['remittance_uuid']).
      case 'remittance_status_changed':
        return BaseRoute.remittanceDetails;

      // Everything else (user_mail, email_verification, forgot_password,
      // unknown future types) → home.
      default:
        return BaseRoute.navigation;
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
  ///
  /// v1.1 (UPD-NOTES): the push may carry `notes` (or `changelog` /
  /// `whats_new`) describing WHAT changed in this version. The text is
  /// passed to the controller and rendered in BOTH the local notification
  /// and the update dialog — previously the notification was a hardcoded
  /// English one-liner with no change information at all.
  void _handleAppUpdateMessage(RemoteMessage message) async {
    final data = message.data;
    final version = data['version'] as String?;
    final force = (data['force'] as String?) == '1';
    final notes = (data['notes'] ?? data['changelog'] ?? data['whats_new'])
        ?.toString()
        .trim();

    // Feed the pushed metadata into the controller before any UI runs so
    // the dialog/notification read the same source of truth.
    if (Get.isRegistered<AppUpdateController>()) {
      Get.find<AppUpdateController>().setPushedUpdateNotes(
        version: version ?? '',
        notes: (notes == null || notes.isEmpty) ? null : notes,
      );
    }

    // Localized push copy. AUTH-BIO pattern: nullable localization with an
    // English fallback (this runs with no BuildContext available).
    final localization = localizationOrNull;
    final title = force
        ? (localization?.updateNotificationTitleForce ??
            'Required update available')
        : (localization?.updateNotificationTitle ?? 'New version available');
    final body = StringBuffer(
      version == null
          ? (localization?.updateNotificationBodyGeneric ??
              'A new version of eCardo is available. Tap to update.')
          : (localization?.updateNotificationBody(version) ??
              'eCardo v$version is available. Tap to update.'),
    );
    if (notes != null && notes.isNotEmpty) {
      body
        ..writeln()
        ..write(notes);
    }

    // Show a local notification so the user is alerted even if the app is
    // in the foreground but the screen is off / another app is on top.
    _localNotificationsService?.showNotification(
      title,
      body.toString(),
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

  /// Deep-links the user to the full-screen update flow when they tap the
  /// notification (foreground-tap, cold-start-from-tap, update dialog and
  /// the auto-prompt all land here). The screen runs its own check when the
  /// controller phase is still idle, so registration order never matters.
  void _openUpdateScreen() {
    final ctx = _lastContext ?? Get.context;
    if (ctx == null) {
      // Cold start: park it; attachContext() opens it on the first frame.
      _pendingUpdateOpen = true;
      if (kDebugMode) {
        print('Update screen deferred until navigator is ready');
      }
      return;
    }
    _pendingUpdateOpen = false;
    Get.toNamed(BaseRoute.appUpdate);
  }

  void _persistAndBanner(RemoteMessage message) {
    final title = message.notification?.title ??
        message.data['title']?.toString() ??
        'eCardo';
    final body = message.notification?.body ??
        message.data['body']?.toString() ??
        '';
    final type = message.data['type']?.toString() ?? 'general';
    final financial = type == 'transaction' ||
        type == 'transfer' ||
        type == 'deposit' ||
        type == 'withdraw' ||
        type == 'financial';
    final payload = message.data.isNotEmpty
        ? (message.data['route']?.toString() ??
            message.data['type']?.toString() ??
            '')
        : type;

    if (Get.isRegistered<NotificationHistoryService>()) {
      // ignore: unawaited_futures
      Get.find<NotificationHistoryService>().add(
        title: title,
        body: body,
        type: financial
            ? 'financial'
            : (type == 'app_update' ? 'update' : 'system'),
        payload: payload,
      );
    }

    _localNotificationsService?.showNotification(
      title,
      body,
      payload.isEmpty ? null : payload,
      financial: financial,
    );

    // In-app banner while foreground
    final ctx = _lastContext ?? Get.context;
    if (ctx != null) {
      final messenger = ScaffoldMessenger.maybeOf(ctx);
      messenger?.clearSnackBars();
      messenger?.showSnackBar(
        SnackBar(
          content: Text('$title\n$body', maxLines: 3),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'باز کردن',
            onPressed: () => _routeFromPayload(payload),
          ),
        ),
      );
    }
  }

  void _routeFromPayload(String? payload) {
    if (payload == null || payload.isEmpty) {
      Get.toNamed(BaseRoute.notifications);
      return;
    }
    if (payload == 'app_update') {
      _openUpdateScreen();
      return;
    }
    if (payload.contains('transaction') || payload.startsWith('/transaction')) {
      Get.toNamed(BaseRoute.transactions);
      return;
    }
    Get.toNamed(BaseRoute.notifications);
  }

}
