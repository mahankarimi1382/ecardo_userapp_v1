import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/common/model/converter_model.dart';
import 'package:qunzo_user/src/common/model/user_model.dart';
import 'package:qunzo_user/src/common/services/settings_service.dart';
import 'package:qunzo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/exchange/model/exchange_config_model.dart';
import 'package:qunzo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';

class ExchangeController extends GetxController {
  // Global Variable
  final RxBool isLoading = false.obs;
  final RxBool isExchangeConfigLoading = false.obs;
  final RxBool isExchangeWalletLoading = false.obs;
  final RxBool isCalculateExchangeRateLoading = false.obs;
  final RxInt currentStep = 0.obs;
  final RxDouble charge = 0.0.obs;
  final RxDouble exchangeRate = 0.0.obs;
  final RxDouble exchangeReviewRate = 0.0.obs;
  final RxDouble exchangeAmount = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];
  final RxList<CurrenciesData> currenciesList = <CurrenciesData>[].obs;
  final Rx<ExchangeConfigModel> exchangeConfigModel = ExchangeConfigModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rxn<Map<String, dynamic>> successExchangeData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;
  final localization = AppLocalizations.of(Get.context!)!;

  // From Wallet
  final RxBool fromWalletBorderFocused = false.obs;
  final Rxn<Wallets> fromWallet = Rxn<Wallets>();
  final RxList<Wallets> fromExchangeWalletsList = <Wallets>[].obs;

  // To Wallet
  final RxBool toWalletBorderFocused = false.obs;
  final Rxn<Wallets> toWallet = Rxn<Wallets>();
  final RxList<Wallets> toExchangeWalletsList = <Wallets>[].obs;

  // Amount
  final RxBool isAmountFocused = false.obs;
  final amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    loadData();
    amountFocusNode.addListener(_handleAmountFocusChange);
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await fetchWallets();
    await fetchCurrencies();
    await fetchUser();
    isLoading.value = false;
  }

  @override
  void onClose() {
    amountFocusNode.removeListener(_handleAmountFocusChange);
    amountFocusNode.dispose();
    super.onClose();
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
      await fetchExchangeConfig();
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

  // Fetch Exchange Config
  Future<void> fetchExchangeConfig() async {
    isExchangeConfigLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.exchangeConfigEndpoint,
      );

      if (response.status == Status.completed) {
        exchangeConfigModel.value = ExchangeConfigModel.fromJson(
          response.data!,
        );
        await getExchangeRateConverter();
        _calculateCharge();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchExchangeConfig() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Charge Calculation
  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final userChargeStr =
        exchangeConfigModel.value.data!.settings!.charge ?? "0";
    final userChargeType =
        exchangeConfigModel.value.data!.settings!.chargeType ?? "fixed";

    double calculatedCharge = 0.0;

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      calculatedCharge = amount * percent / 100;
      charge.value = calculatedCharge;
    } else {
      await getChargeConverter();
      calculatedCharge = charge.value;
    }

    totalAmount.value = amount + calculatedCharge;
    isExchangeConfigLoading.value = false;
  }

  // Get Charge Converter
  Future<void> getChargeConverter() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: exchangeConfigModel.value.data!.settings!.charge!,
          currencyCode: fromWallet.value!.code!,
        ),
      );
      if (response.status == Status.completed) {
        converterModel.value = ConverterModel.fromJson(response.data!);
        charge.value =
            double.tryParse(
              converterModel.value.data!.convertedAmount ?? "0",
            ) ??
            0.0;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Get Exchange Rate Converter
  Future<void> getExchangeRateConverter() async {
    isExchangeConfigLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getCurrencyToCurrencyConverterEndpoint(
          amount: amountController.text,
          toCurrencyCode: toWallet.value!.code!,
          fromCurrencyCode: fromWallet.value!.code!,
        ),
      );
      if (response.status == Status.completed) {
        converterModel.value = ConverterModel.fromJson(response.data!);
        exchangeReviewRate.value =
            double.tryParse(converterModel.value.data!.rate ?? "0") ?? 0.0;
        exchangeAmount.value =
            double.tryParse(
              converterModel.value.data!.convertedAmount ?? "0",
            ) ??
            0.0;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getExchangeRateConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isExchangeConfigLoading.value = false;
    }
  }

  // Validate Amount Step
  bool validateAmountStep() {
    if (fromWallet.value!.name!.isEmpty) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationSelectFromWallet,
      );
      return false;
    }

    if (toWallet.value!.name!.isEmpty) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationSelectToWallet,
      );
      return false;
    }

    if (amountController.text.isEmpty) {
      ToastHelper().showErrorToast(localization.exchangeValidationEnterAmount);
      return false;
    }

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: fromWallet.value!.code!,
      siteCurrencyCode: Get.find<SettingsService>().getSetting(
        "site_currency",
      )!,
      siteCurrencyDecimals: Get.find<SettingsService>().getSetting(
        "site_currency_decimals",
      )!,
      isCrypto: fromWallet.value!.isCrypto!,
    );

    final double enteredAmount =
        double.tryParse(amountController.text.trim()) ?? 0.0;
    final double min =
        double.tryParse(fromWallet.value!.exchangeLimit!.min!) ?? 0.0;
    final double max =
        double.tryParse(fromWallet.value!.exchangeLimit!.max!) ??
        double.infinity;

    if (enteredAmount < min) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationAmountMinimum(
          min.toStringAsFixed(calculateDecimals),
          fromWallet.value!.code!,
        ),
      );
      return false;
    }

    if (enteredAmount > max) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationAmountMaximum(
          max.toStringAsFixed(calculateDecimals),
          fromWallet.value!.code!,
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
        endpoint: "${ApiPath.walletsEndpoint}?exchange",
      );

      if (response.status == Status.completed) {
        final exchangeWalletsModel = ExchangeWalletModel.fromJson(
          response.data!,
        );

        fromExchangeWalletsList.assignAll(
          exchangeWalletsModel.data?.wallets ?? [],
        );
        toExchangeWalletsList.assignAll(
          exchangeWalletsModel.data?.wallets ?? [],
        );

        if (fromExchangeWalletsList.isNotEmpty &&
            toExchangeWalletsList.isNotEmpty) {
          fromWallet.value = fromExchangeWalletsList.first;
          if (toExchangeWalletsList.length > 1) {
            toWallet.value = toExchangeWalletsList[1];
          } else {
            toWallet.value = toExchangeWalletsList.first;
          }

          calculateExchange();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Fetch Currencies
  Future<void> fetchCurrencies() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.currenciesEndpoint,
      );
      if (response.status == Status.completed) {
        final currenciesModel = CurrenciesModel.fromJson(response.data!);
        currenciesList.assignAll(currenciesModel.data ?? []);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCurrencies() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {}
  }

  // Calculate Exchange Rate
  void calculateExchange() {
    if (fromWallet.value != null && toWallet.value != null) {
      final fromCurrency = currenciesList.firstWhere(
        (c) => c.code == fromWallet.value!.code,
        orElse: () =>
            CurrenciesData(conversionRate: "1", code: fromWallet.value!.code),
      );

      final toCurrency = currenciesList.firstWhere(
        (c) => c.code == toWallet.value!.code,
        orElse: () =>
            CurrenciesData(conversionRate: "1", code: toWallet.value!.code),
      );

      final double fromRate =
          double.tryParse(fromCurrency.conversionRate ?? "1") ?? 1;
      final double toRate =
          double.tryParse(toCurrency.conversionRate ?? "1") ?? 1;

      exchangeRate.value = 1 / fromRate * toRate;
    }
  }

  // Exchange Wallet
  Future<void> exchangeWallet() async {
    isExchangeWalletLoading.value = true;

    final Map<String, dynamic> requestBody = {
      'amount': amountController.text.trim(),
      'from_wallet': fromWallet.value!.id == 0
          ? "default"
          : fromWallet.value!.id.toString(),
      'to_wallet': toWallet.value!.id == 0
          ? "default"
          : toWallet.value!.id.toString(),
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.exchangeWalletEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed) {
        ToastHelper().showSuccessToast(response.data!["message"]);
        successExchangeData.value = response.data!['data'];
        currentStep.value = 2;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ exchangeWallet() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isExchangeWalletLoading.value = false;
    }
  }

  // Clear Fields
  void clearFields() {
    exchangeConfigModel.value = ExchangeConfigModel();
    converterModel.value = ConverterModel();
    amountController.clear();
    charge.value = 0.0;
    totalAmount.value = 0.0;
    exchangeRate.value = 0.0;
    exchangeReviewRate.value = 0.0;
    exchangeAmount.value = 0.0;
    fromWalletBorderFocused.value = false;
    toWalletBorderFocused.value = false;
  }
}
