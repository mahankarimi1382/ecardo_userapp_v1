import 'package:get/get.dart';
import '../controllers/rental_controller.dart';
import '../services/rental_service.dart';

class RentalBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<RentalApiService>()) {
      Get.lazyPut<RentalApiService>(() => RentalApiService(), fenix: true);
    }
    Get.lazyPut<RentalController>(() => RentalController(), fenix: true);
  }
}
