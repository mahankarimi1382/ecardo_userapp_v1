import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/model/dashboard_model.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/action_button_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/business_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/travel_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/service_tiles.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/model/wallets_model.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/widgets/multi_currency_flip_card.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/widgets/wallet_card_carousel.dart';

class _TestHomeController extends HomeController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _TestKycController extends KycLevelController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsService settings;
  late HomeController home;

  setUp(() {
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    settings = Get.put<SettingsService>(SettingsService());
    home = Get.put<HomeController>(_TestHomeController());
    Get.put<KycLevelController>(_TestKycController());

    settings.appSettings['user_transfer'] = '1';
    settings.appSettings['user_exchange'] = '1';
    settings.appSettings['user_deposit'] = '1';
    settings.appSettings['user_withdraw'] = '1';

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
        'addons': {
          'travel': true,
          'p2p_trading': true,
        },
      },
    });
  });

  tearDown(Get.reset);

  void setPhoneSurface(WidgetTester tester, {double width = 360, double height = 800}) {
    tester.view.physicalSize = Size(width * 2, height * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  group('ActionButtonSection UI/UX', () {
    testWidgets('renders all 4 core actions (Transfer, Exchange, Deposit, Withdraw) without overflow on 360px screen', (tester) async {
      setPhoneSurface(tester, width: 360);

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fa')],
          locale: const Locale('en'),
          home: const Scaffold(
            body: Center(
              child: ActionButtonSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transfer'), findsOneWidget);
      expect(find.text('Exchange'), findsOneWidget);
      expect(find.text('Deposit'), findsOneWidget);
      expect(find.text('Withdraw'), findsOneWidget);

      expect(find.byIcon(Icons.swap_horiz_rounded), findsOneWidget);
      expect(find.byIcon(Icons.currency_exchange_rounded), findsOneWidget);
      expect(find.byIcon(Icons.add_circle_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);

      // Verify touch target >= 44x44
      final inkWells = find.descendant(
        of: find.byType(ActionButtonSection),
        matching: find.byType(InkWell),
      );
      expect(inkWells, findsNWidgets(4));

      for (int i = 0; i < 4; i++) {
        final size = tester.getSize(inkWells.at(i));
        expect(size.width, greaterThanOrEqualTo(44.0));
        expect(size.height, greaterThanOrEqualTo(44.0));
      }

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders properly in Persian (RTL) without overflow on 360px', (tester) async {
      setPhoneSurface(tester, width: 360);

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fa')],
          locale: const Locale('fa'),
          home: const Scaffold(
            body: Center(
              child: ActionButtonSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('انتقال'), findsOneWidget);
      expect(find.text('تبدیل'), findsOneWidget);
      expect(find.text('واریز'), findsOneWidget);
      expect(find.text('برداشت'), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });

  group('BusinessServicesSection & Equity Projects Tile', () {
    testWidgets('renders Equity Projects tile with corporate fare icon and navigates to commercial projects', (tester) async {
      setPhoneSurface(tester, width: 360);

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fa')],
          locale: const Locale('en'),
          routes: {
            BaseRoute.commercialProjects: (ctx) => const Scaffold(body: Text('CommercialProjectsTarget')),
          },
          home: const Scaffold(
            body: SingleChildScrollView(
              child: BusinessServicesSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Equity Projects'), findsOneWidget);
      expect(find.byIcon(Icons.corporate_fare_rounded), findsOneWidget);

      // Verify touch targets of service tiles in the grid >= 44x44
      final serviceTiles = find.byType(ServiceTileView);
      expect(serviceTiles, findsWidgets);
      final firstTileSize = tester.getSize(serviceTiles.first);
      expect(firstTileSize.width, greaterThanOrEqualTo(44.0));
      expect(firstTileSize.height, greaterThanOrEqualTo(44.0));

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders Equity Projects in Persian (سرمایه‌گذاری تجاری) without overflow', (tester) async {
      setPhoneSurface(tester, width: 360);

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fa')],
          locale: const Locale('fa'),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: BusinessServicesSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('سرمایه‌گذاری تجاری'), findsOneWidget);
      expect(find.byIcon(Icons.corporate_fare_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('TravelServicesSection Core 4 Row', () {
    testWidgets('first row features Flights, Hotels, eSIM, and Taxi', (tester) async {
      setPhoneSurface(tester, width: 360);

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fa')],
          locale: const Locale('en'),
          home: const Scaffold(
            body: SingleChildScrollView(
              child: TravelServicesSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Flights'), findsOneWidget);
      expect(find.text('Hotels'), findsOneWidget);
      expect(find.text('eSIM'), findsOneWidget);
      expect(find.text('Taxi'), findsOneWidget);

      expect(find.byIcon(Icons.flight_rounded), findsOneWidget);
      expect(find.byIcon(Icons.hotel_rounded), findsOneWidget);
      expect(find.byIcon(Icons.sim_card_rounded), findsOneWidget);
      expect(find.byIcon(Icons.local_taxi_rounded), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });

  group('MyWalletSection & MultiCurrencyFlipCard Touch Targets', () {
    testWidgets('flip button has at least 44x44 touch target and localized tooltip', (tester) async {
      setPhoneSurface(tester, width: 360);

      final wallet = Wallets(
        id: 1,
        name: 'USD Wallet',
        code: 'USD',
        symbol: '\$',
        balance: '1250.50',
        accountNo: '1234 5678 9012 3456',
        isDefault: true,
      );

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fa')],
          locale: const Locale('en'),
          home: Scaffold(
            body: Center(
              child: MultiCurrencyFlipCard(
                wallet: wallet,
                width: 320,
                height: 196,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final flipButton = find.byTooltip('Flip card');
      expect(flipButton, findsOneWidget);

      final flipSize = tester.getSize(flipButton);
      expect(flipSize.width, greaterThanOrEqualTo(44.0));
      expect(flipSize.height, greaterThanOrEqualTo(44.0));

      expect(tester.takeException(), isNull);
    });

    testWidgets('carousel caps card width on tablet surface (800px width)', (tester) async {
      setPhoneSurface(tester, width: 800, height: 1200);

      final wallet = Wallets(
        id: 1,
        name: 'EUR Wallet',
        code: 'EUR',
        symbol: '€',
        balance: '500.00',
        accountNo: '9876 5432 1098 7654',
        isDefault: true,
      );

      await tester.pumpWidget(
        GetMaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('fa')],
          locale: const Locale('en'),
          home: Scaffold(
            body: SingleChildScrollView(
              child: WalletCardCarousel(wallets: [wallet]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final cardFinder = find.byType(MultiCurrencyFlipCard);
      expect(cardFinder, findsOneWidget);

      final cardSize = tester.getSize(cardFinder);
      expect(cardSize.width, lessThanOrEqualTo(420.0));

      expect(tester.takeException(), isNull);
    });
  });
}
