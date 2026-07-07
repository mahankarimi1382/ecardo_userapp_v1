class GiftWalletModel {
  String? status;
  String? message;
  GiftWalletData? data;

  GiftWalletModel({this.status, this.message, this.data});

  GiftWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null ? GiftWalletData.fromJson(json['data']) : null;
  }
}

class GiftWalletData {
  List<Wallets>? wallets;

  GiftWalletData({this.wallets});

  GiftWalletData.fromJson(Map<String, dynamic> json) {
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
  GiftLimit? giftLimit;
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
    this.giftLimit,
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
    giftLimit =
        json['gift_limit'] != null
            ? GiftLimit.fromJson(json['gift_limit'])
            : null;
    conversionRate = json['conversion_rate'];
  }
}

class GiftLimit {
  String? min;
  String? max;

  GiftLimit({this.min, this.max});

  GiftLimit.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }
}
