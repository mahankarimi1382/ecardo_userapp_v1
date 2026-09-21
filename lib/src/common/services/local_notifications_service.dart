import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Single source of truth for Android notification channel IDs.
/// Must match `com.google.firebase.messaging.default_notification_channel_id`
/// in AndroidManifest.xml — a mismatch silently drops / deprioritizes pushes.
class NotificationChannels {
  static const String primaryId = 'ecardo_default';
  static const String primaryName = 'eCardo';
  static const String primaryDescription =
      'eCardo account, transaction and update notifications';

  /// Legacy id that older builds / the previous manifest used. We still
  /// create it so any in-flight FCM messages addressed to it still render
  /// at high importance.
  static const String legacyId = 'channel_id';
}

class LocalNotificationsService {
  LocalNotificationsService._internal();
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();
  factory LocalNotificationsService.instance() => _instance;

  late FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  int _id = 0;

  void Function(String? payload)? _tapHandler;

  void setNotificationTapHandler(void Function(String? payload)? handler) {
    _tapHandler = handler;
  }

  Future<void> init() async {
    if (_initialized) return;

    _plugin = FlutterLocalNotificationsPlugin();

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

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    // Primary channel (also the FCM default in the manifest).
    const primary = AndroidNotificationChannel(
      NotificationChannels.primaryId,
      NotificationChannels.primaryName,
      description: NotificationChannels.primaryDescription,
      importance: Importance.max,
      enableLights: true,
      enableVibration: true,
      ledColor: Color(0xFF7445FF),
      playSound: true,
    );

    // Legacy channel so messages already targeted at channel_id still show.
    const legacy = AndroidNotificationChannel(
      NotificationChannels.legacyId,
      NotificationChannels.primaryName,
      description: NotificationChannels.primaryDescription,
      importance: Importance.max,
      enableLights: true,
      enableVibration: true,
      ledColor: Color(0xFF7445FF),
      playSound: true,
    );

    await androidPlugin?.createNotificationChannel(primary);
    await androidPlugin?.createNotificationChannel(legacy);

    _initialized = true;
  }

  void _onNotificationResponse(NotificationResponse response) {
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
    if (!_initialized) {
      await init();
    }

    const androidDetails = AndroidNotificationDetails(
      NotificationChannels.primaryId,
      NotificationChannels.primaryName,
      channelDescription: NotificationChannels.primaryDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_notification',
      playSound: true,
      enableVibration: true,
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
