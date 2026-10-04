import 'package:get/get.dart';
import '../controllers/dining_controller.dart';

class DiningBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiningController>(
      () => DiningController(),
      fenix: true,
    );
  }
}
