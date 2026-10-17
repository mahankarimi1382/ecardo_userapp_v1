import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';

/// Secure offline queue for non-financial mutating requests only (SEC-OFF-01..04).
///
/// Security constraints:
/// - Exact, normalized relative path validation against allowlist.
/// - Strict HTTP method allowlist per path.
/// - Absolute URLs, unknown paths, unknown methods, and paths with traversal,
///   queries, or fragments are rejected.
/// - Deep payload sensitive-data scanner recursively checks all keys and string
///   values for sensitive tokens: password, passcode, pin, otp, token, secret,
///   card, cvv, pan, national_id, kyc, amount, transfer, withdraw, wallet.
/// - Queue governance: 24h TTL (evicted on load or flush), max 25 entries (FIFO),
///   and Dead-Letter Queue (DLQ) after 3 retries (`ecardo_offline_queue_dlq_v1`).
class OfflineRequestQueue extends GetxService {
  static const String storageKey = 'ecardo_offline_queue_v1';
  static const String dlqStorageKey = 'ecardo_offline_queue_dlq_v1';

  static const int maxRetries = 3;
  static const int maxQueueSize = 25;
  static const Duration defaultTtl = Duration(hours: 24);

  /// Active TTL duration for queued items. Defaults to 24 hours.
  Duration ttl = defaultTtl;

  /// Custom retry backoff delay provider for testability.
  Duration Function(int retryCount)? retryDelayProvider;

  final RxList<Map<String, dynamic>> pending = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> deadLetterQueue =
      <Map<String, dynamic>>[].obs;
  final RxBool flushFailed = false.obs;

  StreamSubscription? _sub;
  bool _flushing = false;

  bool get isFlushing => _flushing;
  List<Map<String, dynamic>> get dlq => deadLetterQueue.toList();

  static const List<String> sensitiveTokens = <String>[
    'password',
    'passcode',
    'pin',
    'otp',
    'token',
    'secret',
    'card',
    'cvv',
    'pan',
    'national_id',
    'kyc',
    'amount',
    'transfer',
    'withdraw',
    'wallet',
  ];

  static final RegExp _changeLanguageRegex =
      RegExp(r'^/change-language/[a-zA-Z0-9_\-]+$');

  /// Normalizes and validates the endpoint path.
  ///
  /// Rejects absolute URLs, protocol-relative URLs, backslashes, query parameters,
  /// fragments, and path traversal (`..` or `.`).
  /// Returns normalized path starting with `/` without trailing slash (unless root `/`).
  static String? normalizePath(String endpoint) {
    final trimmed = endpoint.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.contains('://') ||
        trimmed.startsWith('//') ||
        trimmed.startsWith(r'\\') ||
        trimmed.contains(r'\')) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    if (uri.hasScheme || uri.hasAuthority || uri.host.isNotEmpty) {
      return null;
    }

    if (uri.hasQuery || uri.hasFragment) {
      return null;
    }

    for (final seg in uri.pathSegments) {
      if (seg == '..' || seg == '.') return null;
    }

    String path = uri.normalizePath().path;
    if (!path.startsWith('/')) {
      path = '/$path';
    }

    while (path.length > 1 && path.endsWith('/')) {
      path = path.substring(0, path.length - 1);
    }

    return path;
  }

  /// Checks if the normalized endpoint and HTTP method are explicitly allowed.
  ///
  /// Approved operations:
  /// - POST on `/setup-fcm`
  /// - POST on `/mark-as-read-notification`
  /// - POST or PUT on `/user/settings/profile`
  /// - GET or POST on `/change-language/{code}`
  static bool isRouteAllowed(String endpoint, {String method = 'POST'}) {
    final path = normalizePath(endpoint);
    if (path == null) return false;

    final normMethod = method.trim().toUpperCase();

    if (path == '/setup-fcm') {
      return normMethod == 'POST';
    }

    if (path == '/mark-as-read-notification') {
      return normMethod == 'POST';
    }

    if (path == '/user/settings/profile') {
      return normMethod == 'POST' || normMethod == 'PUT';
    }

    if (_changeLanguageRegex.hasMatch(path)) {
      return normMethod == 'GET' || normMethod == 'POST';
    }

    return false;
  }

