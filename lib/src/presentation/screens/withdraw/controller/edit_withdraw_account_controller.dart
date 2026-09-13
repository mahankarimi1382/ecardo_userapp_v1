import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:ecardo_user/src/presentation/screens/withdraw/model/withdraw_account_model.dart';

class EditWithdrawAccountController extends GetxController {
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  // PAYMENT-FIX (P-1): the manual `tokenService` bearer header was removed —
  // NetworkService's interceptor now attaches Authorization from the same
  // TokenService singleton.
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

      // PAYMENT-FIX (P-1): was a raw `dio.Dio()` POST (no timeout, no
      // 401-refresh, silent failures). Same multipart payload (including the
      // Laravel `_method: put` spoof field) is now routed through
      // NetworkService.postMultipart — timeouts, interceptors and 422 error
      // toasts come from the shared network layer; the Authorization header
      // is attached by its interceptor (same token).
      final response = await Get.find<NetworkService>().postMultipart(
        endpoint: '${ApiPath.withdrawAccountCreateEndpoint}/$accountId',
        data: formData,
      );

      if (response.status == Status.completed) {
        Get.find<WithdrawController>().selectedScreen.value = 1;
        final message = response.data?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          ToastHelper().showSuccessToast(message);
        }
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
