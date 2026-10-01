import 'package:get/get.dart';
import '../controllers/stock_controller.dart';
import '../services/stock_service.dart';

/// Dedicated binding for the International Stock Trading module.
class StockBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StockService>()) {
      Get.lazyPut<StockService>(() => StockService(), fenix: true);
    }
    if (!Get.isRegistered<StockController>()) {
      Get.lazyPut<StockController>(() => StockController(), fenix: true);
    }
  }
}
