import 'package:qunzo_user/src/network/response/status.dart';

class ApiResponse<T> {
  final Status? status;
  final T? data;
  final String? message;

  ApiResponse({this.status, this.data, this.message});

  factory ApiResponse.loading() => ApiResponse(status: Status.loading);

  factory ApiResponse.completed(T data) =>
      ApiResponse(status: Status.completed, data: data);

  factory ApiResponse.error(String message) =>
      ApiResponse(status: Status.error, message: message);

  @override
  String toString() => 'Status: $status\nMessage: $message\nData: $data';
}
