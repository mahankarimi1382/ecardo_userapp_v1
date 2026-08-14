import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/model/converter_model.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_config_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/live_rate_badge.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

/// Controller for the redesigned Exchange flow.
///
/// Responsibilities:
///   - Load wallets / currencies / user / exchange-config (unchanged from
///     legacy logic — only orchestration moved here).
///   - Subscribe to [ExchangeRateService] for live rates and recompute the
///     preview amount when either wallet changes or the rate changes.
///   - Track [previousRate] / [currentRate] so the UI can render a direction
///     arrow on the live rate badge.
///   - Debounce amount input — typing 6 digits must not fire 6 conversion
///     API calls. A 300ms debounce is enforced via [Timer].
///   - When the user is typing (focus on amount field), rate refreshes
///     silently update the badge — they never steal focus or jump the
///     layout. Only the displayed number animates.
///   - Lock the rate at the moment the user leaves Amount step → Review
///     step. While on Review, watch for drift; if rate changes by more than
///     0.01% or 60 seconds pass, surface a "rate updated" banner and
///     disable confirm until the user re-confirms.
class ExchangeController extends GetxController {
  ExchangeController({ExchangeRateService? rateService})
      : _rateService = rateService ?? Get.find<ExchangeRateService>();

  final ExchangeRateService _rateService;

  // ------------------ loading flags ------------------
  final RxBool isLoading = false.obs;
  final RxBool isExchangeConfigLoading = false.obs;
  final RxBool isExchangeWalletLoading = false.obs;
  final RxBool isCalculateExchangeRateLoading = false.obs;

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
  final localization = AppLocalizations.of(Get.context!)!;

  // ------------------ rate direction tracking ------------------
  /// Previously displayed live rate (used to compute direction arrow).
  final RxDouble previousRate = 0.0.obs;

  /// Most recent live rate.
  final RxDouble currentRate = 0.0.obs;

  /// Direction derived from [previousRate] → [currentRate].
  final Rx<RateDirection> rateDirection = RateDirection.unknown.obs;

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

  /// True when the user pressed Continue but validation failed — used to
  /// render the Continue button in an errored / disabled state.
  final RxBool isContinueInvalid = false.obs;

  /// True when the user is on Review step and the rate has drifted past
  /// the staleness threshold since entering that step.
  final RxBool isReviewRateStale = false.obs;

  /// Wall-clock when the user entered the Review step. Used to compute
  /// "60 seconds elapsed" — even if the rate hasn't changed, the user has
  /// been staring at the rate long enough that we should ask them to
  /// re-confirm.
  DateTime? _reviewEnteredAt;

  /// Rate snapshot locked when entering Review. Drift detection compares
  /// this to the live rate.
  double? _lockedReviewRate;

  // ------------------ internal timers ------------------
  Timer? _amountDebounce;
  Timer? _reviewStaleTimer;
  Worker? _rateServiceWorker;
  StreamSubscription? _rateSubscription;

  @override
  void onInit() {
    super.onInit();
    loadData();
    amountFocusNode.addListener(_handleAmountFocusChange);

    // React to live rate updates from the service — only recompute the
    // preview, never steal focus.
    _rateSubscription = _rateService.rates.listen(_onRatesChanged);
  }

  @override
  void onClose() {
    // CRITICAL: cancel every timer / subscription. GetX leaks are the #1
    // source of jank in this kind of screen.
    _amountDebounce?.cancel();
    _amountDebounce = null;
    _reviewStaleTimer?.cancel();
    _reviewStaleTimer = null;
    _rateServiceWorker?.dispose();
    _rateServiceWorker = null;
    _rateSubscription?.cancel();
    _rateSubscription = null;

    // Tell the rate service we no longer need rates for our codes.
    final codes = <String>{
      if (fromWallet.value?.code != null) fromWallet.value!.code!,
      if (toWallet.value?.code != null) toWallet.value!.code!,
    }.toList();
    if (codes.isNotEmpty) {
      _rateService.unsubscribe(codes);
    }

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
    isLoading.value = false;
    _subscribeToRateService();
  }

