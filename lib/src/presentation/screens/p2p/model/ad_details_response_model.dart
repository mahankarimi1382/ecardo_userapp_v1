class AdDetailsResponseModel {
  String? status;
  String? message;
  Data? data;

  AdDetailsResponseModel({this.status, this.message, this.data});

  factory AdDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      AdDetailsResponseModel(
        status: json["status"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  int? id;
  bool? isOwnAd;
  String? adNumber;
  String? adType;
  String? description;
  String? assetFiatPair;
  String? totalAmount;
  num? completedOrders;
  num? completionRate;
  String? orderLimit;
  String? price;
  String? rawPrice;
  RawOrderLimit? rawOrderLimit;
  List<PaymentMethodElement>? paymentMethods;
  Advertiser? advertiser;
  TCurrency? assetCurrency;
  TCurrency? fiatCurrency;
  String? responseTime;
  String? averageReleaseTime;
  String? lastUpdated;
  String? createdAt;

  Data({
    this.id,
    this.isOwnAd,
    this.adNumber,
    this.adType,
    this.description,
    this.assetFiatPair,
    this.totalAmount,
    this.completedOrders,
    this.completionRate,
    this.orderLimit,
    this.price,
    this.rawPrice,
    this.rawOrderLimit,
    this.paymentMethods,
    this.advertiser,
    this.assetCurrency,
    this.fiatCurrency,
    this.responseTime,
    this.averageReleaseTime,
    this.lastUpdated,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"],
    isOwnAd: json["is_own_ad"],
    adNumber: json["ad_number"],
    adType: json["ad_type"],
    description: json["description"],
    assetFiatPair: json["asset_fiat_pair"],
    totalAmount: json["total_amount"],
    completedOrders: json["completed_orders"],
    completionRate: json["completion_rate"],
    orderLimit: json["order_limit"],
    price: json["price"],
    rawPrice: json["raw_price"],
    rawOrderLimit: json["raw_order_limit"] == null
        ? null
        : RawOrderLimit.fromJson(json["raw_order_limit"]),
    paymentMethods: json["payment_methods"] == null
        ? []
        : List<PaymentMethodElement>.from(
            json["payment_methods"]!.map(
              (x) => PaymentMethodElement.fromJson(x),
            ),
          ),
    advertiser: json["advertiser"] == null
        ? null
        : Advertiser.fromJson(json["advertiser"]),
    assetCurrency: json["asset_currency"] == null
        ? null
        : TCurrency.fromJson(json["asset_currency"]),
    fiatCurrency: json["fiat_currency"] == null
        ? null
        : TCurrency.fromJson(json["fiat_currency"]),
    responseTime: json["response_time"],
    averageReleaseTime: json["average_release_time"],
    lastUpdated: json["last_updated"],
    createdAt: json["created_at"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "is_own_ad": isOwnAd,
    "ad_number": adNumber,
    "ad_type": adType,
    "description": description,
    "asset_fiat_pair": assetFiatPair,
    "total_amount": totalAmount,
    "completed_orders": completedOrders,
    "completion_rate": completionRate,
    "order_limit": orderLimit,
    "price": price,
    "raw_price": rawPrice,
    "raw_order_limit": rawOrderLimit?.toJson(),
    "payment_methods": paymentMethods == null
        ? []
        : List<dynamic>.from(paymentMethods!.map((x) => x.toJson())),
    "advertiser": advertiser?.toJson(),
    "asset_currency": assetCurrency?.toJson(),
    "fiat_currency": fiatCurrency?.toJson(),
    "response_time": responseTime,
    "average_release_time": averageReleaseTime,
    "last_updated": lastUpdated,
    "created_at": createdAt,
  };
}

class Advertiser {
  int? id;
  String? username;
  String? avatarText;
  String? fullName;
  bool? isVerifiedTrader;

  Advertiser({
    this.id,
    this.username,
    this.avatarText,
    this.fullName,
    this.isVerifiedTrader,
  });

  factory Advertiser.fromJson(Map<String, dynamic> json) => Advertiser(
    id: json["id"],
    username: json["username"],
    avatarText: json["avatar_text"],
    fullName: json["full_name"],
    isVerifiedTrader: json["is_verified_trader"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "avatar_text": avatarText,
    "full_name": fullName,
    "is_verified_trader": isVerifiedTrader,
  };
}

class TCurrency {
  int? id;
  String? name;
  String? code;
  String? icon;
  String? symbol;

  TCurrency({this.id, this.name, this.code, this.icon, this.symbol});

  factory TCurrency.fromJson(Map<String, dynamic> json) => TCurrency(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    icon: json["icon"],
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "icon": icon,
    "symbol": symbol,
  };
}

class PaymentMethodElement {
  int? id;
  int? adsId;
  int? paymentMethodId;
  List<Field>? fields;
  DateTime? createdAt;
  DateTime? updatedAt;
  PaymentMethodPaymentMethod? paymentMethod;

  PaymentMethodElement({
    this.id,
    this.adsId,
    this.paymentMethodId,
    this.fields,
    this.createdAt,
    this.updatedAt,
    this.paymentMethod,
  });

  factory PaymentMethodElement.fromJson(Map<String, dynamic> json) =>
      PaymentMethodElement(
        id: json["id"],
        adsId: json["ads_id"],
        paymentMethodId: json["payment_method_id"],
        fields: json["fields"] == null
            ? []
            : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        paymentMethod: json["payment_method"] == null
            ? null
            : PaymentMethodPaymentMethod.fromJson(json["payment_method"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "ads_id": adsId,
    "payment_method_id": paymentMethodId,
    "fields": fields == null
        ? []
        : List<dynamic>.from(fields!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "payment_method": paymentMethod?.toJson(),
  };
}

class Field {
  String? name;
  String? type;
  String? value;
  String? validation;

  Field({this.name, this.type, this.value, this.validation});

  factory Field.fromJson(Map<String, dynamic> json) => Field(
    name: json["name"],
    type: json["type"],
    value: json["value"],
    validation: json["validation"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "type": type,
    "value": value,
    "validation": validation,
  };
}

class PaymentMethodPaymentMethod {
  int? id;
  int? currencyId;
  String? name;
  List<Field>? fields;
  DateTime? createdAt;
  DateTime? updatedAt;
  Currency? currency;

  PaymentMethodPaymentMethod({
    this.id,
    this.currencyId,
    this.name,
    this.fields,
    this.createdAt,
    this.updatedAt,
    this.currency,
  });

  factory PaymentMethodPaymentMethod.fromJson(Map<String, dynamic> json) =>
      PaymentMethodPaymentMethod(
        id: json["id"],
        currencyId: json["currency_id"],
        name: json["name"],
        fields: json["fields"] == null
            ? []
            : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        currency: json["currency"] == null
            ? null
            : Currency.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "currency_id": currencyId,
    "name": name,
    "fields": fields == null
        ? []
        : List<dynamic>.from(fields!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "currency": currency?.toJson(),
  };
}

class Currency {
  int? id;
  String? name;
  String? code;
  String? type;
  String? symbol;
  String? icon;
  String? conversionRate;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;

  Currency({
    this.id,
    this.name,
    this.code,
    this.type,
    this.symbol,
    this.icon,
    this.conversionRate,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    type: json["type"],
    symbol: json["symbol"],
    icon: json["icon"],
    conversionRate: json["conversion_rate"],
    status: json["status"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "type": type,
    "symbol": symbol,
    "icon": icon,
    "conversion_rate": conversionRate,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class RawOrderLimit {
  String? min;
  String? max;

  RawOrderLimit({this.min, this.max});

  factory RawOrderLimit.fromJson(Map<String, dynamic> json) =>
      RawOrderLimit(min: json["min"], max: json["max"]);

  Map<String, dynamic> toJson() => {"min": min, "max": max};
}
