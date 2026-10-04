import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/fee_ecardo_rate_source.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/live_rate_badge.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';

/// Manager for live exchange rates, rate subscriptions, drift detection,
/// and review-step rate locking.
///
/// Responsibilities:
///   - Encapsulate live rate subscription through [ExchangeRateService].
///   - Normalize currency codes (e.g. USDT -> USDT_IRT for fee.ecardo.ir).
///   - Compute cross-rates (1 FROM = (fromRate / toRate) TO) based on IRR base unit.
///   - Track previous and current rates to derive [rateDirection] for UI badges.
///   - Lock the rate when entering the Review step.
///   - Track drift (>0.01%) and 60-second expiration to alert user of stale rates.
///   - Provide clean lifecycle methods ([init], [dispose], [reset]).
class ExchangeRateManager {
  ExchangeRateManager({ExchangeRateService? rateService})
      : _rateService = rateService ??
            (Get.isRegistered<ExchangeRateService>()
                ? Get.find<ExchangeRateService>()
                : ExchangeRateService());

  final ExchangeRateService _rateService;

  /// Underlying rate service instance.
  ExchangeRateService get rateService => _rateService;

  // ------------------ rate direction tracking ------------------
  /// Previously displayed live rate (used to compute direction arrow).
  final RxDouble previousRate = 0.0.obs;

  /// Most recent live rate.
  final RxDouble currentRate = 0.0.obs;

  /// Direction derived from [previousRate] → [currentRate].
  final Rx<RateDirection> rateDirection = RateDirection.unknown.obs;

  /// 24h change percentage as reported by the API (e.g. +0.17, -0.21).
  final Rxn<double> liveChangePercent = Rxn<double>();

  /// English name of the FROM currency as returned by fee.ecardo.ir.
  final RxString liveFromNameEn = ''.obs;

  /// English name of the TO currency, same source as [liveFromNameEn].
  final RxString liveToNameEn = ''.obs;

  /// True when the user is on Review step and the rate has drifted past
  /// the staleness threshold since entering that step.
  final RxBool isReviewRateStale = false.obs;

  /// Wall-clock when the user entered the Review step.
  DateTime? _reviewEnteredAt;
  DateTime? get reviewEnteredAt => _reviewEnteredAt;

  /// Rate snapshot locked when entering Review. Drift detection compares
  /// this to the live rate.
  double? _lockedReviewRate;
  double? get lockedReviewRate => _lockedReviewRate;

  // ------------------ internal timers / workers ------------------
  Timer? _reviewStaleTimer;
  Worker? _rateServiceWorker;

  /// Maximum permitted rate drift on Review before marking stale (0.01%).
  static const double driftTolerance = 0.0001;

  /// Maximum allowed duration on Review before marking stale (60s).
  static const Duration reviewStalenessDuration = Duration(seconds: 60);

  /// Frequency of the review drift & staleness evaluation (5s).
  static const Duration reviewCheckInterval = Duration(seconds: 5);

  /// Initializes live rate subscription worker.
  void init({
    required ValueGetter<String?> fromCodeProvider,
    required ValueGetter<String?> toCodeProvider,
    VoidCallback? onRateUpdated,
  }) {
    _rateServiceWorker?.dispose();
    _rateServiceWorker = ever(_rateService.rates, (rates) {
      onRatesChanged(
        rates,
        fromCode: fromCodeProvider(),
        toCode: toCodeProvider(),
      );
      onRateUpdated?.call();
    });
  }

  /// Subscribes to rates for the given from/to wallet currency codes.
  void subscribeWallets(String? fromCode, String? toCode) {
    final codes = <String>[
      if (fromCode != null && fromCode.isNotEmpty) fromCode,
      if (toCode != null && toCode.isNotEmpty) toCode,
    ];
    if (codes.isNotEmpty) {
      _rateService.subscribe(codes);
    }
  }

  /// Unsubscribes from the given wallet codes.
  void unsubscribeWallets(String? fromCode, String? toCode) {
    final codes = <String>[
      if (fromCode != null && fromCode.isNotEmpty) fromCode,
      if (toCode != null && toCode.isNotEmpty) toCode,
    ];
    if (codes.isNotEmpty) {
      _rateService.unsubscribe(codes);
    }
  }

