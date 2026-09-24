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
  /// Prefer [hasPasscodeFromStatus] when set; else user JSON sentinel.
  static bool userHasPasscode(String? stored) {
    if (hasPasscodeFromStatus != null) return hasPasscodeFromStatus!;
    if (stored == null) return false;
    final v = stored.trim();
    if (v.isEmpty || v == '0') return false;
    return true;
  }

  /// Client-side format: digits only, length in [minDigits, maxDigits].
  static bool isValidFormat(String? value) {
    if (value == null) return false;
    final v = value.trim();
    if (v.length < minDigits || v.length > maxDigits) return false;
    return RegExp(r'^\d+$').hasMatch(v);
  }

  static String normalize(String value) => value.trim();

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
}
