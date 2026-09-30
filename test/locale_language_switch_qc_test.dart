import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/locale_theme_service.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// v1.0.122 field regression (error_log #62/#63): switching language while
/// every live route was mounted rebuilt the whole tree and hit a Get.find on
/// a dead controller — the release build froze until the process was killed,
/// and the language only "applied" after a restart (it was persisted first).
///
/// The v1.0.123 fix persisted first and re-rooted, but applied locale before
/// GetX had finished disposing the outgoing route. v1.0.124 waits for that
/// transition before applying locale. These tests lock the ordering in.
///
/// The route table here is a minimal stand-in: the service only needs the
/// NAME BaseRoute.root to exist. The real SplashBinding (network, plugins,
/// FCM, biometrics) must never run inside a unit test.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.put<SettingsService>(SettingsService());
  });

  tearDown(Get.reset);

  Future<LocaleThemeService> pumpLanguageApp(WidgetTester tester) async {
    final service = Get.put<LocaleThemeService>(
      LocaleThemeService(),
      permanent: true,
    );
    await tester.pumpWidget(
      GetMaterialApp(
        getPages: [
          GetPage(name: BaseRoute.root, page: () => const SizedBox.shrink()),
          GetPage(
            name: '/test-start',
            page: () => const SizedBox.shrink(),
          ),
        ],
        initialRoute: '/test-start',
      ),
    );
    await tester.pump();
    return service;
  }

  /// Drive the route replacement animation before awaiting the service. The
  /// service intentionally waits for the outgoing route to be disposed before
  /// changing locale, so pumping the fake clock is part of this regression.
  Future<void> switchLanguage(
    WidgetTester tester,
    LocaleThemeService service,
    String code,
  ) async {
    final previousLocale = service.locale.value;
    final pending = service.setLanguage(code);
    await tester.pump();
    expect(
      service.locale.value,
      previousLocale,
      reason: 'locale must not rebuild the app during outgoing-route disposal',
    );
    // The shared-preferences future can resume after the first frame and
    // schedule endOfFrame itself; advance a frame before the route-settle timer.
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 400));
    await pending;
    await tester.pumpAndSettle();
  }

  testWidgets(
    'setLanguage applies the locale, rebuilds the stack at root and persists the choice',
    (tester) async {
      final service = await pumpLanguageApp(tester);
      expect(Get.currentRoute, '/test-start');

      // The exact field trigger: /get-languages carries mixed-case codes
      // (e.g. "Fa") — normalization must not silently drop the switch.
      await switchLanguage(tester, service, 'Fa');

      expect(service.locale.value, const Locale('fa'));
      expect(
        Get.currentRoute,
        BaseRoute.root,
        reason:
            'previous routes must be out of the tree before the locale '
            'rebuild fires — this is the freeze/crash fix itself',
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
    expect(Get.currentRoute, '/test-start');
    expect(await SettingsService.getLanguageLocaleCurrentState(), isNull);
  });

  testWidgets(
    'en→fa and fa→en round-trips re-root and persist each time',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      await switchLanguage(tester, service, 'fa');
      expect(service.locale.value, const Locale('fa'));
      expect(Get.currentRoute, BaseRoute.root);
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');

      await switchLanguage(tester, service, 'en');
      expect(service.locale.value, const Locale('en'));
      expect(Get.currentRoute, BaseRoute.root);
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'en');
    },
  );

  testWidgets(
    'rapid consecutive switches stay consistent and never leave the stack broken',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      // Scenario: the user changes language repeatedly. Each selection must
      // finish disposing the previous route before the next locale rebuild.
      await switchLanguage(tester, service, 'zh');
      await switchLanguage(tester, service, 'ar');
      await switchLanguage(tester, service, 'fa');

      expect(service.locale.value, const Locale('fa'));
      expect(Get.currentRoute, BaseRoute.root);
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');
    },
  );
}
