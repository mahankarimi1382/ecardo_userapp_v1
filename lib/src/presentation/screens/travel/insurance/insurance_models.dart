// DATA: REAL | MOCK | PLACEHOLDER
// Core domain contracts, models, pricing logic and validators for
// eCardo Travel Insurance and Assistance Services.

import 'package:flutter/material.dart';

/// Destination zone classifications for international travel insurance.
enum InsuranceDestinationZone {
  schengen,
  worldwide,
  worldwideExcludingUsa,
  middleEast,
  asia,
  domestic,
}

extension InsuranceDestinationZoneExtension on InsuranceDestinationZone {
  String get code => switch (this) {
        InsuranceDestinationZone.schengen => 'SCHENGEN',
        InsuranceDestinationZone.worldwide => 'WORLDWIDE',
        InsuranceDestinationZone.worldwideExcludingUsa => 'WORLDWIDE_NO_USA',
        InsuranceDestinationZone.middleEast => 'MIDDLE_EAST',
        InsuranceDestinationZone.asia => 'ASIA',
        InsuranceDestinationZone.domestic => 'DOMESTIC',
      };

  String get displayNameEn => switch (this) {
        InsuranceDestinationZone.schengen => 'Schengen & Europe (EU/EEA)',
        InsuranceDestinationZone.worldwide => 'Worldwide (All Countries)',
        InsuranceDestinationZone.worldwideExcludingUsa => 'Worldwide (Excl. USA/Canada)',
        InsuranceDestinationZone.middleEast => 'Turkey & Middle East',
        InsuranceDestinationZone.asia => 'Asia & Pacific',
        InsuranceDestinationZone.domestic => 'Domestic Travel',
      };

  String get displayNameFa => switch (this) {
        InsuranceDestinationZone.schengen => 'حوزه شنگن و اروپا (EU/EEA)',
        InsuranceDestinationZone.worldwide => 'سراسر جهان (کلیه کشورها شامل آمریکا و کانادا)',
        InsuranceDestinationZone.worldwideExcludingUsa => 'سراسر جهان (به‌جز آمریکا و کانادا)',
        InsuranceDestinationZone.middleEast => 'ترکیه، امارات و خاورمیانه',
        InsuranceDestinationZone.asia => 'آسیا و اقیانوسیه',
        InsuranceDestinationZone.domestic => 'سفرهای داخلی',
      };

  double get riskMultiplier => switch (this) {
        InsuranceDestinationZone.domestic => 0.50,
        InsuranceDestinationZone.middleEast => 0.85,
        InsuranceDestinationZone.asia => 0.90,
        InsuranceDestinationZone.schengen => 1.15,
        InsuranceDestinationZone.worldwideExcludingUsa => 1.30,
        InsuranceDestinationZone.worldwide => 1.55,
      };
}

/// Traveler age risk bands.
enum TravelerAgeBand {
  standard, // < 65 years
  senior, // 65 - 75 years
  elderly, // 75+ years
}

extension TravelerAgeBandExtension on TravelerAgeBand {
  String get labelEn => switch (this) {
        TravelerAgeBand.standard => 'Under 65 years',
        TravelerAgeBand.senior => '65 to 75 years',
        TravelerAgeBand.elderly => '75+ years',
      };

  String get labelFa => switch (this) {
        TravelerAgeBand.standard => 'زیر ۶۵ سال',
        TravelerAgeBand.senior => '۶۵ تا ۷۵ سال',
        TravelerAgeBand.elderly => 'بالای ۷۵ سال',
      };

  double get multiplier => switch (this) {
        TravelerAgeBand.standard => 1.0,
        TravelerAgeBand.senior => 1.8,
        TravelerAgeBand.elderly => 2.8,
      };
}

/// Medical coverage tiers with visa compliance attributes.
enum MedicalCoverageTier {
  tier10k, // $10,000 / €10,000 (Budget regional)
  schengen30k, // €30,000 (Mandatory Schengen Visa Regulation EC No 810/2009)
  tier50k, // €50,000 / $50,000 (Standard Comprehensive + COVID-19)
  tier100k, // €100,000 / $100,000 (Worldwide Gold VIP)
}