  /// Clears all rate subscriptions and pauses polling.
  void clearSubscriptions() {
    _rateService.clearSubscriptions();
  }

  /// Maps a wallet currency code to fee.ecardo.ir API code:
  ///   - "USDT" → "USDT_IRT"  (Tether is priced in Toman by the API)
  ///   - "IRR" → "IRR"        (base unit)
  ///   - others pass through unchanged
  String normalizeApiCode(String walletCode) {
    final upper = walletCode.toUpperCase();
    if (upper == 'USDT') return 'USDT_IRT';
    return upper;
  }

  /// Computes cross-rate from two rates quoted in IRR.
  /// Each rate represents: 1 unit of currency = X IRR.
  /// Cross rate: 1 FROM = (fromRate / toRate) TO.
  double? calculateCrossRate(double? fromRate, double? toRate) {
    if (fromRate == null || toRate == null) return null;
    if (fromRate <= 0 || toRate <= 0) return null;
    final rate = fromRate / toRate;
    if (!rate.isFinite || rate <= 0) return null;
    return rate;
  }

  /// Handles incoming live rates map from [ExchangeRateService].
  void onRatesChanged(
    Map<String, double> rates, {
    required String? fromCode,
    required String? toCode,
  }) {
    if (fromCode == null || toCode == null) return;
    final upperFrom = fromCode.toUpperCase();
    final upperTo = toCode.toUpperCase();
    if (upperFrom.isEmpty || upperTo.isEmpty) return;

    final apiFromCode = normalizeApiCode(upperFrom);
    final apiToCode = normalizeApiCode(upperTo);

    final fromRate = rates[apiFromCode] ?? (apiFromCode == 'IRR' ? 1.0 : null);
    final toRate = rates[apiToCode] ?? (apiToCode == 'IRR' ? 1.0 : null);

    final newRate = calculateCrossRate(fromRate, toRate);
    if (newRate == null) return;

    bumpLiveRate(newRate);

    // Extract 24h change percent and names from source if available
    final source = _rateService.source;
    if (source is FeeEcardoRateSource) {
      final entries = source.lastEntries;
      final fromEntry = entries[apiFromCode];
      final toEntry = entries[apiToCode];
      liveChangePercent.value = fromEntry?.changePercent;
      liveFromNameEn.value = fromEntry?.nameEn ?? '';
      liveToNameEn.value = toEntry?.nameEn ?? '';
    }
  }

