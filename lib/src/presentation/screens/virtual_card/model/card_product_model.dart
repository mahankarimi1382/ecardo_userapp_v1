class CardProductModel {
  String? status;
  String? message;
  List<CardProductData> data = [];

  CardProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status']?.toString();
    message = json['message']?.toString();
    final items = json['data'];
    if (items is List) {
      data = items
          .whereType<Map>()
          .map((item) => CardProductData.fromJson(item.cast<String, dynamic>()))
          .toList();
    }
  }
}

class CardProductData {
  int? id;
  String? name;
  String? code;
  String? currency;
  String? fundingMode;
  CardIssuerData? issuer;
  int minimumInitialLoad = 0;
  int maximumInitialLoad = 0;
  int minimumTopup = 0;
  int maximumTopup = 0;
  num creationFee = 0;
  String? topupFeeType;
  num topupFee = 0;
  num physicalCardFee = 0;
  int maximumCardsPerUser = 0;
  bool kycRequired = false;
  String? image;
  String? terms;
  String? maintenanceMessage;
  List<CardApplicationField> applicationFields = [];
  List<CardGatewayData> gateways = [];
  CardProductCapabilities? capabilities;

  CardProductData.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = json['name']?.toString();
    code = json['code']?.toString();
    currency = json['currency']?.toString();
    fundingMode = json['funding_mode']?.toString();
    final issuerData = json['issuer'];
    if (issuerData is Map) {
      issuer = CardIssuerData.fromJson(issuerData.cast<String, dynamic>());
    }
    minimumInitialLoad = _asInt(json['minimum_initial_load']) ?? 0;
    maximumInitialLoad = _asInt(json['maximum_initial_load']) ?? 0;
    minimumTopup = _asInt(json['minimum_topup']) ?? 0;
    maximumTopup = _asInt(json['maximum_topup']) ?? 0;
    creationFee = _asNum(json['creation_fee']);
    topupFeeType = json['topup_fee_type']?.toString();
    topupFee = _asNum(json['topup_fee']);
    physicalCardFee = _asNum(json['physical_card_fee']);
    maximumCardsPerUser = _asInt(json['maximum_cards_per_user']) ?? 0;
    kycRequired = json['kyc_required'] == true;
    image = json['image']?.toString();
    terms = json['terms']?.toString();
    maintenanceMessage = json['maintenance_message']?.toString();

    final fields = json['application_fields'];
    if (fields is List) {
      applicationFields = fields
          .whereType<Map>()
          .map(
            (field) =>
                CardApplicationField.fromJson(field.cast<String, dynamic>()),
          )
          .toList();
    }

    final gatewayItems = json['gateways'];
    if (gatewayItems is List) {
      gateways = gatewayItems
          .whereType<Map>()
          .map(
            (gateway) =>
                CardGatewayData.fromJson(gateway.cast<String, dynamic>()),
          )
          .toList();
    }

    final capabilityData = json['capabilities'];
    if (capabilityData is Map) {
      capabilities = CardProductCapabilities.fromJson(
        capabilityData.cast<String, dynamic>(),
      );
    }
  }
}

class CardIssuerData {
  int? id;
  String? name;
  String? code;
  String? countryCode;
  String? currency;
  String? providerType;
  String? network;
  String? disclosure;
  Map<String, dynamic> capabilities = {};

  CardIssuerData.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = json['name']?.toString();
    code = json['code']?.toString();
    countryCode = json['country_code']?.toString();
    currency = json['currency']?.toString();
    providerType = json['provider_type']?.toString();
    network = json['network']?.toString();
    disclosure = json['disclosure']?.toString();
    final capabilityData = json['capabilities'];
    if (capabilityData is Map) {
      capabilities = capabilityData.cast<String, dynamic>();
    }
  }

  bool get isExternallyUsable => capabilities['external_payments'] == true;
}

class CardApplicationField {
  String name = '';
  String label = '';
  String type = 'text';
  bool required = false;

  CardApplicationField.fromJson(Map<String, dynamic> json) {
    name = json['name']?.toString() ?? '';
    label = json['label']?.toString() ?? name;
    type = json['type']?.toString().toLowerCase() ?? 'text';
    required = json['required'] == true;
  }
}

class CardGatewayData {
  int? id;
  String? name;
  String? gatewayCode;
  num charge = 0;
  String? chargeType;
  int minimumDeposit = 0;
  int maximumDeposit = 0;
  String? currency;

  CardGatewayData.fromJson(Map<String, dynamic> json) {
    id = _asInt(json['id']);
    name = json['name']?.toString();
    gatewayCode = json['gateway_code']?.toString();
    charge = _asNum(json['charge']);
    chargeType = json['charge_type']?.toString();
    minimumDeposit = _asInt(json['minimum_deposit']) ?? 0;
    maximumDeposit = _asInt(json['maximum_deposit']) ?? 0;
    currency = json['currency']?.toString();
  }
}

class CardProductCapabilities {
  bool canCreateVirtual = false;
  bool canRequestPhysical = false;
  bool canFundFromIrrWallet = false;
  bool canFundFromGateway = false;

  CardProductCapabilities.fromJson(Map<String, dynamic> json) {
    canCreateVirtual = json['can_create_virtual'] == true;
    canRequestPhysical = json['can_request_physical'] == true;
    canFundFromIrrWallet = json['can_fund_from_irr_wallet'] == true;
    canFundFromGateway = json['can_fund_from_gateway'] == true;
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return num.tryParse(value?.toString() ?? '')?.toInt();
}

num _asNum(dynamic value) {
  if (value is num) return value;
  return num.tryParse(value?.toString() ?? '') ?? 0;
}