extension MedicalCoverageTierExtension on MedicalCoverageTier {
  String get limitLabel => switch (this) {
        MedicalCoverageTier.tier10k => '€10,000',
        MedicalCoverageTier.schengen30k => '€30,000',
        MedicalCoverageTier.tier50k => '€50,000',
        MedicalCoverageTier.tier100k => '€100,000',
      };

  int get limitAmountEur => switch (this) {
        MedicalCoverageTier.tier10k => 10000,
        MedicalCoverageTier.schengen30k => 30000,
        MedicalCoverageTier.tier50k => 50000,
        MedicalCoverageTier.tier100k => 100000,
      };

  bool get isSchengenCompliant => limitAmountEur >= 30000;

  int get baseDailyRateRial => switch (this) {
        MedicalCoverageTier.tier10k => 28000,
        MedicalCoverageTier.schengen30k => 42000,
        MedicalCoverageTier.tier50k => 65000,
        MedicalCoverageTier.tier100k => 110000,
      };
}

/// Optional riders and addons.
enum InsuranceAddon {
  baggageProtection,
  tripCancellation,
  adventureSports,
}

extension InsuranceAddonExtension on InsuranceAddon {
  String get titleEn => switch (this) {
        InsuranceAddon.baggageProtection => 'Baggage Loss & Delay Rider',
        InsuranceAddon.tripCancellation => 'Trip Cancellation & Curtailment',
        InsuranceAddon.adventureSports => 'Adventure & Winter Sports Rider',
      };

  String get titleFa => switch (this) {
        InsuranceAddon.baggageProtection => 'پوشش سرقت و تأخیر چمدان',
        InsuranceAddon.tripCancellation => 'پوشش لغو و کنسلی سفر',
        InsuranceAddon.adventureSports => 'پوشش ورزش‌های زمستانی و پرخطر',
      };

  String get coverageLimitEn => switch (this) {
        InsuranceAddon.baggageProtection => 'Up to €1,000 (delay >6h: €200)',
        InsuranceAddon.tripCancellation => 'Up to €2,500 non-refundable costs',
        InsuranceAddon.adventureSports => 'Up to €30,000 medical for sports',
      };

  String get coverageLimitFa => switch (this) {
        InsuranceAddon.baggageProtection => 'تا ۱,۰۰۰ یورو (تأخیر بیش از ۶ ساعت: ۲۰۰ یورو)',
        InsuranceAddon.tripCancellation => 'تا ۲,۵۰۰ یورو جبران هزینه‌های غیرقابل استرداد',
        InsuranceAddon.adventureSports => 'تا ۳۰,۰۰۰ یورو حوادث ورزشی و اسکی',
      };

  int calculateCost(int durationDays) {
    return switch (this) {
      InsuranceAddon.baggageProtection => 95000 + (3000 * durationDays),
      InsuranceAddon.tripCancellation => 180000 + (5000 * durationDays),
      InsuranceAddon.adventureSports => 220000 + (8000 * durationDays),
    };
  }
}

/// Premium calculation result with itemized breakdown.
class InsurancePremiumBreakdown {
  final int durationDays;
  final TravelerAgeBand ageBand;
  final InsuranceDestinationZone zone;
  final MedicalCoverageTier tier;
  final int baseMedicalPremium;
  final int ageSurcharge;
  final int zoneAdjustment;
  final Map<InsuranceAddon, int> addonCosts;
  final int totalPremium;

  const InsurancePremiumBreakdown({
    required this.durationDays,
    required this.ageBand,
    required this.zone,
    required this.tier,
    required this.baseMedicalPremium,
    required this.ageSurcharge,
    required this.zoneAdjustment,
    required this.addonCosts,
    required this.totalPremium,
  });

  int get addonsTotal => addonCosts.values.fold(0, (sum, val) => sum + val);
}

/// Validation result for Schengen eligibility.
class SchengenValidationResult {
  final bool isValid;
  final String? errorMessageEn;
  final String? errorMessageFa;

