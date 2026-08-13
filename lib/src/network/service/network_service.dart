import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getx hide Response;
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/app/constants/assets_path/png/png_assets.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
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
  }

  // Config for secured dio
  void _configureHttpClient() {
    _dio.options.baseUrl = baseUrl;
    _dio.options.contentType = 'application/json';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.interceptors.clear();
    _setupInterceptors();
  }

  // Config for global dio
  void _configureGlobalHttpClient() {
    _globalDio.options.baseUrl = baseUrl;
    _globalDio.options.contentType = 'application/json';
    _globalDio.options.headers['Accept'] = 'application/json';
    _globalDio.interceptors.clear();
  }

  // v1.0.5: Token refresh state — جلوگیری از refresh همزمان
  bool _isRefreshing = false;
  final List<void Function(String)> _pendingRequests = [];

  // Setup Interceptor
  void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          String? accessToken = _tokenService.accessToken.value;
          _log('🔑 Token: $accessToken');

          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          // v1.0.5: Request ID برای traceability
          options.headers['X-Request-ID'] =
              options.headers['X-Request-ID'] ?? _generateRequestId();

          // v1.0.5: Client identification
          options.headers['X-App-Version'] = '1.0.5';
          options.headers['X-Client'] = 'ecardo_user_flutter';
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
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            _log("401 Unauthorized — attempting token refresh...");

            // v1.0.5: اگر در حال refresh هستیم، request را صف کنیم
            if (_isRefreshing) {
              _pendingRequests.add((newToken) {
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
              // retry request اصلی
              final newToken = _tokenService.accessToken.value;
              if (newToken != null) {
                error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final response = await _dio.fetch(error.requestOptions);
                  handler.resolve(response);

                  // پردازش صف pending requests
                  for (final callback in _pendingRequests) {
                    callback(newToken);
                  }
                  _pendingRequests.clear();
                  return;
                } catch (e) {
                  _log('Retry failed: $e');
                }
              }
            }

            // refresh ناموفق — logout
            _log("Token refresh failed — logging out.");
            await _tokenService.clearToken();
            _pendingRequests.clear();

            // هدایت به صفحه‌ی login
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (getx.Get.currentRoute != BaseRoute.signIn) {
                getx.Get.offAllNamed(BaseRoute.signIn);
              }
            });
          }
          return handler.next(error);
        },
      ),
    );
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

  /// Generate a ULID-like request ID for traceability.
  String _generateRequestId() {
    final now = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecondsSinceEpoch % 0xFFFFFF;
    return 'req-${now.toRadixString(36)}-${random.toRadixString(36).padLeft(6, '0')}';
  }

  // ------------------------------ AUTH CALLS ------------------------------ //

  // Login POST Method
  Future<ApiResponse<Map<String, dynamic>>> login({
    required String email,
    required String password,
  }) async {
    _dio.interceptors.clear();
    String url = '${_dio.options.baseUrl}${ApiPath.loginEndpoint}';

    _log('📤 Login POST Request URL: $url');
    _log(
      '📦 Login POST Request Body: {"email": $email, "password": $password}',
    );

    try {
      final response = await _dio.post(
        ApiPath.loginEndpoint,
        data: {'email': email, 'password': password},
      );

      _log('✅ Login POST Status Code: ${response.statusCode}');
      _log('✅ Login POST Response: ${response.data}');

      if (response.statusCode == 200) {
        String accessToken = response.data["data"]["token"];
        await _tokenService.clearToken();
        await _tokenService.saveAccessToken(accessToken);
        _setupInterceptors();
        _log('🔑 Token Saved Successfully');
        return ApiResponse.completed(response.data);
      }

      return ApiResponse.error('Login failed.');
    } on DioException catch (e) {
      return _handleDioException(e, "Login POST");
    } catch (e) {
      _log('Login POST Exception: ${e.toString()}', icon: '❌');
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
    _log('📦 Register POST Request Body: ${jsonEncode(data)}');

    try {
      final response = await _dio.post(
        ApiPath.registerEndpoint,
        data: jsonEncode(data),
      );

      stopwatch.stop();
      _log('✅ Register Status Code: ${response.statusCode}');
      _log('✅ Register Response: ${response.data}');
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
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
      ToastHelper().showErrorToast(localization!.networkErrorGeneric);
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
      ToastHelper().showErrorToast(localization!.networkErrorTimeout);
      return ApiResponse.error('Request timed out');
    }

    // Server returned a response
    if (e.response != null) {
      return _handleDioErrorResponse(e.response!, requestType);
    }

    // Generic error
    _log('$requestType DioException: ${e.message}', icon: '🚫');
    ToastHelper().showErrorToast(localization!.networkErrorOccurred);
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
        final jsonResponse = response.data as Map<String, dynamic>? ?? {};
        _log('$requestType Response: ${jsonResponse.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse);
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);
      case 401:
        final jsonResponse = response.data as Map<String, dynamic>? ?? {};
        _log('$requestType Response: ${jsonResponse.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse);
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
                            localization!.unauthorizedDialogTitle,
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
                            localization!.unauthorizedDialogDescription,
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
                        text: localization!.unauthorizedDialogButton,
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
        final jsonResponse = response.data as Map<String, dynamic>? ?? {};
        _log('$requestType Response: ${jsonResponse.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse);
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);

      case 500:
        final jsonResponse = response.data as Map<String, dynamic>? ?? {};
        _log('$requestType Response: ${jsonResponse.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse);
        ToastHelper().showErrorToast(errorMessages);
        return ApiResponse.error(errorMessages);

      case 503:
        final jsonResponse = response.data as Map<String, dynamic>? ?? {};
        _log('$requestType Response: ${jsonResponse.toString()}', icon: '❌');
        final errorMessages = _errorMessage(jsonResponse);
        ToastHelper().showErrorToast(errorMessages);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (getx.Get.currentRoute != BaseRoute.maintenanceMode) {
            getx.Get.offAllNamed(BaseRoute.maintenanceMode);
          }
        });
        return ApiResponse.error(errorMessages);

      default:
        _log('Unknown Error: ${response.statusCode}', icon: '❓');
        ToastHelper().showErrorToast(localization!.networkErrorOccurred);
        return ApiResponse.error('Error occurred: ${response.statusCode}');
    }
  }

  // ---------------------- UTILS ----------------------

  String _errorMessage(Map<String, dynamic> response) {
    for (final key in ['message', 'error', 'detail']) {
      final value = response[key]?.toString().trim() ?? '';
      if (value.isNotEmpty) return value;
    }

    final errors = response['errors'];
    if (errors is Map) {
      for (final value in errors.values) {
        if (value is List && value.isNotEmpty) {
          final message = value.first?.toString().trim() ?? '';
          if (message.isNotEmpty) return message;
        }
        final message = value?.toString().trim() ?? '';
        if (message.isNotEmpty) return message;
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
