class GiftCardHistoryModel {
  String? status;
  String? message;
  GiftCardHistoryData? data;

  GiftCardHistoryModel({this.status, this.message, this.data});

  GiftCardHistoryModel.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    message = json['message'];
    data = json['data'] != null
        ? GiftCardHistoryData.fromJson(json['data'])
        : null;
  }
}

class GiftCardHistoryData {
  List<GiftCards>? giftCards;
  Meta? meta;

  GiftCardHistoryData({this.giftCards, this.meta});

  GiftCardHistoryData.fromJson(Map<String, dynamic> json) {
    if (json['gift_cards'] != null) {
      giftCards = <GiftCards>[];
      json['gift_cards'].forEach((v) {
        giftCards!.add(GiftCards.fromJson(v));
      });
    }
    meta = json['meta'] != null ? Meta.fromJson(json['meta']) : null;
  }
}

class GiftCards {
  int? id;
  String? productName;
  String? productThumbnail;
  String? senderName;
  String? recipientEmail;
  String? recipientPhoneNumber;
  String? transactionId;
  String? unitPrice;
  int? quantity;
  String? totalPrice;
  String? createdAt;

  GiftCards({
    this.id,
    this.productName,
    this.productThumbnail,
    this.senderName,
    this.recipientEmail,
    this.recipientPhoneNumber,
    this.transactionId,
    this.unitPrice,
    this.quantity,
    this.totalPrice,
    this.createdAt,
  });

  GiftCards.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    productName = json['product_name'];
    productThumbnail = json['product_thumbnail'];
    senderName = json['sender_name'];
    recipientEmail = json['recipient_email'];
    recipientPhoneNumber = json['recipient_phone_number'];
    transactionId = json['transaction_id'];
    unitPrice = json['unit_price'];
    quantity = json['quantity'];
    totalPrice = json['total_price'];
    createdAt = json['created_at'];
  }
}

class Meta {
  int? currentPage;
  int? lastPage;
  int? perPage;
  int? total;

  Meta({this.currentPage, this.lastPage, this.perPage, this.total});

  Meta.fromJson(Map<String, dynamic> json) {
    currentPage = json['current_page'];
    lastPage = json['last_page'];
    perPage = json['per_page'];
    total = json['total'];
  }
}
