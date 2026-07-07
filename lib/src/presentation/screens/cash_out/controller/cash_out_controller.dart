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
import 'package:qunzo_user/src/presentation/screens/cash_out/model/cash_out_config_model.dart';
import 'package:qunzo_user/src/presentation/screens/cash_out/model/cash_out_wallet_model.dart';

class CashOutController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isCashOutLoading = false.obs;
  final RxBool isBeneficiaryLoading = false.obs;
  final RxBool isCashoutConfigLoading = false.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];
  final Rx<CashOutConfigModel> cashOutConfig = CashOutConfigModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rx<BeneficiaryModel> beneficiaryModel = BeneficiaryModel().obs;
  final Rxn<Map<String, dynamic>> successCashOutData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // Wallet
  final Rxn<Wallets> wallet = Rxn<Wallets>();
  final RxList<Wallets> cashOutWalletsList = <Wallets>[].obs;

  // Agent AID
  final RxBool isAgentAidFocused = false.obs;
  final FocusNode agentAidFocusNode = FocusNode();
  final agentAidController = TextEditingController();

  // Amount
  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    agentAidFocusNode.addListener(_handleAgentAidFocusChange);
    amountFocusNode.addListener(_handleAmountFocusChange);
  }

  @override
  void onClose() {
    agentAidFocusNode.removeListener(_handleAgentAidFocusChange);
    amountFocusNode.removeListener(_handleAmountFocusChange);
    agentAidFocusNode.dispose();
    amountFocusNode.dispose();
    super.onClose();
  }

  // Agent Aid focus change handler
  void _handleAgentAidFocusChange() {
    isAgentAidFocused.value = agentAidFocusNode.hasFocus;
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
      await fetchCashOutConfig();
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

  // Fetch Cash Out Config
  Future<void> fetchCashOutConfig() async {
    isCashoutConfigLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.cashOutConfigEndpoint,
      );

      if (response.status == Status.completed) {
        cashOutConfig.value = CashOutConfigModel.fromJson(response.data!);
        _calculateCharge();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCashOutConfig() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Charge Calculation
  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final userChargeStr = cashOutConfig.value.data!.settings!.charge ?? "0";
    final userChargeType =
        cashOutConfig.value.data!.settings!.chargeType ?? "fixed";

    double calculatedCharge = 0.0;

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      calculatedCharge = amount * percent / 100;
      charge.value = calculatedCharge;
      totalAmount.value = amount + calculatedCharge;
    } else {
      await getChargeConverter();
    }

    isCashoutConfigLoading.value = false;
  }

  // Get Charge Converter
  Future<void> getChargeConverter() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: cashOutConfig.value.data!.settings!.charge!,
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

  // Validate Amount Step
  bool validateAmountStep() {
    if (wallet.value!.name!.isEmpty) {
      ToastHelper().showErrorToast(localization.cashOutValidationSelectWallet);
      return false;
    }

    if (agentAidController.text.isEmpty) {
      ToastHelper().showErrorToast(localization.cashOutValidationEnterAgentAid);
      return false;
    }

    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization.cashOutValidationEnterAmount);
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
    final double min = double.tryParse(wallet.value!.cashoutLimit!.min!) ?? 0.0;
    final double max =
        double.tryParse(wallet.value!.cashoutLimit!.max!) ?? double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.cashOutValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          wallet.value!.code!,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.cashOutValidationAmountMaximum(
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
    isLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.walletsEndpoint}?cashout",
      );

      if (response.status == Status.completed) {
        final cashOutWalletsModel = CashOutWalletModel.fromJson(response.data!);
        cashOutWalletsList.assignAll(cashOutWalletsModel.data?.wallets ?? []);

        if (cashOutWalletsList.isNotEmpty) {
          wallet.value = cashOutWalletsList.first;
        } else {
          wallet.value = null;
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isLoading.value = false;
    }
  }

  // Cash Out Function
  Future<void> cashOut() async {
    isCashOutLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'agent_number': agentAidController.text.trim(),
      'amount': amountController.text.trim(),
      'wallet_id': wallet.value!.isDefault!
          ? "default"
          : wallet.value!.id.toString(),
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.userCashOutEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        successCashOutData.value = response.data!['data'];
        currentStep.value = 2;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ cashOut() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isCashOutLoading.value = false;
    }
  }

  // Fetch Beneficiary
  Future<void> fetchBeneficiary() async {
    isBeneficiaryLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: "${ApiPath.beneficiaryEndpoint}?type=agent",
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
    converterModel.value = ConverterModel();
    agentAidController.clear();
    amountController.clear();
    totalAmount.value = 0.0;
    charge.value = 0.0;
  }
}
