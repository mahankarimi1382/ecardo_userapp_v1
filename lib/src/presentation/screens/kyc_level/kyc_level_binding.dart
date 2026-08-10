import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';

/// KycLevelBinding — ثبت KycLevelController برای صفحات navigation
class KycLevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycLevelController>(() => KycLevelController());
  }
}
