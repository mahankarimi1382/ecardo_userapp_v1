/// کنترلر صفحه درخواست تأیید معامله‌گر P2P
/// درخواست فایل‌ها با image_picker (XFile) و file_picker انجام می‌شود
/// از XFile به جای dart:io File استفاده شده برای سازگاری با وب

import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/apply_verification/model/apply_verification_model.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/apply_verification/model/verification_status_response_model.dart'
    as verification_model;

/// کنترلر مدیریت فرم درخواست تأیید معامله‌گر P2P
/// شامل بارگذاری وضعیت فعلی، فیلدهای داینامیک، انتخاب فایل و ارسال فرم
class ApplyVerificationController extends GetxController {
  /// وضعیت بارگذاری اولیه
  final RxBool isLoading = false.obs;
  /// وضعیت ارسال فرم
  final RxBool isSubmitting = false.obs;

  /// انتخاب‌گر تصویر (دوربین)
  final ImagePicker _picker = ImagePicker();
  /// سرویس توکن برای احراز هویت درخواست‌ها
  final TokenService tokenService = Get.find<TokenService>();

  /// پاسخ وضعیت تأیید فعلی کاربر
  final Rxn<verification_model.VerificationStatusResponseModel>
      verificationStatusResponse =
      Rxn<verification_model.VerificationStatusResponseModel>();

  /// نقشه فیلدهای داینامیک فرم (کنترلر متن + اعتبارسنجی + نوع)
  /// کلید: نام فیلد، مقدار: نقشه شامل controller, validation, type, instructions
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;

