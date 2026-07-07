import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qunzo_user/l10n/app_localizations.dart';
import 'package:qunzo_user/src/helper/toast_helper.dart';
import 'package:qunzo_user/src/network/api/api_path.dart';
import 'package:qunzo_user/src/network/response/status.dart';
import 'package:qunzo_user/src/network/service/network_service.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/payment_account/model/payment_account_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/model/ads_eligibility_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/model/create_ad_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/model/highest_order_price_response_model.dart';
import 'package:qunzo_user/src/presentation/screens/p2p/sub_category/create_ad/view/create_ad_success_screen.dart';
import 'package:qunzo_user/src/presentation/screens/wallets/model/currencies_model.dart';

class CreateAdController extends GetxController {
  final RxInt currentStep = 0.obs;
  final RxBool isBuySelected = true.obs;
  final RxString selectedTradeType = 'buy'.obs;
  final RxBool isEligibilityLoading = false.obs;
  final RxBool isEligibleToCreateAd = true.obs;
  final RxBool isCurrenciesLoading = false.obs;
  final RxBool isHighestOrderPriceLoading = false.obs;
  final RxBool isPaymentMethodsLoading = false.obs;
  final RxBool isCreateAdLoading = false.obs;
  final RxBool isCreateAdSuccess = false.obs;

  final RxString selectedAsset = ''.obs;
  final RxString selectedFiat = ''.obs;
  final RxString selectedPriceType = ''.obs;
  final RxInt paymentTimeLimit = 0.obs;
  final RxString enteredPrice = '1'.obs;
  final RxString highestOrderPrice = '-'.obs;
  final Rxn<HighestOrderPriceResponseModel> highestOrderPriceResponse =
      Rxn<HighestOrderPriceResponseModel>();
  final Rxn<AdsEligibilityResponseModel> adsEligibilityResponse =
      Rxn<AdsEligibilityResponseModel>();
  final Rxn<CreateAdResponseModel> createAdResponse =
      Rxn<CreateAdResponseModel>();
  final RxString totalAmountApproxText = '≈ 0'.obs;
  final RxString minAmountApproxText = '≈ 0'.obs;
  final RxString maxAmountApproxText = '≈ 0'.obs;
  final RxList<PaymentAccount> availablePaymentAccounts =
      <PaymentAccount>[].obs;
  final RxList<int> selectedPaymentMethodIds = <int>[].obs;
  final RxList<String> selectedPaymentMethodNames = <String>[].obs;

  final RxList<CurrenciesData> assetCurrencies = <CurrenciesData>[].obs;
  final RxList<CurrenciesData> fiatCurrencies = <CurrenciesData>[].obs;
  final Rxn<CurrenciesData> selectedAssetCurrency = Rxn<CurrenciesData>();
  final Rxn<CurrenciesData> selectedFiatCurrency = Rxn<CurrenciesData>();
  final RxnInt selectedAssetId = RxnInt();
  final RxnInt selectedFiatId = RxnInt();
  final TextEditingController assetCurrencyController = TextEditingController();
  final TextEditingController fiatCurrencyController = TextEditingController();
  final TextEditingController priceController = TextEditingController(
    text: '1',
  );
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController minOrderLimitController = TextEditingController();
  final TextEditingController maxOrderLimitController = TextEditingController();
  final TextEditingController paymentTimeLimitController =
      TextEditingController();
  final TextEditingController termsController = TextEditingController();
  final TextEditingController autoReplyController = TextEditingController();

  final List<String> stepTitles = const [
    'Set Type &\nPrice',
    'Set  Amount &\nMethod',
    'Set\nConditions',
  ];

  @override
  void onInit() {
    super.onInit();
    totalAmountController.addListener(_updateApproxValues);
    minOrderLimitController.addListener(_updateApproxValues);
    maxOrderLimitController.addListener(_updateApproxValues);
    fetchAdsEligibility();
  }

  @override
  void onClose() {
    totalAmountController.removeListener(_updateApproxValues);
    minOrderLimitController.removeListener(_updateApproxValues);
    maxOrderLimitController.removeListener(_updateApproxValues);
    assetCurrencyController.dispose();
    fiatCurrencyController.dispose();
    priceController.dispose();
    totalAmountController.dispose();
    minOrderLimitController.dispose();
    maxOrderLimitController.dispose();
    paymentTimeLimitController.dispose();
    termsController.dispose();
    autoReplyController.dispose();
    super.onClose();
  }

  bool get isSecondStep => currentStep.value == 1;
  bool get isThirdStep => currentStep.value == 2;

