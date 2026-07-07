import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/app/routes/routes.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/authentication/sign_up/model/user_kyc_model.dart';

class AuthIdVerificationController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxInt currentFieldIndex = 0.obs;
  final RxString kycId = "".obs;
  final RxList<Fields> fields = <Fields>[].obs;
  RxSet<String> skippedFields = <String>{}.obs;
  RxMap<String, File?> fieldFiles = <String, File?>{}.obs;
  final TokenService tokenService = Get.find<TokenService>();

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
          formData.files.add(
            MapEntry(
              "fields[$fieldName]",
              await dio.MultipartFile.fromFile(
                file.path,
                filename: file.path.split("/").last,
              ),
            ),
          );
        }
      }

      final response = await dio.Dio().post(
        "${ApiPath.baseUrl}${ApiPath.userKycEndpoint}",
        data: formData,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        resetFields();
        Get.toNamed(
          BaseRoute.signUpStatus,
          arguments: {"is_id_verification": true},
        );
        ToastHelper().showSuccessToast(response.data["message"]);
      }
    } on dio.DioException catch (e) {
      if (e.response!.statusCode == 422) {
        ToastHelper().showErrorToast(e.response!.data["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitIdVerification() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
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
