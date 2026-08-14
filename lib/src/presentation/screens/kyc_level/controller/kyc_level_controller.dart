import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
// Conditional import for dart:io — works on mobile, stubbed on web
import 'kyc_file_reader_stub.dart'
    if (dart.library.io) 'kyc_file_reader_io.dart';

/// KycLevelController — مدیریت سطوح KYC در کلاینت
class KycLevelController extends GetxController {
  final NetworkService _networkService = Get.find<NetworkService>();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<KycLevel> levels = <KycLevel>[].obs;
  final Rxn<KycStatus> status = Rxn<KycStatus>();
  final Rxn<KycBadge> badge = Rxn<KycBadge>();

  @override
  void onInit() {
    super.onInit();
    fetchStatus();
  }

  Future<void> fetchLevels() async {
    isLoading.value = true;
    final response = await _networkService.get(endpoint: ApiPath.kycLevelLevelsEndpoint);
    isLoading.value = false;
    if (response.status == Status.completed) {
      final data = response.data?['data'] as List<dynamic>?;
      if (data != null) {
        levels.value = data.map((e) => KycLevel.fromJson(e as Map<String, dynamic>)).toList();
      }
    }
  }

  Future<void> fetchStatus() async {
    isLoading.value = true;
    final response = await _networkService.get(endpoint: ApiPath.kycLevelStatusEndpoint);
    isLoading.value = false;
    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        status.value = KycStatus.fromJson(data);
        badge.value = status.value!.badge;
      }
    }
    await fetchLevels();
  }

  Future<void> fetchBadge() async {
    final response = await _networkService.get(endpoint: ApiPath.kycLevelBadgeEndpoint);
    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        badge.value = KycBadge.fromJson(data);
      }
    }
  }

  Future<bool> submitDocuments({
    required Map<String, String> documents,
    int? targetLevel,
  }) async {
    isSubmitting.value = true;
    try {
      final formData = <String, dynamic>{};
      if (targetLevel != null) {
        formData['level'] = targetLevel.toString();
      }

      for (final entry in documents.entries) {
        final fileName = entry.value.split('/').last;
        final mimeType = _getMimeType(fileName);

        // Use platform-aware file reader
        final bytes = await KycFileReader.readBytes(entry.value);
        if (bytes != null) {
          formData['documents[${entry.key}]'] = http_parser.MultipartFile.fromBytes(
            bytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          );
        } else {
          formData['documents[${entry.key}]'] = entry.value;
        }
      }

      final response = await _networkService.post(
        endpoint: ApiPath.kycLevelSubmitEndpoint,
        data: formData,
      );
      isSubmitting.value = false;

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(
          response.data?['data']?['message'] ?? 'Documents submitted successfully.',
        );
        await fetchStatus();
        return true;
      } else if (response.status == Status.error) {
        ToastHelper().showErrorToast(response.message ?? 'Submission failed.');
      }
    } catch (e) {
      isSubmitting.value = false;
      ToastHelper().showErrorToast('Failed to submit documents: $e');
    }
    return false;
  }

  bool hasFeature(String feature) {
    return badge.value?.hasFeature(feature) ?? false;
  }

  int get currentLevel => status.value?.currentLevel ?? 1;
  bool get isPending => status.value?.kycStatus == 'pending';
  bool get isRejected => status.value?.isRejected ?? false;
  KycNextLevel? get nextLevel => status.value?.nextLevel;

  String get statusLabel {
    switch (status.value?.kycStatus) {
      case 'verified': return 'تأیید شده';
      case 'pending': return 'در حال بررسی';
      case 'failed': return 'رد شده';
      default: return 'ارسال نشده';
    }
  }

  String _getMimeType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'application/octet-stream';
    }
  }
}
