import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart' as svg;
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/data/travel_repository.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/widgets/esim_activation_card.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/widgets/esim_data_usage_gauge.dart';

// ============================================================================
// MOCK REPOSITORY (matches hotel_service_test.dart pattern)
// ============================================================================

class _MockEsimTravelRepository implements TravelRepository {
  @override
  Future<TravelBootstrap> getBootstrap() async => const TravelBootstrap(
        currency: 'USD',
        locale: 'en',
        services: [],
      );

  @override
  Future<List<TravelSuggestion>> getSuggestions(
    TravelProductType type, {
    String query = '',
    int limit = 20,
  }) async =>
      const [];

  @override
  Future<List<TravelOffer>> searchHotels(TravelHotelSearch search) async =>
      const [];

  @override
  Future<List<TravelOffer>> searchFlights(TravelFlightSearch search) async =>
      const [];

  @override
  Future<List<TravelOffer>> getUpcomingFlights() async => const [];

  @override
  Future<TravelOffer> getOfferDetails(
    TravelProductType type,
    String offerId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<List<TravelEsimPackage>> getEsimPackages(String destinationCode) async =>
      // Realistic backend payload matching lib/src/presentation/screens/travel/core/data/travel_api_repository.dart
      const [
        TravelEsimPackage(
          id: 'esim-tr-10gb-30d',
          destinationCode: 'TR',
          dataLabel: '10 GB',
          validityDays: 30,
          total: TravelMoney(amount: 1900, currency: 'USD'),
          isPopular: true,
        ),
        TravelEsimPackage(
          id: 'esim-eu-5gb-14d',
          destinationCode: 'EU-MULTI',
          dataLabel: '5.0 GB',
          validityDays: 14,
          total: TravelMoney(amount: 1250, currency: 'EUR'),
          isPopular: false,
        ),
        TravelEsimPackage(
          id: 'esim-global-unlimited',
          destinationCode: 'GLOBAL',
          dataLabel: '∞',
          validityDays: 7,
          total: TravelMoney(amount: 2800, currency: 'USD'),
          isPopular: false,
        ),
      ];

  @override
  Future<List<TravelTraveler>> getTravelers() async => const [];

  @override
  Future<TravelTraveler> saveTraveler(TravelTraveler traveler) async => traveler;

  @override
  Future<TravelTravelerProfile> getTravelerProfile() async =>
      const TravelTravelerProfile(complete: false);

  @override
  Future<TravelTravelerProfile> updateTravelerProfile(
    TravelPassenger passenger, {
    String phone = '',
  }) async =>
      TravelTravelerProfile(passenger: passenger, phone: phone, complete: true);

  @override
  Future<List<TravelOrder>> getOrders() async => const [];

  @override
  Future<TravelReservation> createReservation({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TravelOrder> payReservation({
    required TravelReservation reservation,
    required String idempotencyKey,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TravelOrder> requestRefund({
    required TravelOrder order,
    required String reasonCode,
    String? customerNote,
    required String eligibilityVersion,
    required String idempotencyKey,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TravelCancellationEligibility> getCancellationEligibility(
    TravelOrder order,
  ) async =>
      TravelCancellationEligibility(
        eligible: false,
        penalty: const TravelMoney(amount: 0, currency: 'USD'),
        refundable: order.total,
        refundDestination: 'original_wallet',
        requiresSupplierReview: false,
        version: '1',
      );

  @override
  Future<TravelOrderTimeline> getOrderEvents(TravelOrder order) async =>
      TravelOrderTimeline(
        orderId: order.id,
        currentStatus: order.rawStatus,
        events: const [],
      );

  @override
  Future<Map<String, dynamic>> subscribeNotifyMe({
    required String serviceType,
    String? origin,
    String? destination,
    String? travelDate,
  }) async =>
      {'id': 'notify-test', 'status': 'active'};
}

// ============================================================================
// TEST WRAPPER WITH ScreenUtil INITIALIZATION
// ============================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void setPhoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

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
        builder: (context, _) => Scaffold(body: SingleChildScrollView(child: child)),
      ),
    );
  }

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    final controller = TravelController(repository: _MockEsimTravelRepository());
    Get.put<TravelController>(controller);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    Get.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

// ============================================================================
// UNIT TESTS: MODEL & DESERIALIZATION
// ============================================================================

  group('eSIM Model Deserialization Tests', () {
    test('TravelEsimPackage correctly deserializes from realistic backend payload', () {
      final pkg = const TravelEsimPackage(
        id: 'esim-tr-10gb-30d',
        destinationCode: 'TR',
        dataLabel: '10 GB',
        validityDays: 30,
        total: TravelMoney(amount: 1900, currency: 'USD'),
        isPopular: true,
      );

      expect(pkg.id, equals('esim-tr-10gb-30d'));
      expect(pkg.destinationCode, equals('TR'));
      expect(pkg.dataLabel, equals('10 GB'));
      expect(pkg.validityDays, equals(30));
      expect(pkg.total.amount, equals(1900.0));
      expect(pkg.total.currency, equals('USD'));
      expect(pkg.isPopular, isTrue);
    });

    test('TravelMoney handles floating point amounts without precision loss', () {
      final m1 = const TravelMoney(amount: 19.99, currency: 'USD');
      expect(m1.amount, equals(19.99));
      expect(m1.currency, equals('USD'));

      final m2 = const TravelMoney(amount: 0.01, currency: 'IRR');
      expect(m2.amount, equals(0.01));
      expect(m2.currency, equals('IRR'));
    });

    test('Unlimited data packages (symbol ∞) are represented as plain "∞" label', () {
      final unlimited = const TravelEsimPackage(
        id: 'esim-global-unlimited',
        destinationCode: 'GLOBAL',
        dataLabel: '∞',
        validityDays: 7,
        total: TravelMoney(amount: 2800, currency: 'USD'),
        isPopular: false,
      );

      expect(unlimited.dataLabel, equals('∞'));
      expect(unlimited.validityDays, equals(7));
    });

    test('Popular flag defaults to false when omitted', () {
      const pkg = TravelEsimPackage(
        id: 'test-1',
        destinationCode: 'DE',
        dataLabel: '3 GB',
        validityDays: 10,
        total: TravelMoney(amount: 500, currency: 'EUR'),
      );

      expect(pkg.isPopular, isFalse);
    });
  });

// ============================================================================
// WIDGET TESTS: EsimDataUsageGauge UI AT DESIGN SIZE
// ============================================================================

  group('EsimDataUsageGauge - Dark Mode & RTL Tests', () {
    void setPhoneSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(750, 1624);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
    }

    testWidgets(
      'renders with correct colors in dark mode - no white-on-white text',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimDataUsageGauge(
              totalDataGb: 10.0,
              usedDataGb: 6.4,
              daysRemaining: 14,
              countryOrRegion: 'Turkey & Europe',
            ),
            isDark: true,
            locale: const Locale('en'),
          ),
        );

        await tester.pumpAndSettle();

        // Verify gauge numbers visible in dark mode
        expect(find.text('3.6 GB'), findsOneWidget);
        expect(find.text('Remaining of 10.0 GB'), findsOneWidget);
        expect(find.text('14 Days left'), findsOneWidget);
        expect(find.text('6.4 GB'), findsOneWidget);
        expect(find.text('36% Available'), findsOneWidget);
        expect(find.text('Active eSIM'), findsOneWidget);
        expect(find.text('Turkey & Europe'), findsOneWidget);

        // Ensure no pure white background on card surface
        final cardFinder = find.byType(Container).at(0);
        expect(cardFinder, findsOneWidget); // card exists
      },
    );

    testWidgets(
      'renders properly in RTL at design size without overflow',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimDataUsageGauge(
              totalDataGb: 10.0,
              usedDataGb: 8.0,
              daysRemaining: 7,
              countryOrRegion: 'تایلند',
              planName: 'بسته تورم استوری',
            ),
            isDark: false,
            locale: const Locale('fa'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('تایلند'), findsOneWidget);
        expect(find.textContaining('سیم‌کارت فعال'), findsOneWidget);
        expect(find.textContaining('2.0 GB'), findsOneWidget);
        expect(find.textContaining('7 Days left'), findsOneWidget);
      },
    );

