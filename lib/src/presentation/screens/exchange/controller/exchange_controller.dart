import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/converter_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/app_event_bus.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_config_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_manager.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_validation_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/recent_pairs_store.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/live_rate_badge.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

/// Controller for the redesigned Exchange flow.
///
/// Responsibilities:
///   - Orchestrate data loading (wallets, currencies, user, exchange-config).
///   - Delegate live rate subscription, cross-rate math, drift detection,
///     and review-step rate locking to [ExchangeRateManager].
///   - Delegate min/max validation, balance verification, and fee calculations
///     to [ExchangeValidationService].
///   - Debounce amount input with a 300ms [Timer].
///   - Coordinate step transitions (Amount -> Review -> Success).
///   - Submit exchange transaction via [NetworkService].
class ExchangeController extends GetxController {
  ExchangeController({
    ExchangeRateService? rateService,
    ExchangeRateManager? rateManager,
    ExchangeValidationService? validationService,
  })  : _rateService = rateService ??
            (Get.isRegistered<ExchangeRateService>()
                ? Get.find<ExchangeRateService>()
                : ExchangeRateService()),
        _validationService =
            validationService ?? const ExchangeValidationService() {
    _rateManager = rateManager ??
        ExchangeRateManager(rateService: _rateService);
  }

  final ExchangeRateService _rateService;
  late final ExchangeRateManager _rateManager;
  final ExchangeValidationService _validationService;

  // ------------------ loading flags ------------------
  final RxBool isLoading = false.obs;
  final RxBool isExchangeConfigLoading = false.obs;
  final RxBool isExchangeWalletLoading = false.obs;
  final RxBool isCalculateExchangeRateLoading = false.obs;
  final RxBool walletLoadError = false.obs;

  // ------------------ step state ------------------
  final RxInt currentStep = 0.obs;
  final List<String> steps = ['Amount', 'Review', 'Success'];

  // ------------------ business data ------------------
  final RxDouble charge = 0.0.obs;
  final RxDouble exchangeRate = 0.0.obs;
  final RxDouble exchangeReviewRate = 0.0.obs;
  final RxDouble exchangeAmount = 0.0.obs;
  final RxDouble totalAmount = 0.0.obs;
  final RxList<CurrenciesData> currenciesList = <CurrenciesData>[].obs;
  final Rx<ExchangeConfigModel> exchangeConfigModel =
      ExchangeConfigModel().obs;
  final Rx<ConverterModel> converterModel = ConverterModel().obs;
  final Rxn<Map<String, dynamic>> successExchangeData =
      Rxn<Map<String, dynamic>>();
  final Rx<UserModel> userModel = UserModel().obs;

