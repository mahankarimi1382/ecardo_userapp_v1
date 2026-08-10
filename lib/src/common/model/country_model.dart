class CountryModel {
  bool? status;
  List<CountryData>? data;

  CountryModel({this.status, this.data});

  CountryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <CountryData>[];
      json['data'].forEach((v) {
        data!.add(CountryData.fromJson(v));
      });
    }
  }
}

class CountryData {
  String? name;
  String? dialCode;
  String? code;
  String? flag;
  bool? selected;

  CountryData({this.name, this.dialCode, this.code, this.flag, this.selected});

  CountryData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    dialCode = json['dial_code'];
    code = json['code'];
    flag = json['flag'];
    selected = json['selected'];
  }
}
