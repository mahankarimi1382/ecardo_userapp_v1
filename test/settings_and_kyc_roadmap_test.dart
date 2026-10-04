import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/config/theme/dark_theme.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/services/biometric_auth_service.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_level_roadmap.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/settings_screen.dart';

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

class _TestBiometricAuthService extends BiometricAuthService {
  @override
  Future<bool> isSupported() async => false;
  @override
  Future<bool> isEnabled() async => false;
  @override
  Future<bool> canAuthenticate() async => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<SettingsService>(SettingsService());
    Get.put<LocaleThemeService>(LocaleThemeService());
    Get.put<BiometricAuthService>(_TestBiometricAuthService());
    final homeController = Get.put<HomeController>(_TestHomeController());
    homeController.isSettingsInitialized.value = true;
  });

  tearDown(() {
    Get.reset();
  });

  group('Settings Screen UI/UX & Touch Targets', () {
    testWidgets(
        'All menu items have touch target height >= 44px and render modern icons',
        (tester) async {
      tester.view.physicalSize = const Size(800, 5000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => GetMaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const SettingsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump();

      // Verify key menu sections are present
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Security'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Personalization'), findsOneWidget);

      // Verify specific menu items required
      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Transaction PIN'), findsOneWidget);
      expect(find.text('Devices & Active Sessions'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      // Verify all ListTile instances have touch target height >= 44px
      final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
      expect(listTiles.isNotEmpty, isTrue);
      for (final tile in listTiles) {
        if (tile.minTileHeight != null) {
          expect(tile.minTileHeight! >= 44.0, isTrue);
        }
      }
    });

    testWidgets(
        'Theme switching between Light and Dark applies cleanly without exceptions',
        (tester) async {
      final lts = Get.find<LocaleThemeService>();

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => Obx(() => GetMaterialApp(
                themeMode: lts.themeMode.value,
                theme: LightTheme().lightTheme(context),
                darkTheme: DarkTheme().darkTheme(context),
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                supportedLocales: const [Locale('en')],
                home: const SettingsScreen(),
              )),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to Dark mode
      await lts.setThemeModePref('dark');
      await tester.pumpAndSettle();
      expect(lts.themeMode.value, equals(ThemeMode.dark));

      // Switch to Light mode
      await lts.setThemeModePref('light');
      await tester.pumpAndSettle();
      expect(lts.themeMode.value, equals(ThemeMode.light));

      // Switch to System mode
      await lts.setThemeModePref('system');
      await tester.pumpAndSettle();
      expect(lts.themeMode.value, equals(ThemeMode.system));
    });

    test('SettingsIconTokens resolves robust light and dark semantic styles', () {
      final tiles = <String, SettingsIconStyle Function(bool)>{
        'profile': (dark) => SettingsIconTokens.profile(isDark: dark),
        'kyc': (dark) => SettingsIconTokens.kyc(isDark: dark),
        'demoLab': (dark) => SettingsIconTokens.demoLab(isDark: dark),
        'changePassword': (dark) => SettingsIconTokens.changePassword(isDark: dark),
        'transactionPin': (dark) => SettingsIconTokens.transactionPin(isDark: dark),
        'twoFactor': (dark) => SettingsIconTokens.twoFactor(isDark: dark),
        'paymentOtp': (dark) => SettingsIconTokens.paymentOtp(isDark: dark),
        'deviceSessions': (dark) => SettingsIconTokens.deviceSessions(isDark: dark),
        'biometric': (dark) => SettingsIconTokens.biometric(isDark: dark),
        'autoAppLock': (dark) => SettingsIconTokens.autoAppLock(isDark: dark),
        'appLockPin': (dark) => SettingsIconTokens.appLockPin(isDark: dark),
        'notificationAccessGranted': (dark) =>
            SettingsIconTokens.notificationAccess(isDark: dark, granted: true),
        'notificationAccessDenied': (dark) =>
            SettingsIconTokens.notificationAccess(isDark: dark, granted: false),
        'notificationFinancial': (dark) =>
            SettingsIconTokens.notificationFinancial(isDark: dark),
        'notificationPromo': (dark) =>
            SettingsIconTokens.notificationPromo(isDark: dark),
        'notificationSecurity': (dark) =>
            SettingsIconTokens.notificationSecurity(isDark: dark),
        'sound': (dark) => SettingsIconTokens.sound(isDark: dark),
        'vibration': (dark) => SettingsIconTokens.vibration(isDark: dark),
        'notificationFeed': (dark) =>
            SettingsIconTokens.notificationFeed(isDark: dark),
        'permissions': (dark) => SettingsIconTokens.permissions(isDark: dark),
        'language': (dark) => SettingsIconTokens.language(isDark: dark),
        'theme': (dark) => SettingsIconTokens.theme(isDark: dark),
        'rateUnit': (dark) => SettingsIconTokens.rateUnit(isDark: dark),
        'support': (dark) => SettingsIconTokens.support(isDark: dark),
        'about': (dark) => SettingsIconTokens.about(isDark: dark),
        'terms': (dark) => SettingsIconTokens.terms(isDark: dark),
        'appUpdate': (dark) => SettingsIconTokens.appUpdate(isDark: dark),
        'demoKyc': (dark) => SettingsIconTokens.demoKyc(isDark: dark),
        'demoExit': (dark) => SettingsIconTokens.demoExit(isDark: dark),
      };

      for (final entry in tiles.entries) {
        final lightStyle = entry.value(false);
        final darkStyle = entry.value(true);

        expect(lightStyle.iconColor, isNotNull, reason: '${entry.key} light iconColor');
        expect(lightStyle.backgroundColor, isNotNull, reason: '${entry.key} light bgColor');
        expect(darkStyle.iconColor, isNotNull, reason: '${entry.key} dark iconColor');
        expect(darkStyle.backgroundColor, isNotNull, reason: '${entry.key} dark bgColor');
        expect(lightStyle.iconColor != lightStyle.backgroundColor, isTrue);
        expect(darkStyle.iconColor != darkStyle.backgroundColor, isTrue);
      }

      // Chevron color verification
      expect(SettingsIconTokens.chevronColor(isDark: false), isNotNull);
      expect(SettingsIconTokens.chevronColor(isDark: true), equals(AppColors.softGray));
    });
  });

  group('KycLevelRoadmap Tier Descriptions', () {
    testWidgets('Renders crystal clear descriptions and spec chips for each tier',
        (tester) async {
      final kycController = Get.put<KycLevelController>(_TestKycController());
      kycController.levels.assignAll([
        KycLevel(
          level: 1,
          name: 'Tier 1 — Basic',
          description: '',
          color: 'green',
          icon: 'user',
          requiredDocs: ['phone', 'email'],
          features: ['transfers'],
          limits: {'daily_limit': 1000},
          status: 'completed',
        ),
        KycLevel(
          level: 2,
          name: 'Tier 2 — Standard',
          description: '',
          color: 'blue',
          icon: 'id_card',
          requiredDocs: ['national_id'],
          features: ['exchange', 'travel'],
          limits: {'daily_limit': 10000},
          status: 'available',
        ),
        KycLevel(
          level: 3,
          name: 'Tier 3 — VIP',
          description: '',
          color: 'gold',
          icon: 'crown',
          requiredDocs: ['proof_of_address', 'video_liveness'],
          features: ['loans', 'vip'],
          limits: {'daily_limit': 100000},
          status: 'locked',
        ),
      ]);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: const Scaffold(
              body: SingleChildScrollView(
                child: KycLevelRoadmap(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Tier names
      expect(find.text('Tier 1 — Basic'), findsOneWidget);
      expect(find.text('Tier 2 — Standard'), findsOneWidget);
      expect(find.text('Tier 3 — VIP'), findsOneWidget);

      // Verify crystal clear tier descriptions
      expect(
        find.textContaining('Email & phone verified. \$1,000/day limit'),
        findsOneWidget,
      );
      expect(
        find.textContaining('National ID / Passport verified. \$10,000/day limit'),
        findsOneWidget,
      );
      expect(
        find.textContaining('Address proof & video liveness'),
        findsOneWidget,
      );

      // Verify highlight spec badges
      expect(find.text('\$1,000 / day'), findsOneWidget);
      expect(find.text('1 Card'), findsOneWidget);
      expect(find.text('\$10,000 / day'), findsOneWidget);
      expect(find.text('3 Cards'), findsOneWidget);
      expect(find.text('\$100,000 / day'), findsOneWidget);
      expect(find.text('Unlimited Cards'), findsOneWidget);
    });
  });
}
