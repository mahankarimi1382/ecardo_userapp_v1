import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_ads/controller/my_ads_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/my_order/controller/my_order_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';

/// Central DI for the main P2P shell controllers (1.0.51).
/// Sub-screens may still call Get.put; fenix keeps these alive across tabs.
class P2pBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MyAdsController>()) {
      Get.lazyPut<MyAdsController>(() => MyAdsController(), fenix: true);
    }
    if (!Get.isRegistered<MyOrderController>()) {
      Get.lazyPut<MyOrderController>(() => MyOrderController(), fenix: true);
    }
    if (!Get.isRegistered<PaymentAccountController>()) {
      Get.lazyPut<PaymentAccountController>(
        () => PaymentAccountController(),
        fenix: true,
      );
    }
  }
}
