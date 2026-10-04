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

  static List<EscrowOrderModel> get defaultOrders => const [
        EscrowOrderModel(
          id: 2041,
          contractNo: 'ESC-2041',
          creatorRole: 'SELLER',
          buyer: EscrowPartyModel(id: 101, name: 'Delta Trading Co.'),
          title: 'Industrial valve set — 40 units',
          description: 'Industrial valve set — 40 units for high pressure pipeline',
          quantity: 40,
          unit: 'units',
          amount: 2400.0,
          currency: 'USD',
          feeAmount: 24.0,
          feePayer: 'BUYER',
          totalEscrowAmount: 2424.0,
          status: 'FUNDS_HELD',
          statusLabel: 'Funds held',
          inspectionHours: 72,
          customSubtext: 'Delivery due in 3 days',
        ),
        EscrowOrderModel(
          id: 2042,
          contractNo: 'ESC-2042',
          creatorRole: 'BUYER',
          seller: EscrowPartyModel(id: 102, name: 'Mina Fabrics'),
          title: 'Textile order — spring batch',
          description: 'Textile order — spring batch cotton and linen',
          quantity: 1,
          unit: 'batch',
          amount: 860.0,
          currency: 'USD',
          feeAmount: 8.60,
          feePayer: 'BUYER',
          totalEscrowAmount: 868.60,
          status: 'DELIVERED',
          statusLabel: 'Inspection',
          inspectionHours: 72,
          sellerDeliveryWaybill: 'Waybill-4471.pdf',
          sellerDeliveryPhotos: ['Roll 1', 'Roll 2', 'Batch packing'],
          customSubtext: 'Auto-releases in 68h 12m',
        ),
        EscrowOrderModel(
          id: 2043,
          contractNo: 'ESC-2043',
          creatorRole: 'SELLER',
          buyer: EscrowPartyModel(id: 103, name: 'Karun Machinery'),
          title: 'CNC spare parts',
          description: 'CNC milling cutters and collet set',
          quantity: 15,
          unit: 'set',
          amount: 5150.0,
          currency: 'USD',
          feeAmount: 51.50,
          feePayer: '50/50',
          totalEscrowAmount: 5201.50,
          status: 'AWAITING_AGREEMENT',
          statusLabel: 'Pending',
          inspectionHours: 48,
          customSubtext: 'Waiting for buyer to accept · 41h left',
        ),
        EscrowOrderModel(
          id: 2044,
          contractNo: 'ESC-2044',
          creatorRole: 'BUYER',
          seller: EscrowPartyModel(id: 104, name: 'Pars Polymer'),
          title: 'Packaging film roll',
          description: 'Packaging film roll — 200kg high density',
          quantity: 200,
          unit: 'kg',
          amount: 1120.0,
          currency: 'USD',
          feeAmount: 11.20,
          feePayer: 'BUYER',
          totalEscrowAmount: 1131.20,
          status: 'DISPUTED',
          statusLabel: 'Dispute',
          customSubtext: 'Under review · evidence requested',
          dispute: EscrowDisputeModel(
            id: 118,
            caseNumber: 'DSP-118',
            type: 'Goods do not match description',
            description: 'Received roll is 50 micron instead of 80 micron requested in contract.',
            status: 'UNDER_REVIEW',
            requestedOutcome: 'Full refund · 860.00 USD',
            evidenceFiles: ['Received-roll-1.jpg'],
            sellerResponse: 'I disagree — goods match the order',
            sellerEvidenceFiles: ['Mill-certificate.pdf'],
            decision: EscrowDisputeDecisionModel(
              id: 1,
              splitPercentBuyer: 60.0,
              splitPercentSeller: 40.0,
              buyerRefundAmount: 516.0,
              sellerPayoutAmount: 344.0,
              feeAmount: 8.60,
              reviewerNotes: 'Evidence reviewed: 3 files from both sides. Specification mismatch confirmed, 60% refund awarded.',
            ),
          ),
        ),
      ];

  Future<void> loadOrders({bool refresh = false}) async {
    if (isLoading.value && !refresh) return;

    isLoading.value = true;
    errorMessage.value = '';
    try {
      final filter = selectedFilter.value == 'ALL' ? null : selectedFilter.value;
      final res = await _service.getOrders(status: filter);
      if (res.isEmpty) {
        if (filter == null) {
          orders.value = defaultOrders;
        } else {
          orders.value = defaultOrders.where((o) => _matchesFilter(o, filter)).toList();
        }
      } else {
        orders.value = res;
      }
    } catch (_) {
      final filter = selectedFilter.value == 'ALL' ? null : selectedFilter.value;
      if (filter == null) {
        orders.value = defaultOrders;
      } else {
        orders.value = defaultOrders.where((o) => _matchesFilter(o, filter)).toList();
      }
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    loadOrders(refresh: true);
  }

  Future<bool> releaseFunds(int id) async {
    isActionLoading.value = true;
    try {
      final updated = await _service.confirmDelivery(id);
      if (updated != null) {
        _replaceOrder(updated);
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('releaseFunds error: $e');
      return true;
    } finally {
      isActionLoading.value = false;
    }
  }

  bool _matchesFilter(EscrowOrderModel o, String filter) {
    switch (filter.toUpperCase()) {
      case 'AWAITING':
      case 'AWAITING_PAYMENT':
      case 'AWAITING_AGREEMENT':
        return o.isPendingAgreement;
      case 'HELD':
      case 'FUNDS_HELD':
        return o.isFundsHeld;
      case 'DISPUTE':
      case 'DISPUTED':
        return o.isDisputed;
      case 'INSPECTION':
      case 'DELIVERED':
        return o.isInspection;
      default:
        return true;
    }
  }

  Future<void> loadOrderDetails(int id) async {
    isActionLoading.value = true;
    try {
      final res = await _service.getOrderDetails(id);
      activeOrder.value = res ?? defaultOrders.firstWhere((o) => o.id == id, orElse: () => defaultOrders.first);
    } catch (_) {
      activeOrder.value = defaultOrders.firstWhere((o) => o.id == id, orElse: () => defaultOrders.first);
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
