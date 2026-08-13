import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';

/// KycLevelBinding — ثبت KycLevelController برای صفحات navigation
///
/// v1.0.6: از Get.put استفاده می‌کنیم (نه lazyPut) تا controller
/// فورا ساخته شود و drawer بتواند به آن دسترسی داشته باشد.
class KycLevelBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<KycLevelController>(KycLevelController(), permanent: true);
  }
}
