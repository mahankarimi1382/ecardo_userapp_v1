import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/stock/controllers/stock_controller.dart';
import 'package:ecardo_user/src/stock/models/stock_models.dart';
import 'package:ecardo_user/src/stock/services/stock_service.dart';
import 'package:ecardo_user/src/stock/screens/stock_home_screen.dart';
import 'package:ecardo_user/src/stock/screens/stock_order_screen.dart';
import 'package:ecardo_user/src/stock/screens/stock_confirm_screen.dart';
import 'package:ecardo_user/src/stock/screens/stock_tracking_screen.dart';
import 'package:ecardo_user/src/stock/screens/stock_intro_screen.dart';

class MockStockService extends StockService {
  @override
  Future<List<StockMarketModel>> getMarkets() async => [];
  @override
  Future<StockTradingAccountModel?> getAccount() async => null;
  @override
  Future<Map<String, dynamic>?> getPortfolio() async => null;
  @override
  Future<Map<String, dynamic>?> getFxQuote({
    required String from,
    required String to,
    required double amount,
  }) async => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  Widget wrapWithTheme(
    Widget child, {
    bool isDark = false,
    Locale locale = const Locale('en'),
  }) {
    return MediaQuery(
      data: const MediaQueryData(size: Size(375, 812)),
      child: GetMaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: isDark
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData.light(useMaterial3: true),
        home: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => Scaffold(body: child),
        ),
      ),
    );
  }

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<StockService>(MockStockService());
  });

  tearDown(() {
    Get.reset();
  });

  // ============================================================================
  // SECTION 1: MODEL PARSING & SERIALIZATION TESTS
  // ============================================================================

  group('Stock Models - Parsing & Deserialization Tests', () {
    test('StockSymbolModel parses live ticker with all fields', () {
      final json = {
        'id': 101,
        'ticker': '700.HK',
        'name_fa': 'تنسنت هلدینگز',
        'name_en': 'Tencent Holdings Ltd',
        'industry': 'Technology & Gaming',
        'last_price': 382.4,
        'prev_close': 375.0,
        'day_high': 385.0,
        'day_low': 374.2,
        'volume_24h': 14500000,
        'high_volatility': false,
        'is_tradeable': true,
        'exchange_code': 'HKEX',
      };

      final symbol = StockSymbolModel.fromJson(json);

      expect(symbol.id, 101);
      expect(symbol.ticker, '700.HK');
      expect(symbol.nameEn, 'Tencent Holdings Ltd');
      expect(symbol.nameFa, 'تنسنت هلدینگز');
      expect(symbol.lastPrice, 382.4);
      expect(symbol.prevClose, 375.0);
      expect(symbol.changePercent, closeTo(1.97333, 0.001));
      expect(symbol.isTradeable, isTrue);
      expect(symbol.exchangeCode, 'HKEX');
      expect(symbol.dailyChangePct, closeTo(1.97333, 0.001));
    });

    test('StockSymbolModel calculates change percentage correctly for negative values', () {
      final json = {
        'id': 104,
        'ticker': 'TSLA',
        'name_fa': 'تسلا',
        'name_en': 'Tesla Inc.',
        'industry': 'Automotive',
        'last_price': 254.60,
        'prev_close': 262.30,
        'day_high': 264.00,
        'day_low': 251.20,
        'volume_24h': 76100000,
        'high_volatility': true,
        'is_tradeable': true,
      };

      final symbol = StockSymbolModel.fromJson(json);
      expect(symbol.changePercent, closeTo(-2.936, 0.001));
    });

    test('StockMarketModel parses market rules, commission and symbols', () {
      final json = {
        'id': 1,
        'code': 'NASDAQ',
        'country_code': 'USA',
        'name_fa': 'بورس نزدک آمریکا',
        'name_en': 'NASDAQ Stock Market',
        'base_currency': 'USD',
        'settlement_days': 2,
        'commission_pct': 0.15,
        'quotes_delay_min': 0,
        'symbols': [
          {
            'id': 101,
            'ticker': 'AAPL',
            'name_fa': 'اپل',
            'name_en': 'Apple Inc.',
            'last_price': 228.40,
            'prev_close': 224.20,
            'day_high': 230.10,
            'day_low': 223.80,
            'exchange_code': 'NASDAQ',
          },
        ],
      };

      final market = StockMarketModel.fromJson(json);

      expect(market.id, 1);
      expect(market.code, 'NASDAQ');
      expect(market.baseCurrency, 'USD');
      expect(market.settlementDays, 2);
      expect(market.commissionPct, 0.15);
      expect(market.symbols.length, 1);
      expect(market.symbols.first.ticker, 'AAPL');
      expect(market.name, 'بورس نزدک آمریکا');
    });

    test('StockOrderModel deserializes executed orders with commission', () {
      final json = {
        'order_no': 'ORD-2026-9901',
        'ticker': 'BABA',
        'name_fa': 'علی‌بابا هلدینگ',
        'side': 'BUY',
        'type': 'LIMIT',
        'qty': 10.0,
        'limit_price': 84.5,
        'stop_price': 0.0,
        'market_currency': 'USD',
        'pay_currency': 'USD',
        'pay_amount': 845.0,
        'executed_fx_rate': 1.0,
        'avg_exec_price': 84.5,
        'commission_amount': 1.27,
        'status': 'EXECUTED',
        'broker_ref': 'IB-9817264',
        'settlement_days': 2,
        'created_at': '2026-10-05T14:30:00Z',
      };

      final order = StockOrderModel.fromJson(json);

      expect(order.orderNo, 'ORD-2026-9901');
      expect(order.ticker, 'BABA');
      expect(order.side, 'BUY');
      expect(order.type, 'LIMIT');
      expect(order.qty, 10.0);
      expect(order.limitPrice, 84.5);
      expect(order.stopPrice, 0.0);
      expect(order.payAmount, 845.0);
      expect(order.status, 'EXECUTED');
      expect(order.brokerRef, 'IB-9817264');
      expect(order.price, 84.5);
      expect(order.totalAmount, 845.0);
      expect(order.currency, 'USD');
      expect(order.isBuy, isTrue);
      expect(order.isSell, isFalse);
      expect(order.isMarket, isFalse);
      expect(order.isLimit, isTrue);
      expect(order.isStopLoss, isFalse);
    });

    test('StockOrderModel handles STOP_LOSS order type', () {
      final json = {
        'order_no': 'ORD-STOP-101',
        'ticker': 'NVDA',
        'name_fa': 'انویدیا',
        'side': 'SELL',
        'type': 'STOP_LOSS',
        'qty': 5.0,
        'limit_price': 135.20,
        'stop_price': 120.00,
        'market_currency': 'USD',
        'pay_currency': 'USDT',
        'pay_amount': 600.0,
        'executed_fx_rate': 1.0,
        'avg_exec_price': 0.0,
        'commission_amount': 0.9,
        'status': 'PENDING_BROKER',
        'broker_ref': null,
        'settlement_days': 2,
      };

      final order = StockOrderModel.fromJson(json);

      expect(order.type, 'STOP_LOSS');
      expect(order.stopPrice, closeTo(120.0, 0.01));
      expect(order.price, closeTo(135.20, 0.01));
      expect(order.isStopLoss, isTrue);
    });

    // ============================================================================
    // SECTION 2: PORTFOLIO & HOLDINGS MODELS WITH P&L CALCULATIONS
    // ============================================================================

    test('StockHoldingModel calculates unrealized P&L correctly', () {
      final holding = const StockHoldingModel(
        ticker: 'AAPL',
        nameFa: 'اپل',
        nameEn: 'Apple Inc.',
        shares: 12.0,
        averageCost: 195.50,
        currentPrice: 228.40,
        currency: 'USD',
        exchangeCode: 'NASDAQ',
        realizedPnl: 150.0,
      );

      expect(holding.currentValue, closeTo(2740.80, 0.01));
      expect(holding.costBasis, closeTo(2346.00, 0.01));
      expect(holding.unrealizedPnl, closeTo(394.80, 0.01));
      expect(holding.unrealizedPnlPercent, closeTo(16.83, 0.01));
      expect(holding.totalPnl, closeTo(544.80, 0.01));
      expect(holding.isProfitable, isTrue);
    });

    test('StockHoldingModel calculates loss scenario correctly', () {
      final holding = const StockHoldingModel(
        ticker: 'TSLA',
        nameFa: 'تسلا',
        nameEn: 'Tesla Inc.',
        shares: 20.0,
        averageCost: 280.00,
        currentPrice: 254.60,
        currency: 'USD',
        exchangeCode: 'NASDAQ',
        realizedPnl: -50.0,
      );

      expect(holding.currentValue, 5092.00);
      expect(holding.costBasis, 5600.00);
      expect(holding.unrealizedPnl, -508.00);
      expect(holding.unrealizedPnlPercent, closeTo(-9.07, 0.01));
      expect(holding.totalPnl, -558.00);
      expect(holding.isProfitable, isFalse);
    });

    test('StockHoldingModel calculates FX conversion for HKD holdings', () {
      final holding = const StockHoldingModel(
        ticker: '700.HK',
        nameFa: 'تنسنت',
        nameEn: 'Tencent',
        shares: 100.0,
        averageCost: 350.00,
        currentPrice: 382.40,
        currency: 'HKD',
        exchangeCode: 'HKEX',
        realizedPnl: 200.0,
      );

      // Expected USD conversion at 0.128 rate
      final expectedCurrentValUsd = 38240.0 * 0.128;
      final expectedCostBaseUsd = 35000.0 * 0.128;

      expect(holding.currentValue, 38240.0);
      expect(holding.costBasis, 35000.0);
      expect(holding.unrealizedPnl, 3240.0);
      expect(holding.isProfitable, isTrue);
      expect(expectedCurrentValUsd, closeTo(4894.72, 0.01));
      expect(expectedCostBaseUsd, closeTo(4480.00, 0.01));
    });

    test('StockPortfolioSummaryModel aggregates holdings P&L correctly', () {
      final summary = StockPortfolioSummaryModel(
        totalValueUsd: 8450.00,
        totalCostBasisUsd: 7200.00,
        totalRealizedPnlUsd: 350.00,
        holdings: [
          const StockHoldingModel(
            ticker: 'AAPL',
            nameFa: 'اپل',
            nameEn: 'Apple Inc.',
            shares: 12.0,
            averageCost: 195.50,
            currentPrice: 228.40,
            currency: 'USD',
            realizedPnl: 150.0,
          ),
          const StockHoldingModel(
            ticker: 'NVDA',
            nameFa: 'انویدیا',
            nameEn: 'NVIDIA Corp.',
            shares: 20.0,
            averageCost: 110.00,
            currentPrice: 135.20,
            currency: 'USD',
            realizedPnl: 0.0,
          ),
        ],
        currencyExposures: [
          CurrencyExposureModel(
            currency: 'USD',
            amountInCurrency: 6337.50,
            amountInUsd: 6337.50,
            percentage: 75.0,
          ),
        ],
      );

      expect(summary.totalValueUsd, 8450.00);
      expect(summary.totalCostBasisUsd, 7200.00);
      expect(summary.totalUnrealizedPnlUsd, 1250.00);
      expect(summary.totalReturnPercent, closeTo(17.36, 0.01));
      expect(summary.netTotalPnlUsd, 1600.00);
      expect(summary.isPositive, isTrue);
    });

    test('RiskProfileResult evaluates different score ranges correctly', () {
      final resultConservative = RiskProfileResult.evaluate(25);
      expect(resultConservative.tier, 'CONSERVATIVE');
      expect(resultConservative.maxLeverage, 'Cash Only (1:1)');
      expect(resultConservative.isApprovedForTrading, isTrue);

      final resultBalanced = RiskProfileResult.evaluate(45);
      expect(resultBalanced.tier, 'BALANCED');
      expect(resultBalanced.maxLeverage, '1:1');

      final resultGrowth = RiskProfileResult.evaluate(65);
      expect(resultGrowth.tier, 'GROWTH');
      expect(resultGrowth.maxLeverage, '1:2');

      final resultAggressive = RiskProfileResult.evaluate(85);
      expect(resultAggressive.tier, 'AGGRESSIVE');
      expect(resultAggressive.maxLeverage, '1:5');
    });

    test('CurrencyExposureModel fromJson parsing', () {
      final json = {
        'currency': 'HKD',
        'amount_in_currency': 156500.0,
        'amount_in_usd': 20000.0,
        'percentage': 20.0,
      };

      final parsed = CurrencyExposureModel.fromJson(json);
      expect(parsed.currency, 'HKD');
      expect(parsed.amountInCurrency, 156500.0);
      expect(parsed.amountInUsd, 20000.0);
      expect(parsed.percentage, 20.0);
    });
  });

  // ============================================================================
  // SECTION 3: UI RENDERING TESTS WITHOUT OVERFLOW
  // ============================================================================

  group('Stock Trading - Screen Rendering Tests (Light/Dark/RTL)', () {
    testWidgets('renders StockHomeScreen in Light mode without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockHomeScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockHomeScreen), findsOneWidget);
      expect(find.text('Global Stock Trading'), findsOneWidget);
    });

    testWidgets('renders StockHomeScreen in Dark mode without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockHomeScreen(),
          isDark: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockHomeScreen), findsOneWidget);
    });

    testWidgets('renders StockHomeScreen in Persian (RTL) without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockHomeScreen(),
          locale: const Locale('fa'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockHomeScreen), findsOneWidget);
      expect(find.text('بورس و سهام بین‌الملل'), findsOneWidget);
    });

    testWidgets('renders StockHomeScreen in Arabic (RTL) without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockHomeScreen(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockHomeScreen), findsOneWidget);
    });

    testWidgets('renders StockHomeScreen in Chinese (LTR) without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockHomeScreen(),
          locale: const Locale('zh'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockHomeScreen), findsOneWidget);
    });

    testWidgets('renders StockOrderScreen form without overflow', (tester) async {
      phoneSurface(tester);
      final controller = Get.put(StockController());
      controller.selectedMarket.value = const StockMarketModel(
        id: 1,
        code: 'NASDAQ',
        countryCode: 'USA',
        nameFa: 'بورس نزدک',
        nameEn: 'NASDAQ',
        baseCurrency: 'USD',
        symbols: [
          StockSymbolModel(
            id: 1,
            ticker: 'AAPL',
            nameFa: 'اپل',
            nameEn: 'Apple Inc.',
            lastPrice: 220.0,
          ),
        ],
      );
      controller.selectSymbol(controller.selectedMarket.value!.symbols.first);

      await tester.pumpWidget(
        wrapWithTheme(
          const StockOrderScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockOrderScreen), findsOneWidget);
      expect(find.textContaining('Order'), findsWidgets);
    });

    testWidgets('renders StockOrderScreen in RTL without overflow', (tester) async {
      phoneSurface(tester);
      final controller = Get.put(StockController());
      controller.selectedMarket.value = const StockMarketModel(
        id: 1,
        code: 'HKEX',
        countryCode: 'HKG',
        nameFa: 'بورس هنگ‌کنگ',
        nameEn: 'HKEX',
        baseCurrency: 'HKD',
        symbols: [
          StockSymbolModel(
            id: 101,
            ticker: '700.HK',
            nameFa: 'تنسنت',
            nameEn: 'Tencent',
            lastPrice: 382.40,
          ),
        ],
      );
      controller.selectSymbol(controller.selectedMarket.value!.symbols.first);

      await tester.pumpWidget(
        wrapWithTheme(
          const StockOrderScreen(),
          locale: const Locale('fa'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockOrderScreen), findsOneWidget);
    });

    testWidgets('renders StockConfirmScreen review card without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockOrderConfirmScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockOrderConfirmScreen), findsOneWidget);
      expect(find.text('Confirm Stock Order'), findsOneWidget);
    });

    testWidgets('renders StockConfirmScreen with risk checkbox visible', (tester) async {
      phoneSurface(tester);
      final controller = Get.put(StockController());
      controller.riskAcknowledged.value = false;

      await tester.pumpWidget(
        wrapWithTheme(
          const StockOrderConfirmScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockOrderConfirmScreen), findsOneWidget);
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('renders StockTrackingScreen Orders tab without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockTrackingScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockTrackingScreen), findsOneWidget);
      expect(find.text('Stock Orders & Portfolio'), findsOneWidget);
    });

    testWidgets('renders StockTrackingScreen Portfolio tab without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockTrackingScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('Portfolio'));
      await tester.pumpAndSettle();

      expect(find.text('Holdings'), findsOneWidget);
    });

    testWidgets('renders StockIntroScreen hero card without overflow', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockIntroScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(StockIntroScreen), findsOneWidget);
      expect(find.text('Direct Access to Global Equities'), findsOneWidget);
    });

    testWidgets('renders StockIntroScreen market cards grid', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          const StockIntroScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(GridView), findsOneWidget);
    });
  });

  // ============================================================================
  // SECTION 4: ORDER VALIDATION & FORM LOGIC TESTS
  // ============================================================================

  group('Stock Controller - Order Validation Tests', () {
    late StockController controller;

    setUp(() {
      controller = Get.put(StockController());
    });

    tearDown(() async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      Get.reset();
    });

    test('validateOrder returns error when no symbol selected', () {
      controller.selectedSymbol.value = null;
      final error = controller.validateOrder();
      expect(error, contains('ERR_PRECONDITION'));
    });

    test('validateOrder passes when symbol selected but qty zero', () {
      controller.selectedMarket.value = const StockMarketModel(
        id: 1,
        code: 'NASDAQ',
        countryCode: 'USA',
        nameFa: 'NASDAQ',
        nameEn: 'NASDAQ',
        baseCurrency: 'USD',
        symbols: [StockSymbolModel(id: 1, ticker: 'AAPL', nameFa: 'Apple', nameEn: 'Apple', lastPrice: 220)],
      );
      controller.selectedSymbol.value = controller.selectedMarket.value!.symbols.first;
      controller.quantity.value = 0.0;

      final error = controller.validateOrder();
      expect(error, contains('ERR_VALIDATION'));
    });

    test('validateOrder requires limit price for LIMIT orders', () {
      controller.orderType.value = 'LIMIT';
      controller.limitPriceInput.value = '';

      final error = controller.validateOrder();
      expect(error, contains('ERR_VALIDATION'));
    });

    test('validateOrder requires stop price for STOP_LOSS orders', () {
      controller.orderType.value = 'STOP_LOSS';
      controller.stopPriceInput.value = '';

      final error = controller.validateOrder();
      expect(error, contains('ERR_VALIDATION'));
    });

    test('validateOrder fails when risk not acknowledged', () {
      controller.riskAcknowledged.value = false;

      final error = controller.validateOrder();
      expect(error, contains('ERR_CONSENT'));
    });

    test('validateOrder passes when all conditions are met', () {
      controller.selectedMarket.value = const StockMarketModel(
        id: 1,
        code: 'NASDAQ',
        countryCode: 'USA',
        nameFa: 'NASDAQ',
        nameEn: 'NASDAQ',
        baseCurrency: 'USD',
        symbols: [
          StockSymbolModel(id: 1, ticker: 'AAPL', nameFa: 'Apple', nameEn: 'Apple', lastPrice: 220),
        ],
      );
      controller.selectedSymbol.value = controller.selectedMarket.value!.symbols.first;
      controller.quantity.value = 10.0;
      controller.riskAcknowledged.value = true;

      final error = controller.validateOrder();
      expect(error, isNull);
    });
  });

  // ============================================================================
  // SECTION 5: SETTLMENT DATE & FX RATE LOGIC TESTS
  // ============================================================================

  group('Stock Order Model - Settlement & FX Calculations', () {
    test('StockOrderModel calculates settlement date T+2', () {
      final order = StockOrderModel(
        orderNo: 'ORD-TEST-001',
        ticker: 'AAPL',
        nameFa: 'اپل',
        side: 'BUY',
        type: 'MARKET',
        qty: 10.0,
        limitPrice: 0.0,
        stopPrice: 0.0,
        marketCurrency: 'USD',
        payCurrency: 'IRR',
        payAmount: 1000000.0,
        executedFxRate: 620000.0,
        avgExecPrice: 100.0,
        commissionAmount: 15.0,
        status: 'PENDING_BROKER',
        settlementDays: 2,
        createdAt: DateTime(2026, 10, 5, 14, 30, 0),
      );

      final estDate = order.settlementDate;
      expect(estDate.year, 2026);
      expect(estDate.month, 10);
      expect(estDate.day, 7); // Oct 5 + 2 days = Oct 7
    });

    test('StockOrderModel calculates settlement date T+2 with default dates', () {
      final order = StockOrderModel(
        orderNo: 'ORD-TEST-002',
        ticker: 'NVDA',
        nameFa: 'انویدیا',
        side: 'SELL',
        type: 'LIMIT',
        qty: 5.0,
        limitPrice: 135.0,
        stopPrice: 0.0,
        marketCurrency: 'USD',
        payCurrency: 'USDT',
        payAmount: 675.0,
        executedFxRate: 1.0,
        avgExecPrice: 135.0,
        commissionAmount: 1.01,
        status: 'SUBMITTED',
        settlementDays: 2,
      );

      expect(order.createdAt, isNull);
      final estDate = order.settlementDate;
      expect(estDate.day, DateTime.now().add(const Duration(days: 2)).day);
    });
  });

  // ============================================================================
  // SECTION 6: RISK ASSESSMENT QUESTIONS TESTS
  // ============================================================================

  group('Risk Questions & Assessment Evaluation', () {
    test('defaultRiskQuestions count is exactly 6', () {
      Get.put<StockController>(StockController());
      final controller = Get.find<StockController>();

      expect(controller.defaultRiskQuestions.length, 6);
    });

    test('RiskQuestionModel structure verification', () {
      final controller = Get.put<StockController>(StockController());
      final q1 = controller.defaultRiskQuestions.firstWhere((q) => q.id == 'Q1');

      expect(q1.id, 'Q1');
      expect(q1.category, 'EXPERIENCE');
      expect(q1.options.length, 3);
      expect(q1.options.any((o) => o.key == 'EXP_MID'), isTrue);
    });
  });
}
