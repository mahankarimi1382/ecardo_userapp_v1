import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/common/services/offline_request_queue.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';

class _MockNetworkService extends GetxService implements NetworkService {
  int postCallCount = 0;
  int putCallCount = 0;
  int getCallCount = 0;
  final List<String> executedEndpoints = [];
  final List<String> executedMethods = [];
  final List<Map<String, dynamic>?> executedPayloads = [];

  ApiResponse<Map<String, dynamic>> Function(
    String endpoint,
    String method,
    Map<String, dynamic>? data,
  )?
  onCall;

  @override
  Future<ApiResponse<Map<String, dynamic>>> post({
    required String endpoint,
    Map<String, dynamic>? data,
    String? idempotencyKey,
    String? operationId,
    bool isForeground = true,
  }) async {
    postCallCount++;
    executedEndpoints.add(endpoint);
    executedMethods.add('POST');
    executedPayloads.add(data);
    if (onCall != null) {
      return onCall!(endpoint, 'POST', data);
    }
    return ApiResponse.completed({'status': 'success'});
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> put({
    required String endpoint,
    Map<String, dynamic>? data,
    String? idempotencyKey,
    String? operationId,
    bool isForeground = true,
  }) async {
    putCallCount++;
    executedEndpoints.add(endpoint);
    executedMethods.add('PUT');
    executedPayloads.add(data);
    if (onCall != null) {
      return onCall!(endpoint, 'PUT', data);
    }
    return ApiResponse.completed({'status': 'success'});
  }

  @override
  Future<ApiResponse<Map<String, dynamic>>> get({
    required String endpoint,
    bool isForeground = true,
  }) async {
    getCallCount++;
    executedEndpoints.add(endpoint);
    executedMethods.add('GET');
    executedPayloads.add(null);
    if (onCall != null) {
      return onCall!(endpoint, 'GET', null);
    }
    return ApiResponse.completed({'status': 'success'});
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late OfflineRequestQueue queue;
  late SharedPreferences prefs;

  setUp(() async {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    queue = OfflineRequestQueue();
    queue.retryDelayProvider = (_) => Duration.zero; // Fast test execution
  });

  tearDown(() {
    Get.reset();
  });

  group('SEC-OFF-01: Exact, normalized path & HTTP method validation', () {
    test('Allows explicitly approved non-financial operations', () {
      // POST on /setup-fcm
      expect(queue.isQueueable('/setup-fcm', method: 'POST'), isTrue);

      // POST on /mark-as-read-notification
      expect(
        queue.isQueueable('/mark-as-read-notification', method: 'POST'),
        isTrue,
      );

      // POST or PUT on /user/settings/profile
      expect(
        queue.isQueueable('/user/settings/profile', method: 'POST'),
        isTrue,
      );
      expect(
        queue.isQueueable('/user/settings/profile', method: 'PUT'),
        isTrue,
      );

      // GET or POST on /change-language/{code}
      expect(queue.isQueueable('/change-language/fa', method: 'GET'), isTrue);
      expect(queue.isQueueable('/change-language/en', method: 'POST'), isTrue);
      expect(
        queue.isQueueable('/change-language/ar-SA', method: 'GET'),
        isTrue,
      );
    });

    test(
      'Normalizes paths (leading slashes, trailing slashes, whitespace)',
      () {
        expect(queue.isQueueable('setup-fcm', method: 'POST'), isTrue);
        expect(queue.isQueueable('/setup-fcm/', method: 'POST'), isTrue);
        expect(queue.isQueueable('  /setup-fcm  ', method: 'POST'), isTrue);
        expect(
          queue.isQueueable('/user/settings/profile/', method: 'PUT'),
          isTrue,
        );
      },
    );

    test('Rejects unapproved HTTP methods on valid endpoints', () {
      // /setup-fcm is POST-only
      expect(queue.isQueueable('/setup-fcm', method: 'GET'), isFalse);
      expect(queue.isQueueable('/setup-fcm', method: 'PUT'), isFalse);
      expect(queue.isQueueable('/setup-fcm', method: 'DELETE'), isFalse);
      expect(queue.isQueueable('/setup-fcm', method: 'PATCH'), isFalse);

      // /mark-as-read-notification is POST-only
      expect(
        queue.isQueueable('/mark-as-read-notification', method: 'GET'),
        isFalse,
      );
      expect(
        queue.isQueueable('/mark-as-read-notification', method: 'PUT'),
        isFalse,
      );

      // /user/settings/profile allows only POST or PUT
      expect(
        queue.isQueueable('/user/settings/profile', method: 'GET'),
        isFalse,
      );
      expect(
        queue.isQueueable('/user/settings/profile', method: 'DELETE'),
        isFalse,
      );
      expect(
        queue.isQueueable('/user/settings/profile', method: 'PATCH'),
        isFalse,
      );

      // /change-language allows only GET or POST
      expect(queue.isQueueable('/change-language/fa', method: 'PUT'), isFalse);
      expect(
        queue.isQueueable('/change-language/fa', method: 'DELETE'),
        isFalse,
      );

      // Arbitrary/unknown methods rejected
      expect(queue.isQueueable('/setup-fcm', method: 'HEAD'), isFalse);
      expect(queue.isQueueable('/setup-fcm', method: 'OPTIONS'), isFalse);
      expect(queue.isQueueable('/setup-fcm', method: 'TRACE'), isFalse);
    });

    test('Rejects absolute URLs and protocol-relative URLs', () {
      expect(
        queue.isQueueable('https://ecardo.ir/setup-fcm', method: 'POST'),
        isFalse,
      );
      expect(
        queue.isQueueable('http://evil.com/setup-fcm', method: 'POST'),
        isFalse,
      );
      expect(
        queue.isQueueable('//evil.com/setup-fcm', method: 'POST'),
        isFalse,
      );
      expect(
        queue.isQueueable(r'\\evil.com\setup-fcm', method: 'POST'),
        isFalse,
      );
      expect(
        queue.isQueueable(
          'https://ecardo.ir/user/settings/profile',
          method: 'POST',
        ),
        isFalse,
      );
    });

    test('Rejects query parameters, URL fragments, and path traversals', () {
      expect(
        queue.isQueueable('/setup-fcm?token=leak', method: 'POST'),
        isFalse,
      );
      expect(
        queue.isQueueable('/user/settings/profile#section', method: 'POST'),
        isFalse,
      );
      expect(
        queue.isQueueable('/change-language/fa?v=1', method: 'GET'),
        isFalse,
      );
      expect(
        queue.isQueueable('/setup-fcm/../auth/login', method: 'POST'),
        isFalse,
      );
      expect(queue.isQueueable('../setup-fcm', method: 'POST'), isFalse);
    });

    test('Rejects unauthorized, credential, and financial routes', () {
      expect(queue.isQueueable('/user/settings/change-password'), isFalse);
      expect(queue.isQueueable('/auth/login'), isFalse);
      expect(queue.isQueueable('/auth/user/register'), isFalse);
      expect(queue.isQueueable('/user/kyc/submit'), isFalse);
      expect(queue.isQueueable('/auth/reset-password'), isFalse);
      expect(queue.isQueueable('/user/settings/passcode'), isFalse);
      expect(queue.isQueueable('/user/transfer'), isFalse);
      expect(queue.isQueueable('/user/wallets'), isFalse);
      expect(queue.isQueueable('/user/withdraw'), isFalse);
      expect(queue.isQueueable('/change-language'), isFalse); // missing {code}
      expect(queue.isQueueable('/change-language/'), isFalse); // empty code
      expect(queue.isQueueable('/change-language/fa/extra'), isFalse);
      expect(queue.isQueueable('/unknown/path'), isFalse);
    });
  });

  group('SEC-OFF-02: Deep payload sensitive-data scanner', () {
    test('Rejects payload containing sensitive keys', () {
      const sensitiveKeys = <String>[
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

      for (final key in sensitiveKeys) {
        final payload = {key: 'any_value'};
        expect(
          OfflineRequestQueue.containsSensitiveData(payload),
          isTrue,
          reason: 'Key "$key" must be detected as sensitive',
        );
        expect(
          queue.isQueueable(
            '/user/settings/profile',
            method: 'POST',
            data: payload,
          ),
          isFalse,
          reason: 'Payload with key "$key" must be rejected from queue',
        );
      }
    });

    test(
      'Detects sensitive variations in key names (snake_case, camelCase)',
      () {
        expect(
          OfflineRequestQueue.containsSensitiveData({'user_password': '123'}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({
            'cardPan': '4111222233334444',
          }),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'user_pin': '1234'}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'pinCode': '1234'}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'loginOtp': '987654'}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'authToken': 'jwt-xyz'}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'client_secret': 'sec'}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'cvv2': '999'}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'wallet_id': 123}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({'transfer_amount': 500}),
          isTrue,
        );
        expect(
          OfflineRequestQueue.containsSensitiveData({
            'nationalId': '0012345678',
          }),
          isTrue,
        );
      },
    );

    test('Recursively detects sensitive tokens in nested maps and lists', () {
      // Nested map
      expect(
        OfflineRequestQueue.containsSensitiveData({
          'settings': {
            'security': {'password': 'secret'},
          },
        }),
        isTrue,
      );

      // List of maps
      expect(
        OfflineRequestQueue.containsSensitiveData({
          'items': [
            {'name': 'item1'},
            {'amount': 50},
          ],
        }),
        isTrue,
      );

      // List of strings containing sensitive keywords
      expect(
        OfflineRequestQueue.containsSensitiveData({
          'tags': ['normal', 'transfer', 'tag2'],
        }),
        isTrue,
      );

      // Deep string value containing sensitive keyword
      expect(
        OfflineRequestQueue.containsSensitiveData({
          'user': {'bio': 'Please reset my password tomorrow'},
        }),
        isTrue,
      );
      expect(
        OfflineRequestQueue.containsSensitiveData({
          'note': 'My card number is 4111-2222-3333-4444',
        }),
        isTrue,
      );
    });

    test('Accepts valid profile updates without false positives', () {
      final validProfile = {
        'username': 'ali_reza',
        'first_name': 'Ali',
        'last_name': 'Rezaei',
        'email': 'ali@ecardo.ir', // "ecardo" must not match "card"
        'phone': '+989123456789',
        'gender': 'm',
        'date_of_birth': '1995-05-15',
        'country': 'IR',
        'city': 'Tehran',
        'zip_code': '1234567890',
        'address':
            'Valiasr St, Shipping Dock 4, Japan Building', // "Shipping", "Japan" must not match "pin", "pan"
      };

      expect(OfflineRequestQueue.containsSensitiveData(validProfile), isFalse);
      expect(
        queue.isQueueable(
          '/user/settings/profile',
          method: 'POST',
          data: validProfile,
        ),
        isTrue,
      );
      expect(
        queue.isQueueable(
          '/user/settings/profile',
          method: 'PUT',
          data: validProfile,
        ),
        isTrue,
      );
    });

    test(
      'Accepts valid FCM setup and permits fcm_token key only for /setup-fcm',
      () {
        final fcmData = {
          'device_id': 'android_unique_id_99',
          'device_type': 'android',
          'fcm_token': 'fH3-9kLqM810:APA91bFwX...sample_fcm_token_stream',
        };

        // FCM token is valid specifically for /setup-fcm
        expect(
          OfflineRequestQueue.containsSensitiveData(
            fcmData,
            endpoint: '/setup-fcm',
          ),
          isFalse,
        );
        expect(
          queue.isQueueable('/setup-fcm', method: 'POST', data: fcmData),
          isTrue,
        );

        // If /setup-fcm payload also carries forbidden credentials (e.g. pin), it must still be rejected!
        final fcmWithPin = {...fcmData, 'pin': '1234'};
        expect(
          queue.isQueueable('/setup-fcm', method: 'POST', data: fcmWithPin),
          isFalse,
        );

        // If fcm_token is sent to a non-FCM endpoint (e.g. /user/settings/profile), it is rejected as sensitive token
        expect(
          queue.isQueueable(
            '/user/settings/profile',
            method: 'POST',
            data: {'fcm_token': 'xyz'},
          ),
          isFalse,
        );
      },
    );

    test(
      'enqueue() rejects unauthorized routes or sensitive payloads',
      () async {
        // Unauthorized route
        final r1 = await queue.enqueue(
          method: 'POST',
          endpoint: '/user/transfer',
          data: {'to': 'user2'},
        );
        expect(r1, isFalse);
        expect(queue.pending, isEmpty);

        // Sensitive payload
        final r2 = await queue.enqueue(
          method: 'POST',
          endpoint: '/user/settings/profile',
          data: {'password': 'newPassword123'},
        );
        expect(r2, isFalse);
        expect(queue.pending, isEmpty);

        // Absolute URL
        final r3 = await queue.enqueue(
          method: 'POST',
          endpoint: 'https://evil.com/setup-fcm',
          data: {'device_id': '123'},
        );
        expect(r3, isFalse);
        expect(queue.pending, isEmpty);
      },
    );

    test(
      'enqueue() successfully queues valid profile and FCM requests',
      () async {
        final ok1 = await queue.enqueue(
          method: 'POST',
          endpoint: '/setup-fcm',
          data: {
            'device_id': 'dev1',
            'device_type': 'android',
            'fcm_token': 'fcm_tok_abc',
          },
        );
        expect(ok1, isTrue);
        expect(queue.pending.length, equals(1));
        expect(queue.pending.first['endpoint'], equals('/setup-fcm'));
        expect(queue.pending.first['method'], equals('POST'));

        final ok2 = await queue.enqueue(
          method: 'PUT',
          endpoint: '/user/settings/profile',
          data: {'username': 'new_user'},
        );
        expect(ok2, isTrue);
        expect(queue.pending.length, equals(2));
        expect(queue.pending.last['method'], equals('PUT'));
      },
    );
  });

  group('SEC-OFF-03: Queue Governance (TTL, Max Size, DLQ)', () {
    test('Max Queue Size caps at 25 entries with FIFO eviction', () async {
      // Enqueue 25 valid requests
      for (int i = 1; i <= 25; i++) {
        final ok = await queue.enqueue(
          method: 'POST',
          endpoint: '/mark-as-read-notification',
          data: {'index': i},
        );
        expect(ok, isTrue);
      }
      expect(queue.pending.length, equals(25));
      expect(queue.pending.first['data']['index'], equals(1));
      expect(queue.pending.last['data']['index'], equals(25));

      // Enqueue 26th request -> 1st request should be evicted (FIFO)
      final ok26 = await queue.enqueue(
        method: 'POST',
        endpoint: '/mark-as-read-notification',
        data: {'index': 26},
      );
      expect(ok26, isTrue);
      expect(queue.pending.length, equals(25));
      expect(
        queue.pending.first['data']['index'],
        equals(2),
      ); // Item 1 was evicted!
      expect(queue.pending.last['data']['index'], equals(26));

      // Enqueue 27th request -> 2nd request evicted
      await queue.enqueue(
        method: 'POST',
        endpoint: '/mark-as-read-notification',
        data: {'index': 27},
      );
      expect(queue.pending.length, equals(25));
      expect(queue.pending.first['data']['index'], equals(3));
      expect(queue.pending.last['data']['index'], equals(27));
    });

    test(
      'TTL Expiration: items older than 24h are evicted on load and flush',
      () async {
        final now = DateTime(2026, 10, 17, 12, 0, 0);

        // Fresh item (1 hour ago)
        final freshItem = {
          'id': 'fresh-1',
          'method': 'POST',
          'endpoint': '/mark-as-read-notification',
          'data': {'id': '101'},
          'retries': 0,
          'created_at': now
              .subtract(const Duration(hours: 1))
              .toIso8601String(),
        };

        // Stale item (25 hours ago, expired under 24h TTL)
        final staleItem = {
          'id': 'stale-1',
          'method': 'POST',
          'endpoint': '/mark-as-read-notification',
          'data': {'id': '102'},
          'retries': 0,
          'created_at': now
              .subtract(const Duration(hours: 25))
              .toIso8601String(),
        };

        // Save directly to SharedPreferences to simulate cold start
        await prefs.setString(
          OfflineRequestQueue.storageKey,
          jsonEncode([freshItem, staleItem]),
        );

        // Load with current time
        final loadedQueue = OfflineRequestQueue();
        await loadedQueue.load(now: now);

        // Only the fresh item must remain
        expect(loadedQueue.pending.length, equals(1));
        expect(loadedQueue.pending.first['id'], equals('fresh-1'));

        // Verify SharedPreferences was pruned
        final updatedRaw = prefs.getString(OfflineRequestQueue.storageKey);
        final updatedList = jsonDecode(updatedRaw!) as List<dynamic>;
        expect(updatedList.length, equals(1));
        expect(updatedList.first['id'], equals('fresh-1'));
      },
    );

    test(
      'Dead-Letter Queue (DLQ): items migrate after 3 failed retries',
      () async {
        final mockNet = Get.put<NetworkService>(_MockNetworkService());
        final mock = mockNet as _MockNetworkService;

        // Server persistently returns failure (500)
        mock.onCall = (endpoint, method, data) {
          return ApiResponse.error('Internal Server Error 500');
        };

        await queue.enqueue(
          method: 'POST',
          endpoint: '/setup-fcm',
          data: {
            'device_id': 'd1',
            'device_type': 'android',
            'fcm_token': 'fcm_xyz',
          },
        );

        expect(queue.pending.length, equals(1));
        expect(queue.deadLetterQueue, isEmpty);

        // Trigger flush
        await queue.flush();

        // After flush attempts (3 retries), item MUST move to DLQ
        expect(mock.postCallCount, equals(3));
        expect(queue.pending, isEmpty); // Removed from active queue!
        expect(queue.deadLetterQueue.length, equals(1));
        expect(queue.deadLetterQueue.first['endpoint'], equals('/setup-fcm'));
        expect(queue.deadLetterQueue.first['retries'], equals(3));
        expect(queue.deadLetterQueue.first['dead_letter_at'], isNotNull);
        expect(queue.flushFailed.value, isTrue);

        // Verify DLQ is persisted in SharedPreferences under ecardo_offline_queue_dlq_v1
        final rawDlq = prefs.getString(OfflineRequestQueue.dlqStorageKey);
        expect(rawDlq, isNotNull);
        final dlqList = jsonDecode(rawDlq!) as List<dynamic>;
        expect(dlqList.length, equals(1));
        expect(dlqList.first['endpoint'], equals('/setup-fcm'));

        // Test DLQ inspection and clearing
        expect(queue.dlq.length, equals(1));
        await queue.clearDlq();
        expect(queue.deadLetterQueue, isEmpty);
        expect(queue.dlq, isEmpty);
        final clearedRawDlq = prefs.getString(
          OfflineRequestQueue.dlqStorageKey,
        );
        expect(jsonDecode(clearedRawDlq!), isEmpty);
      },
    );
  });

  group('SEC-OFF-04: HTTP Replay and Method Preservation', () {
    test(
      'Flushes POST, PUT, and GET requests with corresponding NetworkService methods',
      () async {
        final mockNet = Get.put<NetworkService>(_MockNetworkService());
        final mock = mockNet as _MockNetworkService;

        // Enqueue POST, PUT, and GET
        await queue.enqueue(
          method: 'POST',
          endpoint: '/setup-fcm',
          data: {
            'device_id': 'd1',
            'device_type': 'android',
            'fcm_token': 'tok1',
          },
        );

        await queue.enqueue(
          method: 'PUT',
          endpoint: '/user/settings/profile',
          data: {'city': 'Shiraz'},
        );

        await queue.enqueue(method: 'GET', endpoint: '/change-language/fa');

        expect(queue.pending.length, equals(3));

        // Flush all
        await queue.flush();

        // Verify calls
        expect(mock.executedMethods, equals(['POST', 'PUT', 'GET']));
        expect(
          mock.executedEndpoints,
          equals([
            '/setup-fcm',
            '/user/settings/profile',
            '/change-language/fa',
          ]),
        );
        expect(mock.executedPayloads[0]?['fcm_token'], equals('tok1'));
        expect(mock.executedPayloads[1]?['city'], equals('Shiraz'));
        expect(mock.executedPayloads[2], isNull);

        // All successfully processed items are cleared from queue
        expect(queue.pending, isEmpty);
        expect(queue.deadLetterQueue, isEmpty);
        expect(queue.flushFailed.value, isFalse);
      },
    );

    test(
      'Offline connection error stops flush without burning retries or sending duplicate requests',
      () async {
        final mockNet = Get.put<NetworkService>(_MockNetworkService());
        final mock = mockNet as _MockNetworkService;

        // Mock returns queued_offline (connection error intercepted by NetworkService)
        mock.onCall = (endpoint, method, data) {
          return ApiResponse.error('queued_offline');
        };

        await queue.enqueue(
          method: 'POST',
          endpoint: '/mark-as-read-notification',
          data: {'id': '1'},
        );
        await queue.enqueue(
          method: 'POST',
          endpoint: '/mark-as-read-notification',
          data: {'id': '2'},
        );

        await queue.flush();

        // Must have stopped after first attempt, not burning 3 retries
        expect(mock.postCallCount, equals(1));
        // Both items remain in pending queue
        expect(queue.pending.length, equals(2));
        // Neither item moved to DLQ
        expect(queue.deadLetterQueue, isEmpty);
        expect(queue.pending.first['retries'], equals(0));
      },
    );
  });
}
