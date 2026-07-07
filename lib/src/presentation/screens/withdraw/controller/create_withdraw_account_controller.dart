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
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/controller/withdraw_controller.dart';
import 'package:qunzo_user/src/presentation/screens/withdraw/model/withdraw_method_model.dart';

class CreateWithdrawAccountController extends GetxController {
  // Global Variables
  final RxBool isLoading = false.obs;
  final RxBool isWithdrawMethodsLoading = false.obs;
  final RxBool isCreateWithdrawAccountLoading = false.obs;
  final TokenService tokenService = Get.find<TokenService>();
  final ImagePicker _picker = ImagePicker();
  final localization = AppLocalizations.of(Get.context!)!;

  // Wallet
  final RxBool isWalletFocused = false.obs;
  final FocusNode walletFocusNode = FocusNode();
  final walletController = TextEditingController();
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> walletsList = <Wallets>[].obs;

  // Withdraw Method
  final RxBool isWithdrawMethodFocused = false.obs;
  final FocusNode withdrawMethodFocusNode = FocusNode();
  final withdrawMethodController = TextEditingController();
  final Rxn<WithdrawMethodData> withdrawMethod = Rxn<WithdrawMethodData>();
  final RxList<WithdrawMethodData> withdrawMethodList =
      <WithdrawMethodData>[].obs;
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;

  // Method Name
  final RxBool isMethodNameFocused = false.obs;
  final FocusNode methodNameFocusNode = FocusNode();
  final RxString methodName = "".obs;
  final methodNameController = TextEditingController();

  // Selected Images
  final RxMap<String, File?> selectedImages = <String, File?>{}.obs;

  @override
  void onInit() {
    walletFocusNode.addListener(() {
      isWalletFocused.value = walletFocusNode.hasFocus;
    });
    withdrawMethodFocusNode.addListener(() {
      isWithdrawMethodFocused.value = withdrawMethodFocusNode.hasFocus;
    });
    methodNameFocusNode.addListener(() {
      isMethodNameFocused.value = methodNameFocusNode.hasFocus;
    });
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
    walletFocusNode.dispose();
    walletController.dispose();
    withdrawMethodFocusNode.dispose();
    withdrawMethodController.dispose();
    methodNameFocusNode.dispose();
    methodNameController.dispose();
  }

  // Fetch Wallets
  Future<void> fetchWallets() async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsList.clear();
        walletsList.value = walletsModel.data!.wallets ?? [];
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch Withdraw Methods
  Future<void> fetchWithdrawMethods() async {
    isWithdrawMethodsLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            "${ApiPath.withdrawMethodsEndpoint}?currency=${wallet.value!.isDefault! ? "default" : wallet.value!.id.toString()}",
      );
      if (response.status == Status.completed) {
        final withdrawMethodModel = WithdrawMethodModel.fromJson(
          response.data!,
        );
        withdrawMethodList.clear();
        withdrawMethodList.assignAll(withdrawMethodModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWithdrawMethods() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isWithdrawMethodsLoading.value = false;
    }
  }

  // Create Withdraw Account Function
  Future<void> createWithdrawAccount() async {
    if (!validateFields()) return;

    isCreateWithdrawAccountLoading.value = true;

    try {
      final formData = dio.FormData();

      formData.fields.addAll([
        MapEntry(
          'wallet_id',
          wallet.value!.isDefault! ? "default" : wallet.value!.id.toString(),
        ),
        MapEntry('method_name', methodName.value),
        MapEntry('withdraw_method_id', withdrawMethod.value!.id.toString()),
      ]);

      for (var entry in dynamicFieldControllers.entries) {
        final fieldName = entry.key;
        final fieldType = entry.value['type'] as String;
        final fieldValidation = entry.value['validation'] as String;
        final controller = entry.value['controller'] as TextEditingController?;
        final fieldValue = controller?.text.trim() ?? '';
        final file = selectedImages[fieldName];

        formData.fields.add(
          MapEntry('credentials[$fieldName][type]', fieldType),
        );
        formData.fields.add(
          MapEntry('credentials[$fieldName][validation]', fieldValidation),
        );

        if (fieldType == 'file') {
          if (file != null) {
            formData.files.add(
              MapEntry(
                'credentials[$fieldName][value]',
                await dio.MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ),
            );
          } else {
            if (fieldValidation == 'nullable') {
              formData.fields.add(
                MapEntry('credentials[$fieldName][value]', 'null'),
              );
            } else {
              ToastHelper().showErrorToast(
                localization.createWithdrawAccountFileRequiredError(fieldName),
              );
              isCreateWithdrawAccountLoading.value = false;
              return;
            }
          }
        } else {
          if (fieldValue.isNotEmpty) {
            formData.fields.add(
              MapEntry('credentials[$fieldName][value]', fieldValue),
            );
          } else if (fieldValidation == 'nullable') {
            formData.fields.add(
              MapEntry('credentials[$fieldName][value]', 'null'),
            );
          } else {
            ToastHelper().showErrorToast(
              localization.createWithdrawAccountFieldRequiredError(fieldName),
            );
            isCreateWithdrawAccountLoading.value = false;
            return;
          }
        }
      }

      final response = await dio.Dio().post(
        "${ApiPath.baseUrl}${ApiPath.withdrawAccountCreateEndpoint}",
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
        clearFields();
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 422) {
        ToastHelper().showErrorToast(e.response?.data["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ createWithdrawAccount() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isCreateWithdrawAccountLoading.value = false;
    }
  }

  // Validate Fields
  bool validateFields() {
    // Validate Wallet
    if (walletController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.createWithdrawAccountValidationSelectWallet,
      );
      return false;
    }

    // Validate Withdraw Method
    if (withdrawMethodController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.createWithdrawAccountValidationSelectWithdrawMethod,
      );
      return false;
    }

    // Method Name
    if (methodName.value.isEmpty) {
      ToastHelper().showErrorToast(
        localization.createWithdrawAccountValidationEnterMethodName,
      );
      return false;
    }

    // Validate Dynamic Fields
    for (var entry in dynamicFieldControllers.entries) {
      final fieldName = entry.key;
      final fieldData = entry.value;
      final validation = fieldData['validation'] as String;
      final controller = fieldData['controller'] as TextEditingController;

      if (validation == 'required') {
        if (fieldData['type'] == 'file') {
          if (!selectedImages.containsKey(fieldName)) {
            ToastHelper().showErrorToast(
              localization.createWithdrawAccountValidationUploadFile(fieldName),
            );
            return false;
          }
        } else if (controller.text.isEmpty) {
          ToastHelper().showErrorToast(
            localization.createWithdrawAccountValidationFillField(fieldName),
          );
          return false;
        }
      }
    }

    return true;
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

  void clearFields() {
    wallet.value = Wallets();
    walletController.clear();
    walletsList.clear();
    withdrawMethod.value = WithdrawMethodData();
    withdrawMethodController.clear();
    withdrawMethodList.clear();
    dynamicFieldControllers.clear();
    methodNameController.clear();
    methodName.value == "";
    selectedImages.clear();
    isWalletFocused.value = false;
    isWithdrawMethodFocused.value = false;
    isMethodNameFocused.value = false;
  }
}
