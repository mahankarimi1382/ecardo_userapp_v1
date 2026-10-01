import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/helper/money_math_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BUG-11: MoneyMathHelper unit tests', () {
    test('calculatePercentCharge calculates exact charge without float drift', () {
      // 100 * 2.5% = 2.5
      final charge1 = MoneyMathHelper.calculatePercentCharge(100.0, 2.5);
      expect(charge1, 2.5);

      // 55.55 * 1.5%
      final charge2 = MoneyMathHelper.calculatePercentCharge(55.55, 1.5, decimals: 4);
      expect(charge2, 0.8333);

      // zero values
      expect(MoneyMathHelper.calculatePercentCharge(0.0, 5.0), 0.0);
      expect(MoneyMathHelper.calculatePercentCharge(100.0, 0.0), 0.0);
    });

    test('add avoids binary float rounding errors (0.1 + 0.2)', () {
      // In standard IEEE-754 double: 0.1 + 0.2 = 0.30000000000000004
      final rawDoubleSum = 0.1 + 0.2;
      expect(rawDoubleSum.toString(), '0.30000000000000004');

      // With MoneyMathHelper:
      final safeSum = MoneyMathHelper.add(0.1, 0.2, decimals: 2);
      expect(safeSum, 0.3);
      expect(safeSum.toString(), '0.3');
    });

    test('subtract calculates accurate differences', () {
      final diff = MoneyMathHelper.subtract(100.0, 25.55, decimals: 2);
      expect(diff, 74.45);
    });

    test('roundToDecimals rounds accurately', () {
      expect(MoneyMathHelper.roundToDecimals(1.23456, 2), 1.23);
      expect(MoneyMathHelper.roundToDecimals(1.235, 2), 1.24);
      expect(MoneyMathHelper.roundToDecimals(0.0, 2), 0.0);
    });
  });
}
