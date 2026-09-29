/// Bank Guarantee & LC Service models — Bank-Guarantee-Service-Flow.md

class GuaranteeInstrumentModel {
  final int id;
  final String code;
  final String name;
  final String? description;
  final double marginPct;
  final double feePct;
  final bool isLc;

  const GuaranteeInstrumentModel({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.marginPct,
    required this.feePct,
    required this.isLc,
  });

  factory GuaranteeInstrumentModel.fromJson(Map<String, dynamic> json) {
    return GuaranteeInstrumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      marginPct: (json['margin_pct'] as num?)?.toDouble() ?? 0,
      feePct: (json['fee_pct'] as num?)?.toDouble() ?? 0,
      isLc: json['is_lc'] == true || json['is_lc'] == 1,
    );
  }
}

class GuaranteeBankOfferModel {
  final int id;
  final String bankName;
  final double feePct;
  final double marginPct;
  final int issueSlaDays;
  final int responseSlaDays;

  const GuaranteeBankOfferModel({
    required this.id,
    required this.bankName,
    required this.feePct,
    required this.marginPct,
    required this.issueSlaDays,
    required this.responseSlaDays,
  });

  factory GuaranteeBankOfferModel.fromJson(Map<String, dynamic> json) {
    return GuaranteeBankOfferModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bankName: json['bank_name']?.toString() ?? '',
      feePct: (json['fee_pct'] as num?)?.toDouble() ?? 0,
      marginPct: (json['margin_pct'] as num?)?.toDouble() ?? 0,
      issueSlaDays: (json['issue_sla_days'] as num?)?.toInt() ?? 3,
      responseSlaDays: (json['response_sla_days'] as num?)?.toInt() ?? 5,
    );
  }
}

class CaseDocumentModel {
  final int id;
  final String docType;
  final String fileRef;
  final String status;
  final String? reviewerNote;

  const CaseDocumentModel({
    required this.id,
    required this.docType,
    required this.fileRef,
    required this.status,
    this.reviewerNote,
  });

  factory CaseDocumentModel.fromJson(Map<String, dynamic> json) {
    return CaseDocumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      docType: json['doc_type']?.toString() ?? '',
      fileRef: json['file_ref']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      reviewerNote: json['reviewer_note']?.toString(),
    );
  }
}

class GuaranteeMarginModel {
  final int id;
  final double amount;
  final double feeAmount;
  final String currency;
  final String source;
  final String status;

  const GuaranteeMarginModel({
    required this.id,
    required this.amount,
    required this.feeAmount,
    required this.currency,
    required this.source,
    required this.status,
  });

  factory GuaranteeMarginModel.fromJson(Map<String, dynamic> json) {
    return GuaranteeMarginModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      feeAmount: (json['fee_amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'IRR',
      source: json['source']?.toString() ?? 'WALLET_FIAT',
      status: json['status']?.toString() ?? 'LOCKED',
    );
  }
}

class IssuedInstrumentModel {
  final int id;
  final String bankRef;
  final String documentRef;
  final DateTime? issueDate;
  final DateTime? expiryDate;

  const IssuedInstrumentModel({
    required this.id,
    required this.bankRef,
    required this.documentRef,
    this.issueDate,
    this.expiryDate,
  });

  factory IssuedInstrumentModel.fromJson(Map<String, dynamic> json) {
    return IssuedInstrumentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bankRef: json['bank_ref']?.toString() ?? '',
      documentRef: json['document_ref']?.toString() ?? '',
      issueDate: json['issue_date'] != null ? DateTime.tryParse(json['issue_date'].toString()) : null,
      expiryDate: json['expiry_date'] != null ? DateTime.tryParse(json['expiry_date'].toString()) : null,
    );
  }
}

class GuaranteeCaseModel {
  final int id;
  final String caseNo;
  final GuaranteeInstrumentModel? instrument;
  final GuaranteeBankOfferModel? bankOffer;
  final String beneficiaryName;
  final double amount;
  final String currency;
  final int validityMonths;
  final String status;
  final GuaranteeMarginModel? margin;
  final IssuedInstrumentModel? issued;
  final List<CaseDocumentModel> documents;
  final List<GuaranteeEventModel> events;

  const GuaranteeCaseModel({
    required this.id,
    required this.caseNo,
    this.instrument,
    this.bankOffer,
    required this.beneficiaryName,
    required this.amount,
    required this.currency,
    required this.validityMonths,
    required this.status,
    this.margin,
    this.issued,
    this.documents = const [],
    required this.events,
  });

  factory GuaranteeCaseModel.fromJson(Map<String, dynamic> json) {
    return GuaranteeCaseModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      caseNo: json['case_no']?.toString() ?? '',
      instrument: json['instrument'] is Map<String, dynamic>
          ? GuaranteeInstrumentModel.fromJson(json['instrument'] as Map<String, dynamic>)
          : null,
      bankOffer: json['bank_offer'] is Map<String, dynamic>
          ? GuaranteeBankOfferModel.fromJson(json['bank_offer'] as Map<String, dynamic>)
          : null,
      beneficiaryName: json['beneficiary_name']?.toString() ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currency: json['currency']?.toString() ?? 'IRR',
      validityMonths: (json['validity_months'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'DRAFT',
      margin: json['margin'] is Map<String, dynamic>
          ? GuaranteeMarginModel.fromJson(json['margin'] as Map<String, dynamic>)
          : null,
      issued: json['issued'] is Map<String, dynamic>
          ? IssuedInstrumentModel.fromJson(json['issued'] as Map<String, dynamic>)
          : null,
      documents: ((json['documents'] as List?) ?? [])
          .map((e) => CaseDocumentModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      events: ((json['events'] as List?) ?? [])
          .map((e) => GuaranteeEventModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class GuaranteeEventModel {
  final int id;
  final String actorRole;
  final String? reason;
  final String? source;
  final DateTime? createdAt;

  const GuaranteeEventModel({
    required this.id,
    required this.actorRole,
    this.reason,
    this.source,
    this.createdAt,
  });

  factory GuaranteeEventModel.fromJson(Map<String, dynamic> json) {
    return GuaranteeEventModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      actorRole: json['actor_role']?.toString() ?? 'SYSTEM',
      reason: json['reason']?.toString(),
      source: json['source']?.toString(),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
    );
  }
}
