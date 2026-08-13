/// کنترلر افزودن حساب پرداخت P2P
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
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_method_response_model.dart';

/// کنترلر مدیریت فرم افزودن حساب پرداخت جدید
/// شامل انتخاب روش پرداخت، فیلدهای داینامیک و آپلود تصویر
class AddPaymentMethodController extends GetxController {
  /// وضعیت بارگذاری لیست روش‌های پرداخت
  final RxBool isMethodsLoading = false.obs;
  /// وضعیت ارسال فرم
  final RxBool isSubmitLoading = false.obs;

  /// سرویس توکن برای احراز هویت
  final TokenService tokenService = Get.find<TokenService>();
  /// انتخاب‌گر تصویر
  final ImagePicker _picker = ImagePicker();

  /// وضعیت فوکوس فیلد انتخاب روش پرداخت
  final RxBool isPaymentMethodFocused = false.obs;
  final FocusNode paymentMethodFocusNode = FocusNode();
  final TextEditingController paymentMethodController = TextEditingController();

  /// روش پرداخت انتخاب‌شده
  final Rxn<PaymentMethod> selectedPaymentMethod = Rxn<PaymentMethod>();
  /// لیست روش‌های پرداخت موجود
  final RxList<PaymentMethod> paymentMethodList = <PaymentMethod>[].obs;

  /// فیلدهای داینامیک فرم (کنترلر متن + اعتبارسنجی + نوع)
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;

  /// تصاویر انتخاب‌شده برای فیلدهای فایلی
  /// از XFile به جای dart:io File استفاده شده برای سازگاری وب
  final RxMap<String, XFile?> selectedImages = <String, XFile?>{}.obs;

  @override
  void onInit() {
    super.onInit();
    paymentMethodFocusNode.addListener(() {
      isPaymentMethodFocused.value = paymentMethodFocusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    paymentMethodFocusNode.dispose();
    paymentMethodController.dispose();
    /// آزادسازی تمام کنترلرهای متن
    for (final entry in dynamicFieldControllers.entries) {
      final controller = entry.value['controller'] as TextEditingController?;
      controller?.dispose();
    }
    super.onClose();
  }

  /// بارگذاری لیست روش‌های پرداخت از سرور
  Future<void> fetchPaymentMethods() async {
    isMethodsLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.paymentMethodEndpoint,
      );
      if (response.status == Status.completed) {
        final model = PaymentMethodResponseModel.fromJson(response.data!);
        paymentMethodList.clear();
        paymentMethodList.assignAll(model.data?.paymentMethods ?? []);
      }
    } catch (e, stackTrace) {
      debugPrint('fetchPaymentMethods() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(_defaultErrorText);
    } finally {
      isMethodsLoading.value = false;
    }
  }

  /// انتخاب یک روش پرداخت و مقداردهی فیلدهای داینامیک آن
  void onPaymentMethodSelected(PaymentMethod method) {
    selectedPaymentMethod.value = method;
    paymentMethodController.text = method.name ?? '';
    dynamicFieldControllers.clear();
    selectedImages.clear();

    /// ایجاد کنترلر متن برای هر فیلد داینامیک
    for (final field in method.fields ?? <Field>[]) {
      dynamicFieldControllers[field.name ?? ''] = {
        'controller': TextEditingController(),
        'validation': field.validation ?? 'nullable',
        'type': field.type ?? 'text',
      };
    }
  }

  /// اعتبارسنجی فیلدهای فرم قبل از ارسال
  bool validateFields() {
    if (selectedPaymentMethod.value == null) {
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)?.p2pSelectPaymentMethod ??
            'Please select a payment method',
      );
      return false;
    }

    for (final entry in dynamicFieldControllers.entries) {
      final fieldName = entry.key;
      final validation = entry.value['validation'] as String? ?? 'nullable';
      final type = entry.value['type'] as String? ?? 'text';
      final controller = entry.value['controller'] as TextEditingController?;

      if (validation == 'required') {
        if (type == 'file') {
          if (selectedImages[fieldName] == null) {
            ToastHelper().showErrorToast(
              AppLocalizations.of(Get.context!)?.p2pPleaseUpload ??
                  'Please upload $fieldName',
            );
            return false;
          }
        } else if ((controller?.text.trim() ?? '').isEmpty) {
          ToastHelper().showErrorToast(
            AppLocalizations.of(Get.context!)?.p2pPleaseFill ??
                'Please fill $fieldName',
          );
          return false;
        }
      }
    }

    return true;
  }

  /// ارسال فرم ایجاد حساب پرداخت جدید به سرور
  /// فایل‌ها با fromBytes برای سازگاری وب ارسال می‌شوند
  Future<void> createPaymentAccount() async {
    if (!validateFields()) return;

    isSubmitLoading.value = true;
    try {
      final formData = dio.FormData();
      formData.fields.add(
        MapEntry(
          'payment_method_id',
          selectedPaymentMethod.value!.id.toString(),
        ),
      );

      for (final entry in dynamicFieldControllers.entries) {
        final fieldName = entry.key;
        final fieldType = entry.value['type'] as String? ?? 'text';
        final fieldValidation =
            entry.value['validation'] as String? ?? 'nullable';
        final controller =
            entry.value['controller'] as TextEditingController?;
        final fieldValue = controller?.text.trim() ?? '';
        final xFile = selectedImages[fieldName];

        if (fieldType == 'file') {
          /// ارسال فایل با bytes برای سازگاری وب و موبایل
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
          } else if (fieldValidation == 'nullable') {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast(
              AppLocalizations.of(Get.context!)?.p2pPleaseUpload ??
                  'Please upload $fieldName',
            );
            isSubmitLoading.value = false;
            return;
          }
        } else {
          if (fieldValue.isNotEmpty) {
            formData.fields.add(MapEntry('fields[$fieldName]', fieldValue));
          } else if (fieldValidation == 'nullable') {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast(
              AppLocalizations.of(Get.context!)?.p2pPleaseFill ??
                  'Please fill $fieldName',
            );
            isSubmitLoading.value = false;
            return;
          }
        }
      }

      final response = await dio.Dio().post(
        '${ApiPath.baseUrl}${ApiPath.paymentAccountEndpoint}',
        data: formData,
        options: dio.Options(
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        ToastHelper().showSuccessToast(response.data['message']);
        clearFields();
        await Get.find<PaymentAccountController>().onAddSuccess();
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 422) {
        ToastHelper().showErrorToast(e.response?.data['message']);
      }
    } catch (e, stackTrace) {
      debugPrint('createPaymentAccount() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(_defaultErrorText);
    } finally {
      isSubmitLoading.value = false;
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

  /// پاک‌سازی تمام فیلدها و بازنشانی فرم
  void clearFields() {
    paymentMethodController.clear();
    selectedPaymentMethod.value = null;
    dynamicFieldControllers.clear();
    selectedImages.clear();
    isPaymentMethodFocused.value = false;
  }

  /// متن خطای پیش‌فرض
  String get _defaultErrorText => () {
    final context = Get.context ?? Get.overlayContext ?? Get.key.currentContext;
    if (context == null) return AppLocalizations.of(Get.context!)?.allControllerLoadError ?? 'Something went wrong';
    return AppLocalizations.of(context)?.allControllerLoadError ?? 'Something went wrong';
  }();

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
