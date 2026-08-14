import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import 'exchange_rate_source.dart';
import 'fee_ecardo_rate_source.dart';

/// Lifecycle-managed service that keeps a fresh copy of exchange rates in
/// memory and exposes them reactively to the [ExchangeController].
///
/// Design rules (per acceptance criteria):
///   - 60-second polling via [Timer.periodic]. The timer is owned by this
///     service and cancelled in [onClose]. Never instantiated inside a
///     controller without registration through `Get.put(..., permanent: false)`.
///   - In-memory cache of the last successful fetch. If a refresh fails, the
///     UI receives the cached value with a `stale` flag — never a hard error.
///   - Silent retry on failure. Only after 3 consecutive failures does the
///     service flip [isDisconnected] so the UI can show a soft banner — no
///     toast.
///   - The service is completely independent of the main [NetworkService]:
///     it owns its own Dio instance via [ExchangeRateSource].
class ExchangeRateService extends GetxService {
  ExchangeRateService({ExchangeRateSource? source})
      : _source = source ?? FeeEcardoRateSource();

  final ExchangeRateSource _source;

  /// Refresh interval. Per spec: every 60 seconds.
  static const Duration refreshInterval = Duration(seconds: 60);

  /// A cached entry is considered "stale" after this — surfaced in UI as
  /// "showing last known rate" rather than "live".
  static const Duration staleThreshold = Duration(seconds: 90);

  /// Consecutive failures before the soft-disconnect banner appears.
  static const int _maxConsecutiveFailures = 3;

  Timer? _timer;
  int _consecutiveFailures = 0;
  CachedRate? _cache;

  /// The latest known rates (may be empty if no successful fetch has ever
  /// happened).
  final RxMap<String, double> rates = <String, double>[].obs;

  /// True when [rates] comes from a cache older than [staleThreshold].
  final RxBool isStale = false.obs;

  /// True after [_maxConsecutiveFailures] consecutive failed refreshes.
  /// UI should show a soft "rate service unavailable" banner — not a toast.
  final RxBool isDisconnected = false.obs;

  /// Timestamp of the last successful refresh. Null until first success.
  final Rx<DateTime?> lastUpdatedAt = Rx<DateTime?>(null);

  /// Subscribers asking the service to refresh for a specific set of
  /// currencies. The union of all subscribers is fetched on each tick so
  /// we don't make N calls for N controllers.
  final Set<String> _subscribedCodes = <String>{};

  bool _initialized = false;

  /// Called by [ExchangeController] to declare which currency codes it
  /// currently needs. Triggers an immediate fetch on first call, then a
  /// 60-second periodic refresh.
  void subscribe(List<String> codes) {
    if (codes.isEmpty) return;
    final added = _subscribedCodes.addAll(codes.map((e) => e.toUpperCase()));
    if (!_initialized) {
      _initialized = true;
      // Fire immediately so the UI doesn't wait a full minute for the first
      // data point.
      unawaited(_refresh());
      _timer = Timer.periodic(refreshInterval, (_) => _refresh());
    } else if (added) {
      // New currency code subscribed mid-session — fetch immediately so the
      // user doesn't see a placeholder for up to 60s.
      unawaited(_refresh());
    }
  }

  /// Removes codes that no longer interest the caller. The service keeps
  /// running as long as at least one code is subscribed.
  void unsubscribe(List<String> codes) {
    _subscribedCodes.removeAll(codes.map((e) => e.toUpperCase()));
    if (_subscribedCodes.isEmpty) {
      _timer?.cancel();
      _timer = null;
      _initialized = false;
    }
  }

  /// Returns the cached rate for [code], or `null` if unknown.
  double? rateFor(String code) {
    final r = rates[code.toUpperCase()];
    return r;
  }

  /// Force an immediate refresh (e.g. user pulled-to-refresh). Always
  /// returns silently — UI reads the reactive fields afterwards.
  Future<void> forceRefresh() async {
    await _refresh();
  }

  Future<void> _refresh() async {
    if (_subscribedCodes.isEmpty) return;

    final codes = _subscribedCodes.toList(growable: false);
    final fresh = await _source.fetchRates(currencyCodes: codes);

    if (fresh.isEmpty) {
      _consecutiveFailures += 1;
      if (_consecutiveFailures >= _maxConsecutiveFailures) {
        isDisconnected.value = true;
      }
      if (_cache != null) {
        isStale.value = _cache!.isStale(staleAfter: staleThreshold);
      }
      // Keep cached rates visible — UI falls back gracefully.
      return;
    }

    _consecutiveFailures = 0;
    isDisconnected.value = false;
    _cache = CachedRate(
      rates: Map.unmodifiable(fresh),
      fetchedAt: DateTime.now(),
    );
    rates.assignAll(fresh);
    isStale.value = false;
    lastUpdatedAt.value = _cache!.fetchedAt;
  }

  @override
  void onClose() {
    _timer?.cancel();
    _timer = null;
    _subscribedCodes.clear();
    super.onClose();
  }
}
