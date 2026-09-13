/// کنترلر ویرایش حساب پرداخت P2P
/// از XFile به جای dart:io File استفاده شده برای سازگاری با وب

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
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
  // PAYMENT-FIX (P-1): the manual `tokenService` bearer header was removed —
  // NetworkService's interceptor now attaches Authorization from the same
  // TokenService singleton.

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

      // PAYMENT-FIX (P-1): was a raw `dio.Dio()` POST (no timeout, no
      // 401-refresh, silent failures). Same multipart payload (including the
      // Laravel `_method: put` spoof field) is now routed through
      // NetworkService.postMultipart — timeouts, interceptors and 422 error
      // toasts come from the shared network layer; the Authorization header
      // is attached by its interceptor (same token).
      final response = await Get.find<NetworkService>().postMultipart(
        endpoint: '${ApiPath.paymentAccountEndpoint}/$accountId',
        data: formData,
      );

      if (response.status == Status.completed) {
        await Get.find<PaymentAccountController>().onEditSuccess();
        final message = response.data?['message']?.toString();
        if (message != null && message.isNotEmpty) {
          ToastHelper().showSuccessToast(message);
        }
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
  /// در Dio 5.x از DioMediaType به جای ContentType استفاده شده
  static dio.DioMediaType _contentTypeForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return dio.DioMediaType('application', 'pdf');
    if (lower.endsWith('.png')) return dio.DioMediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return dio.DioMediaType('image', 'jpeg');
    if (lower.endsWith('.webp')) return dio.DioMediaType('image', 'webp');
    return dio.DioMediaType('application', 'octet-stream');
  }
}
