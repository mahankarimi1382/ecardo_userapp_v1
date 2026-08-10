class GiftCardProductModel {
  String? status;
  String? message;
  GiftCardProductData? data;

  GiftCardProductModel({this.status, this.message, this.data});

  GiftCardProductModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? GiftCardProductData.fromJson(json['data'])
        : null;
  }
}

class GiftCardProductData {
  List<Content>? content;
  Pageable? pageable;
  int? totalElements;
  int? totalPages;
  bool? last;
  bool? first;
  Sort? sort;
  int? numberOfElements;
  int? size;
  int? number;
  bool? empty;

  GiftCardProductData({
    this.content,
    this.pageable,
    this.totalElements,
    this.totalPages,
    this.last,
    this.first,
    this.sort,
    this.numberOfElements,
    this.size,
    this.number,
    this.empty,
  });

  GiftCardProductData.fromJson(Map<String, dynamic> json) {
    if (json['content'] != null) {
      content = <Content>[];
      json['content'].forEach((v) {
        content!.add(Content.fromJson(v));
      });
    }
    pageable = json['pageable'] != null
        ? Pageable.fromJson(json['pageable'])
        : null;
    totalElements = json['totalElements'];
    totalPages = json['totalPages'];
    last = json['last'];
    first = json['first'];
    sort = json['sort'] != null ? Sort.fromJson(json['sort']) : null;
    numberOfElements = json['numberOfElements'];
    size = json['size'];
    number = json['number'];
    empty = json['empty'];
  }
}

class Content {
  int? productId;
  String? productName;
  bool? global;
  String? status;
  bool? supportsPreOrder;
  double? senderFee;
  double? senderFeePercentage;
  double? discountPercentage;
  String? denominationType;
  String? recipientCurrencyCode;
  double? minRecipientDenomination;
  double? maxRecipientDenomination;
  String? senderCurrencyCode;
  double? minSenderDenomination;
  double? maxSenderDenomination;
  List<double>? fixedRecipientDenominations;
  List<double>? fixedSenderDenominations;
  Map<String, dynamic>? fixedRecipientToSenderDenominationsMap;
  List<Null>? metadata;
  List<String>? logoUrls;
  Brand? brand;
  Category? category;
  Country? country;
  RedeemInstruction? redeemInstruction;
  AdditionalRequirements? additionalRequirements;
  double? recipientCurrencyToSenderCurrencyExchangeRate;

  Content({
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
  });

  Content.fromJson(Map<String, dynamic> json) {
    productId = json['productId'];
    productName = json['productName'];
    global = json['global'];
    status = json['status'];
    supportsPreOrder = json['supportsPreOrder'];
    senderFee = (json['senderFee'] as num?)?.toDouble();

    senderFeePercentage = (json['senderFeePercentage'] as num?)?.toDouble();

    discountPercentage = (json['discountPercentage'] as num?)?.toDouble();
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
        ?.map((e) => (e as num).toDouble())
        .toList();

    fixedSenderDenominations = (json['fixedSenderDenominations'] as List?)
        ?.map((e) => (e as num).toDouble())
        .toList();

    fixedRecipientToSenderDenominationsMap =
        json['fixedRecipientToSenderDenominationsMap'];

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

class Pageable {
  Sort? sort;
  int? pageNumber;
  int? pageSize;
  int? offset;
  bool? unpaged;
  bool? paged;

  Pageable({
    this.sort,
    this.pageNumber,
    this.pageSize,
    this.offset,
    this.unpaged,
    this.paged,
  });

  Pageable.fromJson(Map<String, dynamic> json) {
    sort = json['sort'] != null ? Sort.fromJson(json['sort']) : null;
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    offset = json['offset'];
    unpaged = json['unpaged'];
    paged = json['paged'];
  }
}

class Sort {
  bool? sorted;
  bool? unsorted;
  bool? empty;

  Sort({this.sorted, this.unsorted, this.empty});

  Sort.fromJson(Map<String, dynamic> json) {
    sorted = json['sorted'];
    unsorted = json['unsorted'];
    empty = json['empty'];
  }
}
