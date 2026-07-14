class VirtualCardsModel {
  String? status;
  String? message;
  List<VirtualCardsData>? data;

  VirtualCardsModel({this.status, this.message, this.data});

  VirtualCardsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    if (json['data'] != null) {
      data = <VirtualCardsData>[];
      json['data'].forEach((v) {
        data!.add(VirtualCardsData.fromJson(v));
      });
    }
  }
}

class VirtualCardsData {
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
  CardActions? actions;

  VirtualCardsData({
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
    this.actions,
  });

  VirtualCardsData.fromJson(Map<String, dynamic> json) {
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
    amount = json['amount'];
    provider = json['provider'];
    cardNumber = json['card_number'];
    displayNumber = json['display_number']?.toString();
    cvc = json['cvc'];
    expirationMonth = json['expiration_month'];
    expirationYear = json['expiration_year'];
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
  int currencyDecimals = 2;
  bool showPan = false;
  bool showExpiry = false;
  bool showCvc = false;

  CardDisplay.fromJson(Map<String, dynamic> json) {
    title = json['title']?.toString();
    subtitle = json['subtitle']?.toString();
    balanceLabel = json['balance_label']?.toString();
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
