import 'package:get/get.dart';
import '../controllers/escrow_controller.dart';

class EscrowBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EscrowController>(
      () => EscrowController(),
      fenix: true,
    );
  }
}
