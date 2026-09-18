import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_labels.dart';

void main() {
  test('renders daily/monthly rows from the server _limit spelling', () {
    final rows = KycLimitLabels.rows(null, {
      'cashin_minimum': 10,
      'cashin_maximum': 500,
      'cashin_daily_limit': 300,
      'cashin_monthly_limit': 2000,
    });

    final measures = rows.map((r) => r.measureLabel).toList();
    expect(measures, containsAll(['min', 'max', 'per day', 'per month']));
    expect(rows.where((r) => r.measureLabel == 'per day').single.value, '300');
    expect(
      rows.where((r) => r.measureLabel == 'per month').single.value,
      '2,000',
    );
    expect(rows.map((r) => r.groupLabel), everyElement('Cash-in'));
  });

  test('still renders the v1.1 checklist spelling', () {
    final rows = KycLimitLabels.rows(null, {
      'cashout_daily': 150,
      'exchange_monthly': 9000,
    });

    expect(
      rows.where((r) => r.measureLabel == 'per day').single.value,
      '150',
    );
    expect(rows.where((r) => r.measureLabel == 'per day').single.groupLabel,
        'Cash-out');
    expect(
      rows.where((r) => r.measureLabel == 'per month').single.value,
      '9,000',
    );
    expect(rows.where((r) => r.measureLabel == 'per month').single.groupLabel,
        'Exchange');
  });

  test('both spellings present yield exactly one row per measure', () {
    final rows = KycLimitLabels.rows(null, {
      'cashin_daily': 111,
      'cashin_daily_limit': 222,
    });

    final daily = rows.where((r) => r.measureLabel == 'per day').toList();
    expect(daily, hasLength(1));
    expect(daily.single.value, '111');
  });

  test('renders the production L1 limits shape including zero caps', () {
    final rows = KycLimitLabels.rows(null, {
      'transfer_maximum': 100,
      'transfer_daily_limit': 100,
      'payment_maximum': 100,
      'gift_maximum': 100,
      'paycardo_topup_limit': 100,
      'cashout_minimum': 0,
      'cashout_maximum': 0,
      'cashout_daily_limit': 0,
      'cashout_monthly_limit': 0,
    });

    expect(rows, isNotEmpty);
    expect(rows.last.groupLabel, 'PayCardo top-up');
    expect(rows.last.measureLabel, isNull);
    final zeroed = rows
        .where((r) => r.groupLabel == 'Cash-out')
        .map((r) => r.value)
        .toList();
    expect(zeroed, everyElement('0'));
  });

  test('null or empty limits render nothing', () {
    expect(KycLimitLabels.rows(null, null), isEmpty);
    expect(KycLimitLabels.rows(null, {}), isEmpty);
  });
}
