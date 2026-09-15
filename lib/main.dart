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
  runApp(const EcardoUser());

  if (!kIsWeb) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePushServices();
    });
  }
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
