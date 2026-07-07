import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/beneficiary_model.dart';
import 'package:qunzo_user/src/common/model/converter_model.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/model/payment_settings_model.dart';
import 'package:qunzo_user/src/presentation/screens/make_payment/model/payment_wallet_model.dart';

class MakePaymentController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isPaymentSettingsLoading = false.obs;
  final RxBool isMakePaymentLoading = false.obs;
  final RxBool isBeneficiaryLoading = false.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final Rx<PaymentSettingsModel> paymentSettings = PaymentSettingsModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rx<BeneficiaryModel> beneficiaryModel = BeneficiaryModel().obs;
  final Rxn<Map<String, dynamic>> successPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // Wallet
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> paymentWalletsList = <Wallets>[].obs;

  // Stepper
  final RxInt currentStep = 0.obs;

  // Merchant MID
  final RxBool isMerchantFocused = false.obs;
  final FocusNode merchantFocusNode = FocusNode();
  final merchantMidController = TextEditingController();

  // Amount
  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  // Steps
  final List<String> steps = ['Amount', 'Review', 'Success'];

  @override
  void onInit() {
    super.onInit();
    merchantFocusNode.addListener(_handleMerchantFocusChange);
    amountFocusNode.addListener(_handleAmountFocusChange);
  }

  @override
  void onClose() {
    merchantFocusNode.removeListener(_handleMerchantFocusChange);
    amountFocusNode.removeListener(_handleAmountFocusChange);
    merchantFocusNode.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }

  // Merchant focus change handler
  void _handleMerchantFocusChange() {
    isMerchantFocused.value = merchantFocusNode.hasFocus;
  }

  // Amount focus change handler
  void _handleAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

  // Next Step Function
  Future<void> nextStepWithValidation() async {
    if (currentStep.value == 0) {
      if (!validateAmountStep()) {
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      await fetchPaymentSettings();
    } else {
      currentStep.value = 0;
    }
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
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Fetch Payment Settings
  Future<void> fetchPaymentSettings() async {
    isPaymentSettingsLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.paymentSettingsEndpoint,
      );

      if (response.status == Status.completed) {
        paymentSettings.value = PaymentSettingsModel.fromJson(response.data!);
        _calculateCharge();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchPaymentSettings() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Charge Calculation
  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final userChargeStr = paymentSettings.value.data?.userCharge ?? "0";
    final userChargeType =
        paymentSettings.value.data?.userChargeType ?? "fixed";

    double calculatedCharge = 0.0;

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      calculatedCharge = amount * percent / 100;
      charge.value = calculatedCharge;
      totalAmount.value = amount + calculatedCharge;
    } else {
      await getChargeConverter();
    }
    isPaymentSettingsLoading.value = false;
  }

  // Get Charge Converter
  Future<void> getChargeConverter() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: paymentSettings.value.data!.userCharge!,
          currencyCode: wallet.value!.code!,
        ),
      );
      if (response.status == Status.completed) {
        converterModel.value = ConverterModel.fromJson(response.data!);
        charge.value =
            double.tryParse(
              converterModel.value.data!.convertedAmount ?? "0",
            ) ??
            0.0;
        totalAmount.value =
            (double.tryParse(amountController.text)! + charge.value);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Make Payment
  Future<void> makePayment() async {
    isMakePaymentLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'merchant_number': merchantMidController.text.trim(),
      'wallet_id': wallet.value!.isDefault == true
          ? "default"
          : wallet.value!.id,
      'amount': amountController.text.trim(),
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.makePaymentEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        successPaymentData.value = response.data!['data'];
        currentStep.value = 2;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ makePayment() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isMakePaymentLoading.value = false;
    }
  }

  // Validate Amount Step
  bool validateAmountStep() {
    // Validate Wallet
    if (wallet.value!.name!.isEmpty) {
      ToastHelper().showErrorToast(
        localization.makePaymentValidationSelectWallet,
      );
      return false;
    }

    if (merchantMidController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.makePaymentValidationEnterMerchantMid,
      );
      return false;
    }

    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(
        localization.makePaymentValidationEnterAmount,
      );
      return false;
    }

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: wallet.value!.code!,
      siteCurrencyCode: Get.find<SettingsService>().getSetting(
        "site_currency",
      )!,
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: wallet.value!.isCrypto!,
    );

    final double enteredAmount =
        double.tryParse(amountController.text.trim()) ?? 0.0;
    final double min = double.tryParse(wallet.value!.paymentLimit!.min!) ?? 0.0;
    final double max =
        double.tryParse(wallet.value!.paymentLimit!.max!) ?? double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.makePaymentValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.makePaymentValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    return true;
  }

  // Fetch Wallets
  Future<void> fetchWallets() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.walletsEndpoint}?payment",
      );

      if (response.status == Status.completed) {
        final paymentWalletsModel = PaymentWalletModel.fromJson(response.data!);
        paymentWalletsList.assignAll(paymentWalletsModel.data?.wallets ?? []);

        if (paymentWalletsList.isNotEmpty) {
          wallet.value = paymentWalletsList.first;
        } else {
          wallet.value = null;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Fetch Beneficiary
  Future<void> fetchBeneficiary() async {
    isBeneficiaryLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.beneficiaryEndpoint}?type=merchant",
      );

      if (response.status == Status.completed) {
        beneficiaryModel.value = BeneficiaryModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      isBeneficiaryLoading.value = false;
      debugPrint('❌ fetchBeneficiary() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isBeneficiaryLoading.value = false;
    }
  }

  // Clear Fields
  void clearFields() {
    paymentSettings.value = PaymentSettingsModel();
    converterModel.value = ConverterModel();
    amountController.clear();
    charge.value = 0.0;
    totalAmount.value = 0.0;
    merchantMidController.clear();
  }
}
