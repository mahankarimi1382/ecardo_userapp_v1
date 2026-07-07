class GiftCardCountryModel {
  String? status;
  String? message;
  List<GiftCardCountryData>? data;

  GiftCardCountryModel({this.status, this.message, this.data});

  GiftCardCountryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <GiftCardCountryData>[];
      json['data'].forEach((v) {
        data!.add(GiftCardCountryData.fromJson(v));
      });
    }
  }
}

class GiftCardCountryData {
  String? isoName;
  String? name;
  String? currencyCode;
  String? currencyName;
  String? flagUrl;

  GiftCardCountryData({
    this.isoName,
    this.name,
    this.currencyCode,
    this.currencyName,
    this.flagUrl,
  });

  GiftCardCountryData.fromJson(Map<String, dynamic> json) {
    isoName = json['isoName'];
    name = json['name'];
    currencyCode = json['currencyCode'];
    currencyName = json['currencyName'];
    flagUrl = json['flagUrl'];
  }
}
