import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:ecardo_user/src/network/service/network_service.dart';
import '../models/visa_models.dart';

class VisaService extends GetxService {
  final NetworkService _network = Get.find<NetworkService>();

  /// Fetch active visa catalog list
  Future<List<VisaCatalogItem>> getCatalog() async {
    final response = await _network.get(endpoint: '/visa/catalog');
    if (response.data != null && response.data?['data'] is List) {
      final list = response.data!['data'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => VisaCatalogItem.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Fetch single catalog item details
  Future<VisaCatalogItem?> getCatalogDetail(int id) async {
    final response = await _network.get(endpoint: '/visa/catalog/$id');
    if (response.data != null && response.data?['data'] is Map) {
      return VisaCatalogItem.fromJson(
        Map<String, dynamic>.from(response.data!['data']),
      );
    }
    return null;
  }

  /// Fetch current user's visa requests
  Future<List<VisaRequestModel>> getUserRequests() async {
    final response = await _network.get(endpoint: '/user/visa/requests');
    if (response.data != null && response.data?['data'] is List) {
      final list = response.data!['data'] as List;
      return list
          .whereType<Map<String, dynamic>>()
          .map((item) => VisaRequestModel.fromJson(item))
          .toList();
    }
    return [];
  }

  /// Fetch single request details by caseNo
  Future<VisaRequestModel?> getRequestDetail(String caseNo) async {
    final response = await _network.get(
      endpoint: '/user/visa/requests/$caseNo',
    );
    if (response.data != null && response.data?['data'] is Map) {
      return VisaRequestModel.fromJson(
        Map<String, dynamic>.from(response.data!['data']),
      );
    }
    return null;
  }

  /// Create new visa request
  Future<VisaRequestModel?> createRequest({
    required int catalogId,
    required Map<String, dynamic> applicantInfo,
    String? travelDate,
    String? returnDate,
  }) async {
    final fullName = applicantInfo['full_name']?.toString() ?? '';
    final names = fullName.trim().split(' ');
    final firstName = names.isNotEmpty ? names.first : 'Applicant';
    final lastName = names.length > 1 ? names.sublist(1).join(' ') : 'Traveler';
    final passportNo =
        (applicantInfo['passport_no'] ??
                applicantInfo['passport_number'] ??
                'A1000000')
            .toString()
            .toUpperCase();
    final passportExpiry =
        applicantInfo['passport_expiry_date'] ??
        applicantInfo['passport_expiry'] ??
        '${DateTime.now().year + 5}-10-20';

    final payload = <String, dynamic>{
      'catalog_id': catalogId,
      'first_name': firstName,
      'last_name': lastName,
      'passport_no': passportNo,
      'passport_expiry_date': passportExpiry,
      'nationality': applicantInfo['nationality'] ?? 'IR',
      'phone': applicantInfo['phone'] ?? '',
      'email': applicantInfo['email'] ?? '',
      'applicant_info': applicantInfo,
      'travel_date': ?travelDate,
      'return_date': ?returnDate,
    };

    final response = await _network.post(
      endpoint: '/user/visa/requests',
      data: payload,
    );

    if (response.data != null && response.data?['data'] is Map) {
      return VisaRequestModel.fromJson(
        Map<String, dynamic>.from(response.data!['data']),
      );
    }
    return null;
  }

  /// Upload document for a visa request
  Future<bool> uploadDocument({
    required String caseNo,
    required String docKey,
    required File file,
  }) async {
    final fileName = file.path.split('/').last.split('\\').last;
    final formData = FormData.fromMap({
      'doc_type': docKey,
      'doc_key': docKey,
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _network.postMultipart(
      endpoint: '/user/visa/requests/$caseNo/documents',
      data: formData,
    );

    return response.data != null && response.data?['status'] != false;
  }

  /// Pay for visa request from user wallet
  Future<bool> payRequest(String caseNo) async {
    final response = await _network.post(
      endpoint: '/user/visa/requests/$caseNo/pay',
      data: {},
    );
    return response.data != null && response.data?['status'] != false;
  }

  /// Final submit request to consultants
  Future<bool> submitRequest(String caseNo) async {
    final response = await _network.post(
      endpoint: '/user/visa/requests/$caseNo/submit',
      data: {},
    );
    return response.data != null && response.data?['status'] != false;
  }

  /// Cancel visa request (if in cancellable state)
  Future<bool> cancelRequest(String caseNo) async {
    final response = await _network.post(
      endpoint: '/user/visa/requests/$caseNo/cancel',
      data: {},
    );
    return response.data != null && response.data?['status'] != false;
  }

  /// Confirm delivery of e-visa by user
  Future<bool> confirmDelivery(String caseNo) async {
    final response = await _network.post(
      endpoint: '/user/visa/requests/$caseNo/confirm-delivery',
      data: {},
    );
    return response.data != null && response.data?['status'] != false;
  }
}