  /// Dynamic localization lookup per call.
  AppLocalizations? get localizationOrNull {
    final ctx = Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  // ------------------ rate delegation ------------------
  ExchangeRateService get rateService => _rateManager.rateService;
  ExchangeRateManager get rateManager => _rateManager;
  ExchangeValidationService get validationService => _validationService;

  RxDouble get previousRate => _rateManager.previousRate;
  RxDouble get currentRate => _rateManager.currentRate;
  Rx<RateDirection> get rateDirection => _rateManager.rateDirection;
  Rxn<double> get liveChangePercent => _rateManager.liveChangePercent;
  RxString get liveFromNameEn => _rateManager.liveFromNameEn;
  RxString get liveToNameEn => _rateManager.liveToNameEn;
  RxBool get isReviewRateStale => _rateManager.isReviewRateStale;

  // ------------------ from / to wallet ------------------
  final RxBool fromWalletBorderFocused = false.obs;
  final Rxn<Wallets> fromWallet = Rxn<Wallets>();
  final RxList<Wallets> fromExchangeWalletsList = <Wallets>[].obs;

  final RxBool toWalletBorderFocused = false.obs;
  final Rxn<Wallets> toWallet = Rxn<Wallets>();
  final RxList<Wallets> toExchangeWalletsList = <Wallets>[].obs;

  // ------------------ amount ------------------
  final RxBool isAmountFocused = false.obs;
  final TextEditingController amountController = TextEditingController();
  final FocusNode amountFocusNode = FocusNode();

  /// Live preview of the destination amount, kept in sync with the
  /// debounced amount input + current rate.
  final RxDouble liveToAmount = 0.0.obs;
  final RxString amountInput = ''.obs;

  /// True when the user pressed Continue but validation failed.
  final RxBool isContinueInvalid = false.obs;

  /// Recently used (from, to) currency pairs.
  final RxList<RecentPair> recentPairs = <RecentPair>[].obs;

  // ------------------ internal timer ------------------
  Timer? _amountDebounce;

  @override
  void onInit() {
    super.onInit();
    loadData();
    amountFocusNode.addListener(_handleAmountFocusChange);

    // Initialize rate manager to react to live rate updates
    _rateManager.init(
      fromCodeProvider: () => fromWallet.value?.code,
      toCodeProvider: () => toWallet.value?.code,
      onRateUpdated: _scheduleLivePreview,
    );
  }

  @override
  void onClose() {
    _amountDebounce?.cancel();
    _amountDebounce = null;

    _rateManager.dispose(
      fromCode: fromWallet.value?.code,
      toCode: toWallet.value?.code,
    );

    amountFocusNode.removeListener(_handleAmountFocusChange);
    amountFocusNode.dispose();
    amountController.dispose();
    super.onClose();
  }

  // ------------------ bootstrap ------------------

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([
      fetchWallets(),
      fetchCurrencies(),
      fetchUser(),
    ]);
    await fetchExchangeConfig();
    unawaited(_loadRecentPairs());
    isLoading.value = false;
    _subscribeToRateService();
  }

  Future<void> _loadRecentPairs() async {
    try {
      final pairs = await RecentPairsStore.load();
      recentPairs.assignAll(pairs);
    } catch (e) {
      debugPrint('⚠️ recent pairs load failed: $e');
    }
  }

  /// Restores a recent pair into the from/to selectors.
  void selectRecentPair(RecentPair pair) {
    final from = fromExchangeWalletsList.firstWhereOrNull(
      (w) => w.code?.toUpperCase() == pair.fromCode,
    );
    final to = toExchangeWalletsList.firstWhereOrNull(
      (w) => w.code?.toUpperCase() == pair.toCode,
    );
    if (from != null && to != null) {
      fromWallet.value = from;
      toWallet.value = to;
      calculateExchange();
      _subscribeToRateService();
    }
  }

  /// Subscribes the rate service to the currently selected from/to codes.
  void _subscribeToRateService() {
    _rateManager.subscribeWallets(
      fromWallet.value?.code,
      toWallet.value?.code,
    );
  }

  // ------------------ amount focus ------------------

  void _handleAmountFocusChange() {
    isAmountFocused.value = amountFocusNode.hasFocus;
  }

  // ------------------ step navigation ------------------

  Future<void> nextStepWithValidation() async {
    if (currentStep.value == 0) {
      if (!validateAmountStep()) {
        isContinueInvalid.value = true;
        return;
      }
    }

    if (currentStep.value < steps.length - 1) {
      currentStep.value++;
      if (currentStep.value == 1) {
        // Entering Review: lock the rate and start the staleness clock.
        _rateManager.lockRateForReview();
        await fetchExchangeConfig();
      }
    } else {
      currentStep.value = 0;
    }
  }

  /// Pops back to the Amount step and clears the locked-rate state.
  void backToAmountStep() {
    currentStep.value = 0;
    _rateManager.clearReviewLock();
  }

  /// Triggered when user confirms an updated rate after staleness warning.
  Future<void> acknowledgeRateChange() async {
    _rateManager.acknowledgeRateChange();
    await fetchExchangeConfig();
  }

  // ------------------ user / config fetch ------------------

