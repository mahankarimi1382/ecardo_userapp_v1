import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/config/theme/dark_theme.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/welcome/view/welcome_screen.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/model/dashboard_model.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/home_screen.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/action_button_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/business_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/home_skeleton_loader.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/my_wallet_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/other_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/recent_transactions_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/referral_stats_section.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/section_header.dart';
import 'package:ecardo_user/src/presentation/screens/home/view/sub_sections/travel_services_section.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/controller/wallets_controller.dart';
import 'package:ecardo_user/src/presentation/screens/wallets/view/wallets_screen.dart';

class _MockWalletsController extends WalletsController {
  @override
  // ignore: must_call_super
  void onInit() {
    // Avoid triggering real HTTP calls in tests
  }
}

class _MockHomeController extends HomeController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _MockKycController extends KycLevelController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

Widget _wrapWithApp(
  Widget child, {
  ThemeMode mode = ThemeMode.light,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => GetMaterialApp(
      themeMode: mode,
      theme: LightTheme().lightTheme(context),
      darkTheme: DarkTheme().darkTheme(context),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void setPhoneSurface(WidgetTester tester, {double width = 390, double height = 844}) {
  tester.view.physicalSize = Size(width * 2, height * 2);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.reset();
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    final settings = Get.put<SettingsService>(SettingsService());
    settings.appSettings['user_transfer'] = '1';
    settings.appSettings['user_exchange'] = '1';
    settings.appSettings['user_deposit'] = '1';
    settings.appSettings['user_withdraw'] = '1';
    Get.put<KycLevelController>(_MockKycController());
  });

  tearDown(() {
    Get.reset();
  });

  group('WalletsScreen Modernization', () {
    testWidgets('Renders Shimmer loading state when isLoading is true',
        (tester) async {
      final controller = Get.put<WalletsController>(_MockWalletsController());
      controller.isLoading.value = true;

      await tester.pumpWidget(_wrapWithApp(const WalletsScreen()));
      await tester.pump();

      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('Renders robust Error state with retry button when isError is true',
        (tester) async {
      final controller = Get.put<WalletsController>(_MockWalletsController());
      controller.isLoading.value = false;
      controller.isError.value = true;

      await tester.pumpWidget(_wrapWithApp(const WalletsScreen()));
      await tester.pump();

      expect(find.byType(EcardoErrorView), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets(
        'Renders clean Empty state with Create Wallet and Add Money when list is empty',
        (tester) async {
      final controller = Get.put<WalletsController>(_MockWalletsController());
      controller.isLoading.value = false;
      controller.isError.value = false;
      controller.walletsList.clear();

      await tester.pumpWidget(_wrapWithApp(const WalletsScreen()));
      await tester.pump();

      expect(find.byType(EcardoEmptyState), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });

    testWidgets('Renders dark theme flawlessly for WalletsScreen',
        (tester) async {
      final controller = Get.put<WalletsController>(_MockWalletsController());
      controller.isLoading.value = false;
      controller.isError.value = false;
      controller.walletsList.clear();

      await tester.pumpWidget(
        _wrapWithApp(const WalletsScreen(), mode: ThemeMode.dark),
      );
      await tester.pump();

      expect(find.byType(WalletsScreen), findsOneWidget);
      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
    });
  });

  group('WelcomeScreen Modernization', () {
    testWidgets('Renders correctly in light mode with accessible buttons',
        (tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(_wrapWithApp(const WelcomeScreen()));
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('Renders correctly in dark mode without text/contrast clipping',
        (tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(
        _wrapWithApp(const WelcomeScreen(), mode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();

      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });

  group('HomeScreen & HomeSkeletonLoader Modernization', () {
    testWidgets('HomeSkeletonLoader renders in light and dark mode',
        (tester) async {
      setPhoneSurface(tester);
      await tester.pumpWidget(
        _wrapWithApp(const HomeSkeletonLoader(), mode: ThemeMode.light),
      );
      await tester.pump();
      expect(find.byType(Shimmer), findsOneWidget);

      await tester.pumpWidget(
        _wrapWithApp(const HomeSkeletonLoader(), mode: ThemeMode.dark),
      );
      await tester.pump();
      expect(find.byType(Shimmer), findsOneWidget);
    });

    testWidgets('HomeScreen applies dynamic SystemUiOverlayStyle during skeleton load',
        (tester) async {
      setPhoneSurface(tester);
      final home = Get.put<HomeController>(_MockHomeController());
      home.isLoading.value = true;

      await tester.pumpWidget(
        _wrapWithApp(const HomeScreen(), mode: ThemeMode.dark),
      );
      await tester.pump();

      expect(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        findsWidgets,
      );
      expect(find.byType(HomeSkeletonLoader), findsOneWidget);
    });

    testWidgets('HomeScreen applies dynamic SystemUiOverlayStyle on error state in dark mode',
        (tester) async {
      setPhoneSurface(tester);
      final home = Get.put<HomeController>(_MockHomeController());
      home.isLoading.value = false;
      home.loadError.value = 'Failed to load home data';

      await tester.pumpWidget(
        _wrapWithApp(const HomeScreen(), mode: ThemeMode.dark),
      );
      await tester.pump();

      expect(
        find.byType(AnnotatedRegion<SystemUiOverlayStyle>),
        findsWidgets,
      );
      expect(find.text('Failed to load home data'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
    });

    testWidgets('HomeScreen slivers render seamlessly in dark mode',
        (tester) async {
      setPhoneSurface(tester);
      final home = Get.put<HomeController>(_MockHomeController());
      home.dashboardModel.value = DashboardModel.fromJson({
        'status': 'success',
        'data': {
          'referral': {'bonus': '10.0', 'count': 2},
          'info': {'unread_notifications_count': 0, 'time_wise_wish': 'Day'},
          'wallets': [],
        },
      });
      home.userModel.value = UserModel.fromJson({
        'status': 'success',
        'data': {
          'kyc_level': 1,
          'passcode': '0',
          'addons': {'travel': true},
        },
      });

      await tester.pumpWidget(
        _wrapWithApp(
          const Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ActionButtonSection(),
                  SectionHeader(sectionName: 'Test Section'),
                  ReferralStatsSection(),
                  MyWalletSection(),
                  OtherServicesSection(),
                  TravelServicesSection(),
                  BusinessServicesSection(),
                  RecentTransactionsSection(),
                ],
              ),
            ),
          ),
          mode: ThemeMode.dark,
        ),
      );
      await tester.pump();

      expect(find.byType(ActionButtonSection), findsOneWidget);
      expect(find.byType(ReferralStatsSection), findsOneWidget);
      expect(find.byType(OtherServicesSection), findsOneWidget);
      expect(find.byType(TravelServicesSection), findsOneWidget);
      expect(find.byType(BusinessServicesSection), findsOneWidget);
      expect(find.byType(RecentTransactionsSection), findsOneWidget);
    });
  });
}
