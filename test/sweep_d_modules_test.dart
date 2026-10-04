import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/license/model/license_models.dart';
import 'package:ecardo_user/src/rental/models/rental_models.dart';
import 'package:ecardo_user/src/rental/screens/rental_voucher_screen.dart';
import 'package:ecardo_user/src/commercial/widgets/equity_project_card.dart';
import 'package:ecardo_user/src/stock/models/stock_models.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  Widget wrapWithTheme({
    required Widget child,
    Brightness brightness = Brightness.light,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => MaterialApp(
        theme: ThemeData(
          brightness: brightness,
          useMaterial3: true,
          colorScheme: brightness == Brightness.dark
              ? const ColorScheme.dark(
                  primary: AppColors.mainSoftBlue,
                  surface: AppColors.darkSurface,
                )
              : const ColorScheme.light(
                  primary: AppColors.deepBlack,
                  surface: AppColors.lightBackground,
                ),
        ),
        home: child,
      ),
    );
  }

  group('Module D: License Models & Vault Calculations', () {
    test('LicenseProductItem calculates correct edition and duration price multipliers', () {
      final product = LicenseProductItem(
        id: 1,
        slug: 'jetbrains-all-pack',
        name: 'JetBrains All Products Pack',
        category: 'developer',
        priceUsd: 100.0,
        isInStock: true,
        stockCount: 15,
        editions: ['Standard', 'Pro', 'Enterprise'],
        durationsMonths: [1, 6, 12, 24],
        editionPricing: {'Standard': 100.0, 'Pro': 150.0, 'Enterprise': 200.0},
        durationMultipliers: {'1': 0.1, '6': 0.5, '12': 1.0, '24': 1.8},
      );

      // Standard edition
      expect(product.calculatePrice('Standard', 12), 100.0);
      expect(product.calculatePrice('Standard', 6), 50.0);

      // Pro edition
      expect(product.calculatePrice('Pro', 12), 150.0);

      // Enterprise edition
      expect(product.calculatePrice('Enterprise', 12), 200.0);
      expect(product.calculatePrice('Enterprise', 24), 360.0);
    });

    test('LicenseKeyItem correctly masks and checks expiration', () {
      final activeKey = LicenseKeyItem(
        id: 101,
        orderNo: 'ORD-501',
        productName: 'Windows 11 Pro Retail',
        edition: 'Pro',
        durationMonths: 12,
        licenseKey: 'VK7JG-NPHTM-C97JM-9MPGT-3V66T',
        keyMasked: '••••-••••-••••-3V66T',
        isExpired: false,
        daysRemaining: 180,
      );

      expect(activeKey.isExpired, isFalse);
      expect(activeKey.daysRemaining, 180);
      expect(activeKey.keyMasked, contains('3V66T'));
      expect(activeKey.keyMasked, startsWith('••••'));
    });
  });

  group('Module D: Rental Vehicle & Voucher Screen', () {
    test('CarModel correctly identifies fleet vs host and price specs', () {
      const fleetCar = CarModel(
        id: 1,
        ownerType: 'FLEET',
        title: 'Mercedes C200',
        category: 'LUXURY',
        transmission: 'Automatic',
        dailyPrice: 120.0,
        depositAmount: 500.0,
        dailyKmLimit: 250,
        extraKmRate: 0.5,
        minAge: 23,
        minLicenseYears: 2,
        insuranceTiers: [
          {'tier': 'BASIC', 'extra_cost': 0},
          {'tier': 'COMPREHENSIVE', 'extra_cost': 25},
        ],
        photos: [],
        features: ['GPS', 'Bluetooth', 'Leather Seats'],
        isActive: true,
      );

      expect(fleetCar.isFleet, isTrue);
      expect(fleetCar.dailyPrice, 120.0);
      expect(fleetCar.depositAmount, 500.0);
      expect(fleetCar.insuranceTiers.length, 2);

      const hostCar = CarModel(
        id: 2,
        ownerType: 'HOST',
        title: 'Toyota Corolla',
        category: 'ECONOMY',
        dailyPrice: 45.0,
        depositAmount: 200.0,
        dailyKmLimit: 200,
        extraKmRate: 0.25,
        minAge: 21,
        minLicenseYears: 1,
        insuranceTiers: [],
        photos: [],
        features: [],
        isActive: true,
      );

      expect(hostCar.isFleet, isFalse);
    });

    testWidgets('RentalVoucherScreen renders QR pass, vehicle title, and facts in light and dark mode', (tester) async {
      phoneSurface(tester);
      const car = CarModel(
        id: 10,
        ownerType: 'FLEET',
        title: 'BMW X5 xDrive40i',
        category: 'SUV',
        transmission: 'Auto',
        dailyPrice: 180.0,
        depositAmount: 800.0,
        dailyKmLimit: 300,
        extraKmRate: 0.75,
        minAge: 25,
        minLicenseYears: 3,
        insuranceTiers: [],
        photos: [],
        features: [],
        isActive: true,
      );

      final booking = RentalBookingModel(
        id: 99,
        bookingNo: 'RNT-2026-9901',
        car: car,
        insuranceTier: 'PREMIUM',
        rentalTotal: 540.0,
        extrasTotal: 50.0,
        status: 'CONFIRMED',
        events: [],
      );

      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          wrapWithTheme(
            brightness: brightness,
            child: RentalVoucherScreen(booking: booking),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('RNT-2026-9901'), findsWidgets);
        expect(find.text('BMW X5 xDrive40i'), findsOneWidget);
        expect(find.text('Rental Voucher Confirmed'), findsOneWidget);
        expect(find.text('Done'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Module D: Commercial Equity Project Card & Progress Meter', () {
    testWidgets('EquityProjectCard renders progress meter and ROI chip under both themes', (tester) async {
      phoneSurface(tester);
      bool tapped = false;
      const project = EquityProjectItem(
        id: 'eq-test',
        title: 'eCardo Terminal Micro-Hub',
        sector: 'Fintech & Payments',
        currency: 'USD',
        targetAmount: 200000.0,
        raisedAmount: 150000.0,
        annualYieldPercent: 24.5,
        minInvestment: 500.0,
        daysLeft: 20,
        location: 'Doha, Qatar',
      );

      expect(project.progressPercent, 75);

      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          wrapWithTheme(
            brightness: brightness,
            child: Scaffold(
              body: EquityProjectCard(
                project: project,
                onInvestTap: () => tapped = true,
              ),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('eCardo Terminal Micro-Hub'), findsOneWidget);
        expect(find.text('Fintech & Payments'), findsOneWidget);
        expect(find.text('Illustrative — 24.5% p.a.'), findsOneWidget);
        expect(find.text('Sample progress'), findsOneWidget);
        expect(find.text('Preview'), findsOneWidget);

        await tester.tap(find.text('Preview'));
        await tester.pump();
        expect(tapped, isTrue);
        tapped = false;
      }
    });
  });

  group('Module D: Stock Symbol & Market Calculations', () {
    test('StockSymbolModel computes positive, negative and zero changePercent accurately', () {
      // Stock that went up from $100 to $105 (+5%)
      final bullStock = StockSymbolModel(
        id: 1,
        ticker: 'AAPL',
        nameFa: 'اپل',
        nameEn: 'Apple Inc.',
        lastPrice: 105.0,
        prevClose: 100.0,
      );
      expect(bullStock.changePercent, 5.0);
      expect(bullStock.dailyChangePct, 5.0);

      // Stock that went down from $200 to $190 (-5%)
      final bearStock = StockSymbolModel(
        id: 2,
        ticker: 'TSLA',
        nameFa: 'تسلا',
        nameEn: 'Tesla Motors',
        lastPrice: 190.0,
        prevClose: 200.0,
      );
      expect(bearStock.changePercent, -5.0);

      // Zero prevClose safeguard
      final zeroPrev = StockSymbolModel(
        id: 3,
        ticker: 'IPO',
        nameFa: 'جدید',
        nameEn: 'New IPO',
        lastPrice: 50.0,
        prevClose: 0.0,
      );
      expect(zeroPrev.changePercent, 0.0);
    });

    test('StockMarketModel correctly deserializes and maps currency', () {
      final json = {
        'id': 1,
        'code': 'NASDAQ',
        'country_code': 'USA',
        'name_fa': 'بورس نزدک',
        'name_en': 'NASDAQ Global Select',
        'base_currency': 'USD',
        'settlement_days': 2,
        'commission_pct': 0.15,
        'quotes_delay_min': 0,
        'symbols': [
          {
            'id': 10,
            'ticker': 'NVDA',
            'name_fa': 'انویدیا',
            'name_en': 'NVIDIA Corporation',
            'industry': 'Semiconductors',
            'last_price': 125.50,
            'prev_close': 120.0,
            'volume_24h': 45000000,
          }
        ]
      };

      final market = StockMarketModel.fromJson(json);
      expect(market.code, 'NASDAQ');
      expect(market.baseCurrency, 'USD');
      expect(market.symbols.length, 1);
      expect(market.symbols.first.ticker, 'NVDA');
      expect(market.symbols.first.lastPrice, 125.50);
      expect(market.symbols.first.changePercent, closeTo(4.583, 0.01));
    });

    test('StockOrderModel calculates and formats correctly', () {
      final order = StockOrderModel(
        orderNo: 'ORD-STK-001',
        ticker: 'MSFT',
        nameFa: 'مایکروسافت',
        side: 'BUY',
        type: 'LIMIT',
        qty: 10.0,
        limitPrice: 420.0,
        marketCurrency: 'USD',
        payCurrency: 'USD',
        payAmount: 4200.0,
        executedFxRate: 1.0,
        avgExecPrice: 420.0,
        status: 'EXECUTED',
      );

      expect(order.orderNo, 'ORD-STK-001');
      expect(order.side, 'BUY');
      expect(order.price, 420.0);
      expect(order.totalAmount, 4200.0);
    });
  });
}
