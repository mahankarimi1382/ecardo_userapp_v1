class GiftCardProductDetailsModel {
  String? status;
  String? message;
  GiftCardProductDetailsData? data;

  GiftCardProductDetailsModel({this.status, this.message, this.data});

  GiftCardProductDetailsModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? GiftCardProductDetailsData.fromJson(json['data'])
        : null;
  }
}

class GiftCardProductDetailsData {
  int? productId;
  String? productName;
  bool? global;
  String? status;
  bool? supportsPreOrder;

  int? senderFee;
  double? senderFeePercentage;
  int? discountPercentage;

  String? denominationType;
  String? recipientCurrencyCode;

  double? minRecipientDenomination;
  double? maxRecipientDenomination;

  String? senderCurrencyCode;
  double? minSenderDenomination;
  double? maxSenderDenomination;

  List<int>? fixedRecipientDenominations;
  List<double>? fixedSenderDenominations;

  FixedRecipientToSenderDenominationsMap?
  fixedRecipientToSenderDenominationsMap;

  List<dynamic>? metadata;
  List<String>? logoUrls;

  Brand? brand;
  Category? category;
  Country? country;
  RedeemInstruction? redeemInstruction;
  AdditionalRequirements? additionalRequirements;

  double? recipientCurrencyToSenderCurrencyExchangeRate;
  int? orderCharge;

  GiftCardProductDetailsData({
    this.productId,
    this.productName,
    this.global,
    this.status,
    this.supportsPreOrder,
    this.senderFee,
    this.senderFeePercentage,
    this.discountPercentage,
    this.denominationType,
    this.recipientCurrencyCode,
    this.minRecipientDenomination,
    this.maxRecipientDenomination,
    this.senderCurrencyCode,
    this.minSenderDenomination,
    this.maxSenderDenomination,
    this.fixedRecipientDenominations,
    this.fixedSenderDenominations,
    this.fixedRecipientToSenderDenominationsMap,
    this.metadata,
    this.logoUrls,
    this.brand,
    this.category,
    this.country,
    this.redeemInstruction,
    this.additionalRequirements,
    this.recipientCurrencyToSenderCurrencyExchangeRate,
    this.orderCharge,
  });

  GiftCardProductDetailsData.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    global = json['global'];
    status = json['status'];
    supportsPreOrder = json['supportsPreOrder'];

    senderFee = json['senderFee'];
    senderFeePercentage = (json['senderFeePercentage'] as num?)?.toDouble();

    discountPercentage = json['discountPercentage'];
    denominationType = json['denominationType'];
    recipientCurrencyCode = json['recipientCurrencyCode'];

    minRecipientDenomination = (json['minRecipientDenomination'] as num?)
        ?.toDouble();
    maxRecipientDenomination = (json['maxRecipientDenomination'] as num?)
        ?.toDouble();

    senderCurrencyCode = json['senderCurrencyCode'];
    minSenderDenomination = (json['minSenderDenomination'] as num?)?.toDouble();
    maxSenderDenomination = (json['maxSenderDenomination'] as num?)?.toDouble();

    fixedRecipientDenominations = (json['fixedRecipientDenominations'] as List?)
        ?.map((e) => e as int)
        .toList();

    fixedSenderDenominations = (json['fixedSenderDenominations'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList();

    fixedRecipientToSenderDenominationsMap =
        json['fixedRecipientToSenderDenominationsMap'] != null
        ? FixedRecipientToSenderDenominationsMap.fromJson(
            json['fixedRecipientToSenderDenominationsMap'],
          )
        : null;

    metadata = json['metadata'] as List<dynamic>?;

    logoUrls = (json['logoUrls'] as List?)?.map((e) => e.toString()).toList();

    brand = json['brand'] != null ? Brand.fromJson(json['brand']) : null;
    category = json['category'] != null
        ? Category.fromJson(json['category'])
        : null;
    country = json['country'] != null
        ? Country.fromJson(json['country'])
        : null;

    redeemInstruction = json['redeemInstruction'] != null
        ? RedeemInstruction.fromJson(json['redeemInstruction'])
        : null;

    additionalRequirements = json['additionalRequirements'] != null
        ? AdditionalRequirements.fromJson(json['additionalRequirements'])
        : null;

    recipientCurrencyToSenderCurrencyExchangeRate =
        (json['recipientCurrencyToSenderCurrencyExchangeRate'] as num?)
            ?.toDouble();

    orderCharge = json['order_charge'];
  }
}

class FixedRecipientToSenderDenominationsMap {
  double? d6000;
  double? d8000;
  double? d12000;

  FixedRecipientToSenderDenominationsMap({this.d6000, this.d8000, this.d12000});

  FixedRecipientToSenderDenominationsMap.fromJson(Map<String, dynamic> json) {
    d6000 = (json['60.00'] as num?)?.toDouble();
    d8000 = (json['80.00'] as num?)?.toDouble();
    d12000 = (json['120.00'] as num?)?.toDouble();
  }
}

class Brand {
  int? brandId;
  String? brandName;
  String? logoUrl;

  Brand({this.brandId, this.brandName, this.logoUrl});

  Brand.fromJson(Map<String, dynamic> json) {
    brandId = json['brandId'];
    brandName = json['brandName'];
    logoUrl = json['logoUrl'];
  }
}

class Category {
  int? id;
  String? name;

  Category({this.id, this.name});

  Category.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }
}

class Country {
  String? isoName;
  String? name;
  String? flagUrl;

  Country({this.isoName, this.name, this.flagUrl});

  Country.fromJson(Map<String, dynamic> json) {
    isoName = json['isoName'];
    name = json['name'];
    flagUrl = json['flagUrl'];
  }
}

class RedeemInstruction {
  String? concise;
  String? verbose;

  RedeemInstruction({this.concise, this.verbose});

  RedeemInstruction.fromJson(Map<String, dynamic> json) {
    concise = json['concise'];
    verbose = json['verbose'];
  }
}

class AdditionalRequirements {
  bool? userIdRequired;

  AdditionalRequirements({this.userIdRequired});

  AdditionalRequirements.fromJson(Map<String, dynamic> json) {
    userIdRequired = json['userIdRequired'];
  }
}
