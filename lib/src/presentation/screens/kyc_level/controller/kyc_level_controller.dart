import 'dart:io' as dart_io;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http_parser/http_parser.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';

/// KycLevelController — مدیریت سطوح KYC در کلاینت
///
/// وظایف:
///   ۱. fetchLevels — دریافت لیست همه سطوح
///   ۲. fetchStatus — دریافت وضعیت فعلی کاربر
///   ۳. submitDocuments — ارسال مدارک برای سطح بعدی
///   ۴. hasFeature — بررسی دسترسی به feature خاص
class KycLevelController extends GetxController {
  final NetworkService _networkService = Get.find<NetworkService>();

  // State
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

  /// دریافت لیست همه سطوح KYC
  Future<void> fetchLevels() async {
    isLoading.value = true;
    final response = await _networkService.get(
      endpoint: ApiPath.kycLevelLevelsEndpoint,
    );
    isLoading.value = false;

    if (response.status == Status.completed) {
      final data = response.data?['data'] as List<dynamic>?;
      if (data != null) {
        levels.value = data
            .map((e) => KycLevel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
  }

  /// دریافت وضعیت کامل KYC کاربر فعلی
  Future<void> fetchStatus() async {
    isLoading.value = true;
    final response = await _networkService.get(
      endpoint: ApiPath.kycLevelStatusEndpoint,
    );
    isLoading.value = false;

    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        status.value = KycStatus.fromJson(data);
        badge.value = status.value!.badge;
      }
    }

    // همچنین levels را fetch کن
    await fetchLevels();
  }

  /// دریافت badge کاربر فعلی
  Future<void> fetchBadge() async {
    final response = await _networkService.get(
      endpoint: ApiPath.kycLevelBadgeEndpoint,
    );

    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) {
        badge.value = KycBadge.fromJson(data);
      }
    }
  }

  /// ارسال مدارک برای سطح بعدی
  /// v56 BUG-K003: از FormData برای multipart file upload استفاده می‌کند
  Future<bool> submitDocuments({
    required Map<String, String> documents,
    int? targetLevel,
  }) async {
    isSubmitting.value = true;
    try {
      // ساخت FormData برای multipart upload
      final formData = <String, dynamic>{};
      if (targetLevel != null) {
        formData['level'] = targetLevel.toString();
      }

      // افزودن فایل‌ها به‌عنوان multipart
      for (final entry in documents.entries) {
        final file = dart_io.File(entry.value);
        if (await file.exists()) {
          final fileName = entry.value.split('/').last;
          final mimeType = _getMimeType(fileName);
          formData['documents[${entry.key}]'] = http_parser.MultipartFile.fromBytes(
            await file.readAsBytes(),
            filename: fileName,
            contentType:MediaType.parse(mimeType),
          );
        } else {
          // اگر فایل موجود نبود، path را به‌عنوان string بفرست
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

  /// بررسی دسترسی کاربر به feature خاص
  bool hasFeature(String feature) {
    return badge.value?.hasFeature(feature) ?? false;
  }

  /// سطح فعلی کاربر
  int get currentLevel => status.value?.currentLevel ?? 1;

  /// آیا کاربر در حالت pending است؟
  bool get isPending => status.value?.kycStatus == 'pending';

  /// آیا کاربر رد شده است؟
  bool get isRejected => status.value?.isRejected ?? false;

  /// سطح بعدی برای ارتقا (اگر وجود دارد)
  KycNextLevel? get nextLevel => status.value?.nextLevel;

  /// نام فارسی وضعیت
  String get statusLabel {
    switch (status.value?.kycStatus) {
      case 'verified':
        return 'تأیید شده';
      case 'pending':
        return 'در حال بررسی';
      case 'failed':
        return 'رد شده';
      default:
        return 'ارسال نشده';
    }
  }
}
