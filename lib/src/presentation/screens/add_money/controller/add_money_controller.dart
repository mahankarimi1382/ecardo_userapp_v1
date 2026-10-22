import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/add_money/model/gateway_methods_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/widgets/web_view_screen.dart';

class AddMoneyController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPaymentLoading = false.obs;
  final RxBool isGatewayMethodsLoading = false.obs;
  final ImagePicker _picker = ImagePicker();
  final Rxn<Map<String, dynamic>> successPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rxn<Map<String, dynamic>> pendingPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  /// v1.0.40 (P-4 pattern): resolve per call — the constructor-time capture
  /// froze the locale at controller creation (language switches left stale
  /// strings) and crashed when no localization context existed yet.
  AppLocalizations? get localization =>
      Get.context == null ? null : AppLocalizations.of(Get.context!);

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
      final code = wallet.value?.code ?? '';
      final response = await Get.find<NetworkService>().get(
        endpoint: code.isNotEmpty
            ? "${ApiPath.getGatewayMethodsEndpoint}?currency=$code"
            : ApiPath.getGatewayMethodsEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final gatewayMethodsModel = GatewayMethodsModel.fromJson(
          response.data!,
        );
        gatewayMethodsList.clear();
        final methods = gatewayMethodsModel.data ?? [];
        if (methods.isNotEmpty) {
          gatewayMethodsList.assignAll(methods);
        } else if (code.isNotEmpty) {
          // Fallback: If no gateways specifically for this currency, fetch all active gateways
          final fallbackResponse = await Get.find<NetworkService>().get(
            endpoint: ApiPath.getGatewayMethodsEndpoint,
          );
          if (fallbackResponse.status == Status.completed && fallbackResponse.data != null) {
            final fallbackModel = GatewayMethodsModel.fromJson(fallbackResponse.data!);
            gatewayMethodsList.assignAll(fallbackModel.data ?? []);
          }
        }
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
          orElse: () => walletsList.isNotEmpty ? walletsList.first : Wallets(),
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
    // v1.0.24: guard against double submission while a request is in flight.
    if (isPaymentLoading.isTrue) return;
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
        // The server answers with ONE of two shapes: {redirect_url} for a
        // hosted/redirect gateway, or {transaction} for a wallet/sandbox
        // gateway. Force-unwrapping ['redirect_url'] threw a TypeError on the
        // second shape AFTER the deposit row had already been created, so the
        // user saw a generic error for a real pending deposit.
        final raw = response.data?["data"];
        final Map<String, dynamic>? payload =
            raw is Map<String, dynamic> ? raw : null;
        final redirectUrl = payload?["redirect_url"]?.toString();

        if (redirectUrl == null || redirectUrl.isEmpty) {
          // No redirect: the deposit exists and is waiting on the gateway.
          pendingPaymentData.value = payload;
          currentStep.value = 2;
          ToastHelper().showSuccessToast(localization!.addMoneySuccess);
        } else {
          final paymentResult = await Get.to<Map<String, dynamic>>(
            () => WebViewScreen(paymentUrl: redirectUrl),
            fullscreenDialog: false,
          );
          if (paymentResult != null && paymentResult['success'] == true) {
            successPaymentData.value = paymentResult['data'];
            currentStep.value = 2;
            AppEventBus.emit(BalanceChangedEvent(sourceModule: 'add_money'));
          } else if (paymentResult == null) {
            // The user backed out of the gateway page without confirmation.
            // Do NOT celebrate as paid. Route to pending status and notify user.
            pendingPaymentData.value = payload;
            currentStep.value = 2;
            ToastHelper().showWarningToast(
              l10nPickAuto(
                en: 'Payment pending gateway confirmation',
                fa: 'پرداخت در انتظار تایید درگاه است',
                ar: 'الدفع بانتظار تأكيد البوابة',
                tr: 'Ödeme ağ geçidi onayını bekliyor',
                ru: 'Платеж ожидает подтверждения',
                zh: '支付等待网关确认',
              ),
            );
          }
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
    // v1.0.24: guard against double submission while a request is in flight.
    if (isPaymentLoading.isTrue) return;
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

      // v1.0.24: was a raw `dio.Dio()` call without timeout/401-refresh —
      // a dead connection kept the spinner on forever. Route through
      // NetworkService.postMultipart (timeouts + interceptors + error toasts).
      final response = await Get.find<NetworkService>().postMultipart(
        endpoint: ApiPath.postAddMoneyEndpoint,
        data: formData,
      );

      if (response.status == Status.completed) {
        pendingPaymentData.value = response.data?['data'];
        currentStep.value = 2;
        AppEventBus.emit(BalanceChangedEvent(sourceModule: 'add_money'));
        ToastHelper().showSuccessToast(localization!.addMoneySuccess);
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
          (double.tryParse((gatewayMethod.value?.charge ?? '0')) ?? 0.0) /
          100);
    } else if (gatewayMethod.value!.chargeType == 'fixed') {
      calculatedCharge.value = (double.tryParse((gatewayMethod.value?.charge ?? '0')) ?? 0.0);
    } else {
      calculatedCharge.value = 0.0;
    }

    totalAmount.value = baseAmount.value + calculatedCharge.value;
  }

  // Validate Amount Step
  bool validateAmountStep() {
    // Validate Wallet
    // phase1-fix (P0-16): no force-unwrap on a failed wallet fetch
    final walletData = wallet.value;
    if (walletData == null || (walletData.name ?? '').isEmpty) {
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

    final isCrypto = wallet.value?.isCrypto ?? false;
    final int decimals = isCrypto ? 8 : 2;

    final minDeposit = double.tryParse(gatewayMethod.value?.minimumDeposit ?? '0') ?? 0.0;
    if (minDeposit > 0 && amount < minDeposit) {
      ToastHelper().showErrorToast(
        localization!.addMoneyValidationAmountMinimum(
          minDeposit.toStringAsFixed(decimals),
        ),
      );
      return false;
    }

    final maxDeposit = double.tryParse(gatewayMethod.value?.maximumDeposit ?? '0') ?? 0.0;
    if (maxDeposit > 0 && amount > maxDeposit) {
      ToastHelper().showErrorToast(
        localization!.addMoneyValidationAmountMaximum(
          maxDeposit.toStringAsFixed(decimals),
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
