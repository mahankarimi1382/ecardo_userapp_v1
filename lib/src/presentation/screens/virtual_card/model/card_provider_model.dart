class CardProviderModel {
  bool? status;
  List<CardProviderData>? data;

  CardProviderModel({this.status, this.data});

  CardProviderModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    if (json['data'] != null) {
      data = <CardProviderData>[];
      json['data'].forEach((v) {
        data!.add(CardProviderData.fromJson(v));
      });
    }
  }
}

class CardProviderData {
  int? id;
  String? name;
  String? code;

  CardProviderData({this.id, this.name, this.code});

  CardProviderData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
  }
}
