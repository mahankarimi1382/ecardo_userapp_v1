import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/tour/models/tour_model.dart';
import 'package:ecardo_user/src/tour/screens/tour_list_screen.dart';

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

  group('Tour Service - Models & Deserialization Tests', () {
    test('TourModel deserializes comprehensive itinerary and departures', () {
      final json = {
        'id': 201,
        'title': 'Silk Road Odyssey Tour',
        'slug': 'silk-road-odyssey',
        'country_code': 'CN',
        'city': 'Xi\'an',
        'category': 'cultural',
        'description': 'Experience ancient history and heritage along the Silk Road',
        'duration_days': 10,
        'duration_nights': 9,
        'base_price': 1850.0,
        'currency': 'USD',
        'deposit_allowed': true,
        'deposit_percent': 25.0,
        'rating_avg': 4.95,
        'rating_count': 64,
        'tags': ['Historical', 'Terracotta Warriors'],
        'hotel_tiers': ['STD', 'LUX'],
        'execution_models': ['group', 'private'],
        'itinerary': [
          {
            'day_no': 1,
            'title': 'Arrival & Ancient City Wall',
            'description': 'Welcome reception and cycling on the historic city walls',
            'meals': ['Dinner'],
            'activities': ['Airport Pickup', 'City Wall Cycling'],
          },
          {
            'day_no': 2,
            'title': 'Terracotta Army Discovery',
            'description': 'Exclusive tour of the Emperor Qinshihuang Mausoleum',
            'meals': ['Breakfast', 'Lunch'],
            'activities': ['Museum Guide', 'Pottery Workshop'],
          },
        ],
        'departures': [
          {
            'id': 1001,
            'depart_date': '2026-11-01',
            'return_date': '2026-11-10',
            'capacity': 20,
            'available_seats': 12,
            'status': 'available',
            'price_multiplier': 1.0,
          },
        ],
      };

      final tour = TourModel.fromJson(json);

      expect(tour.id, 201);
      expect(tour.title, 'Silk Road Odyssey Tour');
      expect(tour.durationDays, 10);
      expect(tour.durationNights, 9);
      expect(tour.basePrice, 1850.0);
      expect(tour.currency, 'USD');
      expect(tour.depositAllowed, isTrue);
      expect(tour.depositPercent, 25.0);
      expect(tour.ratingAvg, 4.95);
      expect(tour.itinerary.length, 2);
      expect(tour.itinerary[0].dayNo, 1);
      expect(tour.itinerary[1].title, 'Terracotta Army Discovery');
      expect(tour.departures.length, 1);
      expect(tour.departures.first.capacity, 20);
      expect(tour.departures.first.availableSeats, 12);
    });

    test('TourBookingModel deserializes booking milestones and payment status', () {
      final json = {
        'id': 5001,
        'booking_no': 'TR-2026-9871',
        'tour_title': 'Silk Road Odyssey Tour',
        'tour_city': 'Xi\'an',
        'status': 'CONFIRMED',
        'tier': 'LUX',
        'model': 'private',
        'travelers_count': 3,
        'adults_count': 2,
        'children_count': 1,
        'base_price': 3700.0,
        'total_price': 4200.0,
        'paid_amount': 4200.0,
        'remaining_balance': 0.0,
        'currency': 'USD',
        'depart_date': '2026-11-01',
        'return_date': '2026-11-10',
      };

      final booking = TourBookingModel.fromJson(json);

      expect(booking.id, 5001);
      expect(booking.bookingNo, 'TR-2026-9871');
      expect(booking.status, 'CONFIRMED');
      expect(booking.totalPrice, 4200.0);
      expect(booking.adultsCount, 2);
      expect(booking.childrenCount, 1);
    });
  });

  group('Tour Service - TourListScreen UI Tests', () {
    testWidgets('renders category chips, headers, and search bar without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TourListScreen(),
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TourListScreen), findsOneWidget);
      expect(find.text('All Tours'), findsOneWidget);
      expect(find.text('Nature'), findsOneWidget);
      expect(find.text('Cultural'), findsOneWidget);
    });

    testWidgets('renders properly in Persian locale and RTL direction', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TourListScreen(),
          locale: const Locale('fa'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TourListScreen), findsOneWidget);
      expect(find.text('همه تورها'), findsOneWidget);
      expect(find.text('طبیعت‌گردی'), findsOneWidget);
      expect(find.text('فرهنگی و تاریخی'), findsOneWidget);
    });

    testWidgets('renders properly in Dark Mode without layout overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapWithTheme(
          const TourListScreen(),
          isDark: true,
          locale: const Locale('en'),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.byType(TourListScreen), findsOneWidget);
      expect(find.text('All Tours'), findsOneWidget);
    });
  });
}
