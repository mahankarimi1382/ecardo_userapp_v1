import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/network/response/api_response_handler.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

class _MockHttpClientAdapter implements HttpClientAdapter {
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
  late _MockHttpClientAdapter mockAdapter;
  DateTime fakeNow = DateTime(2026, 10, 23, 10, 0, 0);

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

    fakeNow = DateTime(2026, 10, 23, 10, 0, 0);
    Get.put(TokenService());
    networkService = Get.put(NetworkService());
    networkService.clock = () => fakeNow;

    mockAdapter = _MockHttpClientAdapter();
    networkService.dio.httpClientAdapter = mockAdapter;
  });

  tearDown(() {
    Get.reset();
  });

  group('Workstream B — Idempotency on Mutating Methods (POST, PUT, PATCH)', () {
    test('PUT requests to state/financial endpoints emit Idempotency-Key & X-Idempotency-Key', () async {
      mockAdapter.capturedRequests.clear();
      mockAdapter.onFetch = (options) async => ResponseBody.fromString(
            jsonEncode({'status': 'success', 'data': {'updated': true}}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );

      await networkService.put(
        endpoint: '/user/cards/update-status',
        data: {'card_id': 123, 'status': 'freeze'},
      );

      expect(mockAdapter.capturedRequests.length, equals(1));
      final req = mockAdapter.capturedRequests[0];
      expect(req.headers['Idempotency-Key'], isNotNull);
      expect(req.headers['X-Idempotency-Key'], equals(req.headers['Idempotency-Key']));
    });

    test('PATCH requests to mutating endpoints emit Idempotency-Key & X-Idempotency-Key', () async {
      mockAdapter.capturedRequests.clear();
      mockAdapter.onFetch = (options) async => ResponseBody.fromString(
            jsonEncode({'status': 'success', 'data': {'ok': true}}),
            200,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );

      await networkService.patch(
        endpoint: '/user/p2p/orders/77/payment-method',
        data: {'payment_method_id': 5},
      );

      expect(mockAdapter.capturedRequests.length, equals(1));
      final req = mockAdapter.capturedRequests[0];
      expect(req.headers['Idempotency-Key'], isNotNull);
      expect(req.headers['X-Idempotency-Key'], equals(req.headers['Idempotency-Key']));
    });

    test('Dynamic endpoints (cards irr-topup, p2p cancel, epay) match isMutatingEndpoint', () {
      expect(NetworkService.isMutatingEndpoint('/user/cards/42/irr-topup'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/cards/balance/topup'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/cards/update-status'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/p2p/orders/99/cancel'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/p2p/orders/99/mark-paid'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/p2p/orders/99/dispute'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/p2p/orders/99/release'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/p2p/ads/10/status-update'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/epay/cards/issue'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/epay/cards/topup'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/gift-cards/product/order'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/ticket'), isTrue);
      expect(NetworkService.isMutatingEndpoint('/user/payment-links/create'), isTrue);

      // Non-mutating / non-financial endpoints
      expect(NetworkService.isMutatingEndpoint('/get-countries'), isFalse);
      expect(NetworkService.isMutatingEndpoint('/get-settings'), isFalse);
      expect(NetworkService.isMutatingEndpoint('/user/dashboard'), isFalse);
    });
  });

  group('Workstream B — Never Auto-Retry Mutating Transactions on Network Timeout', () {
    test('Mutating POST is NEVER automatically retried on connectionTimeout (prevents double charge)', () async {
      int fetchCount = 0;
      mockAdapter.onFetch = (options) async {
        fetchCount++;
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
          message: 'Connection timed out',
        );
      };

      final res = await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 1000, 'to': 'user-99'},
      );

      // Exactly 1 network attempt — zero automatic retries
      expect(fetchCount, equals(1));
      expect(mockAdapter.capturedRequests.length, equals(1));
      expect(res.status, equals(Status.error));
      expect(res.isTimeout, isTrue);
      expect(res.isReconciling, isTrue);
      expect(res.isUnknown, isTrue);
    });

    test('Mutating POST is NEVER automatically retried on sendTimeout or receiveTimeout', () async {
      for (final timeoutType in [DioExceptionType.sendTimeout, DioExceptionType.receiveTimeout]) {
        int fetchCount = 0;
        mockAdapter.capturedRequests.clear();
        mockAdapter.onFetch = (options) async {
          fetchCount++;
          throw DioException(
            requestOptions: options,
            type: timeoutType,
            message: 'Timeout occurred',
          );
        };

        final res = await networkService.post(
          endpoint: '/user/payment/make',
          data: {'merchant_id': 'm-1', 'amount': 250},
        );

        // Exactly 1 attempt
        expect(fetchCount, equals(1), reason: 'Failed for $timeoutType');
        expect(res.isTimeout, isTrue);
        expect(res.isReconciling, isTrue);
      }
    });

    test('Read-only GET requests CAN be retried once on transport failure by _TransportRetryInterceptor', () async {
      int fetchCount = 0;
      mockAdapter.capturedRequests.clear();
      mockAdapter.onFetch = (options) async {
        fetchCount++;
        if (fetchCount == 1) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            message: 'Temporary connection drop',
          );
        }
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {'wallets': []}}),
          200,
          headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
        );
      };

      final res = await networkService.get(endpoint: '/user/wallets');
      // GET request should succeed on retry attempt 2
      expect(fetchCount, equals(2));
      expect(res.status, equals(Status.completed));
    });
  });

  group('Workstream B — Timeouts Transition to Safe Unknown/Reconciling State', () {
    test('Financial transaction timeout transitions to safe unknown/reconciling state without advising blind retry', () async {
      mockAdapter.onFetch = (options) async {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
          message: 'Receive timeout after submission',
        );
      };

      final res = await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': 500, 'to': 'wallet-abc'},
      );

      expect(res.status, equals(Status.error));
      expect(res.isTimeout, isTrue);
      expect(res.isReconciling, isTrue);
      expect(res.isUnknown, isTrue);
      // Message must warn about unknown transaction status and advising checking history
      expect(res.message, contains('Transaction status unknown'));
      expect(res.message, contains('history'));
      // Must NOT tell the user 'Please try again.'
      expect(res.message!.contains('Please try again.'), isFalse);
    });

    test('HTTP 504 Gateway Timeout on mutating financial endpoint transitions to unknown/reconciling state', () async {
      mockAdapter.onFetch = (options) async => ResponseBody.fromString(
            jsonEncode({'message': 'Gateway Time-out'}),
            504,
            headers: {Headers.contentTypeHeader: [Headers.jsonContentType]},
          );

      final res = await networkService.post(
        endpoint: '/user/exchange',
        data: {'from_wallet': 'USD', 'to_wallet': 'EUR', 'amount': 100},
      );

      expect(res.status, equals(Status.error));
      expect(res.isTimeout, isTrue);
      expect(res.isReconciling, isTrue);
      expect(res.isUnknown, isTrue);
      expect(res.message, contains('Gateway timeout'));
      expect(res.message, contains('Transaction status unknown'));
    });
  });

  group('Workstream B — HTTP 500+ Sanitization & Information Leakage Prevention', () {
    test('Filters out SQL queries, PDOException, and QueryException from 500 responses', () {
      final rawSqlError = "SQLSTATE[42S02]: Base table or view not found: 1146 Table 'ecardo.users' doesn't exist (Connection: mysql, SQL: select * from users where id = 123)";
      expect(NetworkService.isTechnicalOrSensitiveServerMessage(rawSqlError), isTrue);

      final res = networkService.handleDioErrorResponse(
        Response(
          requestOptions: RequestOptions(path: '/user/transfer'),
          statusCode: 500,
          data: {'message': rawSqlError},
        ),
        'POST',
      );

      expect(res.message!.contains('SQLSTATE'), isFalse);
      expect(res.message!.contains('ecardo.users'), isFalse);
      expect(res.message!.contains('select * from'), isFalse);
      expect(res.message, contains('A server error occurred. Please try again later.'));
    });

    test('Filters out stack traces, file paths (/var/www, php line numbers), and framework internals', () {
      final rawTrace = "Call to undefined method App\\Services\\PaymentService::process() in /var/www/ecardo/app/Http/Controllers/PaymentController.php on line 214\nStack trace:\n#0 ...";
      expect(NetworkService.isTechnicalOrSensitiveServerMessage(rawTrace), isTrue);

      final res = networkService.handleDioErrorResponse(
        Response(
          requestOptions: RequestOptions(path: '/user/payment/make'),
          statusCode: 500,
          data: {'message': rawTrace},
        ),
        'POST',
      );

      expect(res.message!.contains('/var/www'), isFalse);
      expect(res.message!.contains('PaymentController.php'), isFalse);
      expect(res.message!.contains('Stack trace'), isFalse);
      expect(res.message, contains('A server error occurred. Please try again later.'));
    });

    test('HTTP 502 Bad Gateway returns safe friendly localized message', () {
      final res = networkService.handleDioErrorResponse(
        Response(
          requestOptions: RequestOptions(path: '/user/dashboard'),
          statusCode: 502,
          data: '<html><body>502 Bad Gateway</body></html>',
        ),
        'GET',
      );

      expect(res.message, contains('Service temporarily unavailable. Please try again later.'));
    });
  });

  group('Workstream B — HTTP 422 / 400 Validation Message Parsing', () {
    test('Safely extracts first specific field validation message from Laravel 422 envelope', () {
      final res = networkService.handleDioErrorResponse(
        Response(
          requestOptions: RequestOptions(path: '/user/transfer'),
          statusCode: 422,
          data: {
            'message': 'The given data was invalid.',
            'errors': {
              'amount': ['The amount field must be greater than 10.'],
              'recipient': ['Recipient not found.'],
            },
          },
        ),
        'POST',
      );

      // Must NOT return the useless generic 'The given data was invalid.'
      expect(res.message, equals('The amount field must be greater than 10.'));
    });

    test('Safely parses nested validation error maps and list structures', () {
      final res = networkService.handleDioErrorResponse(
        Response(
          requestOptions: RequestOptions(path: '/user/settings/profile'),
          statusCode: 422,
          data: {
            'errors': {
              'address': {
                'postal_code': ['Postal code must be 10 digits.'],
              },
            },
          },
        ),
        'POST',
      );

      expect(res.message, equals('Postal code must be 10 digits.'));
    });
  });

  group('Workstream B — ApiResponseHandler Business Status & Contract 04 Compliance', () {
    test('Distinguishes confirmed success from pending, rejected, and reconciling statuses', () {
      // 1. Confirmed Success
      final successHandler = ApiResponseHandler({
        'status': 'success',
        'data': {'status': 'completed', 'id': 'tx-1'},
      });
      expect(successHandler.isSuccess, isTrue);
      expect(successHandler.isConfirmedSuccess, isTrue);
      expect(successHandler.isPending, isFalse);
      expect(successHandler.isRejected, isFalse);
      expect(successHandler.isReconciling, isFalse);

      // 2. Pending / Processing
      final pendingHandler = ApiResponseHandler({
        'status': 'success',
        'data': {'status': 'pending', 'id': 'tx-2'},
      });
      expect(pendingHandler.isSuccess, isTrue);
      expect(pendingHandler.isPending, isTrue);
      expect(pendingHandler.isConfirmedSuccess, isFalse);

      // 3. Rejected by domain logic (HTTP 200 with business rejected)
      final rejectedHandler = ApiResponseHandler({
        'status': 'success',
        'data': {'status': 'rejected', 'reason': 'Limit exceeded'},
      });
      expect(rejectedHandler.isRejected, isTrue);
      expect(rejectedHandler.isSuccess, isFalse); // Contract 04: Rejected is not success
      expect(rejectedHandler.isConfirmedSuccess, isFalse);

      // 4. Unknown / Reconciling
      final reconcilingHandler = ApiResponseHandler({
        'status': 'success',
        'data': {'status': 'unknown'},
      });
      expect(reconcilingHandler.isReconciling, isTrue);
      expect(reconcilingHandler.isSuccess, isFalse);
      expect(reconcilingHandler.isConfirmedSuccess, isFalse);

      // 5. Requires Action (e.g. OTP/2FA)
      final actionHandler = ApiResponseHandler({
        'status': 'success',
        'data': {'status': 'requires_action', 'action': 'otp_required'},
      });
      expect(actionHandler.requiresAction, isTrue);
      expect(actionHandler.isConfirmedSuccess, isFalse);
    });

    test('Extracts fieldErrors map and firstError correctly from errors payload', () {
      final handler = ApiResponseHandler({
        'status': 'error',
        'errors': {
          'email': ['Email format is invalid.', 'Email already taken.'],
          'password': ['Password must be at least 8 characters.'],
        },
      });

      expect(handler.firstError, equals('Email format is invalid.'));
      expect(handler.fieldErrors['email'], equals('Email format is invalid.'));
      expect(handler.fieldErrors['password'], equals('Password must be at least 8 characters.'));
    });
  });
}
