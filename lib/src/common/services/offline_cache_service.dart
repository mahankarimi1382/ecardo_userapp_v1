import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight read-only offline data cache using SharedPreferences.
/// Caches last-good API responses so users can view data without network.
/// Financial write operations are NEVER cached (security — those use OfflineRequestQueue).
class OfflineCacheService {
  static const _prefix = 'ecardo_cache_v1_';
  static const _timestampSuffix = '_ts';

  /// Cache TTL: 24 hours for financial data
  static const Duration _financialTtl = Duration(hours: 24);

  // Cache keys
  static const String kWallets = 'wallets';
  static const String kTransactions = 'transactions';
  static const String kExchangeRates = 'exchange_rates';
  static const String kProfile = 'profile';
  static const String kAppSettings = 'app_settings';
  static const String kNotifications = 'notifications';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  /// Store data with a timestamp
  Future<void> put(String key, Map<String, dynamic> data) async {
    try {
      final prefs = await _prefs;
      await prefs.setString(_prefix + key, jsonEncode(data));
      await prefs.setInt(
        _prefix + key + _timestampSuffix,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      debugPrint('⚠️ [OfflineCache] Failed to cache $key: $e');
    }
  }

  /// Retrieve cached data if not expired
  Future<Map<String, dynamic>?> get(String key, {Duration? ttl}) async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_prefix + key);
      final ts = prefs.getInt(_prefix + key + _timestampSuffix);
      if (json == null || ts == null) return null;

      final age = DateTime.now().millisecondsSinceEpoch - ts;
      final maxAge = (ttl ?? _financialTtl).inMilliseconds;
      if (age > maxAge) return null; // expired

      return Map<String, dynamic>.from(jsonDecode(json) as Map);
    } catch (e) {
      debugPrint('⚠️ [OfflineCache] Failed to read $key: $e');
      return null;
    }
  }

  /// Get data even if expired — for showing stale data with a timestamp
  Future<({Map<String, dynamic>? data, DateTime? cachedAt, bool isStale})> getWithMeta(
    String key, {
    Duration? ttl,
  }) async {
    try {
      final prefs = await _prefs;
      final json = prefs.getString(_prefix + key);
      final ts = prefs.getInt(_prefix + key + _timestampSuffix);
      if (json == null || ts == null) {
        return (data: null, cachedAt: null, isStale: false);
      }

      final cachedAt = DateTime.fromMillisecondsSinceEpoch(ts);
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      final maxAge = (ttl ?? _financialTtl).inMilliseconds;
      final isStale = age > maxAge;

      return (
        data: Map<String, dynamic>.from(jsonDecode(json) as Map),
        cachedAt: cachedAt,
        isStale: isStale,
      );
    } catch (e) {
      return (data: null, cachedAt: null, isStale: false);
    }
  }

  /// Remove specific key
  Future<void> evict(String key) async {
    final prefs = await _prefs;
    await prefs.remove(_prefix + key);
    await prefs.remove(_prefix + key + _timestampSuffix);
  }

  /// Clear all cached data (on logout)
  Future<void> clearAll() async {
    final prefs = await _prefs;
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix)).toList();
    for (final k in keys) {
      await prefs.remove(k);
    }
  }

  /// Get human-readable cache age string
  String ageLabel(DateTime cachedAt) {
    final diff = DateTime.now().difference(cachedAt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