  /// Bumps [currentRate] with [newRate], tracks [previousRate] and derives [rateDirection].
  void bumpLiveRate(double newRate) {
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

  /// Recomputes static exchange rate (1 from = X to) from the local currency list.
  void calculateStaticRate({
    required Wallets? fromWallet,
    required Wallets? toWallet,
    required List<CurrenciesData> currenciesList,
    required RxDouble targetStaticRate,
  }) {
    final fromCode = fromWallet?.code;
    final toCode = toWallet?.code;
    if (fromCode == null || toCode == null) return;

    final fromCurrency = currenciesList.firstWhere(
      (c) => c.code == fromCode,
      orElse: () => CurrenciesData(
        conversionRate: "1",
        code: fromCode,
      ),
    );

    final toCurrency = currenciesList.firstWhere(
      (c) => c.code == toCode,
      orElse: () => CurrenciesData(
        conversionRate: "1",
        code: toCode,
      ),
    );

    final double fromRate =
        double.tryParse(fromCurrency.conversionRate ?? "1") ?? 1.0;
    final double toRate =
        double.tryParse(toCurrency.conversionRate ?? "1") ?? 1.0;

    if (fromRate <= 0) {
      targetStaticRate.value = 1.0;
    } else {
      targetStaticRate.value = 1 / fromRate * toRate;
    }

    // Benchmark fallback if rates are 1.0 or 0 and currency codes differ
    if (((targetStaticRate.value - 1.0).abs() < 1e-6 || targetStaticRate.value <= 0) &&
        fromCode.toUpperCase() != toCode.toUpperCase()) {
      final fallback = _benchmarkCrossRate(fromCode, toCode);
      if (fallback != null && fallback > 0) {
        targetStaticRate.value = fallback;
      }
    }

    bumpLiveRate(targetStaticRate.value);
  }

  static double? _benchmarkCrossRate(String from, String to) {
    final f = from.toUpperCase().trim();
    final t = to.toUpperCase().trim();
    if (f == t) return 1.0;

    // Standard baseline rate map against USD
    const ratesAgainstUsd = <String, double>{
      'USD': 1.0,
      'USDT': 1.0,
      'EUR': 0.92,
      'GBP': 0.77,
      'AED': 3.67,
      'TRY': 34.2,
      'IRT': 65000.0,
      'TOMAN': 65000.0,
      'IRR': 650000.0,
    };

    final fRate = ratesAgainstUsd[f];
    final tRate = ratesAgainstUsd[t];

    if (fRate != null && tRate != null && fRate > 0) {
      return (1.0 / fRate) * tRate;
    }
    return null;
  }

  // ------------------ Review Rate Locking & Staleness ------------------

  /// Locks rate snapshot when entering Review step and starts staleness watcher.
  void lockRateForReview([double? rate]) {
    _lockedReviewRate = rate ?? currentRate.value;
    _reviewEnteredAt = DateTime.now();
    isReviewRateStale.value = false;
    startReviewStaleWatcher();
  }

  /// User acknowledged rate update — re-locks rate and resets staleness flag.
  void acknowledgeRateChange([double? rate]) {
    _lockedReviewRate = rate ?? currentRate.value;
    _reviewEnteredAt = DateTime.now();
    isReviewRateStale.value = false;
  }

  /// Clears review rate lock and stops the staleness watcher timer.
  void clearReviewLock() {
    _reviewStaleTimer?.cancel();
    _reviewStaleTimer = null;
    _reviewEnteredAt = null;
    _lockedReviewRate = null;
    isReviewRateStale.value = false;
  }

  /// Starts the periodic staleness watcher (checks every 5 seconds).
  void startReviewStaleWatcher() {
    _reviewStaleTimer?.cancel();
    _reviewStaleTimer = Timer.periodic(reviewCheckInterval, (_) {
      final enteredAt = _reviewEnteredAt;
      final lockedRate = _lockedReviewRate;
      if (enteredAt == null || lockedRate == null) return;

      if (checkDriftOrExpired(
        enteredAt: enteredAt,
        lockedRate: lockedRate,
        currentRate: currentRate.value,
      )) {
        isReviewRateStale.value = true;
      }
    });
  }

  /// Evaluates whether the review rate has drifted beyond tolerance or expired.
  bool checkDriftOrExpired({
    required DateTime enteredAt,
    required double lockedRate,
    required double currentRate,
    double tolerance = driftTolerance,
    Duration maxDuration = reviewStalenessDuration,
  }) {
    final elapsed = DateTime.now().difference(enteredAt);
    final drift = (currentRate - lockedRate).abs();
    final driftPct = lockedRate == 0 ? 0.0 : drift / lockedRate;

    return driftPct > tolerance || elapsed >= maxDuration;
  }

  /// Calculates rate drift percentage.
  double calculateDriftPercentage({
    required double currentRate,
    required double lockedRate,
  }) {
    if (lockedRate == 0) return 0.0;
    return ((currentRate - lockedRate).abs() / lockedRate);
  }

  /// Resets all rate states to defaults.
  void reset() {
    previousRate.value = 0.0;
    currentRate.value = 0.0;
    rateDirection.value = RateDirection.unknown;
    liveChangePercent.value = null;
    liveFromNameEn.value = '';
    liveToNameEn.value = '';
    clearReviewLock();
  }

  /// Disposes timers, workers, and rate subscriptions.
  void dispose({String? fromCode, String? toCode}) {
    clearReviewLock();
    _rateServiceWorker?.dispose();
    _rateServiceWorker = null;

    unsubscribeWallets(fromCode, toCode);
    clearSubscriptions();
  }
}
