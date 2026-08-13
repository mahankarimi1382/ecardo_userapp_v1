class AdPaymentMethodResponseModel {
  String? status;
  String? message;
  Data? data;

  AdPaymentMethodResponseModel({this.status, this.message, this.data});

  factory AdPaymentMethodResponseModel.fromJson(Map<String, dynamic> json) =>
      AdPaymentMethodResponseModel(
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
  List<PaymentMethodElement>? paymentMethods;

  Data({this.paymentMethods});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    paymentMethods: json["payment_methods"] == null
        ? []
        : List<PaymentMethodElement>.from(
            json["payment_methods"]!.map(
              (x) => PaymentMethodElement.fromJson(x),
            ),
          ),
  );

  Map<String, dynamic> toJson() => {
    "payment_methods": paymentMethods == null
        ? []
        : List<dynamic>.from(paymentMethods!.map((x) => x.toJson())),
  };
}

class PaymentMethodElement {
  int? id;
  PaymentMethodPaymentMethod? paymentMethod;
  List<Field>? fields;
  DateTime? createdAt;
  DateTime? updatedAt;

  PaymentMethodElement({
    this.id,
    this.paymentMethod,
    this.fields,
    this.createdAt,
    this.updatedAt,
  });

  factory PaymentMethodElement.fromJson(Map<String, dynamic> json) =>
      PaymentMethodElement(
        id: json["id"],
        paymentMethod: json["payment_method"] == null
            ? null
            : PaymentMethodPaymentMethod.fromJson(json["payment_method"]),
        fields: json["fields"] == null
            ? []
            : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "payment_method": paymentMethod?.toJson(),
    "fields": fields == null
        ? []
        : List<dynamic>.from(fields!.map((x) => x.toJson())),
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
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
  String? name;
  Currency? currency;

  PaymentMethodPaymentMethod({this.id, this.name, this.currency});

  factory PaymentMethodPaymentMethod.fromJson(Map<String, dynamic> json) =>
      PaymentMethodPaymentMethod(
        id: json["id"],
        name: json["name"],
        currency: json["currency"] == null
            ? null
            : Currency.fromJson(json["currency"]),
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "currency": currency?.toJson(),
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
