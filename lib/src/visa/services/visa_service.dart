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
    final response = await _network.get(endpoint: '/user/visa/requests/$caseNo');
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
    final payload = {
      'catalog_id': catalogId,
      'applicant_info': applicantInfo,
      if (travelDate != null) 'travel_date': travelDate,
      if (returnDate != null) 'return_date': returnDate,
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
