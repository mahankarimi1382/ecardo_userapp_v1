import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ecardo_user/src/helper/l10n_pick.dart';

enum NetworkErrorKind { offline, timeout, server, auth, unknown }

class NetworkErrorInfo {
  final NetworkErrorKind kind;

  /// Locale-aware message (en/fa/ar/zh via l10nPickAuto, English fallback).
  /// WAVE-1: used to always return Persian (`messageFa`) regardless of the
  /// user's locale — Chinese/Russian/Arab users read instructions they
  /// could not understand on the most confusing screen there is: failure.
  final String message;
  NetworkErrorInfo(this.kind, this.message);
}

class NetworkErrorHelper {
  static NetworkErrorInfo _timeout() => NetworkErrorInfo(
        NetworkErrorKind.timeout,
        l10nPickAuto(
          en: 'Connection timed out. Please try again.',
          fa: 'زمان اتصال تمام شد. لطفاً دوباره تلاش کنید.',
          ar: 'انتهت مهلة الاتصال. حاول مرة أخرى.',
          zh: '连接超时，请重试。',
        ),
      );

  static NetworkErrorInfo _offline() => NetworkErrorInfo(
        NetworkErrorKind.offline,
        l10nPickAuto(
          en: 'No internet connection.',
          fa: 'اتصال به اینترنت برقرار نیست.',
          ar: 'لا يوجد اتصال بالإنترنت.',
          zh: '无互联网连接。',
        ),
      );

  static NetworkErrorInfo _auth() => NetworkErrorInfo(
        NetworkErrorKind.auth,
        l10nPickAuto(
          en: 'Your session expired or you lack access. Please sign in again.',
          fa: 'نشست منقضی شده یا دسترسی ندارید. دوباره وارد شوید.',
          ar: 'انتهت جلستك أو لا تملك صلاحية. سجّل الدخول مرة أخرى.',
          zh: '会话已过期或无权访问，请重新登录。',
        ),
      );

  static NetworkErrorInfo _server() => NetworkErrorInfo(
        NetworkErrorKind.server,
        l10nPickAuto(
          en: 'Server error. Please try again later.',
          fa: 'خطای سرور. کمی بعد دوباره تلاش کنید.',
          ar: 'خطأ في الخادم. حاول لاحقًا.',
          zh: '服务器错误，请稍后重试。',
        ),
      );

  static NetworkErrorInfo _unknown() => NetworkErrorInfo(
        NetworkErrorKind.unknown,
        l10nPickAuto(
          en: 'Something went wrong. Please try again.',
          fa: 'خطایی رخ داد. دوباره تلاش کنید.',
          ar: 'حدث خطأ ما. حاول مرة أخرى.',
          zh: '出现问题，请重试。',
        ),
      );

  static NetworkErrorInfo from(Object e) {
    if (e is DioException) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return _timeout();
      }
      if (e.type == DioExceptionType.connectionError ||
          e.error is SocketException) {
        return _offline();
      }
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) {
        return _auth();
      }
      if (code != null && code >= 500) {
        return _server();
      }
    }
    final s = e.toString().toLowerCase();
    if (s.contains('socket') || s.contains('network') || s.contains('failed host')) {
      return _offline();
    }
    return _unknown();
  }
}
