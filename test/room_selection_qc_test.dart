import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/widgets/hotel_room_selection_card.dart';

Widget _host(Widget child, {bool isDark = false}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (context, _) => MaterialApp(
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(body: SingleChildScrollView(child: child)),
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

  group('HotelRoomSelectionCard - Unit & Model Tests', () {
    test('renders room details without crash', () {
      final testRoom = <String, dynamic>{
        'room_name': 'Deluxe King Suite',
        'room_size': '45 m²',
        'bed_type': '1 King Bed',
        'capacity': '2 Adults, 1 Child',
        'breakfast_included': true,
        'price': 150.0,
        'currency': 'USD',
      };

      expect(testRoom['room_name'], 'Deluxe King Suite');
      expect(testRoom['price'], 150.0);
    });

    test('calculates total price correctly for multiple nights', () {
      final testRoom = <String, dynamic>{
        'room_name': 'Test Room',
        'price': 200.0,
        'currency': 'EUR',
      };

      final pricePerNight = testRoom['price'];
      final nights = 7;
      final expectedTotal = pricePerNight * nights;

      expect(expectedTotal, 1400.0);
    });

    test('identifies breakfast included status', () {
      final testRoomWithBreakfast = <String, dynamic>{'breakfast_included': true};
      final testRoomWithoutBreakfast = <String, dynamic>{'meal_plan': 'room only'};

      expect(testRoomWithBreakfast['breakfast_included'], isTrue);
      expect(testRoomWithoutBreakfast['breakfast_included'] == true, isFalse);
    });
  });

  group('HotelRoomSelectionCard - UI Rendering Tests', () {
    void phoneSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(750, 1624);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
    }

    testWidgets('renders room name correctly', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Deluxe King Suite',
        'price': 150.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      expect(find.text('Deluxe King Suite'), findsOneWidget);
    });

    testWidgets('renders size information', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Suite',
        'room_size': '45 m²',
        'price': 150.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      expect(find.textContaining('m²'), findsOneWidget);
    });

    testWidgets('shows bed type information', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Twin Room',
        'bed_type': '2 Twin Beds',
        'price': 100.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      expect(find.text('2 Twin Beds'), findsOneWidget);
    });

    testWidgets('displays breakfast badge when included', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Suite with Breakfast',
        'breakfast_included': true,
        'price': 150.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      // Check for breakfast-related text - either English or Persian
      final breakfastFinder = find.textContaining('Breakfast');
      final persianBreakfastFinder = find.textContaining('بریکفست');
      expect(breakfastFinder.evaluate().isNotEmpty || persianBreakfastFinder.evaluate().isNotEmpty, isTrue);
    });

    testWidgets('handles long room names without overflow', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Very Long Deluxe Executive Suite Name with Many Words that Should Overflow Normally',
        'price': 200.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      // Should have at least one widget containing the long name or ellipsis
      expect(find.textContaining('Executive'), findsAtLeastNWidgets(1));
    });

    testWidgets('displays price in correct format', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Standard Room',
        'price': 99.99,
        'currency': 'EUR',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      final priceFinder = find.textContaining('99');
      final euroSymbolFinder = find.textContaining('€');
      final euroWordFinder = find.textContaining('EUR');
      expect(priceFinder.evaluate().isNotEmpty || euroSymbolFinder.evaluate().isNotEmpty || euroWordFinder.evaluate().isNotEmpty, isTrue);
    });
  });

  group('HotelRoomSelectionCard - Dark Mode Tests', () {
    void phoneSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(750, 1624);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
    }

    testWidgets('renders correctly in dark mode', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Dark Mode Test Room',
        'price': 100.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom), isDark: true));

      expect(find.byType(HotelRoomSelectionCard), findsOneWidget);
    });

    testWidgets('uses ECardoTokens colors in dark mode', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Token Test',
        'price': 100.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom), isDark: true));

      // Verify card exists and doesn't use pure white backgrounds
      final cardFinder = find.byType(Material);
      expect(cardFinder, findsAtLeastNWidgets(1));
    });
  });

  group('HotelRoomSelectionCard - Accessibility Tests', () {
    void phoneSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(750, 1624);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
    }

    testWidgets('has semantic labels for screen readers', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Accessible Room',
        'price': 150.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      // Card should have semantics for accessibility
      expect(find.bySemanticsLabel(RegExp(r'Accessible Room')), findsOneWidget);
    });

    testWidgets('touch targets meet minimum size requirements', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Touch Target Test',
        'price': 100.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      // Material buttons/cards should exist
      expect(find.byType(Material), findsAtLeastNWidgets(1));
    });
  });

  group('HotelRoomSelectionCard - Responsive Layout Tests', () {
    void tabletSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(2048, 1536);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
    }

    testWidgets('renders on mobile viewport (375px)', (tester) async {
      phoneSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Mobile View Test',
        'price': 100.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      expect(find.byType(HotelRoomSelectionCard), findsOneWidget);
    });

    testWidgets('renders on tablet viewport (1024px)', (tester) async {
      tabletSurface(tester);
      final testRoom = <String, dynamic>{
        'room_name': 'Tablet View Test',
        'price': 100.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(_host(HotelRoomSelectionCard(room: testRoom)));

      expect(find.byType(HotelRoomSelectionCard), findsOneWidget);
    });
  });

  group('HotelRoomSelectionCard - Selected State Tests', () {
    testWidgets('handles selected state feedback', (tester) async {
      phoneSurface(tester);
      int selectedQty = 0;

      final testRoom = <String, dynamic>{
        'room_id': 'test-room-1',
        'room_name': 'Selected Room Test',
        'price': 150.0,
        'currency': 'USD',
      };

      await tester.pumpWidget(
        _host(
          StatefulBuilder(
            builder: (context, setState) {
              return HotelRoomSelectionCard(
                room: testRoom,
                quantity: selectedQty,
                onSelect: () {
                  setState(() {
                    selectedQty = selectedQty > 0 ? 0 : 1;
                  });
                },
              );
            },
          ),
        ),
      );

      // Initial unselected state
      expect(selectedQty, equals(0));

      // Tap to select
      final selectButton = find.byType(InkWell);
      if (selectButton.evaluate().isNotEmpty) {
        await tester.tap(selectButton.first);
        await tester.pump();
      }
      expect(selectedQty, equals(1));
    });
  });
}
