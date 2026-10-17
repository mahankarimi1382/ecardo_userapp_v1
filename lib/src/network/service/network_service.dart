import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx hide Response;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_helper.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';
import 'package:ecardo_user/src/common/services/kyc_error_handler.dart';
import 'package:ecardo_user/src/common/services/session_manager.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/config/ssl_pinning_config.dart';
import 'package:ecardo_user/src/common/services/offline_request_queue.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

class NetworkService extends getx.GetxService {
  // Properties
  final Dio _dio = Dio();
  final Dio _globalDio = Dio();
  final String baseUrl = ApiPath.baseUrl;
  late TokenService
  _tokenService; // Real app version (from pubspec via package_info_plus). Until resolved we
  // send an empty value — the server treats a missing/unparseable header as
  // pass-through. Never hardcode a stale version again (S-003/S-022 fix).
  String _appVersion = '';

  /// v1.0.24 (S-023) / Workstream B: in-flight Idempotency-Key registry keyed by
  /// '${method}:$path?$query:$identity'. A key is minted when an idempotent/money POST
  /// starts and released when that request completes with success (200/201).
  /// On transport timeouts (connection/receive/send timeout, SocketException),
  /// the key is retained up to 5 minutes so immediate retries reuse the identical
  /// key, preventing double-debits.
  final Map<String, _IdempotencyEntry> _inflightIdempotency = {};

  static const Duration _idempotencyTtl = Duration(minutes: 5);
  static const int _maxIdempotencyEntries = 50;
  DateTime Function() _clock = DateTime.now;

  /// Endpoints that move money — every POST to one of these carries an
  /// Idempotency-Key (the X-Request-ID of the logical call) so the server
  /// (S-023 middleware) can collapse accidental double submissions.
  static const List<String> _idempotentEndpointSuffixes = [
    '/user/pay-bill',
    '/user/transfer',
    '/user/cashout',
    '/user/gifts',
    '/user/withdraw',
    '/user/exchange',
    // The server guards remittance store with the idempotency middleware
    // (FIX-R5), but that middleware is a pass-through when the header is
    // absent — so without this entry the double-debit guard was inert.
    '/user/remittance/store',
    // World-Class Fintech standard: All money movements and commitments carry idempotency keys
    '/user/loans/apply',
    '/user/loans/repay',
    '/user/loans/early-repayment',
    '/user/escrow/store',
    '/user/escrow/pay',
    '/user/escrow/release',
    '/user/stocks/order',
    '/user/guarantee/apply',
    '/user/guarantee/deposit-margin',
    '/user/virtual-card/create',
    '/user/virtual-card/fund',
    '/user/p2p/create-order',
    '/user/p2p/release-order',
    '/user/p2p/pay-order',
    '/user/travel/book',
    '/user/travel/order',
    '/user/visa/requests',
    '/user/card-orders',
    '/user/virtual-card/topup',
    '/user/virtual-card/balance-topup',
    '/user/add-money',
    '/user/rentals/book',
    '/user/tours/book',
    '/user/licenses/order',
  ];

