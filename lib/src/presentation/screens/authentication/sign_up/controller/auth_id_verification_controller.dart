import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/upload_helper.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/model/user_kyc_model.dart';

class AuthIdVerificationController extends GetxController {
  // P-4 pattern: null-safe localization (mirrors app_update_controller).
  AppLocalizations? get localizationOrNull {
    final ctx = Get.context;
    if (ctx == null || !ctx.mounted) return null;
    return AppLocalizations.of(ctx);
  }

  // Global Variable
  final RxBool isLoading = false.obs;
  final RxInt currentFieldIndex = 0.obs;
  final RxString kycId = "".obs;
  final RxList<Fields> fields = <Fields>[].obs;
  RxSet<String> skippedFields = <String>{}.obs;
  RxMap<String, File?> fieldFiles = <String, File?>{}.obs;

  void skipField(String fieldName) {
    skippedFields.add(fieldName);
  }

  bool isFieldProcessed(String fieldName) {
    Fields? field = fields.firstWhereOrNull((f) => f.name == fieldName);
    if (field == null) return false;

    if (field.validation == "required") {
      return fieldFiles[fieldName] != null;
    }

    return fieldFiles[fieldName] != null || skippedFields.contains(fieldName);
  }

  // Pick File
  Future<File?> pickFile(String fieldName) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        fieldFiles[fieldName] = file;
        return file;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Submit ID Verification
  Future<void> submitIdVerification() async {
    isLoading.value = true;
    try {
      final formData = dio.FormData();
      formData.fields.add(MapEntry('kyc_id', kycId.value));

      for (var field in fields) {
        final fieldName = field.name ?? "";
        final file = fieldFiles[fieldName];

        if (file != null) {
          if (UploadHelper.exceedsSize(file, UploadHelper.maxKycDocBytes)) {
            isLoading.value = false;
            ToastHelper().showErrorToast(
              l10nPickAuto(
                en: 'File size must not exceed 20MB',
                fa: 'حجم فایل نباید بیشتر از ۲۰ مگابایت باشد',
              ),
            );
            return;
          }
          formData.files.add(
            MapEntry(
              "fields[$fieldName]",
              await UploadHelper.createMultipartFile(file),
            ),
          );
        }
      }

      // Route through NetworkService.postMultipart (timeouts + interceptors + error toasts).
      final response = await Get.find<NetworkService>().postMultipart(
        endpoint: ApiPath.userKycEndpoint,
        data: formData,
      );

      if (response.status == Status.completed) {
        resetFields();
        Get.toNamed(
          BaseRoute.signUpStatus,
          arguments: {"is_id_verification": true},
        );
        ToastHelper().showSuccessToast(response.data!["message"]);
      } else if (response.status == Status.error) {
        final msg = response.message ??
            localizationOrNull?.allControllerLoadError ??
            l10nPickAuto(
              en: 'Something went wrong. Please try again.',
              fa: 'خطایی رخ داد. دوباره تلاش کنید.',
            );
        ToastHelper().showErrorToast(msg);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitIdVerification() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ?? l10nPickAuto(en: 'Something went wrong. Please try again.', fa: 'خطایی رخ داد. دوباره تلاش کنید.'),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Reset Fields
  void resetFields() {
    currentFieldIndex.value = 0;
    fields.clear();
    fieldFiles.clear();
    skippedFields.clear();
    kycId.value = "";
  }
}
