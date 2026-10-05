// DATA: REAL | MOCK | PLACEHOLDER | NOT-IMPLEMENTED
// Unit & Widget tests for eCardo Travel Sub-Services: Boat, Dining, Local Experiences
// Modeled on test/travel/hotel_service_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';

import 'package:ecardo_user/src/presentation/screens/travel/local/models/experience_contracts.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/models/boat_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/controllers/boat_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_detail_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_voucher_screen.dart';

import 'package:ecardo_user/src/presentation/screens/travel/dining/models/dining_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/controllers/dining_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/dining_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/restaurant_detail_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/dining/screens/dining_order_pass_screen.dart';

import 'package:ecardo_user/src/presentation/screens/travel/local/models/local_experience_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/controllers/local_experience_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_detail_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_voucher_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme(
    Widget child, {
    bool isDark = false,
    Locale locale = const Locale('fa'),
  }) {
    return GetMaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: isDark ? ThemeData.dark(useMaterial3: true) : ThemeData.light(useMaterial3: true),
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
  });

  tearDown(() {
    Get.reset();
  });

  // -------------------------------------------------------------
  // Group 1: Unified Experience Contracts & Policy Logic
  // -------------------------------------------------------------
  group('Experience Contracts & Business Logic', () {
    test('Cancellation policy calculates 100% refund when > free hours prior', () {
      const policy = ExperienceCancellationPolicy(
        freeCancellationHours: 24,
        lateCancelPenaltyPercent: 30.0,
      );

      final scheduled = DateTime.now().add(const Duration(hours: 48));
      final refund = policy.calculateRefund(
        scheduledAt: scheduled,
        totalAmount: 200.0,
        currency: 'USD',
      );

      expect(refund.isFreeCancellation, isTrue);
      expect(refund.refundableAmount, equals(200.0));
      expect(refund.penaltyAmount, equals(0.0));
      expect(refund.refundDestinationWalletCurrency, equals('USD'));
    });

    test('Cancellation policy applies penalty when within late cancellation window', () {
      const policy = ExperienceCancellationPolicy(
        freeCancellationHours: 24,
        lateCancelPenaltyPercent: 30.0,
      );

      final scheduled = DateTime.now().add(const Duration(hours: 6));
      final refund = policy.calculateRefund(
        scheduledAt: scheduled,
        totalAmount: 200.0,
        currency: 'USD',
      );

      expect(refund.isFreeCancellation, isFalse);
      expect(refund.penaltyAmount, equals(60.0)); // 30% of 200
      expect(refund.refundableAmount, equals(140.0));
      expect(refund.refundDestinationWalletCurrency, equals('USD'));
    });

    test('Search query serialization and deserialization adheres to schema_version 1.0', () {
      const query = ExperienceSearchQuery(
        domain: ExperienceDomain.boat,
        keyword: 'yacht',
        city: 'کیش',
        adults: 4,
        children: 2,
        currency: 'USD',
      );

      final json = query.toJson();
      expect(json['schema_version'], equals('1.0'));
      expect(json['domain'], equals('boat'));
      expect(json['adults'], equals(4));

      final restored = ExperienceSearchQuery.fromJson(json);
      expect(restored.domain, equals(ExperienceDomain.boat));
      expect(restored.city, equals('کیش'));
      expect(restored.children, equals(2));
    });
  });

  // -------------------------------------------------------------
  // Group 2: Boat Models, Pricing, and Serialization
  // -------------------------------------------------------------
  group('Boat Domain Models & Pricing', () {
    const boat = BoatExperienceModel(
      schemaVersion: '1.0',
      id: 'test-boat-01',
      title: 'یات سان‌سیکر ۵۵',
      marinaName: 'اسکله کیش',
      city: 'کیش',
      category: BoatCategory.yacht,
      hourlyRate: 100.0,
      childRate: 40.0,
      currency: 'USD',
      maxPassengers: 10,
      lengthMeters: 17.5,
      rating: 4.9,
      reviewsCount: 20,
      captainName: 'کاپیتان آرش',
      images: ['https://example.com/boat.jpg'],
      features: ['سیستم صوتی'],
      availableSlots: ['10:00 - 12:00'],
      addons: [
        BoatAddon(
          id: 'snork',
          title: 'اسنورکلینگ',
          price: 20.0,
          unit: 'هر نفر',
          icon: 'scuba',
        ),
      ],
      description: 'گشت لوکس دریایی',
    );

    test('Calculates total price correctly with hours, passengers, and add-ons', () {
      final total = boat.calculateTotal(
        hours: 3,
        adults: 2,
        children: 1,
        selectedAddonIds: ['snork'],
      );

      // base: 100 * 3 = 300
      // addon: 20 * (2 adults + 1 child) = 60
      // total: 360
      expect(total, equals(360.0));
    });

    test('BoatExperienceModel JSON serialization and deserialization roundtrip', () {
      final json = boat.toJson();
      expect(json['schema_version'], equals('1.0'));
      expect(json['hourly_rate'], equals(100.0));

      final restored = BoatExperienceModel.fromJson(json);
      expect(restored.id, equals('test-boat-01'));
      expect(restored.category, equals(BoatCategory.yacht));
      expect(restored.addons.first.title, equals('اسنورکلینگ'));
    });

    test('BoatBookingModel cancellation creates copy with refund information', () {
      final booking = BoatBookingModel(
        schemaVersion: '1.0',
        bookingId: 'SEA-100',
        boatId: 'test-boat-01',
        boatTitle: 'یات سان‌سیکر',
        marinaName: 'اسکله کیش',
        date: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '10:00 - 12:00',
        durationHours: 2,
        passengersCount: 2,
        selectedAddonIds: const [],
        totalAmount: 200.0,
        currency: 'USD',
        captainPhone: '+98 912 000 0000',
        pierDockNumber: 'Dock 1',
        status: 'confirmed',
        bookedAt: DateTime.now(),
      );

      expect(booking.canCancel, isTrue);
      final cancelled = booking.copyWithCancelled(
        penalty: 0.0,
        refund: 200.0,
        reason: 'Change of plans',
      );

      expect(cancelled.isCancelled, isTrue);
      expect(cancelled.status, equals('cancelled'));
      expect(cancelled.refundedAmount, equals(200.0));
    });
  });

  // -------------------------------------------------------------
  // Group 3: Dining Models, Pricing & Orders
  // -------------------------------------------------------------
  group('Dining Domain Models & Orders', () {
    const restaurant = RestaurantModel(
      schemaVersion: '1.0',
      id: 'test-rest-01',
      name: 'پرشین لانژ IKA',
      terminalLocation: 'فرودگاه امام',
      city: 'تهران (IKA)',
      cuisineType: 'ایرانی',
      rating: 4.8,
      reviewsCount: 50,
      openingHours: '۲۴ ساعته',
      availableModes: [DiningServiceMode.airportGatePickup],
      currency: 'USD',
      minOrderAmount: 10.0,
      menu: [
        MenuItemModel(
          id: 'dish-01',
          title: 'کباب کوبیده',
          description: 'کباب زعفرانی',
          price: 15.0,
          currency: 'USD',
          calories: 600,
          prepMinutes: 12,
        ),
      ],
    );

    test('RestaurantModel and MenuItemModel serialize properly under schema_version 1.0', () {
      final json = restaurant.toJson();
      expect(json['schema_version'], equals('1.0'));
      expect(json['menu'].first['title'], equals('کباب کوبیده'));

      final restored = RestaurantModel.fromJson(json);
      expect(restored.name, equals('پرشین لانژ IKA'));
      expect(restored.menu.first.price, equals(15.0));
    });

    test('DiningOrderModel reflects cancellation fee calculation', () {
      final order = DiningOrderModel(
        schemaVersion: '1.0',
        orderId: 'MEAL-100',
        restaurantId: 'test-rest-01',
        restaurantName: 'پرشین لانژ',
        terminalLocation: 'گیت ۱۸',
        mode: DiningServiceMode.airportGatePickup,
        pickupTime: '12:00',
        items: [
          DiningOrderItem(
            item: const MenuItemModel(
              id: 'dish-01',
              title: 'کباب کوبیده',
              description: '',
              price: 20.0,
              currency: 'USD',
              calories: 600,
              prepMinutes: 10,
            ),
            quantity: 2,
          ),
        ],
        totalAmount: 40.0,
        currency: 'USD',
        status: 'preparing',
        orderedAt: DateTime.now().subtract(const Duration(minutes: 15)),
      );

      final refund = order.calculateCancellationRefund();
      expect(refund.isFreeCancellation, isFalse);
      expect(refund.penaltyAmount, equals(20.0)); // 50% penalty
      expect(refund.refundableAmount, equals(20.0));
    });
  });

  // -------------------------------------------------------------
  // Group 4: Local Experiences Models & Capacity Logic
  // -------------------------------------------------------------
  group('Local Experiences Models & Capacity', () {
    const experience = LocalExperienceItemModel(
      schemaVersion: '1.0',
      id: 'test-local-01',
      title: 'تور تاریخی سلطان‌احمد',
      subtitle: 'گشت نیم‌روز',
      providerName: 'استاد امین',
      city: 'استانبول',
      type: LocalServiceType.tourGuide,
      price: 50.0,
      childPrice: 25.0,
      currency: 'USD',
      pricingType: ExperiencePricingType.perPerson,
      durationLabel: '۴ ساعت',
      languages: ['فارسی', 'انگلیسی'],
      rating: 4.9,
      reviewsCount: 40,
      highlights: ['ایاصوفیه'],
      meetingPoint: 'میدان اصلی',
      description: 'توضیحات گشت',
      minGuests: 1,
      maxGuests: 6,
      remainingCapacity: 5,
    );

    test('Validates guest capacity correctly', () {
      expect(experience.hasCapacityFor(2, 2), isTrue); // 4 <= 5
      expect(experience.hasCapacityFor(5, 2), isFalse); // 7 > 5 remaining
      expect(experience.hasCapacityFor(0, 0), isFalse); // < minGuests
    });

    test('Calculates total price for perPerson with child discount', () {
      final total = experience.calculateTotal(adults: 2, children: 2);
      // 50 * 2 + 25 * 2 = 150
      expect(total, equals(150.0));
    });

    test('LocalExperienceItemModel JSON roundtrip matches 1.0 schema', () {
      final json = experience.toJson();
      expect(json['schema_version'], equals('1.0'));
      expect(json['type'], equals('tour_guide'));

      final restored = LocalExperienceItemModel.fromJson(json);
      expect(restored.title, equals('تور تاریخی سلطان‌احمد'));
      expect(restored.childPrice, equals(25.0));
    });
  });

  // -------------------------------------------------------------
  // Group 5: Screen Rendering & Responsiveness (Light, Dark, RTL)
  // -------------------------------------------------------------
  group('Screens Rendering (Light, Dark, RTL, 375x812)', () {
    testWidgets('BoatCatalogScreen renders without overflow in RTL light & dark',
        (tester) async {
      final controller = Get.put(BoatController());
      controller.loadCatalog();

      // RTL Light
      await tester.pumpWidget(
        wrapWithTheme(const BoatCatalogScreen(), isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BoatCatalogScreen), findsOneWidget);

      // RTL Dark
      await tester.pumpWidget(
        wrapWithTheme(const BoatCatalogScreen(), isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BoatCatalogScreen), findsOneWidget);
    });

    testWidgets('BoatDetailScreen renders without overflow in RTL light & dark',
        (tester) async {
      Get.put(BoatController());
      const sampleBoat = BoatExperienceModel(
        schemaVersion: '1.0',
        id: 'boat-test',
        title: 'شناور تفریحی کیش',
        marinaName: 'اسکله کیش',
        city: 'کیش',
        category: BoatCategory.yacht,
        hourlyRate: 100.0,
        currency: 'USD',
        maxPassengers: 8,
        lengthMeters: 14.0,
        rating: 4.8,
        reviewsCount: 15,
        captainName: 'کاپیتان علی',
        images: [],
        features: ['تهویه مطبوع'],
        availableSlots: ['10:00 - 12:00'],
        addons: [],
        description: 'گشت خاطره‌انگیز',
      );

      // RTL Light
      await tester.pumpWidget(
        wrapWithTheme(const BoatDetailScreen(boat: sampleBoat),
            isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BoatDetailScreen), findsOneWidget);

      // RTL Dark
      await tester.pumpWidget(
        wrapWithTheme(const BoatDetailScreen(boat: sampleBoat),
            isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BoatDetailScreen), findsOneWidget);
    });

    testWidgets('BoatVoucherScreen renders without overflow in RTL light & dark',
        (tester) async {
      Get.put(BoatController());
      final sampleBooking = BoatBookingModel(
        schemaVersion: '1.0',
        bookingId: 'SEA-999',
        boatId: 'boat-test',
        boatTitle: 'یات لوکس سان‌سیکر',
        marinaName: 'اسکله کیش',
        date: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '16:00 - 18:00',
        durationHours: 2,
        passengersCount: 2,
        selectedAddonIds: const [],
        totalAmount: 200.0,
        currency: 'USD',
        captainPhone: '+98 912 111 2233',
        pierDockNumber: 'Dock A',
        status: 'confirmed',
        bookedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        wrapWithTheme(BoatVoucherScreen(booking: sampleBooking),
            isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BoatVoucherScreen), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(BoatVoucherScreen(booking: sampleBooking),
            isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(BoatVoucherScreen), findsOneWidget);
    });

    testWidgets('DiningCatalogScreen renders without overflow in RTL light & dark',
        (tester) async {
      final controller = Get.put(DiningController());
      controller.loadCatalog();

      await tester.pumpWidget(
        wrapWithTheme(const DiningCatalogScreen(), isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DiningCatalogScreen), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(const DiningCatalogScreen(), isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DiningCatalogScreen), findsOneWidget);
    });

    testWidgets('RestaurantDetailScreen renders without overflow in RTL light & dark',
        (tester) async {
      Get.put(DiningController());
      const sampleRestaurant = RestaurantModel(
        schemaVersion: '1.0',
        id: 'rest-test',
        name: 'کافه پرشین',
        terminalLocation: 'فرودگاه امام',
        city: 'تهران',
        cuisineType: 'ایرانی',
        rating: 4.8,
        reviewsCount: 25,
        openingHours: '۲۴ ساعته',
        availableModes: [DiningServiceMode.airportGatePickup],
        menu: [],
      );

      await tester.pumpWidget(
        wrapWithTheme(const RestaurantDetailScreen(restaurant: sampleRestaurant),
            isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(RestaurantDetailScreen), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(const RestaurantDetailScreen(restaurant: sampleRestaurant),
            isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(RestaurantDetailScreen), findsOneWidget);
    });

    testWidgets('DiningOrderPassScreen renders without overflow in RTL light & dark',
        (tester) async {
      Get.put(DiningController());
      final sampleOrder = DiningOrderModel(
        schemaVersion: '1.0',
        orderId: 'MEAL-777',
        restaurantId: 'rest-test',
        restaurantName: 'رستوران پرشین',
        terminalLocation: 'گیت ۱۲',
        mode: DiningServiceMode.airportGatePickup,
        pickupTime: '13:00',
        items: const [],
        totalAmount: 25.0,
        currency: 'USD',
        status: 'preparing',
        orderedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        wrapWithTheme(DiningOrderPassScreen(order: sampleOrder),
            isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DiningOrderPassScreen), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(DiningOrderPassScreen(order: sampleOrder),
            isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(DiningOrderPassScreen), findsOneWidget);
    });

    testWidgets('LocalCatalogScreen renders without overflow in RTL light & dark',
        (tester) async {
      final controller = Get.put(LocalExperienceController());
      controller.loadCatalog();

      await tester.pumpWidget(
        wrapWithTheme(const LocalCatalogScreen(), isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LocalCatalogScreen), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(const LocalCatalogScreen(), isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LocalCatalogScreen), findsOneWidget);
    });

    testWidgets('LocalDetailScreen renders without overflow in RTL light & dark',
        (tester) async {
      Get.put(LocalExperienceController());
      const sampleExp = LocalExperienceItemModel(
        schemaVersion: '1.0',
        id: 'local-test',
        title: 'راهنمای سفر استانبول',
        subtitle: 'گشت شهری',
        providerName: 'استاد امین',
        city: 'استانبول',
        type: LocalServiceType.tourGuide,
        price: 40.0,
        currency: 'USD',
        durationLabel: '۳ ساعت',
        languages: ['فارسی'],
        rating: 4.9,
        reviewsCount: 12,
        highlights: ['دیدار ایاصوفیه'],
        meetingPoint: 'میدان تکسیم',
        description: 'توضیحات کامل',
      );

      await tester.pumpWidget(
        wrapWithTheme(const LocalDetailScreen(experience: sampleExp),
            isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LocalDetailScreen), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(const LocalDetailScreen(experience: sampleExp),
            isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LocalDetailScreen), findsOneWidget);
    });

    testWidgets('LocalVoucherScreen renders without overflow in RTL light & dark',
        (tester) async {
      Get.put(LocalExperienceController());
      final sampleBooking = LocalBookingModel(
        schemaVersion: '1.0',
        bookingId: 'EXP-888',
        serviceId: 'local-test',
        serviceTitle: 'راهنمای تور استانبول',
        providerName: 'استاد امین',
        city: 'استانبول',
        serviceDate: DateTime.now().add(const Duration(days: 2)),
        serviceTime: '10:00',
        guestsCount: 2,
        totalAmount: 80.0,
        currency: 'USD',
        meetingPoint: 'میدان تکسیم',
        providerPhone: '+90 555 123 4567',
        status: 'confirmed',
        bookedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        wrapWithTheme(LocalVoucherScreen(booking: sampleBooking),
            isDark: false, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LocalVoucherScreen), findsOneWidget);

      await tester.pumpWidget(
        wrapWithTheme(LocalVoucherScreen(booking: sampleBooking),
            isDark: true, locale: const Locale('fa')),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(LocalVoucherScreen), findsOneWidget);
    });
  });
}