  const SchengenValidationResult({
    required this.isValid,
    this.errorMessageEn,
    this.errorMessageFa,
  });

  static const valid = SchengenValidationResult(isValid: true);
}

/// Cancellation & Free-look refund result.
class InsuranceCancellationResult {
  final bool isEligible;
  final int refundAmount;
  final double refundPercentage;
  final String reasonEn;
  final String reasonFa;

  const InsuranceCancellationResult({
    required this.isEligible,
    required this.refundAmount,
    required this.refundPercentage,
    required this.reasonEn,
    required this.reasonFa,
  });
}

/// Comprehensive plan model for user display and selection.
class InsurancePlan {
  final String id;
  final String titleEn;
  final String titleFa;
  final MedicalCoverageTier tier;
  final String coverageLimit;
  final int basePrice;
  final List<String> benefitsEn;
  final List<String> benefitsFa;
  final Color color;
  final bool isPopular;

  const InsurancePlan({
    required this.id,
    required this.titleEn,
    required this.titleFa,
    required this.tier,
    required this.coverageLimit,
    required this.basePrice,
    required this.benefitsEn,
    required this.benefitsFa,
    required this.color,
    this.isPopular = false,
  });

  List<String> get benefits => benefitsFa;
}

const List<InsurancePlan> standardInsurancePlans = [
  InsurancePlan(
    id: 'basic_regional',
    titleEn: 'Regional Basic Plan',
    titleFa: 'پلن پایه منطقه‌ای',
    tier: MedicalCoverageTier.tier10k,
    coverageLimit: '€10,000',
    basePrice: 320000,
    benefitsEn: [
      'Emergency medical expenses up to €10,000',
      'Emergency medical evacuation & repatriation',
      'Emergency dental care up to €150',
      '24/7 Multi-lingual SOS telephone assistance',
    ],
    benefitsFa: [
      'پوشش هزینه‌های پزشکی و بستری تا ۱۰,۰۰۰ یورو',
      'انتقال و بازگرداندن بیمار به کشور',
      'پوشش فوریت‌های دندانپزشکی تا ۱۵۰ یورو',
      'پشتیبانی تلفنی ۲۴ ساعته اضطراری',
    ],
    color: Color(0xFF2563EB),
  ),
  InsurancePlan(
    id: 'schengen_standard',
    titleEn: 'Schengen Compliant Standard',
    titleFa: 'پلن استاندارد شنگن (مورد تأیید سفارت‌ها)',
    tier: MedicalCoverageTier.schengen30k,
    coverageLimit: '€30,000',
    basePrice: 490000,
    benefitsEn: [
      'Full Schengen visa compliance (Regulation EC No 810/2009)',
      'Hospitalization & outpatient medical up to €30,000',
      'Direct billing in EU partner network hospitals',
      'Repatriation of mortal remains',
      'Emergency dental care up to €250',
    ],
    benefitsFa: [
      'مطابق کامل ضوابط ویزای شنگن (آیین‌نامه ۸۱۰/۲۰۰۹ اتحادیه اروپا)',
      'پوشش هزینه‌های فوریت‌های پزشکی تا ۳۰,۰۰۰ یورو',
      'پرداخت مستقیم خسارت در مراکز درمانی طرف قرارداد اروپا',
      'بازگرداندن بیمار یا متوفی به کشور',
      'پوشش فوریت‌های دندانپزشکی تا ۲۵۰ یورو',
    ],
    color: Color(0xFF0D9488),
    isPopular: true,
  ),
  InsurancePlan(
    id: 'comprehensive_plus',
    titleEn: 'Standard Comprehensive Plus',
    titleFa: 'پلن جامع پلاس (شنگن + کرونا + بار)',
    tier: MedicalCoverageTier.tier50k,
    coverageLimit: '€50,000',
    basePrice: 820000,
    benefitsEn: [
      'Medical & hospital coverage up to €50,000',
      'COVID-19 full medical & quarantine coverage',
      'Baggage loss or delay compensation up to €1,000',
      'Flight delay compensation for delays over 6 hours',
      'Compassionate family member emergency visit',
    ],
    benefitsFa: [
      'پوشش هزینه‌های پزشکی و بیمارستانی تا ۵۰,۰۰۰ یورو',
      'پوشش کامل بیماری کرونا (COVID-19) و قرنطینه',
      'جبران خسارت مفقودی یا تأخیر چمدان تا ۱,۰۰۰ یورو',
      'پوشش کنسلی یا تأخیر پرواز بیش از ۶ ساعت',
      'پوشش هزینه سفر همراه بیمار در موارد اضطراری',
    ],
    color: Color(0xFF7C3AED),
  ),
  InsurancePlan(
    id: 'vip_worldwide',
    titleEn: 'Worldwide Gold VIP',
    titleFa: 'پلن طلایی VIP جهانی (آمریکا و کانادا)',
    tier: MedicalCoverageTier.tier100k,
    coverageLimit: '€100,000',
    basePrice: 1520000,
    benefitsEn: [
      'Top-tier coverage up to €100,000 worldwide (USA, Canada, Japan)',
      'Zero deductible / excess on medical claims',
      'Return of unattended minor children',
      'Legal assistance & emergency funds transfer',
      'Dedicated 24/7 VIP SOS concierge physician',
    ],
    benefitsFa: [
      'سقف پوشش تا ۱۰۰,۰۰۰ یورو در سراسر جهان (شامل آمریکا و کانادا)',
      'بدون فرانشیز در پرداخت خسارت‌های بیمارستانی',
      'پوشش بازگشت کودکان بدون سرپرست در صورت بستری',
      'کمک‌رسانی حقوقی و انتقال وجه اضطراری',
      'پزشک مشاور و پشتیبانی مستقیم SOS اختصاصی ۲۴ ساعته',
    ],
    color: Color(0xFFD97706),
  ),
];