  /// Subscribes the rate service to the currently selected from/to codes.
  /// Called once after the initial wallet load completes.
  void _subscribeToRateService() {
    final codes = <String>[
      if (fromWallet.value?.code != null) fromWallet.value!.code!,
      if (toWallet.value?.code != null) toWallet.value!.code!,
    ];
    if (codes.isNotEmpty) {
      _rateService.subscribe(codes);
    }
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
        _lockedReviewRate = currentRate.value;
        _reviewEnteredAt = DateTime.now();
        isReviewRateStale.value = false;
        await fetchExchangeConfig();
        _startReviewStaleWatcher();
      }
    } else {
      currentStep.value = 0;
    }
  }

  /// Pops back to the Amount step and clears the locked-rate state.
  void backToAmountStep() {
    currentStep.value = 0;
    _reviewStaleTimer?.cancel();
    _reviewStaleTimer = null;
    _reviewEnteredAt = null;
    _lockedReviewRate = null;
    isReviewRateStale.value = false;
  }

  /// Triggered when the user taps "Confirm" on the Review step and the
  /// rate-staleness banner is showing. Re-locks the rate to the current
  /// live value and re-enables confirm.
  void acknowledgeRateChange() {
    _lockedReviewRate = currentRate.value;
    _reviewEnteredAt = DateTime.now();
    isReviewRateStale.value = false;
  }

  void _startReviewStaleWatcher() {
    _reviewStaleTimer?.cancel();
    _reviewStaleTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_reviewEnteredAt == null || _lockedReviewRate == null) return;

      final elapsed = DateTime.now().difference(_reviewEnteredAt!);
      final drift = (currentRate.value - _lockedReviewRate!).abs();
      final driftPct = _lockedReviewRate == 0
          ? 0.0
          : drift / _lockedReviewRate!;

      // Two trigger conditions:
      //   1. Rate changed by more than 0.01% — material drift.
      //   2. 60 seconds elapsed since entering Review — even without
      //      drift, ask the user to re-confirm to prevent stale-rate
      //      exploitation.
      if (driftPct > 0.0001 || elapsed.inSeconds >= 60) {
        isReviewRateStale.value = true;
      }
    });
  }

  // ------------------ user / config fetch ------------------

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
    }
  }

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
    }
  }

  // ------------------ charge calculation (unchanged business logic) ----

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
        charge.value = double.tryParse(
          converterModel.value.data!.convertedAmount ?? "0",
        ) ?? 0.0;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getChargeConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    }
  }

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
        exchangeReviewRate.value = double.tryParse(
          converterModel.value.data!.rate ?? "0",
        ) ?? 0.0;
        exchangeAmount.value = double.tryParse(
          converterModel.value.data!.convertedAmount ?? "0",
        ) ?? 0.0;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ getExchangeRateConverter() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    } finally {
      isExchangeConfigLoading.value = false;
    }
  }

  // ------------------ validation (unchanged logic, decimal-aware messages) ----

  bool validateAmountStep() {
    if (fromWallet.value == null || fromWallet.value!.name?.isEmpty == true) {
      ToastHelper().showErrorToast(
        localization.exchangeValidationSelectFromWallet,
      );
      return false;
    }

    if (toWallet.value == null || toWallet.value!.name?.isEmpty == true) {
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
      siteCurrencyCode: Get.find<SettingsService>().getSetting("site_currency")!,
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

  // ------------------ wallets ------------------

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
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ fetchWallets() error: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      ToastHelper().showErrorToast(localization.allControllerLoadError);
    }
  }

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
    }
  }

  // ------------------ exchange math ------------------

  /// Recomputes [exchangeRate] (1 from = X to) from the local currency
  /// list. This is the *static* rate that comes from the main backend and
  /// is independent of the live fee.ecardo.ir feed — the live feed is
  /// surfaced separately on the badge.
  void calculateExchange() {
    if (fromWallet.value != null && toWallet.value != null) {
      final fromCurrency = currenciesList.firstWhere(
        (c) => c.code == fromWallet.value!.code,
        orElse: () => CurrenciesData(
          conversionRate: "1",
          code: fromWallet.value!.code,
        ),
      );

      final toCurrency = currenciesList.firstWhere(
        (c) => c.code == toWallet.value!.code,
        orElse: () => CurrenciesData(
          conversionRate: "1",
          code: toWallet.value!.code,
        ),
      );

      final double fromRate =
          double.tryParse(fromCurrency.conversionRate ?? "1") ?? 1;
      final double toRate =
          double.tryParse(toCurrency.conversionRate ?? "1") ?? 1;

      exchangeRate.value = 1 / fromRate * toRate;
      _bumpLiveRate(exchangeRate.value);
    }
    _scheduleLivePreview();
  }

  /// Swap from/to wallets. Fires haptic feedback and animates the swap
  /// button (handled by the widget). The controller only updates state.
  void swapWallets() {
    HapticFeedback.selectionClick();
    final tmp = fromWallet.value;
    fromWallet.value = toWallet.value;
    toWallet.value = tmp;
    calculateExchange();
    _subscribeToRateService();
  }

  /// Called by the rate service whenever a fresh batch of rates arrives.
  /// We never recompute on UI rebuild — only when rates actually change.
  void _onRatesChanged(Map<String, double> rates) {
    final fromCode = fromWallet.value?.code?.toUpperCase();
    final toCode = toWallet.value?.code?.toUpperCase();
    if (fromCode == null || toCode == null) return;

    // The service returns rates expressed in the site currency, so the
    // cross rate is rate[to] / rate[from].
    final fromRate = rates[fromCode];
    final toRate = rates[toCode];
    if (fromRate == null || toRate == null) return;
    if (fromRate == 0) return;

    final newRate = toRate / fromRate;
    if (!newRate.isFinite || newRate <= 0) return;

    _bumpLiveRate(newRate);
    _scheduleLivePreview();
  }

  void _bumpLiveRate(double newRate) {
    if ((newRate - currentRate.value).abs() < 1e-12) return;
    previousRate.value = currentRate.value;
    currentRate.value = newRate;

    if (previousRate.value == 0) {
      rateDirection.value = RateDirection.unknown;
    } else if (newRate > previousRate.value) {
      rateDirection.value = RateDirection.up;
    } else if (newRate < previousRate.value) {
      rateDirection.value = RateDirection.down;
    } else {
      rateDirection.value = RateDirection.stable;
    }
  }

  /// Debounced preview recomputation. While the user is typing, we wait
  /// 300ms after the last keystroke before hitting the converter endpoint.
  void onAmountChanged(String _) {
    isContinueInvalid.value = false;
    _amountDebounce?.cancel();
    _amountDebounce = Timer(const Duration(milliseconds: 300), () {
      _scheduleLivePreview();
    });
  }

  void _scheduleLivePreview() {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0 || currentRate.value <= 0) {
      liveToAmount.value = 0.0;
      return;
    }
    liveToAmount.value = amount * currentRate.value;
  }

  /// Quick-fill the amount field with a percentage of the from-wallet
  /// balance. Used by the 25 / 50 / 75 / Max chips.
  void setAmountPercent(double percent) {
    final balance = double.tryParse(fromWallet.value?.balance ?? '0') ?? 0.0;
    if (balance <= 0) return;
    final amount = (balance * percent).toStringAsFixed(
      fromWallet.value?.isCrypto == true ? 8 : 2,
    );
    amountController.text = amount;
    amountController.selection = TextSelection.fromPosition(
      TextPosition(offset: amountController.text.length),
    );
    onAmountChanged(amount);
  }

  // ------------------ exchange wallet submission ------------------

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
    previousRate.value = 0.0;
    currentRate.value = 0.0;
    rateDirection.value = RateDirection.unknown;
    fromWalletBorderFocused.value = false;
    toWalletBorderFocused.value = false;
    isContinueInvalid.value = false;
    isReviewRateStale.value = false;
  }

  // ------------------ accessors used by the UI ------------------

  ExchangeRateService get rateService => _rateService;

  bool get isAmountValid {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) return false;
    final min = double.tryParse(
      fromWallet.value?.exchangeLimit?.min ?? '0',
    ) ?? 0.0;
    final max = double.tryParse(
      fromWallet.value?.exchangeLimit?.max ?? '0',
    ) ?? double.infinity;
    return amount >= min && amount <= max;
  }
}
