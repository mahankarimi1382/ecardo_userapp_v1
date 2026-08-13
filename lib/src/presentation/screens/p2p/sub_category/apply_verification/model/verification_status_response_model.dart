class VerificationStatusResponseModel {
  String? status;
  String? message;
  Data? data;

  VerificationStatusResponseModel({this.status, this.message, this.data});

  factory VerificationStatusResponseModel.fromJson(
    Map<String, dynamic> json,
  ) => VerificationStatusResponseModel(
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
  bool? isVerified;
  bool? canApply;
  Thresholds? thresholds;
  Metrics? metrics;
  Checks? checks;
  List<String>? reasons;
  ApplicationForm? applicationForm;
  LastApplication? lastApplication;

  Data({
    this.eligible,
    this.isVerified,
    this.canApply,
    this.thresholds,
    this.metrics,
    this.checks,
    this.reasons,
    this.applicationForm,
    this.lastApplication,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    eligible: json["eligible"],
    isVerified: json["is_verified"],
    canApply: json["can_apply"],
    thresholds: json["thresholds"] == null
        ? null
        : Thresholds.fromJson(json["thresholds"]),
    metrics: json["metrics"] == null ? null : Metrics.fromJson(json["metrics"]),
    checks: json["checks"] == null ? null : Checks.fromJson(json["checks"]),
    reasons: json["reasons"] == null
        ? []
        : List<String>.from(json["reasons"]!.map((x) => x)),
    applicationForm: json["application_form"] == null
        ? null
        : ApplicationForm.fromJson(json["application_form"]),
    lastApplication: json["last_application"] == null
        ? null
        : LastApplication.fromJson(json["last_application"]),
  );

  Map<String, dynamic> toJson() => {
    "eligible": eligible,
    "is_verified": isVerified,
    "can_apply": canApply,
    "thresholds": thresholds?.toJson(),
    "metrics": metrics?.toJson(),
    "checks": checks?.toJson(),
    "reasons": reasons == null
        ? []
        : List<dynamic>.from(reasons!.map((x) => x)),
    "application_form": applicationForm?.toJson(),
    "last_application": lastApplication?.toJson(),
  };
}

class ApplicationForm {
  int? id;
  String? name;
  List<Field>? fields;

  ApplicationForm({this.id, this.name, this.fields});

  factory ApplicationForm.fromJson(Map<String, dynamic> json) =>
      ApplicationForm(
        id: json["id"],
        name: json["name"],
        fields: json["fields"] == null
            ? []
            : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "fields": fields == null
        ? []
        : List<dynamic>.from(fields!.map((x) => x.toJson())),
  };
}

class Field {
  String? name;
  String? type;
  String? validation;
  String? instructions;

  Field({this.name, this.type, this.validation, this.instructions});

  factory Field.fromJson(Map<String, dynamic> json) => Field(
    name: json["name"],
    type: json["type"],
    validation: json["validation"],
    instructions: json["instructions"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "type": type,
    "validation": validation,
    "instructions": instructions,
  };
}

class Checks {
  bool? passesMinCompletedOrders;
  bool? passesMinCompletionRate;

  Checks({this.passesMinCompletedOrders, this.passesMinCompletionRate});

  factory Checks.fromJson(Map<String, dynamic> json) => Checks(
    passesMinCompletedOrders: json["passes_min_completed_orders"],
    passesMinCompletionRate: json["passes_min_completion_rate"],
  );

  Map<String, dynamic> toJson() => {
    "passes_min_completed_orders": passesMinCompletedOrders,
    "passes_min_completion_rate": passesMinCompletionRate,
  };
}

class LastApplication {
  String? status;
  String? message;
  DateTime? createdAt;

  LastApplication({this.status, this.message, this.createdAt});

  factory LastApplication.fromJson(Map<String, dynamic> json) =>
      LastApplication(
        status: json["status"],
        message: json["message"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "created_at": createdAt?.toIso8601String(),
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
  int? minCompletedOrders;
  int? minCompletionRate;

  Thresholds({this.minCompletedOrders, this.minCompletionRate});

  factory Thresholds.fromJson(Map<String, dynamic> json) => Thresholds(
    minCompletedOrders: json["min_completed_orders"],
    minCompletionRate: json["min_completion_rate"],
  );

  Map<String, dynamic> toJson() => {
    "min_completed_orders": minCompletedOrders,
    "min_completion_rate": minCompletionRate,
  };
}
