class VisaCatalogItem {
  final int id;
  final String countryCode;
  final String countryName;
  final String countryFlag;
  final String visaType;
  final String title;
  final String description;
  final List<VisaRequiredDoc> requiredDocs;
  final double serviceFee;
  final double govFee;
  final String currency;
  final int processingDaysMin;
  final int processingDaysMax;
  final Map<String, dynamic> refundPolicy;
  final bool needsBiometric;
  final bool appealSupported;
  final int maxRevisions;
  final bool isActive;

  VisaCatalogItem({
    required this.id,
    required this.countryCode,
    required this.countryName,
    required this.countryFlag,
    required this.visaType,
    required this.title,
    required this.description,
    required this.requiredDocs,
    required this.serviceFee,
    required this.govFee,
    required this.currency,
    required this.processingDaysMin,
    required this.processingDaysMax,
    required this.refundPolicy,
    required this.needsBiometric,
    required this.appealSupported,
    required this.maxRevisions,
    required this.isActive,
  });

  double get totalFee => serviceFee + govFee;

  String get processingTimeLabel =>
      '$processingDaysMin - $processingDaysMax';

  factory VisaCatalogItem.fromJson(Map<String, dynamic> json) {
    var rawDocs = json['required_docs'];
    List<VisaRequiredDoc> docs = [];
    if (rawDocs is List) {
      docs = rawDocs
          .whereType<Map<String, dynamic>>()
          .map((d) => VisaRequiredDoc.fromJson(d))
          .toList();
    }

    return VisaCatalogItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      countryCode: json['country_code']?.toString() ?? '',
      countryName: json['country_name']?.toString() ?? '',
      countryFlag: json['country_flag']?.toString() ?? '',
      visaType: json['visa_type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      requiredDocs: docs,
      serviceFee: double.tryParse('${json['service_fee']}') ?? 0.0,
      govFee: double.tryParse('${json['gov_fee']}') ?? 0.0,
      currency: json['currency']?.toString() ?? 'USD',
      processingDaysMin: int.tryParse('${json['processing_days_min']}') ?? 1,
      processingDaysMax: int.tryParse('${json['processing_days_max']}') ?? 5,
      refundPolicy: json['refund_policy'] is Map
          ? Map<String, dynamic>.from(json['refund_policy'])
          : {},
      needsBiometric: json['needs_biometric'] == true ||
          json['needs_biometric'] == 1 ||
          '${json['needs_biometric']}' == 'true',
      appealSupported: json['appeal_supported'] == true ||
          json['appeal_supported'] == 1 ||
          '${json['appeal_supported']}' == 'true',
      maxRevisions: int.tryParse('${json['max_revisions']}') ?? 3,
      isActive: json['is_active'] == true ||
          json['is_active'] == 1 ||
          '${json['is_active']}' == 'true',
    );
  }
}

class VisaRequiredDoc {
  final String key;
  final String title;
  final String type;
  final String instructions;
  final bool required;

  VisaRequiredDoc({
    required this.key,
    required this.title,
    required this.type,
    required this.instructions,
    required this.required,
  });

  factory VisaRequiredDoc.fromJson(Map<String, dynamic> json) {
    return VisaRequiredDoc(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      type: json['type']?.toString() ?? 'FILE',
      instructions: json['instructions']?.toString() ?? '',
      required: json['required'] == true ||
          json['required'] == 1 ||
          '${json['required']}' == 'true',
    );
  }
}

class VisaRequestModel {
  final int id;
  final String caseNo;
  final int catalogId;
  final String status;
  final String countryName;
  final String countryFlag;
  final String visaTitle;
  final String applicantName;
  final String applicantPassport;
  final String applicantNationality;
  final String applicantPhone;
  final String applicantEmail;
  final String? travelDate;
  final String? returnDate;
  final double serviceFee;
  final double govFee;
  final double totalPaid;
  final String currency;
  final String? rejectionReason;
  final String? evisaFilePath;
  final String? deliveredAt;
  final String createdAt;
  final List<VisaSubmittedDoc> documents;
  final List<VisaEventModel> events;

  VisaRequestModel({
    required this.id,
    required this.caseNo,
    required this.catalogId,
    required this.status,
    required this.countryName,
    required this.countryFlag,
    required this.visaTitle,
    required this.applicantName,
    required this.applicantPassport,
    required this.applicantNationality,
    required this.applicantPhone,
    required this.applicantEmail,
    this.travelDate,
    this.returnDate,
    required this.serviceFee,
    required this.govFee,
    required this.totalPaid,
    required this.currency,
    this.rejectionReason,
    this.evisaFilePath,
    this.deliveredAt,
    required this.createdAt,
    required this.documents,
    required this.events,
  });

