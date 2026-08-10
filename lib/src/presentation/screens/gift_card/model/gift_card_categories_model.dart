class GiftCardCategoriesModel {
  String? status;
  String? message;
  List<GiftCardCategoriesData>? data;

  GiftCardCategoriesModel({this.status, this.message, this.data});

  GiftCardCategoriesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <GiftCardCategoriesData>[];
      json['data'].forEach((v) {
        data!.add(GiftCardCategoriesData.fromJson(v));
      });
    }
  }
}

class GiftCardCategoriesData {
  int? id;
  String? name;

  GiftCardCategoriesData({this.id, this.name});

  GiftCardCategoriesData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}
