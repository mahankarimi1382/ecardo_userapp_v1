import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';

class KycLevelController extends GetxController {
  final NetworkService _networkService = Get.find<NetworkService>();
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxList<KycLevel> levels = <KycLevel>[].obs;
  final Rxn<KycStatus> status = Rxn<KycStatus>();
  final Rxn<KycBadge> badge = Rxn<KycBadge>();

  @override
  void onInit() { super.onInit(); fetchStatus(); }

  Future<void> fetchLevels() async {
    isLoading.value = true;
    final response = await _networkService.get(endpoint: ApiPath.kycLevelLevelsEndpoint);
    isLoading.value = false;
    if (response.status == Status.completed) {
      final data = response.data?['data'] as List<dynamic>?;
      if (data != null) levels.value = data.map((e) => KycLevel.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> fetchStatus() async {
    isLoading.value = true;
    final response = await _networkService.get(endpoint: ApiPath.kycLevelStatusEndpoint);
    isLoading.value = false;
    if (response.status == Status.completed) {
      final data = response.data?['data'] as Map<String, dynamic>?;
      if (data != null) { status.value = KycStatus.fromJson(data); badge.value = status.value!.badge; }
    }
    await fetchLevels();
  }

  Future<bool> submitDocuments({required Map<String, String> documents, int? targetLevel}) async {
    isSubmitting.value = true;
    try {
      final response = await _networkService.post(
        endpoint: ApiPath.kycLevelSubmitEndpoint,
        data: {
          'documents': documents,
          if (targetLevel != null) 'level': targetLevel,
        },
      );
      isSubmitting.value = false;
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data?['data']?['message'] ?? 'Documents submitted.');
        await fetchStatus();
        return true;
      } else if (response.status == Status.error) {
        ToastHelper().showErrorToast(response.message ?? 'Submission failed.');
      }
    } catch (e) { isSubmitting.value = false; ToastHelper().showErrorToast('Failed: $e'); }
    return false;
  }

  bool hasFeature(String feature) => badge.value?.hasFeature(feature) ?? false;
  int get currentLevel => status.value?.currentLevel ?? 1;
  bool get isPending => status.value?.kycStatus == 'pending';
  bool get isRejected => status.value?.isRejected ?? false;
  KycNextLevel? get nextLevel => status.value?.nextLevel;
}
