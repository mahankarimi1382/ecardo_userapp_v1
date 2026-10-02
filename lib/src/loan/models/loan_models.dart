/// Loan & Credit Service models — Loan-Service-Flow.md
/// اپ: محصولات، پرونده، پیشنهاد، وثیقه، قسط، تایم‌لاین.

class LoanProductModel {
  final int id;
  final String name;
  final String audience;
  final double minAmount;
  final double maxAmount;
  final List<int> tenureOptions;
  final double interestRatePct;
  final String? requiredCollateralType;
  final double feePct;
  final double lateFeeDailyPct;
  final double lateFeeCapPct;

  const LoanProductModel({
    required this.id,
    required this.name,
    required this.audience,
    required this.minAmount,
    required this.maxAmount,
    required this.tenureOptions,
    required this.interestRatePct,
    this.requiredCollateralType,
    required this.feePct,
    required this.lateFeeDailyPct,
    required this.lateFeeCapPct,
  });

  double get baseRateAnnual => interestRatePct;

  factory LoanProductModel.fromJson(Map<String, dynamic> json) {
    return LoanProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString() ?? '',
      audience: json['audience']?.toString() ?? 'PERSONAL',
      minAmount: (json['min_amount'] as num?)?.toDouble() ?? 0,
      maxAmount: (json['max_amount'] as num?)?.toDouble() ?? 0,
      tenureOptions: ((json['tenure_options'] as List?) ?? [])
          .map((e) => (e as num).toInt())
          .toList(),
      interestRatePct: (json['interest_rate_pct'] as num?)?.toDouble() ?? 0,
      requiredCollateralType: json['required_collateral_type']?.toString(),
      feePct: (json['fee_pct'] as num?)?.toDouble() ?? 0,
      lateFeeDailyPct: (json['late_fee_daily_pct'] as num?)?.toDouble() ?? 0,
      lateFeeCapPct: (json['late_fee_cap_pct'] as num?)?.toDouble() ?? 0,
    );
  }
}

class LoanAssessmentModel {
  final int score;
  final String decision;
  final Map<String, dynamic>? components;

  const LoanAssessmentModel({
    required this.score,
    required this.decision,
    this.components,
  });

  factory LoanAssessmentModel.fromJson(Map<String, dynamic> json) {
    return LoanAssessmentModel(
      score: (json['score'] as num?)?.toInt() ?? 0,
      decision: json['decision']?.toString() ?? '',
      components: json['components'] is Map<String, dynamic>
          ? json['components'] as Map<String, dynamic>
          : null,
    );
  }
}

class LoanOfferModel {
  final int id;
  final double offeredAmount;
  final double ratePct;
  final int tenureMonths;
  final List<Map<String, dynamic>> schedulePreview;
  final String? requiredCollateralType;
  final String status;
  final DateTime? expiresAt;

  const LoanOfferModel({
    required this.id,
    required this.offeredAmount,
    required this.ratePct,
    required this.tenureMonths,
    required this.schedulePreview,
    this.requiredCollateralType,
    required this.status,
    this.expiresAt,
  });

  factory LoanOfferModel.fromJson(Map<String, dynamic> json) {
    return LoanOfferModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      offeredAmount: (json['offered_amount'] as num?)?.toDouble() ?? 0,
      ratePct: (json['rate_pct'] as num?)?.toDouble() ?? 0,
      tenureMonths: (json['tenure_months'] as num?)?.toInt() ?? 0,
      schedulePreview: ((json['schedule_preview'] as List?) ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      requiredCollateralType: json['required_collateral_type']?.toString(),
      status: json['status']?.toString() ?? 'PENDING',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString())
          : null,
    );
  }
}

class LoanCollateralModel {
  final int id;
  final String type;
  final String? asset;
  final double amount;
  final double? ltvPct;
  final String status;

  const LoanCollateralModel({
    required this.id,
    required this.type,
    this.asset,
    required this.amount,
    this.ltvPct,
    required this.status,
  });

