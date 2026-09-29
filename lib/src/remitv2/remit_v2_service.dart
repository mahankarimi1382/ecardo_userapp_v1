import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

/// Remittance v2 (Wise pattern layer) — corridor catalog, validation,
/// public tracking. Works alongside the existing remittance module.
class RemittanceV2ApiService {
  final NetworkService _network = NetworkService();

  /// Corridor catalog — GET /remittance-v2/corridors (public)
  Future<List<Map<String, dynamic>>> getCorridors({String? sourceCountry, String? destCountry}) async {
    final qp = <String>[];
    if (sourceCountry != null) qp.add('source_country=$sourceCountry');
    if (destCountry != null) qp.add('dest_country=$destCountry');
    final ep = qp.isEmpty ? '/remittance-v2/corridors' : '/remittance-v2/corridors?${qp.join('&')}';

    final response = await _network.get(endpoint: ep);
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['corridors'] as List?;
      if (list != null) {
        return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
    }
    return [];
  }

  /// Pre-validate corridor + KYC tiered limits before booking
  /// Returns null on success, or 'ERR_CODE: message' on guard failure.
  Future<String?> validateCorridor({
    required int corridorId,
    required double amount,
    required String payoutMethod,
  }) async {
    final response = await _network.post(endpoint: '/remittance-v2/validate', data: {
      'corridor_id': corridorId,
      'amount': amount,
      'payout_method': payoutMethod,
    });
    if (response.status == Status.completed) return null;
    final data = response.data;
    if (data != null && data['error_code'] != null) {
      return '${data['error_code']}: ${data['message']}';
    }
    return 'ERR_NETWORK: خطا در اعتبارسنجی مسیر';
  }

  /// Public tracking without login — returns status only (no names/amounts)
  Future<Map<String, dynamic>?> publicTrack(String trx) async {
    final response = await _network.get(endpoint: '/remittance-v2/track/$trx');
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// File dispute (30-day window) — BTN_FILE_DISPUTE
  Future<bool> fileDispute({
    required String trx,
    required String reasonType,
    String? description,
  }) async {
    final response = await _network.post(endpoint: '/remittance-v2/disputes', data: {
      'trx': trx,
      'reason_type': reasonType,
      'description': description,
    });
    return response.status == Status.completed;
  }
}
