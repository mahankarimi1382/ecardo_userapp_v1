class KycRejectedModel {
  String? status;
  String? message;
  KycRejectedData? data;

  KycRejectedModel({this.status, this.message, this.data});

  KycRejectedModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? KycRejectedData.fromJson(json['data']) : null;
  }
}

class KycRejectedData {
  int? id;
  int? userId;
  int? kycId;
  String? type;
  List<Data>? data;
  String? message;
  int? isValid;
  String? status;
  String? createdAt;
  String? updatedAt;
  Kyc? kyc;

  KycRejectedData({
    this.id,
    this.userId,
    this.kycId,
    this.type,
    this.data,
    this.message,
    this.isValid,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.kyc,
  });

  KycRejectedData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    kycId = json['kyc_id'];
    type = json['type'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(Data.fromJson(v));
      });
    }
    message = json['message'];
    isValid = json['is_valid'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    kyc = json['kyc'] != null ? Kyc.fromJson(json['kyc']) : null;
  }
}

class Data {
  String? name;
  String? type;
  String? validation;
  String? value;

  Data({this.name, this.type, this.validation, this.value});

  Data.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    validation = json['validation'];
    value = json['value'];
  }
}

class Kyc {
  int? id;
  String? name;
  String? fields;
  int? status;
  String? createdAt;
  String? updatedAt;

  Kyc({
    this.id,
    this.name,
    this.fields,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Kyc.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    fields = json['fields'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
