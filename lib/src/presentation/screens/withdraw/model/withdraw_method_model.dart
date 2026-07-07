class WithdrawMethodModel {
  String? status;
  String? message;
  List<WithdrawMethodData>? data;

  WithdrawMethodModel({this.status, this.message, this.data});

  WithdrawMethodModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <WithdrawMethodData>[];
      json['data'].forEach((v) {
        data!.add(WithdrawMethodData.fromJson(v));
      });
    }
  }
}

class WithdrawMethodData {
  int? id;
  String? icon;
  String? type;
  String? gatewayId;
  String? name;
  String? currency;
  String? rate;
  String? requiredTime;
  String? requiredTimeFormat;
  String? charge;
  String? chargeType;
  String? minWithdraw;
  String? maxWithdraw;
  List<Fields>? fields;
  int? status;
  String? createdAt;
  String? updatedAt;

  WithdrawMethodData({
    this.id,
    this.icon,
    this.type,
    this.gatewayId,
    this.name,
    this.currency,
    this.rate,
    this.requiredTime,
    this.requiredTimeFormat,
    this.charge,
    this.chargeType,
    this.minWithdraw,
    this.maxWithdraw,
    this.fields,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  WithdrawMethodData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    icon = json['icon'];
    type = json['type'];
    gatewayId = json['gateway_id'];
    name = json['name'];
    currency = json['currency'];
    rate = json['rate'];
    requiredTime = json['required_time'];
    requiredTimeFormat = json['required_time_format'];
    charge = json['charge'];
    chargeType = json['charge_type'];
    minWithdraw = json['min_withdraw'];
    maxWithdraw = json['max_withdraw'];
    if (json['fields'] != null) {
      fields = <Fields>[];
      json['fields'].forEach((v) {
        fields!.add(Fields.fromJson(v));
      });
    }
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class Fields {
  String? name;
  String? type;
  String? validation;

  Fields({this.name, this.type, this.validation});

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    validation = json['validation'];
  }
}
