import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/controller/exchange_controller.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/model/exchange_wallet_model.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/service/exchange_rate_service.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/view/sub_sections/exchange_amount_step_section.dart';
import 'package:ecardo_user/src/presentation/screens/exchange/widgets/rate_lock_countdown_timer.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/currencies_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class _MockExchangeController extends ExchangeController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockExchangeController controller;

  setUp(() {
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<SettingsService>(SettingsService());
    if (!Get.isRegistered<ExchangeRateService>()) {
      Get.put<ExchangeRateService>(ExchangeRateService());
    }
    controller = _MockExchangeController();
    Get.put<ExchangeController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  Widget createTestWidget(Widget child) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => GetMaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(body: child),
      ),
    );
  }

  group('Rate Lock Timer & Drift Expiration', () {
    testWidgets('RateLockCountdownTimer renders and fires onExpired when countdown reaches 0', (
      tester,
    ) async {
      bool expiredFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RateLockCountdownTimer(
              duration: const Duration(seconds: 2),
              onExpired: () => expiredFired = true,
            ),
          ),
        ),
      );

      // Verify timer is rendered with circular progress indicator
      expect(find.byType(RateLockCountdownTimer), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);
      expect(expiredFired, false);

      // Advance time by 2.5 seconds to expire the timer
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 1500));

      expect(expiredFired, true);
    });

    testWidgets('RateLockCountdownTimer forces expired state and calls onExpired', (
      tester,
    ) async {
      bool expiredFired = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RateLockCountdownTimer(
              duration: const Duration(seconds: 60),
              isExpired: true,
              onExpired: () => expiredFired = true,
            ),
          ),
        ),
      );

      expect(find.byType(RateLockCountdownTimer), findsOneWidget);
      await tester.pump();
      expect(expiredFired, true);
    });

    test('ExchangeRateManager flags review rate stale after 60s or drift > 0.01%', () {
      final manager = controller.rateManager;
      manager.currentRate.value = 1.0;
      manager.lockRateForReview();

      expect(manager.isReviewRateStale.value, false);
      expect(manager.lockedReviewRate, 1.0);

      // Drift check: 0.005% drift is within 0.01% tolerance
      final withinTolerance = manager.checkDriftOrExpired(
        enteredAt: DateTime.now(),
        lockedRate: 1.0,
        currentRate: 1.00005,
      );
      expect(withinTolerance, false);

      // Drift check: 0.02% drift exceeds 0.01% tolerance -> stale
      final exceedsDrift = manager.checkDriftOrExpired(
        enteredAt: DateTime.now(),
        lockedRate: 1.0,
        currentRate: 1.0002,
      );
      expect(exceedsDrift, true);

      // 60-second expiration check
      final expired = manager.checkDriftOrExpired(
        enteredAt: DateTime.now().subtract(const Duration(seconds: 61)),
        lockedRate: 1.0,
        currentRate: 1.0,
      );
      expect(expired, true);
    });
  });

  group('Rate Swap Calculation & Dynamic Precision', () {
    test('calculateStaticRate and swapWallets correctly computes cross-rates', () {
      final currencies = [
        CurrenciesData(code: 'USD', conversionRate: '1.0'),
        CurrenciesData(code: 'IRT', conversionRate: '95000.0'),
        CurrenciesData(code: 'EUR', conversionRate: '0.92'),
      ];
      controller.currenciesList.assignAll(currencies);

      final usdWallet = Wallets(id: 1, code: 'USD', name: 'USD Wallet', balance: '100');
      final irtWallet = Wallets(id: 2, code: 'IRT', name: 'Toman Wallet', balance: '9500000');

      controller.fromWallet.value = usdWallet;
      controller.toWallet.value = irtWallet;

      controller.calculateExchange();
      // 1 USD = 95,000 / 1.0 = 95,000 IRT
      expect(controller.exchangeRate.value, 95000.0);
      expect(
        ExchangeController.formatDynamicRate(controller.exchangeRate.value, targetCurrencyCode: 'IRT'),
        '95000',
      );

      // Swap wallets: IRT -> USD
      controller.swapWallets();
      expect(controller.fromWallet.value?.code, 'IRT');
      expect(controller.toWallet.value?.code, 'USD');

      // 1 IRT = 1.0 / 95,000 ≈ 0.0000105263 USD
      final rate = controller.exchangeRate.value;
      expect(rate, closeTo(0.000010526, 0.000001));

      // Dynamic precision must scale to 8 decimals for fractional rate
      final formattedFractionalRate = ExchangeController.formatDynamicRate(rate, targetCurrencyCode: 'USD');
      expect(formattedFractionalRate.length, greaterThanOrEqualTo(8));
      expect(formattedFractionalRate.startsWith('0.0000105'), true);
    });

    test('liveToAmount rounds to whole number when target is zero-decimal Toman', () {
      controller.fromWallet.value = Wallets(code: 'USD');
      controller.toWallet.value = Wallets(code: 'IRT');
      controller.currentRate.value = 95234.56;
      controller.amountController.text = '10';

      controller.onAmountChanged('10');
      // 10 * 95234.56 = 952345.6 -> rounded to 952346 for zero-decimal Toman
      expect(controller.liveToAmount.value, 952346.0);
    });
  });

  group('UI State Matrix Resilience (Normal, Loading, Empty, Error, Offline)', () {
    testWidgets('renders EcardoErrorView on Offline state', (tester) async {
      controller.isOffline.value = true;
      controller.walletLoadError.value = false;

      await tester.pumpWidget(createTestWidget(const ExchangeAmountStepSection()));
      await tester.pump();

      expect(find.byKey(const ValueKey('exchange_offline_state')), findsOneWidget);
      expect(find.byType(EcardoErrorView), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
    });

    testWidgets('renders EcardoErrorView on Error state', (tester) async {
      controller.isOffline.value = false;
      controller.walletLoadError.value = true;
      controller.walletErrorMessage.value = 'Failed to fetch wallets';

      await tester.pumpWidget(createTestWidget(const ExchangeAmountStepSection()));
      await tester.pump();

      expect(find.byKey(const ValueKey('exchange_error_state')), findsOneWidget);
      expect(find.byType(EcardoErrorView), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });

    testWidgets('renders EcardoEmptyState on Empty state (no wallets, not error)', (tester) async {
      controller.isOffline.value = false;
      controller.walletLoadError.value = false;
      controller.isLoading.value = false;
      controller.fromExchangeWalletsList.clear();

      await tester.pumpWidget(createTestWidget(const ExchangeAmountStepSection()));
      await tester.pump();

      expect(find.byKey(const ValueKey('exchange_empty_state')), findsOneWidget);
      expect(find.byType(EcardoEmptyState), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('renders Normal exchange form when wallets are available', (tester) async {
      controller.isOffline.value = false;
      controller.walletLoadError.value = false;
      controller.isLoading.value = false;

      final usd = Wallets(id: 1, code: 'USD', name: 'Main USD', balance: '500');
      final irt = Wallets(id: 2, code: 'IRT', name: 'Toman Wallet', balance: '1000000');
      controller.fromExchangeWalletsList.assignAll([usd, irt]);
      controller.toExchangeWalletsList.assignAll([usd, irt]);
      controller.fromWallet.value = usd;
      controller.toWallet.value = irt;

      await tester.pumpWidget(createTestWidget(const ExchangeAmountStepSection()));
      await tester.pump();

      // Normal form should show From/To swap card and live rate badge
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text('Main USD'), findsOneWidget);
      expect(find.text('Toman Wallet'), findsOneWidget);
    });
  });
}