  double get totalFee => serviceFee + govFee;

  bool get isApproved => status == 'APPROVED' || status == 'DELIVERED';
  bool get isRejected => status == 'REJECTED';
  bool get isAwaitingPayment => status == 'AWAITING_PAYMENT';
  bool get isComplementRequired => status == 'COMPLEMENT_REQUIRED';
  bool get canCancel =>
      status == 'DRAFT' ||
      status == 'AWAITING_DOCUMENTS' ||
      status == 'AWAITING_PAYMENT';

  factory VisaRequestModel.fromJson(Map<String, dynamic> json) {
    final catalog = json['catalog'] is Map ? json['catalog'] : {};
    final applicant = json['applicant_info'] is Map ? json['applicant_info'] : {};

    List<VisaSubmittedDoc> docs = [];
    if (json['documents'] is List) {
      docs = (json['documents'] as List)
          .whereType<Map<String, dynamic>>()
          .map((d) => VisaSubmittedDoc.fromJson(d))
          .toList();
    }

    List<VisaEventModel> evts = [];
    if (json['events'] is List) {
      evts = (json['events'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => VisaEventModel.fromJson(e))
          .toList();
    }

    return VisaRequestModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      caseNo: json['case_no']?.toString() ?? '',
      catalogId: json['catalog_id'] is int
          ? json['catalog_id']
          : int.tryParse('${json['catalog_id']}') ?? 0,
      status: json['status']?.toString() ?? 'DRAFT',
      countryName: catalog['country_name']?.toString() ??
          json['country_name']?.toString() ??
          '',
      countryFlag: catalog['country_flag']?.toString() ??
          json['country_flag']?.toString() ??
          '',
      visaTitle: catalog['title']?.toString() ??
          json['visa_title']?.toString() ??
          '',
      applicantName: applicant['full_name']?.toString() ??
          json['applicant_name']?.toString() ??
          '',
      applicantPassport: applicant['passport_number']?.toString() ??
          json['passport_number']?.toString() ??
          '',
      applicantNationality: applicant['nationality']?.toString() ??
          json['nationality']?.toString() ??
          '',
      applicantPhone: applicant['phone']?.toString() ??
          json['phone']?.toString() ??
          '',
      applicantEmail: applicant['email']?.toString() ??
          json['email']?.toString() ??
          '',
      travelDate: json['travel_date']?.toString(),
      returnDate: json['return_date']?.toString(),
      serviceFee: double.tryParse('${json['service_fee']}') ?? 0.0,
      govFee: double.tryParse('${json['gov_fee']}') ?? 0.0,
      totalPaid: double.tryParse('${json['total_paid']}') ?? 0.0,
      currency: json['currency']?.toString() ??
          catalog['currency']?.toString() ??
          'USD',
      rejectionReason: json['rejection_reason']?.toString(),
      evisaFilePath: json['evisa_file_path']?.toString(),
      deliveredAt: json['delivered_at']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      documents: docs,
      events: evts,
    );
  }
}

class VisaSubmittedDoc {
  final int id;
  final String docKey;
  final String title;
  final String status;
  final String? filePath;
  final String? rejectionNote;

  VisaSubmittedDoc({
    required this.id,
    required this.docKey,
    required this.title,
    required this.status,
    this.filePath,
    this.rejectionNote,
  });

  bool get isAccepted => status == 'ACCEPTED';
  bool get isRejected => status == 'REJECTED';
  bool get isPending => status == 'PENDING';

  factory VisaSubmittedDoc.fromJson(Map<String, dynamic> json) {
    return VisaSubmittedDoc(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      docKey: json['doc_key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      filePath: json['file_path']?.toString(),
      rejectionNote: json['rejection_note']?.toString(),
    );
  }
}

class VisaEventModel {
  final int id;
  final String? fromStatus;
  final String toStatus;
  final String title;
  final String? note;
  final String actorType;
  final String createdAt;

  VisaEventModel({
    required this.id,
    this.fromStatus,
    required this.toStatus,
    required this.title,
    this.note,
    required this.actorType,
    required this.createdAt,
  });

  factory VisaEventModel.fromJson(Map<String, dynamic> json) {
    return VisaEventModel(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}') ?? 0,
      fromStatus: json['from_status']?.toString(),
      toStatus: json['to_status']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      note: json['note']?.toString(),
      actorType: json['actor_type']?.toString() ?? 'SYSTEM',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
