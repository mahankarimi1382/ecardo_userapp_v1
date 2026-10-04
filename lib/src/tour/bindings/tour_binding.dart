import 'package:get/get.dart';
import '../controllers/tour_controller.dart';
import '../services/tour_service.dart';

class TourBinding implements Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<TourService>()) {
      Get.lazyPut<TourService>(() => TourService(), fenix: true);
    }
    Get.lazyPut<TourController>(() => TourController(), fenix: true);
  }
}
