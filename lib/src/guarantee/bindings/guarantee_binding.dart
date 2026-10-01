import 'package:get/get.dart';
import '../controllers/guarantee_controller.dart';
import '../services/guarantee_service.dart';

/// Dedicated binding for the Bank Guarantee & LC module.
class GuaranteeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<GuaranteeApiService>()) {
      Get.lazyPut<GuaranteeApiService>(() => GuaranteeApiService(), fenix: true);
    }
    if (!Get.isRegistered<GuaranteeController>()) {
      Get.lazyPut<GuaranteeController>(() => GuaranteeController(), fenix: true);
    }
  }
}
