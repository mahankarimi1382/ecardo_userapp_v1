class ExchangeWalletModel {
  String? status;
  String? message;
  ExchangeWalletData? data;

  ExchangeWalletModel({this.status, this.message, this.data});

  ExchangeWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? ExchangeWalletData.fromJson(json['data']) : null;
  }
}

class ExchangeWalletData {
  List<Wallets>? wallets;

  ExchangeWalletData({this.wallets});

  ExchangeWalletData.fromJson(Map<String, dynamic> json) {
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
  ExchangeLimit? exchangeLimit;
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
    this.exchangeLimit,
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
    exchangeLimit =
        json['exchange_limit'] != null
            ? ExchangeLimit.fromJson(json['exchange_limit'])
            : null;
    conversionRate = json['conversion_rate'];
  }
}

class ExchangeLimit {
  String? min;
  String? max;

  ExchangeLimit({this.min, this.max});

  ExchangeLimit.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }
}
