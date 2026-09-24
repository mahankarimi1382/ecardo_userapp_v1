import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/response/status.dart';

/// Secure offline queue for **non-financial** mutating requests only.
///
/// Allowed (examples): profile update, language, FCM device setup, settings.
/// Never queued: transfer, withdraw, deposit, exchange, p2p, payment, gift,
/// remittance, cash-out, bill, add-money.
class OfflineRequestQueue extends GetxService {
  static const _storageKey = 'ecardo_offline_queue_v1';
  static const _maxRetries = 3;

  final RxList<Map<String, dynamic>> pending = <Map<String, dynamic>>[].obs;
  final RxBool flushFailed = false.obs;
  StreamSubscription? _sub;
  bool _flushing = false;

  static const _allowedPrefixes = <String>[
    '/user/profile',
    '/user/update',
    '/user/settings',
    '/user/language',
    '/user/fcm',
    '/setup',
    '/user/device',
  ];

  static const _blockedKeywords = <String>[
    'transfer',
    'withdraw',
    'deposit',
    'exchange',
    'payment',
    'p2p',
    'gift',
    'remittance',
    'cash-out',
    'cash_out',
    'bill',
    'wallet/add',
    'add-money',
    'add_money',
  ];

  Future<OfflineRequestQueue> init() async {
    await _load();
    _sub = Connectivity().onConnectivityChanged.listen((results) {
      final online = results.any((r) => r != ConnectivityResult.none);
      if (online) unawaited(flush());
    });
    unawaited(flush());
    return this;
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  bool isQueueable(String endpoint) {
    final e = endpoint.toLowerCase();
    for (final b in _blockedKeywords) {
      if (e.contains(b)) return false;
    }
    for (final a in _allowedPrefixes) {
      if (e.contains(a.toLowerCase())) return true;
    }
    return false;
  }

  Future<void> enqueue({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    String? idempotencyKey,
  }) async {
    if (!isQueueable(endpoint)) return;
    final key = idempotencyKey ?? _uuidV4();
    pending.add({
      'id': key,
      'method': method.toUpperCase(),
      'endpoint': endpoint,
      'data': data,
      'retries': 0,
      'created_at': DateTime.now().toIso8601String(),
    });
    await _persist();
  }

  Future<void> flush({bool manual = false}) async {
    if (_flushing || pending.isEmpty) return;
    if (!Get.isRegistered<NetworkService>()) return;
    _flushing = true;
    flushFailed.value = false;
    try {
      final net = Get.find<NetworkService>();
      final remaining = <Map<String, dynamic>>[];
      for (final item in List<Map<String, dynamic>>.from(pending)) {
        final endpoint = item['endpoint']?.toString() ?? '';
        final data = item['data'] is Map
            ? Map<String, dynamic>.from(item['data'] as Map)
            : null;
        final key = item['id']?.toString() ?? _uuidV4();
        var retries = (item['retries'] as int?) ?? 0;
        var ok = false;
        while (retries < _maxRetries && !ok) {
          if (retries > 0) {
            await Future.delayed(Duration(seconds: 1 << (retries - 1)));
          }
          try {
            final res = await net.post(
              endpoint: endpoint,
              data: data,
              idempotencyKey: key,
            );
            if (res.message == 'queued_offline') {
              ok = false;
              retries = _maxRetries;
            } else if (res.status == Status.completed) {
              ok = true;
            } else {
              retries++;
            }
          } catch (_) {
            retries++;
          }
        }
        if (!ok) {
          item['retries'] = retries;
          remaining.add(item);
          flushFailed.value = true;
        }
      }
      pending
        ..clear()
        ..addAll(remaining);
      await _persist();
    } finally {
      _flushing = false;
    }
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) return;
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      pending.assignAll(
        list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
      );
    } catch (_) {}
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(pending.toList()));
  }

  /// Removes queued requests when the authenticated session ends. Requests
  /// must never survive logout and be replayed under another user's token.
  Future<void> clearForSessionEnd() async {
    pending.clear();
    flushFailed.value = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  static String _uuidV4() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String h(int b) => b.toRadixString(16).padLeft(2, '0');
    final b = bytes.map(h).join();
    return '${b.substring(0, 8)}-${b.substring(8, 12)}-${b.substring(12, 16)}-'
        '${b.substring(16, 20)}-${b.substring(20)}';
  }
}
