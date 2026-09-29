import 'package:ecardo_user/src/network/response/status.dart';
import 'package:get/get.dart' as getx;

import 'package:ecardo_user/src/network/service/network_service.dart';
import '../models/guarantee_models.dart';

/// Bank Guarantee & LC API client — endpoints: /guarantee/*
class GuaranteeApiService extends getx.GetxService {
  final NetworkService _network = getx.Get.find<NetworkService>();

  /// Instrument catalog + decision-table finder (۵-الف)
  Future<Map<String, dynamic>?> getInstruments() async {
    final response = await _network.get(endpoint: '/guarantee/instruments');
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  Future<List<GuaranteeInstrumentModel>> listInstruments() async {
    final data = await getInstruments();
    final list = data?['instruments'] as List?;
    if (list != null) {
      return list.map((e) => GuaranteeInstrumentModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
    return [];
  }

  /// Bank offers comparison
  Future<List<GuaranteeBankOfferModel>> getBanks(int instrumentId) async {
    final response = await _network.get(endpoint: '/guarantee/instruments/$instrumentId/banks');
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['offers'] as List?;
      if (list != null) {
        return list.map((e) => GuaranteeBankOfferModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    }
    return [];
  }

  /// My cases
  Future<List<GuaranteeCaseModel>> getMyCases() async {
    final response = await _network.get(endpoint: '/guarantee/my');
    if (response.status == Status.completed && response.data != null) {
      final list = response.data!['data']?['cases'] as List?;
      if (list != null) {
        return list.map((e) => GuaranteeCaseModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      }
    }
    return [];
  }

  /// Case detail
  Future<GuaranteeCaseModel?> getCase(int id) async {
    final response = await _network.get(endpoint: '/guarantee/cases/$id');
    if (response.status == Status.completed && response.data != null) {
      final data = response.data!['data']?['case'];
      if (data is Map<String, dynamic>) return GuaranteeCaseModel.fromJson(data);
    }
    return null;
  }

  /// Create case — BTN_APPLY_GUARANTEE
  Future<Map<String, dynamic>?> createCase({
    required int instrumentId,
    required String beneficiaryName,
    required double amount,
    required int validityMonths,
    int? bankOfferId,
    String? contractRef,
  }) async {
    final response = await _network.post(endpoint: '/guarantee/cases', data: {
      'instrument_id': instrumentId,
      'beneficiary_name': beneficiaryName,
      'amount': amount,
      'validity_months': validityMonths,
      'bank_offer_id': bankOfferId,
      'contract_ref': contractRef,
    });
    if (response.status == Status.completed && response.data != null) {
      return response.data!['data'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Upload doc — BTN_UPLOAD_DOC
  Future<bool> uploadDoc(int caseId, String docType, String fileRef) async {
    final response = await _network.post(endpoint: '/guarantee/cases/$caseId/documents', data: {
      'doc_type': docType,
      'file_ref': fileRef,
    });
    return response.status == Status.completed;
  }

  /// Submit case — BTN_SUBMIT_CASE
  Future<bool> submit(int caseId) async {
    final response = await _network.post(endpoint: '/guarantee/cases/$caseId/submit', data: {});
    return response.status == Status.completed;
  }

  /// Deposit margin — BTN_DEPOSIT_MARGIN
  Future<bool> depositMargin(int caseId, String source) async {
    final response = await _network.post(endpoint: '/guarantee/cases/$caseId/margin', data: {'source': source});
    return response.status == Status.completed;
  }

  /// Cancel case — BTN_CANCEL_CASE
  Future<bool> cancel(int caseId) async {
    final response = await _network.post(endpoint: '/guarantee/cases/$caseId/cancel', data: {});
    return response.status == Status.completed;
  }
}
