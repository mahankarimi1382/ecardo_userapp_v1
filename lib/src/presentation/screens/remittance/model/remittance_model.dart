// Remittance Models — v1.0.4+5
// Models for the international remittance (حواله بین‌المللی) module
// Aligned with backend RemittanceService v3.8

/// Status of a remittance request.
/// Mirrors App\Enums\RemittanceStatus on the backend (14 cases).
enum RemittanceStatus {
  draft,
  waitingInformation,
  waitingDocuments,
  waitingPayment,
  paymentReviewing,
  inProcess,
  destinationProcessing,
  destinationPaid,
  completed,
  rejected,
  expired,
  cancelled,
  refundRequested,
  refundCompleted,
  unknown;

  static RemittanceStatus fromString(String? value) {
    if (value == null) return RemittanceStatus.unknown;
    // Backend sends the enum name (camelCase) or the int value
    switch (value.toLowerCase()) {
      case 'draft':
      case '0':
        return RemittanceStatus.draft;
      case 'waitinginformation':
      case '1':
        return RemittanceStatus.waitingInformation;
      case 'waitingdocuments':
      case '2':
        return RemittanceStatus.waitingDocuments;
      case 'waitingpayment':
      case '3':
        return RemittanceStatus.waitingPayment;
      case 'paymentreviewing':
      case '4':
        return RemittanceStatus.paymentReviewing;
      case 'inprocess':
      case '5':
        return RemittanceStatus.inProcess;
      case 'destinationprocessing':
      case '6':
        return RemittanceStatus.destinationProcessing;
      case 'destinationpaid':
      case '7':
        return RemittanceStatus.destinationPaid;
      case 'completed':
      case '8':
        return RemittanceStatus.completed;
      case 'rejected':
      case '9':
        return RemittanceStatus.rejected;
      case 'expired':
      case '10':
        return RemittanceStatus.expired;
      case 'cancelled':
      case '11':
        return RemittanceStatus.cancelled;
      case 'refundrequested':
      case '12':
        return RemittanceStatus.refundRequested;
      case 'refundcompleted':
      case '13':
        return RemittanceStatus.refundCompleted;
      default:
        return RemittanceStatus.unknown;
    }
  }

  String get label {
    switch (this) {
      case RemittanceStatus.draft:
        return 'Draft';
      case RemittanceStatus.waitingInformation:
        return 'Waiting Information';
      case RemittanceStatus.waitingDocuments:
        return 'Waiting Documents';
      case RemittanceStatus.waitingPayment:
        return 'Waiting Payment';
      case RemittanceStatus.paymentReviewing:
        return 'Payment Reviewing';
      case RemittanceStatus.inProcess:
        return 'In Process';
      case RemittanceStatus.destinationProcessing:
        return 'Destination Processing';
      case RemittanceStatus.destinationPaid:
        return 'Destination Paid';
      case RemittanceStatus.completed:
        return 'Completed';
      case RemittanceStatus.rejected:
        return 'Rejected';
      case RemittanceStatus.expired:
        return 'Expired';
      case RemittanceStatus.cancelled:
        return 'Cancelled';
      case RemittanceStatus.refundRequested:
        return 'Refund Requested';
      case RemittanceStatus.refundCompleted:
        return 'Refund Completed';
      case RemittanceStatus.unknown:
        return 'Unknown';
    }
  }

  bool get isTerminal =>
      this == RemittanceStatus.completed ||
      this == RemittanceStatus.rejected ||
      this == RemittanceStatus.expired ||
      this == RemittanceStatus.cancelled ||
      this == RemittanceStatus.refundCompleted;

  bool get isPending =>
      !isTerminal && this != RemittanceStatus.unknown && this != RemittanceStatus.draft;

  bool get canUploadDocuments =>
      this == RemittanceStatus.waitingDocuments ||
      this == RemittanceStatus.waitingPayment;
}

/// A remittance payout method (e.g. Alipay, WeChat Pay, Bank Transfer).
class RemittanceMethod {
  final int? id;
  final String? countryCode;
  final String? name;
  final int? receiveCurrencyId;
  final String? fields; // JSON string of dynamic form fields
  final int? status;

  RemittanceMethod({
    this.id,
    this.countryCode,
    this.name,
    this.receiveCurrencyId,
    this.fields,
    this.status,
  });

