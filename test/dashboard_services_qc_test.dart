import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/model/dashboard_model.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/business_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/other_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// v1.0.45 (QC): dashboard services hub rework —
///   1. financial tab keeps the money-services grid (dynamic password
///      stays the first tile)
///   2. travel tab shows the destination-country chips + built modules
///      (flights / hotels / eSIM) + the not-yet-built services greyed out
///   3. business services card shows remittance + P2P escrow + the locked
///      upcoming modules
/// and the whole hub settles without exceptions in LTR and RTL.
class _TestHomeController extends HomeController {
  @override
  // The real onInit fires live network calls + plugin channels; the widgets
  // under QC only need the Rx state this test seeds directly.
  // ignore: must_call_super
  void onInit() {}
}

class _TestKycController extends KycLevelController {
  @override
  // The real onInit fires live network calls + plugin channels.
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<SettingsService>(SettingsService());
    Get.put<HomeController>(_TestHomeController());
    Get.put<KycLevelController>(_TestKycController());
  });

  tearDown(Get.reset);

  Widget buildSubject({Locale locale = const Locale('en')}) {
    return GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('fa')],
      locale: locale,
      home: const Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              OtherServicesSection(),
              BusinessServicesSection(),
              SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }

  /// Real-phone geometry (360dp logical width): the service grid's fixed
  /// row-height math fits two rows inside its viewport only at phone
  /// widths — the default 800x600 test surface widens the columns until
  /// row 2 falls outside the PageView viewport and never builds.
  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(720, 1600);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  void seedData(HomeController home) {
    home.dashboardModel.value = DashboardModel.fromJson({
      'status': 'success',
      'data': {
        'referral': {'bonus': '0', 'count': 0},
        'info': {'unread_notifications_count': 0, 'time_wise_wish': 'Day'},
      },
    });
    home.userModel.value = UserModel.fromJson({
      'status': 'success',
      'data': {
        'kyc_level': 2,
        'passcode': '0',
        'kyc': 2,
        'addons': <String, dynamic>{
          'travel': true,
          'virtual_cards': true,
          'p2p_trading': true,
          'gift_cards': true,
        },
      },
    });
  }

  testWidgets(
    'financial tab renders the money grid with dynamic password first, '
    'business card below (LTR)',
    (tester) async {
      final home = Get.find<HomeController>();
      seedData(home);
      phoneSurface(tester);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      expect(find.text('Financial Services'), findsWidgets);
      expect(find.text('Dynamic PIN'), findsOneWidget);
      expect(find.text('Business & Commercial Services'), findsOneWidget);
      expect(find.text('Remittance'), findsOneWidget);
      expect(find.text('P2P Escrow'), findsOneWidget);
      expect(find.text('Service Guarantee'), findsOneWidget);
      expect(find.text('Bank Loan'), findsOneWidget);
      expect(find.text('Stocks & Exchange'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'travel tab shows destination chips, built modules and the locked '
    'upcoming services',
    (tester) async {
      final home = Get.find<HomeController>();
      seedData(home);
      phoneSurface(tester);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Switch to the travel tab (unique before the switch — the header
      // only shows the financial title while tab 1 is active).
      await tester.tap(find.text('Travel Services'));
      await tester.pumpAndSettle();

      expect(find.text('Travel Services'), findsWidgets);
      expect(find.text('Choose your destination to see available services'),
          findsOneWidget);
      // Page 1 of the travel grid: built modules + first locked services.
      expect(find.text('Flights'), findsOneWidget);
      expect(find.text('Hotels'), findsOneWidget);
      expect(find.text('eSIM'), findsOneWidget);
      expect(find.text('Visa'), findsOneWidget);
      expect(find.text('Taxi'), findsOneWidget);

      // Destination countries render as chips (the chip row is a lazy
      // horizontal ListView — the tail is asserted after scrolling it).
      expect(find.text('China'), findsOneWidget);
      expect(find.text('Russia'), findsOneWidget);
      expect(find.text('Turkey'), findsOneWidget);

      await tester.drag(find.byType(ListView).first, const Offset(-300, 0));
      await tester.pumpAndSettle();
      expect(find.text('UAE'), findsOneWidget);
      expect(find.text('Iraq'), findsOneWidget);
      expect(find.text('Oman'), findsOneWidget);
      expect(find.text('Georgia'), findsOneWidget);

      // Selecting a destination rebuilds the hub without exceptions.
      await tester.tap(find.text('Georgia'));
      await tester.pumpAndSettle();

      // Page the travel grid to the second page (locked services tail).
      await tester.drag(find.byType(PageView).first, const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Insurance'), findsOneWidget);

      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'paging the financial grid deep then switching tabs does not build an '
    'out-of-range travel page (grid state is per-tab)',
    (tester) async {
      final home = Get.find<HomeController>();
      seedData(home);
      phoneSurface(tester);

      await tester.pumpWidget(buildSubject());
      await tester.pumpAndSettle();

      // Financial grid: 17 tiles = 3 pages — drag to the last page so the
      // shared grid state sits on page index 2.
      await tester.drag(find.byType(PageView).first, const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView).first, const Offset(-400, 0));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(PageView).first, const Offset(-400, 0));
      await tester.pumpAndSettle();

      // Switch to travel (15 tiles = 2 pages). Without the per-tab key the
      // retained PageController position makes PageView build page 3 of a
      // 2-page list.
      await tester.tap(find.text('Travel Services'));
      await tester.pumpAndSettle();

      expect(find.text('Flights'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('services hub settles in Persian (RTL) without exceptions', (
    tester,
  ) async {
    final home = Get.find<HomeController>();
    seedData(home);
    phoneSurface(tester);

    await tester.pumpWidget(buildSubject(locale: const Locale('fa')));
    await tester.pumpAndSettle();

    expect(find.text('خدمات مالی'), findsWidgets);
    expect(find.text('رمز پویا'), findsOneWidget);
    expect(find.text('خدمات بازرگانی و کسب‌وکار'), findsOneWidget);
    expect(find.text('حواله بین‌الملل'), findsOneWidget);

    // Directionality follows the fa locale.
    final context = tester.element(find.byType(OtherServicesSection));
    expect(Directionality.of(context), TextDirection.rtl);

    expect(tester.takeException(), isNull);
  });
}
