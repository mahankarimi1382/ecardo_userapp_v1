// DATA: MOCK (local persistence) — real issuance requires the backend contract
// described in INS-BE-001. Nothing here calls the network; every artifact is
// deterministic so tests and demos behave identically.

import 'dart:convert';
import 'dart:math';

import 'package:barcode/barcode.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:shared_preferences/shared_preferences.dart';

import 'insurance_models.dart';

/// Verifiable inspection URL embedded in the certificate QR code.
/// DATA: PLACEHOLDER — swap for the real insurer verification portal once the
/// backend exposes it (INS-BE-002).
const String insuranceVerificationBaseUrl =
    'https://verify.ecardo.io/insurance/policy/';

/// Stateless helpers that turn a quote into an issuable certificate.
class InsurancePolicyIssuer {
  const InsurancePolicyIssuer();

  /// Certificate number format used by Iranian travel insurers and accepted by
  /// embassies: `EC-<zone>-<yyMMdd>-<6 alnum>`.
  static String buildCertificateNumber({
    required InsuranceDestinationZone zone,
    required DateTime startDate,
    String? seed,
  }) {
    final rnd = Random(seed?.hashCode ?? startDate.microsecondsSinceEpoch);
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final suffix = List<String>.generate(
      6,
      (_) => alphabet[rnd.nextInt(alphabet.length)],
    ).join();
    final stamp = '${_two(startDate.year % 100)}'
        '${_two(startDate.month)}${_two(startDate.day)}';
    return 'EC-${_zoneShort(zone)}-$stamp-$suffix';
  }

  static String _zoneShort(InsuranceDestinationZone zone) => switch (zone) {
        InsuranceDestinationZone.schengen => 'SNG',
        InsuranceDestinationZone.worldwide => 'WWO',
        InsuranceDestinationZone.worldwideExcludingUsa => 'WWE',
        InsuranceDestinationZone.middleEast => 'MEA',
        InsuranceDestinationZone.asia => 'ASI',
        InsuranceDestinationZone.domestic => 'IRN',
      };

  static String _two(int value) => value.toString().padLeft(2, '0');

  static String buildQrPayload(String certificateNumber) =>
      '$insuranceVerificationBaseUrl$certificateNumber';
}

/// Issue an [InsurancePolicy] from a validated quote.
class InsuranceIssuanceResult {
  final InsurancePolicy? policy;
  final String? errorEn;
  final String? errorFa;

  const InsuranceIssuanceResult.success(InsurancePolicy this.policy)
      : errorEn = null,
        errorFa = null;

  const InsuranceIssuanceResult.failure({
    required String this.errorEn,
    required String this.errorFa,
  }) : policy = null;

  bool get isSuccess => policy != null;
}

class InsuranceService {
  InsuranceService({Random? random}) : _random = random ?? Random();

  final Random _random;

  /// Full quote → validation → issuance pipeline.
  InsuranceIssuanceResult issuePolicy({
    required InsuredTraveler traveler,
    required InsuranceDestinationZone zone,
    required String destinationCountry,
    required DateTime startDate,
    required DateTime endDate,
    required InsurancePlan plan,
    Set<InsuranceAddon> addons = const {},
    DateTime? now,
  }) {
    final issueTime = now ?? DateTime.now();

    // --- Validation error states (never throw, always explain) ---
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final normalizedEnd = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    );
    if (normalizedEnd.isBefore(normalizedStart)) {
      return InsuranceIssuanceResult.failure(
        errorEn: 'The coverage end date must be on or after the start date.',
        errorFa: 'تاریخ پایان پوشش باید برابر یا بعد از تاریخ شروع باشد.',
      );
    }
    if (normalizedStart.isBefore(
      DateTime(issueTime.year, issueTime.month, issueTime.day),
    )) {
      return const InsuranceIssuanceResult.failure(
        errorEn:
            'Retroactive coverage is not allowed. The start date cannot be in the past.',
        errorFa:
            'امکان صدور بیمه‌نامه با اثر تاریخ گذشته وجود ندارد. تاریخ شروع نمی‌تواند در گذشته باشد.',
      );
    }
    if (traveler.age < 1) {
      return const InsuranceIssuanceResult.failure(
        errorEn: 'A valid date of birth is required to issue the policy.',
        errorFa: 'برای صدور بیمه‌نامه ثبت تاریخ تولد معتبر الزامی است.',
      );
    }
    if (traveler.age > 90 &&
        traveler.ageBand == TravelerAgeBand.elderly) {
      return const InsuranceIssuanceResult.failure(
        errorEn:
            'Travelers over 90 require insurer underwriting review. Please contact support.',
        errorFa:
            'صدور بیمه‌نامه برای مسافران بالای ۹۰ سال نیازمند بررسی هسته‌ریزی بیمه‌گر است. با پشتیبانی تماس بگیرید.',
      );
    }
    if (destinationCountry.trim().isEmpty) {
      return const InsuranceIssuanceResult.failure(
        errorEn: 'Please enter the destination country or city.',
        errorFa: 'لطفاً کشور یا شهر مقصد سفر را وارد کنید.',
      );
    }

