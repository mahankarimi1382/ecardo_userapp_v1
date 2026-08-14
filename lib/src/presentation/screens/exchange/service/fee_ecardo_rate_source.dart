// FeeEcardoRateSource — full rewrite
//
// Actual API contract (verified 2026-08-14 against https://fee.ecardo.ir/api/v1/rates):
//
//   {
//     "status": "success",
//     "updated_at": "2026-08-14 21:03:34",
//     "updated_unix": 1786741414,
//     "base_unit": "IRR",
//     "rates": {
//       "USDT_IRT": { "name": "...", "name_en": "Tether Dollar", "price": 187702,
//                     "change_percent": 0.17, "unit": "تومان", "time": "00:33:03" },
//       "USD":      { ..., "price": 187800, "unit": "تومان" },
//       "EUR":      { ..., "price": 216760 },
//       "AED":      { ..., "price": 51080  },
//       "CNY":      { ..., "price": 28000  },
//       "TRY":      { ..., "price": 3910   },
//       "SAR":      { ..., "price": 50015  },
//       "RUB":      { ..., "price": 2273   }
//     },
//     "conversions": {
//       "USD_to_IRR": 1878000,   // price in Toman × 10 = IRR
//       "TRY_to_IRR": 39100, ...
//     }
//   }
//
// IMPORTANT:
//   - `price` is in TOMAN (1 USD = 187,800 Toman = 1,878,000 IRR).
//   - `base_unit` SAYS "IRR" but the per-currency prices are in Toman.
//   - `conversions` map gives the actual IRR (Toman × 10). We use this for
//     the cross-rate math because the wallet balances in the app are in IRR.
//   - `change_percent` is the 24h change. We surface it directly in the UI.
//   - `USDT_IRT` is the only crypto price exposed. For crypto-to-fiat pairs
//     where the from currency is something the API doesn't list (BTC, ETH),
//     the controller's existing calculateExchange() will use the database
//     converter endpoint instead — the rate service just provides "what's
//     available", and the controller decides which source wins.

import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'exchange_rate_source.dart';

/// One rate entry as returned by fee.ecardo.ir.
class FeeEcardoRateEntry {
  const FeeEcardoRateEntry({
    required this.code,
    required this.priceToman,
    required this.priceIrr,
    required this.changePercent,
    required this.nameFa,
    required this.nameEn,
    required this.unit,
    required this.updatedAt,
  });

  /// Canonical currency code as expected by the rest of the app
  /// (uppercased). For USDT_IRT, this is "USDT_IRT" — the controller knows
  /// to map a wallet whose code is "USDT" to this entry.
  final String code;

  /// Price in Toman (Iranian Toman = 10 IRR).
  final double priceToman;

  /// Price in IRR (Iranian Rial). Derived as priceToman × 10, OR taken
  /// from the `conversions` map if present.
  final double priceIrr;

  /// 24h change as a percentage (e.g. +0.17, -0.21). Null when API didn't
  /// return one.
  final double? changePercent;

  /// Persian name (from `name` field).
  final String nameFa;

  /// English name (from `name_en` field).
  final String nameEn;

  /// Unit string from API (usually "تومان").
  final String unit;

  /// ISO timestamp from `updated_at`.
  final String updatedAt;
}

class FeeEcardoRateSource implements ExchangeRateSource {
  static const String baseUrl = 'https://fee.ecardo.ir';

  final Dio _client;

