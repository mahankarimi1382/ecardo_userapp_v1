class TransferConfigModel {
  String? status;
  String? message;
  TransferConfigData? data;

  TransferConfigModel({this.status, this.message, this.data});

  TransferConfigModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? TransferConfigData.fromJson(json['data']) : null;
  }
}

class TransferConfigData {
  Settings? settings;

  TransferConfigData({this.settings});

  TransferConfigData.fromJson(Map<String, dynamic> json) {
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
  bool? kycRequired;

  Settings({
    this.minimumAmount,
    this.maximumAmount,
    this.dailyLimit,
    this.charge,
    this.chargeType,
    this.kycRequired,
  });

  Settings.fromJson(Map<String, dynamic> json) {
    minimumAmount = json['minimum_amount'];
    maximumAmount = json['maximum_amount'];
    dailyLimit = json['daily_limit'];
    charge = json['charge'];
    chargeType = json['charge_type'];
    kycRequired = json['kyc_required'];
  }
}
