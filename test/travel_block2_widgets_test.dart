import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/widgets/esim_activation_card.dart';
import 'package:ecardo_user/src/presentation/screens/travel/esim/widgets/esim_data_usage_gauge.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/widgets/cancellation_policy_timeline.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/widgets/hotel_amenities_grid.dart';
import 'package:ecardo_user/src/presentation/screens/travel/hotels/widgets/hotel_room_selection_card.dart';
import 'package:ecardo_user/src/presentation/screens/travel/services/cip_lounge_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CipLoungeReservationScreen', () {
    testWidgets('renders CIP Lounge Reservation Screen with airport and pricing', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: CipLoungeReservationScreen(),
          ),
        ),
      );

      // Verify header and sections exist
      expect(find.text('Airport CIP & VIP Lounge'), findsOneWidget);
      expect(find.text('Select Airport'), findsOneWidget);
      expect(find.text('Flight Type'), findsOneWidget);
      expect(find.text('Flight Information'), findsOneWidget);
      expect(find.text('Guests'), findsOneWidget);
      expect(find.text('Included CIP & Lounge Amenities'), findsOneWidget);
      expect(find.text('Reserve CIP Lounge Service'), findsOneWidget);
    });

    testWidgets('increments guest count and recalculates price correctly', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: CipLoungeReservationScreen(),
          ),
        ),
      );

      // Default IKA base price for 1 adult is $45
      expect(find.text('\$45'), findsOneWidget);

      // Tap to add 1 adult
      final addIcons = find.byIcon(Icons.add_circle_outline_rounded);
      await tester.ensureVisible(addIcons.first);
      await tester.tap(addIcons.first);
      await tester.pump();

      // Now 2 adults * $45 = $90
      expect(find.text('\$90'), findsOneWidget);
    });
  });

  group('HotelRoomSelectionCard (RoomOptionCard)', () {
    testWidgets('renders room details, badges, chips, price, and responds to selection', (tester) async {
      int selectedQty = 0;

      final testRoom = <String, dynamic>{
        'room_id': 'deluxe-suite-101',
        'room_name': 'Deluxe King Suite',
        'room_size': '45 m²',
        'bed_type': '1 King Bed',
        'capacity': '2 Adults, 1 Child',
        'breakfast_included': true,
        'price': 150.0,
        'currency': 'USD',
        'features': ['City View', 'Balcony', 'Bathtub', 'High-speed Wi-Fi'],
      };

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return HotelRoomSelectionCard(
                    room: testRoom,
                    nights: 2,
                    quantity: selectedQty,
                    onQuantityChanged: (q) {
                      setState(() {
                        selectedQty = q;
                      });
                    },
                    onSelect: () {
                      setState(() {
                        selectedQty = selectedQty > 0 ? 0 : 1;
                      });
                    },
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Verify title & size
      expect(find.text('Deluxe King Suite'), findsOneWidget);
      expect(find.text('45 m²'), findsOneWidget);

      // Verify badges
      expect(find.text('Breakfast Included'), findsOneWidget);
      expect(find.text('Free Cancellation until 48h before check-in'), findsOneWidget);

      // Verify chips
      expect(find.text('1 King Bed'), findsOneWidget);
      expect(find.text('2 Adults, 1 Child'), findsOneWidget);
      expect(find.text('City View'), findsOneWidget);
      expect(find.text('Balcony'), findsOneWidget);

      // Verify initial unselected state
      expect(find.text('Select Room'), findsOneWidget);
      expect(find.text('Includes taxes & fees'), findsOneWidget);

      // Tap "Select Room" button
      await tester.tap(find.text('Select Room'));
      await tester.pump();

      // Verify selected state
      expect(selectedQty, 1);
      expect(find.text('Selected'), findsOneWidget);
    });
  });

  group('HotelAmenitiesGrid', () {
    testWidgets('renders grid with core hotel amenities and view all button', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: HotelAmenitiesGrid(),
            ),
          ),
        ),
      );

      // Check core amenities are rendered
      expect(find.text('High-Speed WiFi'), findsOneWidget);
      expect(find.text('Swimming Pool'), findsOneWidget);
      expect(find.text('Fitness Center / Gym'), findsOneWidget);
      expect(find.text('Spa & Wellness'), findsOneWidget);
      expect(find.text('Free Airport Shuttle'), findsOneWidget);
      expect(find.text('Restaurant & Bar'), findsOneWidget);

      // Check button to view all amenities
      expect(find.textContaining('View all amenities'), findsOneWidget);
    });
  });

  group('CancellationPolicyTimelineCard', () {
    testWidgets('renders 3 cancellation stages and wallet deposit rules', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CancellationPolicyTimelineCard(
                checkInDate: DateTime(2026, 10, 15, 14, 0),
              ),
            ),
          ),
        ),
      );

      // Check stages are visible
      expect(find.text('100% Refund'), findsOneWidget);
      expect(find.text('Partial Refund'), findsOneWidget);
      expect(find.text('0% Refund'), findsOneWidget);

      // Check wallet deposit rules summary
      expect(
        find.text('Refunds deposit directly to your eCardo Wallet within 1-24 hours.'),
        findsOneWidget,
      );
    });
  });

  group('EsimDataUsageGauge', () {
    testWidgets('renders total data, remaining data, days left, and responds to top-up tap', (tester) async {
      bool topUpTapped = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: EsimDataUsageGauge(
                totalDataGb: 10.0,
                usedDataGb: 6.4,
                daysRemaining: 14,
                countryOrRegion: 'Turkey & Europe',
                onTopUpTap: () => topUpTapped = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check numbers and labels
      expect(find.text('Turkey & Europe'), findsOneWidget);
      expect(find.text('Active eSIM'), findsOneWidget);
      expect(find.text('3.6 GB'), findsOneWidget);
      expect(find.text('Remaining of 10.0 GB'), findsOneWidget);
      expect(find.text('14 Days left'), findsOneWidget);
      expect(find.text('6.4 GB'), findsOneWidget);
      expect(find.text('36% Available'), findsOneWidget);

      // Verify top up button
      final topUpButton = find.text('+ Top-Up Data');
      expect(topUpButton, findsOneWidget);
      await tester.tap(topUpButton);
      expect(topUpTapped, true);
    });

    testWidgets('shows low data alert when remaining is under 15%', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: EsimDataUsageGauge(
                totalDataGb: 10.0,
                usedDataGb: 9.2, // 0.8 GB remaining = 8% (<15%)
                daysRemaining: 5,
                countryOrRegion: 'Global',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Low Data Alert'), findsOneWidget);
      expect(find.text('0.8 GB'), findsOneWidget);
    });
  });

  group('EsimActivationCard', () {
    testWidgets('renders QR code, SM-DP+ address, activation code, and installation steps', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EsimActivationCard(
                  smdpAddress: 'rsp.truphone.com',
                  activationCode: 'EC-TR-98421-B884',
                  confirmationCode: 'None',
                  countryOrRegion: 'Turkey & Europe',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header & titles
      expect(find.text('eSIM Activation & Setup'), findsOneWidget);
      expect(find.text('SM-DP+ Address'), findsOneWidget);
      expect(find.text('rsp.truphone.com'), findsOneWidget);
      expect(find.text('Activation Code'), findsOneWidget);
      expect(find.text('EC-TR-98421-B884'), findsOneWidget);
      expect(find.text('Confirmation Code'), findsOneWidget);
      expect(find.text('None (Not Required)'), findsOneWidget);

      // Verify iOS vs Android tabs
      expect(find.text('iOS (iPhone / iPad)'), findsOneWidget);
      expect(find.text('Android'), findsOneWidget);

      // Default is iOS steps
      expect(find.text('1. Open Cellular Settings'), findsOneWidget);

      // Switch to Android
      await tester.tap(find.text('Android'));
      await tester.pumpAndSettle();

      expect(find.text('1. Open SIM Manager'), findsOneWidget);
    });
  });
}

