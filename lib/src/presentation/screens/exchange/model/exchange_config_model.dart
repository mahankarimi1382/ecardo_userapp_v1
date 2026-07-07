class ExchangeConfigModel {
  String? status;
  String? message;
  ExchangeConfigData? data;

  ExchangeConfigModel({this.status, this.message, this.data});

  ExchangeConfigModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? ExchangeConfigData.fromJson(json['data']) : null;
  }
}

class ExchangeConfigData {
  Settings? settings;

  ExchangeConfigData({this.settings});

  ExchangeConfigData.fromJson(Map<String, dynamic> json) {
    settings =
        json['settings'] != null ? Settings.fromJson(json['settings']) : null;
  }
}

class Settings {
  String? minimumAmount;
  String? maximumAmount;
  String? charge;
  String? chargeType;
  bool? kycRequired;

  Settings({
    this.minimumAmount,
    this.maximumAmount,
    this.charge,
    this.chargeType,
    this.kycRequired,
  });

  Settings.fromJson(Map<String, dynamic> json) {
    minimumAmount = json['minimum_amount'];
    maximumAmount = json['maximum_amount'];
    charge = json['charge'];
    chargeType = json['charge_type'];
    kycRequired = json['kyc_required'];
  }
}
