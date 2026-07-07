import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class EditWithdrawAccountController extends GetxController {
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  final TokenService tokenService = Get.find<TokenService>();
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, File?> selectedImages = <String, File?>{}.obs;

  // Method Name
  final RxBool isMethodNameFocused = false.obs;
  final FocusNode methodNameFocusNode = FocusNode();
  final methodNameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    methodNameFocusNode.addListener(() {
      isMethodNameFocused.value = methodNameFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    super.onClose();
    methodNameFocusNode.dispose();
    methodNameController.dispose();
  }

  void initializeFields(Accounts account) {
    methodNameController.text = account.methodName ?? "";
    dynamicFieldControllers.clear();
    selectedImages.clear();

    if (account.method?.fields != null) {
      for (var field in account.method!.fields!) {
        final controller = TextEditingController();

        if (field.value != null && field.value!.isNotEmpty) {
          if (field.type == 'file') {
          } else {
            controller.text = field.value!;
          }
        }

        dynamicFieldControllers[field.name ?? ''] = {
          'controller': controller,
          'validation': field.validation ?? 'nullable',
          'type': field.type ?? 'text',
          'value': field.value ?? '',
        };
      }
    }
  }

  // Update Withdraw Account
  Future<void> updateWithdrawAccount({required String accountId}) async {
    isLoading.value = true;

    try {
      final formData = dio.FormData();

      // Base fields
      formData.fields.addAll([
        MapEntry('method_name', methodNameController.text),
        MapEntry('_method', "put"),
      ]);

      for (var entry in dynamicFieldControllers.entries) {
        final fieldName = entry.key;
        final fieldType = entry.value['type'] as String;
        final fieldValidation = entry.value['validation'] as String;
        final controller = entry.value['controller'] as TextEditingController?;
        final fieldValue = controller?.text ?? '';
        final existingValue = entry.value['value'] as String? ?? '';
        final file = selectedImages[fieldName];

        if (fieldType == "file") {
          if (file != null) {
            formData.files.add(
              MapEntry(
                "credentials[$fieldName][value]",
                await dio.MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split("/").last,
                ),
              ),
            );

            formData.fields.addAll([
              MapEntry("credentials[$fieldName][name]", fieldName),
              MapEntry("credentials[$fieldName][type]", fieldType),
              MapEntry("credentials[$fieldName][validation]", fieldValidation),
            ]);
          } else {
            String finalValue = existingValue;
            if (finalValue.contains('public/')) {
              final uri = Uri.parse(finalValue);
              finalValue = uri.path.replaceFirst('/public', '');
            }

            formData.fields.addAll([
              MapEntry("credentials[$fieldName][name]", fieldName),
              MapEntry("credentials[$fieldName][type]", fieldType),
              MapEntry("credentials[$fieldName][validation]", fieldValidation),
              MapEntry("credentials[$fieldName][value]", finalValue),
            ]);
          }
        } else {
          formData.fields.addAll([
            MapEntry("credentials[$fieldName][name]", fieldName),
            MapEntry("credentials[$fieldName][type]", fieldType),
            MapEntry("credentials[$fieldName][validation]", fieldValidation),
            MapEntry("credentials[$fieldName][value]", fieldValue),
          ]);
        }
      }

      final response = await dio.Dio().post(
        "${ApiPath.baseUrl}${ApiPath.withdrawAccountCreateEndpoint}/$accountId",
        data: formData,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        Get.find<WithdrawController>().selectedScreen.value = 1;
        ToastHelper().showSuccessToast(response.data["message"]);
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 422) {
        ToastHelper().showErrorToast(e.response?.data["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ updateWithdrawAccount() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Pick Image Function
  Future<void> pickImage(String fieldName, ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (pickedImage != null) {
        selectedImages[fieldName] = File(pickedImage.path);
      }
    } finally {}
  }
}
