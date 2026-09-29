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
