import 'package:get/get.dart' as getx;
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import '../model/license_models.dart';

/// Service client for License Store API — endpoints: /user/licenses/*
class LicenseService extends getx.GetxService {
  final NetworkService _network = getx.Get.find<NetworkService>();

  /// Fetch license product catalog with optional category and search query
  Future<List<LicenseProductItem>> getCatalog({String? category, String? search}) async {
    String ep = '/user/licenses/catalog';
    final qp = <String>[];
    if (category != null && category != 'all') qp.add('category=$category');
    if (search != null && search.isNotEmpty) qp.add('search=${Uri.encodeComponent(search)}');
    if (qp.isNotEmpty) ep += '?${qp.join('&')}';

    final ApiResponse<Map<String, dynamic>> res = await _network.get(endpoint: ep);
    if (res.status == Status.completed && res.data != null) {
      final list = res.data!['data']?['products'] as List? ?? [];
      return list.map((item) => LicenseProductItem.fromJson(item)).toList();
    }
    return [];
  }

  /// Fetch single license product details by slug
  Future<LicenseProductItem?> getProduct(String slug) async {
    final ApiResponse<Map<String, dynamic>> res = await _network.get(
      endpoint: '/user/licenses/catalog/$slug',
    );
    if (res.status == Status.completed && res.data != null) {
      final data = res.data!['data'];
      if (data != null) {
        return LicenseProductItem.fromJson(data);
      }
    }
    return null;
  }

  /// Create license purchase order
  Future<LicenseOrderItem?> createOrder({
    required int productId,
    required int tierId,
    int quantity = 1,
  }) async {
    final ApiResponse<Map<String, dynamic>> res = await _network.post(
      endpoint: '/user/licenses/orders',
      data: {
        'product_id': productId,
        'tier_id': tierId,
        'quantity': quantity,
      },
    );

    if (res.status == Status.completed && res.data != null) {
      final data = res.data!['data'];
      if (data != null) {
        return LicenseOrderItem.fromJson(data);
      }
    }
    return null;
  }

  /// Pay for order from wallet balance
  Future<bool> payOrder(String orderNumber) async {
    final ApiResponse<Map<String, dynamic>> res = await _network.post(
      endpoint: '/user/licenses/orders/$orderNumber/pay',
      data: {'payment_method': 'WALLET'},
    );
    return res.status == Status.completed;
  }

  /// Get purchased license keys / vault
  Future<List<LicenseKeyItem>> getMyLicenses() async {
    final ApiResponse<Map<String, dynamic>> res = await _network.get(
      endpoint: '/user/licenses/my',
    );
    if (res.status == Status.completed && res.data != null) {
      final list = res.data!['data']?['licenses'] as List? ?? [];
      return list.map((item) => LicenseKeyItem.fromJson(item)).toList();
    }
    return [];
  }

  /// Get user's order history
  Future<List<LicenseOrderItem>> getMyOrders() async {
    final ApiResponse<Map<String, dynamic>> res = await _network.get(
      endpoint: '/user/licenses/orders',
    );
    if (res.status == Status.completed && res.data != null) {
      final list = res.data!['data']?['orders'] as List? ?? [];
      return list.map((item) => LicenseOrderItem.fromJson(item)).toList();
    }
    return [];
  }

  /// File dispute / support claim for key issue
  Future<bool> submitDispute({
    required int licenseKeyId,
    required String issueType,
    required String description,
  }) async {
    final ApiResponse<Map<String, dynamic>> res = await _network.post(
      endpoint: '/user/licenses/disputes',
      data: {
        'license_key_id': licenseKeyId,
        'issue_type': issueType,
        'description': description,
      },
    );
    return res.status == Status.completed;
  }
}
