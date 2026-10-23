import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ecardo_user/src/common/services/demo_account_service.dart';

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
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 4),
      receiveTimeout: const Duration(seconds: 4),
      contentType: Headers.jsonContentType,
    ),
  );

  String? _currentRoute;

  /// توسط RouteObserver/صفحات کلیدی ست می‌شود تا context صفحه در گزارش بیاید.
  String get currentRoute => _currentRoute ?? 'unknown';
  set currentRoute(String value) => _currentRoute = value;

  bool _shouldSend() {
    if (DemoAccountService.isDemoInterceptionAllowedNow) return false;
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
      await _dio.post(
        _endpoint,
        data: {
          'message': _sanitizeReportText(message),
          'stack': _sanitizeReportText(stack),
          'screen': screen,
          'app_version': '1.0.171',
        },
      );
    } catch (_) {
      // گزارش‌دهی نباید خودش خطا بسازد — ساکت رد می‌شود.
    }
  }

  static String _sanitizeReportText(String input) {
    if (input.isEmpty) return input;
    var sanitized = input;
    // Redact Bearer tokens
    sanitized = sanitized.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9\-_\.]+', caseSensitive: false),
      'Bearer <redacted>',
    );
    // Redact JWT tokens
    sanitized = sanitized.replaceAll(
      RegExp(r'eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+'),
      '<jwt-redacted>',
    );
    // Redact passwords, pins, passcodes, cvv, secrets
    sanitized = sanitized.replaceAll(
      RegExp(
        r'''("?(?:password|passcode|pin|cvv|secret|current_password|new_password)"?\s*[:=]\s*"?)[^"',\s\}]+("?)''',
        caseSensitive: false,
      ),
      r'$1<redacted>$2',
    );
    // Redact 16-digit payment card numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'\b(?:\d{4}[ -]?){3}\d{4}\b'),
      '**** **** **** <redacted>',
    );
    // Redact Iranian Sheba numbers
    sanitized = sanitized.replaceAll(
      RegExp(r'\b[iI][rR]\d{2}(?:[ -]?\d{4}){5}[ -]?\d{2}\b'),
      'IR** **** **** <redacted>',
    );
    return sanitized;
  }
}
