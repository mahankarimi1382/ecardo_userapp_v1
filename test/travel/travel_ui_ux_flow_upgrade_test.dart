import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/shared/travel_widgets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme(
    Widget child, {
    Locale locale = const Locale('fa'),
    TextDirection textDirection = TextDirection.rtl,
  }) {
    return MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Directionality(
        textDirection: textDirection,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (context, _) => Scaffold(body: Center(child: child)),
        ),
      ),
    );
  }

  group('MOD-TRAVEL: Zero-Decimal Toman & Currency Formatting', () {
    testWidgets('enforces zero decimals on TOMAN, IRT, IRR, and other zero-decimal currencies', (
      tester,
    ) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fa'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              testContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Zero decimal enforcement
      expect(DynamicDecimalsHelper.isZeroDecimal('TOMAN'), isTrue);
      expect(DynamicDecimalsHelper.isZeroDecimal('IRT'), isTrue);
      expect(DynamicDecimalsHelper.isZeroDecimal('IRR'), isTrue);
      expect(DynamicDecimalsHelper.isZeroDecimal('JPY'), isTrue);
      expect(DynamicDecimalsHelper.isZeroDecimal('USD'), isFalse);
      expect(DynamicDecimalsHelper.isZeroDecimal('EUR'), isFalse);

      // Persian format for Toman
      final tomanPrice = formatTravelPrice(
        testContext,
        amount: 2500000.75,
        currency: 'TOMAN',
      );
      expect(tomanPrice, '2,500,001 تومان');

      // Persian format for IRT
      final irtPrice = formatTravelPrice(
        testContext,
        amount: 1450000.0,
        currency: 'IRT',
      );
      expect(irtPrice, '1,450,000 تومان');

      // Persian format for IRR
      final irrPrice = formatTravelPrice(
        testContext,
        amount: 25000000.0,
        currency: 'IRR',
      );
      expect(irrPrice, '25,000,000 ریال');

      // USD currency with decimals when fractional
      final usdPrice = formatTravelPrice(
        testContext,
        amount: 15.50,
        currency: 'USD',
      );
      expect(usdPrice, '\$15.50');

      // USD round amount has no unnecessary trailing decimals
      final usdRound = formatTravelPrice(
        testContext,
        amount: 150.0,
        currency: 'USD',
      );
      expect(usdRound, '\$150');

      // EUR currency
      final eurPrice = formatTravelPrice(
        testContext,
        amount: 99.0,
        currency: 'EUR',
      );
      expect(eurPrice, '€99');
    });

    testWidgets('formats English currency labels correctly', (tester) async {
      late BuildContext testContext;

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (ctx) {
              testContext = ctx;
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tomanEn = formatTravelPrice(
        testContext,
        amount: 500000,
        currency: 'TOMAN',
      );
      expect(tomanEn, '500,000 Toman');

      final irrEn = formatTravelPrice(
        testContext,
        amount: 5000000,
        currency: 'IRR',
      );
      expect(irrEn, '5,000,000 IRR');
    });
  });

  group('MOD-TRAVEL: RTL/LTR Directional Safety for Flight Routes', () {
    testWidgets('renders flight route correctly in RTL (Persian/Arabic)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TravelFlightRouteIndicator(
            originCode: 'IKA',
            originCity: 'تهران',
            departureTime: '10:30',
            destinationCode: 'DXB',
            destinationCity: 'دبی',
            arrivalTime: '13:15',
            duration: '2h 15m',
            stopsLabel: 'مستقیم',
            isDirect: true,
          ),
          locale: const Locale('fa'),
          textDirection: TextDirection.rtl,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('IKA'), findsOneWidget);
      expect(find.text('DXB'), findsOneWidget);
      expect(find.text('10:30'), findsOneWidget);
      expect(find.text('13:15'), findsOneWidget);
      expect(find.text('تهران'), findsOneWidget);
      expect(find.text('دبی'), findsOneWidget);
      expect(find.text('مستقیم'), findsOneWidget);

      // Verify airplane icon is flipped (scaleX == -1) to point towards destination in RTL
      final transformFinder = find.byType(Transform);
      expect(transformFinder, findsWidgets);

      final iconFinder = find.byIcon(Icons.flight_takeoff_rounded);
      expect(iconFinder, findsOneWidget);

      final transformWidget = tester.widget<Transform>(
        find.ancestor(of: iconFinder, matching: find.byType(Transform)).first,
      );
      // scaleX is negative in RTL
      expect(transformWidget.transform.storage[0], -1.0);
    });

    testWidgets('renders flight route correctly in LTR (English)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TravelFlightRouteIndicator(
            originCode: 'JFK',
            originCity: 'New York',
            departureTime: '08:00',
            destinationCode: 'LHR',
            destinationCity: 'London',
            arrivalTime: '20:15',
            duration: '7h 15m',
            stopsLabel: 'Direct',
            isDirect: true,
          ),
          locale: const Locale('en'),
          textDirection: TextDirection.ltr,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('JFK'), findsOneWidget);
      expect(find.text('LHR'), findsOneWidget);
      expect(find.text('08:00'), findsOneWidget);
      expect(find.text('20:15'), findsOneWidget);

      final iconFinder = find.byIcon(Icons.flight_takeoff_rounded);
      expect(iconFinder, findsOneWidget);

      final transformWidget = tester.widget<Transform>(
        find.ancestor(of: iconFinder, matching: find.byType(Transform)).first,
      );
      // scaleX is positive in LTR
      expect(transformWidget.transform.storage[0], 1.0);
    });
  });

  group('MOD-TRAVEL: Harmonized Passenger & Booking Fee Breakdown', () {
    testWidgets('renders flight itemized breakdown with passenger categories and total debit', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TravelFeeBreakdownCard(
            type: TravelProductType.flight,
            total: TravelMoney(amount: 10000000, currency: 'TOMAN'),
            adultCount: 2,
            childCount: 1,
            infantCount: 0,
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      // Should display adult passenger line
      expect(find.textContaining('بزرگسال × 2'), findsOneWidget);
      // Should display child passenger line
      expect(find.textContaining('کودک × 1'), findsOneWidget);
      // Should display airport taxes
      expect(find.textContaining('مالیات فرودگاهی'), findsOneWidget);
      // Should display total debit
      expect(find.textContaining('10,000,000 تومان'), findsOneWidget);
    });

    testWidgets('renders hotel breakdown with room, nights, and VAT', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TravelFeeBreakdownCard(
            type: TravelProductType.hotel,
            total: TravelMoney(amount: 4500000, currency: 'TOMAN'),
            roomName: 'اتاق دبل دلوکس',
            roomCount: 1,
            nights: 3,
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('اتاق دبل دلوکس'), findsOneWidget);
      expect(find.textContaining('مالیات بر ارزش افزوده'), findsOneWidget);
      expect(find.textContaining('4,500,000 تومان'), findsOneWidget);
    });

    testWidgets('renders eSIM breakdown with data tariff and regulatory fee', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TravelFeeBreakdownCard(
            type: TravelProductType.esim,
            total: TravelMoney(amount: 25, currency: 'USD'),
          ),
          locale: const Locale('en'),
          textDirection: TextDirection.ltr,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Global Data Package Tariff'), findsOneWidget);
      expect(find.textContaining('Network Provisioning'), findsOneWidget);
      expect(find.textContaining('\$25'), findsOneWidget);
    });
  });

  group('MOD-TRAVEL: State Matrix & Design System Upgrades', () {
    testWidgets('TravelEmptyState renders modern empty state with action', (
      tester,
    ) async {
      var actionTriggered = false;

      await tester.pumpWidget(
        wrapWithTheme(
          TravelEmptyState(
            title: 'پروازی یافت نشد',
            message: 'لطفاً تاریخ یا مقصد دیگری را امتحان فرمایید.',
            actionText: 'جستجوی مجدد',
            onAction: () => actionTriggered = true,
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('پروازی یافت نشد'), findsOneWidget);
      expect(find.text('لطفاً تاریخ یا مقصد دیگری را امتحان فرمایید.'), findsOneWidget);
      expect(find.text('جستجوی مجدد'), findsOneWidget);

      await tester.tap(find.text('جستجوی مجدد'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('TravelErrorState renders error view with retry action', (
      tester,
    ) async {
      var retryTriggered = false;

      await tester.pumpWidget(
        wrapWithTheme(
          TravelErrorState(
            title: 'خطای برقراری ارتباط',
            message: 'پاسخی از سرور دریافت نشد.',
            retryText: 'تلاش مجدد',
            onRetry: () => retryTriggered = true,
          ),
          locale: const Locale('fa'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('خطای برقراری ارتباط'), findsOneWidget);
      expect(find.text('پاسخی از سرور دریافت نشد.'), findsOneWidget);
      expect(find.text('تلاش مجدد'), findsOneWidget);

      await tester.tap(find.text('تلاش مجدد'));
      expect(retryTriggered, isTrue);
    });

    testWidgets('TravelCard with useGlass renders EcardoGlassCard smoothly', (
      tester,
    ) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          TravelCard(
            useGlass: true,
            onTap: () => tapped = true,
            child: const Text('Glass Content'),
          ),
          locale: const Locale('en'),
          textDirection: TextDirection.ltr,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Glass Content'), findsOneWidget);
      await tester.tap(find.text('Glass Content'));
      expect(tapped, isTrue);
    });
  });
}
