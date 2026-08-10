class QrCodeModel {
  String? status;
  String? message;
  String? data;

  QrCodeModel({this.status, this.message, this.data});

  QrCodeModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'];
  }
}
