class KycHistoryModel {
  String? status;
  String? message;
  List<KycHistoryData>? data;

  KycHistoryModel({this.status, this.message, this.data});

  KycHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <KycHistoryData>[];
      json['data'].forEach((v) {
        data!.add(KycHistoryData.fromJson(v));
      });
    }
  }
}

class KycHistoryData {
  int? id;
  int? userId;
  int? kycId;
  String? type;
  String? message;
  int? isValid;
  String? status;
  String? createdAt;
  String? updatedAt;
  Map<String, dynamic>? submittedData;

  KycHistoryData({
    this.id,
    this.userId,
    this.kycId,
    this.type,
    this.message,
    this.isValid,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.submittedData,
  });

  KycHistoryData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    kycId = json['kyc_id'];
    type = json['type'];
    message = json['message'];
    isValid = json['is_valid'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    submittedData =
        json['submitted_data'] != null
            ? Map<String, dynamic>.from(json['submitted_data'])
            : null;
  }
}
