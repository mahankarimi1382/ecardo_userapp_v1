import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/model/ad_payment_method_response_model.dart'
    as ad_payment_method;
import 'package:qunzo_user/src/presentation/screens/p2p/model/order_details_response_model.dart'
    as order_details;
import 'package:qunzo_user/src/presentation/screens/p2p/controller/p2p_buy_ad_controller.dart';

class P2pOrderDetailsController extends GetxController {
  final int orderId;

  P2pOrderDetailsController({
    required this.orderId,
  });

  final RxBool isLoading = false.obs;
  final RxBool isPaymentMethodsLoading = false.obs;
  final RxBool isUpdatingPaymentMethod = false.obs;
  final RxBool isCancellingOrder = false.obs;
  final RxBool isMarkingPaid = false.obs;
  final RxBool isDisputingOrder = false.obs;
  final RxBool isReleasingOrder = false.obs;
  final Rxn<order_details.OrderDetailsResponseModel> orderResponse =
      Rxn<order_details.OrderDetailsResponseModel>();
  final Rxn<order_details.Data> orderData = Rxn<order_details.Data>();

  final RxList<AdPaymentOption> paymentMethods = <AdPaymentOption>[].obs;
  final RxnInt selectedPaymentMethodId = RxnInt();

  final Rx<Duration> remainingDuration = Duration.zero.obs;
  final RxBool isOrderCreatedExpanded = true.obs;
  final RxBool isTransferExpanded = true.obs;
  final RxBool isNotifySellerExpanded = true.obs;
  Timer? _countdownTimer;

  @override
  void onInit() {
    super.onInit();
    fetchOrderDetails();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchOrderDetails() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: '${ApiPath.getMyOrdersEndPoint}/$orderId',
      );