  Future<void> fetchUser() async {
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.userEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        userModel.value = UserModel.fromJson(response.data!);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchUser() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> fetchExchangeConfig() async {
    isExchangeConfigLoading.value = true;
    try {
      final response = await Get.find<NetworkService>().get(
        endpoint: ApiPath.exchangeConfigEndpoint,
      );

      if (response.status == Status.completed && response.data != null) {
        exchangeConfigModel.value = ExchangeConfigModel.fromJson(
          response.data!,
        );
        await getExchangeRateConverter();
        await _calculateCharge();
        _recalculateChargeForAmountStep();
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchExchangeConfig() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    } finally {
      isExchangeConfigLoading.value = false;
    }
  }

  // ------------------ charge calculation ------------------

  Future<void> _calculateCharge() async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final settings = exchangeConfigModel.value.data?.settings;
    if (settings == null) {
      charge.value = 0.0;
      totalAmount.value = amount;
      isExchangeConfigLoading.value = false;
      return;
    }
    final userChargeStr = settings.charge ?? "0";
    final userChargeType = settings.chargeType ?? "fixed";

    if (userChargeType == "percentage") {
      final percent = double.tryParse(userChargeStr) ?? 0.0;
      final calc = _validationService.calculatePercentageCharge(
        amount: amount,
        percent: percent,
      );
      charge.value = calc.charge;
      totalAmount.value = calc.totalAmount;
    } else {
      await getChargeConverter();
      final calc = _validationService.calculateTotalWithFixedCharge(
        amount: amount,
        fixedCharge: charge.value,
      );
      totalAmount.value = calc.totalAmount;
    }

    isExchangeConfigLoading.value = false;
  }

  Future<void> getChargeConverter() async {
    final chargeStr = exchangeConfigModel.value.data?.settings?.charge;
    final fromCode = fromWallet.value?.code;
    if (chargeStr == null || chargeStr.isEmpty || fromCode == null) return;
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getConverterEndpoint(
          amount: chargeStr,
          currencyCode: fromCode,
        ),
      );
      if (response.status == Status.completed && response.data != null) {
        converterModel.value = ConverterModel.fromJson(response.data!);
        charge.value = double.tryParse(
              converterModel.value.data?.convertedAmount ?? "0",
            ) ??
            0.0;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> getExchangeRateConverter() async {
    isExchangeConfigLoading.value = true;
    try {
      final rawAmount = amountController.text.trim();
      final amount = double.tryParse(rawAmount) ?? 0.0;
      if (amount <= 0) {
        exchangeReviewRate.value = 0.0;
        exchangeAmount.value = 0.0;
        isExchangeConfigLoading.value = false;
        return;
      }
      final fromCode = fromWallet.value?.code;
      final toCode = toWallet.value?.code;
      if (fromCode == null || toCode == null) return;
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.getCurrencyToCurrencyConverterEndpoint(
          amount: rawAmount,
          toCurrencyCode: toCode,
          fromCurrencyCode: fromCode,
        ),
      );
      if (response.status == Status.completed && response.data != null) {
        converterModel.value = ConverterModel.fromJson(response.data!);
        exchangeReviewRate.value = double.tryParse(
              converterModel.value.data?.rate ?? "0",
            ) ??
            0.0;
        exchangeAmount.value = double.tryParse(
              converterModel.value.data?.convertedAmount ?? "0",
            ) ??
            0.0;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getExchangeRateConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    } finally {
      isExchangeConfigLoading.value = false;
    }
  }

  // ------------------ validation ------------------

  bool validateAmountStep() {
    final from = fromWallet.value;
    final to = toWallet.value;

    final calculateDecimals = DynamicDecimalsHelper().getDynamicDecimals(
      currencyCode: from?.code ?? '',
      siteCurrencyCode:
          Get.find<SettingsService>().getSetting("site_currency") ?? 'USD',
      siteCurrencyDecimals:
          Get.find<SettingsService>().getSetting("site_currency_decimals") ??
              '2',
      isCrypto: from?.isCrypto ?? false,
    );

    final result = _validationService.validateAmountStep(
      fromWallet: from,
      toWallet: to,
      amountText: amountController.text,
      decimals: calculateDecimals,
      localizations: localizationOrNull,
    );

    if (!result.isValid) {
      if (result.errorMessage != null) {
        ToastHelper().showErrorToast(result.errorMessage!);
      }
      return false;
    }

    return true;
  }

  // ------------------ wallets & currencies ------------------

  Future<void> fetchWallets() async {
    walletLoadError.value = false;
    Object? lastError;
    ApiResponse<Map<String, dynamic>>? response;
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        response = await Get.find<NetworkService>().get(
          endpoint: "${ApiPath.walletsEndpoint}?exchange",
        );
        lastError = null;
        break;
      } catch (e, stackTrace) {
        lastError = e;
        debugPrint('❌ fetchWallets() attempt ${attempt + 1} error: $e');
        debugPrint('📍 StackTrace: $stackTrace');
        if (attempt == 0) {
          await Future.delayed(const Duration(milliseconds: 600));
        }
      }
    }

    if (lastError != null || response == null) {
      walletLoadError.value = true;
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
      return;
    }

    if (response.status == Status.completed && response.data != null) {
      final exchangeWalletsModel = ExchangeWalletModel.fromJson(
        response.data!,
      );

      final wallets = exchangeWalletsModel.data?.wallets ?? [];
      fromExchangeWalletsList.assignAll(wallets);
      toExchangeWalletsList.assignAll(wallets);
      walletLoadError.value = fromExchangeWalletsList.isEmpty;

      if (fromExchangeWalletsList.isNotEmpty &&
          toExchangeWalletsList.isNotEmpty) {
        final arguments =
            Get.arguments is Map ? Get.arguments as Map : {};
        final requestedFrom =
            arguments['from_currency']?.toString().toUpperCase();
        final requestedTo =
            arguments['to_currency']?.toString().toUpperCase();
        fromWallet.value = fromExchangeWalletsList.firstWhereOrNull(
              (wallet) => wallet.code?.toUpperCase() == requestedFrom,
            ) ??
            fromExchangeWalletsList.firstWhereOrNull(
              (wallet) =>
                  wallet.code?.toUpperCase() != requestedTo &&
                  (double.tryParse(wallet.balance ?? '0') ?? 0) > 0,
            ) ??
            fromExchangeWalletsList.first;
        toWallet.value = toExchangeWalletsList.firstWhereOrNull(
              (wallet) => wallet.code?.toUpperCase() == requestedTo,
            ) ??
            toExchangeWalletsList.firstWhereOrNull(
              (wallet) => wallet.code != fromWallet.value?.code,
            ) ??
            toExchangeWalletsList.first;

        calculateExchange();
      } else {
        walletLoadError.value = true;
      }
    } else {
      walletLoadError.value = true;
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    }
  }