    final schengen = InsurancePricingCalculator.validateSchengenEligibility(
      zone: zone,
      tier: plan.tier,
    );
    if (!schengen.isValid) {
      return InsuranceIssuanceResult.failure(
        errorEn: schengen.errorMessageEn ?? 'Schengen eligibility failed.',
        errorFa: schengen.errorMessageFa ?? 'مجوز شنگن صادر نشد.',
      );
    }

    final durationDays = InsurancePricingCalculator.calculateDurationDays(
      normalizedStart,
      normalizedEnd,
    );
    final breakdown = InsurancePricingCalculator.calculatePremium(
      durationDays: durationDays,
      ageBand: traveler.ageBand,
      zone: zone,
      tier: plan.tier,
      addons: addons,
    );

    final certificate = InsurancePolicyIssuer.buildCertificateNumber(
      zone: zone,
      startDate: normalizedStart,
      seed: '${traveler.passportNumber}$issueTime',
    );

    final policy = InsurancePolicy(
      id: 'pol-${issueTime.microsecondsSinceEpoch}-${_random.nextInt(9999)}',
      policyNumber: certificate,
      certificateNumber: certificate,
      qrVerificationPayload: InsurancePolicyIssuer.buildQrPayload(certificate),
      traveler: traveler,
      destinationZone: zone,
      destinationCountry: destinationCountry.trim(),
      startDate: normalizedStart,
      endDate: normalizedEnd,
      durationDays: durationDays,
      plan: plan,
      tier: plan.tier,
      addons: addons,
      breakdown: breakdown,
      issuedAt: issueTime,
    );
    return InsuranceIssuanceResult.success(policy);
  }

  /// Deterministic mock claim acknowledgement id.
  static String buildClaimReference() {
    final stamp = DateTime.now().microsecondsSinceEpoch.toRadixString(36);
    return 'CLM-${stamp.toUpperCase()}';
  }
}

/// Local persistence for issued policies and submitted claims.
/// DATA: MOCK — replaced by backend sync in INS-BE-001 / INS-BE-004.
class InsuranceLocalStore {
  static const _policiesKey = 'travel_insurance_policies_v1';
  static const _claimsKey = 'travel_insurance_claims_v1';

  static Future<List<InsurancePolicy>> loadPolicies() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_policiesKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List? ?? const [];
      return decoded
          .whereType<Map>()
          .map(
            (entry) => InsurancePolicyCodec.decode(
              Map<String, dynamic>.from(entry),
            ),
          )
          .whereType<InsurancePolicy>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Future<void> addPolicy(InsurancePolicy policy) async {
    final existing = await loadPolicies();
    final preferences = await SharedPreferences.getInstance();
    final next = [...existing, policy];
    await preferences.setString(
      _policiesKey,
      jsonEncode(next.map(InsurancePolicyCodec.encode).toList()),
    );
  }