  factory LoanCollateralModel.fromJson(Map<String, dynamic> json) {
    return LoanCollateralModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      type: json['type']?.toString() ?? 'CASH',
      asset: json['asset']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      ltvPct: (json['ltv_pct'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? 'LOCKED',
    );
  }
}

class LoanInstallmentModel {
  final int id;
  final int seq;
  final DateTime? dueDate;
  final double amount;
  final double principalPart;
  final double interestPart;
  final double paidAmount;
  final double lateFeeAccrued;
  final String status;

  const LoanInstallmentModel({
    required this.id,
    required this.seq,
    this.dueDate,
    required this.amount,
    required this.principalPart,
    required this.interestPart,
    required this.paidAmount,
    required this.lateFeeAccrued,
    required this.status,
  });

  bool get isPaid => status == 'PAID' || status == 'WAIVED';
  bool get isOverdue => status == 'OVERDUE';
  double get totalDue => amount + lateFeeAccrued - paidAmount;
  int get installmentNo => seq;

  factory LoanInstallmentModel.fromJson(Map<String, dynamic> json) {
    return LoanInstallmentModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      seq: (json['seq'] as num?)?.toInt() ?? 0,
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'].toString())
          : null,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      principalPart: (json['principal_part'] as num?)?.toDouble() ?? 0,
      interestPart: (json['interest_part'] as num?)?.toDouble() ?? 0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0,
      lateFeeAccrued: (json['late_fee_accrued'] as num?)?.toDouble() ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
    );
  }
}

class LoanCaseModel {
  final int id;
  final String caseNo;
  final int borrowerId;
  final LoanProductModel? product;
  final LoanOfferModel? offer;
  final double requestedAmount;
  final int tenureMonths;
  final String status;
  final DateTime? offerExpiresAt;
  final List<LoanCollateralModel> collaterals;
  final List<LoanInstallmentModel> installments;
  final List<LoanEventModel> events;
  final DateTime? createdAt;

  const LoanCaseModel({
    required this.id,
    required this.caseNo,
    required this.borrowerId,
    this.product,
    this.offer,
    required this.requestedAmount,
    required this.tenureMonths,
    required this.status,
    this.offerExpiresAt,
    required this.collaterals,
    required this.installments,
    required this.events,
    this.createdAt,
  });

  factory LoanCaseModel.fromJson(Map<String, dynamic> json) {
    return LoanCaseModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      caseNo: json['case_no']?.toString() ?? '',
      borrowerId: (json['borrower_id'] as num?)?.toInt() ?? 0,
      product: json['product'] is Map<String, dynamic>
          ? LoanProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      offer: json['offer'] is Map<String, dynamic>
          ? LoanOfferModel.fromJson(json['offer'] as Map<String, dynamic>)
          : null,
      requestedAmount: (json['requested_amount'] as num?)?.toDouble() ?? 0,
      tenureMonths: (json['tenure_months'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'DRAFT',
      offerExpiresAt: json['offer_expires_at'] != null
          ? DateTime.tryParse(json['offer_expires_at'].toString())
          : null,
      collaterals: ((json['collaterals'] as List?) ?? [])
          .map((e) => LoanCollateralModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      installments: ((json['installments'] as List?) ?? [])
          .map((e) => LoanInstallmentModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      events: ((json['events'] as List?) ?? [])
          .map((e) => LoanEventModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}

class LoanEventModel {
  final int id;
  final String actorRole;
  final String? fromStatus;
  final String? toStatus;
  final String? reason;
  final DateTime? createdAt;

  const LoanEventModel({
    required this.id,
    required this.actorRole,
    this.fromStatus,
    this.toStatus,
    this.reason,
    this.createdAt,
  });

  factory LoanEventModel.fromJson(Map<String, dynamic> json) {
    return LoanEventModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      actorRole: json['actor_role']?.toString() ?? 'SYSTEM',
      fromStatus: json['from_status']?.toString(),
      toStatus: json['to_status']?.toString(),
      reason: json['reason']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
