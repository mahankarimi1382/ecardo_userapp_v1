import 'package:get/get.dart';
import '../controller/license_controller.dart';
import '../service/license_service.dart';

/// Dedicated binding for the License Store module.
class LicenseBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LicenseService>()) {
      Get.lazyPut<LicenseService>(() => LicenseService(), fenix: true);
    }
    if (!Get.isRegistered<LicenseController>()) {
      Get.lazyPut<LicenseController>(() => LicenseController(), fenix: true);
    }
  }
}
