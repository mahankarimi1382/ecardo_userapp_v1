class LanguageModel {
  bool? status;
  List<LanguageData>? data;

  LanguageModel({this.status, this.data});

  LanguageModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <LanguageData>[];
      json['data'].forEach((v) {
        data!.add(LanguageData.fromJson(v));
      });
    }
  }
}

class LanguageData {
  int? id;
  String? flag;
  String? name;
  String? locale;
  bool? isRtl;
  bool? isDefault;
  bool? status;
  String? createdAt;
  String? updatedAt;

  LanguageData({
    this.id,
    this.flag,
    this.name,
    this.locale,
    this.isRtl,
    this.isDefault,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  LanguageData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    flag = json['flag'];
    name = json['name'];
    locale = json['locale'];
    isRtl = json['is_rtl'];
    isDefault = json['is_default'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
