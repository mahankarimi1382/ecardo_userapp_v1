class PaymentWalletModel {
  String? status;
  String? message;
  PaymentWalletData? data;

  PaymentWalletModel({this.status, this.message, this.data});

  PaymentWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? PaymentWalletData.fromJson(json['data']) : null;
  }
}

class PaymentWalletData {
  List<Wallets>? wallets;

  PaymentWalletData({this.wallets});

  PaymentWalletData.fromJson(Map<String, dynamic> json) {
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
  PaymentLimit? paymentLimit;
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
    this.paymentLimit,
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
    paymentLimit =
        json['payment_limit'] != null
            ? PaymentLimit.fromJson(json['payment_limit'])
            : null;
    conversionRate = json['conversion_rate'];
  }
}

class PaymentLimit {
  String? min;
  String? max;

  PaymentLimit({this.min, this.max});

  PaymentLimit.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }
}