  /// نقشه فایل‌های انتخاب‌شده برای فیلدهای فایلی
  /// کلید: نام فیلد، مقدار: اطلاعات فایل (XFile + نام + آیا تصویر است)
  final RxMap<String, ApplyVerificationFieldFileValue> selectedFiles =
      <String, ApplyVerificationFieldFileValue>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchVerificationStatus();
  }

  @override
  void onClose() {
    /// آزادسازی تمام کنترلرهای متن برای جلوگیری از نشت حافظه
    for (final entry in dynamicFieldControllers.entries) {
      final controller = entry.value['controller'] as TextEditingController?;
      controller?.dispose();
    }
    super.onClose();
  }

  /// دسترسی سریع به داده‌های وضعیت تأیید
   verification_model.Data? get verificationData =>
      verificationStatusResponse.value?.data;

  /// آخرین درخواست تأیید کاربر
  verification_model.LastApplication? get lastApplication =>
      verificationData?.lastApplication;

  /// آیا کاربر تأیید شده است
  bool get isVerified => verificationData?.isVerified == true;

  /// آیا درخواست فعلی در وضعیت انتظار است
  bool get isPending =>
      (verificationData?.lastApplication?.status ?? '').toLowerCase() ==
      'pending';

  /// آیا کاربر واجد شرایط ارسال درخواست است
  bool get isEligibleToApply =>
      verificationData?.eligible == true && verificationData?.canApply == true;

  /// آیا کاربر واجد شرایط نیست (رد شده یا محدود شده)
  bool get isNotEligible => verificationData?.eligible == false;

  /// بارگذاری وضعیت تأیید فعلی کاربر از سرور
  Future<void> fetchVerificationStatus() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.verifiedStatusEndPoint,
      );

      if (response.status == Status.completed && response.data != null) {
        final model =
            verification_model.VerificationStatusResponseModel.fromJson(
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

  /// مقداردهی اولیه فیلدهای داینامیک بر اساس فرم دریافتی از سرور
  /// برای هر فیلد یک TextEditingController ایجاد می‌شود
  void _initializeDynamicFields() {
    /// آزادسازی کنترلرهای قبلی
    for (final entry in dynamicFieldControllers.entries) {
      final oldController = entry.value['controller'] as TextEditingController?;
      oldController?.dispose();
    }

    dynamicFieldControllers.clear();
    selectedFiles.clear();

    /// ایجاد کنترلر جدید برای هر فیلد فرم
    final fields =
        verificationData?.applicationForm?.fields ?? <verification_model.Field>[];
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

  /// بررسی آیا فیلد اجباری است
   bool isRequiredField(String validation) =>
      validation.toLowerCase() == 'required';

  /// بررسی آیا نوع فیلد فایلی است (فایل، دوربین، دوربین جلو)
  bool isFileFieldType(String type) {
    final lower = type.toLowerCase();
    return lower == 'file' || lower == 'camera' || lower == 'front_camera';
  }

  /// انتخاب فایل از گالری/فایل منیجر
  /// از FilePicker.platform.pickFiles استفاده شده که در وب و موبایل کار می‌کند
  Future<void> pickFile(String fieldName, String type) async {
    /// اگر نوع دوربین است، از image_picker استفاده شود
    if (type == 'camera' || type == 'front_camera') {
      await _pickCameraFile(
        fieldName: fieldName,
        useFront: type == 'front_camera',
      );
      return;
    }

    /// انتخاب فایل از گالری/فایل منیجر
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
    );
    if (result == null || result.files.isEmpty) return;

    final picked = result.files.first;
    /// در وب، path ممکن است خالی باشد ولی bytes موجود است
    if (picked.path == null || picked.path!.trim().isEmpty) {
      /// در پلتفرم وب از bytes استفاده می‌کنیم
      if (picked.bytes == null) return;
    }

    final fileName = picked.name;
    final lower = fileName.toLowerCase();
    selectedFiles[fieldName] = ApplyVerificationFieldFileValue(
      file: XFile(picked.path ?? '', bytes: picked.bytes, name: fileName),
      isImage: lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp'),
      name: fileName,
    );
    selectedFiles.refresh();
  }

  /// انتخاب تصویر از دوربین
  /// XFile به صورت مستقیم از image_picker برگردانده می‌شود (سازگار با وب)
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
      file: picked,
      isImage: true,
      name: picked.name,
    );
    selectedFiles.refresh();
  }

  /// حذف فایل انتخاب‌شده برای یک فیلد
  void removeSelectedFile(String fieldName) {
    selectedFiles.remove(fieldName);
    selectedFiles.refresh();
  }

  /// اعتبارسنجی فرم: بررسی تمام فیلدهای اجباری
  /// اگر فیلد اجباری خالی باشد، خطا نشان داده و false برمی‌گرداند
  bool validateForm() {
    final localization = AppLocalizations.of(Get.context!);

    for (final entry in dynamicFieldControllers.entries) {
      final fieldName = entry.key;
      final validation = entry.value['validation'] as String? ?? 'nullable';
      final type = entry.value['type'] as String? ?? 'text';
      final controller = entry.value['controller'] as TextEditingController?;

      if (!isRequiredField(validation)) continue;

      if (isFileFieldType(type)) {
        /// فیلدهای فایلی: بررسی انتخاب فایل
        if (!selectedFiles.containsKey(fieldName)) {
          ToastHelper().showErrorToast(
            '${localization?.p2pFieldRequired ?? "$fieldName is required"}',
          );
          return false;
        }
      } else {
        /// فیلدهای متنی: بررسی خالی نبودن
        if ((controller?.text ?? '').trim().isEmpty) {
          ToastHelper().showErrorToast(
            '${localization?.p2pFieldRequired ?? "$fieldName is required"}',
          );
          return false;
        }
      }
    }
    return true;
  }

  /// ارسال فرم درخواست تأیید به سرور
  /// فایل‌ها با MultipartFile و متغیرها به صورت fields ارسال می‌شوند
  /// از XFile.path (موبایل) یا XFile.readAsBytes() (وب) استفاده می‌شود
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
          /// ارسال فایل: از XFile برای سازگاری با وب و موبایل
          if (selectedFile != null) {
            final xFile = selectedFile.file;
            final fileLength = await xFile.length();
            final fileBytes = await xFile.readAsBytes();

            formData.files.add(
              MapEntry(
                'fields[$fieldName]',
                dio.MultipartFile.fromBytes(
                  fileBytes,
                  filename: selectedFile.name,
                  contentType: _contentTypeForFile(selectedFile.name),
                ),
              ),
            );
          } else if (!isRequiredField(validation)) {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast(
              AppLocalizations.of(Get.context!)?.p2pPleaseUpload ?? 'Please upload $fieldName',
            );
            return;
          }
        } else {
          /// ارسال متغیر متنی
          if (value.isNotEmpty) {
            formData.fields.add(MapEntry('fields[$fieldName]', value));
          } else if (!isRequiredField(validation)) {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast(
              AppLocalizations.of(Get.context!)?.p2pPleaseFill ?? 'Please fill $fieldName',
            );
            return;
          }
        }
      }

      /// ارسال فرم به سرور با هدر احراز هویت
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
              ? (response.data['message'] ??
                  AppLocalizations.of(Get.context!)?.p2pVerificationSubmitted ??
                  'Verification submitted successfully')
              : AppLocalizations.of(Get.context!)?.p2pVerificationSubmitted ??
                  'Verification submitted successfully',
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

  /// متن خطای پیش‌فرض با تلاش برای لوکالایزیشن
  String get _defaultErrorText => () {
    final context = Get.context ?? Get.overlayContext ?? Get.key.currentContext;
    if (context == null) return AppLocalizations.of(Get.context!)?.allControllerLoadError ?? 'Something went wrong';
    return AppLocalizations.of(context)?.allControllerLoadError ?? 'Something went wrong';
  }();

  /// تشخیص نوع محتوای فایل بر اساس پسوند
  /// در Dio 5.x از DioMediaType به جای ContentType استفاده شده
  static dio.DioMediaType _contentTypeForFile(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.pdf')) return dio.DioMediaType('application', 'pdf');
    if (lower.endsWith('.png')) return dio.DioMediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) {
      return dio.DioMediaType('image', 'jpeg');
    }
    if (lower.endsWith('.webp')) return dio.DioMediaType('image', 'webp');
    return dio.DioMediaType('application', 'octet-stream');
  }
}
