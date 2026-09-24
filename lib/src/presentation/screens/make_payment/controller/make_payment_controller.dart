import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/beneficiary_model.dart';
import 'package:ecardo_user/src/common/model/converter_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/passcode_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/model/payment_settings_model.dart';
import 'package:ecardo_user/src/presentation/screens/make_payment/model/payment_wallet_model.dart';

class MakePaymentController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isPaymentSettingsLoading = false.obs;
  final RxBool isMakePaymentLoading = false.obs;
  final RxBool isBeneficiaryLoading = false.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxBool chargeLoadFailed = false.obs;
  final Rx<PaymentSettingsModel> paymentSettings = PaymentSettingsModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rx<BeneficiaryModel> beneficiaryModel = BeneficiaryModel().obs;
  final Rxn<Map<String, dynamic>> successPaymentData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  AppLocalizations get localization => AppLocalizations.of(Get.context!)!;

  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> paymentWalletsList = <Wallets>[].obs;

  final RxInt currentStep = 0.obs;

  final RxBool isMerchantFocused = false.obs;
  final FocusNode merchantFocusNode = FocusNode();
  final merchantMidController = TextEditingController();

  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

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

  void _handleMerchantFocusChange() {
    isMerchantFocused.value = merchantFocusNode.hasFocus;
  }

  void _handleAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

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
    } finally {
      isPaymentSettingsLoading.value = false;
    }
  }

  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final userChargeStr = paymentSettings.value.data?.userCharge ?? "0";
    final userChargeType =
        paymentSettings.value.data?.userChargeType ?? "fixed";

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      charge.value = amount * percent / 100;
      totalAmount.value = amount + charge.value;
    } else {
      await getChargeConverter();
    }
    isPaymentSettingsLoading.value = false;
  }

  Future<void> getChargeConverter() async {
    chargeLoadFailed.value = false;
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
            ((double.tryParse(amountController.text) ?? 0.0) + charge.value);
      } else {
        chargeLoadFailed.value = true;
      }
    } catch (e, stackTrace) {
      chargeLoadFailed.value = true;
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  /// [passcode] — verified 4-digit transaction passcode when required.
  Future<void> makePayment({String? passcode}) async {
    if (isMakePaymentLoading.isTrue) return;
    isMakePaymentLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'merchant_number': merchantMidController.text.trim(),
      'wallet_id': wallet.value!.isDefault == true
          ? "default"
          : wallet.value!.id,
      'amount': amountController.text.trim(),
    };
    if (passcode != null && PasscodeHelper.isValidFormat(passcode)) {
      requestBody['passcode'] = PasscodeHelper.normalize(passcode);
    }

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

  bool validateAmountStep() {
    if (chargeLoadFailed.value) {
      ToastHelper().showErrorToast(localization.allControllerLoadError);
      return false;
    }
    final walletData = wallet.value;
    if (walletData == null || (walletData.name ?? '').isEmpty) {
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
          ) ??
          'USD',
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
            "site_currency_decimals",
          ) ??
          '2',
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

    final double availableBalance =
        double.tryParse(wallet.value!.balance ?? '') ?? 0.0;
    if (enteredAmount > availableBalance) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationInsufficientBalance(
          availableBalance.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    return true;
  }

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

  void clearFields() {
    paymentSettings.value = PaymentSettingsModel();
    converterModel.value = ConverterModel();
    amountController.clear();
    charge.value = 0.0;
    totalAmount.value = 0.0;
    merchantMidController.clear();
  }
}
