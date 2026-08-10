class RequestMoneyWalletModel {
  String? status;
  String? message;
  RequestMoneyWalletData? data;

  RequestMoneyWalletModel({this.status, this.message, this.data});

  RequestMoneyWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null
            ? RequestMoneyWalletData.fromJson(json['data'])
            : null;
  }
}

class RequestMoneyWalletData {
  List<Wallets>? wallets;

  RequestMoneyWalletData({this.wallets});

  RequestMoneyWalletData.fromJson(Map<String, dynamic> json) {
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
  RequestMoneyLimit? requestMoneyLimit;
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
    this.requestMoneyLimit,
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
    requestMoneyLimit =
        json['request_money_limit'] != null
            ? RequestMoneyLimit.fromJson(json['request_money_limit'])
            : null;
    conversionRate = json['conversion_rate'];
  }
}

class RequestMoneyLimit {
  String? min;
  String? max;

  RequestMoneyLimit({this.min, this.max});

  RequestMoneyLimit.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }
}
