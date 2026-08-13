class WithdrawHistoryModel {
  String? status;
  String? message;
  WithdrawHistoryData? data;

  WithdrawHistoryModel({this.status, this.message, this.data});

  WithdrawHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null
            ? WithdrawHistoryData.fromJson(json['data'])
            : null;
  }
}

class WithdrawHistoryData {
  List<Transactions>? transactions;
  Meta? meta;

  WithdrawHistoryData({this.transactions, this.meta});

  WithdrawHistoryData.fromJson(Map<String, dynamic> json) {
    if (json['transactions'] != null) {
      transactions = <Transactions>[];
      json['transactions'].forEach((v) {
        transactions!.add(Transactions.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
}

class Transactions {
  String? description;
  String? tnx;
  bool? isPlus;
  String? type;
  String? amount;
  String? charge;
  String? finalAmount;
  String? status;
  String? method;
  String? createdAt;
  String? payCurrency;
  String? payAmount;
  String? walletType;
  bool? isCrypto;
  String? trxCurrency;

  Transactions({
    this.description,
    this.tnx,
    this.isPlus,
    this.type,
    this.amount,
    this.charge,
    this.finalAmount,
    this.status,
    this.method,
    this.createdAt,
    this.payCurrency,
    this.payAmount,
    this.walletType,
    this.isCrypto,
    this.trxCurrency,
  });

  Transactions.fromJson(Map<String, dynamic> json) {
    description = json['description'];
    tnx = json['tnx'];
    isPlus = json['is_plus'];
    type = json['type'];
    amount = json['amount'];
    charge = json['charge'];
    finalAmount = json['final_amount'];
    status = json['status'];
    method = json['method'];
    createdAt = json['created_at'];
    payCurrency = json['pay_currency'];
    payAmount = json['pay_amount'];
    walletType = json['wallet_type'];
    isCrypto = json['is_crypto'];
    trxCurrency = json['trx_currency'];
  }
}

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}