/// Policyholder Traveler details.
class InsuredTraveler {
  final String fullNameEn;
  final String passportNumber;
  final String nationalId;
  final DateTime birthDate;
  final String phone;
  final String email;

  const InsuredTraveler({
    required this.fullNameEn,
    required this.passportNumber,
    required this.nationalId,
    required this.birthDate,
    required this.phone,
    required this.email,
  });

  int get age {
    final now = DateTime.now();
    int years = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      years--;
    }
    return years.clamp(0, 120);
  }

  TravelerAgeBand get ageBand => InsurancePricingCalculator.getAgeBand(age);
}

/// Official Issued Policy.
class InsurancePolicy {
  final String id;
  final String policyNumber;
  final String certificateNumber;
  final String qrVerificationPayload;
  final InsuredTraveler traveler;
  final InsuranceDestinationZone destinationZone;
  final String destinationCountry;
  final DateTime startDate;
  final DateTime endDate;
  final int durationDays;
  final InsurancePlan plan;
  final MedicalCoverageTier tier;
  final Set<InsuranceAddon> addons;
  final InsurancePremiumBreakdown breakdown;
  final DateTime issuedAt;
  final String status; // active, cancelled, claimInProgress, expired

  const InsurancePolicy({
    required this.id,
    required this.policyNumber,
    required this.certificateNumber,
    required this.qrVerificationPayload,
    required this.traveler,
    required this.destinationZone,
    required this.destinationCountry,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.plan,
    required this.tier,
    required this.addons,
    required this.breakdown,
    required this.issuedAt,
    this.status = 'active',
  });

  bool get isSchengenCompliant => tier.isSchengenCompliant;

  bool isEligibleForFreeLookCancellation({DateTime? checkDate}) {
    final now = checkDate ?? DateTime.now();
    // Free look is valid before the policy start date
    return now.isBefore(startDate) && status == 'active';
  }
}

/// Claim incident classifications.
enum InsuranceClaimType {
  medicalEmergency,
  baggageLossOrDelay,
  tripCancellation,
  flightDelay,
  dentalEmergency,
  other,
}