  void toggleTradeType(bool isBuy) {
    isBuySelected.value = isBuy;
    selectedTradeType.value = isBuy ? 'buy' : 'sell';
    _triggerHighestOrderPriceFetch();
  }

  void goToPreviousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  void goToNextStep() {
    if (!_validateCurrentStep()) return;
    if (currentStep.value < 2) {
      currentStep.value++;
    } else {
      createAd();
    }
  }

  void goToStep(int index) {
    if (index <= currentStep.value && index >= 0 && index <= 2) {
      currentStep.value = index;
    }
  }

  bool isStepActive(int stepIndex) => stepIndex <= currentStep.value;

  List<String> get eligibilityReasons {
    return adsEligibilityResponse.value?.data?.reasons ?? <String>[];
  }

  void increasePrice() {
    final value = _currentPriceValue + 1;
    _setPriceValue(value);
  }

  void decreasePrice() {
    if (_currentPriceValue <= 0) return;
    final value = _currentPriceValue - 1;
    _setPriceValue(value);
  }

  bool _validateCurrentStep() {
    final localization = AppLocalizations.of(Get.context!)!;
    if (currentStep.value == 0) {
      if (selectedAssetId.value == null) {
        ToastHelper().showErrorToast(localization.error_select_asset);
        return false;
      }
      if (selectedFiatId.value == null) {
        ToastHelper().showErrorToast(localization.error_select_fiat);
        return false;
      }
      if (selectedPriceType.value.isEmpty) {
        ToastHelper().showErrorToast(localization.error_select_price_type);
        return false;
      }
      if (_currentPriceValue <= 0) {
        ToastHelper().showErrorToast(localization.error_price_zero);
        return false;
      }
    } else if (currentStep.value == 1) {
      if (totalAmountController.text.trim().isEmpty) {
        ToastHelper().showErrorToast(localization.error_enter_total_amount);
        return false;
      }
      if (minOrderLimitController.text.trim().isEmpty) {
        ToastHelper().showErrorToast(localization.error_enter_min_order);
        return false;
      }
      if (maxOrderLimitController.text.trim().isEmpty) {
        ToastHelper().showErrorToast(localization.error_enter_max_order);
        return false;
      }
      final paymentTime = int.tryParse(paymentTimeLimitController.text.trim());
      if (paymentTime == null || paymentTime <= 0) {
        ToastHelper().showErrorToast(localization.error_payment_time_zero);
        return false;
      }
      if (selectedPaymentMethodIds.isEmpty) {
        ToastHelper().showErrorToast(localization.error_select_payment);
        return false;
      }
    } else if (currentStep.value == 2) {
      if (termsController.text.trim().isEmpty) {
        ToastHelper().showErrorToast(localization.error_enter_terms);
        return false;
      }
    }
    return true;
  }

  Future<void> fetchStepOneCurrencies() async {
    await Future.wait([
      fetchCurrencies(type: 'crypto'),
      fetchCurrencies(type: 'fiat'),
    ]);
  }

  Future<void> fetchAdsEligibility() async {
    isEligibilityLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.adsEligibilityEndPoint,
      );