  static Future<void> updatePolicyStatus({
    required String policyId,
    required String status,
  }) async {
    final existing = await loadPolicies();
    final preferences = await SharedPreferences.getInstance();
    final next = existing
        .map(
          (item) => item.id == policyId
              ? InsurancePolicyCodec.copyWithStatus(item, status)
              : item,
        )
        .toList();
    await preferences.setString(
      _policiesKey,
      jsonEncode(next.map(InsurancePolicyCodec.encode).toList()),
    );
  }

  static Future<List<InsuranceClaim>> loadClaims() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_claimsKey);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List? ?? const [];
      return decoded
          .whereType<Map>()
          .map(
            (entry) => InsuranceClaimCodec.decode(Map<String, dynamic>.from(entry)),
          )
          .whereType<InsuranceClaim>()
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  static Future<void> addClaim(InsuranceClaim claim) async {
    final existing = await loadClaims();
    final preferences = await SharedPreferences.getInstance();
    final next = [...existing, claim];
    await preferences.setString(
      _claimsKey,
      jsonEncode(next.map(InsuranceClaimCodec.encode).toList()),
    );
  }

  static Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_policiesKey);
    await preferences.remove(_claimsKey);
  }
}

/// JSON codecs kept separate so the models stay immutable and const-friendly.
class InsurancePolicyCodec {
  static Map<String, dynamic> encode(InsurancePolicy policy) => {
        'id': policy.id,
        'policy_number': policy.policyNumber,
        'certificate_number': policy.certificateNumber,
        'qr_payload': policy.qrVerificationPayload,
        'traveler': {
          'full_name_en': policy.traveler.fullNameEn,
          'passport': policy.traveler.passportNumber,
          'national_id': policy.traveler.nationalId,
          'birth_date': policy.traveler.birthDate.toIso8601String(),
          'phone': policy.traveler.phone,
          'email': policy.traveler.email,
        },
        'zone': policy.destinationZone.code,
        'country': policy.destinationCountry,
        'start_date': policy.startDate.toIso8601String(),
        'end_date': policy.endDate.toIso8601String(),
        'duration_days': policy.durationDays,
        'plan_id': policy.plan.id,
        'tier': policy.tier.name,
        'addons': policy.addons.map((item) => item.name).toList(),
        'total_premium': policy.breakdown.totalPremium,
        'base_medical': policy.breakdown.baseMedicalPremium,
        'age_surcharge': policy.breakdown.ageSurcharge,
        'issued_at': policy.issuedAt.toIso8601String(),
        'status': policy.status,
      };

  static InsurancePolicy? decode(Map<String, dynamic> json) {
    try {
      final planId = json['plan_id']?.toString() ?? '';
      final plan = standardInsurancePlans.firstWhere(
        (item) => item.id == planId,
        orElse: () => standardInsurancePlans.first,
      );
      final travelerMap = Map<String, dynamic>.from(
        json['traveler'] as Map? ?? const {},
      );
      final breakdown = InsurancePremiumBreakdown(
        durationDays: int.tryParse(json['duration_days']?.toString() ?? '') ?? 1,
        ageBand: TravelerAgeBand.standard,
        zone: insuranceZoneFromCode(json['zone']?.toString() ?? ''),
        tier: coverageTierFromName(json['tier']?.toString() ?? ''),
        baseMedicalPremium:
            int.tryParse(json['base_medical']?.toString() ?? '') ?? 0,
        ageSurcharge: int.tryParse(json['age_surcharge']?.toString() ?? '') ?? 0,
        zoneAdjustment: 0,
        addonCosts: const {},
        totalPremium: int.tryParse(json['total_premium']?.toString() ?? '') ?? 0,
      );
      return InsurancePolicy(
        id: json['id']?.toString() ?? '',
        policyNumber: json['policy_number']?.toString() ?? '',
        certificateNumber: json['certificate_number']?.toString() ?? '',
        qrVerificationPayload: json['qr_payload']?.toString() ?? '',
        traveler: InsuredTraveler(
          fullNameEn: travelerMap['full_name_en']?.toString() ?? '',
          passportNumber: travelerMap['passport']?.toString() ?? '',
          nationalId: travelerMap['national_id']?.toString() ?? '',
          birthDate:
              DateTime.tryParse(travelerMap['birth_date']?.toString() ?? '') ??
              DateTime(1990),
          phone: travelerMap['phone']?.toString() ?? '',
          email: travelerMap['email']?.toString() ?? '',
        ),
        destinationZone: insuranceZoneFromCode(json['zone']?.toString() ?? ''),
        destinationCountry: json['country']?.toString() ?? '',
        startDate:
            DateTime.tryParse(json['start_date']?.toString() ?? '') ??
            DateTime.now(),
        endDate: DateTime.tryParse(json['end_date']?.toString() ?? '') ??
            DateTime.now(),
        durationDays:
            int.tryParse(json['duration_days']?.toString() ?? '') ?? 1,
        plan: plan,
        tier: coverageTierFromName(json['tier']?.toString() ?? ''),
        addons: (json['addons'] as List? ?? const [])
            .map((raw) => insuranceAddonFromName(raw.toString()))
            .whereType<InsuranceAddon>()
            .toSet(),
        breakdown: breakdown,
        issuedAt: DateTime.tryParse(json['issued_at']?.toString() ?? '') ??
            DateTime.now(),
        status: json['status']?.toString() ?? 'active',
      );
    } catch (_) {
      return null;
    }
  }

