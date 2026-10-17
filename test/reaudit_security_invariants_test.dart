import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:ecardo_user/src/common/services/offline_request_queue.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

class _MockSecureStorage extends FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => _storage[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.clear();
  }
}

class _TestAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (onFetch != null) return onFetch!(options);
    return ResponseBody.fromString('{"status":true}', 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (MethodCall methodCall) async => <String, dynamic>{
        'appName': 'ecardo',
        'packageName': 'ir.ecardo.user',
        'version': '1.0.171',
        'buildNumber': '171',
      },
    );
  });

  group('Re-Audit P0-01 — Offline Request Queue Safety', () {
    test('Rejects change-password and credentials from offline queue', () {
      final queue = OfflineRequestQueue();
      expect(queue.isQueueable('/user/settings/change-password'), isFalse);
      expect(queue.isQueueable('/auth/login'), isFalse);
      expect(queue.isQueueable('/auth/user/register'), isFalse);
      expect(queue.isQueueable('/user/kyc/submit'), isFalse);
      expect(queue.isQueueable('/auth/reset-password'), isFalse);
      expect(queue.isQueueable('/user/settings/passcode'), isFalse);
      expect(queue.isQueueable('/user/transfer'), isFalse);

      // Safe endpoints remain queueable
      expect(queue.isQueueable('/user/settings/profile'), isTrue);
      expect(queue.isQueueable('/setup-fcm'), isTrue);
      expect(queue.isQueueable('/change-language/fa'), isTrue);
      expect(queue.isQueueable('/mark-as-read-notification'), isTrue);
    });
  });

  group('Re-Audit P0-02 & P1-02 — Idempotency Safety on 5xx & Header Naming', () {
    test('NetworkService attaches both Idempotency-Key and X-Idempotency-Key', () async {
      Get.put(TokenService(secureStorage: _MockSecureStorage()));
      final networkService = Get.put(NetworkService());
      final adapter = _TestAdapter();
      networkService.dio.httpClientAdapter = adapter;

      adapter.onFetch = (options) async {
        expect(options.headers['Idempotency-Key'], isNotNull);
        expect(options.headers['X-Idempotency-Key'], isNotNull);
        expect(options.headers['Idempotency-Key'], equals(options.headers['X-Idempotency-Key']));
        return ResponseBody.fromString('{"status":true}', 200, headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        });
      };

      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 100},
      );
    });

    test('Idempotency key is retained on HTTP 500 server error', () async {
      Get.put(TokenService(secureStorage: _MockSecureStorage()));
      final networkService = Get.put(NetworkService());
      final adapter = _TestAdapter();
      networkService.dio.httpClientAdapter = adapter;

      String? firstIdemKey;
      int callCount = 0;

      adapter.onFetch = (options) async {
        callCount++;
        if (callCount == 1) {
          firstIdemKey = options.headers['Idempotency-Key'];
          return ResponseBody.fromString(
            jsonEncode({'status': false, 'message': 'Internal Server Error'}),
            500,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        } else {
          expect(options.headers['Idempotency-Key'], equals(firstIdemKey));
          return ResponseBody.fromString(
            jsonEncode({'status': true, 'message': 'Success'}),
            200,
            headers: {
              Headers.contentTypeHeader: [Headers.jsonContentType],
            },
          );
        }
      };

      // First call fails with 500
      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 250},
      );

      // Second identical call (retry) must reuse the same key!
      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 250},
      );

      expect(callCount, equals(2));
    });
  });

  group('Re-Audit P1-03 — TokenService Cleanup & Logout', () {
    test('clearToken wipes both secure storage and legacy SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({'access_token': 'legacy_secret_123'});
      final mockSecure = _MockSecureStorage();
      await mockSecure.write(key: TokenService.accessTokenKey, value: 'secure_secret_456');

      final tokenService = TokenService(secureStorage: mockSecure);
      await tokenService.loadAccessToken();
      expect(tokenService.accessToken.value, equals('secure_secret_456'));

      final cleared = await tokenService.clearToken();
      expect(cleared, isTrue);
      expect(tokenService.accessToken.value, isNull);

      final secureToken = await mockSecure.read(key: TokenService.accessTokenKey);
      expect(secureToken, isNull);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('access_token'), isFalse);
    });
  });

  group('Re-Audit P2-02 — AppLockService Persistent Failed Attempts Reset', () {
    test('resetFailedAttempts resets reactive count and persists 0 to storage', () async {
      final mockSecure = _MockSecureStorage();
      await mockSecure.write(key: 'app_lock_failed_count', value: '4');

      final appLock = AppLockService(secureStorage: mockSecure);
      await appLock.init();
      expect(appLock.failedAttempts.value, equals(4));

      await appLock.resetFailedAttempts();
      expect(appLock.failedAttempts.value, equals(0));

      final persisted = await mockSecure.read(key: 'app_lock_failed_count');
      expect(persisted, equals('0'));
    });
  });
}