extension InsuranceClaimTypeExtension on InsuranceClaimType {
  String get labelEn => switch (this) {
        InsuranceClaimType.medicalEmergency => 'Medical Emergency / Hospitalization',
        InsuranceClaimType.baggageLossOrDelay => 'Baggage Loss or Delay',
        InsuranceClaimType.tripCancellation => 'Trip Cancellation or Curtailment',
        InsuranceClaimType.flightDelay => 'Flight Delay (> 6 Hours)',
        InsuranceClaimType.dentalEmergency => 'Emergency Dental Care',
        InsuranceClaimType.other => 'Other Incident / Assistance',
      };

  String get labelFa => switch (this) {
        InsuranceClaimType.medicalEmergency => 'فوریت‌های پزشکی و بستری بیمارستان',
        InsuranceClaimType.baggageLossOrDelay => 'گم شدن یا تأخیر بار و چمدان',
        InsuranceClaimType.tripCancellation => 'کنسلی یا قطع سفر اضطراری',
        InsuranceClaimType.flightDelay => 'تأخیر پرواز بیش از ۶ ساعت',
        InsuranceClaimType.dentalEmergency => 'فوریت‌های دندانپزشکی',
        InsuranceClaimType.other => 'سایر خسارت‌ها و حوادث',
      };
}

/// Claim review status.
enum InsuranceClaimStatus {
  submitted,
  underReview,
  documentsRequired,
  approved,
  rejected,
  paidOut,
}

extension InsuranceClaimStatusExtension on InsuranceClaimStatus {
  String get labelEn => switch (this) {
        InsuranceClaimStatus.submitted => 'Submitted',
        InsuranceClaimStatus.underReview => 'Under Review',
        InsuranceClaimStatus.documentsRequired => 'Documents Required',
        InsuranceClaimStatus.approved => 'Approved',
        InsuranceClaimStatus.rejected => 'Rejected',
        InsuranceClaimStatus.paidOut => 'Settled & Paid',
      };

  String get labelFa => switch (this) {
        InsuranceClaimStatus.submitted => 'ثبت اولیه',
        InsuranceClaimStatus.underReview => 'در حال بررسی کارشناس',
        InsuranceClaimStatus.documentsRequired => 'نیازمند بارگذاری مدارک',
        InsuranceClaimStatus.approved => 'تأیید خسارت',
        InsuranceClaimStatus.rejected => 'عدم تأیید',
        InsuranceClaimStatus.paidOut => 'تسویه و پرداخت شد',
      };

  Color get color => switch (this) {
        InsuranceClaimStatus.submitted => const Color(0xFF2563EB),
        InsuranceClaimStatus.underReview => const Color(0xFFD97706),
        InsuranceClaimStatus.documentsRequired => const Color(0xFFEA580C),
        InsuranceClaimStatus.approved => const Color(0xFF16A34A),
        InsuranceClaimStatus.rejected => const Color(0xFFDC2626),
        InsuranceClaimStatus.paidOut => const Color(0xFF0D9488),
      };
}

/// Submitted claim report.
class InsuranceClaim {
  final String claimId;
  final String policyNumber;
  final String insuredName;
  final InsuranceClaimType incidentType;
  final DateTime incidentDate;
  final String incidentLocation;
  final String description;
  final int estimatedAmount;
  final String currency;
  final String contactPhone;
  final DateTime submittedAt;
  final InsuranceClaimStatus status;
  final List<String> documentNames;

  const InsuranceClaim({
    required this.claimId,
    required this.policyNumber,
    required this.insuredName,
    required this.incidentType,
    required this.incidentDate,
    required this.incidentLocation,
    required this.description,
    required this.estimatedAmount,
    required this.currency,
    required this.contactPhone,
    required this.submittedAt,
    this.status = InsuranceClaimStatus.submitted,
    this.documentNames = const [],
  });
}

/// Pure Business Logic & Pricing Engine.
class InsurancePricingCalculator {
  /// Determine the traveler age risk band based on age in years.
  static TravelerAgeBand getAgeBand(int age) {
    if (age < 65) return TravelerAgeBand.standard;
    if (age <= 75) return TravelerAgeBand.senior;
    return TravelerAgeBand.elderly;
  }

