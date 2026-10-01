import 'package:get/get.dart';
import '../controllers/visa_controller.dart';
import '../services/visa_service.dart';

/// Dedicated binding for the Visa service module.
class VisaBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<VisaService>()) {
      Get.lazyPut<VisaService>(() => VisaService(), fenix: true);
    }
    if (!Get.isRegistered<VisaController>()) {
      Get.lazyPut<VisaController>(() => VisaController(), fenix: true);
    }
  }
}
