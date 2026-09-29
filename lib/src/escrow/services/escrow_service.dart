import 'package:ecardo_user/src/network/response/status.dart';
import 'package:get/get.dart' as getx;
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import '../models/escrow_models.dart';

class EscrowService extends getx.GetxService {
  final NetworkService _network = getx.Get.find<NetworkService>();

  /// Get escrow configuration (rules, inspection limits, fee rates)
  Future<Map<String, dynamic>?> getConfig() async {
    final response = await _network.get(endpoint: '/user/escrow/config');
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// List user's escrow transactions (with optional status filter & pagination)
  Future<List<EscrowOrderModel>> getOrders({String? status, int page = 1}) async {
    final params = <String, dynamic>{'page': page};
    if (status != null && status.isNotEmpty && status != 'ALL') {
      params['status'] = status;
    }

    final queryStr = Uri(queryParameters: params.map((k, v) => MapEntry(k, v.toString()))).query;
    final path = '/user/escrow${queryStr.isNotEmpty ? '?$queryStr' : ''}';

    final response = await _network.get(endpoint: path);
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      final list = data is List ? data : (data is Map ? data['data'] as List? : null);
      if (list != null) {
        return list.map((e) => EscrowOrderModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    }
    return [];
  }

  /// Get full order details by ID
  Future<EscrowOrderModel?> getOrderDetails(int id) async {
    final response = await _network.get(endpoint: '/user/escrow/$id');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 1: Create new escrow deal (draft)
  Future<EscrowOrderModel?> createOrder(Map<String, dynamic> payload) async {
    final response = await _network.post(endpoint: '/user/escrow', data: payload);
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 2: Send for approval
  Future<EscrowOrderModel?> sendApproval(int id) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/send-approval');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 2: Accept terms (Counterparty)
  Future<EscrowOrderModel?> acceptTerms(int id) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/accept-terms');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 2: Request changes
  Future<EscrowOrderModel?> requestChanges(int id, String reason) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/request-changes',
      data: {'reason': reason},
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 3: Pay into escrow
  Future<EscrowOrderModel?> payIntoEscrow(int id, {int? walletId}) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/pay',
      data: {
        if (walletId != null) 'wallet_id': walletId,
      },
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 3: Cancel deal
  Future<EscrowOrderModel?> cancelDeal(int id, {String? reason}) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/cancel',
      data: {
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 4: Submit shipment details (Seller)
  Future<EscrowOrderModel?> submitShipment(int id, {
    required String carrier,
    required String trackingNumber,
    String? trackingUrl,
    String? shippingNotes,
  }) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/shipment',
      data: {
        'shipping_carrier': carrier,
        'tracking_number': trackingNumber,
        if (trackingUrl != null) 'tracking_url': trackingUrl,
        if (shippingNotes != null) 'shipping_notes': shippingNotes,
      },
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 5: Confirm delivery (Buyer)
  Future<EscrowOrderModel?> confirmDelivery(int id) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/confirm-delivery');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 6: Approve & Release funds to seller
  Future<EscrowOrderModel?> approveRelease(int id) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/approve-release');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 6: Request inspection extension
  Future<EscrowOrderModel?> extendInspection(int id, {int hours = 48}) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/extend-inspection',
      data: {'hours': hours},
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowOrderModel.fromJson(data);
      }
    }
    return null;
  }

  /// D1: Open dispute
  Future<EscrowDisputeModel?> openDispute(int id, {
    required String type,
    required String description,
    List<String>? evidenceFiles,
  }) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/dispute',
      data: {
        'type': type,
        'description': description,
        if (evidenceFiles != null) 'evidence_files': evidenceFiles,
      },
    );
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return EscrowDisputeModel.fromJson(data);
      }
    }
    return null;
  }

  /// Step 7: Submit mutual rating
  Future<bool> submitRating(int id, {required int rating, String? comment}) async {
    final response = await _network.post(endpoint: '/user/escrow/$id/rating',
      data: {
        'rating': rating,
        if (comment != null) 'comment': comment,
      },
    );
    return response.status == Status.completed;
  }
}