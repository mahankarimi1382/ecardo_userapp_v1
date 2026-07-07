class HighestOrderPriceResponseModel {
  String? status;
  String? message;
  Data? data;

  HighestOrderPriceResponseModel({this.status, this.message, this.data});

  factory HighestOrderPriceResponseModel.fromJson(Map<String, dynamic> json) =>
      HighestOrderPriceResponseModel(
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
  String? highestPrice;
  Filters? filters;
  String? priceSource;

  Data({this.highestPrice, this.filters, this.priceSource});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    highestPrice: json["highest_price"],
    filters: json["filters"] == null ? null : Filters.fromJson(json["filters"]),
    priceSource: json["price_source"],
  );

  Map<String, dynamic> toJson() => {
    "highest_price": highestPrice,
    "filters": filters?.toJson(),
    "price_source": priceSource,
  };
}

class Filters {
  String? type;
  String? assetCurrencyId;
  String? fiatCurrencyId;

  Filters({this.type, this.assetCurrencyId, this.fiatCurrencyId});

  factory Filters.fromJson(Map<String, dynamic> json) => Filters(
    type: json["type"],
    assetCurrencyId: json["asset_currency_id"],
    fiatCurrencyId: json["fiat_currency_id"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "asset_currency_id": assetCurrencyId,
    "fiat_currency_id": fiatCurrencyId,
  };
}
