// ============================================================================
// notification_router_helper.dart
// ----------------------------------------------------------------------------
// NOTIF-FIX: background-isolate-safe notification helpers.
//
// `_firebaseMessagingBackgroundHandler` in main.dart runs in a SEPARATE Dart
// isolate with no live Flutter engine, no GetX, and no shared service
// instances — so it cannot use LocalNotificationsService.instance() (its
// `_tapHandler`/state live in the main isolate) or NotificationHistoryService
// (SharedPreferences IS accessible, but the badge/handler wiring is not).
// This helper exposes only the pieces that are safe to call from a
// background isolate: initializing the local-notifications plugin and
// showing a system-tray notification for data-only FCM messages, which the
// OS would otherwise silently drop.
// ============================================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:ecardo_user/src/common/services/local_notifications_service.dart';

class NotificationRouterHelper {
  NotificationRouterHelper._();

  static FlutterLocalNotificationsPlugin? _bgPlugin;
  static bool _bgInitialized = false;

  /// Show a data-only FCM message as a system-tray notification from the
  /// background isolate. Safe to call repeatedly; initializes the plugin
  /// lazily. The payload carries the full FCM data map (JSON) so tapping it
  /// once the app opens routes through the normal tap handler.
  static Future<void> showBackgroundNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    try {
      _bgPlugin ??= FlutterLocalNotificationsPlugin();

      if (!_bgInitialized) {
        const androidSettings = AndroidInitializationSettings(
          '@drawable/ic_notification',
        );
        const iosSettings = DarwinInitializationSettings();
        final ok = await _bgPlugin!.initialize(
          const InitializationSettings(android: androidSettings, iOS: iosSettings),
        );
        _bgInitialized = ok ?? false;
        if (!_bgInitialized) return;
      }

      final financial = type == 'transaction' ||
          type == 'transfer' ||
          type == 'deposit' ||
          type == 'withdraw' ||
          type == 'financial';

      final androidDetails = AndroidNotificationDetails(
        financial
            ? NotificationChannels.financialId
            : NotificationChannels.primaryId,
        financial
            ? NotificationChannels.financialName
            : NotificationChannels.primaryName,
        channelDescription: financial
            ? NotificationChannels.financialDescription
            : NotificationChannels.primaryDescription,
        importance: financial ? Importance.max : Importance.high,
        priority: financial ? Priority.max : Priority.high,
        icon: '@drawable/ic_notification',
        playSound: true,
        enableVibration: true,
      );
      const iosDetails = DarwinNotificationDetails(
        interruptionLevel: InterruptionLevel.active,
      );

      await _bgPlugin!.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 % 0x7FFFFFFF,
        title,
        body,
        NotificationDetails(android: androidDetails, iOS: iosDetails),
        payload: type,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('⚠️ showBackgroundNotification failed: $e');
      }
    }
  }
}
