/// Abstract source for live exchange rates.
///
/// The exchange module depends only on this abstraction — never on a specific
/// URL or response shape. The default implementation
/// [FeeEcardoRateSource] talks to https://fee.ecardo.ir, but a future
/// implementation (Binance, CoinGecko, internal aggregator, etc.) can be
/// dropped in without touching the controller or UI.
abstract class ExchangeRateSource {
  /// Fetches the rate for each requested currency code.
  ///
  /// Returns a map of `{currency_code: rate_in_site_currency}`.
  /// Implementations should:
  ///   - never throw — return an empty map on failure and let the caller
  ///     decide whether to fall back to cache or another source.
  ///   - be idempotent and safe to call concurrently.
  Future<Map<String, double>> fetchRates({required List<String> currencyCodes});

  /// Human-readable label for analytics / debug only.
  String get label;
}

/// Rate entry cached in memory after a successful fetch.
class CachedRate {
  final Map<String, double> rates;
  final DateTime fetchedAt;

  CachedRate({required this.rates, required this.fetchedAt});

  /// True when [fetchedAt] is older than [staleAfter].
  bool isStale({required Duration staleAfter}) {
    return DateTime.now().difference(fetchedAt) > staleAfter;
  }
}
