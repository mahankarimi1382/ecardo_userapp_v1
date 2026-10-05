import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/controllers/boat_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/models/boat_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/boat/screens/boat_voucher_screen.dart';

Widget _host(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => GetMaterialApp(
      home: child,
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  tearDown(() {
    Get.reset();
  });

  group('Boat Module Unit & Model Tests', () {
    test('BoatExperienceModel category labels are properly defined', () {
      const yacht = BoatExperienceModel(
        id: 'test-1',
        title: 'Test Yacht',
        marinaName: 'Marina Pier',
        city: 'Kish',
        category: BoatCategory.yacht,
        hourlyRate: 100.0,
        currency: 'USD',
        maxPassengers: 10,
        lengthMeters: 15.0,
        rating: 5.0,
        reviewsCount: 10,
        captainName: 'Captain Jack',
        images: [],
        features: ['AC', 'Music'],
        availableSlots: ['10:00 - 12:00'],
        addons: [
          BoatAddon(
            id: 'snorkeling',
            title: 'Snorkeling',
            price: 20.0,
            unit: 'هر نفر',
            icon: 'scuba',
          ),
          BoatAddon(
            id: 'fuel',
            title: 'Extra Fuel',
            price: 50.0,
            unit: 'پکیج',
            icon: 'fuel',
          ),
        ],
        description: 'Luxury cruising',
      );

      expect(yacht.categoryLabel, contains('Yacht'));

      final controller = Get.put(BoatController());
      controller.selectedDurationHours.value = 3;
      controller.passengerCount.value = 2;
      controller.selectedAddons.assignAll(['snorkeling', 'fuel']);

      // 100 * 3 = 300 + (20 * 2) = 40 + 50 = 390
      final total = controller.calculateTotalPrice(yacht);
      expect(total, equals(390.0));
    });

    testWidgets('BoatCatalogScreen renders catalog with boats and filters', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(_host(const BoatCatalogScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Marine & Yacht Club'), findsOneWidget);
      expect(find.text('کیش 🇮🇷'), findsOneWidget);
      expect(find.text('دبی 🇦🇪'), findsOneWidget);
      expect(find.textContaining('سان‌سیکر ۵۵'), findsOneWidget);
    });

    testWidgets('BoatVoucherScreen renders marine pass with dock and QR', (tester) async {
      phoneSurface(tester);
      final sampleBooking = BoatBookingModel(
        bookingId: 'SEA-99123',
        boatId: 'boat-01',
        boatTitle: 'Sunseeker 55ft Luxury Yacht',
        marinaName: 'Kish Island Marina Pier 3',
        date: DateTime(2026, 10, 15),
        timeSlot: '17:00 - 19:00',
        durationHours: 2,
        passengersCount: 4,
        selectedAddonIds: ['snorkeling'],
        totalAmount: 250.0,
        currency: 'USD',
        captainPhone: '+98 912 000 0000',
        pierDockNumber: 'Dock B - #12',
        status: 'confirmed',
        bookedAt: DateTime(2026, 10, 10),
      );

      await tester.pumpWidget(_host(BoatVoucherScreen(booking: sampleBooking)));
      // Wait for QR code generation and UI settling
      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text('Marine Boarding Pass'), findsOneWidget);
      expect(find.text('eCardo Marine Club'), findsOneWidget);
      expect(find.text('Sunseeker 55ft Luxury Yacht'), findsOneWidget);
      expect(find.text('Dock B - #12'), findsOneWidget);
      expect(find.textContaining('SEA-99123'), findsOneWidget);
      expect(find.text('تماس با کاپیتان'), findsOneWidget);
      expect(find.text('مسیریابی اسکله'), findsOneWidget);
    });
  });
}
