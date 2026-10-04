import 'package:get/get.dart';
import '../controllers/commercial_controller.dart';

class CommercialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommercialController>(
      () => CommercialController(),
      fenix: true,
    );
  }
}