  Future<void> fetchCurrencies() async {
    try {
      final response = await Get.find<NetworkService>().globalGet(
        endpoint: ApiPath.currenciesEndpoint,
      );
      if (response.status == Status.completed && response.data != null) {
        final currenciesModel = CurrenciesModel.fromJson(response.data!);
        currenciesList.assignAll(currenciesModel.data ?? []);
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchCurrencies() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    }
  }

  // ------------------ exchange math ------------------

  void calculateExchange() {
    _rateManager.calculateStaticRate(
      fromWallet: fromWallet.value,
      toWallet: toWallet.value,
      currenciesList: currenciesList,
      targetStaticRate: exchangeRate,
    );
    _scheduleLivePreview();
  }

  void swapWallets() {
    HapticFeedback.selectionClick();
    final tmp = fromWallet.value;
    fromWallet.value = toWallet.value;
    toWallet.value = tmp;
    calculateExchange();
    _subscribeToRateService();
  }

  void onAmountChanged(String val) {
    amountInput.value = val;
    isContinueInvalid.value = false;
    _amountDebounce?.cancel();
    _amountDebounce = Timer(const Duration(milliseconds: 300), () {
      _scheduleLivePreview();
      _recalculateChargeForAmountStep();
    });
  }

  void _recalculateChargeForAmountStep() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final settings = exchangeConfigModel.value.data?.settings;
    if (settings == null) {
      charge.value = 0.0;
      totalAmount.value = amount;
      return;
    }

    final calc = _validationService.calculateChargeForAmountStep(
      amount: amount,
      chargeStr: settings.charge,
      chargeType: settings.chargeType,
      currentCharge: charge.value,
    );

    charge.value = calc.charge;
    totalAmount.value = calc.totalAmount;
  }

