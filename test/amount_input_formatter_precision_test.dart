import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';

void main() {
  group('AmountInputFormatter Precision & Zero-Decimal Tests', () {
    test(
      'maxDecimals = 0 (Toman/Rial) rejects decimal separator completely',
      () {
        final formatter = AmountInputFormatter(maxDecimals: 0);

        // Typing '1500.' with maxDecimals 0 should discard the dot
        final result = formatter.formatEditUpdate(
          const TextEditingValue(text: '1500'),
          const TextEditingValue(text: '1500.'),
        );
        expect(result.text, '1500');

        // Typing '1500.5' should discard dot and fraction
        final result2 = formatter.formatEditUpdate(
          const TextEditingValue(text: '1500'),
          const TextEditingValue(text: '1500.5'),
        );
        expect(result2.text, '15005');
      },
    );

    test('maxDecimals = 2 (USD/CNY) limits to 2 decimal places', () {
      final formatter = AmountInputFormatter(maxDecimals: 2);

      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '95.2'),
        const TextEditingValue(text: '95.25'),
      );
      expect(result.text, '95.25');

      // 3rd decimal is discarded
      final result2 = formatter.formatEditUpdate(
        const TextEditingValue(text: '95.25'),
        const TextEditingValue(text: '95.258'),
      );
      expect(result2.text, '95.25');
    });

    test('normalizes Persian and Arabic numerals to Latin digits', () {
      expect(AmountInputFormatter.normalize('۱۲۵۰۰۰'), '125000');
      expect(AmountInputFormatter.normalize('٩٥٠٠'), '9500');
      expect(AmountInputFormatter.normalize('۱,۲۵۰,۰۰۰'), '1250000');
    });
  });
}