  factory RemittanceMethod.fromJson(Map<String, dynamic> json) {
    return RemittanceMethod(
      id: json['id'] as int?,
      countryCode: json['country_code'] as String?,
      name: json['name'] as String?,
      receiveCurrencyId: json['receive_currency_id'] as int?,
      fields: json['fields'] as String?,
      status: json['status'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'country_code': countryCode,
        'name': name,
        'receive_currency_id': receiveCurrencyId,
        'fields': fields,
        'status': status,
      };
}

/// Quote returned by /user/remittance/quote.
/// Rate is locked for [rateExpiresInSeconds] seconds.
class RemittanceQuote {
  final int? userId;
  final double sendAmount;
  final int sendCurrencyId;
  final int receiveCurrencyId;
  final int methodId;
  final double exchangeRate;
  final double receiveAmount;
  final double systemFee;
  final double totalPayable;
  final DateTime? rateLockedAt;
  final DateTime? rateExpiresAt;
  final int rateExpiresInSeconds;

  RemittanceQuote({
    this.userId,
    required this.sendAmount,
    required this.sendCurrencyId,
    required this.receiveCurrencyId,
    required this.methodId,
    required this.exchangeRate,
    required this.receiveAmount,
    required this.systemFee,
    required this.totalPayable,
    this.rateLockedAt,
    this.rateExpiresAt,
    required this.rateExpiresInSeconds,
  });

  factory RemittanceQuote.fromJson(Map<String, dynamic> json) {
    return RemittanceQuote(
      userId: json['user_id'] as int?,
      sendAmount: (json['send_amount'] as num?)?.toDouble() ?? 0,
      sendCurrencyId: json['send_currency_id'] as int? ?? 0,
      receiveCurrencyId: json['receive_currency_id'] as int? ?? 0,
      methodId: json['method_id'] as int? ?? 0,
      exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 0,
      receiveAmount: (json['receive_amount'] as num?)?.toDouble() ?? 0,
      systemFee: (json['system_fee'] as num?)?.toDouble() ?? 0,
      totalPayable: (json['total_payable'] as num?)?.toDouble() ?? 0,
      rateLockedAt: json['rate_locked_at'] != null
          ? DateTime.tryParse(json['rate_locked_at'].toString())
          : null,
      rateExpiresAt: json['rate_expires_at'] != null
          ? DateTime.tryParse(json['rate_expires_at'].toString())
          : null,
      rateExpiresInSeconds: json['rate_expires_in_seconds'] as int? ?? 900,
    );
  }

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'send_amount': sendAmount,
        'send_currency_id': sendCurrencyId,
        'receive_currency_id': receiveCurrencyId,
        'method_id': methodId,
        'exchange_rate': exchangeRate,
        'receive_amount': receiveAmount,
        'system_fee': systemFee,
        'total_payable': totalPayable,
        'rate_locked_at': rateLockedAt?.toIso8601String(),
        'rate_expires_at': rateExpiresAt?.toIso8601String(),
        'rate_expires_in_seconds': rateExpiresInSeconds,
      };

  bool get isExpired =>
      rateExpiresAt != null && DateTime.now().isAfter(rateExpiresAt!);
}

/// Sender info structure (validated by backend).
class RemittanceSenderInfo {
  final String name;
  final String country; // ISO 3166-1 alpha-2
  final String phone;
  final String idNumber;
  final String type; // 'individual' | 'business'

  RemittanceSenderInfo({
    required this.name,
    required this.country,
    required this.phone,
    required this.idNumber,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'phone': phone,
        'id_number': idNumber,
        'type': type,
      };
}

/// Receiver info structure.
class RemittanceReceiverInfo {
  final String name;
  final String country; // ISO 3166-1 alpha-2
  final String phone;
  final String? bankName;
  final String? accountNumber;
  final String? iban;
  // Optional fields for Chinese payout methods
  final String? alipayAccount;
  final String? wechatAccount;

  RemittanceReceiverInfo({
    required this.name,
    required this.country,
    required this.phone,
    this.bankName,
    this.accountNumber,
    this.iban,
    this.alipayAccount,
    this.wechatAccount,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'country': country,
        'phone': phone,
        if (bankName != null) 'bank_name': bankName,
        if (accountNumber != null) 'account_number': accountNumber,
        if (iban != null) 'iban': iban,
        if (alipayAccount != null) 'alipay_account': alipayAccount,
        if (wechatAccount != null) 'wechat_account': wechatAccount,
      };
}

/// A remittance request record.
class Remittance {
  final int? id;
  final String uuid;
  final String trx;
  final int? userId;
  final RemittanceSenderInfo? senderInfo;
  final RemittanceReceiverInfo? receiverInfo;
  final int? sendCurrencyId;
  final int? receiveCurrencyId;
  final int? remittanceMethodId;
  final double exchangeRate;
  final double sendAmount;
  final double receiveAmount;
  final double systemFee;
  final double agentFee;
  final double tax;
  final double totalPayable;
  final RemittanceStatus status;
  final DateTime? rateLockedAt;
  final DateTime? rateExpiresAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<RemittanceLog>? logs;
  final List<RemittanceAttachment>? attachments;
  final RemittanceMethod? method;

  Remittance({
    this.id,
    required this.uuid,
    required this.trx,
    this.userId,
    this.senderInfo,
    this.receiverInfo,
    this.sendCurrencyId,
    this.receiveCurrencyId,
    this.remittanceMethodId,
    required this.exchangeRate,
    required this.sendAmount,
    required this.receiveAmount,
    required this.systemFee,
    this.agentFee = 0,
    this.tax = 0,
    required this.totalPayable,
    required this.status,
    this.rateLockedAt,
    this.rateExpiresAt,
    this.createdAt,
    this.updatedAt,
    this.logs,
    this.attachments,
    this.method,
  });

