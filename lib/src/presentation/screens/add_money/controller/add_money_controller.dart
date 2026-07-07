import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/network/service/token_service.dart';
import 'package:qunzo_user/src/presentation/screens/add_money/model/gateway_methods_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:qunzo_user/src/presentation/widgets/web_view_screen.dart';

class AddMoneyController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPaymentLoading = false.obs;
  final RxBool isGatewayMethodsLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  final TokenService tokenService = Get.find<TokenService>();
  final Rxn<Map<String, dynamic>> successPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> pendingPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!);

  // Wallet
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> walletsList = <Wallets>[].obs;

  // Gateway
  final gatewayController = TextEditingController();
  final Rxn<GatewayMethodsData> gatewayMethod = Rxn<GatewayMethodsData>();
  final RxList<GatewayMethodsData> gatewayMethodsList =
      <GatewayMethodsData>[].obs;
  final RxMap<String, Map<String, dynamic>> dynamicFieldControllers =
      <String, Map<String, dynamic>>{}.obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  // Gateway Focused
  final RxBool isGatewayFocused = false.obs;
  final FocusNode gatewayFocusNode = FocusNode();

  // Stepper
  final RxInt currentStep = 0.obs;

  // Selected Images
  final RxMap<String, File?> selectedImages = <String, File?>{}.obs;

  // Review Amounts
  final RxDouble baseAmount = 0.0.obs;
  final RxDouble calculatedCharge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;

  // Steps
  final List<String> steps = ['Amount', 'Review', 'Success'];

  // Next Step Function
  void nextStepWithValidation() {
    if (currentStep.value == 0) {
      if (!validateAmountStep()) {
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      reviewCalculate();
    } else {
      currentStep.value = 0;
    }
  }

  @override
  void onInit() {
    super.onInit();
    amountFocusNode.addListener(_handleAmountFocusChange);
    gatewayFocusNode.addListener(_handleGatewayFocusChange);
  }

  @override
  void onClose() {
    amountFocusNode.removeListener(_handleAmountFocusChange);
    gatewayFocusNode.removeListener(_handleGatewayFocusChange);
    amountFocusNode.dispose();
    gatewayFocusNode.dispose();
    super.onClose();
  }

  // Amount focus change handler
  void _handleAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

  // Gateway focus change handler
  void _handleGatewayFocusChange() {
    isGatewayFocused.value = gatewayFocusNode.hasFocus;
  }

  // Fetch User
  Future<void> fetchUser() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed) {
        userModel.value = UserModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  // Fetch Wallets
  Future<void> fetchWallets() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsList.assignAll(walletsModel.data?.wallets ?? []);

        if (walletsList.isNotEmpty) {
          wallet.value = walletsList.first;
          gatewayMethod.value = GatewayMethodsData();
          gatewayController.clear();
          await fetchGatewayMethods(isSetUpLoading: false);
        } else {
          wallet.value = null;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {}
  }

  // Fetch Gateway Methods
  Future<void> fetchGatewayMethods({required bool isSetUpLoading}) async {
    isSetUpLoading == true
        ? isGatewayMethodsLoading.value = true
        : isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            "${ApiPath.getGatewayMethodsEndpoint}?currency=${wallet.value!.code}",
      );
      if (response.status == Status.completed) {
        final gatewayMethodsModel = GatewayMethodsModel.fromJson(
          response.data!,
        );
        gatewayMethodsList.clear();
        gatewayMethodsList.assignAll(gatewayMethodsModel.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchGatewayMethods() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isSetUpLoading == true
          ? isGatewayMethodsLoading.value = false
          : isLoading.value = false;
    }
  }

  // Find Wallet
  Future<void> findWallet({required String walletIdQuery}) async {
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.walletsEndpoint,
      );

      if (response.status == Status.completed) {
        final walletsModel = WalletsModel.fromJson(response.data!);
        walletsList.assignAll(walletsModel.data?.wallets ?? []);
        wallet.value = walletsList.firstWhere(
          (w) => w.id.toString() == walletIdQuery,
          orElse: () => Wallets(),
        );
        gatewayMethod.value = GatewayMethodsData();
        gatewayController.clear();
        await fetchGatewayMethods(isSetUpLoading: false);
        await fetchUser();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ findWallet() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Submit Add Money Auto Function
  Future<void> submitAddMoneyAuto() async {
    isPaymentLoading.value = true;

    try {
      final requestBody = {
        'payment_gateway': gatewayMethod.value!.id.toString(),
        'amount': amountController.text,
        'user_wallet': wallet.value!.isDefault == true
            ? "default"
            : wallet.value!.id.toString(),
      };
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.postAddMoneyEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        final String redirectUrl = response.data!["data"]['redirect_url'];
        final paymentResult = await Get.to<Map<String, dynamic>>(
          () => WebViewScreen(paymentUrl: redirectUrl),
          fullscreenDialog: false,
        );
        if (paymentResult != null && paymentResult['success'] == true) {
          successPaymentData.value = paymentResult['data'];
          currentStep.value = 2;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitAddMoneyAuto() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isPaymentLoading.value = false;
    }
  }

  // Submit Add Money Manual Function
  Future<void> submitAddMoneyManual() async {
    isPaymentLoading.value = true;

    try {
      final formData = dio.FormData();

      formData.fields.addAll([
        MapEntry('payment_gateway', gatewayMethod.value!.id.toString()),
        MapEntry('amount', amountController.text),
        MapEntry(
          'user_wallet',
          wallet.value!.isDefault == true
              ? "default"
              : wallet.value!.id.toString(),
        ),
      ]);

      for (var entry in dynamicFieldControllers.entries) {
        final fieldName = entry.key;
        final fieldType = entry.value['type'] as String;

        if (fieldType == 'file') {
          final file = selectedImages[fieldName];
          if (file != null) {
            formData.files.add(
              MapEntry(
                'manual_data[$fieldName]',
                await dio.MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ),
            );
          }
        } else {
          final controller =
              entry.value['controller'] as TextEditingController?;
          final fieldValue = controller?.text ?? '';
          formData.fields.add(MapEntry('manual_data[$fieldName]', fieldValue));
        }
      }

      final response = await dio.Dio().post(
        "${ApiPath.baseUrl}${ApiPath.postAddMoneyEndpoint}",
        data: formData,
        options: dio.Options(
          headers: {
            "Accept": "application/json",
            'Authorization': 'Bearer ${tokenService.accessToken.value}',
          },
        ),
      );

      if (response.statusCode == 200) {
        pendingPaymentData.value = response.data['data'];
        currentStep.value = 2;
        ToastHelper().showSuccessToast(localization!.addMoneySuccess);
      }
    } on dio.DioException catch (e) {
      if (e.response!.statusCode == 422) {
        ToastHelper().showErrorToast(e.response!.data["message"]);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ submitAddMoneyManual() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization!.allControllerLoadError);
    } finally {
      isPaymentLoading.value = false;
    }
  }

  // Review Calculate Function
  void reviewCalculate() {
    baseAmount.value = double.tryParse(amountController.text) ?? 0.0;

    if (gatewayMethod.value!.chargeType == 'percentage') {
      calculatedCharge.value =
          (baseAmount.value *
          double.tryParse(gatewayMethod.value!.charge!)! /
          100);
    } else if (gatewayMethod.value!.chargeType == 'fixed') {
      calculatedCharge.value = double.tryParse(gatewayMethod.value!.charge!)!;
    } else {
      calculatedCharge.value = 0.0;
    }

    totalAmount.value = baseAmount.value + calculatedCharge.value;
  }

  // Validate Amount Step
  bool validateAmountStep() {
    // Validate Wallet
    if (wallet.value!.name!.isEmpty) {
      ToastHelper().showErrorToast(
        localization!.addMoneyValidationSelectWallet,
      );
      return false;
    }

    // Validate Gateway
    if (gatewayController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization!.addMoneyValidationSelectGateway,
      );
      return false;
    }

    // Validate Amount
    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization!.addMoneyValidationEnterAmount);
      return false;
    }

    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) {
      ToastHelper().showErrorToast(
        localization!.addMoneyValidationAmountGreaterThanZero,
      );
      return false;
    }

    if (double.tryParse(gatewayMethod.value!.minimumDeposit!)! > 0 &&
        amount < double.tryParse(gatewayMethod.value!.minimumDeposit!)!) {
      ToastHelper().showErrorToast(
        localization!.addMoneyValidationAmountMinimum(
          double.tryParse(
            gatewayMethod.value!.minimumDeposit!,
          )!.toStringAsFixed(2),
        ),
      );
      return false;
    }

    if (double.tryParse(gatewayMethod.value!.maximumDeposit!)! > 0 &&
        amount > double.tryParse(gatewayMethod.value!.maximumDeposit!)!) {
      ToastHelper().showErrorToast(
        localization!.addMoneyValidationAmountMaximum(
          double.tryParse(
            gatewayMethod.value!.maximumDeposit!,
          )!.toStringAsFixed(2),
        ),
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
              localization!.addMoneyValidationUploadFile(fieldName),
            );
            return false;
          }
        } else if (controller.text.isEmpty) {
          ToastHelper().showErrorToast(
            localization!.addMoneyValidationFillField(fieldName),
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
    successPaymentData.value = null;
    pendingPaymentData.value = null;

    // Gateway
    gatewayMethod.value = GatewayMethodsData();
    gatewayController.clear();
    dynamicFieldControllers.clear();

    // Review Amounts
    baseAmount.value = 0.0;
    calculatedCharge.value = 0.0;
    totalAmount.value = 0.0;

    // Amount
    amountController.clear();
  }
}
