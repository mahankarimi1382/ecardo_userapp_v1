/// کنترلر ویرایش حساب پرداخت P2P
/// از XFile به جای dart:io File استفاده شده برای سازگاری با وب

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';

import 'payment_account_controller.dart';

/// کنترلر ویرایش حساب پرداخت موجود
/// فیلدهای داینامیک بارگذاری و قابل ویرایش هستند
/// فایل‌ها با fromBytes برای سازگاری وب ارسال می‌شوند
class EditPaymentAccountController extends GetxController {
  /// وضعیت بارگذاری/ارسال
  final RxBool isLoading = false.obs;
  /// انتخاب‌گر تصویر
  final ImagePicker _picker = ImagePicker();
  /// سرویس توکن برای احراز هویت
  final TokenService tokenService = Get.find<TokenService>();

  /// فیلدهای داینامیک فرم (کنترلر متن + اعتبارسنجی + نوع + مقدار موجود)
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;

  /// تصاویر انتخاب‌شده جدید برای فیلدهای فایلی
  /// از XFile به جای dart:io File استفاده شده
  final RxMap<String, XFile?> selectedImages = <String, XFile?>{}.obs;

  /// مقداردهی اولیه فیلدها بر اساس داده‌های حساب موجود
  void initializeFields(PaymentAccount account) {
    dynamicFieldControllers.clear();
    selectedImages.clear();

    if (account.fields != null) {
      for (final field in account.fields!) {
        final controller = TextEditingController();
        /// پیش‌بارگذاری مقدار موجود (فقط فیلدهای متنی)
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

  /// ارسال فرم ویرایش حساب پرداخت به سرور
  /// از _method=put برای شبیه‌سازی PUT در لاراول استفاده می‌شود
  Future<void> updatePaymentAccount({required String accountId}) async {
    isLoading.value = true;

    try {
      final formData = dio.FormData();
      formData.fields.add(const MapEntry('_method', 'put'));

      for (final entry in dynamicFieldControllers.entries) {
        final fieldName = entry.key;
        final fieldType = entry.value['type'] as String;
        final controller =
            entry.value['controller'] as TextEditingController?;
        final fieldValue = controller?.text ?? '';
        final existingValue = entry.value['value'] as String? ?? '';
        final xFile = selectedImages[fieldName];

        if (fieldType == 'file') {
          /// اگر فایل جدیدی انتخاب شده، آن را آپلود کن
          if (xFile != null) {
            final fileBytes = await xFile.readAsBytes();
            formData.files.add(
              MapEntry(
                'fields[$fieldName]',
                dio.MultipartFile.fromBytes(
                  fileBytes,
                  filename: xFile.name,
                  contentType: _contentTypeForFile(xFile.name),
                ),
              ),
            );
          } else {
            /// اگر فایل جدیدی انتخاب نشده، مقدار موجود را حفظ کن
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

  /// انتخاب تصویر با image_picker
  /// XFile ذخیره می‌شود (سازگار با وب و موبایل)
  Future<void> pickImage(String fieldName, ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      selectedImages[fieldName] = pickedImage;
    }
  }

  /// تشخیص نوع محتوای فایل بر اساس پسوند
  static dio.ContentType _contentTypeForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return dio.ContentType('application', 'pdf');
    if (lower.endsWith('.png')) return dio.ContentType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return dio.ContentType('image', 'jpeg');
    if (lower.endsWith('.webp')) return dio.ContentType('image', 'webp');
    return dio.ContentType('application', 'octet-stream');
  }
}
