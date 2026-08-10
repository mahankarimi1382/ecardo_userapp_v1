class BeneficiaryModel {
  String? status;
  String? message;
  BeneficiaryData? data;

  BeneficiaryModel({this.status, this.message, this.data});

  BeneficiaryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? BeneficiaryData.fromJson(json['data']) : null;
  }
}

class BeneficiaryData {
  List<Beneficiaries>? beneficiaries;

  BeneficiaryData({this.beneficiaries});

  BeneficiaryData.fromJson(Map<String, dynamic> json) {
    if (json['beneficiaries'] != null) {
      beneficiaries = <Beneficiaries>[];
      json['beneficiaries'].forEach((v) {
        beneficiaries!.add(Beneficiaries.fromJson(v));
      });
    }
  }
}

class Beneficiaries {
  int? id;
  String? nickname;
  String? accountNumber;
  Receiver? receiver;
  String? createdAt;

  Beneficiaries({
    this.id,
    this.nickname,
    this.accountNumber,
    this.receiver,
    this.createdAt,
  });

  Beneficiaries.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nickname = json['nickname'];
    accountNumber = json['account_number'];
    receiver = json['receiver'] != null
        ? Receiver.fromJson(json['receiver'])
        : null;
    createdAt = json['created_at'];
  }
}

class Receiver {
  int? id;
  String? name;
  String? email;
  String? avatar;

  Receiver({this.id, this.name, this.email, this.avatar});

  Receiver.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    avatar = json['avatar'];
  }
}
