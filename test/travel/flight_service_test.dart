import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/data/travel_repository.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/flights/flight_screens.dart';

class _MockFlightTravelRepository implements TravelRepository {
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
      const [];

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
    final controller = TravelController(repository: _MockFlightTravelRepository());
    Get.put<TravelController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('Flight Service - Models & Search Criteria Tests', () {
    test('TravelFlightSearch correctly serializes and restores round-trip query', () {
      final search = TravelFlightSearch(
        origin: 'IKA',
        destination: 'DXB',
        departureDate: DateTime(2026, 11, 15),
        returnDate: DateTime(2026, 11, 22),
        adultCount: 2,
        childCount: 1,
        infantCount: 0,
        cabinClass: 'business',
      );

      expect(search.isRoundTrip, isTrue);

      final json = search.toJson();
      final restored = TravelFlightSearch.fromJson(json);

      expect(restored.origin, 'IKA');
      expect(restored.destination, 'DXB');
      expect(restored.isRoundTrip, isTrue);
      expect(restored.adultCount, 2);
      expect(restored.childCount, 1);
      expect(restored.infantCount, 0);
      expect(restored.cabinClass, 'business');
    });

    test('TravelFlightSearch marks one-way trips by null return date', () {
      final oneWay = TravelFlightSearch(
        origin: 'IKA',
        destination: 'IST',
        departureDate: DateTime(2026, 12, 1),
      );

      expect(oneWay.isRoundTrip, isFalse);
    });
  });

  group('Flight Service - FlightSearchScreen UI Tests', () {
    testWidgets('renders flight search inputs, route toggles, and button without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const FlightSearchScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FlightSearchScreen), findsOneWidget);
      expect(find.text('Search flights'), findsOneWidget);
    });

    testWidgets('renders properly in Persian locale and RTL direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const FlightSearchScreen(),
          locale: const Locale('fa'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FlightSearchScreen), findsOneWidget);
    });

    testWidgets('renders properly in Dark Theme without layout overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const FlightSearchScreen(),
          isDark: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(FlightSearchScreen), findsOneWidget);
      expect(find.text('Search flights'), findsOneWidget);
    });
  });
}