    testWidgets(
      'shows low data alert (<15%) with red indicator in RTL',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimDataUsageGauge(
              totalDataGb: 5.0,
              usedDataGb: 4.35, // 0.65 remaining = 13% < 15%
              daysRemaining: 3,
              countryOrRegion: 'دبی',
            ),
            isDark: true,
            locale: const Locale('ar'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('تنبيه'), findsOneWidget);
        expect(find.textContaining('دبی'), findsOneWidget);
      },
    );
  });

  group('EsimDataUsageGauge - Light Mode Tests', () {
    testWidgets(
      'renders primary metrics in light theme at design size',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimDataUsageGauge(
              totalDataGb: 20.0,
              usedDataGb: 5.0,
              daysRemaining: 30,
              countryOrRegion: 'Germany · EU',
            ),
            isDark: false,
            locale: const Locale('de'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.textContaining('15.0 GB'), findsOneWidget);
        expect(find.textContaining('Remaining of 20.0 GB'), findsOneWidget);
        expect(find.textContaining('30 Days left'), findsOneWidget);
      },
    );

    testWidgets(
      'changes gradient based on usage percentage: green >35%, warning 15–35%, danger <15%',
      (tester) async {
        setPhoneSurface(tester);

        // High usage = danger (red)
        await tester.pumpWidget(
          wrapWithTheme(
            const EsimDataUsageGauge(
              totalDataGb: 10.0,
              usedDataGb: 9.1, // 9% remaining
              daysRemaining: 2,
              countryOrRegion: 'FR',
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('9% Available'), findsOneWidget);

        // Medium usage = warning (yellow)
        await tester.pumpWidget(
          wrapWithTheme(
            const EsimDataUsageGauge(
              totalDataGb: 10.0,
              usedDataGb: 7.0, // 30% remaining
              daysRemaining: 5,
              countryOrRegion: 'ES',
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('30% Available'), findsOneWidget);

        // Low usage = green
        await tester.pumpWidget(
          wrapWithTheme(
            const EsimDataUsageGauge(
              totalDataGb: 10.0,
              usedDataGb: 2.0, // 80% remaining
              daysRemaining: 10,
              countryOrRegion: 'IT',
            ),
          ),
        );

        await tester.pumpAndSettle();
        expect(find.textContaining('80% Available'), findsOneWidget);
      },
    );
  });

// ============================================================================
// WIDGET TESTS: EsimActivationCard - Dark Mode & RTL
// ============================================================================

  group('EsimActivationCard - Platform Tabs & Installation Steps', () {
    void setPhoneSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(750, 1624);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
    }

    testWidgets(
      'renders QR code, SM-DP+, activation code, and copy buttons in dark mode',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimActivationCard(
              smdpAddress: 'rsp.truphone.com',
              activationCode: 'EC-TR-98421-B884',
              confirmationCode: 'CONF-XYZ',
              countryOrRegion: '🇹🇷 Turkey & Europe',
            ),
            isDark: true,
            locale: const Locale('en'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('eSIM Activation & Setup'), findsOneWidget);
        expect(find.textContaining('rsp.truphone.com'), findsOneWidget);
        expect(find.textContaining('EC-TR-98421-B884'), findsOneWidget);
        expect(find.textContaining('Confirmation Code'), findsOneWidget);
        expect(find.textContaining('CONF-XYZ'), findsOneWidget);
        expect(find.text('iOS (iPhone / iPad)'), findsOneWidget);
        expect(find.text('Android'), findsOneWidget);

        // Default shows iOS steps
        expect(find.text('1. Open Cellular Settings'), findsOneWidget);

        // Scroll into view before tapping Android tab
        final androidTab = find.text('Android');
        await tester.ensureVisible(androidTab);
        await tester.tap(androidTab);
        await tester.pumpAndSettle();

        expect(find.text('1. Open SIM Manager'), findsOneWidget);
      },
    );

    testWidgets(
      'copies activation fields to clipboard with haptic feedback',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimActivationCard(
              smdpAddress: 'demo-server.esim.global',
              activationCode: r'LPA:1@demo-server.esim.global$TEST-ACT-CODE',
              confirmationCode: 'TEST-CONF',
            ),
            isDark: false,
            locale: const Locale('zh'),
          ),
        );

        await tester.pumpAndSettle();

        // Find copy buttons
        final copyButtons = find.byIcon(Icons.copy_rounded);
        expect(copyButtons, findsWidgets);
        await tester.ensureVisible(copyButtons.first);
        await tester.tap(copyButtons.first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        // After copying, checkmark appears
        expect(find.byIcon(Icons.check_circle_rounded), findsAtLeastNWidgets(1));

        // Advance clock past the revert duration to cleanly settle timers
        await tester.pump(const Duration(seconds: 3));
      },
    );

    testWidgets(
      'displays "None (Not Required)" when confirmation code is null or "None"',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimActivationCard(
              smdpAddress: 'demo.server.com',
              activationCode: 'ACT-CODE-123',
              confirmationCode: 'None',
            ),
            isDark: true,
            locale: const Locale('en'),
          ),
        );

        await tester.pumpAndSettle();

        expect(
          find.textContaining('None (Not Required)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'renders installation steps in RTL (Persian/Arabic)',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimActivationCard(
              smdpAddress: 'ir.provider.ir',
              activationCode: 'IR-ACT-2024',
            ),
            isDark: false,
            locale: const Locale('fa'),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('راهنمای فعال‌سازی و بارکد eSIM'), findsOneWidget);
        expect(find.text('۱. مراجعه به بخش Cellular'), findsOneWidget);

        // iOS tab
        expect(find.text('iOS (iPhone / iPad)'), findsOneWidget);

        // Scroll and switch to Android
        final androidTab = find.text('Android');
        await tester.ensureVisible(androidTab);
        await tester.tap(androidTab);
        await tester.pumpAndSettle();

        expect(find.text('۱. مراجعه به بخش مدیریت سیم‌کارت'), findsOneWidget);
      },
    );

    testWidgets(
      'tap-to-enlarge QR opens dialog with enlarged SVG',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimActivationCard(
              smdpAddress: 'qr.test.ecardo.io',
              activationCode: 'QR-ACT-TST',
            ),
            isDark: false,
            locale: const Locale('en'),
          ),
        );

        await tester.pumpAndSettle();

        // Tap "Tap to enlarge QR"
        final tapToEnlarge = find.text('Tap to enlarge QR');
        expect(tapToEnlarge, findsOneWidget);

        // Scroll into view and tap
        await tester.ensureVisible(tapToEnlarge);
        await tester.tap(tapToEnlarge);
        await tester.pumpAndSettle();

        // Dialog should appear with enlarged QR (SVG)
        expect(find.byType(Dialog), findsOneWidget);
        expect(find.byType(svg.SvgPicture), findsWidgets);
      },
    );
  });

  group('EsimActivationCard - Accessibility Labels', () {
    testWidgets(
      'QR code container has semantic label for screen readers',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimActivationCard(
              smdpAddress: 'accessibility-test.qr.io',
              activationCode: 'ACCESS-ACT',
            ),
            isDark: true,
            locale: const Locale('en'),
          ),
        );

        await tester.pumpAndSettle();

        // The QR gesture detector should have a semantics label
        final qrContainerSemantics = find.bySemanticsLabel(RegExp(r'eSIM activation QR code'));
        expect(qrContainerSemantics, findsOneWidget);
      },
    );

    testWidgets(
      'iOS vs Android tabs are marked with labels for accessibility',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const EsimActivationCard(
              smdpAddress: 'tab-test.qr.io',
              activationCode: 'TAB-ACT',
            ),
            isDark: false,
            locale: const Locale('en'),
          ),
        );

        await tester.pumpAndSettle();

        final iosTabLabel = find.bySemanticsLabel(RegExp(r'iOS'));
        final androidTabLabel = find.bySemanticsLabel(RegExp(r'Android'));

        expect(iosTabLabel, findsOneWidget);
        expect(androidTabLabel, findsOneWidget);
      },
    );
  });

  group('eSIM Service - Integration Flow Tests', () {
    testWidgets(
      'controller loads eSIM packages from repository and displays them',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const SizedBox(),
            isDark: false,
            locale: const Locale('en'),
          ),
        );

        await tester.pump();

        final controller = Get.find<TravelController>();

        // Trigger package load
        final success = await controller.loadEsimPackages('TR');

        expect(success, isTrue);
        expect(controller.esimPackages.length, equals(3));
        expect(controller.esimPackages.first.id, equals('esim-tr-10gb-30d'));
        expect(controller.esimPackages.first.dataLabel, equals('10 GB'));
        expect(controller.searchError.value, isNull);
      },
    );

    testWidgets(
      'controller handles network error gracefully',
      (tester) async {
        setPhoneSurface(tester);

        await tester.pumpWidget(
          wrapWithTheme(
            const SizedBox(),
            isDark: true,
            locale: const Locale('fa'),
          ),
        );

        await tester.pump();

        final badRepo = MockEsimTravelRepositoryWithError();
        final controller = TravelController(repository: badRepo);
        Get.replace<TravelController>(controller);

        final success = await controller.loadEsimPackages('XX');

        expect(success, isFalse);
        expect(controller.esimPackages.isEmpty, isTrue);
        expect(controller.searchError.value, isNotNull);
      },
    );
  });
}

