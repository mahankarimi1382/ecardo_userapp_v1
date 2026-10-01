import 'package:get/get.dart';
import '../controllers/loan_controller.dart';
import '../services/loan_service.dart';

/// Dedicated binding for the Loan & Credit module.
class LoanBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<LoanApiService>()) {
      Get.lazyPut<LoanApiService>(() => LoanApiService(), fenix: true);
    }
    if (!Get.isRegistered<LoanController>()) {
      Get.lazyPut<LoanController>(() => LoanController(), fenix: true);
    }
  }
}
