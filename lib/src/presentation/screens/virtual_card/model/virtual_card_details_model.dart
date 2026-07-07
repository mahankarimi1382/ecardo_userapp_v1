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
  String? amount;
  String? provider;
  String? cardNumber;
  String? cvc;
  int? expirationMonth;
  int? expirationYear;
  String? lastFourDigits;
  String? createdAt;
  String? updatedAt;
  CardHolder? cardHolder;

  VirtualCardDetailsData({
    this.id,
    this.userId,
    this.cardHolderId,
    this.cardId,
    this.currency,
    this.type,
    this.status,
    this.amount,
    this.provider,
    this.cardNumber,
    this.cvc,
    this.expirationMonth,
    this.expirationYear,
    this.lastFourDigits,
    this.createdAt,
    this.updatedAt,
    this.cardHolder,
  });

  VirtualCardDetailsData.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    userId = json['user_id'];
    cardHolderId = json['card_holder_id'];
    cardId = json['card_id'];
    currency = json['currency'];
    type = json['type'];
    status = json['status'];
    amount = json['amount'];
    provider = json['provider'];
    cardNumber = json['card_number'];
    cvc = json['cvc'];
    expirationMonth = json['expiration_month'];
    expirationYear = json['expiration_year'];
    lastFourDigits = json['last_four_digits'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    cardHolder = json['card_holder'] != null
        ? CardHolder.fromJson(json['card_holder'])
        : null;
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