  /// Calculate the duration in calendar days inclusive of start and end dates.
  static int calculateDurationDays(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate)) return 1;
    final diff = endDate.difference(startDate).inDays;
    return (diff + 1).clamp(1, 365);
  }

  /// Validate Schengen visa compliance.
  /// Schengen visa rules mandate minimum €30,000 medical coverage.
  static SchengenValidationResult validateSchengenEligibility({
    required InsuranceDestinationZone zone,
    required MedicalCoverageTier tier,
  }) {
    if (zone == InsuranceDestinationZone.schengen && !tier.isSchengenCompliant) {
      return const SchengenValidationResult(
        isValid: false,
        errorMessageEn: 'Schengen embassies require a minimum of €30,000 medical coverage.',
        errorMessageFa: 'استاندارد سفارت‌های حوزه شنگن حداقل ۳۰,۰۰۰ یورو پوشش درمانی را الزامی می‌داند.',
      );
    }
    return SchengenValidationResult.valid;
  }

  /// Calculate itemized premium.
  static InsurancePremiumBreakdown calculatePremium({
    required int durationDays,
    required TravelerAgeBand ageBand,
    required InsuranceDestinationZone zone,
    required MedicalCoverageTier tier,
    Set<InsuranceAddon> addons = const {},
  }) {
    final int safeDays = durationDays.clamp(1, 365).toInt();

    // Duration ratio tiering for extended trips
    final durationFactor = switch (safeDays) {
      <= 7 => 0.85,
      <= 15 => 1.0,
      <= 30 => 1.45,
      <= 60 => 2.10,
      <= 92 => 2.75,
      <= 180 => 3.80,
      _ => 5.20,
    };

    final baseDaily = tier.baseDailyRateRial;
    final zoneFactor = zone.riskMultiplier;
    final ageFactor = ageBand.multiplier;

    // Base medical cost before age surcharge
    final baseMedical = (baseDaily * safeDays * durationFactor * zoneFactor).round();
    // Age surcharge component
    final ageSurcharge = (baseMedical * (ageFactor - 1.0)).round();

    // Zone adjustment from domestic base
    final zoneAdj = (baseDaily * safeDays * (zoneFactor - 1.0)).round();

    // Addons calculations
    final addonCosts = <InsuranceAddon, int>{};
    for (final addon in addons) {
      addonCosts[addon] = addon.calculateCost(safeDays);
    }

    final int total = baseMedical +
        ageSurcharge +
        addonCosts.values.fold<int>(0, (sum, val) => sum + val);

    return InsurancePremiumBreakdown(
      durationDays: safeDays,
      ageBand: ageBand,
      zone: zone,
      tier: tier,
      baseMedicalPremium: baseMedical,
      ageSurcharge: ageSurcharge,
      zoneAdjustment: zoneAdj,
      addonCosts: addonCosts,
      totalPremium: total,
    );
  }

  /// Calculate cancellation refund under the free-look period.
  static InsuranceCancellationResult calculateCancellationRefund({
    required InsurancePolicy policy,
    required DateTime requestDate,
  }) {
    if (requestDate.isBefore(policy.startDate)) {
      // 100% full refund prior to trip start
      return InsuranceCancellationResult(
        isEligible: true,
        refundAmount: policy.breakdown.totalPremium,
        refundPercentage: 1.0,
        reasonEn: 'Full 100% refund approved (cancelled prior to coverage start date).',
        reasonFa: 'استرداد ۱۰۰٪ وجه بیمه‌نامه (درخواست لغو پیش از شروع تاریخ پوشش).',
      );
    } else {
      // Policy has already activated
      return const InsuranceCancellationResult(
        isEligible: false,
        refundAmount: 0,
        refundPercentage: 0.0,
        reasonEn: 'Policy has already commenced coverage and is no longer refundable.',
        reasonFa: 'به دلیل فعال شدن دوره پوشش بیمه، امکان لغو و استرداد وجه وجود ندارد.',
      );
    }
  }
}
