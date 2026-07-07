class RegisterFieldsModel {
  bool? status;
  List<GetRegisterFields>? data;

  RegisterFieldsModel({this.status, this.data});

  RegisterFieldsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <GetRegisterFields>[];
      json['data'].forEach((v) {
        data!.add(GetRegisterFields.fromJson(v));
      });
    }
  }
}

class GetRegisterFields {
  int? id;
  String? key;
  String? value;
  String? createdAt;
  String? updatedAt;

  GetRegisterFields({
    this.id,
    this.key,
    this.value,
    this.createdAt,
    this.updatedAt,
  });

  GetRegisterFields.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    key = json['key'];
    value = json['value'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