  void _scheduleLivePreview() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    final rate = currentRate.value;
    if (amount <= 0 || rate <= 0) {
      liveToAmount.value = 0.0;
      return;
    }
    liveToAmount.value = amount * rate;
  }

  void setAmountPercent(double percent) {
    final from = fromWallet.value;
    if (from == null) return;
    final balance = double.tryParse(from.balance ?? '0') ?? 0.0;
    if (balance <= 0) return;
    final amount = _validationService.calculateQuickAmountString(
      balance: balance,
      percent: percent,
      isCrypto: from.isCrypto == true,
    );
    amountController.text = amount;
    amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: amountController.text.length),
    );
    onAmountChanged(amount);
  }

  // ------------------ exchange wallet submission ------------------

  Future<void> exchangeWallet({String? passcode}) async {
    if (isExchangeWalletLoading.isTrue) return;

    if (isReviewRateStale.isTrue) {
      ToastHelper().showWarningToast(
        localizationOrNull?.exchangeReviewRateStaleBanner ??
            'Rate has changed. Please confirm the updated rate before proceeding.',
      );
      return;
    }

    isExchangeWalletLoading.value = true;

    final rateToSend = _rateManager.lockedReviewRate ?? currentRate.value;
    final reviewEnteredAt = _rateManager.reviewEnteredAt;

    final from = fromWallet.value;
    final to = toWallet.value;

    final fromWalletId = from?.id ?? 0;
    final toWalletId = to?.id ?? 0;

    final Map<String, dynamic> requestBody = {
      'amount': amountController.text.trim(),
      'from_wallet': fromWalletId == 0 ? "default" : fromWalletId.toString(),
      'to_wallet': toWalletId == 0 ? "default" : toWalletId.toString(),
      'rate': rateToSend.toStringAsFixed(8),
      'total_amount': totalAmount.value.toStringAsFixed(8),
      'charge': charge.value.toStringAsFixed(8),
      'exchange_amount': exchangeAmount.value.toStringAsFixed(8),
      'exchange_review_rate': exchangeReviewRate.value.toStringAsFixed(8),
      if (reviewEnteredAt != null)
        'rate_locked_at': reviewEnteredAt.toUtc().toIso8601String(),
      if (passcode != null && passcode.isNotEmpty) 'passcode': passcode,
    };

    try {
      final response = await Get.find<NetworkService>().post(
        endpoint: ApiPath.exchangeWalletEndpoint,
        data: requestBody,
      );

      if (response.status == Status.completed && response.data != null) {
        ToastHelper().showSuccessToast(response.data!["message"] ?? '');
        successExchangeData.value = response.data!['data'];
        final fromCode = from?.code?.toUpperCase();
        final toCode = to?.code?.toUpperCase();
        if (fromCode != null && toCode != null) {
          unawaited(
            RecentPairsStore.add(
              RecentPair(fromCode: fromCode, toCode: toCode),
            ).then((_) => _loadRecentPairs()),
          );
        }
        currentStep.value = 2;
        AppEventBus.emit(BalanceChangedEvent(sourceModule: 'exchange'));
      }
    } catch (e, stackTrace) {
      debugPrint('❌ exchangeWallet() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(
        localizationOrNull?.allControllerLoadError ??
            'Something went wrong. Please try again.',
      );
    } finally {
      isExchangeWalletLoading.value = false;
    }
  }

  // ------------------ cleanup ------------------

  void clearFields() {
    exchangeConfigModel.value = ExchangeConfigModel();
    converterModel.value = ConverterModel();
    amountController.clear();
    charge.value = 0.0;
    totalAmount.value = 0.0;
    exchangeRate.value = 0.0;
    exchangeReviewRate.value = 0.0;
    exchangeAmount.value = 0.0;
    liveToAmount.value = 0.0;
    fromWalletBorderFocused.value = false;
    toWalletBorderFocused.value = false;
    isContinueInvalid.value = false;
    _rateManager.reset();
  }

  // ------------------ accessors used by the UI ------------------

  bool get isAmountValid {
    final from = fromWallet.value;
    final to = toWallet.value;
    final text =
        amountInput.value.isNotEmpty ? amountInput.value : amountController.text;
    return _validationService.isAmountValid(
      fromWallet: from,
      toWallet: to,
      amountText: text,
    );
  }
}
