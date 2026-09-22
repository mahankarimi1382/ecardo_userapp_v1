import 'dart:ui' show Color;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannels {
  static const String primaryId = 'ecardo_default';
  static const String primaryName = 'eCardo';
  static const String primaryDescription =
      'eCardo account, transaction and update notifications';

  static const String financialId = 'ecardo_financial';
  static const String financialName = 'تراکنش‌های مالی';
  static const String financialDescription =
      'واریز، برداشت، انتقال و هشدارهای مالی';

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

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.primaryId,
        NotificationChannels.primaryName,
        description: NotificationChannels.primaryDescription,
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        ledColor: Color(0xFF7445FF),
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.financialId,
        NotificationChannels.financialName,
        description: NotificationChannels.financialDescription,
        importance: Importance.max,
        enableLights: true,
        enableVibration: true,
        ledColor: Color(0xFF14AE6F),
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        NotificationChannels.legacyId,
        NotificationChannels.primaryName,
        description: NotificationChannels.primaryDescription,
        importance: Importance.high,
        playSound: true,
      ),
    );

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
    String? payload, {
    bool financial = false,
  }) async {
    if (!_initialized) await init();

    final channelId = financial
        ? NotificationChannels.financialId
        : NotificationChannels.primaryId;
    final channelName = financial
        ? NotificationChannels.financialName
        : NotificationChannels.primaryName;
    final channelDesc = financial
        ? NotificationChannels.financialDescription
        : NotificationChannels.primaryDescription;

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: financial ? Importance.max : Importance.high,
      priority: financial ? Priority.max : Priority.high,
      icon: '@drawable/ic_notification',
      playSound: true,
      enableVibration: true,
      number: 1,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _plugin.show(
      _id++,
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }
}