  AppLocalizations? get localization {
    final ctx = getx.Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

  // ------------------------- RELEASE SAFETY: DEMO GATE ------------------------- //
  //
  // Demo mode short-circuits the socket and returns fabricated balances. It is a
  // debug-only tool, so EVERY interception site below (there are many, including the
  // on-network-error fallback paths) must go through this one guard rather than
  // re-testing `isRegistered && isDemoMode` inline.
  //
  // `kDebugMode` is a compile-time constant: false in profile and release builds, so
  // in a shipped app this always returns false and no mock can ever be served — even
  // if the service were registered by some future code path.
  static bool get _demoInterceptionAllowed =>
      DemoAccountService.isDemoInterceptionAllowedNow;

  // Lifecycle Methods
  @override
  void onInit() {
    super.onInit();
    _tokenService = getx.Get.find<TokenService>();
    _configureHttpClient();
    _configureGlobalHttpClient();
    _resolveAppVersion();
  }

  Future<void> _resolveAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = info.version;
      if (kDebugMode) debugPrint('📱 X-App-Version resolved: $_appVersion');
    } catch (e) {
      debugPrint('⚠️ Could not resolve app version: $e');
    }
  }

  // Config for secured dio
  void _configureHttpClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.contentType = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    // v1.0.24: explicit timeouts — requests used to hang indefinitely on a
    // dead connection, keeping spinners on screen forever.
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(seconds: 30);

    // BUG-10 (P2): Runtime TLS certificate pinning for ecardo domains.
    // SECURITY: badCertificateCallback was removed here. It is the callback
    // for chains the platform REJECTED, so returning the pinning result from
    // it accepted untrusted certificates outright. Dio's validateCertificate
    // runs after the platform has already accepted the chain, which is the
    // correct place for a pin check.
    if (!kIsWeb) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        validateCertificate: (cert, host, port) {
          return SslPinningConfig.validateCertificate(
            cert?.der,
            host,
            allowDebugWithoutPin: kDebugMode,
          );
        },
      );
    }

    _setupInterceptors();
  }

  // Config for global dio
  void _configureGlobalHttpClient() {
    _globalDio.options.baseUrl = baseUrl;
    _globalDio.options.contentType = 'application/json';
    _globalDio.options.headers['Accept'] = 'application/json';
    _globalDio.options.connectTimeout = const Duration(seconds: 15);
    _globalDio.options.receiveTimeout = const Duration(seconds: 30);
    _globalDio.options.sendTimeout = const Duration(seconds: 30);

    // BUG-10 (P2): Runtime TLS certificate pinning for global dio.
    // SECURITY: see the note in _configureHttpClient — no badCertificateCallback.
    if (!kIsWeb) {
      _globalDio.httpClientAdapter = IOHttpClientAdapter(
        validateCertificate: (cert, host, port) {
          return SslPinningConfig.validateCertificate(
            cert?.der,
            host,
            allowDebugWithoutPin: kDebugMode,
          );
        },
      );
    }

    _globalDio.interceptors.clear();
    _globalDio.interceptors.add(
      _TransportRetryInterceptor((options) => _globalDio.fetch(options)),
    );
  }

  // v1.0.5: Token refresh state — جلوگیری از refresh همزمان
  // v1.0.24: queued callbacks now take a nullable token — null means the
  // refresh FAILED and the queued request must be failed too (they used to
  // hang forever when the refresh errored out).
  bool _isRefreshing = false;
  final List<void Function(String?)> _pendingRequests = [];

  // Setup Interceptor
  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      _TransportRetryInterceptor((options) => _dio.fetch(options)),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Await token readiness to prevent premature dispatched requests racing initial load/migration
          await _tokenService.isReady;
          String? accessToken = _tokenService.accessToken.value;
          // v1.0.24: never log the raw token (was: full bearer leak in logs).
          _log(
            '🔑 Token: ${accessToken == null || accessToken.isEmpty ? '<none>' : '<redacted ${accessToken.length} chars>'}',
          );

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          // v1.0.5: Request ID برای traceability
          options.headers['X-Request-ID'] =
              options.headers['X-Request-ID'] ?? _generateRequestId();

          // v1.0.24: real version instead of hardcoded '1.0.5'
          if (_appVersion.isNotEmpty) {
            options.headers['X-App-Version'] = _appVersion;
          }
          options.headers['X-Client'] = 'ecardo_user_flutter';

          // v1.0.24 (S-023 client side) / Workstream B: money and idempotent POSTs
          // carry Idempotency-Key.
          // The key is reused across an in-flight logical call and retained on
          // transport timeouts (up to 5 min TTL) so a retry maps to the same
          // idempotency key server-side.
          if (options.method.toUpperCase() == 'POST' &&
              options.headers['Idempotency-Key'] == null) {
            final path = options.uri.path;
            final rawOpId =
                options.headers['X-Operation-ID'] ??
                options.extra['operationId'];
            final explicitOpId =
                (rawOpId is String && rawOpId.trim().isNotEmpty)
                ? rawOpId.trim()
                : null;
            final isMoney = _idempotentEndpointSuffixes.any(
              (suffix) => path.endsWith(suffix),
            );
            if (isMoney || explicitOpId != null) {
              _evictExpiredIdempotencyEntries();
              final mapKey = _getIdempotencyMapKey(options);
              var entry = _inflightIdempotency[mapKey];
              final now = _clock();
              if (entry != null &&
                  now.difference(entry.createdAt) >= _idempotencyTtl) {
                _inflightIdempotency.remove(mapKey);
                entry = null;
              }
              if (entry == null) {
                _boundRegistrySize();
                final seed =
                    explicitOpId ??
                    (options.headers['X-Request-ID'] as String?) ??
                    _generateRequestId();
                entry = _IdempotencyEntry(seed, now);
                _inflightIdempotency[mapKey] = entry;
              }
              options.headers['Idempotency-Key'] = entry.key;
              // P1-02 (FIN-IDEM-02): Send both Idempotency-Key and X-Idempotency-Key
              // to guarantee 100% compatibility across all server and middleware contracts.
              options.headers['X-Idempotency-Key'] = entry.key;
              if (explicitOpId != null &&
                  options.headers['X-Operation-ID'] == null) {
                options.headers['X-Operation-ID'] = explicitOpId;
              }
            }
          }
          // v1.0.5: Platform identification
          if (kIsWeb) {
            options.headers['X-Platform'] = 'web';
          } else {
            options.headers['X-Platform'] = Platform.isAndroid
                ? 'android'
                : Platform.isIOS
                ? 'ios'
                : 'unknown';
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          final statusCode = response.statusCode;
          if (statusCode == null || (statusCode >= 200 && statusCode < 300)) {
            _releaseIdempotencyKey(response.requestOptions);
          }
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final isTimeout = _isTransportTimeoutOrSocketException(error);
          final statusCode = error.response?.statusCode;
          // P0-02 (FIN-IDEM-01): 5xx server errors are ambiguous — the server transaction
          // may have committed before an upstream or serialization crash occurred.
          // Retain the idempotency key for 5xx, timeouts, and connection drops to prevent
          // double-debits on retry! Only release on deterministic 4xx client errors (e.g. 400, 422).
          final isAmbiguousServerError =
              statusCode != null && statusCode >= 500 && statusCode < 600;
          if (!isTimeout && !isAmbiguousServerError) {
            _releaseIdempotencyKey(error.requestOptions);
          }
          if (error.response?.statusCode == 401) {
            // Do NOT attempt token refresh for login/auth/fcm or unauthenticated endpoints
            final path = error.requestOptions.uri.path;
            final isUnauthenticatedFlow =
                path.contains('/auth/user/login') ||
                path.contains('/auth/user/login-otp') ||
                path.contains('/auth/user/register') ||
                path.contains('/auth/user/refresh') ||
                path.contains('/setup-fcm');

            final currentToken = _tokenService.accessToken.value;
            if (isUnauthenticatedFlow ||
                currentToken == null ||
                currentToken.isEmpty) {
              return handler.next(error);
            }

            _log("401 Unauthorized — attempting token refresh...");

            // v1.0.5: اگر در حال refresh هستیم، request را صف کنیم
            if (_isRefreshing) {
              _pendingRequests.add((newToken) {
                if (newToken == null) {
                  // refresh failed meanwhile — fail this queued request too
                  handler.next(error);
                  return;
                }
                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                _dio
                    .fetch(error.requestOptions)
                    .then(
                      (response) => handler.resolve(response),
                      onError: (e) => handler.next(error),
                    );
              });
              return;
            }

            // تلاش برای refresh
            _isRefreshing = true;
            final refreshed = await _attemptTokenRefresh();
            _isRefreshing = false;

            if (refreshed) {
              final newToken = _tokenService.accessToken.value;
              if (newToken != null) {
                // v1.0.24: drain the queue FIRST (with the new token) so the
                // queued requests can never be left hanging, then retry the
                // original request.
                final queued = List<void Function(String?)>.of(
                  _pendingRequests,
                );
                _pendingRequests.clear();
                for (final callback in queued) {
                  callback(newToken);
                }

                error.requestOptions.headers['Authorization'] =
                    'Bearer $newToken';
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  handler.resolve(response);
                  return;
                } catch (e) {
                  _log('Retry failed: $e');
                  if (e is DioException) {
                    return handler.next(e);
                  }
                  return handler.next(error);
                }
              }
            }

            // refresh ناموفق — fail queued requests + single-flight logout
            _log("Token refresh failed — logging out.");
            final queued = List<void Function(String?)>.of(_pendingRequests);
            _pendingRequests.clear();
            for (final callback in queued) {
              callback(null); // null => handler.next(error) for that request
            }

            final isForeground =
                error.requestOptions.extra['isForeground'] as bool? ?? true;

            if (getx.Get.isRegistered<SessionManager>()) {
              unawaited(
                getx.Get.find<SessionManager>().handleUnauthorized(
                  isForeground: isForeground,
                  message:
                      localization?.unauthorizedDialogTitle ??
                      'Your session has expired. Please sign in again.',
                ),
              );
            }
          }

          // v1.0.26 (UPD-5): server-side force update — CheckAppVersion
          // answers 426 when the running version is older than the published
          // one and force update is enabled. Surface the non-dismissible
          // update dialog instead of a generic request error.
          if (error.response?.statusCode == 426) {
            _handleServerForcedUpdate(error.response?.data);
          }

          // v1.1 (KYC-ERR): unified KYC block contract — 403
          // KYC_LEVEL_REQUIRED / KYC_FEATURE_REQUIRED route the user to the
          // UpgradeRequiredScreen (instead of a raw 403 toast) and 503
          // KYC_CHECK_UNAVAILABLE surfaces a retry message without ever
          // logging out or clearing the token. Flagged on requestOptions so
          // the shared 403/503 branches below stay in sync.
          final kycBlock = KycErrorHandler.parse(
            error.response?.data,
            statusCode: error.response?.statusCode,
          );
          if (kycBlock != null) {
            error.requestOptions.extra[KycErrorHandler.handledExtraKey] = true;
            await KycErrorHandler.handle(kycBlock);
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// v1.0.26 (UPD-5): show the force-update dialog when the server answers
  /// 426. The dialog downloads from the settings app_update_link (the GitHub
  /// release asset). Guarded inside AppUpdateHelper so concurrent 426s from
  /// parallel requests surface the dialog only once.
  void _handleServerForcedUpdate(dynamic data) {
    try {
      final body = data is Map
          ? Map<String, dynamic>.from(data)
          : (data is String ? jsonDecode(data) as Map<String, dynamic> : null);
      AppUpdateHelper.handleServerForcedUpdate(body);
    } catch (e) {
      _log('426 handling failed: $e');
    }
  }

  /// v1.0.5: تلاش برای refresh token
  /// از endpoint /api/auth/user/refresh استفاده می‌کند
  Future<bool> _attemptTokenRefresh() async {
    // NET-FIX: the refresh POST used to carry exactly one attempt, so a
    // single flaky second during the refresh call logged the user out of a
    // perfectly valid session. Retry the transport failure once before
    // declaring the session dead (an HTTP 401 from the server is NOT a
    // transport failure — it fails immediately as before).
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(milliseconds: 800));
          _log('Retrying token refresh (attempt ${attempt + 1})...');
        } else {
          _log('Attempting token refresh...');
        }
        final response = await _globalDio.post(
          '$baseUrl${ApiPath.tokenRefreshEndpoint}',
          options: Options(
            headers: {
              'Authorization': 'Bearer ${_tokenService.accessToken.value}',
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

        if (response.statusCode == 200) {
          final newToken = response.data['data']?['token'];
          if (newToken != null && newToken is String) {
            final saveOk = await _tokenService.saveAccessToken(newToken);
            if (!saveOk) {
              _log(
                '❌ Failed to save refreshed access token to secure storage',
                icon: '❌',
              );
              return false;
            }
            _log('✓ Token refreshed successfully');
            return true;
          }
        }
        _log('Token refresh failed: ${response.statusCode}');
        return false;
      } on DioException catch (e) {
        final isTransportFailure = e.response == null;
        _log('Token refresh error: $e');
        if (!isTransportFailure || attempt == 1) return false;
      } catch (e) {
        _log('Token refresh error: $e');
        return false;
      }
    }
    return false;
  }

  void _evictExpiredIdempotencyEntries([DateTime? now]) {
    final currentTime = now ?? _clock();
    _inflightIdempotency.removeWhere(
      (_, entry) => currentTime.difference(entry.createdAt) >= _idempotencyTtl,
    );
  }

  void _boundRegistrySize() {
    while (_inflightIdempotency.length >= _maxIdempotencyEntries) {
      final oldestKey = _inflightIdempotency.entries
          .reduce(
            (a, b) => a.value.createdAt.isBefore(b.value.createdAt) ? a : b,
          )
          .key;
      _inflightIdempotency.remove(oldestKey);
    }
  }

  String _getIdempotencyMapKey(RequestOptions options) {
    final rawOpId =
        options.headers['X-Operation-ID'] ?? options.extra['operationId'];
    final explicitOpId = (rawOpId is String && rawOpId.trim().isNotEmpty)
        ? rawOpId.trim()
        : null;
    final identity = explicitOpId != null
        ? 'op:$explicitOpId'
        : _payloadFingerprint(options.data);
    return '${options.method.toUpperCase()}:${options.uri.path}?${options.uri.query}:$identity';
  }

  /// Workstream B: release the in-flight idempotency key once the request
  /// has finished successfully (or on deterministic 4xx client errors), so the
  /// NEXT logical submission mints a fresh key.
  void _releaseIdempotencyKey(RequestOptions options) {
    final headerKey =
        options.headers['Idempotency-Key'] ??
        options.headers['X-Idempotency-Key'];
    if (headerKey is! String || headerKey.isEmpty) return;
    _evictExpiredIdempotencyEntries();
    final mapKey = _getIdempotencyMapKey(options);
    if (_inflightIdempotency[mapKey]?.key == headerKey) {
      _inflightIdempotency.remove(mapKey);
    }
  }

  bool _isTransportTimeoutOrSocketException(DioException error) {
    if (error.response != null) return false;
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }
    final underlying = error.error;
    if (underlying is SocketException ||
        (underlying != null &&
            underlying.toString().toLowerCase().contains('socketexception'))) {
      return true;
    }
    final message = error.message?.toLowerCase() ?? '';
    if (message.contains('socketexception') ||
        message.contains('connection refused') ||
        message.contains('connection reset') ||
        message.contains('network is unreachable') ||
        message.contains('broken pipe')) {
      return true;
    }
    return false;
  }

  /// phase1-fix (P0-3): payload fingerprint for idempotency scoping.
  String _payloadFingerprint(Object? data) {
    if (data == null) return 'empty';
    if (data is FormData) return 'fd:${data.boundary}';
    try {
      return 'j:${jsonEncode(data).hashCode.toRadixString(36)}';
    } catch (_) {
      return 'raw:${data.hashCode}';
    }
  }

  /// Cryptographically random, unguessable request ID.
  String _generateRequestId() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(12, (_) => rnd.nextInt(256));
    return 'req-${base64UrlEncode(bytes).replaceAll('=', '').toLowerCase()}';
  }

  static const Set<String> _sensitivePayloadKeys = {
    'password',
    'current_password',
    'currentpassword',
    'current-password',
    'new_password',
    'newpassword',
    'new-password',
    'password_confirmation',
    'passwordconfirmation',
    'password-confirmation',
    'code',
    'otp',
    'passcode',
    'pin',
    'cvv',
    'card_number',
    'cardnumber',
    'card-number',
    'pan',
    'access_token',
    'accesstoken',
    'access-token',
    'refresh_token',
    'refreshtoken',
    'refresh-token',
    'authorization',
    'iban',
    'account_number',
    'accountnumber',
    'account-number',
    'national_id',
    'nationalid',
    'national-id',
    'secret',
    'bearer',
  };

  static bool _isSensitiveKey(String key) {
    final trimmed = key.trim();
    if (_sensitivePayloadKeys.contains(trimmed)) return true;
    final lower = trimmed.toLowerCase();
    if (_sensitivePayloadKeys.contains(lower)) return true;
    final stripped = lower.replaceAll(RegExp(r'[-_\s]'), '');
    return _sensitivePayloadKeys.contains(stripped);
  }

  static dynamic _sanitizePayload(dynamic data) {
    if (data is Map) {
      final sanitized = <dynamic, dynamic>{};
      for (final entry in data.entries) {
        final keyStr = entry.key.toString();
        if (_isSensitiveKey(keyStr)) {
          sanitized[entry.key] = '<redacted>';
        } else {
          sanitized[entry.key] = _sanitizePayload(entry.value);
        }
      }
      return sanitized;
    } else if (data is List) {
      return data.map(_sanitizePayload).toList();
    }
    return data;
  }

  // ------------------------------ AUTH CALLS ------------------------------ //

  // Login POST Method
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    String url = '${_dio.options.baseUrl}${ApiPath.loginEndpoint}';

    _log('📤 Login POST Request URL: $url');
    // v1.0.24: never log the password — only the (non-secret) email.
    _log(
      '📦 Login POST Request Body: {"email": $email, "password": "<redacted>"}',
    );

    try {
      final response = await _dio.post(
        ApiPath.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      _log('✅ Login POST Status Code: ${response.statusCode}');
      // v1.0.24: response contains the bearer token — do not log it raw.
      _log('✅ Login POST Response: <received, token not logged>');

      if (response.statusCode == 200) {
        String accessToken = response.data["data"]["token"];
        await _tokenService.clearToken();
        final saveOk = await _tokenService.saveAccessToken(accessToken);
        if (!saveOk) {
          _log('❌ Failed to save access token to secure storage', icon: '❌');
          if (getx.Get.isRegistered<SettingsService>()) {
            await getx.Get.find<SettingsService>().wipeSession();
          }
          await _tokenService.clearToken();
          final errorMsg = _secureStorageUnavailableMessage();
          ToastHelper().showErrorToast(errorMsg);
          return ApiResponse.error(errorMsg);
        }
        _log('🔑 Token Saved Successfully');
        return ApiResponse.completed(response.data);
      }

      return ApiResponse.error('Login failed.');
    } on DioException catch (e) {
      return _handleDioException(e, "Login POST");
    } catch (e) {
      _log('Login POST Exception: ${e.toString()}', icon: '❌');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    } finally {
      // v1.0.24: interceptors used to be cleared at the start of login() and
      // only re-installed on success — after a FAILED login every subsequent
      // request lost its headers/401 handling. Always (re)install (the
      // method clears before adding, so no duplicates).
      _setupInterceptors();
    }
  }

  // WAVE-1: request a 6-digit email login code (unauthenticated channel).
  // The server answers identically whether the email exists or not — no
  // account enumeration.
  Future<ApiResponse<Map<String, dynamic>>> requestLoginOtp({
    required String email,
  }) async {
    _log('📤 Login OTP Request for $email');
    try {
      final response = await _globalDio.post(
        '${_globalDio.options.baseUrl}${ApiPath.loginOtpRequestEndpoint}',
        data: {'email': email},
      );
      if (response.statusCode == 200) {
        return ApiResponse.completed(Map<String, dynamic>.from(response.data));
      }
      return ApiResponse.error('Request failed.');
    } on DioException catch (e) {
      return _handleDioException(e, "Login OTP Request");
    } catch (e) {
      _log('LoginOtpRequest Exception: ${e.toString()}', icon: '❌');
      return ApiResponse.error(e.toString());
    }
  }

  // WAVE-1: verify the email code and persist the bearer token — the
  // response shape is identical to login(), so the shared post-login chain
  // (fetchUser → 2FA gate → passcode/onboarding) can run unchanged.
  Future<ApiResponse<Map<String, dynamic>>> verifyLoginOtp({
    required String email,
    required String code,
  }) async {
    _log('📤 Login OTP Verify for $email (code not logged)');
    try {
      final response = await _globalDio.post(
        '${_globalDio.options.baseUrl}${ApiPath.loginOtpVerifyEndpoint}',
        data: {'email': email, 'code': code},
      );
      if (response.statusCode == 200) {
        final accessToken = response.data["data"]?["token"];
        if (accessToken is String && accessToken.isNotEmpty) {
          await _tokenService.clearToken();
          final saveOk = await _tokenService.saveAccessToken(accessToken);
          if (!saveOk) {
            _log(
              '❌ Failed to save OTP access token to secure storage',
              icon: '❌',
            );
            if (getx.Get.isRegistered<SettingsService>()) {
              await getx.Get.find<SettingsService>().wipeSession();
            }
            await _tokenService.clearToken();
            final errorMsg = _secureStorageUnavailableMessage();
            ToastHelper().showErrorToast(errorMsg);
            return ApiResponse.error(errorMsg);
          }
          _setupInterceptors();
          _log('🔑 Login OTP token saved');
        }
        return ApiResponse.completed(Map<String, dynamic>.from(response.data));
      }
      return ApiResponse.error('Verification failed.');
    } on DioException catch (e) {
      return _handleDioException(e, "Login OTP Verify");
    } catch (e) {
      _log('LoginOtpVerify Exception: ${e.toString()}', icon: '❌');
      return ApiResponse.error(e.toString());
    }
  }

  // Register POST Method
  Future<ApiResponse<Map<String, dynamic>>> register({
    required Map<String, dynamic> data,
  }) async {
    String url = '${_dio.options.baseUrl}${ApiPath.registerEndpoint}';
    final stopwatch = Stopwatch()..start();

    _log('📤 Register POST Request URL: $url');
    // v1.0.24: never log plaintext passwords — redact like login() does.
    _log(
      '📦 Register POST Request Body: ${jsonEncode(_sanitizePayload(data))}',
    );

    try {
      final response = await _dio.post(
        ApiPath.registerEndpoint,
        data: jsonEncode(data),
      );

      stopwatch.stop();
      _log('✅ Register Status Code: ${response.statusCode}');
      // v1.0.24: response contains the bearer token — do not log it raw.
      _log('✅ Register Response: <received, token not logged>');
      _log('⏱️ Register Time: ${stopwatch.elapsedMilliseconds}ms');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        final accessToken = responseData["data"]?['token'];
        if (accessToken is String && accessToken.isNotEmpty) {
          final saveOk = await _tokenService.saveAccessToken(accessToken);
          if (!saveOk) {
            _log(
              '❌ Failed to save register access token to secure storage',
              icon: '❌',
            );
            if (getx.Get.isRegistered<SettingsService>()) {
              await getx.Get.find<SettingsService>().wipeSession();
            }
            await _tokenService.clearToken();
            final errorMsg = _secureStorageUnavailableMessage();
            ToastHelper().showErrorToast(errorMsg);
            return ApiResponse.error(errorMsg);
          }
          _setupInterceptors();
          _log('🔑 Token Saved Successfully');
        }
        return ApiResponse.completed(responseData);
      }

      return ApiResponse.error('Register failed.');
    } on DioException catch (e) {
      stopwatch.stop();
      _log('⏱️ Register Time: ${stopwatch.elapsedMilliseconds}ms');
      return _handleDioException(e, "Register");
    } catch (e) {
      stopwatch.stop();
      _log('⏱️ Register Time: ${stopwatch.elapsedMilliseconds}ms');
      _log('Register Exception: ${e.toString()}', icon: '❌');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  // ----------------------------- SECURED API ------------------------------ //

  Future<ApiResponse<Map<String, dynamic>>> get({
    required String endpoint,
    bool isForeground = true,
  }) async {
    // Demo Mode Smart Response
    if (_demoInterceptionAllowed) {
      final mock = getx.Get.find<DemoAccountService>().handleDemoRequest(
        endpoint: endpoint,
        method: 'GET',
      );
      if (mock != null) {
        _log('⚡ [DEMO MOCK] Instant response for GET $endpoint');
        return ApiResponse.completed(mock);
      }
      return ApiResponse.completed({
        'status': 'success',
        'message': 'Demo Mode simulated response',
        'data': <String, dynamic>{},
      });
    }

    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📥 GET Request URL: $url');

    try {
      final response = await _dio.get(
        endpoint,
        options: Options(extra: {'isForeground': isForeground}),
      );
      return _handleResponse(response, "GET");
    } on DioException catch (e) {
      // Demo Mode Smart Fallback on network errors or 404
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'GET',
          statusCode: e.response?.statusCode,
        );
        if (fallback != null) {
          _log('🛡️ [DEMO FALLBACK] Handled network error for GET $endpoint');
          return ApiResponse.completed(fallback);
        }
      }
      return _handleDioException(e, "GET");
    } catch (e) {
      _log('GET Exception: ${e.toString()}', icon: '❌');
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'GET',
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> post({
    required String endpoint,
    Map<String, dynamic>? data,
    String? idempotencyKey,
    String? operationId,
    bool isForeground = true,
  }) async {
    // Demo Mode Smart Response
    if (_demoInterceptionAllowed) {
      final mock = getx.Get.find<DemoAccountService>().handleDemoRequest(
        endpoint: endpoint,
        method: 'POST',
        data: data,
      );
      if (mock != null) {
        _log('⚡ [DEMO MOCK] Instant response for POST $endpoint');
        return ApiResponse.completed(mock);
      }
    }

    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📤 POST Request URL: $url');

    if (data != null) {
      _log('📦 POST Request Body: ${jsonEncode(_sanitizePayload(data))}');
    } else {
      _log('📦 POST Request Body: No body data');
    }

    try {
      final headers = <String, dynamic>{};
      if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
        headers['Idempotency-Key'] = idempotencyKey;
        headers['X-Idempotency-Key'] = idempotencyKey;
      }
      if (operationId != null && operationId.isNotEmpty) {
        headers['X-Operation-ID'] = operationId;
      }
      final response = await _dio.post(
        endpoint,
        data: data != null ? jsonEncode(data) : null,
        options: Options(
          headers: headers.isEmpty ? null : headers,
          extra: {
            'isForeground': isForeground,
            if (operationId != null && operationId.isNotEmpty)
              'operationId': operationId,
          },
        ),
      );

      return _handleResponse(response, "POST");
    } on DioException catch (e) {
      // Demo Mode Smart Fallback
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'POST',
          data: data,
          statusCode: e.response?.statusCode,
        );
        if (fallback != null) {
          _log('🛡️ [DEMO FALLBACK] Handled network error for POST $endpoint');
          return ApiResponse.completed(fallback);
        }
      }

      // Queue non-financial POSTs when offline.
      if ((e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.connectionTimeout) &&
          getx.Get.isRegistered<OfflineRequestQueue>()) {
        final q = getx.Get.find<OfflineRequestQueue>();
        if (q.isQueueable(endpoint)) {
          await q.enqueue(
            method: 'POST',
            endpoint: endpoint,
            data: data,
            idempotencyKey: idempotencyKey,
          );
          return ApiResponse.error('queued_offline');
        }
      }
      return _handleDioException(e, "POST");
    } catch (e) {
      _log('POST Exception: ${e.toString()}', icon: '❌');
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'POST',
          data: data,
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      ToastHelper().showErrorToast(
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  /// v1.0.21+21 — Multipart POST for file uploads.
  ///
  /// Use this instead of [post] when the request body is a `FormData`
  /// (e.g. uploading files via `MultipartFile.fromFile`). The regular
  /// [post] method calls `jsonEncode(data)` which would corrupt a
  /// `FormData` instance — Dio needs the raw `FormData` object so it
  /// can stream the multipart body and set the Content-Type header
  /// (with the correct boundary) itself.
  ///
  /// The caller is responsible for constructing the `FormData`:
  /// ```dart
  /// final formData = FormData.fromMap({
  ///   'file': await MultipartFile.fromFile('/path/to/file'),
  /// });
  /// final response = await networkService.postMultipart(
  ///   endpoint: '/api/upload',
  ///   data: formData,
  /// );
  /// ```
  Future<ApiResponse<Map<String, dynamic>>> postMultipart({
    required String endpoint,
    required FormData data,
    bool isForeground = true,
    ProgressCallback? onSendProgress,
  }) async {
    // Demo Mode Upload Bypass
    if (_demoInterceptionAllowed) {
      _log('⚡ [DEMO MOCK] Instant success for multipart upload to $endpoint');
      return ApiResponse.completed({
        'status': 'success',
        'message': 'File uploaded successfully (Demo Mode)',
        'data': {'file_url': 'https://ecardo.ir/demo/uploaded_doc.jpg'},
      });
    }

    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📤 POST (multipart) Request URL: $url');
    _log(
      '📦 POST (multipart) Fields: ${data.fields.length}, Files: ${data.files.length}',
    );

    try {
      // Allow Dio to handle Content-Type and multipart boundary generation natively.
      // Manually setting boundary or contentType causes header stripping in Dio interceptors
      // and conflicts with Nginx/Cloudflare body parsing. Extended timeout for mobile stability.
      final response = await _dio.post(
        endpoint,
        data: data,
        onSendProgress: onSendProgress,
        options: Options(
          sendTimeout: const Duration(seconds: 180),
          receiveTimeout: const Duration(seconds: 180),
          extra: {'isForeground': isForeground},
          headers: {'Accept': 'application/json'},
        ),
      );
      return _handleResponse(response, "POST (multipart)");
    } on DioException catch (e) {
      if (_demoInterceptionAllowed) {
        return ApiResponse.completed({
          'status': 'success',
          'message': 'File upload simulated (Demo Mode)',
          'data': {'file_url': 'https://ecardo.ir/demo/uploaded_doc.jpg'},
        });
      }
      return _handleDioException(e, "POST (multipart)");
    } catch (e) {
      _log('POST (multipart) Exception: ${e.toString()}', icon: '❌');
      if (_demoInterceptionAllowed) {
        return ApiResponse.completed({
          'status': 'success',
          'message': 'File upload simulated (Demo Mode)',
          'data': {'file_url': 'https://ecardo.ir/demo/uploaded_doc.jpg'},
        });
      }
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> put({
    required String endpoint,
    Map<String, dynamic>? data,
    bool isForeground = true,
  }) async {
    // Demo Mode Smart Response
    if (_demoInterceptionAllowed) {
      final mock = getx.Get.find<DemoAccountService>().handleDemoRequest(
        endpoint: endpoint,
        method: 'PUT',
        data: data,
      );
      if (mock != null) {
        _log('⚡ [DEMO MOCK] Instant response for PUT $endpoint');
        return ApiResponse.completed(mock);
      }
    }

    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📤 PUT Request URL: $url');

    if (data != null) {
      _log('📦 PUT Request Body: ${jsonEncode(_sanitizePayload(data))}');
    } else {
      _log('📦 PUT Request Body: No body data');
    }

    try {
      final response = await _dio.put(
        endpoint,
        data: data != null ? jsonEncode(data) : null,
        options: Options(extra: {'isForeground': isForeground}),
      );

      return _handleResponse(response, "PUT");
    } on DioException catch (e) {
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'PUT',
          data: data,
          statusCode: e.response?.statusCode,
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      return _handleDioException(e, "PUT");
    } catch (e) {
      _log('PUT Exception: ${e.toString()}', icon: '❌');
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'PUT',
          data: data,
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  /// v1.0.88 — PATCH support (P2P ads/{id}/status-update and
  /// orders/{id}/payment-method on server accept only PATCH;
  /// previous post + {'_method': 'PATCH'} → 405 Method Not Allowed).
  Future<ApiResponse<Map<String, dynamic>>> patch({
    required String endpoint,
    Map<String, dynamic>? data,
    bool isForeground = true,
  }) async {
    // Demo Mode Smart Response
    if (_demoInterceptionAllowed) {
      final mock = getx.Get.find<DemoAccountService>().handleDemoRequest(
        endpoint: endpoint,
        method: 'PATCH',
        data: data,
      );
      if (mock != null) {
        return ApiResponse.completed(mock);
      }
    }

    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📤 PATCH Request URL: $url');

    if (data != null) {
      _log('📦 PATCH Request Body: ${jsonEncode(_sanitizePayload(data))}');
    } else {
      _log('📦 PATCH Request Body: No body data');
    }

    try {
      final response = await _dio.patch(
        endpoint,
        data: data != null ? jsonEncode(data) : null,
        options: Options(extra: {'isForeground': isForeground}),
      );

      return _handleResponse(response, "PATCH");
    } on DioException catch (e) {
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'PATCH',
          data: data,
          statusCode: e.response?.statusCode,
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      return _handleDioException(e, "PATCH");
    } catch (e) {
      _log('PATCH Exception: ${e.toString()}', icon: '❌');
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'PATCH',
          data: data,
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      ToastHelper().showErrorToast(
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> delete({
    required String endpoint,
    Map<String, dynamic>? data,
    bool isForeground = true,
  }) async {
    // Demo Mode Smart Response
    if (_demoInterceptionAllowed) {
      final mock = getx.Get.find<DemoAccountService>().handleDemoRequest(
        endpoint: endpoint,
        method: 'DELETE',
        data: data,
      );
      if (mock != null) {
        return ApiResponse.completed(mock);
      }
    }

    String url = '${_dio.options.baseUrl}$endpoint';
    _log('🗑️ DELETE Request URL: $url');

    if (data != null) {
      _log('📦 DELETE Request Body: ${jsonEncode(_sanitizePayload(data))}');
    } else {
      _log('📦 DELETE Request Body: No body data');
    }

    try {
      final response = await _dio.delete(
        endpoint,
        data: data != null ? jsonEncode(data) : null,
        options: Options(extra: {'isForeground': isForeground}),
      );

      return _handleResponse(response, "DELETE");
    } on DioException catch (e) {
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'DELETE',
          data: data,
          statusCode: e.response?.statusCode,
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      return _handleDioException(e, "DELETE");
    } catch (e) {
      _log('DELETE Exception: ${e.toString()}', icon: '❌');
      if (_demoInterceptionAllowed) {
        final fallback = getx.Get.find<DemoAccountService>().handleDemoFallback(
          endpoint: endpoint,
          method: 'DELETE',
          data: data,
        );
        if (fallback != null) {
          return ApiResponse.completed(fallback);
        }
      }
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  // ------------------------------ GLOBAL API ------------------------------ //

  Future<ApiResponse<Map<String, dynamic>>> globalPost({
    required String endpoint,
    Map<String, dynamic>? data,
    bool isForeground = true,
  }) async {
    // Demo Mode Smart Response
    if (_demoInterceptionAllowed) {
      final mock = getx.Get.find<DemoAccountService>().handleDemoRequest(
        endpoint: endpoint,
        method: 'POST',
        data: data,
      );
      if (mock != null) {
        _log('⚡ [DEMO MOCK] Instant response for Global POST $endpoint');
        return ApiResponse.completed(mock);
      }
      return ApiResponse.completed({
        'status': 'success',
        'message': 'Demo Mode simulated response',
        'data': {
          'id': DateTime.now().millisecondsSinceEpoch,
          'status': 'completed',
        },
      });
    }

    try {
      String url = '$baseUrl$endpoint';
      _log('Global POST Request URL: $url', icon: '✅');

      if (data != null) {
        _log(
          '📦 Global POST Request Body: ${jsonEncode(_sanitizePayload(data))}',
        );
      } else {
        _log('📦 Global POST Request Body: No body data');
      }

      final response = await _globalDio.post(
        url,
        data: data != null ? jsonEncode(data) : null,
        options: Options(
          headers: _baseHeaders,
          extra: {'isForeground': isForeground},
        ),
      );

      return _handleResponse(response, "Global POST");
    } on DioException catch (e) {
      return _handleDioException(e, "Global POST");
    } catch (e) {
      _log('Global POST Exception: ${e.toString()}', icon: '❌');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> globalGet({
    required String endpoint,
    bool isForeground = true,
  }) async {
    // Demo Mode Smart Response
    if (_demoInterceptionAllowed) {
      final mock = getx.Get.find<DemoAccountService>().handleDemoRequest(
        endpoint: endpoint,
        method: 'GET',
      );
      if (mock != null) {
        _log('⚡ [DEMO MOCK] Instant response for Global GET $endpoint');
        return ApiResponse.completed(mock);
      }
      return ApiResponse.completed({
        'status': 'success',
        'message': 'Demo Mode simulated response',
        'data': <String, dynamic>{},
      });
    }

    try {
      String url = '$baseUrl$endpoint';
      _log('Global GET Request URL: $url', icon: '✅');

      final response = await _globalDio.get(
        url,
        options: Options(
          headers: _baseHeaders,
          extra: {'isForeground': isForeground},
        ),
      );

      return _handleResponse(response, "Global GET");
    } on DioException catch (e) {
      return _handleDioException(e, "Global GET");
    } catch (e) {
      _log('Global GET Exception: ${e.toString()}', icon: '❌');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  // ------------------------------- HANDLERS ------------------------------- //

  ApiResponse<Map<String, dynamic>> _handleDioException(
    DioException e,
    String requestType,
  ) {
    // Detect No Internet Connection.
    // NET-FIX (RC2): this branch used to answer ANY transient connection
    // blip by tearing the whole navigation stack down with
    // `Get.offAllNamed(noInternetConnection)` — background dashboard
    // refreshes and FCM-poked settings calls could yank the user off their
    // screen mid-action. Offline navigation is owned exclusively by
    // ConnectivityWatchService (debounced 2s, route-guarded); this layer
    // only reports the error to the caller.
    if (e.type == DioExceptionType.connectionError ||
        (e.type == DioExceptionType.unknown &&
            e.error.toString().contains('SocketException'))) {
      _log('$requestType No Internet Connection', icon: '🚫');
      return ApiResponse.error('No internet connection');
    }

    // Detect Timeout Manually
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      _log('$requestType TimeoutException: Request timed out', icon: '⏳');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization with English fallback (was `localization!`).
        localization?.networkErrorTimeout ??
            'Request timed out. Please try again.',
      );
      return ApiResponse.error('Request timed out');
    }

    // Detect SSL / Bad Certificate validation failure
    if (e.type == DioExceptionType.badCertificate) {
      _log(
        '$requestType Security Error: SSL certificate verification failed',
        icon: '🚨',
      );
      ToastHelper().showErrorToast(
        localization?.networkErrorGeneric ??
            'Secure connection could not be established.',
      );
      return ApiResponse.error('SSL certificate verification failed');
    }

    // Server returned a response
    if (e.response != null) {
      return _handleDioErrorResponse(e.response!, requestType);
    }

    // Generic error
    _log('$requestType DioException: ${e.message}', icon: '🚫');
    ToastHelper().showErrorToast(
      // P-4: null-safe localization with English fallback (was `localization!`).
      localization?.networkErrorOccurred ??
          'An error occurred. Please try again.',
    );
    return ApiResponse.error(e.message ?? 'An error occurred');
  }

  ApiResponse<Map<String, dynamic>> _handleResponse(
    Response response,
    String requestType,
  ) {
    _log('Handling Response - Status Code: ${response.statusCode}', icon: '📥');

    switch (response.statusCode) {
      case 200:
      case 201:
        final jsonData = response.data is Map
            ? Map<String, dynamic>.from(response.data as Map)
            : <String, dynamic>{};
        _log(
          '$requestType Response: [status ${response.statusCode}]',
          icon: '✅',
        );
        return ApiResponse.completed(jsonData);
      default:
        _log('Unknown Status Code: ${response.statusCode}', icon: '❓');
        return ApiResponse.error('Error occurred: ${response.statusCode}');
    }
  }

  ApiResponse<Map<String, dynamic>> _handleDioErrorResponse(
    Response response,
    String requestType,
  ) {
    _log(
      'Handling Error Response - Status Code: ${response.statusCode}',
      icon: '⚠️',
    );

    switch (response.statusCode) {
      case 400:
        // v1.0.24: safe cast — some servers return an HTML error body which
        // made `as Map<String, dynamic>?` throw before a message was shown.
        final jsonResponse = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final errorMessages = _errorMessage(jsonResponse);
        _log('$requestType Error [status 400]: $errorMessages', icon: '❌');
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);
      case 401:
        final jsonResponse401 = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final errorMessages = _errorMessage(jsonResponse401);
        _log('$requestType Error [status 401]: $errorMessages', icon: '❌');

        // Do not invoke session expiration logout when user is on login/register endpoints
        final isAuthEndpoint =
            response.requestOptions.path.contains(ApiPath.loginEndpoint) ||
            response.requestOptions.path.contains('/login') ||
            response.requestOptions.path.contains('/register');

        // Delegate all UI + logout to SessionManager (single-flight).
        // isForeground comes from request options.extra (default true).
        final isForeground =
            response.requestOptions.extra['isForeground'] as bool? ?? true;

        if (!isAuthEndpoint && getx.Get.isRegistered<SessionManager>()) {
          unawaited(
            getx.Get.find<SessionManager>().handleUnauthorized(
              isForeground: isForeground,
              message: errorMessages,
            ),
          );
        } else if (isAuthEndpoint) {
          ToastHelper().showErrorToast(errorMessages);
        }

        return ApiResponse.error(errorMessages);

      case 403:
      case 404:
      case 422:
        final jsonResponse4xx = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final errorMessages = _errorMessage(jsonResponse4xx);
        _log(
          '$requestType Error [status ${response.statusCode}]: $errorMessages',
          icon: '❌',
        );
        // v1.1 (KYC-ERR): a KYC block (KYC_LEVEL_REQUIRED /
        // KYC_FEATURE_REQUIRED) was already routed to the
        // UpgradeRequiredScreen by the interceptor — the raw server message
        // must NOT double up as an error toast here.
        final isKycBlock =
            response.requestOptions.extra[KycErrorHandler.handledExtraKey] ==
            true;
        if (isKycBlock) {
          final friendly =
              localization?.kycUpgradeRequiredTitle ??
              'Verification upgrade required';
          return ApiResponse.error(friendly);
        }
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);

      case 500:
        final jsonResponse500 = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final errorMessages = _errorMessage(jsonResponse500);
        _log('$requestType Error [status 500]: $errorMessages', icon: '❌');
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);

      case 503:
        final jsonResponse503 = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        final errorMessages503 = _errorMessage(jsonResponse503);
        _log('$requestType Error [status 503]: $errorMessages503', icon: '❌');
        // v1.1 (KYC-ERR): KYC_CHECK_UNAVAILABLE is a transient verification
        // infrastructure outage — show a retry message, never logout, never
        // clear the token and never take over with the maintenance screen.
        final isKycUnavailable =
            response.requestOptions.extra[KycErrorHandler.handledExtraKey] ==
            true;
        if (isKycUnavailable) {
          final retryMessage =
              localization?.kycVerificationUnavailable ??
              'Verification service is temporarily unavailable. Please try again in a few moments.';
          ToastHelper().showErrorToast(retryMessage);
          return ApiResponse.error(retryMessage);
        }
        ToastHelper().showErrorToast(errorMessages503);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (getx.Get.currentRoute != BaseRoute.maintenanceMode) {
            getx.Get.offAllNamed(BaseRoute.maintenanceMode);
          }
        });
        return ApiResponse.error(errorMessages503);

      default:
        _log('Unknown Error [status ${response.statusCode}]', icon: '❓');
        ToastHelper().showErrorToast(
          // P-4: null-safe localization with English fallback (was `localization!`).
          localization?.networkErrorOccurred ??
              'An error occurred. Please try again.',
        );
        return ApiResponse.error('Error occurred: ${response.statusCode}');
    }
  }

  // ---------------------- UTILS ----------------------

  String _errorMessage(Map<String, dynamic> response) {
    for (final key in ['message', 'error', 'detail']) {
      final value = response[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return _friendlyServerMessage(value);
    }

    final errors = response['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          final message = value.first?.toString().trim() ?? '';
          if (message.isNotEmpty) return _friendlyServerMessage(message);
        }
        final message = value?.toString().trim() ?? '';
        if (message.isNotEmpty) return _friendlyServerMessage(message);
      }
    } else if (errors is List && errors.isNotEmpty) {
      final message = errors.first?.toString().trim() ?? '';
      if (message.isNotEmpty) return _friendlyServerMessage(message);
    }

    return localization?.networkErrorOccurred ?? 'An error occurred.';
  }

  String _friendlyServerMessage(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('no query results for model') ||
        lower.contains('model not found') ||
        lower.contains(r'app\models\page') ||
        lower.contains('app/models/page')) {
      return localization?.allControllerLoadError ??
          'This service is temporarily unavailable. Please try again later.';
    }
    if (lower.contains('user not found') ||
        lower.contains('account not found') ||
        lower.contains('no user') ||
        lower.contains('credentials do not match') ||
        lower.contains('record not found') ||
        lower.contains('account does not exist') ||
        lower.contains('کاربر یافت نشد') ||
        lower.contains('حساب کاربری یافت نشد')) {
      final ctx = getx.Get.context;
      if (ctx != null) {
        return l10nPick(
          ctx,
          en: 'No account found with this information. Please register first.',
          fa: 'حسابی با این مشخصات یافت نشد. لطفاً ابتدا ثبت‌نام کنید.',
          ar: 'لم يتم العثور على حساب بهذه البيانات. يرجى التسجيل أولاً.',
          zh: '未找到匹配的账户，请先注册。',
        );
      }
      return 'No account found with this information. Please register first.';
    }
    if (lower.contains('unauthenticated') || lower.contains('token expired')) {
      return localization?.unauthorizedDialogTitle ??
          'Your session has expired. Please sign in again.';
    }
    return raw;
  }

  String _secureStorageUnavailableMessage() {
    return l10nPickAuto(
      en: 'Secure storage unavailable. Please check device security settings and try again.',
      fa: 'فضای ذخیره‌سازی امن در دسترس نیست. لطفاً تنظیمات امنیتی دستگاه را بررسی کرده و مجدداً تلاش کنید.',
      ar: 'وحدة التخزين الآمنة غير متوفرة. يرجى التحقق من إعدادات أمان الجهاز والمحاولة مرة أخرى.',
      tr: 'Güvenli depolama alanı kullanılamıyor. Lütfen cihaz güvenlik ayarlarını kontrol edip tekrar deneyin.',
      ru: 'Безопасное хранилище недоступно. Проверьте настройки безопасности устройства и повторите попытку.',
      zh: '安全存储不可用。请检查设备安全设置后重试。',
    );
  }

  Map<String, String> get _baseHeaders {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  void _log(String message, {String icon = '📄'}) {
    if (kDebugMode) {
      debugPrint('$icon $message');
    }
  }

  // ---------------------- TESTING HELPERS ----------------------

  @visibleForTesting
  Dio get dio => _dio;

  @visibleForTesting
  Dio get globalDio => _globalDio;

  @visibleForTesting
  set clock(DateTime Function() c) => _clock = c;

  @visibleForTesting
  DateTime Function() get clock => _clock;

  @visibleForTesting
  Map<String, String> get inflightIdempotencyKeys =>
      _inflightIdempotency.map((k, v) => MapEntry(k, v.key));

  @visibleForTesting
  int get inflightIdempotencyCount => _inflightIdempotency.length;

  @visibleForTesting
  String? getIdempotencyKey(String mapKey) {
    _evictExpiredIdempotencyEntries();
    return _inflightIdempotency[mapKey]?.key;
  }

  @visibleForTesting
  void setIdempotencyEntry(String mapKey, String key, DateTime createdAt) {
    _inflightIdempotency[mapKey] = _IdempotencyEntry(key, createdAt);
  }

  @visibleForTesting
  void evictExpiredIdempotencyEntries([DateTime? now]) {
    _evictExpiredIdempotencyEntries(now);
  }

  @visibleForTesting
  void boundRegistrySize() => _boundRegistrySize();

  @visibleForTesting
  String getIdempotencyMapKey(RequestOptions options) =>
      _getIdempotencyMapKey(options);

  @visibleForTesting
  void releaseIdempotencyKey(RequestOptions options) =>
      _releaseIdempotencyKey(options);

  @visibleForTesting
  bool isTransportTimeoutOrSocketException(DioException error) =>
      _isTransportTimeoutOrSocketException(error);

  @visibleForTesting
  static dynamic sanitizePayload(dynamic data) => _sanitizePayload(data);

  @visibleForTesting
  ApiResponse<Map<String, dynamic>> handleDioErrorResponse(
    Response response,
    String requestType,
  ) => _handleDioErrorResponse(response, requestType);
}

/// Workstream B: Idempotency entry tracking the minted key and creation timestamp.
class _IdempotencyEntry {
  final String key;
  final DateTime createdAt;
  _IdempotencyEntry(this.key, this.createdAt);
}

/// NET-FIX: single silent retry for idempotent (GET) requests that failed on
/// pure transport errors (connection timeout/error, receive timeout, socket
/// drop). Transient mobile-data handovers and CDN edge blips used to surface
/// toasts or error states on the FIRST attempt even though a second attempt
/// half a second later would succeed. Mutating methods (POST/PUT/DELETE/PATCH)
/// are never retried here.
class _TransportRetryInterceptor extends Interceptor {
  _TransportRetryInterceptor(this._refetch);

  final Future<Response<dynamic>> Function(RequestOptions options) _refetch;

  static const Duration _backoff = Duration(milliseconds: 600);

  bool _isTransportFailure(DioException err) {
    final hasResponse = err.response != null;
    return !hasResponse &&
        (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError ||
            (err.type == DioExceptionType.unknown &&
                (err.error is SocketException ||
                    err.error.toString().contains('SocketException'))));
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final options = err.requestOptions;
    final isIdempotent = options.method.toUpperCase() == 'GET';
    final alreadyRetried = options.extra['__transport_retried__'] == true;

    if (!isIdempotent || alreadyRetried || !_isTransportFailure(err)) {
      return handler.next(err);
    }

    try {
      await Future<void>.delayed(_backoff);
      options.extra['__transport_retried__'] = true;
      final response = await _refetch(options);
      return handler.resolve(response);
    } catch (_) {
      // The retry failed too — hand the ORIGINAL error to the pipeline so
      // the caller sees the transport failure, not the retry's.
      return handler.next(err);
    }
  }
}
