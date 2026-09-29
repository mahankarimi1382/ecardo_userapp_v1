class EscrowPartyModel {
  final int id;
  final String name;
  final String? email;
  final String? accountNumber;

  const EscrowPartyModel({
    required this.id,
    required this.name,
    this.email,
    this.accountNumber,
  });

  factory EscrowPartyModel.fromJson(Map<String, dynamic> json) {
    return EscrowPartyModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? 'کاربر ای‌کاردو',
      email: json['email']?.toString(),
      accountNumber: json['account_number']?.toString(),
    );
  }
}

class EscrowEventModel {
  final int id;
  final String actorRole;
  final String? fromStatus;
  final String toStatus;
  final String action;
  final String? reason;
  final DateTime? createdAt;

  const EscrowEventModel({
    required this.id,
    required this.actorRole,
    this.fromStatus,
    required this.toStatus,
    required this.action,
    this.reason,
    this.createdAt,
  });

  factory EscrowEventModel.fromJson(Map<String, dynamic> json) {
    return EscrowEventModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      actorRole: json['actor_role']?.toString() ?? 'SYSTEM',
      fromStatus: json['from_status']?.toString(),
      toStatus: json['to_status']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      reason: json['reason']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class EscrowDisputeModel {
  final int id;
  final String caseNumber;
  final String type;
  final String description;
  final String status;
  final String? resolution;
  final DateTime? createdAt;

  const EscrowDisputeModel({
    required this.id,
    required this.caseNumber,
    required this.type,
    required this.description,
    required this.status,
    this.resolution,
    this.createdAt,
  });

  factory EscrowDisputeModel.fromJson(Map<String, dynamic> json) {
    return EscrowDisputeModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      caseNumber: json['case_number']?.toString() ?? ('DSP-' + json['id'].toString()),
      type: json['type']?.toString() ?? 'مغایرت کالا',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      resolution: json['resolution']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}

class EscrowOrderModel {
  final int id;
  final String contractNo;
  final String creatorRole; // BUYER or SELLER
  final EscrowPartyModel? buyer;
  final EscrowPartyModel? seller;
  final String title;
  final String description;
  final double quantity;
  final String unit;
  final double amount;
  final String currency;
  final double feeAmount;
  final String feePayer;
  final double shippingCost;
  final String shippingPayer;
  final double totalEscrowAmount;
  final String status; // DRAFT, AWAITING_AGREEMENT, AWAITING_PAYMENT, FUNDS_HELD, IN_DELIVERY, DELIVERED, RELEASED, COMPLETED, DISPUTED, REFUNDED, CANCELLED, EXPIRED
  final String statusLabel;
  final int revisionCount;
  final DateTime? shipDeadline;
  final int inspectionHours;
  final DateTime? inspectionDeadline;
  final String? shippingCompany;
  final String? trackingNumber;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final DateTime? releasedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final EscrowDisputeModel? dispute;
  final List<EscrowEventModel> events;
  final int? buyerRating;
  final String? buyerComment;
  final int? sellerRating;
  final String? sellerComment;
  final DateTime? createdAt;

  const EscrowOrderModel({
    required this.id,
    required this.contractNo,
    required this.creatorRole,
    this.buyer,
    this.seller,
    required this.title,
    required this.description,
    required this.quantity,
    this.unit = 'عدد',
    required this.amount,
    this.currency = 'IRR',
    this.feeAmount = 0.0,
    this.feePayer = 'BUYER',
    this.shippingCost = 0.0,
    this.shippingPayer = 'BUYER',
    required this.totalEscrowAmount,
    required this.status,
    required this.statusLabel,
    this.revisionCount = 0,
    this.shipDeadline,
    this.inspectionHours = 72,
    this.inspectionDeadline,
    this.shippingCompany,
    this.trackingNumber,
    this.shippedAt,
    this.deliveredAt,
    this.releasedAt,
    this.completedAt,
    this.cancelledAt,
    this.dispute,
    this.events = const [],
    this.buyerRating,
    this.buyerComment,
    this.sellerRating,
    this.sellerComment,
    this.createdAt,
  });

  factory EscrowOrderModel.fromJson(Map<String, dynamic> json) {
    return EscrowOrderModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '') ?? 0,
      contractNo: json['contract_no']?.toString() ?? ('ESC-' + json['id'].toString()),
      creatorRole: json['creator_role']?.toString() ?? 'BUYER',
      buyer: json['buyer'] is Map ? EscrowPartyModel.fromJson(Map<String, dynamic>.from(json['buyer'])) : null,
      seller: json['seller'] is Map ? EscrowPartyModel.fromJson(Map<String, dynamic>.from(json['seller'])) : null,
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : double.tryParse(json['quantity']?.toString() ?? '') ?? 1.0,
      unit: json['unit']?.toString() ?? 'عدد',
      amount: (json['amount'] is num) ? (json['amount'] as num).toDouble() : double.tryParse(json['amount']?.toString() ?? '') ?? 0.0,
      currency: json['currency']?.toString() ?? 'IRR',
      feeAmount: (json['fee_amount'] is num) ? (json['fee_amount'] as num).toDouble() : double.tryParse(json['fee_amount']?.toString() ?? '') ?? 0.0,
      feePayer: json['fee_payer']?.toString() ?? 'BUYER',
      shippingCost: (json['shipping_cost'] is num) ? (json['shipping_cost'] as num).toDouble() : double.tryParse(json['shipping_cost']?.toString() ?? '') ?? 0.0,
      shippingPayer: json['shipping_payer']?.toString() ?? 'BUYER',
      totalEscrowAmount: (json['total_escrow_amount'] is num) ? (json['total_escrow_amount'] as num).toDouble() : double.tryParse(json['total_escrow_amount']?.toString() ?? '') ?? 0.0,
      status: json['status']?.toString() ?? 'DRAFT',
      statusLabel: json['status_label']?.toString() ?? 'پیش‌نویس',
      revisionCount: (json['revision_count'] is num) ? (json['revision_count'] as num).toInt() : 0,
      shipDeadline: json['ship_deadline'] != null ? DateTime.tryParse(json['ship_deadline'].toString()) : null,
      inspectionHours: (json['inspection_hours'] is num) ? (json['inspection_hours'] as num).toInt() : 72,
      inspectionDeadline: json['inspection_deadline'] != null ? DateTime.tryParse(json['inspection_deadline'].toString()) : null,
      shippingCompany: json['shipping_company']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      shippedAt: json['shipped_at'] != null ? DateTime.tryParse(json['shipped_at'].toString()) : null,
      deliveredAt: json['delivered_at'] != null ? DateTime.tryParse(json['delivered_at'].toString()) : null,
      releasedAt: json['released_at'] != null ? DateTime.tryParse(json['released_at'].toString()) : null,
      completedAt: json['completed_at'] != null ? DateTime.tryParse(json['completed_at'].toString()) : null,
      cancelledAt: json['cancelled_at'] != null ? DateTime.tryParse(json['cancelled_at'].toString()) : null,
      dispute: json['dispute'] is Map ? EscrowDisputeModel.fromJson(Map<String, dynamic>.from(json['dispute'])) : null,
      events: (json['events'] is List)
          ? (json['events'] as List).map((e) => EscrowEventModel.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      buyerRating: json['buyer_rating'] is int ? json['buyer_rating'] : null,
      buyerComment: json['buyer_comment']?.toString(),
      sellerRating: json['seller_rating'] is int ? json['seller_rating'] : null,
      sellerComment: json['seller_comment']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}