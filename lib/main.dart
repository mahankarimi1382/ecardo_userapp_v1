import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/firebase_options.dart';
import 'package:ecardo_user/src/app/app.dart';
import 'package:ecardo_user/src/common/services/app_update_controller.dart';
import 'package:ecardo_user/src/common/services/firebase_messaging_service.dart';
import 'package:ecardo_user/src/common/services/local_notifications_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/services/wallet_live_rate_service.dart';
import 'package:ecardo_user/src/common/services/permission_flow_service.dart';
import 'package:ecardo_user/src/common/services/notification_history_service.dart';
import 'package:ecardo_user/src/common/services/app_badge_service.dart';
import 'package:ecardo_user/src/common/services/offline_request_queue.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  // phase1-fix (P0-14): only synchronous, local service registration before
  // the first frame. The notification permission dialog and FCM token
  // network calls move to post-first-frame so cold start can never hang.
  await _initializeServices();
  _configureUI();
  _installGlobalErrorHandlers();
  runApp(const EcardoUser());

  if (!kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePushServices();
    });
  }
}

/// v1.0.43 (NO-MORE-GRAY): an uncaught build exception used to render the
/// framework's blank GREY screen — the "frozen grey page" reported on the
/// home screen. From now on every widget-build error renders a graceful
/// card instead, and the real error still goes to the console for triage.
void _installGlobalErrorHandlers() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('❌ FlutterError: ${details.exception}');
  };
  ErrorWidget.builder = (details) {
    debugPrint('❌ Widget build error: ${details.exception}');
    return Material(
      color: const Color(0xFFF8F8F8),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFF7445FF),
                  size: 44,
                ),
                const SizedBox(height: 12),
                const Text(
                  'eCardo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF2D2D2D),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Something went wrong rendering this section.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  kDebugMode ? '${details.exception}' : ' ',
                  maxLines: kDebugMode ? 6 : 0,
                  overflow: TextOverflow.fade,
                  style: const TextStyle(fontSize: 10, color: Color(0xFF9E9E9E)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };
}

Future<void> _initializeServices() async {
  Get.put(SettingsService());
  // Register the in-app self-update controller for the user app.
  // Pass [AppUpdateConfig.merchant] / [AppUpdateConfig.agent] in the
  // respective merchant / agent apps.
  Get.put<AppUpdateController>(
    AppUpdateController(config: AppUpdateConfig.user),
    permanent: true,
  );
  Get.put<TokenService>(TokenService());
  Get.put(NetworkService());
  Get.put<PermissionFlowService>(PermissionFlowService(), permanent: true);
  Get.put<NotificationHistoryService>(NotificationHistoryService(), permanent: true);
  Get.put<AppBadgeService>(AppBadgeService(), permanent: true);
  Get.put<OfflineRequestQueue>(OfflineRequestQueue(), permanent: true);
  Future.microtask(() => Get.find<OfflineRequestQueue>().init());
  Future.microtask(() => Get.find<NotificationHistoryService>().init());
  Future.microtask(() => Get.find<AppBadgeService>().init());
  Get.put<WalletLiveRateService>(WalletLiveRateService(), permanent: true);
  // Fire-and-forget live FX seed for wallet cards (non-blocking).
  Future.microtask(() => Get.find<WalletLiveRateService>().refresh());
}

/// phase1-fix (P0-14): push/notification bootstrap moved after the first
/// frame — the permission dialog and FCM network calls no longer block
/// cold start (a push arriving in the first seconds is dropped; acceptable
/// trade-off vs an unresponsive first paint).
Future<void> _initializePushServices() async {
  try {
    final localNotificationsService = LocalNotificationsService.instance();
    await localNotificationsService.init();
    final firebaseMessagingService = FirebaseMessagingService.instance();
    await firebaseMessagingService.init(
      localNotificationsService: localNotificationsService,
    );
  } catch (e) {
    debugPrint('⚠️ _initializePushServices error: $e');
  }
}

void _configureUI() {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}
