import 'dart:async';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import '../model/license_models.dart';

class LicenseController extends GetxController {
  final NetworkService _networkService = Get.find<NetworkService>();

  final RxList<LicenseProductItem> products = <LicenseProductItem>[].obs;
  final RxBool isLoadingCatalog = false.obs;
  final RxString selectedCategory = 'all'.obs;

  final Rx<LicenseProductItem?> currentProduct = Rx<LicenseProductItem?>(null);
  final RxBool isLoadingProduct = false.obs;

  final Rx<LicenseOrderItem?> currentOrder = Rx<LicenseOrderItem?>(null);
  final RxBool isCreatingOrder = false.obs;
  final RxBool isPaying = false.obs;

  final RxList<LicenseKeyItem> myLicenses = <LicenseKeyItem>[].obs;
  final RxBool isLoadingMyLicenses = false.obs;

  final RxList<LicenseOrderItem> myOrders = <LicenseOrderItem>[].obs;
  final RxBool isLoadingMyOrders = false.obs;

  final RxInt remainingSeconds = 0.obs;
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  void startCountdown(int seconds) {
    _timer?.cancel();
    remainingSeconds.value = seconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        t.cancel();
      }
    });
  }

  Future<void> fetchCatalog({String? category, String? search}) async {
    try {
      isLoadingCatalog.value = true;
      String ep = '/user/licenses/catalog';
      final qp = <String>[];
      if (category != null && category != 'all') qp.add('category=$category');
      if (search != null && search.isNotEmpty) qp.add('search=${Uri.encodeComponent(search)}');
      if (qp.isNotEmpty) ep += '?${qp.join('&')}';

      final ApiResponse<Map<String, dynamic>> res = await _networkService.get(
        endpoint: ep,
      );

      if (res.status == Status.completed && res.data != null) {
        final list = res.data!['data']?['products'] as List? ?? [];
        products.value = list.map((item) => LicenseProductItem.fromJson(item)).toList();
      }
    } catch (e) {
      ToastHelper().showErrorToast(l10nPickAuto(
        en: 'Failed to load license catalog.',
        fa: 'خطا در بارگذاری کاتالوگ لایسنس‌ها.',
      ));
    } finally {
      isLoadingCatalog.value = false;
    }
  }

  Future<LicenseProductItem?> fetchProduct(String slug) async {
    try {
      isLoadingProduct.value = true;
      final ApiResponse<Map<String, dynamic>> res = await _networkService.get(
        endpoint: '/user/licenses/catalog/$slug',
      );

      if (res.status == Status.completed && res.data != null) {
        final data = res.data!['data'];
        if (data != null) {
          final prod = LicenseProductItem.fromJson(data);
          currentProduct.value = prod;
          return prod;
        }
      }
    } catch (_) {
    } finally {
      isLoadingProduct.value = false;
    }
    return null;
  }

  Future<LicenseOrderItem?> createOrder({
    required int productId,
    required String edition,
    required int durationMonths,
    String payRoute = 'CRYPTO_WALLET',
    String payCurrency = 'USD',
  }) async {
    try {
      isCreatingOrder.value = true;
      final ApiResponse<Map<String, dynamic>> res = await _networkService.post(
        endpoint: '/user/licenses/orders',
        data: {
          'product_id': productId,
          'edition': edition,
          'duration_months': durationMonths,
          'pay_route': payRoute,
          'pay_currency': payCurrency,
        },
      );

      if (res.status == Status.completed && res.data != null) {
        final orderData = res.data!['data'];
        final order = LicenseOrderItem.fromJson(orderData);
        currentOrder.value = order;
        startCountdown(order.priceLockRemainingSeconds > 0 ? order.priceLockRemainingSeconds : 900);
        return order;
      } else {
        ToastHelper().showErrorToast(res.message ?? l10nPickAuto(
          en: 'Failed to create order.',
          fa: 'خطا در ایجاد سفارش.',
        ));
      }
    } catch (e) {
      ToastHelper().showErrorToast(l10nPickAuto(
        en: 'Error creating license order.',
        fa: 'خطا در ایجاد سفارش لایسنس.',
      ));
    } finally {
      isCreatingOrder.value = false;
    }
    return null;
  }

  Future<bool> payWallet(int orderId, {int? walletId}) async {
    try {
      isPaying.value = true;
      final body = <String, dynamic>{};
      if (walletId != null) body['wallet_id'] = walletId;

      final ApiResponse<Map<String, dynamic>> res = await _networkService.post(
        endpoint: '/user/licenses/orders/$orderId/pay-wallet',
        data: body,
      );

      if (res.status == Status.completed && res.data != null) {
        final order = LicenseOrderItem.fromJson(res.data!['data']);
        currentOrder.value = order;
        _timer?.cancel();
        ToastHelper().showSuccessToast(l10nPickAuto(
          en: 'Payment successful! License key delivered.',
          fa: 'پرداخت موفقیت‌آمیز بود! کلید لایسنس تحویل داده شد.',
        ));
        return true;
      } else {
        ToastHelper().showErrorToast(res.message ?? l10nPickAuto(
          en: 'Wallet payment failed.',
          fa: 'پرداخت از کیف پول با خطا مواجه شد.',
        ));
      }
    } catch (e) {
      ToastHelper().showErrorToast(l10nPickAuto(
        en: 'Payment processing error.',
        fa: 'خطا در پردازش پرداخت.',
      ));
    } finally {
      isPaying.value = false;
    }
    return false;
  }

  Future<bool> payCrypto(int orderId, {String network = 'TRC20'}) async {
    try {
      isPaying.value = true;
      final ApiResponse<Map<String, dynamic>> res = await _networkService.post(
        endpoint: '/user/licenses/orders/$orderId/pay-crypto',
        data: {'network': network},
      );

      if (res.status == Status.completed && res.data != null) {
        final order = LicenseOrderItem.fromJson(res.data!['data']?['order']);
        currentOrder.value = order;
        return true;
      }
    } catch (_) {
    } finally {
      isPaying.value = false;
    }
    return false;
  }

  Future<bool> confirmActivation(int orderId) async {
    try {
      final ApiResponse<Map<String, dynamic>> res = await _networkService.post(
        endpoint: '/user/licenses/orders/$orderId/confirm-activation',
        data: {},
      );

      if (res.status == Status.completed && res.data != null) {
        currentOrder.value = LicenseOrderItem.fromJson(res.data!['data']);
        ToastHelper().showSuccessToast(l10nPickAuto(
          en: 'Activation confirmed!',
          fa: 'فعال‌سازی با موفقیت تأیید شد!',
        ));
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<void> fetchMyLicenses() async {
    try {
      isLoadingMyLicenses.value = true;
      final ApiResponse<Map<String, dynamic>> res = await _networkService.get(
        endpoint: '/user/licenses/my-licenses',
      );

      if (res.status == Status.completed && res.data != null) {
        final list = res.data!['data']?['licenses'] as List? ?? [];
        myLicenses.value = list.map((item) => LicenseKeyItem.fromJson(item)).toList();
      }
    } catch (_) {
    } finally {
      isLoadingMyLicenses.value = false;
    }
  }

  Future<void> fetchMyOrders() async {
    try {
      isLoadingMyOrders.value = true;
      final ApiResponse<Map<String, dynamic>> res = await _networkService.get(
        endpoint: '/user/licenses/my-orders',
      );

      if (res.status == Status.completed && res.data != null) {
        final list = res.data!['data']?['orders'] as List? ?? [];
        myOrders.value = list.map((item) => LicenseOrderItem.fromJson(item)).toList();
      }
    } catch (_) {
    } finally {
      isLoadingMyOrders.value = false;
    }
  }

  Future<bool> cancelOrder(int orderId, {String? reason}) async {
    try {
      final ApiResponse<Map<String, dynamic>> res = await _networkService.post(
        endpoint: '/user/licenses/orders/$orderId/cancel',
        data: {'reason': reason ?? 'Cancelled by user'},
      );

      if (res.status == Status.completed) {
        _timer?.cancel();
        ToastHelper().showSuccessToast(l10nPickAuto(
          en: 'Order cancelled.',
          fa: 'سفارش لغو شد.',
        ));
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> submitDispute(int orderId, String reasonType, String description, {String? screenshot}) async {
    try {
      final ApiResponse<Map<String, dynamic>> res = await _networkService.post(
        endpoint: '/user/licenses/orders/$orderId/dispute',
        data: {
          'reason_type': reasonType,
          'description': description,
          'evidence_screenshot': screenshot,
        },
      );

      if (res.status == Status.completed) {
        ToastHelper().showSuccessToast(l10nPickAuto(
          en: 'Dispute submitted. Support will review within 48 hours.',
          fa: 'گزارش اختلاف ثبت شد. پشتیبانی ظرف ۴۸ ساعت بررسی خواهد کرد.',
        ));
        return true;
      } else {
        ToastHelper().showErrorToast(res.message ?? l10nPickAuto(
          en: 'Failed to submit dispute.',
          fa: 'خطا در ثبت اختلاف.',
        ));
      }
    } catch (_) {
      ToastHelper().showErrorToast(l10nPickAuto(
        en: 'Error reporting issue.',
        fa: 'خطا در ارسال گزارش.',
      ));
    }
    return false;
  }

  Future<LicenseOrderItem?> renewLicense(int keyId, {int? durationMonths}) async {
    try {
      final ApiResponse<Map<String, dynamic>> res = await _networkService.post(
        endpoint: '/user/licenses/renew/$keyId',
        data: durationMonths != null ? {'duration_months': durationMonths} : {},
      );

      if (res.status == Status.completed && res.data != null) {
        final order = LicenseOrderItem.fromJson(res.data!['data']);
        currentOrder.value = order;
        startCountdown(order.priceLockRemainingSeconds > 0 ? order.priceLockRemainingSeconds : 900);
        return order;
      }
    } catch (_) {}
    return null;
  }
}
