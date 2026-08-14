import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'exchange_rate_source.dart';

/// Default [ExchangeRateSource] backed by `https://fee.ecardo.ir`.
///
/// The endpoint shape is intentionally isolated here so the rest of the
/// module stays agnostic. If the real API path or response envelope differs
/// from the current assumption, edit ONLY this file — no other file in the
/// exchange module references the URL or response structure directly.
///
/// Tolerated response shapes (any of the following):
///   1. `{ "data": { "rates": { "USD": 1.0, ... } } }`
///   2. `{ "data": { "USD": 1.0, ... } }`
///   3. `{ "USD": 1.0, "EUR": 0.92, ... }`
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
                headers: const {'Accept': 'application/json'},
              ),
            );

  @override
  String get label => 'fee.ecardo.ir';

  @override
  Future<Map<String, double>> fetchRates({
    required List<String> currencyCodes,
  }) async {
    if (currencyCodes.isEmpty) return const {};

    try {
      final response = await _client.get<dynamic>(
        '/api/v1/rates',
        queryParameters: {
          'currencies': currencyCodes.join(','),
        },
      );

      final parsed = _parseResponse(response.data);
      if (parsed.isNotEmpty) return parsed;

      // Try the alternative path before giving up — the production endpoint
      // shape is not confirmed yet. Silent — only one extra HTTP call on
      // first failure.
      final fallbackResponse = await _client.get<dynamic>(
        '/rates',
        queryParameters: {
          'currencies': currencyCodes.join(','),
        },
      );
      return _parseResponse(fallbackResponse.data);
    } on DioException catch (e, st) {
      // Network/HTTP error — bubble up an empty map so the caller can fall
      // back to cache.
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

  /// Tolerates three response shapes:
  ///   1. `{ "data": { "rates": { ... } } }`
  ///   2. `{ "data": { "USD": 1.0, ... } }`
  ///   3. `{ "USD": 1.0, "EUR": 0.92, ... }`
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

    // Strip envelope(s).
    Object? inner = map;
    while (inner is Map<String, dynamic> &&
        inner.containsKey('data') &&
        inner['data'] is Map<String, dynamic>) {
      inner = inner['data'];
    }

    if (inner is! Map<String, dynamic>) return const {};

    // Case 1: explicit "rates" key.
    if (inner['rates'] is Map<String, dynamic>) {
      return _coerceMap(inner['rates'] as Map<String, dynamic>);
    }

    // Case 2/3: flat map of code → number.
    return _coerceMap(inner);
  }

  Map<String, double> _coerceMap(Map<String, dynamic> raw) {
    final out = <String, double>{};
    raw.forEach((key, value) {
      final parsed = _toDouble(value);
      if (parsed != null && parsed.isFinite && parsed > 0) {
        out[key.toUpperCase()] = parsed;
      }
    });
    return out;
  }

  double? _toDouble(Object? v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}
