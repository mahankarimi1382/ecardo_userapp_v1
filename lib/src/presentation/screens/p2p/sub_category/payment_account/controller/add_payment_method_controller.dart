import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/controller/payment_account_controller.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_method_response_model.dart';

class AddPaymentMethodController extends GetxController {
  final RxBool isMethodsLoading = false.obs;
  final RxBool isSubmitLoading = false.obs;
  final TokenService tokenService = Get.find<TokenService>();
  final ImagePicker _picker = ImagePicker();

  final RxBool isPaymentMethodFocused = false.obs;
  final FocusNode paymentMethodFocusNode = FocusNode();
  final TextEditingController paymentMethodController = TextEditingController();

  final Rxn<PaymentMethod> selectedPaymentMethod = Rxn<PaymentMethod>();
  final RxList<PaymentMethod> paymentMethodList = <PaymentMethod>[].obs;
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, File?> selectedImages = <String, File?>{}.obs;

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
    for (final entry in dynamicFieldControllers.entries) {
      final controller = entry.value['controller'] as TextEditingController?;
      controller?.dispose();
    }
    super.onClose();
  }

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

  void onPaymentMethodSelected(PaymentMethod method) {
    selectedPaymentMethod.value = method;
    paymentMethodController.text = method.name ?? '';
    dynamicFieldControllers.clear();
    selectedImages.clear();

    for (final field in method.fields ?? <Field>[]) {
      dynamicFieldControllers[field.name ?? ''] = {
        'controller': TextEditingController(),
        'validation': field.validation ?? 'nullable',
        'type': field.type ?? 'text',
      };
    }
  }

  bool validateFields() {
    if (selectedPaymentMethod.value == null) {
      ToastHelper().showErrorToast('Please select a payment method');
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
            ToastHelper().showErrorToast('Please upload $fieldName');
            return false;
          }
        } else if ((controller?.text.trim() ?? '').isEmpty) {
          ToastHelper().showErrorToast('Please fill $fieldName');
          return false;
        }
      }
    }

    return true;
  }

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
        final controller = entry.value['controller'] as TextEditingController?;
        final fieldValue = controller?.text.trim() ?? '';
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
          } else if (fieldValidation == 'nullable') {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast('Please upload $fieldName');
            isSubmitLoading.value = false;
            return;
          }
        } else {
          if (fieldValue.isNotEmpty) {
            formData.fields.add(MapEntry('fields[$fieldName]', fieldValue));
          } else if (fieldValidation == 'nullable') {
            formData.fields.add(MapEntry('fields[$fieldName]', 'null'));
          } else {
            ToastHelper().showErrorToast('Please fill $fieldName');
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

  Future<void> pickImage(String fieldName, ImageSource source) async {
    final XFile? pickedImage = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      selectedImages[fieldName] = File(pickedImage.path);
    }
  }

  void clearFields() {
    paymentMethodController.clear();
    selectedPaymentMethod.value = null;
    dynamicFieldControllers.clear();
    selectedImages.clear();
    isPaymentMethodFocused.value = false;
  }

  String get _defaultErrorText =>
      () {
        final context =
            Get.context ?? Get.overlayContext ?? Get.key.currentContext;
        if (context == null) return 'Something went wrong';
        return AppLocalizations.of(context)?.allControllerLoadError ??
            'Something went wrong';
      }();
}