  static InsurancePolicy copyWithStatus(InsurancePolicy policy, String status) =>
      InsurancePolicy(
        id: policy.id,
        policyNumber: policy.policyNumber,
        certificateNumber: policy.certificateNumber,
        qrVerificationPayload: policy.qrVerificationPayload,
        traveler: policy.traveler,
        destinationZone: policy.destinationZone,
        destinationCountry: policy.destinationCountry,
        startDate: policy.startDate,
        endDate: policy.endDate,
        durationDays: policy.durationDays,
        plan: policy.plan,
        tier: policy.tier,
        addons: policy.addons,
        breakdown: policy.breakdown,
        issuedAt: policy.issuedAt,
        status: status,
      );
}

class InsuranceClaimCodec {
  static Map<String, dynamic> encode(InsuranceClaim claim) => {
        'claim_id': claim.claimId,
        'policy_number': claim.policyNumber,
        'insured_name': claim.insuredName,
        'incident_type': claim.incidentType.name,
        'incident_date': claim.incidentDate.toIso8601String(),
        'location': claim.incidentLocation,
        'description': claim.description,
        'estimated_amount': claim.estimatedAmount,
        'currency': claim.currency,
        'phone': claim.contactPhone,
        'submitted_at': claim.submittedAt.toIso8601String(),
        'status': claim.status.name,
        'documents': claim.documentNames,
      };

  static InsuranceClaim? decode(Map<String, dynamic> json) {
    try {
      return InsuranceClaim(
        claimId: json['claim_id']?.toString() ?? '',
        policyNumber: json['policy_number']?.toString() ?? '',
        insuredName: json['insured_name']?.toString() ?? '',
        incidentType: insuranceClaimTypeFromName(
          json['incident_type']?.toString() ?? '',
        ),
        incidentDate:
            DateTime.tryParse(json['incident_date']?.toString() ?? '') ??
            DateTime.now(),
        incidentLocation: json['location']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
        estimatedAmount:
            int.tryParse(json['estimated_amount']?.toString() ?? '') ?? 0,
        currency: json['currency']?.toString() ?? 'IRR',
        contactPhone: json['phone']?.toString() ?? '',
        submittedAt:
            DateTime.tryParse(json['submitted_at']?.toString() ?? '') ??
            DateTime.now(),
        status: insuranceClaimStatusFromName(json['status']?.toString() ?? ''),
        documentNames: (json['documents'] as List? ?? const [])
            .map((item) => item.toString())
            .toList(growable: false),
      );
    } catch (_) {
      return null;
    }
  }
}

InsuranceDestinationZone insuranceZoneFromCode(String code) {
  final normalized = code.trim().toUpperCase();
  for (final zone in InsuranceDestinationZone.values) {
    if (zone.code == normalized) return zone;
  }
  return InsuranceDestinationZone.schengen;
}

