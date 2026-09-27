import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// WAVE-REVIEW: گزارش خطاهای رندر/استثناهای اپ به بک‌اند
/// (`POST /api/client-error-report` → error_logs).
///
/// چرا: تا پیش از این، خطاهای سمت کلاینت کاملاً کور بودند — باگ صفحهٔ
/// اکسچنج («Something went wrong rendering this section») روی دستگاه
/// مالک قابل تشخیص نبود چون هیچ stack از دستگاه نمی‌آمد.
///
/// قواعد: fire-and-forget (هیچ استثنایی از خودش بالا نمی‌آید)،
/// throttle ۳۰ ثانیه‌ای + سقف ۱۰ گزارش در هر اجرای اپ، جدا از
/// NetworkService (Dio مستقل؛ خطا نباید به خطا وابسته باشد).
class ClientErrorReporter {
  ClientErrorReporter._();

  static final ClientErrorReporter instance = ClientErrorReporter._();

  static const String _endpoint = 'https://ecardo.ir/api/client-error-report';
  static const int _maxReportsPerSession = 10;
  static const Duration _minInterval = Duration(seconds: 30);

  int _sessionCount = 0;
  DateTime? _lastSentAt;
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
    contentType: Headers.jsonContentType,
  ));

  String? _currentRoute;

  /// توسط RouteObserver/صفحات کلیدی ست می‌شود تا context صفحه در گزارش بیاید.
  String get currentRoute => _currentRoute ?? 'unknown';
  set currentRoute(String value) => _currentRoute = value;

  bool _shouldSend() {
    if (_sessionCount >= _maxReportsPerSession) return false;
    final last = _lastSentAt;
    if (last != null && DateTime.now().difference(last) < _minInterval) {
      return false;
    }
    return true;
  }

  void reportFlutterError(FlutterErrorDetails details, {String? screen}) {
    if (!_shouldSend()) return;
    _lastSentAt = DateTime.now();
    _sessionCount++;

    _send(
      message: details.exceptionAsString(),
      stack: details.stack?.toString() ?? '',
      screen: screen ?? currentRoute,
    );
  }

  void reportBuildError(Object exception, StackTrace? stack, {String? screen}) {
    if (!_shouldSend()) return;
    _lastSentAt = DateTime.now();
    _sessionCount++;

    _send(
      message: exception.toString(),
      stack: stack?.toString() ?? '',
      screen: screen ?? currentRoute,
    );
  }

  Future<void> _send({
    required String message,
    required String stack,
    required String screen,
  }) async {
    try {
      await _dio.post(_endpoint, data: {
        'message': message,
        'stack': stack,
        'screen': screen,
        'app_version': '1.0.100',
      });
    } catch (_) {
      // گزارش‌دهی نباید خودش خطا بسازد — ساکت رد می‌شود.
    }
  }
}
