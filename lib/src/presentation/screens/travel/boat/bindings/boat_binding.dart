import 'package:get/get.dart';
import '../controllers/boat_controller.dart';

class BoatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BoatController>(
      () => BoatController(),
      fenix: true,
    );
  }
}
