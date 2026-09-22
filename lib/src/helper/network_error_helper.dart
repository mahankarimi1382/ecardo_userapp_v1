import 'dart:io';

import 'package:dio/dio.dart';

enum NetworkErrorKind { offline, timeout, server, auth, unknown }

class NetworkErrorInfo {
  final NetworkErrorKind kind;
  final String messageFa;
  NetworkErrorInfo(this.kind, this.messageFa);
}

class NetworkErrorHelper {
  static NetworkErrorInfo from(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return NetworkErrorInfo(
          NetworkErrorKind.timeout,
          'زمان اتصال تمام شد. لطفاً دوباره تلاش کنید.',
        );
      }
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        return NetworkErrorInfo(
          NetworkErrorKind.offline,
          'اتصال به اینترنت برقرار نیست.',
        );
      }
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return NetworkErrorInfo(
          NetworkErrorKind.auth,
          'نشست منقضی شده یا دسترسی ندارید. دوباره وارد شوید.',
        );
      }
      if (code != null && code >= 500) {
        return NetworkErrorInfo(
          NetworkErrorKind.server,
          'خطای سرور. کمی بعد دوباره تلاش کنید.',
        );
      }
    }
    final s = e.toString().toLowerCase();
    if (s.contains('socket') || s.contains('network') || s.contains('failed host')) {
      return NetworkErrorInfo(
        NetworkErrorKind.offline,
        'اتصال به اینترنت برقرار نیست.',
      );
    }
    return NetworkErrorInfo(
      NetworkErrorKind.unknown,
      'خطایی رخ داد. دوباره تلاش کنید.',
    );
  }
}
