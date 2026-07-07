import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';

import 'payment_account_controller.dart';

class EditPaymentAccountController extends GetxController {
  final RxBool isLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  final TokenService tokenService = Get.find<TokenService>();
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, File?> selectedImages = <String, File?>{}.obs;
  void initializeFields(PaymentAccount account) {
    dynamicFieldControllers.clear();
    selectedImages.clear();

    if (account.fields != null) {
      for (final field in account.fields!) {
        final controller = TextEditingController();
        if (field.value != null &&
            field.value!.isNotEmpty &&
            field.type != 'file') {
          controller.text = field.value!;
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

  Future<void> updatePaymentAccount({required String accountId}) async {
    isLoading.value = true;

    try {
      final formData = dio.FormData();
      formData.fields.add(const MapEntry('_method', 'put'));

      for (final entry in dynamicFieldControllers.entries) {
        final fieldName = entry.key;
        final fieldType = entry.value['type'] as String;
        final controller = entry.value['controller'] as TextEditingController?;
        final fieldValue = controller?.text ?? '';
        final existingValue = entry.value['value'] as String? ?? '';
        final file = selectedImages[fieldName];
        if (fieldType == 'file') {
          if (file != null) {
            formData.files.add(
              MapEntry(
                'fields[$fieldName]',
                await dio.MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ),
            );
          } else {
            String finalValue = existingValue;
            if (finalValue.contains('public/')) {
              final uri = Uri.parse(finalValue);
              finalValue = uri.path.replaceFirst('/public', '');
            }

            formData.fields.addAll([
              MapEntry('fields[$fieldName]', finalValue),
            ]);
          }
        } else {
          formData.fields.addAll([MapEntry('fields[$fieldName]', fieldValue)]);
        }
      }

      final response = await dio.Dio().post(
        '${ApiPath.baseUrl}${ApiPath.paymentAccountEndpoint}/$accountId',
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        await Get.find<PaymentAccountController>().onEditSuccess();
        ToastHelper().showSuccessToast(response.data['message']);
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 422) {
        ToastHelper().showErrorToast(e.response?.data['message']);
      }
    } catch (e, stackTrace) {
      debugPrint('updatePaymentAccount() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(String fieldName, ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      selectedImages[fieldName] = File(pickedImage.path);
    }
  }
}
