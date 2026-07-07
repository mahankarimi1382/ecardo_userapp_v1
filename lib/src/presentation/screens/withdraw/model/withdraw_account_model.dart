class WithdrawAccountModel {
  String? status;
  String? message;
  WithdrawAccountData? data;

  WithdrawAccountModel({this.status, this.message, this.data});

  WithdrawAccountModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? WithdrawAccountData.fromJson(json['data'])
        : null;
  }
}

class WithdrawAccountData {
  List<Accounts>? accounts;
  Pagination? pagination;

  WithdrawAccountData({this.accounts, this.pagination});

  WithdrawAccountData.fromJson(Map<String, dynamic> json) {
    if (json['accounts'] != null) {
      accounts = <Accounts>[];
      json['accounts'].forEach((v) {
        accounts!.add(Accounts.fromJson(v));
      });
    }
    pagination = json['pagination'] != null
        ? Pagination.fromJson(json['pagination'])
        : null;
  }
}

class Accounts {
  int? id;
  String? methodName;
  String? currency;
  String? walletName;
  Method? method;

  Accounts({
    this.id,
    this.methodName,
    this.currency,
    this.walletName,
    this.method,
  });

  Accounts.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    methodName = json['method_name'];
    currency = json['currency'];
    walletName = json['wallet_name'];
    method = json['method'] != null ? Method.fromJson(json['method']) : null;
  }
}

class Method {
  int? id;
  String? name;
  String? icon;
  String? type;
  String? minWithdraw;
  String? maxWithdraw;
  bool? isCrypto;
  String? charge;
  int? rate;
  String? chargeType;
  String? time;
  List<Fields>? fields;

  Method({
    this.id,
    this.name,
    this.icon,
    this.type,
    this.minWithdraw,
    this.maxWithdraw,
    this.isCrypto,
    this.charge,
    this.rate,
    this.chargeType,
    this.time,
    this.fields,
  });

  Method.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    icon = json['icon'];
    type = json['type'];
    minWithdraw = json['min_withdraw'];
    maxWithdraw = json['max_withdraw'];
    isCrypto = json['is_crypto'];
    charge = json['charge'];
    rate = json['rate'];
    chargeType = json['charge_type'];
    time = json['time'];
    if (json['fields'] != null) {
      fields = <Fields>[];
      json['fields'].forEach((v) {
        fields!.add(Fields.fromJson(v));
      });
    }
  }
}

class Fields {
  String? name;
  String? type;
  String? validation;
  String? value;

  Fields({this.name, this.type, this.validation, this.value});

  Fields.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    validation = json['validation'];
    value = json['value'];
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
