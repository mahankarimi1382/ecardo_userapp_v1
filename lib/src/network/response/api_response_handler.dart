/// ApiResponseHandler — parses eCardo v3.8 API responses.
///
/// v3.8 response format (uniform across all endpoints):
/// {
///   "status": "success" | "error",
///   "message": "string",
///   "data": `{...}` | `[...]` | null,
///   "errors": {...} | null,
///   "meta": {
///     "timestamp": "ISO-8601",
///     "request_id": "ULID",
///     "version": "3.8",
///     `error_code`: "VALIDATION_ERROR" | "NOT_FOUND" | ...  // error only
///     "pagination": { "current_page": 1, "last_page": 5, ... }  // paginated only
///   }
/// }
///
/// This class extracts the relevant fields and exposes typed accessors.
/// NetworkService still returns `ApiResponse<Map<String, dynamic>>` (the full body),
/// but controllers can use these helpers to extract `data`, `pagination`, etc.
class ApiResponseHandler {
  final Map<String, dynamic>? body;

  ApiResponseHandler(this.body);

  /// True if the API call was successful (status == 'success' or HTTP 2xx)
  /// and not in an explicit business rejected, failed, or reconciling state.
  bool get isSuccess {
    if (body == null) return false;
    final status = body!['status'];
    final bool statusOk;
    if (status is String) {
      statusOk = status.toLowerCase() == 'success' ||
          status.toLowerCase() == 'true';
    } else if (status is bool) {
      statusOk = status;
    } else {
      statusOk = false;
    }
    // Contract 04: HTTP success with business rejected/unknown is not a transaction success
    if (statusOk && (isRejected || isReconciling)) {
      return false;
    }
    return statusOk;
  }

  /// True if the API call failed (HTTP level or business rejected/unknown).
  bool get isError => !isSuccess;

  /// Business status string extracted from payload (e.g. 'success', 'pending', 'rejected', 'requires_action', 'unknown').
  String? get businessStatus {
    if (body == null) return null;
    final dataObj = body!['data'];
    if (dataObj is Map && dataObj['status'] != null) {
      return dataObj['status'].toString().toLowerCase().trim();
    }
    if (body!['business_status'] != null) {
      return body!['business_status'].toString().toLowerCase().trim();
    }
    final metaObj = meta;
    if (metaObj != null) {
      if (metaObj['business_status'] != null) {
        return metaObj['business_status'].toString().toLowerCase().trim();
      }
      if (metaObj['status'] != null) {
        return metaObj['status'].toString().toLowerCase().trim();
      }
    }
    final topStatus = body!['status'];
    if (topStatus != null) {
      return topStatus.toString().toLowerCase().trim();
    }
    return null;
  }

  /// True if the business transaction is in an asynchronous pending / processing state.
  bool get isPending {
    final s = businessStatus;
    return s == 'pending' || s == 'processing' || s == 'in_review';
  }

  /// True if the business transaction was explicitly rejected or failed by the business domain.
  bool get isRejected {
    final s = businessStatus;
    return s == 'rejected' ||
        s == 'failed' ||
        s == 'declined' ||
        s == 'cancelled';
  }

  /// True if the business transaction requires additional user action (e.g. OTP, 2FA, KYC upgrade).
  bool get requiresAction {
    final s = businessStatus;
    return s == 'requires_action' ||
        s == 'action_required' ||
        s == 'otp_required' ||
        s == 'kyc_required';
  }

  /// True if the business transaction status is unknown or reconciling.
  bool get isReconciling {
    final s = businessStatus;
    return s == 'unknown' || s == 'reconciling' || s == 'ambiguous';
  }

  /// True if the transaction is confirmed successful (not pending, not requires_action, not reconciling).
  bool get isConfirmedSuccess =>
      isSuccess && !isPending && !requiresAction && !isRejected && !isReconciling;

  /// The user-facing message.
  String get message {
    final m = body?['message'];
    if (m is String) return m;
    if (m is List) return m.join(' ');
    return '';
  }

  /// The data payload (could be a Map, List, or null).
  dynamic get data => body?['data'];

  /// The errors payload (typically a `Map<String, List<String>>` for validation).
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
  ///   1. `{"email": ["Email is required", "..."], "password": ["..."]}`
  ///   2. `["Error 1", "Error 2"]`
  ///   3. "Single error string"
  ///   4. Nested maps: `{"address": {"street": ["Street is required"]}}`
  String? get firstError {
    return _extractFirstError(errors);
  }

  /// Flattens validation errors into a `Map<String, String>` of fieldName -> firstErrorMessage.
  Map<String, String> get fieldErrors {
    final result = <String, String>{};
    final errs = errors;
    if (errs is Map) {
      for (final entry in errs.entries) {
        final key = entry.key.toString();
        final firstMsg = _extractFirstError(entry.value);
        if (firstMsg != null && firstMsg.isNotEmpty) {
          result[key] = firstMsg;
        }
      }
    }
    return result;
  }

  static String? _extractFirstError(dynamic errs) {
    if (errs == null) return null;
    if (errs is String && errs.isNotEmpty) return errs;
    if (errs is List && errs.isNotEmpty) {
      for (final item in errs) {
        final extracted = _extractFirstError(item);
        if (extracted != null && extracted.isNotEmpty) return extracted;
      }
    }
    if (errs is Map && errs.isNotEmpty) {
      for (final val in errs.values) {
        final extracted = _extractFirstError(val);
        if (extracted != null && extracted.isNotEmpty) return extracted;
      }
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
