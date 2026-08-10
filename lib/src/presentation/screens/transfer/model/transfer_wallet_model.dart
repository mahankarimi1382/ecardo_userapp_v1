class TransferWalletModel {
  String? status;
  String? message;
  TransferWalletData? data;

  TransferWalletModel({this.status, this.message, this.data});

  TransferWalletModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data =
        json['data'] != null ? TransferWalletData.fromJson(json['data']) : null;
  }
}

class TransferWalletData {
  List<Wallets>? wallets;

  TransferWalletData({this.wallets});

  TransferWalletData.fromJson(Map<String, dynamic> json) {
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
  TransferLimit? transferLimit;
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
    this.transferLimit,
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
    transferLimit =
        json['transfer_limit'] != null
            ? TransferLimit.fromJson(json['transfer_limit'])
            : null;
    conversionRate = json['conversion_rate'];
  }
}

class TransferLimit {
  String? min;
  String? max;

  TransferLimit({this.min, this.max});

  TransferLimit.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }
}
