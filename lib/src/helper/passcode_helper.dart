import 'package:ecardo_user/src/helper/digit_normalization_formatter.dart';
/// Transaction PIN (رمز انتقال وجه / پس‌کد) — system B.
///
/// Distinct from:
/// - A: account password
/// - C: Google 2FA TOTP (login only)
/// - D: App Lock PIN (local device)
/// - E: payment OTP / dynamic password (web pro-pay)
///
/// Server: bcrypt in users.passcode; length 4–6 digits (from GET /user/passcode/status).
class PasscodeHelper {
  PasscodeHelper._();

  /// Defaults aligned with pro-pay / ecardo backend (4–6 digits).
  static int minDigits = 4;
  static int maxDigits = 6;

  /// Cached from GET /user/passcode/status — null until first fetch.
  static bool? hasPasscodeFromStatus;

  /// Apply server status payload:
  /// `{ has_passcode, min_digits?, max_digits? }` or nested under `data`.
  static void applyStatus(Map<String, dynamic>? raw) {
    if (raw == null) return;
    final data = raw['data'] is Map
        ? Map<String, dynamic>.from(raw['data'] as Map)
        : raw;
    final has = data['has_passcode'];
    if (has is bool) {
      hasPasscodeFromStatus = has;
    } else if (has != null) {
      hasPasscodeFromStatus =
          has == 1 || has == '1' || has.toString().toLowerCase() == 'true';
    }
    final min = data['min_digits'] ?? data['minDigits'];
    final max = data['max_digits'] ?? data['maxDigits'];
    if (min is int && min >= 4 && min <= 8) minDigits = min;
    if (min is String) {
      final p = int.tryParse(min);
      if (p != null && p >= 4 && p <= 8) minDigits = p;
    }
    if (max is int && max >= minDigits && max <= 12) maxDigits = max;
    if (max is String) {
      final p = int.tryParse(max);
      if (p != null && p >= minDigits && p <= 12) maxDigits = p;
    }
  }

  /// True when the user has an active server-side passcode.
  /// Prioritizes explicit positive confirmation from status, field, or stored string.
  static bool userHasPasscode(String? stored, [bool? hasPasscodeField]) {
    if (hasPasscodeFromStatus == true) return true;
    if (hasPasscodeField == true) return true;
    if (stored != null && stored.trim().isNotEmpty && stored.trim() != '0') return true;
    if (hasPasscodeFromStatus == false) return false;
    if (hasPasscodeField == false) return false;
    return false;
  }

  /// Client-side format: digits only, length in [minDigits, maxDigits].
  static bool isValidFormat(String? value) {
    if (value == null) return false;
    final v = value.trim();
    if (v.length < minDigits || v.length > maxDigits) return false;
    return RegExp(r'^\d+$').hasMatch(v);
  }

  static String normalize(String value) => DigitNormalizationFormatter.normalize(value);

  /// Input formatters for PIN fields (digits + max length from server).
  static List<dynamic> digitFormatters() {
    // Callers import services.dart and use:
    // FilteringTextInputFormatter.digitsOnly + LengthLimitingTextInputFormatter(maxDigits)
    return [maxDigits];
  }

  static const String transferSetting = 'transfer_money_passcode_status';
  static const String cashOutSetting = 'cashout_passcode_status';
  static const String makePaymentSetting = 'make_payment_passcode_status';
  static const String exchangeSetting = 'exchange_passcode_status';

  /// Canonical backend error codes for Passcode challenge & state machine (P0 Resilience).
  static const String codePasscodeRequired = 'PASSCODE_REQUIRED';
  static const String codePasscodeInvalid = 'PASSCODE_INVALID';
  static const String codePasscodeNotConfigured = 'PASSCODE_NOT_CONFIGURED';
  static const String codePasscodeLocked = 'PASSCODE_LOCKED';

  /// Returns true ONLY if the error signifies that a passcode is required
  /// and hasn't been provided yet.
  ///
  /// CRITICAL INVARIANT: If [wasPasscodeProvided] is true, this ALWAYS returns false
  /// to strictly guarantee that no infinite prompt/retry loop can ever occur.
  static bool isPasscodeRequired(
    dynamic errorOrResponse, {
    bool wasPasscodeProvided = false,
  }) {
    if (wasPasscodeProvided) {
      return false;
    }

    final text = errorOrResponse?.toString().toLowerCase() ?? '';
    if (text.isEmpty) return false;

    // Check for explicit structured error code first
    if (text.contains('passcode_required')) {
      return true;
    }

    // Check for negative signals: if error indicates invalid/locked, it's NOT a missing passcode challenge
    if (text.contains('invalid') ||
        text.contains('incorrect') ||
        text.contains('wrong') ||
        text.contains('locked') ||
        text.contains('اشتباه') ||
        text.contains('نادرست') ||
        text.contains('نامعتبر') ||
        text.contains('مسدود')) {
      return false;
    }

    final hasPasscodeTerm = text.contains('passcode') ||
        text.contains('پس‌کد') ||
        text.contains('رمز معامله') ||
        text.contains('رمز عبور معامله') ||
        text.contains('رمز');

    // Check for legacy string indicators
    if (hasPasscodeTerm &&
        (text.contains('required') ||
            text.contains('missing') ||
            text.contains('enter') ||
            text.contains('provide') ||
            text.contains('الزامی') ||
            text.contains('وارد'))) {
      return true;
    }

    // Fallback: If 422 specifically mentions passcode and no invalid keyword was matched
    if (text.contains('passcode') && (text.contains('422') || text.contains('error'))) {
      return true;
    }

    return false;
  }

  /// Returns true if the error indicates the entered passcode was invalid/wrong.
  static bool isPasscodeInvalid(dynamic errorOrResponse) {
    final text = errorOrResponse?.toString().toLowerCase() ?? '';
    final hasPasscodeTerm = text.contains('passcode') ||
        text.contains('پس‌کد') ||
        text.contains('رمز معامله') ||
        text.contains('رمز عبور معامله') ||
        text.contains('رمز');

    return text.contains('passcode_invalid') ||
        (hasPasscodeTerm &&
            (text.contains('invalid') ||
                text.contains('incorrect') ||
                text.contains('wrong') ||
                text.contains('اشتباه') ||
                text.contains('نادرست') ||
                text.contains('نامعتبر')));
  }

  /// Returns true if the passcode is temporarily or permanently locked.
  static bool isPasscodeLocked(dynamic errorOrResponse) {
    final text = errorOrResponse?.toString().toLowerCase() ?? '';
    final hasPasscodeTerm = text.contains('passcode') ||
        text.contains('پس‌کد') ||
        text.contains('رمز معامله') ||
        text.contains('رمز عبور معامله') ||
        text.contains('رمز');

    return text.contains('passcode_locked') ||
        text.contains('passcode_blocked') ||
        (hasPasscodeTerm &&
            (text.contains('lock') || text.contains('مسدود') || text.contains('قفل')));
  }
}
