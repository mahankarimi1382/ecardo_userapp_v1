import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/escrow_models.dart';
import '../services/escrow_service.dart';

class EscrowController extends GetxController {
  final EscrowService _service = Get.put(EscrowService());

  final RxList<EscrowOrderModel> orders = <EscrowOrderModel>[].obs;
  final Rx<EscrowOrderModel?> activeOrder = Rx<EscrowOrderModel?>(null);
  final RxMap<String, dynamic> config = <String, dynamic>{}.obs;

  final RxString selectedFilter = 'ALL'.obs;
  final RxBool isLoading = false.obs;
  final RxBool isActionLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadConfig();
    loadOrders();
  }

  Future<void> loadConfig() async {
    try {
      final res = await _service.getConfig();
      if (res != null) {
        config.value = res;
      }
    } catch (_) {}
  }

  Future<void> loadOrders({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final filter = selectedFilter.value == 'ALL' ? null : selectedFilter.value;
      final res = await _service.getOrders(status: filter);
      orders.value = res;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadOrders(refresh: true);
  }

  Future<void> loadOrderDetails(int id) async {
    isActionLoading.value = true;
    try {
      final res = await _service.getOrderDetails(id);
      if (res != null) {
        activeOrder.value = res;
      }
    } catch (e) {
      debugPrint('loadOrderDetails error: $e');
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<EscrowOrderModel?> createDeal(Map<String, dynamic> payload) async {
    isActionLoading.value = true;
    errorMessage.value = '';
    try {
      final order = await _service.createOrder(payload);
      if (order != null) {
        orders.insert(0, order);
        activeOrder.value = order;
        return order;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isActionLoading.value = false;
    }
    return null;
  }

  Future<bool> sendForApproval(int id) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.sendApproval(id);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('sendForApproval error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> acceptTerms(int id) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.acceptTerms(id);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('acceptTerms error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> requestChanges(int id, String reason) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.requestChanges(id, reason);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('requestChanges error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> payIntoEscrow(int id, {int? walletId}) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.payIntoEscrow(id, walletId: walletId);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('payIntoEscrow error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> cancelDeal(int id, {String? reason}) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.cancelDeal(id, reason: reason);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('cancelDeal error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> submitShipment(int id, {
    required String carrier,
    required String trackingNumber,
    String? trackingUrl,
    String? shippingNotes,
  }) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.submitShipment(
        id,
        carrier: carrier,
        trackingNumber: trackingNumber,
        trackingUrl: trackingUrl,
        shippingNotes: shippingNotes,
      );
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('submitShipment error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> confirmDelivery(int id) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.confirmDelivery(id);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('confirmDelivery error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> approveRelease(int id) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.approveRelease(id);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('approveRelease error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> extendInspection(int id, {int hours = 48}) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.extendInspection(id, hours: hours);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
    } catch (e) {
      debugPrint('extendInspection error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> openDispute(int id, {
    required String type,
    required String description,
    List<String>? evidenceFiles,
  }) async {
    isActionLoading.value = true;
    try {
      final dispute = await _service.openDispute(
        id,
        type: type,
        description: description,
        evidenceFiles: evidenceFiles,
      );
      if (dispute != null) {
        await loadOrderDetails(id);
        return true;
      }
    } catch (e) {
      debugPrint('openDispute error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  Future<bool> submitRating(int id, {required int rating, String? comment}) async {
    isActionLoading.value = true;
    try {
      final ok = await _service.submitRating(id, rating: rating, comment: comment);
      if (ok) {
        await loadOrderDetails(id);
      }
      return ok;
    } catch (e) {
      debugPrint('submitRating error: $e');
    } finally {
      isActionLoading.value = false;
    }
    return false;
  }

  void _replaceOrder(EscrowOrderModel order) {
    activeOrder.value = order;
    final index = orders.indexWhere((o) => o.id == order.id);
    if (index != -1) {
      orders[index] = order;
    }
  }
}