MedicalCoverageTier coverageTierFromName(String name) {
  for (final tier in MedicalCoverageTier.values) {
    if (tier.name == name.trim()) return tier;
  }
  return MedicalCoverageTier.schengen30k;
}

InsuranceAddon? insuranceAddonFromName(String name) {
  for (final addon in InsuranceAddon.values) {
    if (addon.name == name.trim()) return addon;
  }
  return null;
}

InsuranceClaimType insuranceClaimTypeFromName(String name) {
  for (final type in InsuranceClaimType.values) {
    if (type.name == name.trim()) return type;
  }
  return InsuranceClaimType.other;
}

InsuranceClaimStatus insuranceClaimStatusFromName(String name) {
  for (final status in InsuranceClaimStatus.values) {
    if (status.name == name.trim()) return status;
  }
  return InsuranceClaimStatus.submitted;
}

/// Builds the embassy-compliant A4 certificate as PDF bytes.
/// DATA: MOCK — the layout mirrors a real issuance document; the backend
/// returns the signed master PDF once INS-BE-003 lands.
class InsuranceDocumentBuilder {
  const InsuranceDocumentBuilder._();

  static Future<Uint8List> buildCertificateBytes(InsurancePolicy policy) async {
    final document = pw.Document();
    final line = DateFormat('yyyy-MM-dd');

    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('eCardo Insurance & Assistance',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 18,
                            )),
                    pw.Text('Certificate of Travel Medical Insurance',
                        style: const pw.TextStyle(fontSize: 12)),
                  ],
                ),
                pw.BarcodeWidget(
                  barcode: Barcode.qrCode(),
                  data: policy.qrVerificationPayload,
                  width: 72,
                  height: 72,
                ),
              ],
            ),
            pw.Divider(thickness: 1.4),
            pw.SizedBox(height: 12),
            _row(context, 'Policy / Certificate No.', policy.certificateNumber),
            _row(context, 'Insured Person', policy.traveler.fullNameEn),
            _row(context, 'Passport No.', policy.traveler.passportNumber),
            _row(context, 'National ID', policy.traveler.nationalId),
            _row(context, 'Date of Birth', line.format(policy.traveler.birthDate)),
            _row(context, 'Destination Zone', policy.destinationZone.displayNameEn),
            _row(context, 'Country of Travel', policy.destinationCountry),
            _row(
              context,
              'Period of Coverage',
              '${line.format(policy.startDate)} - ${line.format(policy.endDate)}'
              ' (${policy.durationDays} days)',
            ),
            _row(context, 'Plan', policy.plan.titleEn),
            _row(context, 'Medical Coverage Limit', policy.plan.coverageLimit),
            _row(
              context,
              'Optional Riders',
              policy.addons.isEmpty
                  ? 'None'
                  : policy.addons.map((item) => item.titleEn).join(', '),
            ),
            _row(
              context,
              'Premium',
              '${policy.breakdown.totalPremium} IRR',
            ),
            pw.SizedBox(height: 18),
            pw.Text(
              'This certificate confirms that the insured person holds a travel '
              'medical insurance policy meeting the Schengen acquisition '
              'requirements (Regulation (EC) No 810/2009, Article 15). Emergency '
              'medical expenses, hospitalisation and repatriation are covered up '
              'to the stated limit for the full validity period.',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '24/7 International SOS Assistance: +33 1 45 16 65 65',
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'Verify authenticity at $insuranceVerificationBaseUrl'
              '${policy.certificateNumber}',
              style: const pw.TextStyle(fontSize: 9),
            ),
            pw.SizedBox(height: 24),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Issued on: ${line.format(policy.issuedAt)}',
                        style: const pw.TextStyle(fontSize: 9)),
                    pw.Text('Status: ${policy.status.toUpperCase()}',
                        style: const pw.TextStyle(fontSize: 9)),
                  ],
                ),
                pw.Text('eCardo Fintech Super-App',
                    style: const pw.TextStyle(fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );

    return document.save();
  }

  static pw.Widget _row(pw.Context context, String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 150,
            child: pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          ),
          pw.Expanded(
            child: pw.Text(
              value,
              style: pw.Theme.of(context).defaultTextStyle.copyWith(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
