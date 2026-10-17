import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

/// Test HTTP client adapter enabling fine-grained control over responses and exceptions.
class _TestHttpClientAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? onFetch;
  final List<RequestOptions> capturedRequests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    capturedRequests.add(options);
    if (onFetch != null) {
      return onFetch!(options);
    }
    return ResponseBody.fromString(
      jsonEncode({'status': 'success', 'data': <String, dynamic>{}}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NetworkService networkService;
  late _TestHttpClientAdapter testAdapter;
  DateTime fakeNow = DateTime(2026, 10, 15, 12, 0, 0);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();

    // Mock platform channels for fluttertoast, flutter_secure_storage, package_info
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
      (MethodCall methodCall) async => null,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/package_info'),
      (MethodCall methodCall) async => <String, dynamic>{
        'appName': 'ecardo',
        'packageName': 'ir.ecardo.user',
        'version': '1.0.41',
        'buildNumber': '41',
      },
    );

    fakeNow = DateTime(2026, 10, 15, 12, 0, 0);
    Get.put(TokenService());
    networkService = Get.put(NetworkService());
    networkService.clock = () => fakeNow;

    testAdapter = _TestHttpClientAdapter();
    networkService.dio.httpClientAdapter = testAdapter;
  });

  tearDown(() {
    Get.reset();
  });

  group('Workstream B — Idempotency Lifecycle & Intent Management', () {
    test('Idempotency key reuse on transport timeout (connectionTimeout) within TTL', () async {
      int attempt = 0;
      testAdapter.onFetch = (options) async {
        attempt++;
        if (attempt == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          );
        }
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {'transfer_id': 'tx-123'}}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      // First call times out
      final res1 = await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 150, 'recipient': 'user-88'},
      );
      expect(res1.status, equals(Status.error));
      expect(testAdapter.capturedRequests.length, equals(1));
      final firstKey = testAdapter.capturedRequests[0].headers['Idempotency-Key'] as String?;
      expect(firstKey, isNotNull);
      expect(firstKey, isNotEmpty);

      // Verify the key is retained in the registry after connectionTimeout
      expect(networkService.inflightIdempotencyCount, equals(1));

      // User retries 30 seconds later (within 5-minute TTL)
      fakeNow = fakeNow.add(const Duration(seconds: 30));
      final res2 = await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 150, 'recipient': 'user-88'},
      );
      expect(res2.status, equals(Status.completed));
      expect(testAdapter.capturedRequests.length, equals(2));
      final secondKey = testAdapter.capturedRequests[1].headers['Idempotency-Key'] as String?;

      // Must reuse identical Idempotency-Key to prevent double debit
      expect(secondKey, equals(firstKey));

      // After successful completion (HTTP 200), key must be immediately released
      expect(networkService.inflightIdempotencyCount, equals(0));
    });

    test('Idempotency key reuse on receiveTimeout, sendTimeout, and SocketException', () async {
      final testCases = [
        DioException(
          requestOptions: RequestOptions(path: '/user/transfer'),
          type: DioExceptionType.receiveTimeout,
          message: 'Receive timeout',
        ),
        DioException(
          requestOptions: RequestOptions(path: '/user/transfer'),
          type: DioExceptionType.sendTimeout,
          message: 'Send timeout',
        ),
        DioException(
          requestOptions: RequestOptions(path: '/user/transfer'),
          type: DioExceptionType.connectionError,
          error: const SocketException('Connection refused by remote host'),
          message: 'SocketException: Connection refused',
        ),
      ];

      for (int i = 0; i < testCases.length; i++) {
        final exception = testCases[i];
        final testEndpoint = '/user/transfer';
        final payload = {'amount': 100 + i, 'target': 'account-$i'};

        int attempt = 0;
        testAdapter.capturedRequests.clear();
        testAdapter.onFetch = (options) async {
          attempt++;
          if (attempt == 1) {
            throw DioException(
              requestOptions: options,
              type: exception.type,
              error: exception.error,
              message: exception.message,
            );
          }
          return ResponseBody.fromString(
            jsonEncode({'status': 'success', 'data': {'ok': true}}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        };

        // Attempt 1 fails with transport error
        await networkService.post(endpoint: testEndpoint, data: payload);
        final key1 = testAdapter.capturedRequests[0].headers['Idempotency-Key'] as String?;
        expect(key1, isNotNull);
        expect(networkService.inflightIdempotencyCount, equals(1));

        // Retry 45s later
        fakeNow = fakeNow.add(const Duration(seconds: 45));
        await networkService.post(endpoint: testEndpoint, data: payload);
        final key2 = testAdapter.capturedRequests[1].headers['Idempotency-Key'] as String?;

        expect(key2, equals(key1), reason: 'Failed for ${exception.type} / ${exception.error}');
        expect(networkService.inflightIdempotencyCount, equals(0), reason: 'Must release on 200');
      }
    });

    test('Idempotency key expires after 5-minute TTL — subsequent request gets a fresh key', () async {
      int attempt = 0;
      testAdapter.onFetch = (options) async {
        attempt++;
        if (attempt == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionTimeout,
            message: 'Timed out',
          );
        }
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {}}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      // Initial call times out at T0
      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 500, 'to': 'wallet-1'},
      );
      final key1 = testAdapter.capturedRequests[0].headers['Idempotency-Key'] as String?;
      expect(key1, isNotNull);
      expect(networkService.inflightIdempotencyCount, equals(1));

      // Fast forward past the 5-minute TTL: 5 minutes and 1 second later
      fakeNow = fakeNow.add(const Duration(minutes: 5, seconds: 1));

      // Subsequent transfer with the same payload
      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 500, 'to': 'wallet-1'},
      );
      final key2 = testAdapter.capturedRequests[1].headers['Idempotency-Key'] as String?;

      expect(key2, isNotNull);
      expect(key2, isNot(equals(key1)), reason: 'Expired key must not be reused; a fresh key must be minted');
    });

    test('HTTP 200 / 201 immediately releases key, allowing future identical transfers to get fresh keys', () async {
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {}}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await networkService.post(
        endpoint: '/user/pay-bill',
        data: {'bill_id': 'bill-99', 'amount': 25},
      );
      final key1 = testAdapter.capturedRequests[0].headers['Idempotency-Key'] as String?;
      expect(key1, isNotNull);
      expect(networkService.inflightIdempotencyCount, equals(0));

      // Immediately paying another bill with the same parameters gets a new fresh key
      await networkService.post(
        endpoint: '/user/pay-bill',
        data: {'bill_id': 'bill-99', 'amount': 25},
      );
      final key2 = testAdapter.capturedRequests[1].headers['Idempotency-Key'] as String?;
      expect(key2, isNotNull);
      expect(key2, isNot(equals(key1)));
      expect(networkService.inflightIdempotencyCount, equals(0));
    });

    test('Deterministic client error (HTTP 422) releases key immediately (FIN-IDEM-05)', () async {
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Insufficient funds', 'errors': {'amount': ['Too high']}}),
          422,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 999999},
      );
      expect(networkService.inflightIdempotencyCount, equals(0), reason: '422 should release key immediately');

      // Next request gets fresh key
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'status': 'success'}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };
      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 999999},
      );
      expect(testAdapter.capturedRequests.length, equals(2));
      final k1 = testAdapter.capturedRequests[0].headers['Idempotency-Key'];
      final k2 = testAdapter.capturedRequests[1].headers['Idempotency-Key'];
      expect(k1, isNot(equals(k2)));
    });

    test('Deterministic client error (HTTP 400) releases key immediately (FIN-IDEM-05)', () async {
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'message': 'Bad Request', 'errors': {'amount': ['Invalid format']}}),
          400,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': -50},
      );
      expect(networkService.inflightIdempotencyCount, equals(0), reason: '400 should release key immediately');

      // Next request gets fresh key
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'status': 'success'}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };
      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': -50},
      );
      expect(testAdapter.capturedRequests.length, equals(2));
      final k1 = testAdapter.capturedRequests[0].headers['Idempotency-Key'];
      final k2 = testAdapter.capturedRequests[1].headers['Idempotency-Key'];
      expect(k1, isNot(equals(k2)));
    });

    test('Ambiguous server errors (HTTP 500-599) retain idempotency key across retries and release only on 200 (FIN-IDEM-01, FIN-IDEM-05)', () async {
      final serverErrorCodes = [500, 502, 503, 504];

      for (final code in serverErrorCodes) {
        testAdapter.capturedRequests.clear();
        int attempt = 0;
        testAdapter.onFetch = (options) async {
          attempt++;
          if (attempt == 1) {
            return ResponseBody.fromString(
              jsonEncode({'message': 'Server Error $code'}),
              code,
              headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
            );
          }
          return ResponseBody.fromString(
            jsonEncode({'status': 'success', 'data': {'transferred': true}}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );
        };

        // Attempt 1 fails with 5xx
        final res1 = await networkService.post(
          endpoint: '/user/transfer',
          data: {'amount': 300, 'code': code},
        );
        expect(res1.status, equals(Status.error));
        expect(networkService.inflightIdempotencyCount, equals(1),
            reason: 'HTTP $code must retain idempotency key (ambiguous state)');

        final key1 = testAdapter.capturedRequests[0].headers['Idempotency-Key'];
        final xKey1 = testAdapter.capturedRequests[0].headers['X-Idempotency-Key'];
        expect(key1, isNotNull);
        expect(xKey1, equals(key1));

        // Attempt 2 (retry with same payload within TTL)
        fakeNow = fakeNow.add(const Duration(seconds: 10));
        final res2 = await networkService.post(
          endpoint: '/user/transfer',
          data: {'amount': 300, 'code': code},
        );
        expect(res2.status, equals(Status.completed));
        expect(testAdapter.capturedRequests.length, equals(2));

        final key2 = testAdapter.capturedRequests[1].headers['Idempotency-Key'];
        final xKey2 = testAdapter.capturedRequests[1].headers['X-Idempotency-Key'];
        expect(key2, equals(key1),
            reason: 'Retry after HTTP $code must reuse the exact same idempotency key');
        expect(xKey2, equals(key1));

        // After HTTP 200, key must be released
        expect(networkService.inflightIdempotencyCount, equals(0),
            reason: 'HTTP 200 must release the key');

        // Subsequent new transfer gets fresh key
        testAdapter.onFetch = (options) async => ResponseBody.fromString(
          jsonEncode({'status': 'success'}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
        await networkService.post(
          endpoint: '/user/transfer',
          data: {'amount': 300, 'code': code},
        );
        final key3 = testAdapter.capturedRequests[2].headers['Idempotency-Key'];
        expect(key3, isNot(equals(key1)),
            reason: 'Subsequent submission after success must get fresh key');
        expect(networkService.inflightIdempotencyCount, equals(0));
      }
    });

    test('Explicit X-Operation-ID header is used directly as idempotency seed', () async {
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {}}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await networkService.dio.post(
        '/user/transfer',
        data: {'amount': 300},
        options: Options(
          headers: {'X-Operation-ID': 'op-intent-uuid-42'},
        ),
      );

      expect(testAdapter.capturedRequests.length, equals(1));
      final req = testAdapter.capturedRequests[0];
      expect(req.headers['Idempotency-Key'], equals('op-intent-uuid-42'));
      expect(req.headers['X-Operation-ID'], equals('op-intent-uuid-42'));
    });

    test('Explicit operationId in options.extra is used directly as idempotency seed', () async {
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {}}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await networkService.dio.post(
        '/user/transfer',
        data: {'amount': 200},
        options: Options(
          extra: {'operationId': 'op-extra-seed-99'},
        ),
      );

      expect(testAdapter.capturedRequests.length, equals(1));
      final req = testAdapter.capturedRequests[0];
      expect(req.headers['Idempotency-Key'], equals('op-extra-seed-99'));
      expect(req.headers['X-Operation-ID'], equals('op-extra-seed-99'));
    });

    test('Explicit operationId parameter in networkService.post is passed and used', () async {
      testAdapter.onFetch = (options) async {
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {}}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 50},
        operationId: 'op-direct-param-77',
      );

      expect(testAdapter.capturedRequests.length, equals(1));
      final req = testAdapter.capturedRequests[0];
      expect(req.headers['Idempotency-Key'], equals('op-direct-param-77'));
      expect(req.headers['X-Operation-ID'], equals('op-direct-param-77'));
    });

    test('Bounded registry size: capacity capped at maximum 50 entries with oldest evicted', () {
      final baseTime = DateTime(2026, 10, 15, 10, 0, 0);

      // Populate 50 entries with strictly increasing timestamps
      for (int i = 0; i < 50; i++) {
        networkService.setIdempotencyEntry(
          'POST:/endpoint-$i:data',
          'key-$i',
          baseTime.add(Duration(seconds: i)),
        );
      }
      expect(networkService.inflightIdempotencyCount, equals(50));

      // Adding 51st entry should bound registry size to <= 50 and evict oldest (key-0)
      networkService.clock = () => baseTime.add(const Duration(minutes: 1));
      networkService.boundRegistrySize();
      networkService.setIdempotencyEntry(
        'POST:/endpoint-50:data',
        'key-50',
        baseTime.add(const Duration(seconds: 50)),
      );

      expect(networkService.inflightIdempotencyCount, equals(50));
      // Oldest entry (key-0) must be evicted
      expect(networkService.getIdempotencyKey('POST:/endpoint-0:data'), isNull);
      // Newest entry (key-50) must be retained
      expect(networkService.getIdempotencyKey('POST:/endpoint-50:data'), equals('key-50'));
    });

    test('Automatic eviction of expired entries on check', () {
      final t0 = DateTime(2026, 10, 15, 12, 0, 0);
      networkService.setIdempotencyEntry('POST:/user/cashout:1', 'key-old-1', t0);
      networkService.setIdempotencyEntry('POST:/user/cashout:2', 'key-old-2', t0.add(const Duration(minutes: 1)));
      networkService.setIdempotencyEntry('POST:/user/cashout:3', 'key-recent', t0.add(const Duration(minutes: 4)));

      // Fast forward to t0 + 5m 30s
      // key-old-1 is 5m30s old (expired)
      // key-old-2 is 4m30s old (alive)
      // key-recent is 1m30s old (alive)
      networkService.clock = () => t0.add(const Duration(minutes: 5, seconds: 30));

      expect(networkService.getIdempotencyKey('POST:/user/cashout:1'), isNull);
      expect(networkService.getIdempotencyKey('POST:/user/cashout:2'), equals('key-old-2'));
      expect(networkService.getIdempotencyKey('POST:/user/cashout:3'), equals('key-recent'));
    });

    test('Deterministic canonical SHA-256 payload fingerprinting with recursive key sorting (FIN-IDEM-04)', () {
      // 1. Map key order independence (flat)
      final mapA = {'b': 2, 'a': 1, 'c': 3};
      final mapB = {'c': 3, 'b': 2, 'a': 1};
      final mapC = {'a': 1, 'c': 3, 'b': 2};

      final fpA = networkService.payloadFingerprint(mapA);
      final fpB = networkService.payloadFingerprint(mapB);
      final fpC = networkService.payloadFingerprint(mapC);

      expect(fpA, equals(fpB));
      expect(fpA, equals(fpC));
      // Must be 64-char lowercase hex
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(fpA), isTrue);

      // Verify exact canonical SHA-256 computation: jsonEncode is '{"a":1,"b":2,"c":3}'
      final expectedSha = sha256.convert(utf8.encode('{"a":1,"b":2,"c":3}')).toString();
      expect(fpA, equals(expectedSha));

      // 2. Nested Maps key order independence
      final nested1 = {
        'metadata': {'z': 100, 'y': 200},
        'amount': 500,
        'account': {'iban': 'IR123', 'bank': 'Mellat'},
      };
      final nested2 = {
        'account': {'bank': 'Mellat', 'iban': 'IR123'},
        'amount': 500,
        'metadata': {'y': 200, 'z': 100},
      };

      final fpNested1 = networkService.payloadFingerprint(nested1);
      final fpNested2 = networkService.payloadFingerprint(nested2);
      expect(fpNested1, equals(fpNested2));

      // 3. Lists containing Maps
      final list1 = {
        'items': [
          {'key': 'k2', 'val': 'v2'},
          {'key': 'k1', 'val': 'v1'},
        ],
      };
      final list2 = {
        'items': [
          {'val': 'v2', 'key': 'k2'},
          {'val': 'v1', 'key': 'k1'},
        ],
      };
      expect(networkService.payloadFingerprint(list1), equals(networkService.payloadFingerprint(list2)));

      // 4. Collision-free: different payloads produce distinct SHA-256 hashes
      final diff1 = networkService.payloadFingerprint({'amount': 100});
      final diff2 = networkService.payloadFingerprint({'amount': 101});
      expect(diff1, isNot(equals(diff2)));

      // 5. Null payload produces SHA-256 of empty bytes
      final nullFp = networkService.payloadFingerprint(null);
      final emptyBytesSha = sha256.convert(const <int>[]).toString();
      expect(nullFp, equals(emptyBytesSha));
    });

    test('_getIdempotencyMapKey produces collision-free METHOD:NORMALIZED_PATH:IDENTITY format (FIN-IDEM-06)', () {
      final req1 = RequestOptions(
        method: 'post',
        path: '//user///transfer//',
        data: {'amount': 100, 'currency': 'USD'},
      );
      final mapKey1 = networkService.getIdempotencyMapKey(req1);

      // Verify structure: METHOD:NORMALIZED_PATH:IDENTITY
      final parts1 = mapKey1.split(':');
      expect(parts1.length, equals(3));
      expect(parts1[0], equals('POST'));
      expect(parts1[1], equals('/user/transfer'));
      expect(RegExp(r'^[0-9a-f]{64}$').hasMatch(parts1[2]), isTrue);

      // Verify path with query parameters is sorted deterministically
      final reqWithQuery = RequestOptions(
        method: 'POST',
        path: '/user/transfer?b=2&a=1&c=3',
        data: {'amount': 50},
      );
      final mapKeyWithQuery = networkService.getIdempotencyMapKey(reqWithQuery);
      expect(mapKeyWithQuery.contains('/user/transfer?a=1&b=2&c=3'), isTrue);

      // Verify explicit operationId produces METHOD:NORMALIZED_PATH:op:OPERATION_ID
      final reqWithOp = RequestOptions(
        method: 'POST',
        path: '/user/transfer',
        headers: {'X-Operation-ID': 'op-unique-789'},
      );
      final mapKeyWithOp = networkService.getIdempotencyMapKey(reqWithOp);
      expect(mapKeyWithOp, equals('POST:/user/transfer:op:op-unique-789'));
    });

    test('Emits both Idempotency-Key and X-Idempotency-Key on idempotent requests (FIN-IDEM-01)', () async {
      testAdapter.capturedRequests.clear();
      testAdapter.onFetch = (options) async => ResponseBody.fromString(
        jsonEncode({'status': 'success', 'data': {}}),
        200,
        headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
      );

      await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 75},
      );

      expect(testAdapter.capturedRequests.length, equals(1));
      final captured = testAdapter.capturedRequests[0];
      final idem = captured.headers['Idempotency-Key'] as String?;
      final xIdem = captured.headers['X-Idempotency-Key'] as String?;

      expect(idem, isNotNull);
      expect(idem, isNotEmpty);
      expect(xIdem, isNotNull);
      expect(xIdem, equals(idem), reason: 'Both headers must carry identical keys');
    });
  });

  group('Workstream B — Comprehensive PII & Secret Redaction in Logging', () {
    test('Sanitizes all sensitive keys in snake_case, camelCase, and kebab-case', () {
      final payload = {
        'password': 'secret_password_1',
        'current_password': 'current_password_2',
        'currentPassword': 'current_password_3',
        'current-password': 'current_password_4',
        'new_password': 'new_password_5',
        'newPassword': 'new_password_6',
        'new-password': 'new_password_7',
        'password_confirmation': 'password_confirmation_8',
        'passwordConfirmation': 'password_confirmation_9',
        'password-confirmation': 'password_confirmation_10',
        'code': '123456',
        'otp': '654321',
        'passcode': '7788',
        'pin': '9900',
        'cvv': '123',
        'card_number': '5022291012345678',
        'cardNumber': '5022291012345679',
        'card-number': '5022291012345680',
        'pan': '6037991812345678',
        'access_token': 'eyJh...token1',
        'accessToken': 'eyJh...token2',
        'access-token': 'eyJh...token3',
        'refresh_token': 'ref_token_1',
        'refreshToken': 'ref_token_2',
        'refresh-token': 'ref_token_3',
        'authorization': 'Bearer super_secret',
        'iban': 'IR120000000000000000000001',
        'account_number': '010203040506',
        'accountNumber': '010203040507',
        'account-number': '010203040508',
        'national_id': '0012345678',
        'nationalId': '0012345679',
        'national-id': '0012345680',
        'secret': 'client_secret_xyz',
        'bearer': 'jwt_bearer_token',
        // Non-sensitive fields that MUST NOT be redacted:
        'email': 'user@example.com',
        'amount': 250000,
        'currency': 'USD',
        'status': 'pending',
        'description': 'Family transfer',
      };

      final sanitized = NetworkService.sanitizePayload(payload) as Map;

      // Verify every sensitive key is masked with '<redacted>'
      final sensitiveKeys = [
        'password',
        'current_password',
        'currentPassword',
        'current-password',
        'new_password',
        'newPassword',
        'new-password',
        'password_confirmation',
        'passwordConfirmation',
        'password-confirmation',
        'code',
        'otp',
        'passcode',
        'pin',
        'cvv',
        'card_number',
        'cardNumber',
        'card-number',
        'pan',
        'access_token',
        'accessToken',
        'access-token',
        'refresh_token',
        'refreshToken',
        'refresh-token',
        'authorization',
        'iban',
        'account_number',
        'accountNumber',
        'account-number',
        'national_id',
        'nationalId',
        'national-id',
        'secret',
        'bearer',
      ];

      for (final key in sensitiveKeys) {
        expect(sanitized[key], equals('<redacted>'), reason: 'Key "$key" was not redacted');
      }

      // Verify non-sensitive keys are preserved intact
      expect(sanitized['email'], equals('user@example.com'));
      expect(sanitized['amount'], equals(250000));
      expect(sanitized['currency'], equals('USD'));
      expect(sanitized['status'], equals('pending'));
      expect(sanitized['description'], equals('Family transfer'));
    });

    test('Sanitizes deeply nested Maps and Lists recursively', () {
      final nested = {
        'batch': [
          {
            'user': {
              'nationalId': '1122334455',
              'cards': [
                {'cardNumber': '50221234', 'cvv': '999', 'nickname': 'Main Card'},
                {'cardNumber': '60375678', 'cvv': '888', 'nickname': 'Second Card'},
              ],
            },
            'auth': {'accessToken': 'secret-tok-123'},
          }
        ],
        'meta': {'page': 1, 'total': 100},
      };

      final sanitized = NetworkService.sanitizePayload(nested) as Map;
      final batch = sanitized['batch'] as List;
      final item = batch[0] as Map;
      final user = item['user'] as Map;
      final cards = user['cards'] as List;

      expect(user['nationalId'], equals('<redacted>'));
      expect(cards[0]['cardNumber'], equals('<redacted>'));
      expect(cards[0]['cvv'], equals('<redacted>'));
      expect(cards[0]['nickname'], equals('Main Card'));
      expect(cards[1]['cardNumber'], equals('<redacted>'));
      expect(cards[1]['cvv'], equals('<redacted>'));
      expect(cards[1]['nickname'], equals('Second Card'));
      expect(item['auth']['accessToken'], equals('<redacted>'));
      expect(sanitized['meta']['page'], equals(1));
      expect(sanitized['meta']['total'], equals(100));
    });

    test('Case-insensitive sensitive key redaction', () {
      final uppercaseData = {
        'PASSWORD': 'secret_1',
        'PIN': '1234',
        'CVV': '999',
        'IBAN': 'IR123',
        'PAN': '6037',
        'CardNumber': '5022',
        'National_Id': '0012',
        'Access_Token': 'tok_xyz',
      };

      final sanitized = NetworkService.sanitizePayload(uppercaseData) as Map;
      for (final key in uppercaseData.keys) {
        expect(sanitized[key], equals('<redacted>'), reason: 'Uppercase key "$key" was not redacted');
      }
    });
  });

  group('Workstream B — Error Response Sanitization & Log Protection', () {
    test('_handleDioErrorResponse does NOT log raw response bodies or credentials', () {
      final originalDebugPrint = debugPrint;
      final capturedLogs = <String>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) capturedLogs.add(message);
      };

      try {
        final rawSensitiveBody = {
          'message': 'Validation failed on credentials',
          'access_token': 'SUPER_SECRET_LEAKED_ACCESS_TOKEN',
          'refresh_token': 'SUPER_SECRET_REFRESH_TOKEN',
          'secret_dump': 'PRIVATE_KEY_BYTES_12345',
          'errors': {
            'password': ['Password is incorrect'],
            'pin': ['Wrong PIN entered: 9988'],
            'cardNumber': ['Card 5022291012345678 is invalid'],
          },
        };

        // Test 400 Bad Request
        networkService.handleDioErrorResponse(
          Response(
            requestOptions: RequestOptions(path: '/user/transfer'),
            statusCode: 400,
            data: rawSensitiveBody,
          ),
          'POST',
        );

        // Test 401 Unauthorized
        networkService.handleDioErrorResponse(
          Response(
            requestOptions: RequestOptions(path: '/user/transfer'),
            statusCode: 401,
            data: rawSensitiveBody,
          ),
          'POST',
        );

        // Test 422 Unprocessable Entity
        networkService.handleDioErrorResponse(
          Response(
            requestOptions: RequestOptions(path: '/user/transfer'),
            statusCode: 422,
            data: rawSensitiveBody,
          ),
          'POST',
        );

        // Test 500 Server Error
        networkService.handleDioErrorResponse(
          Response(
            requestOptions: RequestOptions(path: '/user/transfer'),
            statusCode: 500,
            data: rawSensitiveBody,
          ),
          'POST',
        );

        // Verify none of the raw sensitive payloads leaked into logs
        for (final log in capturedLogs) {
          expect(log.contains('SUPER_SECRET_LEAKED_ACCESS_TOKEN'), isFalse,
              reason: 'Leaked raw access token in log: $log');
          expect(log.contains('SUPER_SECRET_REFRESH_TOKEN'), isFalse,
              reason: 'Leaked raw refresh token in log: $log');
          expect(log.contains('PRIVATE_KEY_BYTES_12345'), isFalse,
              reason: 'Leaked raw secret dump in log: $log');
          expect(log.contains('secret_dump'), isFalse,
              reason: 'Leaked raw body key in log: $log');
        }

        // Verify logs contain sanitized HTTP status and message only
        expect(capturedLogs.any((l) => l.contains('POST Error [status 400]: Validation failed on credentials')), isTrue);
        expect(capturedLogs.any((l) => l.contains('POST Error [status 401]: Validation failed on credentials')), isTrue);
        expect(capturedLogs.any((l) => l.contains('POST Error [status 422]: Validation failed on credentials')), isTrue);
        expect(capturedLogs.any((l) => l.contains('POST Error [status 500]: Validation failed on credentials')), isTrue);
      } finally {
        debugPrint = originalDebugPrint;
      }
    });

    test('Transport timeout logging does not leak authorization tokens', () {
      final originalDebugPrint = debugPrint;
      final capturedLogs = <String>[];
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) capturedLogs.add(message);
      };

      try {
        networkService.isTransportTimeoutOrSocketException(
          DioException(
            requestOptions: RequestOptions(
              path: '/user/transfer',
              headers: {'Authorization': 'Bearer my-sensitive-token'},
            ),
            type: DioExceptionType.connectionTimeout,
            message: 'Connection timed out',
          ),
        );

        for (final log in capturedLogs) {
          expect(log.contains('my-sensitive-token'), isFalse);
        }
      } finally {
        debugPrint = originalDebugPrint;
      }
    });
  });
}
