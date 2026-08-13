class SettingsModel {
  bool? status;
  List<SettingsData>? data;

  SettingsModel({this.status, this.data});

  SettingsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <SettingsData>[];
      json['data'].forEach((v) {
        data!.add(SettingsData.fromJson(v));
      });
    }
  }
}

class SettingsData {
  String? name;
  String? value;

  SettingsData({this.name, this.value});

  SettingsData.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    value = json['value'];
  }
}
