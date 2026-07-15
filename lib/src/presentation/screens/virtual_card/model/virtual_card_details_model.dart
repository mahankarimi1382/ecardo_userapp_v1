class VirtualCardDetailsModel {
  String? status;
  String? message;
  VirtualCardDetailsData? data;

  VirtualCardDetailsModel({this.status, this.message, this.data});

  VirtualCardDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? VirtualCardDetailsData.fromJson(json['data'])
        : null;
  }
}

class VirtualCardDetailsData {
  int? id;
  int? userId;
  int? cardHolderId;
  String? cardId;
  String? currency;
  String? type;
  String? status;
  String? lifecycleStatus;
  String? virtualStatus;
  String? physicalStatus;
  String? amount;
  String? provider;
  String? cardNumber;
  String? displayNumber;
  String? cvc;
  int? expirationMonth;
  int? expirationYear;
  String? lastFourDigits;
  String? createdAt;
  String? updatedAt;
  CardHolder? cardHolder;
  CardDisplay? display;
  CardCapabilities? capabilities;
  CardFunding? funding;
  CardActions? actions;

  VirtualCardDetailsData({
    this.id,
    this.userId,
    this.cardHolderId,
    this.cardId,
    this.currency,
    this.type,
    this.status,
    this.lifecycleStatus,
    this.virtualStatus,
    this.physicalStatus,
    this.amount,
    this.provider,
    this.cardNumber,
    this.displayNumber,
    this.cvc,
    this.expirationMonth,
    this.expirationYear,
    this.lastFourDigits,
    this.createdAt,
    this.updatedAt,
    this.cardHolder,
    this.display,
    this.capabilities,
    this.funding,
    this.actions,
  });

  VirtualCardDetailsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    cardHolderId = json['card_holder_id'];
    cardId = json['card_id'];
    currency = json['currency'];
    type = json['type'];
    status = json['status'];
    lifecycleStatus = json['lifecycle_status']?.toString();
    virtualStatus = json['virtual_status']?.toString();
    physicalStatus = json['physical_status']?.toString();
    amount = json['amount']?.toString();
    provider = json['provider']?.toString();
    cardNumber = json['card_number']?.toString();
    displayNumber = json['display_number']?.toString();
    cvc = json['cvc']?.toString();
    expirationMonth =
        num.tryParse(json['expiration_month']?.toString() ?? '')?.toInt();
    expirationYear =
        num.tryParse(json['expiration_year']?.toString() ?? '')?.toInt();
    lastFourDigits = json['last_four_digits'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cardHolder = json['card_holder'] != null
        ? CardHolder.fromJson(json['card_holder'])
        : null;
    display = json['display'] is Map
        ? CardDisplay.fromJson(
            (json['display'] as Map).cast<String, dynamic>(),
          )
        : null;
    capabilities = json['capabilities'] is Map
        ? CardCapabilities.fromJson(
            (json['capabilities'] as Map).cast<String, dynamic>(),
          )
        : null;
    funding = json['funding'] is Map
        ? CardFunding.fromJson(
            (json['funding'] as Map).cast<String, dynamic>(),
          )
        : null;
    actions = json['actions'] is Map
        ? CardActions.fromJson(
            (json['actions'] as Map).cast<String, dynamic>(),
          )
        : null;
  }
}

class CardDisplay {
  String? title;
  String? subtitle;
  String? balanceLabel;
  String? numberLabel;
  String? expiryLabel;
  String? cvcLabel;
  String? currencyLabel;
  String? primaryColor;
  String? secondaryColor;
  String? backgroundImage;
  String? brandImage;
  String? network;
  int currencyDecimals = 2;
  bool showPan = false;
  bool showExpiry = false;
  bool showCvc = false;

