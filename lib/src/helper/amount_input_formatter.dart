import 'package:flutter/services.dart';

/// phase3-fix: money-safe keyboard input (audit A6-P2-10).
///
/// - Persian/Arabic digits are normalized to Latin («۱۰۰» used to reach
///   double.tryParse and silently become 0.0).
/// - Thousand separators (, ٬) and stray spaces are stripped.
/// - Only digits and ONE decimal separator survive; decimals are capped so
///   the server never receives more precision than the field allows.
class AmountInputFormatter extends TextInputFormatter {
  AmountInputFormatter({this.maxDecimals = 8});

  final int maxDecimals;

  static const List<String> _faDigits = [
    '۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹',
  ];
  static const List<String> _arDigits = [
    '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩',
  ];

  /// Normalizes user input to a plain Latin numeric string.
  static String normalize(String raw) {
    var s = raw;
    for (var i = 0; i < 10; i++) {
      s = s.replaceAll(_faDigits[i], '$i').replaceAll(_arDigits[i], '$i');
    }
    return s
        .replaceAll('٫', '.')
        .replaceAll(',', '')
        .replaceAll('٬', '')
        .replaceAll(' ', '');
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final cleaned = <String>[];
    var dotSeen = false;
    var decimals = 0;
    for (final ch in normalize(newValue.text).split('')) {
      if (ch == '.') {
        if (dotSeen) continue;
        dotSeen = true;
        cleaned.add(ch);
        continue;
      }
      final code = ch.codeUnitAt(0);
      final isDigit = code >= 0x30 && code <= 0x39;
      if (!isDigit) continue;
      if (dotSeen) {
        if (decimals >= maxDecimals) continue;
        decimals++;
      }
      cleaned.add(ch);
    }
    var text = cleaned.join();
    if (text.startsWith('.')) text = '0$text';
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
