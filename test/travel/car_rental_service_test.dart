import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/rental/models/rental_models.dart';
import 'package:ecardo_user/src/rental/screens/rental_home_screen.dart';

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

  group('Car Rental Service - Models & Deserialization Tests', () {
    test('CarModel parses full vehicle specifications from live API spec', () {
      final json = {
        'id': 1,
        'owner_type': 'FLEET',
        'title': 'پژو ۲۰۷ اتوماتیک — تحویل فرودگاه',
        'brand': 'Peugeot',
        'model': '207',
        'year': 2023,
        'category': 'ECONOMY',
        'transmission': 'AUTO',
        'fuel_type': 'GASOLINE',
        'seats': 5,
        'specs': {'ac': true, 'bluetooth': true},
        'photos': null,
        'features': {'child_seat': true, 'airport_delivery': true},
        'daily_price': 85,
        'deposit_amount': 300,
        'daily_km_limit': 200,
        'extra_km_rate': 0.3,
        'min_age': 21,
        'min_license_years': 1,
        'insurance_tiers': [
          {'tier': 'BASIC', 'deductible_pct': 30, 'extra_cost': 0},
          {'tier': 'FULL', 'deductible_pct': 10, 'extra_cost': 12},
          {'tier': 'ZERO_DEDUCTIBLE', 'deductible_pct': 0, 'extra_cost': 25},
        ],
        'pickup_location': 'فرودگاه امام خمینی — دفتر ناوگان',
        'is_active': true,
        'created_at': '2026-09-29T11:18:55.000000Z',
        'updated_at': '2026-09-29T11:18:55.000000Z',
      };

      final car = CarModel.fromJson(json);

      expect(car.id, 1);
      expect(car.ownerType, 'FLEET');
      expect(car.isFleet, isTrue);
      expect(car.title, 'پژو ۲۰۷ اتوماتیک — تحویل فرودگاه');
      expect(car.brand, 'Peugeot');
      expect(car.model, '207');
      expect(car.category, 'ECONOMY');
      expect(car.transmission, 'AUTO');
      expect(car.dailyPrice, 85.0);
      expect(car.depositAmount, 300.0);
      expect(car.dailyKmLimit, 200);
      expect(car.extraKmRate, 0.3);
      expect(car.minAge, 21);
      expect(car.minLicenseYears, 1);
      expect(car.pickupLocation, 'فرودگاه امام خمینی — دفتر ناوگان');
      expect(car.insuranceTiers.length, 3);
      expect(car.isActive, isTrue);
    });

    test('CarModel tolerates live null photos and map-shaped features', () {
      // The live /rental/cars payload returns photos: null and features as a
      // Map of boolean flags, so the model must not assume a List here.
      final json = {
        'id': 2,
        'owner_type': 'HOST',
        'title': 'Toyota Corolla — Classic',
        'category': 'ECONOMY',
        'daily_price': 350,
        'deposit_amount': 200,
        'daily_km_limit': 250,
        'extra_km_rate': 0.25,
        'min_age': 21,
        'min_license_years': 1,
        'insurance_tiers': null,
        'photos': null,
        'features': {'child_seat': true},
        'is_active': true,
      };

      final car = CarModel.fromJson(json);

      expect(car.isFleet, isFalse);
      expect(car.photos, isEmpty);
      expect(car.features, isNotEmpty);
      expect(car.insuranceTiers, isEmpty);
    });

    test('RentalBookingModel parses rental lifecycle and escrow deposit status', () {
      final json = {
        'id': 101,
        'booking_no': 'RNB-2026-8801',
        'pickup_at': '2026-11-01 10:00:00',
        'return_at': '2026-11-04 10:00:00',
        'rental_total': 255.0,
        'insurance_tier': 'FULL',
        'extras_total': 36.0,
        'status': 'CONFIRMED',
        'deposit': {
          'id': 9,
          'amount': 300.0,
          'currency': 'USD',
          'status': 'LOCKED',
          'released_amount': 0.0,
          'consumed_amount': 0.0,
        },
        'car': {
          'id': 1,
          'owner_type': 'FLEET',
          'title': 'Peugeot 207 Automatic',
          'category': 'ECONOMY',
          'daily_price': 85.0,
          'deposit_amount': 300.0,
          'daily_km_limit': 200,
          'extra_km_rate': 0.3,
          'min_age': 21,
          'min_license_years': 1,
          'is_active': true,
          'insurance_tiers': [],
          'photos': [],
          'features': [],
        },
        'events': [
          {
            'id': 1,
            'actor_role': 'RENTER',
            'reason': 'Booking submitted',
            'created_at': '2026-11-01 10:00:00',
          },
        ],
      };

      final booking = RentalBookingModel.fromJson(json);

      expect(booking.id, 101);
      expect(booking.bookingNo, 'RNB-2026-8801');
      expect(booking.insuranceTier, 'FULL');
      expect(booking.rentalTotal, 255.0);
      expect(booking.extrasTotal, 36.0);
      expect(booking.grandTotal, 291.0);
      expect(booking.status, 'CONFIRMED');
      expect(booking.deposit?.amount, 300.0);
      expect(booking.deposit?.status, 'LOCKED');
      expect(booking.events.length, 1);
    });
  });

  group('Car Rental Service - RentalHomeScreen UI Tests', () {
    testWidgets('renders RentalHomeScreen categories, search, and banner without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const RentalHomeScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RentalHomeScreen), findsOneWidget);
    });

    testWidgets('renders properly in Persian locale (RTL) without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const RentalHomeScreen(),
          locale: const Locale('fa'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RentalHomeScreen), findsOneWidget);
    });

    testWidgets('renders properly in Dark Theme without layout overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const RentalHomeScreen(),
          isDark: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(RentalHomeScreen), findsOneWidget);
    });
  });
}
