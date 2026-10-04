import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/controllers/local_experience_controller.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/models/local_experience_models.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_catalog_screen.dart';
import 'package:ecardo_user/src/presentation/screens/travel/local/screens/local_voucher_screen.dart';

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

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('PonnamKarthik/fluttertoast'),
      (MethodCall methodCall) async => true,
    );
  });

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  tearDown(() {
    Get.reset();
  });

  group('Local Experiences Unit & Model Tests', () {
    test('LocalExperienceItemModel type labels and booking execution work', () async {
      const item = LocalExperienceItemModel(
        id: 'test-local-1',
        title: 'Istanbul Historical Tour',
        subtitle: 'Sultanahmet and Bosphorus',
        providerName: 'Amin Khalili',
        city: 'Istanbul',
        type: LocalServiceType.tourGuide,
        price: 50.0,
        currency: 'USD',
        durationLabel: '4 hours',
        languages: ['فارسی', 'English'],
        rating: 4.9,
        reviewsCount: 20,
        highlights: ['Topkapi Palace', 'Hagia Sophia'],
        meetingPoint: 'Sultanahmet Square',
        description: 'Deep dive into history',
      );

      expect(item.typeLabel, contains('Tour Guide'));

      final controller = Get.put(LocalExperienceController());
      final booking = await controller.bookExperience(item: item);

      expect(booking, isNotNull);
      expect(booking!.serviceId, equals('test-local-1'));
      expect(booking.totalAmount, equals(50.0));
      expect(controller.myBookings.first.serviceTitle, equals(item.title));
    });

    testWidgets('LocalCatalogScreen renders experiences and city filters', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(_host(const LocalCatalogScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Local Guides & Experiences'), findsOneWidget);
      expect(find.text('استانبول 🇹🇷'), findsOneWidget);
      expect(find.text('دبی 🇦🇪'), findsOneWidget);
      expect(find.textContaining('استاد امین خلیلی'), findsOneWidget);
    });

    testWidgets('LocalVoucherScreen renders experience pass with meeting point and QR', (tester) async {
      phoneSurface(tester);
      final sampleBooking = LocalBookingModel(
        bookingId: 'EXP-12345',
        serviceId: 'local-01',
        serviceTitle: 'Istanbul Old City Tour',
        providerName: 'Amin Khalili',
        city: 'Istanbul',
        serviceDate: DateTime(2026, 10, 20),
        serviceTime: '10:00',
        guestsCount: 2,
        totalAmount: 50.0,
        currency: 'USD',
        meetingPoint: 'Sultanahmet Gate #1',
        providerPhone: '+90 532 000 0000',
        status: 'confirmed',
        bookedAt: DateTime(2026, 10, 10),
      );

      await tester.pumpWidget(_host(LocalVoucherScreen(booking: sampleBooking)));
      await tester.pumpAndSettle();

      expect(find.text('Local Service Pass'), findsOneWidget);
      expect(find.text('eCardo Local Experiences'), findsOneWidget);
      expect(find.text('Istanbul Old City Tour'), findsOneWidget);
      expect(find.text('Sultanahmet Gate #1'), findsOneWidget);
      expect(find.textContaining('EXP-12345'), findsOneWidget);
      expect(find.text('تماس با مجری'), findsOneWidget);
      expect(find.text('مسیریابی نقطه قرار'), findsOneWidget);
    });
  });
}
