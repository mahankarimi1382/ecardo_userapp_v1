class PaymentLinksHistoryModel {
  String? status;
  String? message;
  PaymentLinksHistoryData? data;

  PaymentLinksHistoryModel({this.status, this.message, this.data});

  PaymentLinksHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? PaymentLinksHistoryData.fromJson(json['data'])
        : null;
  }
}

class PaymentLinksHistoryData {
  List<PaymentLinks>? paymentLinks;
  Pagination? pagination;

  PaymentLinksHistoryData({this.paymentLinks, this.pagination});

  PaymentLinksHistoryData.fromJson(Map<String, dynamic> json) {
    if (json['payment_links'] != null) {
      paymentLinks = <PaymentLinks>[];
      json['payment_links'].forEach((v) {
        paymentLinks!.add(PaymentLinks.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }
}

class PaymentLinks {
  int? id;
  String? number;
  bool? isPaid;
  String? paymentLink;
  String? createdAt;

  PaymentLinks({
    this.id,
    this.number,
    this.isPaid,
    this.paymentLink,
    this.createdAt,
  });

  PaymentLinks.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    number = json['number'];
    isPaid = json['is_paid'];
    paymentLink = json['payment_link'];
    createdAt = json['created_at'];
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}
