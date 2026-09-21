import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx hide Response;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/app_update_helper.dart';
import 'package:ecardo_user/src/common/services/kyc_error_handler.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/button/common_button.dart';
import 'package:ecardo_user/src/helper/toast_helper.dart';
import 'package:ecardo_user/src/network/api/api_path.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

class NetworkService extends getx.GetxService {
  // Properties
  final Dio _dio = Dio();
  final Dio _globalDio = Dio();
  final String baseUrl = ApiPath.baseUrl;
  late TokenService _tokenService;

  // Real app version (from pubspec via package_info_plus). Until resolved we
  // send an empty value — the server treats a missing/unparseable header as
  // pass-through. Never hardcode a stale version again (S-003/S-022 fix).
  String _appVersion = '';

  /// v1.0.24 (S-023): in-flight Idempotency-Key registry keyed by
  /// '${method}:$path'. A key is minted when a money POST starts and released
  /// when that request completes, so an accidental double submission of the
  /// same logical call REUSES the same key (the server can then collapse it)
  /// instead of minting a fresh one per request.
  final Map<String, String> _inflightIdempotency = {};

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
  ];

  AppLocalizations? get localization {
    final ctx = getx.Get.context;
    if (ctx == null) return null;
    return AppLocalizations.of(ctx);
  }

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
    _dio.interceptors.clear();
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
    _globalDio.interceptors.clear();
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
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? accessToken = _tokenService.accessToken.value;
          // v1.0.24: never log the raw token (was: full bearer leak in logs).
          _log('🔑 Token: ${accessToken == null || accessToken.isEmpty ? '<none>' : '<redacted ${accessToken.length} chars>'}');

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

          // v1.0.24 (S-023 client side): money POSTs carry Idempotency-Key.
          // The key is reused across an in-flight logical call so a double
          // submission maps to the same idempotency key server-side.
          if (options.method.toUpperCase() == 'POST' &&
              options.headers['Idempotency-Key'] == null) {
            final path = options.uri.path;
            final isMoney = _idempotentEndpointSuffixes.any(
              (suffix) => path.endsWith(suffix),
            );
            if (isMoney) {
              // phase1-fix (P0-3): identity of the LOGICAL operation is
              // path + query + payload fingerprint. Two different concurrent
              // money ops on one endpoint no longer share a key; a genuine
              // double-tap of the same op still reuses it.
              final mapKey =
                  'POST:$path?${options.uri.query}:${_payloadFingerprint(options.data)}';
              options.headers['Idempotency-Key'] =
                  _inflightIdempotency.putIfAbsent(mapKey, () {
                    final minted = options.headers['X-Request-ID'] as String?;
                    return minted ?? _generateRequestId();
                  });
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
          _releaseIdempotencyKey(response.requestOptions);
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          _releaseIdempotencyKey(error.requestOptions);
          if (error.response?.statusCode == 401) {
            _log("401 Unauthorized — attempting token refresh...");

            // v1.0.5: اگر در حال refresh هستیم، request را صف کنیم
            if (_isRefreshing) {
              _pendingRequests.add((newToken) {
                if (newToken == null) {
                  // refresh failed meanwhile — fail this queued request too
                  handler.next(error);
                  return;
                }
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                _dio.fetch(error.requestOptions).then(
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
                final queued = List<void Function(String?)>.of(_pendingRequests);
                _pendingRequests.clear();
                for (final callback in queued) {
                  callback(newToken);
                }

                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  handler.resolve(response);
                  return;
                } catch (e) {
                  _log('Retry failed: $e');
                }
              }
            }

            // refresh ناموفق — logout + fail every queued request explicitly
            _log("Token refresh failed — logging out.");
            await _tokenService.clearToken();
            try {
              await getx.Get.find<SettingsService>().wipeSession();
            } catch (_) {}
            final queued = List<void Function(String?)>.of(_pendingRequests);
            _pendingRequests.clear();
            for (final callback in queued) {
              callback(null); // null => handler.next(error) for that request
            }

            WidgetsBinding.instance.addPostFrameCallback((_) {
              ToastHelper().showErrorToast(
                localization?.unauthorizedDialogTitle ??
                    'Your session has expired. Please sign in again.',
              );
              if (getx.Get.currentRoute != BaseRoute.signIn) {
                getx.Get.offAllNamed(BaseRoute.signIn);
              }
            });
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
    try {
      _log('Attempting token refresh...');
      final response = await _globalDio.post(
        '$baseUrl${ApiPath.tokenRefreshEndpoint}',
        options: Options(headers: {
          'Authorization': 'Bearer ${_tokenService.accessToken.value}',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        }),
      );

      if (response.statusCode == 200) {
        final newToken = response.data['data']?['token'];
        if (newToken != null && newToken is String) {
          await _tokenService.saveAccessToken(newToken);
          _log('✓ Token refreshed successfully');
          return true;
        }
      }
      _log('Token refresh failed: ${response.statusCode}');
      return false;
    } catch (e) {
      _log('Token refresh error: $e');
      return false;
    }
  }

  /// v1.0.24 (S-023): release the in-flight idempotency key once the request
  /// has finished (success or failure), so the NEXT logical submission mints a
  /// fresh key. The 401-refresh retry is safe: it re-enters with the key
  /// already embedded in the request headers, so nothing is re-minted.
  void _releaseIdempotencyKey(RequestOptions options) {
    final headerKey = options.headers['Idempotency-Key'];
    if (headerKey is! String || headerKey.isEmpty) return;
    final mapKey =
        '${options.method.toUpperCase()}:${options.uri.path}?${options.uri.query}:${_payloadFingerprint(options.data)}';
    if (_inflightIdempotency[mapKey] == headerKey) {
      _inflightIdempotency.remove(mapKey);
    }
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

  // ------------------------------ AUTH CALLS ------------------------------ //

  // Login POST Method
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    String url = '${_dio.options.baseUrl}${ApiPath.loginEndpoint}';

    _log('📤 Login POST Request URL: $url');
    // v1.0.24: never log the password — only the (non-secret) email.
    _log('📦 Login POST Request Body: {"email": $email, "password": "<redacted>"}');

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
        await _tokenService.saveAccessToken(accessToken);
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

  // Register POST Method
  Future<ApiResponse<Map<String, dynamic>>> register({
    required Map<String, dynamic> data,
  }) async {
    String url = '${_dio.options.baseUrl}${ApiPath.registerEndpoint}';
    final stopwatch = Stopwatch()..start();

    _log('📤 Register POST Request URL: $url');
    // v1.0.24: never log plaintext passwords — redact like login() does.
    final sanitizedBody = Map<String, dynamic>.of(data);
    for (final key in sanitizedBody.keys.toList()) {
      if (key.toLowerCase().contains('password')) {
        sanitizedBody[key] = '<redacted>';
      }
    }
    _log('📦 Register POST Request Body: ${jsonEncode(sanitizedBody)}');

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

      if (response.statusCode == 200) {
        String accessToken = response.data["data"]['token'];
        await _tokenService.saveAccessToken(accessToken);
        _setupInterceptors();
        _log('🔑 Token Saved Successfully');
        return ApiResponse.completed(response.data);
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
  }) async {
    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📥 GET Request URL: $url');

    try {
      final response = await _dio.get(endpoint);
      return _handleResponse(response, "GET");
    } on DioException catch (e) {
      return _handleDioException(e, "GET");
    } catch (e) {
      _log('GET Exception: ${e.toString()}', icon: '❌');
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
  }) async {
    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📤 POST Request URL: $url');

    if (data != null) {
      _log('📦 POST Request Body: ${jsonEncode(data)}');
    } else {
      _log('📦 POST Request Body: No body data');
    }

    try {
      final response = await _dio.post(
        endpoint,
        data: data != null ? jsonEncode(data) : null,
      );

      return _handleResponse(response, "POST");
    } on DioException catch (e) {
      return _handleDioException(e, "POST");
    } catch (e) {
      _log('POST Exception: ${e.toString()}', icon: '❌');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
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
  }) async {
    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📤 POST (multipart) Request URL: $url');
    _log('📦 POST (multipart) Fields: ${data.fields.length}, Files: ${data.files.length}');

    try {
      // Pass the FormData directly — Dio auto-sets Content-Type to
      // multipart/form-data with the proper boundary.
      final response = await _dio.post(endpoint, data: data);
      return _handleResponse(response, "POST (multipart)");
    } on DioException catch (e) {
      return _handleDioException(e, "POST (multipart)");
    } catch (e) {
      _log('POST (multipart) Exception: ${e.toString()}', icon: '❌');
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
  }) async {
    String url = '${_dio.options.baseUrl}$endpoint';
    _log('📤 PUT Request URL: $url');

    if (data != null) {
      _log('📦 PUT Request Body: ${jsonEncode(data)}');
    } else {
      _log('📦 PUT Request Body: No body data');
    }

    try {
      final response = await _dio.put(
        endpoint,
        data: data != null ? jsonEncode(data) : null,
      );

      return _handleResponse(response, "PUT");
    } on DioException catch (e) {
      return _handleDioException(e, "PUT");
    } catch (e) {
      _log('PUT Exception: ${e.toString()}', icon: '❌');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization + English fallback (was `localization!`).
        localization?.networkErrorGeneric ??
            'An unexpected error occurred. Please try again.',
      );
      return ApiResponse.error(e.toString());
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> delete({
    required String endpoint,
    Map<String, dynamic>? data,
  }) async {
    String url = '${_dio.options.baseUrl}$endpoint';
    _log('🗑️ DELETE Request URL: $url');

    if (data != null) {
      _log('📦 DELETE Request Body: ${jsonEncode(data)}');
    } else {
      _log('📦 DELETE Request Body: No body data');
    }

    try {
      final response = await _dio.delete(
        endpoint,
        data: data != null ? jsonEncode(data) : null,
      );

      return _handleResponse(response, "DELETE");
    } on DioException catch (e) {
      return _handleDioException(e, "DELETE");
    } catch (e) {
      _log('DELETE Exception: ${e.toString()}', icon: '❌');
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
  }) async {
    try {
      String url = '$baseUrl$endpoint';
      _log('Global POST Request URL: $url', icon: '✅');

      if (data != null) {
        _log('📦 Global POST Request Body: ${jsonEncode(data)}');
      } else {
        _log('📦 Global POST Request Body: No body data');
      }

      final response = await _globalDio.post(
        url,
        data: data != null ? jsonEncode(data) : null,
        options: Options(headers: _baseHeaders),
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
  }) async {
    try {
      String url = '$baseUrl$endpoint';
      _log('Global GET Request URL: $url', icon: '✅');

      final response = await _globalDio.get(
        url,
        options: Options(headers: _baseHeaders),
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
    // Detect No Internet Connection
    if (e.type == DioExceptionType.connectionError ||
        (e.type == DioExceptionType.unknown &&
            e.error.toString().contains('SocketException'))) {
      _log('$requestType No Internet Connection', icon: '🚫');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (getx.Get.currentRoute != BaseRoute.noInternetConnection) {
          getx.Get.offAllNamed(BaseRoute.noInternetConnection);
        }
      });
      return ApiResponse.error('No internet connection');
    }

    // Detect Timeout Manually
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      _log('$requestType TimeoutException: Request timed out', icon: '⏳');
      ToastHelper().showErrorToast(
        // P-4: null-safe localization with English fallback (was `localization!`).
        localization?.networkErrorTimeout ?? 'Request timed out. Please try again.',
      );
      return ApiResponse.error('Request timed out');
    }

    // Server returned a response
    if (e.response != null) {
      return _handleDioErrorResponse(e.response!, requestType);
    }

    // Generic error
    _log('$requestType DioException: ${e.message}', icon: '🚫');
    ToastHelper().showErrorToast(
      // P-4: null-safe localization with English fallback (was `localization!`).
      localization?.networkErrorOccurred ?? 'An error occurred. Please try again.',
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
        final jsonData = response.data as Map<String, dynamic>;
        _log('$requestType Response: $jsonData', icon: '✅');
        return ApiResponse.completed(jsonData);
      default:
        _log('Unknown Status Code: ${response.statusCode}', icon: '❓');
        return ApiResponse.error('Error occurred: ${response.statusCode}');
    }
  }

  // phase2-fix: 401 dialogs used to stack when several parallel requests
  // failed at once (the 426 path had a guard; 401 did not). Time-based so no
  // manual reset wiring is needed.
  DateTime? _lastUnauthorizedDialogAt;
  bool get _unauthorizedDialogActive =>
      _lastUnauthorizedDialogAt != null &&
      DateTime.now().difference(_lastUnauthorizedDialogAt!) <
          const Duration(seconds: 3);

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
        _log('$requestType Response: ${jsonResponse.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse);
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);
      case 401:
        final jsonResponse401 = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        _log('$requestType Response: ${jsonResponse401.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse401);
        if (_unauthorizedDialogActive) {
          return ApiResponse.error(errorMessages);
        }
        _lastUnauthorizedDialogAt = DateTime.now();
        getx.Get.dialog(
          PopScope(
            canPop: false,
            child: Dialog(
              insetPadding: EdgeInsets.zero,
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox(
                width: 324,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(15),
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(52),
                          color: AppColors.error.withValues(alpha: 0.10),
                        ),
                        child: Image.asset(
                          PngAssets.commonAlertIcon,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Text(
                            localization?.unauthorizedDialogTitle ?? 'Unauthorized',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            textAlign: TextAlign.center,
                            localization?.unauthorizedDialogDescription ??
                                'You are not authorized to access this resource. Please log in again!',
                            style: TextStyle(
                              letterSpacing: 0,
                              fontWeight: FontWeight.w400,
                              fontSize: 12,
                              color: AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      CommonButton(
                        borderRadius: 8,
                        width: 60,
                        height: 35,
                        text: localization?.unauthorizedDialogButton ?? 'OK',
                        onPressed: () => getx.Get.offAllNamed(BaseRoute.signIn),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);

      case 403:
      case 404:
      case 422:
        final jsonResponse4xx = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        _log('$requestType Response: ${jsonResponse4xx.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse4xx);
        // v1.1 (KYC-ERR): a KYC block (KYC_LEVEL_REQUIRED /
        // KYC_FEATURE_REQUIRED) was already routed to the
        // UpgradeRequiredScreen by the interceptor — the raw server message
        // must NOT double up as an error toast here.
        final isKycBlock =
            response.requestOptions.extra[KycErrorHandler.handledExtraKey] ==
                true;
        if (isKycBlock) {
          final friendly = localization?.kycUpgradeRequiredTitle ??
              'Verification upgrade required';
          return ApiResponse.error(friendly);
        }
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);

      case 500:
        final jsonResponse500 = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        _log('$requestType Response: ${jsonResponse500.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse500);
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);

      case 503:
        final jsonResponse503 = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : <String, dynamic>{};
        _log('$requestType Response: ${jsonResponse503.toString()}', icon: '❌');
        final errorMessages503 = _errorMessage(jsonResponse503);
        // v1.1 (KYC-ERR): KYC_CHECK_UNAVAILABLE is a transient verification
        // infrastructure outage — show a retry message, never logout, never
        // clear the token and never take over with the maintenance screen.
        final isKycUnavailable =
            response.requestOptions.extra[KycErrorHandler.handledExtraKey] ==
                true;
        if (isKycUnavailable) {
          final retryMessage = localization?.kycVerificationUnavailable ??
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
        _log('Unknown Error: ${response.statusCode}', icon: '❓');
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
      if (message.isNotEmpty) return message;
    }

    return localization?.networkErrorOccurred ?? 'An error occurred.';
  }

  Map<String, String> get _baseHeaders {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  void _log(String message, {String icon = '📄'}) {
    if (kDebugMode) {
      debugPrint('$icon $message');
    }
  }
}
