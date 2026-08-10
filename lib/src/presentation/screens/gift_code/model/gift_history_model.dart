class GiftHistoryModel {
  String? status;
  String? message;
  GiftHistoryData? data;

  GiftHistoryModel({this.status, this.message, this.data});

  GiftHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? GiftHistoryData.fromJson(json['data']) : null;
  }
}

class GiftHistoryData {
  List<Gifts>? gifts;
  Pagination? pagination;

  GiftHistoryData({this.gifts, this.pagination});

  GiftHistoryData.fromJson(Map<String, dynamic> json) {
    if (json['gifts'] != null) {
      gifts = <Gifts>[];
      json['gifts'].forEach((v) {
        gifts!.add(Gifts.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }
}

class Gifts {
  int? id;
  String? code;
  String? amount;
  String? charge;
  String? finalAmount;
  String? currency;
  String? currencySymbol;
  bool? isRedeemed;
  String? type;
  bool? isCrypto;
  Creator? creator;
  String? createdAt;
  String? claimedAt;

  Gifts({
    this.id,
    this.code,
    this.amount,
    this.charge,
    this.finalAmount,
    this.currency,
    this.currencySymbol,
    this.isRedeemed,
    this.type,
    this.isCrypto,
    this.creator,
    this.createdAt,
    this.claimedAt,
  });

  Gifts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    code = json['code'];
    amount = json['amount'];
    charge = json['charge'];
    finalAmount = json['final_amount'];
    currency = json['currency'];
    currencySymbol = json['currency_symbol'];
    isRedeemed = json['is_redeemed'];
    type = json['type'];
    isCrypto = json['is_crypto'];
    creator =
        json['creator'] != null ? Creator.fromJson(json['creator']) : null;
    createdAt = json['created_at'];
    claimedAt = json['claimed_at'];
  }
}

class Creator {
  int? id;
  String? name;
  String? email;
  String? accountNumber;
  String? avatar;

  Creator({this.id, this.name, this.email, this.accountNumber, this.avatar});

  Creator.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    accountNumber = json['account_number'];
    avatar = json['avatar'];
  }
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  Pagination.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}
