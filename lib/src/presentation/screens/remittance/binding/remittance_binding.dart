import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/remittance/controller/remittance_controller.dart';

/// Ensures [RemittanceController] exists for details / history deep-links.
class RemittanceBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RemittanceController>()) {
      Get.lazyPut<RemittanceController>(() => RemittanceController(), fenix: true);
    }
  }
}
