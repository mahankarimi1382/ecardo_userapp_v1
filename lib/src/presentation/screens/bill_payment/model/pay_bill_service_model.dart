class PayBillServiceModel {
  String? status;
  String? message;
  List<PayBillServiceData>? data;

  PayBillServiceModel({this.status, this.message, this.data});

  PayBillServiceModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <PayBillServiceData>[];
      json['data'].forEach((v) {
        data!.add(PayBillServiceData.fromJson(v));
      });
    }
  }
}

class PayBillServiceData {
  int? id;
  String? name;
  String? code;
  String? country;
  String? countryCode;
  List<String>? fields;
  String? currency;
  int? rate;
  int? amount;
  int? minAmount;
  int? maxAmount;
  double? charge;
  String? chargeType;

  PayBillServiceData({
    this.id,
    this.name,
    this.code,
    this.country,
    this.countryCode,
    this.fields,
    this.currency,
    this.rate,
    this.amount,
    this.minAmount,
    this.maxAmount,
    this.charge,
    this.chargeType,
  });

  PayBillServiceData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    country = json['country'];
    countryCode = json['country_code'];

    fields = json['fields'] != null ? List<String>.from(json['fields']) : [];

    currency = json['currency'];
    rate = json['rate'];
    amount = json['amount'];
    minAmount = json['min_amount'];
    maxAmount = json['max_amount'];
    charge = json['charge'] != null
        ? (json['charge'] is int
              ? (json['charge'] as int).toDouble()
              : json['charge'])
        : null;
    chargeType = json['charge_type'];
  }
}
