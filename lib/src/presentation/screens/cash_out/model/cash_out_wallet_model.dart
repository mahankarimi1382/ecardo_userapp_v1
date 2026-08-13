class CashOutWalletModel {
  String? status;
  String? message;
  CashOutWalletData? data;

  CashOutWalletModel({this.status, this.message, this.data});

  CashOutWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? CashOutWalletData.fromJson(json['data']) : null;
  }
}

class CashOutWalletData {
  List<Wallets>? wallets;

  CashOutWalletData({this.wallets});

  CashOutWalletData.fromJson(Map<String, dynamic> json) {
    if (json['wallets'] != null) {
      wallets = <Wallets>[];
      json['wallets'].forEach((v) {
        wallets!.add(Wallets.fromJson(v));
      });
    }
  }
}

class Wallets {
  int? id;
  String? name;
  String? accountNo;
  String? balance;
  String? formattedBalance;
  String? code;
  String? symbol;
  String? icon;
  bool? isDefault;
  bool? isCrypto;
  int? currencyId;
  CashoutLimit? cashoutLimit;
  String? conversionRate;

  Wallets({
    this.id,
    this.name,
    this.accountNo,
    this.balance,
    this.formattedBalance,
    this.code,
    this.symbol,
    this.icon,
    this.isDefault,
    this.isCrypto,
    this.currencyId,
    this.cashoutLimit,
    this.conversionRate,
  });

  Wallets.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    accountNo = json['account_no'];
    balance = json['balance'];
    formattedBalance = json['formatted_balance'];
    code = json['code'];
    symbol = json['symbol'];
    icon = json['icon'];
    isDefault = json['is_default'];
    isCrypto = json['is_crypto'];
    currencyId = json['currency_id'];
    cashoutLimit =
        json['cashout_limit'] != null
            ? CashoutLimit.fromJson(json['cashout_limit'])
            : null;
    conversionRate = json['conversion_rate'];
  }
}

class CashoutLimit {
  String? min;
  String? max;

  CashoutLimit({this.min, this.max});

  CashoutLimit.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }
}
