import 'dart:ui' show Color, PlatformDispatcher;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationChannels {
  static const String primaryId = 'ecardo_default';
  static const String financialId = 'ecardo_financial';
  static const String securityId = 'ecardo_security';
  static const String marketingId = 'ecardo_marketing';
  static const String legacyId = 'channel_id';

  static String get primaryName =>
      _pick(en: 'eCardo', fa: 'ای‌کاردو', ar: 'إيكاردو');
  static String get primaryDescription => _pick(
    en: 'eCardo account, transaction and update notifications',
    fa: 'اطلاعیه‌ها، تراکنش‌ها و به‌روزرسانی‌های ای‌کاردو',
    ar: 'إشعارات الحساب والمعاملات والتحديثات',
  );

  static String get financialName => _pick(
    en: 'Financial Transactions',
    fa: 'تراکنش‌های مالی',
    ar: 'المعاملات المالية',
  );
  static String get financialDescription => _pick(
    en: 'Deposits, withdrawals, transfers, and transaction alerts',
    fa: 'واریز، برداشت، انتقال و هشدارهای مالی',
    ar: 'الإيداع، السحب، التحويل والتنبيهات المالية',
  );

  static String get securityName =>
      _pick(en: 'Security Alerts', fa: 'هشدارهای امنیتی', ar: 'تنبيهات الأمان');
  static String get securityDescription => _pick(
    en: 'Account security, logins, and authentication alerts',
    fa: 'امنیت حساب، ورود دستگاه جدید و تغییر رمز عبور',
    ar: 'أمان الحساب، تسجيل الدخول وتغيير كلمة المرور',
  );

  static String get marketingName => _pick(
    en: 'Promotions & Deals',
    fa: 'پیشنهادها و تخفیف‌ها',
    ar: 'العروض الترويجية',
  );
  static String get marketingDescription => _pick(
    en: 'Promotions, deals, and product updates',
    fa: 'تخفیف‌ها، جشنواره‌ها و اخبار محصولات',
    ar: 'العروض الترويجية والصفقات وتحديثات المنتجات',
  );

  static String _pick({required String en, required String fa, String? ar}) {
    try {
      final lang =
          Get.locale?.languageCode ??
          PlatformDispatcher.instance.locale.languageCode;
      if (lang == 'fa') return fa;
      if (lang == 'ar' && ar != null) return ar;
    } catch (_) {}
    return en;
  }
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
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.primaryId,
        NotificationChannels.primaryName,
        description: NotificationChannels.primaryDescription,
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        ledColor: const Color(0xFFABC3EA),
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.securityId,
        NotificationChannels.securityName,
        description: NotificationChannels.securityDescription,
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        ledColor: const Color(0xFFE53935),
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.financialId,
        NotificationChannels.financialName,
        description: NotificationChannels.financialDescription,
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        ledColor: const Color(0xFF14AE6F),
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        NotificationChannels.marketingId,
        NotificationChannels.marketingName,
        description: NotificationChannels.marketingDescription,
        importance: Importance.defaultImportance,
        enableLights: false,
        enableVibration: false,
        playSound: true,
      ),
    );

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
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
    bool security = false,
    bool marketing = false,
    String? channelId,
  }) async {
    if (!_initialized) await init();

    String resolvedChannelId = NotificationChannels.primaryId;
    String resolvedChannelName = NotificationChannels.primaryName;
    String resolvedChannelDesc = NotificationChannels.primaryDescription;
    Importance resolvedImportance = Importance.high;
    Priority resolvedPriority = Priority.high;

    if (security || channelId == NotificationChannels.securityId) {
      resolvedChannelId = NotificationChannels.securityId;
      resolvedChannelName = NotificationChannels.securityName;
      resolvedChannelDesc = NotificationChannels.securityDescription;
      resolvedImportance = Importance.high;
      resolvedPriority = Priority.high;
    } else if (financial || channelId == NotificationChannels.financialId) {
      resolvedChannelId = NotificationChannels.financialId;
      resolvedChannelName = NotificationChannels.financialName;
      resolvedChannelDesc = NotificationChannels.financialDescription;
      resolvedImportance = Importance.high;
      resolvedPriority = Priority.high;
    } else if (marketing || channelId == NotificationChannels.marketingId) {
      resolvedChannelId = NotificationChannels.marketingId;
      resolvedChannelName = NotificationChannels.marketingName;
      resolvedChannelDesc = NotificationChannels.marketingDescription;
      resolvedImportance = Importance.defaultImportance;
      resolvedPriority = Priority.defaultPriority;
    }

    final androidDetails = AndroidNotificationDetails(
      resolvedChannelId,
      resolvedChannelName,
      channelDescription: resolvedChannelDesc,
      importance: resolvedImportance,
      priority: resolvedPriority,
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
