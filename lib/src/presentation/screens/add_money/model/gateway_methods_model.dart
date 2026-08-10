class GatewayMethodsModel {
  String? status;
  String? message;
  List<GatewayMethodsData>? data;

  GatewayMethodsModel({this.status, this.message, this.data});

  GatewayMethodsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <GatewayMethodsData>[];
      json['data'].forEach((v) {
        data!.add(GatewayMethodsData.fromJson(v));
      });
    }
  }
}

class GatewayMethodsData {
  int? id;
  String? name;
  String? formattedName;
  String? gatewayCode;
  String? type;
  String? currency;
  String? symbol;
  int? currencyDecimals;
  String? minimumDeposit;
  String? maximumDeposit;
  String? instructions;
  String? charge;
  String? chargeType;
  String? currencyType;
  String? conversionRate;
  int? status;
  String? image;
  List<FieldOptions>? fieldOptions;
  String? fieldName;
  String? details;
  String? createdAt;
  String? updatedAt;

  GatewayMethodsData({
    this.id,
    this.name,
    this.formattedName,
    this.gatewayCode,
    this.type,
    this.currency,
    this.symbol,
    this.currencyDecimals,
    this.minimumDeposit,
    this.maximumDeposit,
    this.instructions,
    this.charge,
    this.chargeType,
    this.currencyType,
    this.conversionRate,
    this.status,
    this.image,
    this.fieldOptions,
    this.fieldName,
    this.details,
    this.createdAt,
    this.updatedAt,
  });

  GatewayMethodsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    formattedName = json['formatted_name'];
    gatewayCode = json['gateway_code'];
    type = json['type'];
    currency = json['currency'];
    symbol = json['symbol'];
    currencyDecimals = json['currency_decimals'];
    minimumDeposit = json['minimum_deposit'];
    maximumDeposit = json['maximum_deposit'];
    instructions = json['instructions'];
    charge = json['charge'];
    chargeType = json['charge_type'];
    currencyType = json['currency_type'];
    conversionRate = json['conversion_rate'];
    status = json['status'];
    image = json['image'];
    if (json['field_options'] != null) {
      fieldOptions = <FieldOptions>[];
      json['field_options'].forEach((v) {
        fieldOptions!.add(FieldOptions.fromJson(v));
      });
    }
    fieldName = json['field_name'];
    details = json['details'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}

class FieldOptions {
  String? name;
  String? type;
  String? validation;

  FieldOptions({this.name, this.type, this.validation});

  FieldOptions.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    type = json['type'];
    validation = json['validation'];
  }
}