  /// Extracts word tokens from camelCase, snake_case, kebab-case, or whitespace text.
  static List<String> extractWords(String text) {
    final withSpaces = text.replaceAllMapped(
      RegExp(r'([a-z0-9])([A-Z])'),
      (m) => '${m[1]} ${m[2]}',
    );
    return withSpaces
        .toLowerCase()
        .split(RegExp(r'[^a-z0-9]+'))
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Checks if a single string contains any sensitive token.
  static bool isSensitiveText(String text, {bool isFcmToken = false}) {
    if (text.isEmpty) return false;
    final lower = text.toLowerCase();
    final words = extractWords(text);

    for (final token in sensitiveTokens) {
      if (token == 'token' && isFcmToken) continue;

      if (token == 'national_id') {
        if (lower.contains('national_id') ||
            lower.contains('national-id') ||
            lower.contains('nationalid') ||
            (words.contains('national') && words.contains('id'))) {
          return true;
        }
      } else if (token == 'pin') {
        if (words.contains('pin') ||
            words.contains('pins') ||
            lower.contains('pin_code') ||
            lower.contains('pincode') ||
            words.contains('pincode')) {
          return true;
        }
      } else if (token == 'pan') {
        if (words.contains('pan') ||
            words.contains('pans') ||
            lower.contains('card_pan') ||
            lower.contains('cardpan') ||
            lower.contains('pan_number')) {
          return true;
        }
      } else if (token == 'otp') {
        if (words.contains('otp') || words.contains('otps')) {
          return true;
        }
      } else if (token == 'card') {
        if (words.contains('card') ||
            words.contains('cards') ||
            words.any((w) =>
                w.endsWith('card') &&
                w != 'ecardo' &&
                w != 'wildcard' &&
                w != 'discard')) {
          return true;
        }
      } else if (token == 'token') {
        if (words.contains('token') ||
            words.contains('tokens') ||
            words.any((w) =>
                (w.endsWith('token') || w.endsWith('tokens')) &&
                w != 'fcm_token')) {
          return true;
        }
      } else {
        // password, passcode, secret, cvv, kyc, amount, transfer, withdraw, wallet
        if (lower.contains(token) || words.contains(token)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Recursively scans all keys and string values in the payload for sensitive tokens.
  /// Returns true if any sensitive token is found.
  static bool containsSensitiveData(dynamic payload, {String? endpoint}) {
    if (payload == null) return false;

    final isFcmEndpoint =
        endpoint != null && normalizePath(endpoint) == '/setup-fcm';

    return _scanNode(payload, isFcmEndpoint: isFcmEndpoint);
  }

  static bool _scanNode(dynamic node, {required bool isFcmEndpoint}) {
    if (node is Map) {
      for (final entry in node.entries) {
        final keyStr = entry.key.toString();
        final isFcmTokenField =
            isFcmEndpoint && keyStr.toLowerCase() == 'fcm_token';

        if (!isFcmTokenField && isSensitiveText(keyStr)) {
          return true;
        }

        final val = entry.value;
        if (val is Map || val is Iterable) {
          if (_scanNode(val, isFcmEndpoint: isFcmEndpoint)) {
            return true;
          }
        } else if (val is String) {
          if (isSensitiveText(val, isFcmToken: isFcmTokenField)) {
            return true;
          }
        }
      }
    } else if (node is Iterable) {
      for (final item in node) {
        if (_scanNode(item, isFcmEndpoint: isFcmEndpoint)) {
          return true;
        }
      }
    } else if (node is String) {
      if (isSensitiveText(node)) {
        return true;
      }
    }
    return false;
  }

  /// Determines if an item in the queue has exceeded its TTL.
  bool isItemExpired(Map<String, dynamic> item, {DateTime? now}) {
    final raw = item['created_at']?.toString();
    if (raw == null || raw.isEmpty) return false;
    final created = DateTime.tryParse(raw);
    if (created == null) return false;
    final currentTime = now ?? DateTime.now();
    return currentTime.difference(created) > ttl;
  }

  /// Evicts expired items from the active queue. Returns number of evicted items.
  int evictExpired({DateTime? now}) {
    final before = pending.length;
    pending.removeWhere((item) => isItemExpired(item, now: now));
    return before - pending.length;
  }

  /// Validates whether an endpoint, HTTP method, and optional payload can be queued offline.
  bool isQueueable(
    String endpoint, {
    String method = 'POST',
    Map<String, dynamic>? data,
  }) {
    if (!isRouteAllowed(endpoint, method: method)) {
      return false;
    }
    if (data != null && containsSensitiveData(data, endpoint: endpoint)) {
      return false;
    }
    return true;
  }

  Future<OfflineRequestQueue> init() async {
    await load();
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

  /// Enqueues a request after strict route, method, payload, and queue-cap checks.
  ///
  /// Returns `true` if enqueued, or `false` if rejected.
  Future<bool> enqueue({
    required String method,
    required String endpoint,
    Map<String, dynamic>? data,
    String? idempotencyKey,
  }) async {
    final normMethod = method.trim().toUpperCase();
    final normPath = normalizePath(endpoint);
    if (normPath == null ||
        !isQueueable(normPath, method: normMethod, data: data)) {
      return false;
    }

    final key = idempotencyKey ?? _uuidV4();
    final item = <String, dynamic>{
      'id': key,
      'method': normMethod,
      'endpoint': normPath,
      'data': data,
      'retries': 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    // FIFO eviction: cap at maxQueueSize entries.
    while (pending.length >= maxQueueSize) {
      pending.removeAt(0);
    }

    pending.add(item);
    await _persist();
    return true;
  }

  /// Flushes pending offline requests.
  Future<void> flush({bool manual = false}) async {
    if (_flushing || pending.isEmpty) return;
    if (!Get.isRegistered<NetworkService>()) return;

    final evicted = evictExpired();
    if (evicted > 0) {
      await _persist();
    }
    if (pending.isEmpty) return;

    _flushing = true;
    flushFailed.value = false;
    try {
      final net = Get.find<NetworkService>();
      final remaining = <Map<String, dynamic>>[];
      final currentPending = List<Map<String, dynamic>>.from(pending);

      for (int i = 0; i < currentPending.length; i++) {
        final item = currentPending[i];

        if (isItemExpired(item)) {
          continue;
        }

        final endpoint = item['endpoint']?.toString() ?? '';
        final method = (item['method']?.toString() ?? 'POST').toUpperCase();
        final data = item['data'] is Map
            ? Map<String, dynamic>.from(item['data'] as Map)
            : null;

        if (!isQueueable(endpoint, method: method, data: data)) {
          continue;
        }

        var retries = (item['retries'] as int?) ?? 0;
        var ok = false;
        var offlineBlocked = false;

        while (retries < maxRetries && !ok) {
          if (retries > 0) {
            final delay = retryDelayProvider != null
                ? retryDelayProvider!(retries)
                : Duration(seconds: 1 << (retries - 1));
            if (delay > Duration.zero) {
              await Future.delayed(delay);
            }
          }
          try {
            final res = await _executeRequest(net, item);
            if (res.message == 'queued_offline') {
              offlineBlocked = true;
              break;
            } else if (res.status == Status.completed) {
              ok = true;
            } else {
              retries++;
            }
          } catch (_) {
            retries++;
          }
        }

        if (offlineBlocked) {
          remaining.add(item);
          for (int j = i + 1; j < currentPending.length; j++) {
            remaining.add(currentPending[j]);
          }
          flushFailed.value = true;
          break;
        }

        if (!ok) {
          item['retries'] = retries;
          flushFailed.value = true;
          if (retries >= maxRetries) {
            item['dead_letter_at'] = DateTime.now().toIso8601String();
            deadLetterQueue.add(Map<String, dynamic>.from(item));
          } else {
            remaining.add(item);
          }
        }
      }

      pending.assignAll(remaining);
      await _persist();
      await _persistDlq();
    } finally {
      _flushing = false;
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> _executeRequest(
    NetworkService net,
    Map<String, dynamic> item,
  ) async {
    final method = (item['method']?.toString() ?? 'POST').toUpperCase();
    final endpoint = item['endpoint']?.toString() ?? '';
    final data = item['data'] is Map
        ? Map<String, dynamic>.from(item['data'] as Map)
        : null;
    final key = item['id']?.toString() ?? _uuidV4();

    switch (method) {
      case 'POST':
        return await net.post(
          endpoint: endpoint,
          data: data,
          idempotencyKey: key,
        );
      case 'PUT':
        return await net.put(
          endpoint: endpoint,
          data: data,
        );
      case 'GET':
        return await net.get(
          endpoint: endpoint,
        );
      default:
        return ApiResponse.error('unsupported_method');
    }
  }

  /// Loads queued items and DLQ from persistent storage.
  Future<void> load({DateTime? now}) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(storageKey);
    var dirty = false;
    if (raw != null && raw.isNotEmpty) {
      try {
        final list = jsonDecode(raw) as List<dynamic>;
        final items = <Map<String, dynamic>>[];
        for (final e in list.whereType<Map>()) {
          final item = Map<String, dynamic>.from(e);
          if (isItemExpired(item, now: now)) {
            dirty = true;
            continue;
          }
          final path = item['endpoint']?.toString() ?? '';
          final method = item['method']?.toString() ?? 'POST';
          final data = item['data'] is Map
              ? Map<String, dynamic>.from(item['data'] as Map)
              : null;
          if (!isQueueable(path, method: method, data: data)) {
            dirty = true;
            continue;
          }
          items.add(item);
        }
        while (items.length > maxQueueSize) {
          items.removeAt(0);
          dirty = true;
        }
        pending.assignAll(items);
      } catch (_) {}
    }

    final rawDlq = prefs.getString(dlqStorageKey);
    if (rawDlq != null && rawDlq.isNotEmpty) {
      try {
        final list = jsonDecode(rawDlq) as List<dynamic>;
        deadLetterQueue.assignAll(
          list.whereType<Map>().map((e) => Map<String, dynamic>.from(e)),
        );
      } catch (_) {}
    }

    if (dirty) {
      await _persist();
    }
  }

  Future<void> clearQueue() async {
    pending.clear();
    await _persist();
  }

  Future<void> clearDlq() async {
    deadLetterQueue.clear();
    await _persistDlq();
  }

  Future<void> clearAll() async {
    pending.clear();
    deadLetterQueue.clear();
    await _persist();
    await _persistDlq();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, jsonEncode(pending.toList()));
  }

  Future<void> _persistDlq() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(dlqStorageKey, jsonEncode(deadLetterQueue.toList()));
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
