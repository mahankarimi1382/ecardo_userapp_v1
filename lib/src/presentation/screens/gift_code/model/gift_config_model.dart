class GiftConfigModel {
  String? status;
  String? message;
  GiftConfigData? data;

  GiftConfigModel({this.status, this.message, this.data});

  GiftConfigModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? GiftConfigData.fromJson(json['data']) : null;
  }
}

class GiftConfigData {
  Settings? settings;

  GiftConfigData({this.settings});

  GiftConfigData.fromJson(Map<String, dynamic> json) {
    settings =
        json['settings'] != null ? Settings.fromJson(json['settings']) : null;
  }
}

class Settings {
  String? minimumAmount;
  String? maximumAmount;
  String? dailyLimit;
  String? charge;
  String? chargeType;

  Settings({
    this.minimumAmount,
    this.maximumAmount,
    this.dailyLimit,
    this.charge,
    this.chargeType,
  });

  Settings.fromJson(Map<String, dynamic> json) {
    minimumAmount = json['minimum_amount'];
    maximumAmount = json['maximum_amount'];
    dailyLimit = json['daily_limit'];
    charge = json['charge'];
    chargeType = json['charge_type'];
  }
}
