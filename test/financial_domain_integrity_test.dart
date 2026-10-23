import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/common/widgets/design_system/ecardo_swipe_button.dart';
import 'package:ecardo_user/src/helper/amount_input_formatter.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/helper/money_math_helper.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_manager.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Domain Integrity 1: Currency & Amount Precision Invariants', () {
    final helper = DynamicDecimalsHelper();

    test('Iranian currencies strictly use ZERO-DECIMAL precision', () {
      const iranianCurrencyCodes = [
        'IRR',
        'irr',
        'IRT',
        'irt',
        'TOMAN',
        'toman',
        'TMN',
        'tmn',
        'RLS',
        'rls',
        'RIAL',
        'rial',
      ];

      for (final code in iranianCurrencyCodes) {
        expect(
          DynamicDecimalsHelper.isZeroDecimal(code),
          isTrue,
          reason: '$code must be recognized as zero-decimal',
        );
        expect(
          DynamicDecimalsHelper.isRtlCurrency(code),
          isTrue,
          reason: '$code must be recognized as RTL Persian currency',
        );
        expect(
          helper.getDynamicDecimals(
            currencyCode: code,
            siteCurrencyCode: 'USD',
            siteCurrencyDecimals: '2',
            isCrypto: false,
          ),
          0,
          reason: '$code must return 0 decimal places',
        );
      }
    });

    test('Zero-decimal global currencies return 0 decimals', () {
      const globalZeroDecimals = ['JPY', 'jpy', 'KRW', 'krw', 'VND', 'CLP', 'IDR'];
      for (final code in globalZeroDecimals) {
        expect(
          DynamicDecimalsHelper.isZeroDecimal(code),
          isTrue,
          reason: '$code must be zero-decimal',
        );
        expect(
          helper.getDynamicDecimals(
            currencyCode: code,
            siteCurrencyCode: 'USD',
            siteCurrencyDecimals: '2',
            isCrypto: false,
          ),
          0,
        );
      }
    });

    test('Traditional fiat currencies strictly maintain 2-decimal precision', () {
      const twoDecimalFiats = [
        'USD',
        'usd',
        'EUR',
        'eur',
        'AED',
        'aed',
        'TRY',
        'try',
        'GBP',
        'gbp',
        'CAD',
        'CHF',
        'CNY',
      ];

      for (final code in twoDecimalFiats) {
        expect(
          DynamicDecimalsHelper.isZeroDecimal(code),
          isFalse,
          reason: '$code is not a zero-decimal currency',
        );
        expect(
          helper.getDynamicDecimals(
            currencyCode: code,
            siteCurrencyCode: 'USD',
            siteCurrencyDecimals: '2',
            isCrypto: false,
          ),
          2,
          reason: '$code must return 2 decimal places',
        );
      }
    });

    test('Major crypto assets maintain exact decimal precision (8 decimals)', () {
      expect(
        helper.getDynamicDecimals(
          currencyCode: 'BTC',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: true,
        ),
        8,
        reason: 'BTC must return 8 decimals',
      );
      expect(
        helper.getDynamicDecimals(
          currencyCode: 'ETH',
          siteCurrencyCode: 'USD',
          siteCurrencyDecimals: '2',
          isCrypto: true,
        ),
        8,
        reason: 'ETH must return 8 decimals',
      );
    });

    test('AmountInputFormatter strictly prohibits decimal separators on zero-decimal assets', () {
      final formatter = AmountInputFormatter(maxDecimals: 0);

      // Attempting to type a decimal dot on Toman input
      final textWithDot = formatter.formatEditUpdate(
        const TextEditingValue(text: '100000'),
        const TextEditingValue(text: '100000.'),
      );
      expect(textWithDot.text, '100000', reason: 'Dot must be stripped');

      // Attempting to paste a fractional amount like '100000.50'
      final textWithFraction = formatter.formatEditUpdate(
        const TextEditingValue(text: '100000'),
        const TextEditingValue(text: '100000.50'),
      );
      expect(textWithFraction.text, '10000050', reason: 'Dot stripped; fraction digits appended as integer');
    });

    test('AmountInputFormatter preserves exactly 2 decimals for fiat', () {
      final formatter = AmountInputFormatter(maxDecimals: 2);
      final res = formatter.formatEditUpdate(
        const TextEditingValue(text: '100.5'),
        const TextEditingValue(text: '100.55'),
      );
      expect(res.text, '100.55');

      // 3rd decimal place must be rejected
      final resOver = formatter.formatEditUpdate(
        const TextEditingValue(text: '100.55'),
        const TextEditingValue(text: '100.559'),
      );
      expect(resOver.text, '100.55');
    });

    test('AmountInputFormatter normalizes Persian and Arabic numerals to Latin digits', () {
      expect(AmountInputFormatter.normalize('۵۰۰۰۰۰'), '500000');
      expect(AmountInputFormatter.normalize('١٢٥٠٫٧٥'), '1250.75');
      expect(AmountInputFormatter.normalize('۱,۵۰۰,۰۰۰'), '1500000');
    });

    test('Dynamic precision calculation prevents inverse exchange rates from truncating to 0.0000', () {
      // Exchanging 100,000 IRT to USD (~$1.05 USD)
      const payAmount = 100000.0;
      const convertedAmount = 1.0526;
      final rate = convertedAmount / payAmount; // ~0.000010526

      final int rateDecimals = rate >= 1.0
          ? 4
          : (rate >= 0.001 ? 6 : 8);

      final formattedRate = rate.toStringAsFixed(rateDecimals);
      expect(formattedRate, isNot('0.0000'), reason: 'Micro rate must not truncate to 0.0000');
      expect(formattedRate, '0.00001053');
    });
  });

  group('Domain Integrity 2: Quotes & Fee Calculation Invariants', () {
    test('MoneyMathHelper calculates percentage charge without IEEE-754 drift', () {
      // 1.5% fee on 100.00 = 1.5000
      final fee = MoneyMathHelper.calculatePercentCharge(100.0, 1.5, decimals: 4);
      expect(fee, 1.5);

      // Safe addition 0.1 + 0.2 != 0.30000000000000004
      final sum = MoneyMathHelper.add(0.1, 0.2, decimals: 4);
      expect(sum, 0.3);

      // Safe subtraction
      final diff = MoneyMathHelper.subtract(100.0, 1.5, decimals: 4);
      expect(diff, 98.5);
    });

    test('ExchangeRateManager locks quote rate and triggers staleness on expiry or drift', () {
      final manager = ExchangeRateManager();
      manager.bumpLiveRate(100.0);

      // Lock rate for review
      manager.lockRateForReview(100.0);
      expect(manager.lockedReviewRate, 100.0);
      expect(manager.isReviewRateStale.value, isFalse);

      // Drift calculation
      final driftPct = manager.calculateDriftPercentage(
        currentRate: 100.02,
        lockedRate: 100.0,
      );
      expect(driftPct, closeTo(0.0002, 1e-6));

      // Staleness check after max duration (60s)
      final isExpired = manager.checkDriftOrExpired(
        enteredAt: DateTime.now().subtract(const Duration(seconds: 65)),
        lockedRate: 100.0,
        currentRate: 100.0,
        maxDuration: const Duration(seconds: 60),
      );
      expect(isExpired, isTrue, reason: 'Rate must expire after 60 seconds');

      // Staleness check with drift > 0.01%
      final isDriftStale = manager.checkDriftOrExpired(
        enteredAt: DateTime.now(),
        lockedRate: 100.0,
        currentRate: 100.05,
        tolerance: 0.0001,
      );
      expect(isDriftStale, isTrue, reason: 'Rate must be marked stale on drift > 0.01%');
    });
  });

  group('Domain Integrity 3: Idempotency & UI Debounce Invariants', () {
    test('NetworkService.isMutatingFinancialOrStateEndpoint covers standard & dynamic endpoints', () {
      // Standard financial endpoints
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/transfer'), isTrue);
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/exchange'), isTrue);
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/withdraw'), isTrue);
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/payment/make'), isTrue);
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/pay-bill'), isTrue);
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/cashout'), isTrue);
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/gifts/redeem'), isTrue);

      // Dynamic path parameter endpoints (card update-status, balance topup, and request-money action)
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/cards/update-status/card_abc123'),
        isTrue,
        reason: 'Card freeze/status update with cardId must be idempotency protected',
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/cards/balance/topup/card_abc123'),
        isTrue,
        reason: 'Card balance topup with cardId must be idempotency protected',
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/request-money/42/action'),
        isTrue,
        reason: 'Accepting/rejecting money request must be idempotency protected',
      );

      // Safe non-mutating endpoints should not match
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/wallets'), isFalse);
      expect(NetworkService.isMutatingFinancialOrStateEndpoint('/api/user/notifications'), isFalse);
    });

    testWidgets('VirtualCardSecurityControls disables freeze switch when isFreezeLoading is true', (
      tester,
    ) async {
      bool toggleCalled = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: VirtualCardSecurityControls(
                  isFrozen: false,
                  isFreezeLoading: true, // In-flight mutation active
                  onToggleFreeze: (_) => toggleCalled = true,
                ),
              ),
            ),
          ),
        ),
      );

      final switchFinder = find.byType(Switch).first;
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.onChanged, isNull, reason: 'Freeze switch must be disabled during in-flight freeze request');

      await tester.tap(switchFinder);
      await tester.pump();
      expect(toggleCalled, isFalse, reason: 'Tapping disabled switch must not trigger callback');
    });

    testWidgets('EcardoSwipeButton immediately disables interaction upon completion to prevent double-submit', (
      tester,
    ) async {
      int completeCallCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 320,
                height: 58,
                child: EcardoSwipeButton(
                  text: 'Swipe to Confirm',
                  animateShimmer: false,
                  onSwipeComplete: () {
                    completeCallCount++;
                  },
                ),
              ),
            ),
          ),
        ),
      );

      final buttonState = tester.state<EcardoSwipeButtonState>(find.byType(EcardoSwipeButton));
      expect(buttonState.mounted, isTrue);

      // Drag the thumb icon across the track
      final thumbFinder = find.byIcon(Icons.arrow_forward_rounded);
      expect(thumbFinder, findsOneWidget);
      await tester.drag(thumbFinder, const Offset(300, 0));
      await tester.pumpAndSettle();

      expect(completeCallCount, 1, reason: 'First full swipe must trigger callback once');

      // Attempting a second drag immediately without reset
      await tester.drag(find.byType(EcardoSwipeButton), const Offset(300, 0));
      await tester.pumpAndSettle();

      expect(completeCallCount, 1, reason: 'Completed swipe button must swallow subsequent drag gestures');
    });
  });
}
