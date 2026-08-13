class BillCountriesModel {
  bool? status;
  List<String>? data;

  BillCountriesModel({this.status, this.data});

  BillCountriesModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    data = json['data'].cast<String>();
  }
}
