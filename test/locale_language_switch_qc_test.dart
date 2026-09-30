import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// Language switch regression (v1.0.124).
///
/// Earlier versions ran `Get.offAllNamed(BaseRoute.root)` plus
/// `Get.updateLocale` when the language changed. `/` is the SplashScreen and
/// `Get.updateLocale` force-restarts the app/Navigator, so the logo and
/// loading indicator replayed on every switch. The switch must now be applied
/// IN PLACE: the locale and text direction change, the active route does not.
///
/// The route table is a minimal stand-in: the real SplashBinding (network,
/// plugins, FCM, biometrics) must never run inside a unit test. A `/` route is
/// registered anyway so that a regression that navigates there is detected.
class _Probe extends StatefulWidget {
  const _Probe({required this.name});

  final String name;
  static final List<String> built = [];

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  @override
  void initState() {
    super.initState();
    _Probe.built.add(widget.name);
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const startRoute = '/test-start';
  final startKey = GlobalKey();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.put<SettingsService>(SettingsService());
    _Probe.built.clear();
  });

  tearDown(() {
    Get.locale = null;
    Get.reset();
  });

  Future<LocaleThemeService> pumpLanguageApp(WidgetTester tester) async {
    final service = Get.put<LocaleThemeService>(
      LocaleThemeService(),
      permanent: true,
    );
    // Mirrors lib/src/app/app.dart: a reactive GetMaterialApp driven by
    // LocaleThemeService.locale.
    await tester.pumpWidget(
      Obx(
        () => GetMaterialApp(
          locale: service.locale.value,
          fallbackLocale: const Locale('en'),
          supportedLocales: const [
            Locale('en'),
            Locale('ar'),
            Locale('fa'),
            Locale('zh'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          getPages: [
            GetPage(
              name: BaseRoute.root,
              page: () => const _Probe(name: 'splash'),
            ),
            GetPage(
              name: startRoute,
              page: () => _Probe(key: startKey, name: 'start'),
            ),
          ],
          initialRoute: startRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(Get.currentRoute, startRoute);
    expect(_Probe.built, ['start']);
    return service;
  }

  TextDirection currentDirection() =>
      Directionality.of(startKey.currentContext!);

  Locale currentWidgetLocale() =>
      Localizations.localeOf(startKey.currentContext!);

  Future<void> switchLanguage(
    WidgetTester tester,
    LocaleThemeService service,
    String code,
  ) async {
    await service.setLanguage(code);
    await tester.pumpAndSettle();
  }

  void expectStayedOnActiveRoute() {
    expect(
      Get.currentRoute,
      startRoute,
      reason: 'a language switch must not navigate (no re-root to splash)',
    );
    expect(
      _Probe.built,
      ['start'],
      reason: 'splash must not be built and the active screen must not be '
          'recreated by a language switch',
    );
  }

  testWidgets(
    'setLanguage applies locale + RTL in place, persists, and keeps the route',
    (tester) async {
      final service = await pumpLanguageApp(tester);
      expect(currentWidgetLocale(), const Locale('en'));
      expect(currentDirection(), TextDirection.ltr);

      // The field trigger: /get-languages carries mixed-case codes ("Fa").
      await switchLanguage(tester, service, 'Fa');

      expect(service.locale.value, const Locale('fa'));
      expect(Get.locale, const Locale('fa'));
      expect(currentWidgetLocale(), const Locale('fa'));
      expect(currentDirection(), TextDirection.rtl);
      expectStayedOnActiveRoute();
      expect(
        await SettingsService.getLanguageLocaleCurrentState(),
        'fa',
        reason: 'the choice must survive the app restart',
      );
      expect(Get.find<SettingsService>().currentLanguageLocale.value, 'fa');
    },
  );

  testWidgets('setLanguage is a no-op for unsupported codes', (tester) async {
    final service = await pumpLanguageApp(tester);

    await switchLanguage(tester, service, 'de');

    expect(service.locale.value, const Locale('en'));
    expect(currentDirection(), TextDirection.ltr);
    expectStayedOnActiveRoute();
    expect(await SettingsService.getLanguageLocaleCurrentState(), isNull);
  });

  testWidgets(
    'en→fa→en round-trip flips direction each time without navigating',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      await switchLanguage(tester, service, 'fa');
      expect(service.locale.value, const Locale('fa'));
      expect(currentDirection(), TextDirection.rtl);
      expectStayedOnActiveRoute();
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');

      await switchLanguage(tester, service, 'en');
      expect(service.locale.value, const Locale('en'));
      expect(Get.locale, const Locale('en'));
      expect(currentDirection(), TextDirection.ltr);
      expectStayedOnActiveRoute();
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'en');
    },
  );

  testWidgets(
    'consecutive switches across LTR/RTL languages stay consistent',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      await switchLanguage(tester, service, 'zh');
      expect(currentDirection(), TextDirection.ltr);
      await switchLanguage(tester, service, 'ar');
      expect(currentDirection(), TextDirection.rtl);
      await switchLanguage(tester, service, 'fa');

      expect(service.locale.value, const Locale('fa'));
      expect(Get.locale, const Locale('fa'));
      expect(currentWidgetLocale(), const Locale('fa'));
      expect(currentDirection(), TextDirection.rtl);
      expectStayedOnActiveRoute();
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');
    },
  );
}
