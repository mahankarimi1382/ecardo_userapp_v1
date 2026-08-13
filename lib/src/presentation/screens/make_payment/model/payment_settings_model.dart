class PaymentSettingsModel {
  String? status;
  String? message;
  PaymentSettingsData? data;

  PaymentSettingsModel({this.status, this.message, this.data});

  PaymentSettingsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null
            ? PaymentSettingsData.fromJson(json['data'])
            : null;
  }
}

class PaymentSettingsData {
  String? minimumAmount;
  String? maximumAmount;
  String? userCharge;
  String? userChargeType;
  String? merchantCharge;
  String? merchantChargeType;

  PaymentSettingsData({
    this.minimumAmount,
    this.maximumAmount,
    this.userCharge,
    this.userChargeType,
    this.merchantCharge,
    this.merchantChargeType,
  });

  PaymentSettingsData.fromJson(Map<String, dynamic> json) {
    minimumAmount = json['minimum_amount'];
    maximumAmount = json['maximum_amount'];
    userCharge = json['user_charge'];
    userChargeType = json['user_charge_type'];
    merchantCharge = json['merchant_charge'];
    merchantChargeType = json['merchant_charge_type'];
  }
}