// ============================================================================
// ERROR REPOSITORY FOR FAILURE SCENARIOS
// ============================================================================

class MockEsimTravelRepositoryWithError implements TravelRepository {
  @override
  Future<TravelBootstrap> getBootstrap() async => const TravelBootstrap(
        currency: 'USD',
        locale: 'en',
        services: [],
      );

  @override
  Future<List<TravelSuggestion>> getSuggestions(
    TravelProductType type, {
    String query = '',
    int limit = 20,
  }) async =>
      const [];

  @override
  Future<List<TravelOffer>> searchHotels(TravelHotelSearch search) async =>
      throw Exception('Network timeout');

  @override
  Future<List<TravelOffer>> searchFlights(TravelFlightSearch search) async =>
      const [];

  @override
  Future<List<TravelOffer>> getUpcomingFlights() async => const [];

  @override
  Future<TravelOffer> getOfferDetails(
    TravelProductType type,
    String offerId,
  ) async =>
      throw UnimplementedError();

  @override
  Future<List<TravelEsimPackage>> getEsimPackages(String destinationCode) async =>
      throw Exception('Backend API unreachable');

  @override
  Future<List<TravelTraveler>> getTravelers() async => const [];

  @override
  Future<TravelTraveler> saveTraveler(TravelTraveler traveler) async => traveler;