      if (response.status == Status.completed && response.data != null) {
        final model = order_details.OrderDetailsResponseModel.fromJson(
          response.data!,
        );
        orderResponse.value = model;
        orderData.value = model.data;

        final selectedFromOrder = model.data?.paymentMethod?.id;
        if (selectedFromOrder != null) {
          selectedPaymentMethodId.value = selectedFromOrder;
        }
        await fetchAdPaymentMethods();
        _startCountdown();
      }
    } catch (e, stackTrace) {
      debugPrint('fetchOrderDetails() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to load order details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAdPaymentMethods() async {
    final adId = orderData.value?.adId;
    if (adId == null) return;

    isPaymentMethodsLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.adPaymentMethodEndpoint(adId: '$adId'),
      );

      if (response.status != Status.completed || response.data == null) {
        return;
      }

      final model = ad_payment_method.AdPaymentMethodResponseModel.fromJson(
        response.data!,
      );
      final methods =
          model.data?.paymentMethods ??
          <ad_payment_method.PaymentMethodElement>[];

      final options = methods
          .map((method) {
            final id = method.paymentMethod?.id ?? method.id ?? 0;
            final name = method.paymentMethod?.name ?? 'Method';
            final fields = method.fields ?? <ad_payment_method.Field>[];
            final accountInfo = fields.isNotEmpty
                ? (fields.first.value ?? '')
                : '';
            return AdPaymentOption(
              id: id,
              name: name,
              accountInfo: accountInfo,
            );
          })
          .where((item) => item.id > 0)
          .toList();

      if (options.isEmpty) return;
      paymentMethods
        ..clear()
        ..addAll(options);
      selectedPaymentMethodId.value ??= options.first.id;
    } catch (e, stackTrace) {
      debugPrint('fetchAdPaymentMethods() error: $e');
      debugPrint('StackTrace: $stackTrace');
    } finally {
      isPaymentMethodsLoading.value = false;
    }
  }

  AdPaymentOption? get selectedPaymentMethod {
    final selectedId = selectedPaymentMethodId.value;
    if (selectedId == null) return null;
    for (final item in paymentMethods) {
      if (item.id == selectedId) return item;
    }
    return null;
  }

  void onPaymentMethodChanged(int id) {
    selectedPaymentMethodId.value = id;
  }

  Future<void> updateOrderPaymentMethod(int newPaymentMethodId) async {
    final currentId = selectedPaymentMethodId.value;
    if (currentId == newPaymentMethodId) {
      return;
    }

    final adId = orderData.value?.adId;
    if (adId == null) {
      ToastHelper().showErrorToast('Ad not found for this order');
      return;
    }

    isUpdatingPaymentMethod.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.adPaymentMethodEndpoint(adId: '$adId'),
        data: <String, dynamic>{
          'payment_method_id': newPaymentMethodId,
          '_method': 'PATCH',
        },
      );

      if (response.status == Status.completed) {
        selectedPaymentMethodId.value = newPaymentMethodId;
        await fetchOrderDetails();
      }
    } catch (e, stackTrace) {
      debugPrint('updateOrderPaymentMethod() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to change payment method');
    } finally {
      isUpdatingPaymentMethod.value = false;
    }
  }

  Future<void> cancelOrder() async {
    isCancellingOrder.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.cancelAdEndpoint(id: '$orderId'),
      );

      if (response.status == Status.completed) {
        final message = response.data?['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          ToastHelper().showSuccessToast(message);
        }
        await fetchOrderDetails();
      }
    } catch (e, stackTrace) {
      debugPrint('cancelOrder() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to cancel order');
    } finally {
      isCancellingOrder.value = false;
    }
  }

  Future<void> markOrderPaid() async {
    isMarkingPaid.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.markPaidEndpoint(id: '$orderId'),
      );

      if (response.status == Status.completed) {
        final message = response.data?['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          ToastHelper().showSuccessToast(message);
        }
        await fetchOrderDetails();
      }
    } catch (e, stackTrace) {
      debugPrint('markOrderPaid() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to notify seller');
    } finally {
      isMarkingPaid.value = false;
    }
  }

  Future<bool> disputeOrder({required String reason}) async {
    final safeReason = reason.trim();
    if (safeReason.isEmpty) {
      ToastHelper().showErrorToast('Reason is required');
      return false;
    }

    isDisputingOrder.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.disputeOrderEndpoint(id: '$orderId'),
        data: <String, dynamic>{'reason': safeReason},
      );

      if (response.status == Status.completed) {
        final message = response.data?['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          ToastHelper().showSuccessToast(message);
        }
        await fetchOrderDetails();
        return true;
      }
    } catch (e, stackTrace) {
      debugPrint('disputeOrder() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to submit dispute');
    } finally {
      isDisputingOrder.value = false;
    }
    return false;
  }

  Future<void> releaseOrder() async {
    isReleasingOrder.value = true;
    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.releaseOrderEndpoint(id: '$orderId'),
      );

      if (response.status == Status.completed) {
        final message = response.data?['message']?.toString();
        if (message != null && message.trim().isNotEmpty) {
          ToastHelper().showSuccessToast(message);
        }
        await fetchOrderDetails();
      }
    } catch (e, stackTrace) {
      debugPrint('releaseOrder() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast('Failed to release order');
    } finally {
      isReleasingOrder.value = false;
    }
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final deadline = orderData.value?.paymentDeadlineAt;
    if (deadline == null) {
      remainingDuration.value = Duration.zero;
      return;
    }
    final now = DateTime.now();
    final diff = deadline.difference(now);
    remainingDuration.value = diff.isNegative ? Duration.zero : diff;
  }

  String get countdownText {
    final d = remainingDuration.value;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = d.inHours;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  bool get isBuy {
    final adType = (orderData.value?.adType ?? '').toLowerCase();
    return adType == 'sell';
  }

  void toggleOrderCreated() {
    isOrderCreatedExpanded.value = !isOrderCreatedExpanded.value;
  }

  void toggleTransfer() {
    isTransferExpanded.value = !isTransferExpanded.value;
  }

  void toggleNotifySeller() {
    isNotifySellerExpanded.value = !isNotifySellerExpanded.value;
  }
}
