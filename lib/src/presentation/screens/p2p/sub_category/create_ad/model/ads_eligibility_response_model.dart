class AdsEligibilityResponseModel {
  String? status;
  String? message;
  Data? data;

  AdsEligibilityResponseModel({this.status, this.message, this.data});

  factory AdsEligibilityResponseModel.fromJson(Map<String, dynamic> json) =>
      AdsEligibilityResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  bool? eligible;
  Thresholds? thresholds;
  Metrics? metrics;
  Checks? checks;
  List<String>? reasons;

  Data({
    this.eligible,
    this.thresholds,
    this.metrics,
    this.checks,
    this.reasons,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    eligible: json["eligible"],
    thresholds: json["thresholds"] == null
        ? null
        : Thresholds.fromJson(json["thresholds"]),
    metrics: json["metrics"] == null ? null : Metrics.fromJson(json["metrics"]),
    checks: json["checks"] == null ? null : Checks.fromJson(json["checks"]),
    reasons: json["reasons"] == null
        ? []
        : List<String>.from(json["reasons"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "eligible": eligible,
    "thresholds": thresholds?.toJson(),
    "metrics": metrics?.toJson(),
    "checks": checks?.toJson(),
    "reasons": reasons == null
        ? []
        : List<dynamic>.from(reasons!.map((x) => x)),
  };
}

class Checks {
  bool? passesMinTransactionsSuccessRate;
  bool? passesMinCompletionRate;
  bool? passesMinOrdersRequired;

  Checks({
    this.passesMinTransactionsSuccessRate,
    this.passesMinCompletionRate,
    this.passesMinOrdersRequired,
  });

  factory Checks.fromJson(Map<String, dynamic> json) => Checks(
    passesMinTransactionsSuccessRate:
        json["passes_min_transactions_success_rate"],
    passesMinCompletionRate: json["passes_min_completion_rate"],
    passesMinOrdersRequired: json["passes_min_orders_required"],
  );

  Map<String, dynamic> toJson() => {
    "passes_min_transactions_success_rate": passesMinTransactionsSuccessRate,
    "passes_min_completion_rate": passesMinCompletionRate,
    "passes_min_orders_required": passesMinOrdersRequired,
  };
}

class Metrics {
  int? terminalOrdersCount;
  int? completedOrdersCount;
  double? completionRate;
  int? totalTransactionsCount;
  int? successfulTransactionsCount;
  double? transactionsSuccessRate;

  Metrics({
    this.terminalOrdersCount,
    this.completedOrdersCount,
    this.completionRate,
    this.totalTransactionsCount,
    this.successfulTransactionsCount,
    this.transactionsSuccessRate,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) => Metrics(
    terminalOrdersCount: json["terminal_orders_count"],
    completedOrdersCount: json["completed_orders_count"],
    completionRate: json["completion_rate"]?.toDouble(),
    totalTransactionsCount: json["total_transactions_count"],
    successfulTransactionsCount: json["successful_transactions_count"],
    transactionsSuccessRate: json["transactions_success_rate"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "terminal_orders_count": terminalOrdersCount,
    "completed_orders_count": completedOrdersCount,
    "completion_rate": completionRate,
    "total_transactions_count": totalTransactionsCount,
    "successful_transactions_count": successfulTransactionsCount,
    "transactions_success_rate": transactionsSuccessRate,
  };
}

class Thresholds {
  int? minTransactionsSuccessRate;
  int? minCompletionRate;
  int? minOrdersRequired;

  Thresholds({
    this.minTransactionsSuccessRate,
    this.minCompletionRate,
    this.minOrdersRequired,
  });

  factory Thresholds.fromJson(Map<String, dynamic> json) => Thresholds(
    minTransactionsSuccessRate: json["min_transactions_success_rate"],
    minCompletionRate: json["min_completion_rate"],
    minOrdersRequired: json["min_orders_required"],
  );

  Map<String, dynamic> toJson() => {
    "min_transactions_success_rate": minTransactionsSuccessRate,
    "min_completion_rate": minCompletionRate,
    "min_orders_required": minOrdersRequired,
  };
}
