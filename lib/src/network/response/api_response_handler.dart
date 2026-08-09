import 'package:dio/dio.dart';

/// ApiResponseHandler — parses eCardo v3.8 API responses.
///
/// v3.8 response format (uniform across all endpoints):
/// {
///   "status": "success" | "error",
///   "message": "string",
///   "data": {...} | [...] | null,
///   "errors": {...} | null,
///   "meta": {
///     "timestamp": "ISO-8601",
///     "request_id": "ULID",
///     "version": "3.8",
///     "error_code": "VALIDATION_ERROR" | "NOT_FOUND" | ...  // error only
///     "pagination": { "current_page": 1, "last_page": 5, ... }  // paginated only
///   }
/// }
///
/// This class extracts the relevant fields and exposes typed accessors.
/// NetworkService still returns ApiResponse<Map<String, dynamic>> (the full body),
/// but controllers can use these helpers to extract `data`, `pagination`, etc.
class ApiResponseHandler {
  final Map<String, dynamic>? body;

  ApiResponseHandler(this.body);

  /// True if the API call was successful (status == 'success' or HTTP 2xx).
  bool get isSuccess {
    if (body == null) return false;
    final status = body!['status'];
    if (status is String) {
      return status.toLowerCase() == 'success' || status.toLowerCase() == 'true';
    }
    if (status is bool) return status;
    return false;
  }

  /// True if the API call failed.
  bool get isError => !isSuccess;

  /// The user-facing message.
  String get message {
    final m = body?['message'];
    if (m is String) return m;
    if (m is List) return m.join(' ');
    return '';
  }

  /// The data payload (could be a Map, List, or null).
  dynamic get data => body?['data'];

  /// The errors payload (typically a Map<String, List<String>> for validation).
  dynamic get errors => body?['errors'];

  /// The metadata object.
  Map<String, dynamic>? get meta {
    final m = body?['meta'];
    if (m is Map<String, dynamic>) return m;
    if (m is Map) return Map<String, dynamic>.from(m);
    return null;
  }

  /// The request ID from meta (useful for support tickets).
  String? get requestId => meta?['request_id'] as String?;

  /// The API version reported by the server.
  String? get apiVersion => meta?['version'] as String?;

  /// The error code (only present on error responses).
  String? get errorCode => meta?['error_code'] as String?;

  /// Pagination metadata (only present on paginated responses).
  PaginationMeta? get pagination {
    final p = meta?['pagination'];
    if (p is Map) return PaginationMeta.fromMap(p);
    return null;
  }

  /// Extracts the first error message from a 422-style `errors` field.
  ///
  /// The backend sends validation errors in one of these shapes:
  ///   1. {"email": ["Email is required", "..."], "password": ["..."]}
  ///   2. ["Error 1", "Error 2"]
  ///   3. "Single error string"
  String? get firstError {
    final errs = errors;
    if (errs is Map) {
      for (final v in errs.values) {
        if (v is List && v.isNotEmpty) {
          return v.first?.toString();
        }
        if (v is String && v.isNotEmpty) return v;
      }
    } else if (errs is List && errs.isNotEmpty) {
      return errs.first?.toString();
    } else if (errs is String && errs.isNotEmpty) {
      return errs;
    }
    return null;
  }
}

/// Pagination metadata extracted from a v3.8 paginated response.
class PaginationMeta {
  final int currentPage;
  final int? lastPage;
  final int perPage;
  final int? total;
  final int? from;
  final int? to;
  final bool hasMore;

  const PaginationMeta({
    required this.currentPage,
    this.lastPage,
    required this.perPage,
    this.total,
    this.from,
    this.to,
    required this.hasMore,
  });

  factory PaginationMeta.fromMap(Map<dynamic, dynamic> m) {
    return PaginationMeta(
      currentPage: (m['current_page'] as num?)?.toInt() ?? 1,
      lastPage: (m['last_page'] as num?)?.toInt(),
      perPage: (m['per_page'] as num?)?.toInt() ?? 10,
      total: (m['total'] as num?)?.toInt(),
      from: (m['from'] as num?)?.toInt(),
      to: (m['to'] as num?)?.toInt(),
      hasMore: (m['has_more'] as bool?) ?? false,
    );
  }
}
