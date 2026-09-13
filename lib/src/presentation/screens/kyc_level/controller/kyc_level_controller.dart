import 'dart:io' show File;

import 'package:dio/dio.dart' as dio show FormData, MultipartFile;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
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

  /// S-019 — submit KYC documents as a real multipart upload.
  ///
  /// The server (`api/user/kyc-level/submit`) accepts each document under the
  /// key `documents[<name>]` either as an uploaded FILE (preferred — it runs
  /// the ImageUploadTrait on it) or as a plain string. This method used to
  /// JSON-encode local file *paths* into `{'documents': {...}}`, which the
  /// server stored as unreachable path strings.
  ///
  /// Behaviour now:
  ///  - value is an existing local file  -> MultipartFile under documents[key]
  ///  - value is anything else (e.g. an already-uploaded server path on web)
  ///      -> plain string field under documents[key]
  Future<bool> submitDocuments({required Map<String, String> documents, int? targetLevel}) async {
    isSubmitting.value = true;
    try {
      final formData = dio.FormData();
      if (targetLevel != null) {
        formData.fields.add(MapEntry('level', targetLevel.toString()));
      }

      for (final entry in documents.entries) {
        final key = 'documents[${entry.key}]';
        final isLocalFile = !kIsWeb && entry.value.isNotEmpty && File(entry.value).existsSync();
        if (isLocalFile) {
          formData.files.add(
            MapEntry(key, await dio.MultipartFile.fromFile(entry.value)),
          );
        } else {
          formData.fields.add(MapEntry(key, entry.value));
        }
      }

      if (formData.files.isEmpty && formData.fields.where((f) => f.key.startsWith('documents[')).isEmpty) {
        isSubmitting.value = false;
        // v1.0.24: localized (nullable l10n — controller may live longer than
        // the current language context).
        final localization = AppLocalizations.of(Get.context!);
        ToastHelper().showErrorToast(
          localization?.kycDocumentsRequired ?? 'Documents are required.',
        );
        return false;
      }

      final response = await _networkService.postMultipart(
        endpoint: ApiPath.kycLevelSubmitEndpoint,
        data: formData,
      );
      isSubmitting.value = false;
      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data?['data']?['message'] ?? 'Documents submitted.');
        await fetchStatus();
        return true;
      } else if (response.status == Status.error) {
        final localization = AppLocalizations.of(Get.context!);
        ToastHelper().showErrorToast(
          response.message ?? localization?.kycUploadFailed ?? 'Upload failed. Please try again.',
        );
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
