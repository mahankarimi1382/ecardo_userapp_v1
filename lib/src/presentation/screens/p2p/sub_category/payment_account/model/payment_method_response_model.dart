class PaymentMethodResponseModel {
  String? status;
  String? message;
  Data? data;

  PaymentMethodResponseModel({this.status, this.message, this.data});

  factory PaymentMethodResponseModel.fromJson(Map<String, dynamic> json) =>
      PaymentMethodResponseModel(
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
  List<PaymentMethod>? paymentMethods;

  Data({this.paymentMethods});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    paymentMethods: json["payment_methods"] == null
        ? []
        : List<PaymentMethod>.from(
            json["payment_methods"]!.map((x) => PaymentMethod.fromJson(x)),
          ),
  );

  Map<String, dynamic> toJson() => {
    "payment_methods": paymentMethods == null
        ? []
        : List<dynamic>.from(paymentMethods!.map((x) => x.toJson())),
  };
}

class PaymentMethod {
  int? id;
  String? name;
  Currency? currency;
  List<Field>? fields;

  PaymentMethod({this.id, this.name, this.currency, this.fields});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
    id: json["id"],
    name: json["name"],
    currency: json["currency"] == null
        ? null
        : Currency.fromJson(json["currency"]),
    fields: json["fields"] == null
        ? []
        : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "currency": currency?.toJson(),
    "fields": fields == null
        ? []
        : List<dynamic>.from(fields!.map((x) => x.toJson())),
  };
}

class Currency {
  int? id;
  String? name;
  String? code;
  String? symbol;

  Currency({this.id, this.name, this.code, this.symbol});

  factory Currency.fromJson(Map<String, dynamic> json) => Currency(
    id: json["id"],
    name: json["name"],
    code: json["code"],
    symbol: json["symbol"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "code": code,
    "symbol": symbol,
  };
}

class Field {
  String? name;
  String? type;
  String? validation;

  Field({this.name, this.type, this.validation});

  factory Field.fromJson(Map<String, dynamic> json) => Field(
    name: json["name"],
    type: json["type"],
    validation: json["validation"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "type": type,
    "validation": validation,
  };
}
