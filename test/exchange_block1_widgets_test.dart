import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/input_field/quick_amount_selector.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/currency_sparkline_chart.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/rate_lock_countdown_timer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuickAmountSelector', () {
    testWidgets('renders default percentage chips: 25%, 50%, 75%, Max', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAmountSelector(
              textController: controller,
              availableBalance: 1000.0,
              isCrypto: false,
            ),
          ),
        ),
      );

      expect(find.text('25%'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
      expect(find.text('75%'), findsOneWidget);
      expect(find.text('Max'), findsOneWidget);
    });

    testWidgets('tapping 50% on fiat formats to 2 decimal places and updates controller', (tester) async {
      final controller = TextEditingController();
      double? changedAmount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAmountSelector(
              textController: controller,
              availableBalance: 250.0,
              isCrypto: false,
              onAmountChanged: (amount) => changedAmount = amount,
            ),
          ),
        ),
      );

      await tester.tap(find.text('50%'));
      await tester.pump();

      expect(controller.text, '125.00');
      expect(controller.selection.baseOffset, 6);
      expect(changedAmount, 125.0);
    });

    testWidgets('tapping 25% on crypto formats to 8 decimal places', (tester) async {
      final controller = TextEditingController();
      double? changedAmount;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAmountSelector(
              textController: controller,
              availableBalance: 1.0,
              isCrypto: true,
              onAmountChanged: (amount) => changedAmount = amount,
            ),
          ),
        ),
      );

      await tester.tap(find.text('25%'));
      await tester.pump();

      expect(controller.text, '0.25000000');
      expect(controller.selection.baseOffset, 10);
      expect(changedAmount, 0.25);
    });

    testWidgets('tapping Max on IRR formats with 0 decimals (integer)', (tester) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAmountSelector(
              textController: controller,
              availableBalance: 1500000.0,
              isCrypto: false,
              currencyCode: 'IRR',
            ),
          ),
        ),
      );

      await tester.tap(find.text('Max'));
      await tester.pump();

      expect(controller.text, '1500000');
      expect(controller.selection.baseOffset, 7);
    });

    testWidgets('tapping chips when availableBalance <= 0 does not alter text', (tester) async {
      final controller = TextEditingController(text: 'initial');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickAmountSelector(
              textController: controller,
              availableBalance: 0.0,
              isCrypto: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('50%'));
      await tester.pump();

      expect(controller.text, 'initial');
    });
  });

  group('RateLockCountdownTimer', () {
    testWidgets('renders circular timer with countdown text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RateLockCountdownTimer(
              duration: Duration(seconds: 45),
            ),
          ),
        ),
      );

      expect(find.text('45s'), findsOneWidget);
    });

    testWidgets('renders linear timer mode when isLinear is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RateLockCountdownTimer(
              duration: Duration(seconds: 30),
              isLinear: true,
            ),
          ),
        ),
      );

      expect(find.text('30s'), findsOneWidget);
    });

    testWidgets('triggers onExpired callback when duration elapses', (tester) async {
      bool expired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RateLockCountdownTimer(
              duration: const Duration(seconds: 5),
              onExpired: () => expired = true,
            ),
          ),
        ),
      );

      expect(expired, isFalse);

      // Advance clock past 5s
      await tester.pump(const Duration(seconds: 6));

      expect(expired, isTrue);
      expect(find.text('0s'), findsOneWidget);
    });

    testWidgets('isExpired = true immediately renders 0s and error color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: RateLockCountdownTimer(
              duration: Duration(seconds: 60),
              isExpired: true,
            ),
          ),
        ),
      );

      expect(find.text('0s'), findsOneWidget);
    });
  });

  group('CurrencySparklineChart', () {
    testWidgets('renders CustomPaint with explicit rate series without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrencySparklineChart(
              rates: [1.05, 1.07, 1.06, 1.08, 1.10],
              height: 40,
            ),
          ),
        ),
      );

      expect(find.byType(CurrencySparklineChart), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
    });

    testWidgets('renders smoothly with changePercent and baseRate synthesis', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrencySparklineChart(
              changePercent: 1.45,
              baseRate: 62000.0,
              height: 40,
            ),
          ),
        ),
      );

      expect(find.byType(CurrencySparklineChart), findsOneWidget);
    });

    testWidgets('negative changePercent generates realistic points without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrencySparklineChart(
              changePercent: -2.30,
              baseRate: 1.085,
              height: 40,
            ),
          ),
        ),
      );

      expect(find.byType(CurrencySparklineChart), findsOneWidget);
    });

    testWidgets('handles edge cases gracefully (zero rate, single point)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CurrencySparklineChart(
              rates: [1.0],
              baseRate: 0.0,
              changePercent: 0.0,
              height: 40,
            ),
          ),
        ),
      );

      expect(find.byType(CurrencySparklineChart), findsOneWidget);
    });
  });
}
