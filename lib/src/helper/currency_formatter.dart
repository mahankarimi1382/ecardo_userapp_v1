// =============================================================================
// currency_formatter.dart — T11-5a (Task-11 wave)
// -----------------------------------------------------------------------------
// WHAT THIS FILE IS:
//   The central, app-wide currency/amount formatter. It replaces the scattered
//   manual `value.toStringAsFixed(decimals)` calls (70+ sites) that rendered
//   money WITHOUT thousands grouping — e.g. `1234567.5 USD` — with a single
//   intl `NumberFormat`-based implementation that is:
//     * grouping-aware (1,234,567.5),
//     * decimal-precision faithful (callers pass the SAME decimals they used
//       before — no rounding behavior change, only display grouping changes),
//     * locale-aware (follows Intl.defaultLocale, matching the house style of
//       MoneyDisplayText — Persian/Arabic digits render correctly in fa/ar),
//     * API-driven by default via DynamicDecimalsHelper when callers do not
//       pass an explicit decimal count (server config is never hardcoded).
//
// WHAT WAS DONE TO CREATE IT (Task-11 / T11-5a):
//   1. Designed against intl ^0.20.2 (already a direct dependency).
//   2. Migrated the money-display call sites of the core flows (transfer,
//      withdraw, add_money, cash_out, make_payment, request_money, gift_code,
//      gift_card, bill_payment ×6 services, p2p card) mechanically via
//      scripts/migrate_currency_formatter.py — every migration kept the
//      original decimals expression and only swapped the formatting call.
//   3. Remittance + Exchange intentionally NOT migrated: both already use
//      their own API-driven, audited formatters (RemittanceController
//      .formatAmount(currencyId:) and MoneyDisplayText). Zero behavior change
//      policy for already-verified flows.
//
// SAFETY:
//   * `format(null)` returns "0" — previously `null!.toStringAsFixed()`
//     crashed; this is strictly safer.
//   * No payload/formatting for API requests — display-only. Request bodies
//     keep sending raw numbers/strings.
// =============================================================================
import 'package:intl/intl.dart';

import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final CurrencyFormatter instance = CurrencyFormatter._();

  static final DynamicDecimalsHelper _dynamicDecimals =
      DynamicDecimalsHelper();

  /// Resolve how many decimal digits to render.
  ///
  /// Precedence:
  ///   1. [decimals] — explicit caller-provided count (migration sites pass
  ///      their original expression here, so precision is unchanged).
  ///   2. DynamicDecimalsHelper — per-currency derivation from API settings
  ///      (site_currency / site_currency_decimals), 8 for crypto.
  ///   3. Fallback: 2.
  int resolveDecimals({
    int? decimals,
    String? currencyCode,
    String? siteCurrencyCode,
    String? siteCurrencyDecimals,
    bool isCrypto = false,
  }) {
    if (decimals != null) {
      return decimals.clamp(0, 12);
    }
    if (currencyCode != null &&
        currencyCode.isNotEmpty &&
        siteCurrencyCode != null &&
        siteCurrencyCode.isNotEmpty) {
      return _dynamicDecimals.getDynamicDecimals(
        currencyCode: currencyCode,
        siteCurrencyCode: siteCurrencyCode,
        siteCurrencyDecimals: siteCurrencyDecimals,
        isCrypto: isCrypto,
      );
    }
    return 2;
  }

  /// Format a monetary value for display.
  ///
  /// [value]        — the amount (num or null; null renders as "0").
  /// [decimals]     — explicit decimal digits (highest precedence).
  /// [currencyCode] — ISO code of the displayed currency (enables the
  ///                  API-driven decimal derivation when [decimals] is null).
  /// [symbol]       — optional trailing currency label, e.g. "USD". When
  ///                  provided the result is "<amount> <symbol>".
  /// [locale]       — optional BCP-47 tag; defaults to Intl.defaultLocale.
  String format(
    num? value, {
    int? decimals,
    String? currencyCode,
    String? siteCurrencyCode,
    String? siteCurrencyDecimals,
    bool isCrypto = false,
    String? symbol,
    String? locale,
  }) {
    final double amount = value?.toDouble() ?? 0.0;
    final int resolved = resolveDecimals(
      decimals: decimals,
      currencyCode: currencyCode,
      siteCurrencyCode: siteCurrencyCode,
      siteCurrencyDecimals: siteCurrencyDecimals,
      isCrypto: isCrypto,
    );

    final NumberFormat formatter = NumberFormat.decimalPatternDigits(
      decimalDigits: resolved,
      locale: locale,
    );
    final String formatted = formatter.format(amount);

    if (symbol == null || symbol.isEmpty) {
      return formatted;
    }
    return '$formatted $symbol';
  }
}