  FeeEcardoRateSource({Dio? client})
      : _client = client ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 6),
                receiveTimeout: const Duration(seconds: 10),
                contentType: Headers.jsonContentType,
                // Cloudflare on eCardo.ir challenges any client without a
                // browser-like User-Agent. With Dio's default UA ("Dart/3.x
                // (dart:io)") the request gets a 403 + JS challenge page.
                // A full Chrome UA + Accept headers gets through.
                headers: const {
                  'Accept': 'application/json, text/plain, */*',
                  'Accept-Language': 'en-US,en;q=0.9,fa;q=0.8',
                  'User-Agent':
                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 '
                      '(KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36',
                },
              ),
            );

  @override
  String get label => 'fee.ecardo.ir';

  /// Latest full payload (including change_percent, names, etc.). Used by
  /// the UI for richer rendering. Reactive listeners can read this after
  /// [fetchRates] returns.
  Map<String, FeeEcardoRateEntry> _lastEntries = const {};
  Map<String, FeeEcardoRateEntry> get lastEntries => _lastEntries;

  @override
  Future<Map<String, double>> fetchRates({
    required List<String> currencyCodes,
  }) async {
    if (currencyCodes.isEmpty) return const {};

    try {
      final response = await _client.get<dynamic>('/api/v1/rates');
      final parsed = _parseResponse(response.data);
      if (parsed.isEmpty) {
        // Fall back to the alternative path before giving up. Silent.
        final fallback = await _client.get<dynamic>('/rates');
        return _parseResponse(fallback.data);
      }
      return parsed;
    } on DioException catch (e, st) {
      if (kDebugMode) {
        debugPrint('⚠️ FeeEcardoRateSource.fetchRates() failed: $e');
        debugPrint('📍 $st');
      }
      return const {};
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('⚠️ FeeEcardoRateSource unexpected error: $e');
        debugPrint('📍 $st');
      }
      return const {};
    }
  }

  /// Parses the actual API envelope and returns a flat
  /// `{currency_code: price_in_IRR}` map for the rest of the module.
  ///
  /// Side-effect: populates [_lastEntries] with the full per-currency
  /// detail (change_percent, name_en, unit, etc.) so the UI can render
  /// the live rate badge with real API deltas instead of deriving from
  /// two consecutive snapshots.
  Map<String, double> _parseResponse(dynamic raw) {
    if (raw == null) return const {};

    Map<String, dynamic> map;
    if (raw is String) {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return const {};
      map = decoded;
    } else if (raw is Map<String, dynamic>) {
      map = raw;
    } else {
      return const {};
    }

    final status = map['status'];
    if (status != null && status != 'success') {
      if (kDebugMode) {
        debugPrint('⚠️ fee.ecardo.ir status=$status — discarding payload');
      }
      return const {};
    }

    final ratesRaw = map['rates'];
    if (ratesRaw is! Map<String, dynamic>) return const {};

    final conversionsRaw = map['conversions'];
    final conversions = conversionsRaw is Map<String, dynamic>
        ? conversionsRaw
        : <String, dynamic>{};

    final updatedAt = map['updated_at']?.toString() ?? '';
    final out = <String, double>{};
    final entries = <String, FeeEcardoRateEntry>{};

    ratesRaw.forEach((key, value) {
      if (value is! Map<String, dynamic>) return;
      final code = key.toUpperCase();
      final priceToman = _toDouble(value['price']);
      if (priceToman == null || !priceToman.isFinite || priceToman <= 0) {
        return;
      }

      // Prefer conversions map when available (it's the canonical IRR
      // value), otherwise derive Toman × 10.
      final convKey = '${key.toUpperCase()}_TO_IRR';
      final fromConv = _toDouble(conversions[convKey]);
      final priceIrr = (fromConv != null && fromConv > 0)
          ? fromConv
          : priceToman * 10;

      final entry = FeeEcardoRateEntry(
        code: code,
        priceToman: priceToman,
        priceIrr: priceIrr,
        changePercent: _toDouble(value['change_percent']),
        nameFa: value['name']?.toString() ?? '',
        nameEn: value['name_en']?.toString() ?? '',
        unit: value['unit']?.toString() ?? '',
        updatedAt: updatedAt,
      );
      entries[code] = entry;
      out[code] = priceIrr;
    });

    if (out.isNotEmpty) {
      _lastEntries = Map.unmodifiable(entries);
    }
    return out;
  }

  double? _toDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
