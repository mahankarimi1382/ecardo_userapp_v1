import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/services/connectivity_watch_service.dart';
import 'package:ecardo_user/src/common/services/session_timeout_service.dart';
import 'package:ecardo_user/src/common/services/session_manager.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TokenService>(TokenService());
    Get.put<SettingsService>(SettingsService());
    Get.put<SessionManager>(SessionManager());
    Get.put<NetworkService>(NetworkService());
    Get.putAsync<ConnectivityWatchService>(
      () async => ConnectivityWatchService().init(),
    );
    Get.putAsync<SessionTimeoutService>(
      () async => SessionTimeoutService().init(),
    );
  }
}
