import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';

void main() {
  group('DynamicDecimalsHelper — Currency Decimals Invariants', () {
    final helper = DynamicDecimalsHelper();

    test('strictly strips all decimals (returns 0) for Toman and Rial variants', () {
      const zeroDecimalCodes = [
        'TOMAN',
        'toman',
        'TMN',
        'tmn',
        'IRT',
        'irt',
        'IRR',
        'irr',
        'RLS',
        'RIAL',
        'JPY',
        'KRW',
      ];

      for (final code in zeroDecimalCodes) {
        final decimals = helper.getDynamicDecimals(
          currencyCode: code,
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: false,
        );
        expect(decimals, 0, reason: 'Currency $code must have 0 decimals');
      }
    });

    test('returns strictly 2 decimals for USD, EUR, and Yuan (CNY/RMB)', () {
      const twoDecimalCodes = [
        'USD',
        'usd',
        'EUR',
        'CNY',
        'cny',
        'RMB',
        'YUAN',
        'GBP',
        'AED',
        'TRY',
      ];

      for (final code in twoDecimalCodes) {
        final decimals = helper.getDynamicDecimals(
          currencyCode: code,
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: false,
        );
        expect(decimals, 2, reason: 'Currency $code must have 2 decimals');
      }
    });

    test('crypto assets default to 8 decimals unless in zero/two decimal list', () {
      expect(
        helper.getDynamicDecimals(
          currencyCode: 'BTC',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: true,
        ),
        8,
      );
      expect(
        helper.getDynamicDecimals(
          currencyCode: 'ETH',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: true,
        ),
        8,
      );
      expect(
        helper.getDynamicDecimals(
          currencyCode: 'USDT',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: true,
        ),
        8,
      );
    });
  });
}
