import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/common/services/local_notifications_service.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;

  LocalNotificationsService? _localNotificationsService;

  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    _localNotificationsService = localNotificationsService;

    await _requestPermission();
    await _handlePushNotificationsToken();

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

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

  void _onForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification != null) {
      _localNotificationsService?.showNotification(
        notification.title,
        notification.body,
        message.data.toString(),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      print('Notification opened: ${message.data}');
    }
  }
}
