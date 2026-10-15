import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/services/app_lock_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/response/status.dart';

/// Test HTTP client adapter enabling fine-grained control over responses.
class _TestHttpClientAdapter implements HttpClientAdapter {
  Future<ResponseBody> Function(RequestOptions options)? onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (onFetch != null) {
      return onFetch!(options);
    }
    return ResponseBody.fromString(
      jsonEncode({
        'status': 'success',
        'data': {
          'token': 'jwt_mock_token_abc',
          'message': 'Operation successful',
        },
      }),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// In-memory mock implementation of [FlutterSecureStorage] allowing simulated
/// hardware keystore/keychain failures and verified inspection of stored values.
class InMemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> storage = {};
  bool shouldFailWrite = false;
  bool shouldFailRead = false;
  bool shouldFailDelete = false;

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (shouldFailRead) {
      throw PlatformException(
        code: 'KEYSTORE_UNAVAILABLE',
        message: 'Simulated Keystore/Keychain read failure',
      );
    }
    return storage[key];
  }

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
    if (shouldFailWrite) {
      throw PlatformException(
        code: 'KEYSTORE_LOCKED',
        message: 'Simulated Keystore/Keychain secure write failure',
      );
    }
    if (value != null) {
      storage[key] = value;
    } else {
      storage.remove(key);
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
    if (shouldFailDelete) {
      throw PlatformException(
        code: 'KEYSTORE_ERROR',
        message: 'Simulated delete failure',
      );
    }
    storage.remove(key);
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
    storage.clear();
  }

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return storage.containsKey(key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
  });

  tearDown(() {
    Get.reset();
  });

  group('Workstream A — Legacy PIN Migration & Plaintext Cleanup', () {
    test('Migrates 4-digit plaintext PIN to AppLockService and removes it from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'app_pin_4': '1382',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_pin_4'), '1382');

      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);
      Get.put<AppLockService>(appLock);

      final settings = SettingsService();
      Get.put<SettingsService>(settings);

      // Trigger migration
      await settings.migrateLegacyPin();

      // SharedPreferences must no longer contain 'app_pin_4'
      expect(prefs.containsKey('app_pin_4'), isFalse);
      expect(prefs.getString('app_pin_4'), isNull);

      // AppLockService must now have the PIN configured and verifiable
      expect(await appLock.hasPinSet(), isTrue);
      expect(await appLock.verifyPin('1382'), isTrue);
      expect(await appLock.verifyPin('0000'), isFalse);

      // Verify that the stored value is a salted SHA-256 hash, not plaintext!
      final storedHash = fakeSecure.storage['app_lock_pin_hash'];
      final storedSalt = fakeSecure.storage['app_lock_pin_salt'];
      expect(storedHash, isNotNull);
      expect(storedSalt, isNotNull);
      expect(storedHash, isNot(contains('1382')));
      expect(storedHash!.length, 64); // 256 bits = 64 hex chars
    });

    test('Purges legacy "set" placeholder without attempting invalid migration', () async {
      SharedPreferences.setMockInitialValues({
        'app_pin_4': 'set',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_pin_4'), 'set');

      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);
      Get.put<AppLockService>(appLock);

      final settings = SettingsService();
      Get.put<SettingsService>(settings);

      await settings.migrateLegacyPin();

      // Removed from SharedPreferences
      expect(prefs.containsKey('app_pin_4'), isFalse);
      // AppLockService should NOT have a PIN set from 'set'
      expect(await appLock.hasPinSet(), isFalse);
    });

    test('Purges invalid length legacy PINs safely from SharedPreferences', () async {
      SharedPreferences.setMockInitialValues({
        'app_pin_4': '12',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey('app_pin_4'), isTrue);

      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);
      Get.put<AppLockService>(appLock);

      final settings = SettingsService();
      await settings.migrateLegacyPin();

      expect(prefs.containsKey('app_pin_4'), isFalse);
      expect(await appLock.hasPinSet(), isFalse);
    });

    test('Does not overwrite existing AppLockService PIN during migration', () async {
      SharedPreferences.setMockInitialValues({
        'app_pin_4': '1111',
      });
      final prefs = await SharedPreferences.getInstance();

      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);
      await appLock.setPin('9999');
      Get.put<AppLockService>(appLock);

      final settings = SettingsService();
      Get.put<SettingsService>(settings);

      await settings.migrateLegacyPin();

      // SharedPreferences is cleaned up
      expect(prefs.containsKey('app_pin_4'), isFalse);
      // Existing PIN '9999' is preserved
      expect(await appLock.verifyPin('9999'), isTrue);
      expect(await appLock.verifyPin('1111'), isFalse);
    });

    test('wipeSession purges all credentials, session flags, and legacy PIN key', () async {
      SharedPreferences.setMockInitialValues({
        'login_current_state': 'logged_in',
        'current_email': 'user@ecardo.ir',
        'app_pin_4': '7777',
        'current_biometric': true,
      });
      final prefs = await SharedPreferences.getInstance();

      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);
      await appLock.setPin('7777');
      Get.put<AppLockService>(appLock);

      final settings = SettingsService();
      Get.put<SettingsService>(settings);

      await settings.wipeSession();

      expect(prefs.getString('login_current_state'), isNull);
      expect(prefs.getString('current_email'), isNull);
      expect(prefs.containsKey('app_pin_4'), isFalse);
      expect(await appLock.hasPinSet(), isFalse);
      expect(settings.currentEmail.value, isNull);
      expect(settings.logInCurrentState.value, isNull);
    });
  });

  group('Workstream A — TokenService Readiness & Failure Handling', () {
    test('saveAccessToken succeeds and updates reactive accessToken.value', () async {
      final fakeSecure = InMemorySecureStorage();
      final tokenService = TokenService(secureStorage: fakeSecure);

      final ok = await tokenService.saveAccessToken('secret_token_123');
      expect(ok, isTrue);
      expect(tokenService.accessToken.value, 'secret_token_123');
      expect(await fakeSecure.read(key: TokenService.accessTokenKey), 'secret_token_123');
    });

    test('saveAccessToken fails closed on Keystore write failure: resets memory to null and returns false', () async {
      final fakeSecure = InMemorySecureStorage();
      final tokenService = TokenService(secureStorage: fakeSecure);

      // Pre-condition: user was logged in with an old token
      await tokenService.saveAccessToken('old_token');
      expect(tokenService.accessToken.value, 'old_token');

      // Now simulate Keystore/Keychain write failure on re-auth/login
      fakeSecure.shouldFailWrite = true;
      final ok = await tokenService.saveAccessToken('new_token_failing');

      expect(ok, isFalse);
      // CRITICAL SECURITY FIX (FIND-004): Must NOT retain phantom token in memory!
      expect(tokenService.accessToken.value, isNull);
      // Keystore does NOT contain the new token
      expect(fakeSecure.storage[TokenService.accessTokenKey], 'old_token');
    });

    test('isReady Future guarantees loadAccessToken completion', () async {
      final fakeSecure = InMemorySecureStorage();
      await fakeSecure.write(key: TokenService.accessTokenKey, value: 'persisted_jwt');

      final tokenService = TokenService(secureStorage: fakeSecure);
      tokenService.onInit();

      // Await readiness Future
      await tokenService.isReady;

      expect(tokenService.accessToken.value, 'persisted_jwt');
    });

    test('Migrates legacy access_token from SharedPreferences to secure storage on load', () async {
      SharedPreferences.setMockInitialValues({
        'access_token': 'legacy_sp_token_456',
      });
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('access_token'), 'legacy_sp_token_456');

      final fakeSecure = InMemorySecureStorage();
      final tokenService = TokenService(secureStorage: fakeSecure);

      await tokenService.loadAccessToken();

      // Token loaded into reactive state
      expect(tokenService.accessToken.value, 'legacy_sp_token_456');
      // Token written to secure storage
      expect(fakeSecure.storage[TokenService.accessTokenKey], 'legacy_sp_token_456');
      // Plaintext token deleted from SharedPreferences
      expect(prefs.containsKey('access_token'), isFalse);
    });

    test('clearToken wipes secure storage and reactive state', () async {
      final fakeSecure = InMemorySecureStorage();
      final tokenService = TokenService(secureStorage: fakeSecure);
      await tokenService.saveAccessToken('token_to_clear');

      final ok = await tokenService.clearToken();
      expect(ok, isTrue);
      expect(tokenService.accessToken.value, isNull);
      expect(fakeSecure.storage[TokenService.accessTokenKey], isNull);
    });
  });

  group('Workstream A — AppLockService Salted SHA-256 PIN Verification', () {
    test('Generates salted SHA-256 hash with unique salt for identical PINs', () async {
      final storage1 = InMemorySecureStorage();
      final appLock1 = AppLockService(secureStorage: storage1);
      await appLock1.setPin('1234');

      final storage2 = InMemorySecureStorage();
      final appLock2 = AppLockService(secureStorage: storage2);
      await appLock2.setPin('1234');

      final hash1 = storage1.storage['app_lock_pin_hash'];
      final salt1 = storage1.storage['app_lock_pin_salt'];
      final hash2 = storage2.storage['app_lock_pin_hash'];
      final salt2 = storage2.storage['app_lock_pin_salt'];

      expect(hash1, isNotNull);
      expect(salt1, isNotNull);
      expect(hash2, isNotNull);
      expect(salt2, isNotNull);

      // Salts must differ
      expect(salt1, isNot(equals(salt2)));
      // Hashes must differ even though the PIN is identical!
      expect(hash1, isNot(equals(hash2)));

      // Both must verify correctly against their respective instances
      expect(await appLock1.verifyPin('1234'), isTrue);
      expect(await appLock2.verifyPin('1234'), isTrue);
    });

    test('Rejects invalid PIN formats with ArgumentError', () async {
      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);

      expect(() => appLock.setPin('12'), throwsArgumentError);
      expect(() => appLock.setPin('12345'), throwsArgumentError);
      expect(() => appLock.setPin('abcd'), throwsArgumentError);
      expect(() => appLock.setPin(''), throwsArgumentError);
    });

    test('Tracks failed unlock attempts and resets on successful unlock', () async {
      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);
      await appLock.setPin('5555');

      expect(appLock.failedAttempts.value, 0);

      // Failed unlock 1
      final ok1 = await appLock.unlock('0000');
      expect(ok1, isFalse);
      expect(appLock.failedAttempts.value, 1);

      // Failed unlock 2
      final ok2 = await appLock.unlock('1111');
      expect(ok2, isFalse);
      expect(appLock.failedAttempts.value, 2);

      // Successful unlock resets counter
      final okSuccess = await appLock.unlock('5555');
      expect(okSuccess, isTrue);
      expect(appLock.failedAttempts.value, 0);
      expect(appLock.locked.value, isFalse);
    });

    test('clearPin wipes hash, salt, failed count and resets state', () async {
      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);
      await appLock.setPin('8888');
      expect(await appLock.hasPinSet(), isTrue);

      await appLock.clearPin();

      expect(await appLock.hasPinSet(), isFalse);
      expect(fakeSecure.storage['app_lock_pin_hash'], isNull);
      expect(fakeSecure.storage['app_lock_pin_salt'], isNull);
      expect(fakeSecure.storage['app_lock_failed_count'], isNull);
    });

    test('Auto-lock timeout maps settings correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsService();
      Get.put<SettingsService>(settings);

      final fakeSecure = InMemorySecureStorage();
      final appLock = AppLockService(secureStorage: fakeSecure);

      // Default (0) = never
      expect(await appLock.getAutoLockTimeout(), Duration.zero);

      // -1 = immediate
      await settings.setAppLockMinutes(-1);
      expect((await appLock.getAutoLockTimeout()).inMilliseconds, -1);

      // 5 minutes
      await settings.setAppLockMinutes(5);
      expect(await appLock.getAutoLockTimeout(), const Duration(minutes: 5));
    });
  });

  group('Workstream A — Zero Plaintext Secrets in SharedPreferences Verification', () {
    test('SettingsService keys contain zero plaintext PIN or password storage methods', () async {
      SharedPreferences.setMockInitialValues({});
      final settings = SettingsService();
      Get.put<SettingsService>(settings);

      // Save valid settings
      await settings.saveLoggedInUserEmail('test@ecardo.ir');
      await settings.saveLoginCurrentState('logged_in');
      await settings.saveBiometricEnableOrDisable(true);
      await settings.saveSetUpPassword(true);
      await settings.saveEmailVerified(true);
      await settings.setThemeModePref('dark');
      await settings.setRateUnit('toman');

      final prefs = await SharedPreferences.getInstance();

      // Absolutely NO 'app_pin_4' key allowed
      expect(prefs.containsKey('app_pin_4'), isFalse);
      // Absolutely NO plaintext password key allowed
      expect(prefs.containsKey('current_password'), isFalse);
      expect(prefs.getString('current_password'), isNull);
    });
  });

  group('Workstream A — NetworkService & Session Safety on Secure Storage Failure', () {
    test('NetworkService.login aborts persistent login when saveAccessToken fails', () async {
      SharedPreferences.setMockInitialValues({});
      final fakeSecure = InMemorySecureStorage();
      final settings = SettingsService(secureStorage: fakeSecure);
      Get.put<SettingsService>(settings);

      // Pre-populate session state to verify it gets wiped on failure
      await settings.saveLoginCurrentState('logged_in');
      await settings.saveLoggedInUserEmail('victim@ecardo.ir');

      final tokenService = TokenService(secureStorage: fakeSecure);
      Get.put<TokenService>(tokenService);

      final networkService = NetworkService();
      Get.put<NetworkService>(networkService);

      final testAdapter = _TestHttpClientAdapter();
      networkService.dio.httpClientAdapter = testAdapter;

      // Simulate Keystore/Keychain failure
      fakeSecure.shouldFailWrite = true;

      final response = await networkService.login(
        email: 'user@ecardo.ir',
        password: 'Password123!',
      );

      // 1. Result must be an error, NOT completed
      expect(response.status, Status.error);
      expect(response.message, contains('Secure storage unavailable'));

      // 2. TokenService must NOT retain a phantom token
      expect(tokenService.accessToken.value, isNull);

      // 3. SettingsService session must be wiped clean
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('login_current_state'), isNull);
      expect(settings.logInCurrentState.value, isNull);
    });

    test('NetworkService.register aborts persistent login when saveAccessToken fails', () async {
      SharedPreferences.setMockInitialValues({});
      final fakeSecure = InMemorySecureStorage();
      final settings = SettingsService(secureStorage: fakeSecure);
      Get.put<SettingsService>(settings);

      final tokenService = TokenService(secureStorage: fakeSecure);
      Get.put<TokenService>(tokenService);

      final networkService = NetworkService();
      Get.put<NetworkService>(networkService);

      final testAdapter = _TestHttpClientAdapter();
      networkService.dio.httpClientAdapter = testAdapter;

      fakeSecure.shouldFailWrite = true;

      final response = await networkService.register(
        data: {'email': 'newuser@ecardo.ir', 'password': 'Password123!'},
      );

      expect(response.status, Status.error);
      expect(response.message, contains('Secure storage unavailable'));
      expect(tokenService.accessToken.value, isNull);
    });

    test('NetworkService.verifyLoginOtp aborts persistent login when saveAccessToken fails', () async {
      SharedPreferences.setMockInitialValues({});
      final fakeSecure = InMemorySecureStorage();
      final settings = SettingsService(secureStorage: fakeSecure);
      Get.put<SettingsService>(settings);

      final tokenService = TokenService(secureStorage: fakeSecure);
      Get.put<TokenService>(tokenService);

      final networkService = NetworkService();
      Get.put<NetworkService>(networkService);

      final testAdapter = _TestHttpClientAdapter();
      networkService.globalDio.httpClientAdapter = testAdapter;

      fakeSecure.shouldFailWrite = true;

      final response = await networkService.verifyLoginOtp(
        email: 'user@ecardo.ir',
        code: '123456',
      );

      expect(response.status, Status.error);
      expect(response.message, contains('Secure storage unavailable'));
      expect(tokenService.accessToken.value, isNull);
    });

    test('NetworkService onRequest attaches Bearer token once TokenService is ready', () async {
      SharedPreferences.setMockInitialValues({});
      final fakeSecure = InMemorySecureStorage();
      final settings = SettingsService(secureStorage: fakeSecure);
      Get.put<SettingsService>(settings);

      final tokenService = TokenService(secureStorage: fakeSecure);
      await tokenService.saveAccessToken('bearer_token_xyz');
      Get.put<TokenService>(tokenService);

      final networkService = NetworkService();
      Get.put<NetworkService>(networkService);

      RequestOptions? interceptedOptions;
      final testAdapter = _TestHttpClientAdapter();
      testAdapter.onFetch = (options) async {
        interceptedOptions = options;
        return ResponseBody.fromString(
          jsonEncode({'status': 'success', 'data': {'test': true}}),
          200,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType],
          },
        );
      };
      networkService.dio.httpClientAdapter = testAdapter;

      await networkService.get(endpoint: '/api/test-endpoint');

      expect(interceptedOptions, isNotNull);
      expect(interceptedOptions!.headers['Authorization'], 'Bearer bearer_token_xyz');
    });

    test('Phantom session detection and cleanup: logged_in flag without token is wiped', () async {
      SharedPreferences.setMockInitialValues({
        'login_current_state': 'logged_in',
        'current_email': 'phantom@ecardo.ir',
      });
      final fakeSecure = InMemorySecureStorage();
      final settings = SettingsService(secureStorage: fakeSecure);
      Get.put<SettingsService>(settings);

      final tokenService = TokenService(secureStorage: fakeSecure);
      await tokenService.loadAccessToken();
      Get.put<TokenService>(tokenService);

      // Verify initial phantom condition
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('login_current_state'), 'logged_in');
      expect(tokenService.accessToken.value, isNull);

      // Trigger session wipe on detected phantom state
      await settings.wipeSession();
      await tokenService.clearToken();

      expect(prefs.getString('login_current_state'), isNull);
      expect(prefs.getString('current_email'), isNull);
      expect(settings.logInCurrentState.value, isNull);
      expect(tokenService.accessToken.value, isNull);
    });
  });
}
