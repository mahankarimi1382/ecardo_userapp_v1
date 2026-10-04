import 'package:get/get.dart';
import '../controllers/local_experience_controller.dart';

class LocalExperienceBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LocalExperienceController>(
      () => LocalExperienceController(),
      fenix: true,
    );
  }
}
