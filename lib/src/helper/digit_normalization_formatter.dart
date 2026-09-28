import 'package:flutter/services.dart';

/// Normalizes Persian (۰-۹) and Arabic (٠-٩) digits to standard ASCII digits (0-9)
/// and strictly limits to digits only up to [maxLength].
///
/// Prevents the issue where users typing with a Persian or Arabic keyboard on Android/iOS
/// have their input completely blocked by FilteringTextInputFormatter.digitsOnly.
class DigitNormalizationFormatter extends TextInputFormatter {
  final int maxLength;

  const DigitNormalizationFormatter({this.maxLength = 6});

  static const _farsi = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
  static const _arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

  static String normalize(String input) {
    var res = input;
    for (int i = 0; i < 10; i++) {
      res = res.replaceAll(_farsi[i], i.toString());
      res = res.replaceAll(_arabic[i], i.toString());
    }
    return res.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final normalized = normalize(newValue.text);
    final truncated = normalized.length > maxLength
        ? normalized.substring(0, maxLength)
        : normalized;

    return TextEditingValue(
      text: truncated,
      selection: TextSelection.collapsed(offset: truncated.length),
    );
  }
}