      if (response.status == Status.completed && response.data != null) {
        final model = AdsEligibilityResponseModel.fromJson(response.data!);
        adsEligibilityResponse.value = model;
        final isEligible = model.data?.eligible ?? true;
        isEligibleToCreateAd.value = isEligible;
      } else {
        isEligibleToCreateAd.value = true;
      }
    } catch (e, stackTrace) {
      debugPrint('fetchAdsEligibility() error: $e');
      debugPrint('StackTrace: $stackTrace');
      isEligibleToCreateAd.value = true;
    } finally {
      isEligibilityLoading.value = false;
      if (isEligibleToCreateAd.value &&
          assetCurrencies.isEmpty &&
          fiatCurrencies.isEmpty) {
        fetchStepOneCurrencies();
      }
    }
  }

  Future<void> fetchCurrencies({required String type}) async {
    isCurrenciesLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: '${ApiPath.currenciesEndpoint}?type=$type',
      );

      if (response.status == Status.completed) {
        final currenciesModel = CurrenciesModel.fromJson(response.data!);
        final items = currenciesModel.data ?? <CurrenciesData>[];
        if (type == 'crypto') {
          assetCurrencies
            ..clear()
            ..assignAll(items);
        } else if (type == 'fiat') {
          fiatCurrencies
            ..clear()
            ..assignAll(items);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('fetchCurrencies(type: $type) error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isCurrenciesLoading.value = false;
    }
  }

  void onAssetSelected(CurrenciesData currency) {
    selectedAssetCurrency.value = currency;
    selectedAssetId.value = currency.id;
    selectedAsset.value = currency.code ?? currency.name ?? '';
    assetCurrencyController.text = selectedAsset.value;
    _updateApproxValues();
    _triggerHighestOrderPriceFetch();
  }

  void onFiatSelected(CurrenciesData currency) {
    selectedFiatCurrency.value = currency;
    selectedFiatId.value = currency.id;
    selectedFiat.value = currency.code ?? currency.name ?? '';
    fiatCurrencyController.text = selectedFiat.value;
    availablePaymentAccounts.clear();
    selectedPaymentMethodIds.clear();
    selectedPaymentMethodNames.clear();
    _updateApproxValues();
    _triggerHighestOrderPriceFetch();
  }

  void onPriceTypeSelected(String type) {
    selectedPriceType.value = type;
    final current = _currentPriceValue;
    _setPriceValue(current);
  }

  void onPriceChanged(String value) {
    enteredPrice.value = value.trim().isEmpty ? '0' : value.trim();
  }

  List<TextInputFormatter> get priceInputFormatters {
    if (selectedPriceType.value == 'Float') {
      return [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))];
    }
    return [FilteringTextInputFormatter.digitsOnly];
  }

  TextInputType get priceKeyboardType {
    return selectedPriceType.value == 'Float'
        ? const TextInputType.numberWithOptions(decimal: true)
        : TextInputType.number;
  }

  double get _currentPriceValue {
    final value = double.tryParse(priceController.text.trim()) ?? 0;
    if (value.isNaN || value.isInfinite) return 0;
    return value;
  }

  void _setPriceValue(double value) {
    if (selectedPriceType.value == 'Float') {
      final text = value % 1 == 0
          ? value.toStringAsFixed(1)
          : value.toStringAsFixed(2);
      priceController.text = text;
      enteredPrice.value = text;
    } else {
      final text = value.round().toString();
      priceController.text = text;
      enteredPrice.value = text;
    }
  }

  Future<void> _triggerHighestOrderPriceFetch() async {
    final tradeType = selectedTradeType.value;
    final assetId = selectedAssetId.value;
    final fiatId = selectedFiatId.value;

    if (tradeType.isEmpty || assetId == null || fiatId == null) {
      highestOrderPrice.value = '-';
      highestOrderPriceResponse.value = null;
      return;
    }

    await fetchHighestOrderPrice(
      type: tradeType,
      assetCurrencyId: assetId,
      fiatCurrencyId: fiatId,
    );
  }

  Future<void> fetchHighestOrderPrice({
    required String type,
    required int assetCurrencyId,
    required int fiatCurrencyId,
  }) async {
    isHighestOrderPriceLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.highestOrderPriceEndpoint}?type=$type&asset_currency_id=$assetCurrencyId&fiat_currency_id=$fiatCurrencyId',
      );

      if (response.status == Status.completed) {
        final model = HighestOrderPriceResponseModel.fromJson(response.data!);
        highestOrderPriceResponse.value = model;
        highestOrderPrice.value =
            model.data?.highestPrice?.trim().isNotEmpty == true
            ? model.data!.highestPrice!
            : '-';
      }
    } catch (e, stackTrace) {
      debugPrint('fetchHighestOrderPrice() error: $e');
      debugPrint('StackTrace: $stackTrace');
      highestOrderPrice.value = '-';
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isHighestOrderPriceLoading.value = false;
    }
  }

  Future<void> fetchPaymentMethodsByFiat() async {
    if (selectedFiatId.value == null) {
      ToastHelper().showErrorToast('Please select fiat first');
      return;
    }

    isPaymentMethodsLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint:
            '${ApiPath.paymentAccountEndpoint}?currency_id=${selectedFiatId.value}',
      );
      if (response.status != Status.completed || response.data == null) {
        availablePaymentAccounts.clear();
        return;
      }
      final paymentAccountResponse = PaymentAccountResponseModel.fromJson(
        response.data!,
      );
      final accounts =
          paymentAccountResponse.data?.paymentAccounts ?? <PaymentAccount>[];

      availablePaymentAccounts
        ..clear()
        ..assignAll(accounts.where((account) => account.id != null).toList());
    } catch (e, stackTrace) {
      debugPrint('fetchPaymentMethodsByFiat() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isPaymentMethodsLoading.value = false;
    }
  }

  void togglePaymentMethodSelection(PaymentAccount account) {
    final accountId = account.id;
    if (accountId == null) return;
    final label = account.paymentMethod?.name ?? 'Method';

    if (selectedPaymentMethodIds.contains(accountId)) {
      selectedPaymentMethodIds.remove(accountId);
      selectedPaymentMethodNames.remove(label);
      selectedPaymentMethodIds.refresh();
      selectedPaymentMethodNames.refresh();
      return;
    }

    selectedPaymentMethodIds.add(accountId);
    selectedPaymentMethodNames.add(label);
    selectedPaymentMethodIds.refresh();
    selectedPaymentMethodNames.refresh();
  }

  void _updateApproxValues() {
    final totalAmount = double.tryParse(totalAmountController.text.trim()) ?? 0;
    final minAmount = double.tryParse(minOrderLimitController.text.trim()) ?? 0;
    final maxAmount = double.tryParse(maxOrderLimitController.text.trim()) ?? 0;
    final assetRate = double.tryParse(
      selectedAssetCurrency.value?.conversionRate ?? '',
    );
    final fiatRate = double.tryParse(
      selectedFiatCurrency.value?.conversionRate ?? '',
    );

    final fiatCode = selectedFiatCurrency.value?.code ?? selectedFiat.value;
    final assetCode = selectedAssetCurrency.value?.code ?? selectedAsset.value;

    final totalConverted = _convertAssetToFiat(
      amount: totalAmount,
      assetRate: assetRate,
      fiatRate: fiatRate,
    );
    final minConverted = _convertFiatToAsset(
      amount: minAmount,
      assetRate: assetRate,
      fiatRate: fiatRate,
    );
    final maxConverted = _convertFiatToAsset(
      amount: maxAmount,
      assetRate: assetRate,
      fiatRate: fiatRate,
    );

    totalAmountApproxText.value =
        '≈ ${_formatConvertedValue(totalConverted, decimals: 2)} ${fiatCode.isEmpty ? '' : fiatCode}';
    minAmountApproxText.value =
        '≈ ${_formatConvertedValue(minConverted, decimals: 8)} ${assetCode.isEmpty ? '' : assetCode}';
    maxAmountApproxText.value =
        '≈ ${_formatConvertedValue(maxConverted, decimals: 8)} ${assetCode.isEmpty ? '' : assetCode}';
  }

  double _convertAssetToFiat({
    required double amount,
    required double? assetRate,
    required double? fiatRate,
  }) {
    if (amount <= 0 ||
        assetRate == null ||
        fiatRate == null ||
        assetRate == 0) {
      return 0;
    }
    return (fiatRate * amount) / assetRate;
  }

  double _convertFiatToAsset({
    required double amount,
    required double? assetRate,
    required double? fiatRate,
  }) {
    if (amount <= 0 || assetRate == null || fiatRate == null || fiatRate == 0) {
      return 0;
    }
    return (assetRate * amount) / fiatRate;
  }

  String _formatConvertedValue(double value, {required int decimals}) {
    if (value == 0) return '0';
    final fixed = value.toStringAsFixed(decimals);
    return fixed;
  }

  Future<void> createAd() async {
    if (!_validateCurrentStep()) return;

    isCreateAdLoading.value = true;
    try {
      final body = <String, dynamic>{
        'asset_currency_id': selectedAssetId.value,
        'fiat_currency_id': selectedFiatId.value,
        'type': selectedTradeType.value,
        'total_amount': totalAmountController.text.trim(),
        'min_amount': minOrderLimitController.text.trim(),
        'max_amount': maxOrderLimitController.text.trim(),
        'price': priceController.text.trim(),
        'payment_duration': paymentTimeLimitController.text.trim(),
        'description': termsController.text.trim(),
        'auto_response_message': autoReplyController.text.trim(),
        'payment_method_ids': selectedPaymentMethodIds.toList(),
      };

      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.createAdEndpoint,
        data: body,
      );

      if (response.status == Status.completed && response.data != null) {
        final model = CreateAdResponseModel.fromJson(response.data!);
        createAdResponse.value = model;
        isCreateAdSuccess.value = true;
        ToastHelper().showSuccessToast(
          model.message ?? 'Ad created successfully',
        );
        Get.off(() => CreateAdSuccessScreen(adData: model.data));
      }
    } catch (e, stackTrace) {
      debugPrint('createAd() error: $e');
      debugPrint('StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        AppLocalizations.of(Get.context!)!.allControllerLoadError,
      );
    } finally {
      isCreateAdLoading.value = false;
    }
  }
}
