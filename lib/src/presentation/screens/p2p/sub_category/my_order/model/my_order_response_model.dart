class MyOrderResponseModel {
  String? status;
  String? message;
  Data? data;

  MyOrderResponseModel({this.status, this.message, this.data});

  factory MyOrderResponseModel.fromJson(Map<String, dynamic> json) =>
      MyOrderResponseModel(
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
  List<Order>? orders;
  Pagination? pagination;

  Data({this.orders, this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    orders: json["orders"] == null
        ? []
        : List<Order>.from(json["orders"]!.map((x) => Order.fromJson(x))),
    pagination: json["pagination"] == null
        ? null
        : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "orders": orders == null
        ? []
        : List<dynamic>.from(orders!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Order {
  int? id;
  String? orderNumber;
  int? adId;
  String? adType;
  String? adsFiatCurrency;
  String? adsAssetCurrency;
  int? adsFiatCurrencyId;
  int? adsAssetCurrencyId;
  String? status;
  String? assetAmount;
  String? fiatAmount;
  String? totalFiatAmount;
  String? price;
  int? feePercent;
  String? feeAssetAmount;
  String? sellerLockedAsset;
  DateTime? paymentDeadlineAt;
  dynamic markedPaidAt;
  dynamic completedAt;
  dynamic cancelledAt;
  dynamic expiredAt;
  dynamic disputedAt;
  dynamic resolvedAt;
  dynamic disputeReason;
  dynamic resolutionNote;
  Role? role;
  PaymentMethod? paymentMethod;
  RecipientPaymentMethod? recipientPaymentMethod;
  bool? chatEnabled;
  DateTime? createdAt;
  DateTime? updatedAt;

  Order({
    this.id,
    this.orderNumber,
    this.adId,
    this.adType,
    this.adsFiatCurrency,
    this.adsAssetCurrency,
    this.adsFiatCurrencyId,
    this.adsAssetCurrencyId,
    this.status,
    this.assetAmount,
    this.fiatAmount,
    this.totalFiatAmount,
    this.price,
    this.feePercent,
    this.feeAssetAmount,
    this.sellerLockedAsset,
    this.paymentDeadlineAt,
    this.markedPaidAt,
    this.completedAt,
    this.cancelledAt,
    this.expiredAt,
    this.disputedAt,
    this.resolvedAt,
    this.disputeReason,
    this.resolutionNote,
    this.role,
    this.paymentMethod,
    this.recipientPaymentMethod,
    this.chatEnabled,
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json["id"],
    orderNumber: json["order_number"],
    adId: json["ad_id"],
    adType: json["ad_type"],
    adsFiatCurrency: json["ads_fiat_currency"],
    adsAssetCurrency: json["ads_asset_currency"],
    adsFiatCurrencyId: json["ads_fiat_currency_id"],
    adsAssetCurrencyId: json["ads_asset_currency_id"],
    status: json["status"],
    assetAmount: json["asset_amount"],
    fiatAmount: json["fiat_amount"],
    totalFiatAmount: json["total_fiat_amount"],
    price: json["price"],
    feePercent: json["fee_percent"],
    feeAssetAmount: json["fee_asset_amount"],
    sellerLockedAsset: json["seller_locked_asset"],
    paymentDeadlineAt: json["payment_deadline_at"] == null
        ? null
        : DateTime.parse(json["payment_deadline_at"]),
    markedPaidAt: json["marked_paid_at"],
    completedAt: json["completed_at"],
    cancelledAt: json["cancelled_at"],
    expiredAt: json["expired_at"],
    disputedAt: json["disputed_at"],
    resolvedAt: json["resolved_at"],
    disputeReason: json["dispute_reason"],
    resolutionNote: json["resolution_note"],
    role: json["role"] == null ? null : Role.fromJson(json["role"]),
    paymentMethod: json["payment_method"] == null
        ? null
        : PaymentMethod.fromJson(json["payment_method"]),
    recipientPaymentMethod: json["recipient_payment_method"] == null
        ? null
        : RecipientPaymentMethod.fromJson(json["recipient_payment_method"]),
    chatEnabled: json["chat_enabled"],
    createdAt: json["created_at"] == null
        ? null
        : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null
        ? null
        : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "order_number": orderNumber,
    "ad_id": adId,
    "ad_type": adType,
    "ads_fiat_currency": adsFiatCurrency,
    "ads_asset_currency": adsAssetCurrency,
    "ads_fiat_currency_id": adsFiatCurrencyId,
    "ads_asset_currency_id": adsAssetCurrencyId,
    "status": status,
    "asset_amount": assetAmount,
    "fiat_amount": fiatAmount,
    "total_fiat_amount": totalFiatAmount,
    "price": price,
    "fee_percent": feePercent,
    "fee_asset_amount": feeAssetAmount,
    "seller_locked_asset": sellerLockedAsset,
    "payment_deadline_at": paymentDeadlineAt?.toIso8601String(),
    "marked_paid_at": markedPaidAt,
    "completed_at": completedAt,
    "cancelled_at": cancelledAt,
    "expired_at": expiredAt,
    "disputed_at": disputedAt,
    "resolved_at": resolvedAt,
    "dispute_reason": disputeReason,
    "resolution_note": resolutionNote,
    "role": role?.toJson(),
    "payment_method": paymentMethod?.toJson(),
    "recipient_payment_method": recipientPaymentMethod?.toJson(),
    "chat_enabled": chatEnabled,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}

class PaymentMethod {
  int? id;
  String? name;
  List<Field>? accountFields;

  PaymentMethod({this.id, this.name, this.accountFields});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json["id"],
    name: json["name"],
    accountFields: json["account_fields"] == null
        ? []
        : List<Field>.from(
            json["account_fields"]!.map((x) => Field.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "account_fields": accountFields == null
        ? []
        : List<dynamic>.from(accountFields!.map((x) => x.toJson())),
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

class RecipientPaymentMethod {
  int? id;
  String? name;
  List<Field>? fields;

  RecipientPaymentMethod({this.id, this.name, this.fields});

  factory RecipientPaymentMethod.fromJson(Map<String, dynamic> json) =>
      RecipientPaymentMethod(
        id: json["id"],
        name: json["name"],
        fields: json["fields"] == null
            ? []
            : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "fields": fields == null
        ? []
        : List<dynamic>.from(fields!.map((x) => x.toJson())),
  };
}

class Role {
  bool? isBuyer;
  bool? isSeller;
  Buyer? buyer;
  Buyer? seller;

  Role({this.isBuyer, this.isSeller, this.buyer, this.seller});

  factory Role.fromJson(Map<String, dynamic> json) => Role(
    isBuyer: json["is_buyer"],
    isSeller: json["is_seller"],
    buyer: json["buyer"] == null ? null : Buyer.fromJson(json["buyer"]),
    seller: json["seller"] == null ? null : Buyer.fromJson(json["seller"]),
  );

  Map<String, dynamic> toJson() => {
    "is_buyer": isBuyer,
    "is_seller": isSeller,
    "buyer": buyer?.toJson(),
    "seller": seller?.toJson(),
  };
}

class Buyer {
  int? id;
  String? username;
  String? name;
  bool? isVerifiedTrader;

  Buyer({this.id, this.username, this.name, this.isVerifiedTrader});

  factory Buyer.fromJson(Map<String, dynamic> json) => Buyer(
    id: json["id"],
    username: json["username"],
    name: json["name"],
    isVerifiedTrader: json["is_verified_trader"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "name": name,
    "is_verified_trader": isVerifiedTrader,
  };
}

class Pagination {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Pagination({this.currentPage, this.lastPage, this.perPage, this.total});

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["current_page"],
    lastPage: json["last_page"],
    perPage: json["per_page"],
    total: json["total"],
  );

  Map<String, dynamic> toJson() => {
    "current_page": currentPage,
    "last_page": lastPage,
    "per_page": perPage,
    "total": total,
  };
}
