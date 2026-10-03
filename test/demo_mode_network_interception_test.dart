import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/common/services/demo_account_service.dart';
import 'package:ecardo_user/src/network/response/status.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });

  tearDown(() {
    Get.reset();
  });

  group('Demo Mode Endpoint Normalization Tests', () {
    test('normalizes diverse endpoint formats correctly', () {
      expect(
        DemoAccountService.normalizeEndpoint('/user/dashboard'),
        equals('/user/dashboard'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('user/dashboard'),
        equals('/user/dashboard'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('/api/user/dashboard'),
        equals('/user/dashboard'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('api/user/dashboard'),
        equals('/user/dashboard'),
      );
      expect(
        DemoAccountService.normalizeEndpoint(
          'https://ecardo.ir/api/user/dashboard',
        ),
        equals('/user/dashboard'),
      );
      expect(
        DemoAccountService.normalizeEndpoint(
          'https://ecardo.ir/api/app-version',
        ),
        equals('/app-version'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('/api/app-version'),
        equals('/app-version'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('/app-version'),
        equals('/app-version'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('/api/get-settings-v2?cb=17482348'),
        equals('/get-settings-v2'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('/api/get-currencies'),
        equals('/get-currencies'),
      );
      expect(
        DemoAccountService.normalizeEndpoint('/get-currencies'),
        equals('/get-currencies'),
      );
    });
  });

  group('Demo Mode Instant Mock Responses Tests', () {
    late DemoAccountService demoService;

    setUp(() {
      demoService = Get.put(DemoAccountService());
      demoService.isDemoMode.value = true;
    });

    test('returns immediate mock for /user/dashboard', () {
      final res = demoService.handleDemoRequest(
        endpoint: '/user/dashboard',
        method: 'GET',
      );
      expect(res, isNotNull);
      expect(res!['status'], equals('success'));
      expect(res['data']['user']['email'], equals('demo@ecardo.ir'));
    });

    test('returns immediate mock for /user/wallets', () {
      final res = demoService.handleDemoRequest(
        endpoint: '/user/wallets',
        method: 'GET',
      );
      expect(res, isNotNull);
      expect(res!['status'], equals('success'));
      final wallets = res['data']['wallets'] as List;
      expect(wallets, isNotEmpty);
      expect(wallets.any((w) => w['code'] == 'USD'), isTrue);
      expect(wallets.any((w) => w['code'] == 'USDT'), isTrue);
    });

    test('returns immediate mock for /user/transactions', () {
      final res = demoService.handleDemoRequest(
        endpoint: '/user/transactions',
        method: 'GET',
      );
      expect(res, isNotNull);
      expect(res!['status'], equals('success'));
      final txs = res['data']['transactions'] as List;
      expect(txs, isNotEmpty);
    });

    test('returns immediate mock for /api/app-version and /app-version', () {
      for (final ep in [
        '/api/app-version',
        '/app-version',
        'https://ecardo.ir/api/app-version',
      ]) {
        final res = demoService.handleDemoRequest(endpoint: ep, method: 'GET');
        expect(res, isNotNull);
        expect(res!['status'], equals('success'));
        expect(res['data']['version'], isNotNull);
        expect(res['data']['force_update'], equals(false));
      }
    });

    test(
      'returns immediate mock for /api/get-settings-v2 and /get-settings',
      () {
        for (final ep in [
          '/api/get-settings-v2',
          '/get-settings-v2',
          '/get-settings-v2?cb=99281',
          '/get-settings',
        ]) {
          final res = demoService.handleDemoRequest(
            endpoint: ep,
            method: 'GET',
          );
          expect(res, isNotNull);
          expect(res!['status'], equals(true));
          final data = res['data'] as List;
          expect(data, isNotEmpty);
          expect(data.any((s) => s['name'] == 'site_title'), isTrue);
          expect(data.any((s) => s['name'] == 'currency'), isTrue);
        }
      },
    );

    test('returns immediate mock for /api/get-currencies', () {
      for (final ep in ['/api/get-currencies', '/get-currencies']) {
        final res = demoService.handleDemoRequest(endpoint: ep, method: 'GET');
        expect(res, isNotNull);
        expect(res!['status'], equals(true));
        final currencies = res['data'] as List;
        expect(currencies, isNotEmpty);
        expect(currencies.any((c) => c['code'] == 'USD'), isTrue);
        expect(currencies.any((c) => c['code'] == 'EUR'), isTrue);
        expect(currencies.any((c) => c['code'] == 'USDT'), isTrue);
      }
    });

    test('returns immediate mock for /get-countries and /get-languages', () {
      final countries = demoService.handleDemoRequest(
        endpoint: '/api/get-countries',
        method: 'GET',
      );
      expect(countries, isNotNull);
      expect(countries!['status'], equals(true));
      expect((countries['data'] as List), isNotEmpty);

      final languages = demoService.handleDemoRequest(
        endpoint: '/get-languages',
        method: 'GET',
      );
      expect(languages, isNotNull);
      expect(languages!['status'], equals(true));
      expect((languages['data'] as List), isNotEmpty);
    });

    test('returns immediate mock for arbitrary unmapped GET endpoint', () {
      final res = demoService.handleDemoRequest(
        endpoint: '/some/future/endpoint',
        method: 'GET',
      );
      expect(res, isNotNull);
      expect(res!['status'], equals('success'));
    });

    test('returns immediate mock for POST, PUT, PATCH, DELETE operations', () {
      for (final m in ['POST', 'PUT', 'PATCH', 'DELETE']) {
        final res = demoService.handleDemoRequest(
          endpoint: '/user/some-action',
          method: m,
          data: {'amount': 100},
        );
        expect(res, isNotNull);
        expect(res!['status'], equals('success'));
      }
    });
  });

  group('NetworkService Demo Mode Zero-Delay Interception', () {
    late DemoAccountService demoService;
    late NetworkService networkService;

    setUp(() {
      Get.put(TokenService());
      demoService = Get.put(DemoAccountService());
      demoService.isDemoMode.value = true;
      networkService = Get.put(NetworkService());
    });

    test('NetworkService.get intercepts /user/dashboard with 0ms delay', () async {
      final sw = Stopwatch()..start();
      final resp = await networkService.get(endpoint: '/user/dashboard');
      sw.stop();

      expect(resp.status, equals(Status.completed));
      expect(resp.data, isNotNull);
      expect(resp.data!['status'], equals('success'));
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('NetworkService.get intercepts /user/wallets with 0ms delay', () async {
      final sw = Stopwatch()..start();
      final resp = await networkService.get(endpoint: '/user/wallets');
      sw.stop();

      expect(resp.status, equals(Status.completed));
      expect(resp.data, isNotNull);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('NetworkService.globalGet intercepts /get-settings-v2 with 0ms delay', () async {
      final sw = Stopwatch()..start();
      final resp = await networkService.globalGet(
        endpoint: '/get-settings-v2?cb=123',
      );
      sw.stop();

      expect(resp.status, equals(Status.completed));
      expect(resp.data, isNotNull);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('NetworkService.globalPost intercepts immediate mock in demo mode', () async {
      final sw = Stopwatch()..start();
      final resp = await networkService.globalPost(
        endpoint: '/auth/user/login-otp/request',
        data: {'email': 'demo@ecardo.ir'},
      );
      sw.stop();

      expect(resp.status, equals(Status.completed));
      expect(resp.data, isNotNull);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });

    test('NetworkService.post intercepts immediate mock without timeout', () async {
      final sw = Stopwatch()..start();
      final resp = await networkService.post(
        endpoint: '/user/transfer',
        data: {'amount': '10.00', 'to': 'user2'},
      );
      sw.stop();

      expect(resp.status, equals(Status.completed));
      expect(resp.data, isNotNull);
      expect(sw.elapsedMilliseconds, lessThan(50));
    });
  });
}
