import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  LocalNotificationsService._internal();
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();
  factory LocalNotificationsService.instance() => _instance;

  late FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  int _id = 0;

  /// AUTH-BIO (A-2): single notification-tap router. FirebaseMessagingService
  /// registers itself here during its init() so every local-notification tap
  /// is routed through the same payload→route mapping as FCM push taps.
  void Function(String? payload)? _tapHandler;

  /// Registers (or clears with null) the tap handler invoked whenever the
  /// user taps a notification while the app is alive (foreground or
  /// background-but-running).
  void setNotificationTapHandler(void Function(String? payload)? handler) {
    _tapHandler = handler;
  }

  Future<void> init() async {
    if (_initialized) return;

    _plugin = FlutterLocalNotificationsPlugin();

    // v1.0.38: the status-bar small icon MUST be a white-on-transparent
    // monochrome asset — the previous setup pointed at the full-color
    // launcher icon, which Android renders as an anonymous grey square on
    // most devices.
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_notification',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // AUTH-BIO (A-2): previously no response callback was registered, so
    // tapping a local notification did nothing.
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    const channel = AndroidNotificationChannel(
      'ecardo_default',
      'eCardo',
      description: 'eCardo account & transaction notifications',
      importance: Importance.max,
      enableLights: true,
      enableVibration: true,
      ledColor: Color(0xFF7445FF),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);

    _initialized = true;
  }

  /// AUTH-BIO (A-2): forwards taps on regular notifications (not action
  /// buttons) to the registered router. Unknown payloads are handled
  /// gracefully by the router — it never throws.
  void _onNotificationResponse(NotificationResponse response) {
    // Only taps on the notification body route somewhere; action-button
    // responses have no payload contract in this app.
    if (response.notificationResponseType !=
        NotificationResponseType.selectedNotification) {
      return;
    }
    if (kDebugMode) {
      debugPrint('Local notification tapped: ${response.payload}');
    }
    _tapHandler?.call(response.payload);
  }

  Future<void> showNotification(
    String? title,
    String? body,
    String? payload,
  ) async {
    const androidDetails = AndroidNotificationDetails(
      'ecardo_default',
      'eCardo',
      channelDescription: 'eCardo account & transaction notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(_id++, title, body, details, payload: payload);
  }
}