  factory Remittance.fromJson(Map<String, dynamic> json) {
    final senderInfoJson = json['sender_info'] as Map<String, dynamic>?;
    final receiverInfoJson = json['receiver_info'] as Map<String, dynamic>?;

    // status can be int or string enum name
    final statusRaw = json['status'];
    String? statusStr;
    if (statusRaw is int) {
      statusStr = statusRaw.toString();
    } else if (statusRaw is String) {
      statusStr = statusRaw;
    } else if (statusRaw is Map) {
      // backend enum cast — sometimes serialized as object
      statusStr = statusRaw['value']?.toString();
    }

    return Remittance(
      id: json['id'] as int?,
      uuid: json['uuid'] as String? ?? '',
      trx: json['trx'] as String? ?? '',
      userId: json['user_id'] as int?,
      senderInfo: senderInfoJson != null
          ? RemittanceSenderInfo(
              name: senderInfoJson['name'] as String? ?? '',
              country: senderInfoJson['country'] as String? ?? '',
              phone: senderInfoJson['phone'] as String? ?? '',
              idNumber: senderInfoJson['id_number'] as String? ?? '',
              type: senderInfoJson['type'] as String? ?? 'individual',
            )
          : null,
      receiverInfo: receiverInfoJson != null
          ? RemittanceReceiverInfo(
              name: receiverInfoJson['name'] as String? ?? '',
              country: receiverInfoJson['country'] as String? ?? '',
              phone: receiverInfoJson['phone'] as String? ?? '',
              bankName: receiverInfoJson['bank_name'] as String?,
              accountNumber: receiverInfoJson['account_number'] as String?,
              iban: receiverInfoJson['iban'] as String?,
              alipayAccount: receiverInfoJson['alipay_account'] as String?,
              wechatAccount: receiverInfoJson['wechat_account'] as String?,
            )
          : null,
      sendCurrencyId: json['send_currency_id'] as int?,
      receiveCurrencyId: json['receive_currency_id'] as int?,
      remittanceMethodId: json['remittance_method_id'] as int?,
      exchangeRate: (json['exchange_rate'] as num?)?.toDouble() ?? 0,
      sendAmount: (json['send_amount'] as num?)?.toDouble() ?? 0,
      receiveAmount: (json['receive_amount'] as num?)?.toDouble() ?? 0,
      systemFee: (json['system_fee'] as num?)?.toDouble() ?? 0,
      agentFee: (json['agent_fee'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      totalPayable: (json['total_payable'] as num?)?.toDouble() ?? 0,
      status: RemittanceStatus.fromString(statusStr),
      rateLockedAt: json['rate_locked_at'] != null
          ? DateTime.tryParse(json['rate_locked_at'].toString())
          : null,
      rateExpiresAt: json['rate_expires_at'] != null
          ? DateTime.tryParse(json['rate_expires_at'].toString())
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      logs: (json['logs'] as List<dynamic>?)
          ?.map((e) => RemittanceLog.fromJson(e as Map<String, dynamic>))
          .toList(),
      attachments: (json['attachments'] as List<dynamic>?)
          ?.map((e) => RemittanceAttachment.fromJson(e as Map<String, dynamic>))
          .toList(),
      method: json['method'] != null
          ? RemittanceMethod.fromJson(json['method'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// An audit log entry for a remittance (status transition record).
class RemittanceLog {
  final int? id;
  final int? remittanceId;
  final String? causerType; // 'user' | 'admin' | 'system'
  final int? causerId;
  final RemittanceStatus? oldStatus;
  final RemittanceStatus? newStatus;
  final String? note;
  final String? ipAddress;
  final DateTime? createdAt;

  RemittanceLog({
    this.id,
    this.remittanceId,
    this.causerType,
    this.causerId,
    this.oldStatus,
    this.newStatus,
    this.note,
    this.ipAddress,
    this.createdAt,
  });

  factory RemittanceLog.fromJson(Map<String, dynamic> json) {
    return RemittanceLog(
      id: json['id'] as int?,
      remittanceId: json['remittance_id'] as int?,
      causerType: json['causer_type'] as String?,
      causerId: json['causer_id'] as int?,
      oldStatus: RemittanceStatus.fromString(json['old_status']?.toString()),
      newStatus: RemittanceStatus.fromString(json['new_status']?.toString()),
      note: json['note'] as String?,
      ipAddress: json['ip_address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

/// A document attached to a remittance (KYC, payment receipt, payout receipt).
class RemittanceAttachment {
  final int? id;
  final int? remittanceId;
  final String filePath;
  final String type; // 'kyc' | 'payment_receipt' | 'payout_receipt' | 'other'
  final DateTime? createdAt;

  RemittanceAttachment({
    this.id,
    this.remittanceId,
    required this.filePath,
    required this.type,
    this.createdAt,
  });

  factory RemittanceAttachment.fromJson(Map<String, dynamic> json) {
    return RemittanceAttachment(
      id: json['id'] as int?,
      remittanceId: json['remittance_id'] as int?,
      filePath: json['file_path'] as String? ?? '',
      type: json['type'] as String? ?? 'other',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