  CardDisplay.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    subtitle = json['subtitle']?.toString();
    balanceLabel = json['balance_label']?.toString();
    numberLabel = json['number_label']?.toString();
    expiryLabel = json['expiry_label']?.toString();
    cvcLabel = json['cvc_label']?.toString();
    currencyLabel = json['currency_label']?.toString();
    primaryColor = json['primary_color']?.toString();
    secondaryColor = json['secondary_color']?.toString();
    backgroundImage = json['background_image']?.toString();
    brandImage = json['brand_image']?.toString();
    network = json['network']?.toString();
    currencyDecimals =
        num.tryParse(json['currency_decimals']?.toString() ?? '')?.toInt() ?? 2;
    showPan = json['show_pan'] == true;
    showExpiry = json['show_expiry'] == true;
    showCvc = json['show_cvc'] == true;
  }
}

class CardCapabilities {
  bool canTopup = false;
  bool canFreeze = false;
  bool canViewTransactions = false;
  bool canRequestPhysical = false;
  bool canRevealPan = false;

  CardCapabilities.fromJson(Map<String, dynamic> json) {
    canTopup = json['can_topup'] == true;
    canFreeze = json['can_freeze'] == true;
    canViewTransactions = json['can_view_transactions'] == true;
    canRequestPhysical = json['can_request_physical'] == true;
    canRevealPan = json['can_reveal_pan'] == true;
  }
}

class CardFunding {
  String? mode;
  String? defaultSource;
  int? defaultGatewayMethodId;
  int minimumTopup = 0;
  int maximumTopup = 0;
  String? topupFeeType;
  num topupFee = 0;
  List<CardGateway> gateways = [];

  CardFunding.fromJson(Map<String, dynamic> json) {
    mode = json['mode']?.toString();
    defaultSource = json['default_source']?.toString();
    defaultGatewayMethodId =
        num.tryParse(json['default_gateway_method_id']?.toString() ?? '')
            ?.toInt();
    minimumTopup =
        num.tryParse(json['minimum_topup']?.toString() ?? '')?.toInt() ?? 0;
    maximumTopup =
        num.tryParse(json['maximum_topup']?.toString() ?? '')?.toInt() ?? 0;
    topupFeeType = json['topup_fee_type']?.toString();
    topupFee = num.tryParse(json['topup_fee']?.toString() ?? '') ?? 0;
    final items = json['gateways'];
    if (items is List) {
      gateways = items
          .whereType<Map>()
          .map((item) => CardGateway.fromJson(item.cast<String, dynamic>()))
          .toList();
    }
  }
}

class CardGateway {
  int? id;
  String? name;
  String? gatewayCode;

  CardGateway.fromJson(Map<String, dynamic> json) {
    id = num.tryParse(json['id']?.toString() ?? '')?.toInt();
    name = json['name']?.toString();
    gatewayCode = json['gateway_code']?.toString();
  }
}

class CardActions {
  String? topupEndpoint;
  String? statusEndpoint;
  String? transactionsEndpoint;

  CardActions.fromJson(Map<String, dynamic> json) {
    topupEndpoint = json['topup_endpoint']?.toString();
    statusEndpoint = json['status_endpoint']?.toString();
    transactionsEndpoint = json['transactions_endpoint']?.toString();
  }
}

class CardHolder {
  int? id;
  int? userId;
  String? cardHolderId;
  String? provider;
  String? name;
  String? email;
  String? phoneNumber;
  String? status;
  String? type;
  String? address;
  String? country;
  String? city;
  String? state;
  String? postalCode;
  String? createdAt;
  String? updatedAt;

  CardHolder({
    this.id,
    this.userId,
    this.cardHolderId,
    this.provider,
    this.name,
    this.email,
    this.phoneNumber,
    this.status,
    this.type,
    this.address,
    this.country,
    this.city,
    this.state,
    this.postalCode,
    this.createdAt,
    this.updatedAt,
  });

  CardHolder.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    cardHolderId = json['card_holder_id'];
    provider = json['provider'];
    name = json['name'];
    email = json['email'];
    phoneNumber = json['phone_number'];
    status = json['status'];
    type = json['type'];
    address = json['address'];
    country = json['country'];
    city = json['city'];
    state = json['state'];
    postalCode = json['postal_code'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
}
