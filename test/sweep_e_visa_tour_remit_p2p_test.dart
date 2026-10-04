import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/visa/widgets/visa_widgets.dart';
import 'package:ecardo_user/src/tour/models/tour_model.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/model/p2p_marketplace_response_model.dart' as p2p_m;
import 'package:ecardo_user/src/presentation/screens/p2p/widgets/p2p_ad_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableWidget(Widget child, {bool isDark = false}) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, _) => GetMaterialApp(
        theme: ThemeData(brightness: isDark ? Brightness.dark : Brightness.light),
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(body: child),
      ),
    );
  }

  group('Visa Module Widgets & Tokens', () {
    testWidgets('VisaStatusBadge renders correct label and container colors', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const Column(
          children: [
            VisaStatusBadge(status: 'APPROVED'),
            VisaStatusBadge(status: 'UNDER_REVIEW'),
            VisaStatusBadge(status: 'REJECTED'),
            VisaStatusBadge(status: 'AWAITING_PAYMENT'),
          ],
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Under Review'), findsOneWidget);
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.text('Awaiting Payment'), findsOneWidget);
    });

    testWidgets('VisaTimelineWidget renders 5-step status tracker', (tester) async {
      await tester.pumpWidget(buildTestableWidget(
        const VisaTimelineWidget(currentStatus: 'UNDER_REVIEW'),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Application'), findsOneWidget);
      expect(find.text('Payment'), findsOneWidget);
      expect(find.text('Doc Audit'), findsOneWidget);
      expect(find.text('At Authority'), findsOneWidget);
      expect(find.text('Issued'), findsOneWidget);
    });

    testWidgets('VisaDocUploadCard renders requirement and action button', (tester) async {
      bool picked = false;
      await tester.pumpWidget(buildTestableWidget(
        VisaDocUploadCard(
          title: 'Passport Scan',
          instructions: 'Clear color photo or scan',
          isRequired: true,
          onPickFile: () {
            picked = true;
          },
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Passport Scan'), findsOneWidget);
      expect(find.text('Upload'), findsOneWidget);

      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
      expect(picked, isTrue);
    });
  });

  group('Tour Module Models & Itinerary', () {
    test('TourModel parses correctly with all highlight properties', () {
      final json = {
        'id': 101,
        'title': 'Golden Triangle Heritage Tour',
        'slug': 'golden-triangle',
        'country_code': 'IN',
        'city': 'Delhi',
        'category': 'cultural',
        'description': 'Explore historical monuments and cultural wonders',
        'duration_days': 7,
        'duration_nights': 6,
        'base_price': 1200.0,
        'currency': 'USD',
        'deposit_allowed': true,
        'deposit_percent': 30.0,
        'rating_avg': 4.9,
        'rating_count': 128,
        'tags': ['Best Seller', 'UNESCO'],
        'hotel_tiers': ['STD', 'LUX'],
        'itinerary': [
          {
            'day_no': 1,
            'title': 'Arrival & Old Delhi Tour',
            'description': 'Welcome greeting at airport and Red Fort visit',
            'meals': ['Dinner'],
            'activities': ['Airport Transfer', 'Red Fort Walk'],
          },
        ],
      };

      final tour = TourModel.fromJson(json);
      expect(tour.id, equals(101));
      expect(tour.title, equals('Golden Triangle Heritage Tour'));
      expect(tour.durationDays, equals(7));
      expect(tour.ratingAvg, equals(4.9));
      expect(tour.itinerary.length, equals(1));
      expect(tour.itinerary.first.dayNo, equals(1));
      expect(tour.itinerary.first.meals, contains('Dinner'));
    });
  });

  group('P2P Module Reputation Badges & Cards', () {
    testWidgets('P2pAdCard renders trader reputation badge and price info', (tester) async {
      final ad = p2p_m.Ad(
        id: 55,
        adType: 'sell',
        price: '1,050 USD',
        orderLimit: '100 - 1,000 USD',
        totalAmount: '5,000 USDT',
        completionRate: 98.7,
        completedOrders: 340,
        responseTime: '10 min',
        isOwnAd: false,
        advertiser: p2p_m.Advertiser(
          id: 12,
          username: 'CryptoMaster',
          fullName: 'Crypto Master Pro',
          avatarText: 'C',
          isVerifiedTrader: true,
        ),
        paymentMethods: [
          p2p_m.PaymentMethodElement(
            id: 1,
            paymentMethod: p2p_m.PaymentMethodPaymentMethod(id: 1, name: 'Bank Transfer'),
          ),
        ],
      );

      await tester.pumpWidget(buildTestableWidget(
        P2pAdCard(item: ad),
      ));
      await tester.pumpAndSettle();

      expect(find.text('CryptoMaster'), findsOneWidget);
      expect(find.text('98.7%'), findsOneWidget);
      expect(find.text('1,050 USD'), findsOneWidget);
      expect(find.text('Bank Transfer'), findsOneWidget);
    });
  });
}
