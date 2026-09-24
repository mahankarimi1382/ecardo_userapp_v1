/// Transaction passcode (پس‌کد) rules for eCardo user app.
///
/// One mandatory 4-digit PIN used for transfer / cash-out / make-payment /
/// exchange and similar money flows. Distinct from:
/// - App-lock PIN (local device lock)
/// - Dynamic OTP (رمز پویا) used only for web-page payments
class PasscodeHelper {
  PasscodeHelper._();

  /// Exactly four decimal digits.
  static final RegExp _fourDigits = RegExp(r'^\d{4}$');

  /// True when the user has an active server-side passcode.
  /// Backend stores unset as null, empty, or the sentinel `"0"`.
  static bool userHasPasscode(String? stored) {
    if (stored == null) return false;
    final v = stored.trim();
    if (v.isEmpty || v == '0') return false;
    return true;
  }

  /// Client-side format check before hitting the API.
  static bool isValidFormat(String? value) {
    if (value == null) return false;
    return _fourDigits.hasMatch(value.trim());
  }

  /// Normalize for request bodies (trim only).
  static String normalize(String value) => value.trim();

  /// Setting keys that gate whether a module requires passcode on confirm.
  /// When passcode is mandatory system-wide we still respect these toggles
  /// for gradual rollout, but a user without passcode is always blocked.
  static const String transferSetting = 'transfer_money_passcode_status';
  static const String cashOutSetting = 'cashout_passcode_status';
  static const String makePaymentSetting = 'make_payment_passcode_status';
  static const String exchangeSetting = 'exchange_passcode_status';
}
