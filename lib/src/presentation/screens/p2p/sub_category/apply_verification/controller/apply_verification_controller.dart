import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/apply_verification/model/apply_verification_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/apply_verification/model/verification_status_response_model.dart'
    as verification_model;

class ApplyVerificationController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final ImagePicker _picker = ImagePicker();
  final TokenService tokenService = Get.find<TokenService>();

  final Rxn<verification_model.VerificationStatusResponseModel>
  verificationStatusResponse = Rxn<verification_model.VerificationStatusResponseModel>();

  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, ApplyVerificationFieldFileValue> selectedFiles =
      <String, ApplyVerificationFieldFileValue>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVerificationStatus();
  }

  @override
  void onClose() {
    for (final entry in dynamicFieldControllers.entries) {
      final controller = entry.value['controller'] as TextEditingController?;
      controller?.dispose();
    }
    super.onClose();
  }

  verification_model.Data? get verificationData =>
      verificationStatusResponse.value?.data;

  verification_model.LastApplication? get lastApplication =>
      verificationData?.lastApplication;

  bool get isVerified => verificationData?.isVerified == true;
  bool get isPending =>
      (verificationData?.lastApplication?.status ?? '').toLowerCase() ==
      'pending';
  bool get isEligibleToApply =>
      verificationData?.eligible == true && verificationData?.canApply == true;
  bool get isNotEligible => verificationData?.eligible == false;

  Future<void> fetchVerificationStatus() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.verifiedStatusEndPoint,
      );

      if (response.status == Status.completed && response.data != null) {
        final model = verification_model.VerificationStatusResponseModel.fromJson(
          response.data!,
        );
        verificationStatusResponse.value = model;
        _initializeDynamicFields();
      }
    } catch (e, stackTrace) {
      debugPrint('fetchVerificationStatus() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _initializeDynamicFields() {
    for (final entry in dynamicFieldControllers.entries) {
      final oldController = entry.value['controller'] as TextEditingController?;
      oldController?.dispose();
    }

    dynamicFieldControllers.clear();
    selectedFiles.clear();

    final fields = verificationData?.applicationForm?.fields ?? <verification_model.Field>[];
    for (final field in fields) {
      final fieldName = (field.name ?? '').trim();
      if (fieldName.isEmpty) continue;

      dynamicFieldControllers[fieldName] = {
        'controller': TextEditingController(),
        'validation': (field.validation ?? 'nullable').toLowerCase(),
        'type': (field.type ?? 'text').toLowerCase(),
        'instructions': field.instructions ?? '',
      };
    }
  }

  bool isRequiredField(String validation) =>
      validation.toLowerCase() == 'required';

  bool isFileFieldType(String type) {
    final lower = type.toLowerCase();
    return lower == 'file' || lower == 'camera' || lower == 'front_camera';
  }

  Future<void> pickFile(String fieldName, String type) async {
    if (type == 'camera' || type == 'front_camera') {
      await _pickCameraFile(fieldName: fieldName, useFront: type == 'front_camera');
      return;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    if (picked.path == null || picked.path!.trim().isEmpty) return;

    final path = picked.path!;
    final fileName = picked.name;
    final lower = fileName.toLowerCase();
    selectedFiles[fieldName] = ApplyVerificationFieldFileValue(
      file: File(path),
      isImage:
          lower.endsWith('.png') ||
          lower.endsWith('.jpg') ||
          lower.endsWith('.jpeg') ||
          lower.endsWith('.webp'),
      name: fileName,
    );
    selectedFiles.refresh();
  }

  Future<void> _pickCameraFile({
    required String fieldName,
    required bool useFront,
  }) async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      preferredCameraDevice: useFront ? CameraDevice.front : CameraDevice.rear,
    );
    if (picked == null) return;

    selectedFiles[fieldName] = ApplyVerificationFieldFileValue(
      file: File(picked.path),
      isImage: true,
      name: picked.name,
    );
    selectedFiles.refresh();
  }

  void removeSelectedFile(String fieldName) {
    selectedFiles.remove(fieldName);
    selectedFiles.refresh();
  }

  bool validateForm() {
    for (final entry in dynamicFieldControllers.entries) {
      final fieldName = entry.key;
      final validation = entry.value['validation'] as String? ?? 'nullable';
      final type = entry.value['type'] as String? ?? 'text';
      final controller = entry.value['controller'] as TextEditingController?;

      if (!isRequiredField(validation)) continue;

      if (isFileFieldType(type)) {
        if (!selectedFiles.containsKey(fieldName)) {
          ToastHelper().showErrorToast('$fieldName is required');
          return false;
        }
      } else {
        if ((controller?.text ?? '').trim().isEmpty) {
          ToastHelper().showErrorToast('$fieldName is required');
          return false;
        }
      }
    }
    return true;
  }

  Future<void> onSubmitPressed() async {
    if (isSubmitting.value) return;
    if (!validateForm()) return;

    isSubmitting.value = true;
    try {
      final formData = dio.FormData();

      for (final entry in dynamicFieldControllers.entries) {
        final fieldName = entry.key;
        final validation = entry.value['validation'] as String? ?? 'nullable';
        final type = entry.value['type'] as String? ?? 'text';
        final controller = entry.value['controller'] as TextEditingController?;
        final value = controller?.text.trim() ?? '';
        final selectedFile = selectedFiles[fieldName];

        if (isFileFieldType(type)) {
          if (selectedFile != null) {
            formData.files.add(
              MapEntry(
                'fields[$fieldName]',
                await dio.MultipartFile.fromFile(
                  selectedFile.file.path,
                  filename: selectedFile.name,
                ),
              ),
            );
          } else if (!isRequiredField(validation)) {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast('Please upload $fieldName');
            return;
          }
        } else {
          if (value.isNotEmpty) {
            formData.fields.add(MapEntry('fields[$fieldName]', value));
          } else if (!isRequiredField(validation)) {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast('Please fill $fieldName');
            return;
          }
        }
      }

      final response = await dio.Dio().post(
        '${ApiPath.baseUrl}${ApiPath.applyVerificationEndPoint}',
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ToastHelper().showSuccessToast(
          (response.data is Map<String, dynamic>)
              ? (response.data['message'] ?? 'Verification submitted successfully')
              : 'Verification submitted successfully',
        );
        await fetchVerificationStatus();
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final message = e.response?.data?['message'];
        ToastHelper().showErrorToast(
          message is String && message.isNotEmpty
              ? message
              : _defaultErrorText,
        );
      } else {
        ToastHelper().showErrorToast(_defaultErrorText);
      }
    } catch (e, stackTrace) {
      debugPrint('onSubmitPressed() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(_defaultErrorText);
    } finally {
      isSubmitting.value = false;
    }
  }

  String get _defaultErrorText =>
      () {
        final context = Get.context ?? Get.overlayContext ?? Get.key.currentContext;
        if (context == null) return 'Something went wrong';
        return AppLocalizations.of(context)?.allControllerLoadError ??
            'Something went wrong';
      }();
}
