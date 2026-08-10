class KycModel {
  String? status;
  String? message;
  List<KycData>? data;

  KycModel({this.status, this.message, this.data});

  KycModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <KycData>[];
      json['data'].forEach((v) {
        data!.add(KycData.fromJson(v));
      });
    }
  }
}

class KycData {
  int? id;
  String? name;
  List<Fields>? fields;
  int? status;
  String? createdAt;
  String? updatedAt;

  KycData({
    this.id,
    this.name,
    this.fields,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  KycData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
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
  String? instructions;

  Fields({this.name, this.type, this.validation, this.instructions});

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    validation = json['validation'];
    instructions = json['instructions'];
  }
}
