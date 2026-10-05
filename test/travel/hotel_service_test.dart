import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/controller/travel_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/data/travel_repository.dart';
import 'package:ecardo_user/src/presentation/screens/travel/core/models/travel_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/hotel_filter_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/hotel_screens.dart';

class _MockHotelTravelRepository implements TravelRepository {
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
    final controller = TravelController(repository: _MockHotelTravelRepository());
    Get.put<TravelController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('Hotel Service - formatHotelOccupancy Tests', () {
    testWidgets('formats occupancy correctly in English', (tester) async {
      late String singleAdult;
      late String multipleAdults;
      late String withChildren;

      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (context) {
              singleAdult = formatHotelOccupancy(
                context,
                rooms: 1,
                adults: 1,
                children: 0,
              );
              multipleAdults = formatHotelOccupancy(
                context,
                rooms: 2,
                adults: 4,
                children: 0,
              );
              withChildren = formatHotelOccupancy(
                context,
                rooms: 1,
                adults: 2,
                children: 2,
              );
              return const SizedBox();
            },
          ),
          locale: const Locale('en'),
        ),
      );

      expect(singleAdult, '1 Room, 1 Adult');
      expect(multipleAdults, '2 Rooms, 4 Adults');
      expect(withChildren, '1 Room, 2 Adults, 2 Children');
    });

    testWidgets('formats occupancy correctly in Persian', (tester) async {
      late String resultFa;

      await tester.pumpWidget(
        wrapWithTheme(
          Builder(
            builder: (context) {
              resultFa = formatHotelOccupancy(
                context,
                rooms: 1,
                adults: 2,
                children: 1,
              );
              return const SizedBox();
            },
          ),
          locale: const Locale('fa'),
        ),
      );

      expect(resultFa, '1 اتاق، 2 بزرگسال، 1 کودک');
    });
  });

  group('Hotel Service - HotelFilterState & Options Logic Tests', () {
    test('default filter state is inactive', () {
      const state = HotelFilterState();
      expect(state.isActive, isFalse);
    });

    test('state with name or stars is active', () {
      final state = const HotelFilterState().copyWith(
        name: 'Espinas',
        stars: {5},
      );
      expect(state.isActive, isTrue);
      expect(state.name, 'Espinas');
      expect(state.stars, {5});
    });

    test('options extracts price range, stars and amenities correctly', () {
      final List<TravelOffer> offers = [
        const TravelOffer(
          id: 'hotel-1',
          type: TravelProductType.hotel,
          titleKey: 'Espinas Palace',
          subtitleKey: 'Tehran',
          badgeKey: 'Popular',
          total: TravelMoney(amount: 250, currency: 'USD'),
          rating: 4.8,
          featureKeys: ['Pool', 'Spa'],
          metadata: {},
          attributes: {
            'stars': 5,
            'property_type': 'Luxury Hotel',
            'free_cancellation': true,
          },
          product: {
            'amenities': ['WiFi'],
          },
        ),
        const TravelOffer(
          id: 'hotel-2',
          type: TravelProductType.hotel,
          titleKey: 'Parsian Hotel',
          subtitleKey: 'Tehran',
          badgeKey: 'City',
          total: TravelMoney(amount: 120, currency: 'USD'),
          rating: 4.2,
          featureKeys: ['WiFi'],
          metadata: {},
          attributes: {
            'stars': 4,
            'property_type': 'City Hotel',
          },
          product: {
            'amenities': ['Gym'],
          },
        ),
      ];

      final options = HotelFilterOptions.fromOffers(offers);
      expect(options.minimumPrice, 120);
      expect(options.maximumPrice, 250);
      expect(options.stars, {4, 5});
      expect(options.features, containsAll(['Pool', 'Spa', 'WiFi', 'Gym']));
      expect(options.propertyTypes, containsAll(['Luxury Hotel', 'City Hotel']));
    });
  });

  group('Hotel Service - HotelSearchScreen UI Tests', () {
    testWidgets('renders search card, inputs, and search button without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const HotelSearchScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HotelSearchScreen), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
      expect(find.byIcon(Icons.date_range_outlined), findsOneWidget);
      expect(find.byIcon(Icons.group_outlined), findsOneWidget);
      expect(find.text('Search hotels'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Theme without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const HotelSearchScreen(),
          isDark: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HotelSearchScreen), findsOneWidget);
      expect(find.text('Search hotels'), findsOneWidget);
    });
  });

  group('Hotel Service - HotelResultsScreen UI Tests', () {
    testWidgets('renders offer card badges, rating, cancellation and taxes without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final controller = Get.find<TravelController>();
      controller.isLoading.value = false;
      controller.lastHotelSearch.value = TravelHotelSearch(
        city: 'Tehran',
        checkInDate: DateTime.now().add(const Duration(days: 10)),
        checkOutDate: DateTime.now().add(const Duration(days: 12)),
        roomCount: 1,
        adultCount: 2,
        childCount: 0,
      );
      controller.hotelOffers.value = [
        const TravelOffer(
          id: 'hotel-101',
          type: TravelProductType.hotel,
          titleKey: 'travelMockHotelEspinas',
          subtitleKey: 'travelMockHotelEspinasLocation',
          badgeKey: 'travelLuxury',
          total: TravelMoney(amount: 200, currency: 'USD'),
          rating: 4.8,
          featureKeys: ['travelFeatureBreakfast'],
          metadata: {},
          attributes: {
            'stars': 5,
            'free_cancellation': true,
          },
          product: {
            'amenities': ['Breakfast Included'],
          },
        ),
      ];

      await tester.pumpWidget(
        wrapWithTheme(
          const HotelResultsScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HotelResultsScreen), findsOneWidget);
      expect(find.text('Espinas Palace Hotel'), findsOneWidget);
      expect(find.text('Saadat Abad, Tehran'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('Free Cancellation'), findsOneWidget);
      expect(find.text('Taxes & fees included'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Mode without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final controller = Get.find<TravelController>();
      controller.isLoading.value = false;
      controller.lastHotelSearch.value = TravelHotelSearch(
        city: 'Tehran',
        checkInDate: DateTime.now().add(const Duration(days: 10)),
        checkOutDate: DateTime.now().add(const Duration(days: 12)),
        roomCount: 1,
        adultCount: 2,
        childCount: 0,
      );
      controller.hotelOffers.value = [
        const TravelOffer(
          id: 'hotel-101',
          type: TravelProductType.hotel,
          titleKey: 'travelMockHotelEspinas',
          subtitleKey: 'travelMockHotelEspinasLocation',
          badgeKey: 'travelLuxury',
          total: TravelMoney(amount: 200, currency: 'USD'),
          rating: 4.8,
          featureKeys: ['travelFeatureBreakfast'],
          metadata: {},
          attributes: {
            'stars': 5,
            'free_cancellation': true,
          },
          product: {
            'amenities': ['Breakfast Included'],
          },
        ),
      ];

      await tester.pumpWidget(
        wrapWithTheme(
          const HotelResultsScreen(),
          isDark: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(HotelResultsScreen), findsOneWidget);
      expect(find.text('Espinas Palace Hotel'), findsOneWidget);
      expect(find.text('Free Cancellation'), findsOneWidget);
    });
  });
}
