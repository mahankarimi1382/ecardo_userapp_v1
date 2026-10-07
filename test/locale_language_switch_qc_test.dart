import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// Language switch regression (v1.0.125).
///
/// History of this crash, all release-only:
/// * v1.0.121/122 applied the locale IN PLACE. The full-tree rebuild while
///   every live route/controller was mounted hit a Get.find for a controller
///   whose route was mid-teardown — "controller not found" (error_log #62/#63).
/// * v1.0.123 cleared the stack FIRST (crash fixed) but went to the splash
///   route, so the splash logo replayed on every switch.
/// * v1.0.124 went back to in-place to stop the splash replay — the crash
///   came back with it.
///
/// The v1.0.125 contract (LocaleThemeService.setLanguage):
///   1. clear the stack to the dependency-free `/locale_transition_route`
///      waypoint (splash must NEVER be built),
///   2. apply the locale while only that lightweight screen is mounted,
///   3. restore the user's original route (with its arguments) under the
///      new locale.
/// So a switch DOES navigate — through the waypoint — but the user always
/// ends on the route they started from, and the splash never replays.
///
/// The route table is a minimal stand-in: the real SplashBinding (network,
/// plugins, FCM, biometrics) must never run inside a unit test. A `/` route is
/// registered anyway so that a regression that navigates there is detected.
class _ProbeController extends GetxController {
  final RxInt counter = 0.obs;
  void increment() => counter.value++;
}

class _Probe extends StatefulWidget {
  const _Probe({super.key, required this.name});

  final String name;
  static final List<String> built = [];

  @override
  State<_Probe> createState() => _ProbeState();
}

class _ProbeState extends State<_Probe> {
  late final _ProbeController controller;

  @override
  void initState() {
    super.initState();
    _Probe.built.add(widget.name);
    controller = Get.isRegistered<_ProbeController>()
        ? Get.find<_ProbeController>()
        : Get.put(_ProbeController());
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => Text('${widget.name}: ${controller.counter.value}'));
  }
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
            Locale('tr'),
            Locale('ru'),
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
              name: BaseRoute.localeTransition,
              page: () => const _Probe(name: 'localeTransition'),
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

  /// Drives the fake clock through the waypoint sequence: offAllNamed +
  /// first endOfFrame → 400 ms waypoint delay → apply → restore route.
  Future<void> switchLanguage(
    WidgetTester tester,
    LocaleThemeService service,
    String code,
  ) async {
    final switching = service.setLanguage(code);
    await tester.pump(); // offAllNamed → waypoint, first endOfFrame settles
    await tester
        .pump(const Duration(milliseconds: 450)); // fire the 400 ms delay
    await tester.pumpAndSettle(); // apply + restore navigation settles
    await switching;
    await tester.pumpAndSettle();
  }

  void expectRestoredActiveRoute() {
    expect(
      Get.currentRoute,
      startRoute,
      reason: 'the language switch must return the user to the route they '
          'started from (via the locale-transition waypoint)',
    );
    expect(
      _Probe.built.contains('splash'),
      isFalse,
      reason: 'the SplashScreen must never be built by a language switch',
    );
  }

  testWidgets(
    'setLanguage applies locale + RTL via the waypoint, restores the route, persists',
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
      expectRestoredActiveRoute();
      expect(
        _Probe.built,
        containsAllInOrder(['start', 'localeTransition', 'start']),
        reason: 'the switch must clear the stack to the waypoint and then '
            'recreate the active screen under the new locale',
      );
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
    expectRestoredActiveRoute();
    expect(_Probe.built, ['start'],
        reason: 'an unsupported code must not navigate at all');
    expect(await SettingsService.getLanguageLocaleCurrentState(), isNull);
  });

  testWidgets(
    'setLanguage is a no-op when the requested locale is already active',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      await switchLanguage(tester, service, 'en');

      expect(_Probe.built, ['start'],
          reason: 're-selecting the active language must not rebuild anything');
      expectRestoredActiveRoute();
    },
  );

  testWidgets(
    'en→fa→en round-trip flips direction each time and always comes back',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      await switchLanguage(tester, service, 'fa');
      expect(service.locale.value, const Locale('fa'));
      expect(currentDirection(), TextDirection.rtl);
      expectRestoredActiveRoute();
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');

      await switchLanguage(tester, service, 'en');
      expect(service.locale.value, const Locale('en'));
      expect(Get.locale, const Locale('en'));
      expect(currentDirection(), TextDirection.ltr);
      expectRestoredActiveRoute();
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
      expectRestoredActiveRoute();
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');
    },
  );
}
