class CardTransactionModel {
  String? status;
  String? message;
  List<CardTransactionData>? data;
  CardTransactionModel({this.status, this.data});
  CardTransactionModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <CardTransactionData>[];
      for (var v in json['data']) {
        data!.add(CardTransactionData.fromJson(v));
      }
    } else {
      data = [];
    }
  }
}

class CardTransactionData {
  String? id;
  String? created;
  int? amount;
  String? currency;
  String? status;
  MerchantData? merchantData;

  CardTransactionData({
    this.id,
    this.created,
    this.amount,
    this.currency,
    this.status,
    this.merchantData,
  });

  CardTransactionData.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    created = json['created'];
    amount = json['amount'];
    currency = json['currency'];
    status = json['status'];

    merchantData = json['merchant_data'] != null
        ? MerchantData.fromJson(json['merchant_data'])
        : null;
  }
}

class MerchantData {
  String? name;

  MerchantData({this.name});

  MerchantData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
  }
}
