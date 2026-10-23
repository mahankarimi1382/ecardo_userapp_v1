import 'package:ecardo_user/src/network/response/status.dart';

class ApiResponse<T> {
  final Status? status;
  final T? data;
  final String? message;
  final bool isTimeout;
  final bool isReconciling;

  ApiResponse({
    this.status,
    this.data,
    this.message,
    this.isTimeout = false,
    this.isReconciling = false,
  });

  factory ApiResponse.loading() => ApiResponse(status: Status.loading);

  factory ApiResponse.completed(T data) =>
      ApiResponse(status: Status.completed, data: data);

  factory ApiResponse.error(
    String message, {
    bool isTimeout = false,
    bool isReconciling = false,
  }) =>
      ApiResponse(
        status: Status.error,
        message: message,
        isTimeout: isTimeout,
        isReconciling: isReconciling,
      );

  factory ApiResponse.unknown(
    String message, {
    T? data,
    bool isTimeout = true,
  }) =>
      ApiResponse(
        status: Status.unknown,
        message: message,
        data: data,
        isTimeout: isTimeout,
        isReconciling: true,
      );

  bool get isSuccess => status == Status.completed;
  bool get isError => status == Status.error;
  bool get isUnknown => status == Status.unknown || isReconciling;

  @override
  String toString() =>
      'Status: $status\nMessage: $message\nData: $data\nisTimeout: $isTimeout\nisReconciling: $isReconciling';
}
