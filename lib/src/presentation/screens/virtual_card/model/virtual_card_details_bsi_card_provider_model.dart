class VirtualCardDetailsBsiCardProviderModel {
  String? status;
  String? message;
  VirtualCardDetailsBsiCardProviderData? data;

  VirtualCardDetailsBsiCardProviderModel({
    this.status,
    this.message,
    this.data,
  });

  VirtualCardDetailsBsiCardProviderModel.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    data = json['data'] != null
        ? VirtualCardDetailsBsiCardProviderData.fromJson(json['data'])
        : null;
  }
}

class VirtualCardDetailsBsiCardProviderData {
  String? status;
  String? message;
  String? code;
  String? externalId;
  BsiCardDetailsData? data;

  VirtualCardDetailsBsiCardProviderData({
    this.status,
    this.message,
    this.code,
    this.externalId,
    this.data,
  });

  VirtualCardDetailsBsiCardProviderData.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    code = json['code']?.toString();
    externalId = json['external_id']?.toString();
    data = json['data'] != null
        ? BsiCardDetailsData.fromJson(json['data'])
        : null;
  }
}

class BsiCardDetailsData {
  String? cardId;
  String? cardNumber;
  String? type;
  String? physicalStatus;
  String? status;
  String? expiryYear;
  String? expiryMonth;
  String? cvv;
  String? nameOnCard;
  String? userEmail;
  String? walletId;
  num? balance;
  String? depositAddress;
  String? usdtDepositAddress;
  String? btcDepositAddress;
  String? ethDepositAddress;
  String? solDepositAddress;
  String? bnbDepositAddress;
  String? xrpDepositAddress;
  String? paxgDepositAddress;
  String? brand;
  String? address1;
  String? city;
  String? state;
  String? country;
  String? postalCode;
  String? phone;
  String? pin;
  String? pointBalance;
  int? isAddon;
  List<dynamic>? deposits;
  BsiTransactions? transactions;
  List<dynamic>? points;
  List<dynamic>? addonCard;

  BsiCardDetailsData({
    this.cardId,
    this.cardNumber,
    this.type,
    this.physicalStatus,
    this.status,
    this.expiryYear,
    this.expiryMonth,
    this.cvv,
    this.nameOnCard,
    this.userEmail,
    this.walletId,
    this.balance,
    this.depositAddress,
    this.usdtDepositAddress,
    this.btcDepositAddress,
    this.ethDepositAddress,
    this.solDepositAddress,
    this.bnbDepositAddress,
    this.xrpDepositAddress,
    this.paxgDepositAddress,
    this.brand,
    this.address1,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.phone,
    this.pin,
    this.pointBalance,
    this.isAddon,
    this.deposits,
    this.transactions,
    this.points,
    this.addonCard,
  });

  BsiCardDetailsData.fromJson(Map<String, dynamic> json) {
    cardId = json['cardid']?.toString();
    cardNumber = json['card_number']?.toString();
    type = json['type']?.toString();
    physicalStatus = json['physicalstatus']?.toString();
    status = json['status']?.toString();
    expiryYear = json['expiry_year']?.toString();
    expiryMonth = json['expiry_month']?.toString();
    cvv = json['cvv']?.toString();
    nameOnCard = json['nameoncard']?.toString();
    userEmail = json['useremail']?.toString();
    walletId = json['walletid']?.toString();
    balance = json['balance'];
    depositAddress = json['depositaddress']?.toString();
    usdtDepositAddress = json['usdtdepositaddress']?.toString();
    btcDepositAddress = json['btcdepositaddress']?.toString();
    ethDepositAddress = json['ethdepositaddress']?.toString();
    solDepositAddress = json['soldepositaddress']?.toString();
    bnbDepositAddress = json['bnbdepositaddress']?.toString();
    xrpDepositAddress = json['xrpdepositaddress']?.toString();
    paxgDepositAddress = json['paxgdepositaddress']?.toString();
    brand = json['brand']?.toString();
    address1 = json['address1']?.toString();
    city = json['city']?.toString();
    state = json['state']?.toString();
    country = json['country']?.toString();
    postalCode = json['postalCode']?.toString();
    phone = json['phone']?.toString();
    pin = json['pin']?.toString();
    pointBalance = json['point_balance']?.toString();
    isAddon = json['isaddon'] is int
        ? json['isaddon'] as int
        : int.tryParse(json['isaddon']?.toString() ?? '');
    deposits = json['deposits'] is List
        ? List<dynamic>.from(json['deposits'])
        : [];
    transactions = json['transactions'] is Map<String, dynamic>
        ? BsiTransactions.fromJson(json['transactions'])
        : json['transactions'] is List
        ? BsiTransactions.fromList(List<dynamic>.from(json['transactions']))
        : null;
    points = json['points'] is List ? List<dynamic>.from(json['points']) : [];
    addonCard = json['addoncard'] is List
        ? List<dynamic>.from(json['addoncard'])
        : [];
  }
}

class BsiTransactions {
  BsiTransactionResponse? response;
  int? code;
  List<dynamic>? items;

  BsiTransactions({this.response, this.code, this.items});

  BsiTransactions.fromJson(Map<String, dynamic> json) {
    response = json['response'] is Map<String, dynamic>
        ? BsiTransactionResponse.fromJson(json['response'])
        : json['response'] is List
        ? BsiTransactionResponse.fromList(List<dynamic>.from(json['response']))
        : null;
    code = json['code'] is int
        ? json['code'] as int
        : int.tryParse(json['code']?.toString() ?? '');
    items = json['items'] is List ? List<dynamic>.from(json['items']) : [];
  }

  BsiTransactions.fromList(List<dynamic> list) {
    items = list;
  }
}

class BsiTransactionResponse {
  List<dynamic>? items;
  int? count;
  bool? hasMore;
  int? page;

  BsiTransactionResponse({this.items, this.count, this.hasMore, this.page});

  BsiTransactionResponse.fromJson(Map<String, dynamic> json) {
    items = json['items'] is List ? List<dynamic>.from(json['items']) : [];
    count = json['count'] is int
        ? json['count'] as int
        : int.tryParse(json['count']?.toString() ?? '');
    hasMore = json['hasMore'] == true;
    page = json['page'] is int
        ? json['page'] as int
        : int.tryParse(json['page']?.toString() ?? '');
  }

  BsiTransactionResponse.fromList(List<dynamic> list) {
    items = list;
    count = list.length;
    hasMore = false;
    page = 0;
  }
}
