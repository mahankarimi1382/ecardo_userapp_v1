import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Renders a monetary amount with a strict typographic hierarchy:
///   - Integer part: large, [FontWeight.w900], full-opacity.
///   - Decimal separator + decimal digits: smaller, [FontWeight.w500],
///     55% opacity — visually de-emphasised so the eye reads the magnitude
///     first, the cents/wei second.
///   - Optional trailing zeros after the decimal point are kept (not stripped)
///     because in financial UI they signal precision, e.g. `1,250.00` reads
///     as "currency" while `1,250` reads as "count".
///
/// Locale-aware: thousands separator and decimal separator follow
/// [locale] (passed in) or [Localizations.localeOf] (default). Persian and
/// Arabic digits are rendered correctly when the locale is `fa` / `ar`.
///
/// Designed as a reusable component — no exchange-specific dependency. Can
/// be lifted into `lib/src/common/widgets/` later if other modules adopt
/// the same convention.
class MoneyDisplayText extends StatelessWidget {
  const MoneyDisplayText({
    super.key,
    required this.amount,
    this.locale,
    this.decimals = 2,
    this.currencyCode,
    this.integerStyle,
    this.decimalStyle,
    this.integerColor,
    this.decimalColor,
    this.currencyStyle,
    this.textAlign = TextAlign.start,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
  });

  /// The numeric value to render. NaN / Infinity are rendered as `—`.
  final double amount;

  /// BCP-47 tag (e.g. `en`, `fa`, `ar`). If null, the widget reads the
  /// ambient [Localizations.localeOf].
  final String? locale;

  /// Number of decimal digits to display. For fiat use 2, for crypto up to 8.
  /// Callers should pass through [DynamicDecimalsHelper.getDynamicDecimals].
  final int decimals;

  /// Optional currency code rendered after the amount, e.g. `USDT`.
  final String? currencyCode;

  /// Optional overrides — if null, sensible defaults are used.
  final TextStyle? integerStyle;
  final TextStyle? decimalStyle;
  final TextStyle? currencyStyle;
  final Color? integerColor;
  final Color? decimalColor;

  final TextAlign textAlign;
  final int maxLines;
  final TextOverflow overflow;

  @override
  Widget build(BuildContext context) {
    if (amount.isNaN || amount.isInfinite) {
      return Text(
        '—',
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
        style: integerStyle ??
            TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: integerColor ?? Theme.of(context).colorScheme.onSurface,
            ),
      );
    }

    final effectiveLocale = locale ?? _localeTag(context);
    final formatted = _format(amount, decimals, effectiveLocale);

    // Split into integer part and decimal part.
    // NumberFormat always uses the locale's separators, so we split on the
    // actual decimal separator rather than '.'.
    final decimalSeparator = _decimalSeparatorFor(effectiveLocale);
    final parts = formatted.split(decimalSeparator);
    final integerPart = parts.first;
    final decimalPart = parts.length > 1 ? decimalSeparator + parts[1] : '';

    final baseColor = integerColor ?? Theme.of(context).colorScheme.onSurface;
    final fadedColor =
        decimalColor ?? baseColor.withValues(alpha: 0.55);

    final iStyle = integerStyle ??
        TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 22,
          color: baseColor,
          letterSpacing: 0,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    final dStyle = decimalStyle ??
        TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: fadedColor,
          letterSpacing: 0,
          fontFeatures: const [FontFeature.tabularFigures()],
        );
    final cStyle = currencyStyle ??
        TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: fadedColor,
          letterSpacing: 0,
        );

    return RichText(
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      text: TextSpan(
        children: [
          TextSpan(text: integerPart, style: iStyle),
          if (decimalPart.isNotEmpty) TextSpan(text: decimalPart, style: dStyle),
          if (currencyCode != null && currencyCode!.isNotEmpty) ...[
            const TextSpan(text: ' '),
            TextSpan(text: currencyCode, style: cStyle),
          ],
        ],
      ),
    );
  }

  /// Formats [value] with [decimalDigits] and a thousand separator, in
  /// [locale]. Falls back to `en` if Intl doesn't have data for the locale.
  String _format(double value, int decimalDigits, String localeTag) {
    try {
      final nf = NumberFormat.currency(
        locale: localeTag,
        symbol: '',
        decimalDigits: decimalDigits,
      );
      // NumberFormat.currency always emits a trailing space before the
      // (empty) symbol — strip it.
      return nf.format(value).trim();
    } catch (_) {
      // Intl can throw on unknown locales — degrade to a safe format.
      return value.toStringAsFixed(decimalDigits);
    }
  }

  String _localeTag(BuildContext context) {
    final l = Localizations.localeOf(context);
    return l.toLanguageTag();
  }

  /// Returns the decimal separator used by [localeTag] (or `.` if unknown).
  String _decimalSeparatorFor(String localeTag) {
    try {
      final symbols = NumberFormat.decimalPattern(localeTag).symbols;
      return symbols.DECIMAL_SEP;
    } catch (_) {
      return '.';
    }
  }
}
