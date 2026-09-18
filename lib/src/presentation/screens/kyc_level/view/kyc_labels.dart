// ============================================================================
// kyc_labels.dart
// ----------------------------------------------------------------------------
// v1.1 (KYC-LIM/KYC-DOC): localized label helpers for the KYC surfaces.
//
// Why a shared helper: the roadmap cards and the submit wizard both render
// `required_docs` keys, and the roadmap renders per-level `limits`. With the
// per-country doc rules the server can now send keys the app has never seen
// (e.g. `national_card` for IR users) — every key must render with a
// readable label and never crash.
// ============================================================================

import 'package:ecardo_user/l10n/app_localizations.dart';

/// One rendered limit row, e.g. group "Cash-in" + measure "per day".
class KycLimitRow {
  final String groupLabel;
  final String? measureLabel;
  final String value;

  const KycLimitRow({
    required this.groupLabel,
    this.measureLabel,
    required this.value,
  });
}

class KycDocLabels {
  KycDocLabels._();

  /// Localized label for a `required_docs` key. Unknown keys fall back to a
  /// readable rendering of the raw key — never null, never a crash.
  static String label(AppLocalizations? loc, String docKey) {
    switch (docKey) {
      case 'selfie':
        return loc?.kycDocSelfie ?? 'Selfie';
      case 'govt_id':
        return loc?.kycDocGovtId ?? 'ID document';
      case 'personal_info':
        return loc?.kycDocPersonalInfo ?? 'Personal information';
      case 'trade_license':
        return loc?.kycDocTradeLicense ?? 'Trade license';
      case 'business_info':
        return loc?.kycDocBusinessInfo ?? 'Business information';
      case 'company_docs':
        return loc?.kycDocCompanyDocs ?? 'Company documents';
      case 'national_card':
        return loc?.kycDocNationalCard ?? 'National ID card';
      case 'source_of_funds':
        return loc?.kycDocSourceOfFunds ?? 'Proof of source of funds';
      case 'video_verification':
        return loc?.kycDocVideoVerification ?? 'Video verification';
      default:
        return _readableKey(docKey);
    }
  }

  /// Localized upload instruction for a `required_docs` key (submit wizard).
  /// Unknown keys get the generic instruction — never null, never a crash.
  static String instruction(AppLocalizations? loc, String docKey) {
    switch (docKey) {
      case 'selfie':
        return loc?.kycDocSelfieHint ??
            'Take a clear selfie with good lighting and a fully visible face.';
      case 'govt_id':
        return loc?.kycDocGovtIdHint ??
            'A clear photo of the front and back of your ID document. All details must be readable.';
      case 'personal_info':
        return loc?.kycDocPersonalInfoHint ??
            'Personal information including address, postal code and phone number.';
      case 'trade_license':
        return loc?.kycDocTradeLicenseHint ??
            'A scanned copy of a valid trade license.';
      case 'business_info':
        return loc?.kycDocBusinessInfoHint ??
            'Complete business information including name, activity type and address.';
      case 'company_docs':
        return loc?.kycDocCompanyDocsHint ??
            'Company registration documents, articles of association and incorporation notice.';
      case 'national_card':
        return loc?.kycDocNationalCardHint ??
            'A clear photo of both sides of your national ID card. All details must be readable.';
      case 'source_of_funds':
        return loc?.kycDocSourceOfFundsHint ??
            'A document proving the source of your funds (payslip, bank statement, business income…).';
      case 'video_verification':
        return loc?.kycDocVideoVerificationHint ??
            'Record a short video of your face following the on-screen instructions.';
      default:
        return loc?.kycDocGenericHint ?? 'Please upload the required document.';
    }
  }

  /// Readable fallback for unknown server keys: `national_card` →
  /// `National card`. Keeps new per-country doc keys usable on day one.
  static String _readableKey(String key) {
    final trimmed = key.trim();
    if (trimmed.isEmpty) return key;
    final spaced = trimmed.replaceAll('_', ' ').replaceAll('-', ' ');
    return spaced[0].toUpperCase() + spaced.substring(1);
  }
}

class KycLimitLabels {
  KycLimitLabels._();

  /// Limit keys the server may send per level (v1.1 contract). A missing key
  /// means the server has no per-level override — the global value applies.
  /// Unknown keys are skipped (they must NOT crash the roadmap).
  /// Daily/monthly caps also arrive under the server's `*_daily_limit` /
  /// `*_monthly_limit` spelling — resolved via [_dailyMonthlyAliases].
  static const Set<String> knownKeys = {
    'cashin_minimum', 'cashin_maximum', 'cashin_daily', 'cashin_monthly',
    'cashout_minimum', 'cashout_maximum', 'cashout_daily', 'cashout_monthly',
    'exchange_minimum', 'exchange_maximum', 'exchange_daily', 'exchange_monthly',
    'transfer_maximum', 'transfer_daily_limit',
    'payment_maximum', 'gift_maximum', 'paycardo_topup_limit',
  };

  /// Server sends daily/monthly caps as `<group>_daily_limit` /
  /// `<group>_monthly_limit`; the v1.1 checklist originally spelled them
  /// `<group>_daily` / `<group>_monthly`. Both spellings must render — the
  /// alias only fills the canonical key when the canonical key is absent,
  /// so either spelling (or both) yields exactly one row per measure.
  static const Map<String, String> _dailyMonthlyAliases = {
    'cashin_daily_limit': 'cashin_daily',
    'cashin_monthly_limit': 'cashin_monthly',
    'cashout_daily_limit': 'cashout_daily',
    'cashout_monthly_limit': 'cashout_monthly',
    'exchange_daily_limit': 'exchange_daily',
    'exchange_monthly_limit': 'exchange_monthly',
  };

