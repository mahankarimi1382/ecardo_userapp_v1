class ReceivedRequestModel {
  String? status;
  String? message;
  ReceivedRequestData? data;

  ReceivedRequestModel({this.status, this.message, this.data});

  ReceivedRequestModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null
            ? ReceivedRequestData.fromJson(json['data'])
            : null;
  }
}

class ReceivedRequestData {
  List<Requests>? requests;
  Pagination? pagination;

  ReceivedRequestData({this.requests, this.pagination});

  ReceivedRequestData.fromJson(Map<String, dynamic> json) {
    if (json['requests'] != null) {
      requests = <Requests>[];
      json['requests'].forEach((v) {
        requests!.add(Requests.fromJson(v));
      });
    }
    pagination =
        json['pagination'] != null
            ? Pagination.fromJson(json['pagination'])
            : null;
  }
}

class Requests {
  int? id;
  String? amount;
  String? charge;
  String? finalAmount;
  String? currency;
  String? currencySymbol;
  String? requesterWalletCurrencyName;
  String? recipientWalletCurrencyName;
  String? status;
  String? note;
  String? type;
  bool? isCrypto;
  Requester? requester;
  Recipient? recipient;
  bool? canAction;
  String? createdAt;
  String? updatedAt;

  Requests({
    this.id,
    this.amount,
    this.charge,
    this.finalAmount,
    this.currency,
    this.currencySymbol,
    this.requesterWalletCurrencyName,
    this.recipientWalletCurrencyName,
    this.status,
    this.note,
    this.type,
    this.isCrypto,
    this.requester,
    this.recipient,
    this.canAction,
    this.createdAt,
    this.updatedAt,
  });

  Requests.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    amount = json['amount'];
    charge = json['charge'];
    finalAmount = json['final_amount'];
    currency = json['currency'];
    currencySymbol = json['currency_symbol'];
    requesterWalletCurrencyName = json['requester_wallet_currency_name'];
    recipientWalletCurrencyName = json['recipient_wallet_currency_name'];
    status = json['status'];
    note = json['note'];
    type = json['type'];
    isCrypto = json['is_crypto'];
    requester =
        json['requester'] != null
            ? Requester.fromJson(json['requester'])
            : null;
    recipient =
        json['recipient'] != null
            ? Recipient.fromJson(json['recipient'])
            : null;
    canAction = json['can_action'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class Requester {
  int? id;
  String? name;
  String? email;
  String? accountNumber;
  String? avatar;

  Requester({this.id, this.name, this.email, this.accountNumber, this.avatar});

  Requester.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    email = json['email'];
    accountNumber = json['account_number'];
    avatar = json['avatar'];
  }
}

class Recipient {
  int? id;
  String? name;
  String? email;
  String? accountNumber;
  String? avatar;

  Recipient({this.id, this.name, this.email, this.accountNumber, this.avatar});

  Recipient.fromJson(Map<String, dynamic> json) {
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
