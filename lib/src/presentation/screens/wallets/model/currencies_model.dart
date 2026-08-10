class CurrenciesModel {
  bool? status;
  List<CurrenciesData>? data;

  CurrenciesModel({this.status, this.data});

  CurrenciesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <CurrenciesData>[];
      json['data'].forEach((v) {
        data!.add(CurrenciesData.fromJson(v));
      });
    }
  }
}

class CurrenciesData {
  int? id;
  String? name;
  String? code;
  String? type;
  String? symbol;
  String? icon;
  String? conversionRate;
  String? status;
  String? createdAt;
  String? updatedAt;
  String? fullName;

  CurrenciesData({
    this.id,
    this.name,
    this.code,
    this.type,
    this.symbol,
    this.icon,
    this.conversionRate,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.fullName,
  });

  CurrenciesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    type = json['type'];
    symbol = json['symbol'];
    icon = json['icon'];
    conversionRate = json['conversion_rate'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    fullName = json['full_name'];
  }
}
