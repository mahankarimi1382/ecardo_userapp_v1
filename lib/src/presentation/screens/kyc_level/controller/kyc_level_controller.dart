import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Future<bool> submitDocuments({
    required Map<String, String> documents,
    int? targetLevel,
  }) async {
    isSubmitting.value = true;
    final response = await _networkService.post(
      endpoint: ApiPath.kycLevelSubmitEndpoint,
      data: {
        'documents': documents,
        if (targetLevel != null) 'level': targetLevel,
      },
    );
    isSubmitting.value = false;

    if (response.status == Status.completed) {
      ToastHelper().showSuccessToast(
        response.data?['data']?['message'] ?? 'Documents submitted successfully.',
      );
      // refresh status
      await fetchStatus();
      return true;
    } else if (response.status == Status.error) {
      ToastHelper().showErrorToast(response.message ?? 'Submission failed.');
    }
    return false;
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