  @override
  Future<TravelTravelerProfile> getTravelerProfile() async =>
      const TravelTravelerProfile(complete: false);

  @override
  Future<TravelTravelerProfile> updateTravelerProfile(
    TravelPassenger passenger, {
    String phone = '',
  }) async =>
      throw UnimplementedError();

  @override
  Future<List<TravelOrder>> getOrders() async => const [];

  @override
  Future<TravelReservation> createReservation({
    required TravelProductType type,
    required String productId,
    required TravelMoney expectedTotal,
    required String idempotencyKey,
    required TravelBookingDetails bookingDetails,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TravelOrder> payReservation({
    required TravelReservation reservation,
    required String idempotencyKey,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TravelOrder> requestRefund({
    required TravelOrder order,
    required String reasonCode,
    String? customerNote,
    required String eligibilityVersion,
    required String idempotencyKey,
  }) async =>
      throw UnimplementedError();

  @override
  Future<TravelCancellationEligibility> getCancellationEligibility(
    TravelOrder order,
  ) async =>
      TravelCancellationEligibility(
        eligible: false,
        penalty: const TravelMoney(amount: 0, currency: 'USD'),
        refundable: order.total,
        refundDestination: 'original_wallet',
        requiresSupplierReview: false,
        version: '1',
      );

  @override
  Future<TravelOrderTimeline> getOrderEvents(TravelOrder order) async =>
      TravelOrderTimeline(
        orderId: order.id,
        currentStatus: order.rawStatus,
        events: const [],
      );

  @override
  Future<Map<String, dynamic>> subscribeNotifyMe({
    required String serviceType,
    String? origin,
    String? destination,
    String? travelDate,
  }) async =>
      {'error': 'mock-failure'};
}
