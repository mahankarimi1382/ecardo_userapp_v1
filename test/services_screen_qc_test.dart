import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/config/theme/dark_theme.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/services/view/services_screen.dart';

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

Widget _wrapWithServicesScreen({
  Locale locale = const Locale('en'),
  ThemeMode mode = ThemeMode.light,
}) {
  return ScreenUtilInit(
    designSize: const Size(390, 844),
    minTextAdapt: true,
    builder: (context, _) => GetMaterialApp(
      themeMode: mode,
      theme: LightTheme().lightTheme(context),
      darkTheme: DarkTheme().darkTheme(context),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: const ServicesScreen(),
    ),
  );
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

  testWidgets('Services Hub settles in Light mode LTR with animations and hero banner', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrapWithServicesScreen());
    await tester.pumpAndSettle();

    // Verify Title and Subtitle
    expect(find.text('Services Hub'), findsOneWidget);
    expect(find.text('Fintech & Travel Suite'), findsOneWidget);

    // Verify Quick Access Hero Banner
    expect(find.text('Quick Access'), findsOneWidget);
    expect(find.text('Top financial & travel actions'), findsOneWidget);

    // Verify Category Filter Chips
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Financial'), findsOneWidget);
  });

  testWidgets('Services Hub settles in Dark mode Persian RTL without errors', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrapWithServicesScreen(
      locale: const Locale('fa'),
      mode: ThemeMode.dark,
    ));
    await tester.pumpAndSettle();

    // Verify Persian Header
    expect(find.text('مرکز خدمات'), findsOneWidget);
    expect(find.text('دسترسی سریع و یکپارچه'), findsOneWidget);

    // Verify Quick Access Persian Banner
    expect(find.text('دسترسی سریع و پرتکرار'), findsOneWidget);
    expect(find.text('عملیات برگزیده مالی و مسافرتی'), findsOneWidget);
  });

  testWidgets('Services Hub category filtering transitions smoothly', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrapWithServicesScreen());
    await tester.pumpAndSettle();

    // Tap Financial chip
    await tester.tap(find.text('Financial'));
    await tester.pumpAndSettle();

    // Quick Access hero is hidden in single category view
    expect(find.text('Quick Access'), findsNothing);

    // Tap All chip to restore full view
    await tester.tap(find.text('All'));
    await tester.pumpAndSettle();

    expect(find.text('Quick Access'), findsOneWidget);
  });

  testWidgets('Services Hub search filtering responds to input and clear', (tester) async {
    tester.view.physicalSize = const Size(390 * 2, 844 * 2);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrapWithServicesScreen());
    await tester.pumpAndSettle();

    // Search for "flight"
    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'flight');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Clear search button appears
    final clearButton = find.byIcon(Icons.cancel_rounded);
    expect(clearButton, findsOneWidget);

    await tester.tap(clearButton);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(find.text('Quick Access'), findsOneWidget);
  });
}
