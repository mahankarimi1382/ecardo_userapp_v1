import 'package:get/get.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<TokenService>(TokenService());
    Get.put<SettingsService>(SettingsService());
    Get.put<NetworkService>(NetworkService());
  }
}
