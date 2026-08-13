class BillPaymentHistoryModel {
  String? status;
  String? message;
  BillPaymentHistoryData? data;

  BillPaymentHistoryModel({this.status, this.message, this.data});

  factory BillPaymentHistoryModel.fromJson(Map<String, dynamic> json) {
    return BillPaymentHistoryModel(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null
          ? BillPaymentHistoryData.fromJson(json['data'])
          : null,
    );
  }
}

class BillPaymentHistoryData {
  List<Bills>? bills;
  Meta? meta;

  BillPaymentHistoryData({this.bills, this.meta});

  factory BillPaymentHistoryData.fromJson(Map<String, dynamic> json) {
    return BillPaymentHistoryData(
      bills: (json['bills'] as List?)?.map((e) => Bills.fromJson(e)).toList(),
      meta: json['meta'] != null ? Meta.fromJson(json['meta']) : null,
    );
  }
}

class Bills {
  String? serviceName;
  String? serviceType;
  String? amount;
  String? charge;
  String? status;
  String? method;
  String? createdAt;
  List<Metadata>? metadata;

  Bills({
    this.serviceName,
    this.serviceType,
    this.amount,
    this.charge,
    this.status,
    this.method,
    this.createdAt,
    this.metadata,
  });

  factory Bills.fromJson(Map<String, dynamic> json) {
    return Bills(
      serviceName: json['service_name'],
      serviceType: json['service_type'],
      amount: json['amount'],
      charge: json['charge'],
      status: json['status'],
      method: json['method'],
      createdAt: json['created_at'],
      metadata: (json['metadata'] as List?)
          ?.map((e) => Metadata.fromJson(e))
          .toList(),
    );
  }
}

class Metadata {
  final String key;
  final String value;

  Metadata({required this.key, required this.value});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    final entry = json.entries.first;
    return Metadata(key: entry.key, value: entry.value.toString());
  }
}

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      perPage: json['per_page'],
      total: json['total'],
    );
  }
}