  static Map<String, dynamic> _resolveLimitAliases(
    Map<String, dynamic> limits,
  ) {
    final resolved = Map<String, dynamic>.of(limits);
    _dailyMonthlyAliases.forEach((alias, canonical) {
      final aliasValue = resolved[alias];
      if (aliasValue == null) return;
      resolved[canonical] ??= aliasValue;
    });
    return resolved;
  }

  /// Builds the localized limit rows for a level's `limits` map, in the
  /// canonical key order above. Unknown keys are ignored.
  static List<KycLimitRow> rows(
    AppLocalizations? loc,
    Map<String, dynamic>? limits,
  ) {
    if (limits == null || limits.isEmpty) return const <KycLimitRow>[];

    final resolved = _resolveLimitAliases(limits);
    final result = <KycLimitRow>[];
    for (final key in knownKeys) {
      final raw = resolved[key];
      if (raw == null) continue;
      final value = _formatValue(raw);
      if (value == null) continue;

      switch (key) {
        case 'cashin_minimum':
          result.add(_row(loc, _group(loc, Group.cashin), Measure.min, value));
        case 'cashin_maximum':
          result.add(_row(loc, _group(loc, Group.cashin), Measure.max, value));
        case 'cashin_daily':
          result.add(_row(loc, _group(loc, Group.cashin), Measure.daily, value));
        case 'cashin_monthly':
          result.add(_row(loc, _group(loc, Group.cashin), Measure.monthly, value));
        case 'cashout_minimum':
          result.add(_row(loc, _group(loc, Group.cashout), Measure.min, value));
        case 'cashout_maximum':
          result.add(_row(loc, _group(loc, Group.cashout), Measure.max, value));
        case 'cashout_daily':
          result.add(_row(loc, _group(loc, Group.cashout), Measure.daily, value));
        case 'cashout_monthly':
          result.add(_row(loc, _group(loc, Group.cashout), Measure.monthly, value));
        case 'exchange_minimum':
          result.add(_row(loc, _group(loc, Group.exchange), Measure.min, value));
        case 'exchange_maximum':
          result.add(_row(loc, _group(loc, Group.exchange), Measure.max, value));
        case 'exchange_daily':
          result.add(_row(loc, _group(loc, Group.exchange), Measure.daily, value));
        case 'exchange_monthly':
          result.add(_row(loc, _group(loc, Group.exchange), Measure.monthly, value));
        case 'transfer_maximum':
          result.add(_row(loc, _group(loc, Group.transfer), Measure.max, value));
        case 'transfer_daily_limit':
          result.add(_row(loc, _group(loc, Group.transfer), Measure.daily, value));
        case 'payment_maximum':
          result.add(_row(loc, _group(loc, Group.payment), Measure.max, value));
        case 'gift_maximum':
          result.add(_row(loc, _group(loc, Group.gift), Measure.max, value));
        case 'paycardo_topup_limit':
          result.add(KycLimitRow(
            groupLabel: loc?.kycLimitPaycardoTopup ?? 'PayCardo top-up',
            value: value,
          ));
      }
    }
    return result;
  }

  static KycLimitRow _row(
    AppLocalizations? loc,
    String group,
    Measure measure,
    String value,
  ) {
    switch (measure) {
      case Measure.min:
        return KycLimitRow(
          groupLabel: group,
          measureLabel: loc?.kycLimitMeasureMin ?? 'min',
          value: value,
        );
      case Measure.max:
        return KycLimitRow(
          groupLabel: group,
          measureLabel: loc?.kycLimitMeasureMax ?? 'max',
          value: value,
        );
      case Measure.daily:
        return KycLimitRow(
          groupLabel: group,
          measureLabel: loc?.kycLimitMeasureDaily ?? 'per day',
          value: value,
        );
      case Measure.monthly:
        return KycLimitRow(
          groupLabel: group,
          measureLabel: loc?.kycLimitMeasureMonthly ?? 'per month',
          value: value,
        );
    }
  }

  static String _group(AppLocalizations? loc, Group group) {
    switch (group) {
      case Group.cashin:
        return loc?.kycLimitGroupCashin ?? 'Cash-in';
      case Group.cashout:
        return loc?.kycLimitGroupCashout ?? 'Cash-out';
      case Group.exchange:
        return loc?.kycLimitGroupExchange ?? 'Exchange';
      case Group.transfer:
        return loc?.kycLimitGroupTransfer ?? 'Transfer';
      case Group.payment:
        return loc?.kycLimitGroupPayment ?? 'Payment';
      case Group.gift:
        return loc?.kycLimitGroupGift ?? 'Gift';
    }
  }

  /// Server values may be num, int, double or string. Numbers get thousand
  /// separators; doubles keep up to 2 decimals. Strings pass through.
  static String? _formatValue(dynamic raw) {
    if (raw is num) {
      if (raw == raw.roundToDouble() && raw.abs() < 1e15) {
        final intPart = raw.toInt().abs().toString();
        final grouped = _groupThousands(intPart);
        return (raw < 0 ? '-' : '') + grouped;
      }
      return raw.toString();
    }
    final s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  static String _groupThousands(String digits) {
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      final remaining = digits.length - i;
      buffer.write(digits[i]);
      if (remaining > 1 && (remaining - 1) % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }
}

enum Group { cashin, cashout, exchange, transfer, payment, gift }

enum Measure { min, max, daily, monthly }
