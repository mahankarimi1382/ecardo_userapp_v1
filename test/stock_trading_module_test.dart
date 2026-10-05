import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/stock/controllers/stock_controller.dart';
import 'package:ecardo_user/src/stock/models/stock_models.dart';
import 'package:ecardo_user/src/stock/screens/stock_home_screen.dart';
import 'package:ecardo_user/src/stock/screens/stock_order_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme(
    Widget child, {
    bool isDark = false,
    Locale locale = const Locale('en'),
  }) {
    return GetMaterialApp(
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
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
  });

  tearDown(() {
    Get.reset();
  });

  group('Stock Trading - Models & Deserialization Tests', () {
    test('StockSymbolModel parses live ticker and calculates change percentage', () {
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
      };

      final symbol = StockSymbolModel.fromJson(json);

      expect(symbol.id, 101);
      expect(symbol.ticker, '700.HK');
      expect(symbol.nameEn, 'Tencent Holdings Ltd');
      expect(symbol.nameFa, 'تنسنت هلدینگز');
      expect(symbol.lastPrice, 382.4);
      expect(symbol.prevClose, 375.0);
      expect(symbol.changePercent, closeTo(1.973, 0.01));
      expect(symbol.isTradeable, isTrue);
    });

    test('StockMarketModel parses market rules, commission and symbols', () {
      final json = {
        'id': 1,
        'code': 'HKEX',
        'country_code': 'HKG',
        'name_fa': 'بورس اوراق بهادار هنگ‌کنگ',
        'name_en': 'Hong Kong Exchanges',
        'base_currency': 'HKD',
        'settlement_days': 2,
        'commission_pct': 0.25,
        'quotes_delay_min': 15,
        'symbols': [
          {
            'id': 101,
            'ticker': '700.HK',
            'name_fa': 'تنسنت',
            'name_en': 'Tencent',
            'last_price': 382.4,
          }
        ],
      };

      final market = StockMarketModel.fromJson(json);

      expect(market.id, 1);
      expect(market.code, 'HKEX');
      expect(market.baseCurrency, 'HKD');
      expect(market.settlementDays, 2);
      expect(market.commissionPct, 0.25);
      expect(market.symbols.length, 1);
      expect(market.symbols.first.ticker, '700.HK');
    });

    test('StockOrderModel deserializes executed orders and prices', () {
      final json = {
        'order_no': 'ORD-2026-9901',
        'ticker': 'BABA',
        'name_fa': 'علی‌بابا هلدینگ',
        'side': 'BUY',
        'type': 'LIMIT',
        'qty': 10.0,
        'limit_price': 84.5,
        'market_currency': 'USD',
        'pay_currency': 'USD',
        'pay_amount': 845.0,
        'executed_fx_rate': 1.0,
        'avg_exec_price': 84.5,
        'status': 'EXECUTED',
        'broker_ref': 'IB-9817264',
        'settlement_days': 2,
      };

      final order = StockOrderModel.fromJson(json);

      expect(order.orderNo, 'ORD-2026-9901');
      expect(order.ticker, 'BABA');
      expect(order.side, 'BUY');
      expect(order.type, 'LIMIT');
      expect(order.qty, 10.0);
      expect(order.limitPrice, 84.5);
      expect(order.payAmount, 845.0);
      expect(order.status, 'EXECUTED');
      expect(order.brokerRef, 'IB-9817264');
    });
  });

  group('Stock Trading - UI Rendering Tests', () {
    testWidgets('renders StockHomeScreen markets, portfolio card and actions without overflow', (
      tester,
    ) async {
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

    testWidgets('renders StockHomeScreen properly in Persian locale (RTL)', (
      tester,
    ) async {
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

    testWidgets('renders StockOrderScreen inputs and action button without overflow', (
      tester,
    ) async {
      final controller = Get.put(StockController());
      controller.selectedMarket.value = const StockMarketModel(
        id: 1,
        code: 'US_NYSE',
        countryCode: 'USA',
        nameFa: 'بورس نیویورک',
        nameEn: 'NYSE',
        baseCurrency: 'USD',
        symbols: [
          StockSymbolModel(
            id: 1,
            ticker: 'AAPL',
            nameFa: 'اپل',
            nameEn: 'Apple Inc',
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
    });

    testWidgets('renders properly in Dark Theme without overflow', (
      tester,
    ) async {
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
  });
}
