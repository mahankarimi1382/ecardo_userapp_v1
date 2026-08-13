class PaymentAccountResponseModel {
    String? status;
    String? message;
    Data? data;

    PaymentAccountResponseModel({
        this.status,
        this.message,
        this.data,
    });

    factory PaymentAccountResponseModel.fromJson(Map<String, dynamic> json) => PaymentAccountResponseModel(
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
    List<PaymentAccount>? paymentAccounts;
    Pagination? pagination;

    Data({
        this.paymentAccounts,
        this.pagination,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        paymentAccounts: json["payment_accounts"] == null ? [] : List<PaymentAccount>.from(json["payment_accounts"]!.map((x) => PaymentAccount.fromJson(x))),
        pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "payment_accounts": paymentAccounts == null ? [] : List<dynamic>.from(paymentAccounts!.map((x) => x.toJson())),
        "pagination": pagination?.toJson(),
    };
}

class Pagination {
    int? currentPage;
    int? lastPage;
    int? perPage;
    int? total;

    Pagination({
        this.currentPage,
        this.lastPage,
        this.perPage,
        this.total,
    });

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

class PaymentAccount {
    int? id;
    PaymentMethod? paymentMethod;
    List<Field>? fields;
    DateTime? createdAt;
    DateTime? updatedAt;

    PaymentAccount({
        this.id,
        this.paymentMethod,
        this.fields,
        this.createdAt,
        this.updatedAt,
    });

    factory PaymentAccount.fromJson(Map<String, dynamic> json) => PaymentAccount(
        id: json["id"],
        paymentMethod: json["payment_method"] == null ? null : PaymentMethod.fromJson(json["payment_method"]),
        fields: json["fields"] == null ? [] : List<Field>.from(json["fields"]!.map((x) => Field.fromJson(x))),
        createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "payment_method": paymentMethod?.toJson(),
        "fields": fields == null ? [] : List<dynamic>.from(fields!.map((x) => x.toJson())),
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
    };
}

class Field {
    String? name;
    String? type;
    String? value;
    String? validation;

    Field({
        this.name,
        this.type,
        this.value,
        this.validation,
    });

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

class PaymentMethod {
    int? id;
    String? name;
    Currency? currency;

    PaymentMethod({
        this.id,
        this.name,
        this.currency,
    });

    factory PaymentMethod.fromJson(Map<String, dynamic> json) => PaymentMethod(
        id: json["id"],
        name: json["name"],
        currency: json["currency"] == null ? null : Currency.fromJson(json["currency"]),
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

    Currency({
        this.id,
        this.name,
        this.code,
        this.symbol,
    });

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
