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
/// The fix (wallet-modules v1.0.123 in LocaleThemeService.setLanguage):
/// persist FIRST, then Get.offAllNamed(BaseRoute.root) so only the splash is
/// mounted, THEN apply the locale. These tests lock that behavior in.
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

  testWidgets(
    'setLanguage applies the locale, rebuilds the stack at root and persists the choice',
    (tester) async {
      final service = await pumpLanguageApp(tester);
      expect(Get.currentRoute, '/test-start');

      // The exact field trigger: /get-languages carries mixed-case codes
      // (e.g. "Fa") — normalization must not silently drop the switch.
      await service.setLanguage('Fa');
      await tester.pumpAndSettle();

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

    await service.setLanguage('de');
    await tester.pumpAndSettle();

    expect(service.locale.value, const Locale('en'));
    expect(Get.currentRoute, '/test-start');
    expect(await SettingsService.getLanguageLocaleCurrentState(), isNull);
  });

  testWidgets(
    'en→fa and fa→en round-trips re-root and persist each time',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      await service.setLanguage('fa');
      await tester.pumpAndSettle();
      expect(service.locale.value, const Locale('fa'));
      expect(Get.currentRoute, BaseRoute.root);
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');

      await service.setLanguage('en');
      await tester.pumpAndSettle();
      expect(service.locale.value, const Locale('en'));
      expect(Get.currentRoute, BaseRoute.root);
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'en');
    },
  );

  testWidgets(
    'rapid consecutive switches stay consistent and never leave the stack broken',
    (tester) async {
      final service = await pumpLanguageApp(tester);

      // Scenario: user hammers the language list — every switch re-roots and
      // the last one wins everywhere (storage + locale + route). Each tap in
      // the real app is separated by at least one frame, so pump once between
      // switches; calling updateLocale twice within a single frame phase is
      // a scheduler-assertion artifact of the test binding, not a real path.
      await service.setLanguage('zh');
      await tester.pump();
      await service.setLanguage('ar');
      await tester.pump();
      await service.setLanguage('fa');
      await tester.pumpAndSettle();

      expect(service.locale.value, const Locale('fa'));
      expect(Get.currentRoute, BaseRoute.root);
      expect(await SettingsService.getLanguageLocaleCurrentState(), 'fa');
    },
  );
}
