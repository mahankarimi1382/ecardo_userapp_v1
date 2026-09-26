import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/connectivity_watch_service.dart';
import 'package:ecardo_user/src/common/services/session_manager.dart';
import 'package:ecardo_user/src/common/services/session_timeout_service.dart';

/// Session-layer services only (WAVE-1 wiring).
///
/// TokenService / NetworkService / SettingsService are already registered in
/// main.dart before runApp — re-putting them here would swap live instances
/// out from under controllers that captured references at startup, so they
/// deliberately stay out of this binding.
///
/// Effect of this binding going live:
/// - 401 → SessionManager single-flight logout + dialog (network_service
///   already calls it behind `Get.isRegistered<SessionManager>()`).
/// - VPN soft banner in app.dart becomes observable (isVpn).
/// - 30-min foreground idle timeout ends the session (owner request:
///   «خروج بعد ثانیه» — auto-logout on inactivity).
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<SessionManager>(SessionManager());
    Get.putAsync<ConnectivityWatchService>(
      () async => ConnectivityWatchService().init(),
    );
    Get.putAsync<SessionTimeoutService>(
      () async => SessionTimeoutService().init(),
    );
  }
}
