import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/app/routes/routes.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// Reactive locale + theme so settings changes apply without app restart.
class LocaleThemeService extends GetxService {
  static const supported = ['fa', 'en', 'ar', 'zh', 'tr', 'ru'];

  final Rx<Locale> locale = const Locale('en').obs;
  final Rx<ThemeMode> themeMode = ThemeMode.system.obs;

  Future<LocaleThemeService> init() async {
    final saved = await SettingsService.getLanguageLocaleCurrentState();
    final savedNormalized = saved?.trim().toLowerCase();
    if (savedNormalized != null && supported.contains(savedNormalized)) {
      locale.value = Locale(savedNormalized);
    } else {
      final device = Get.deviceLocale?.languageCode ??
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      final code = supported.contains(device) ? device : 'en';
      locale.value = Locale(code);
    }
    Get.updateLocale(locale.value);

    if (Get.isRegistered<SettingsService>()) {
      final mode = await Get.find<SettingsService>().getThemeModePref();
      themeMode.value = _parseTheme(mode);
    }
    // DARK-FIX: most screens have no AnnotatedRegion, so they inherit the
    // last global SystemChrome style. Keep that global style in sync with
    // the effective brightness (mode + OS setting) whenever it changes.
    ever(themeMode, (_) => _syncSystemChrome());
    _syncSystemChrome();
    return this;
  }

  /// Resolves ThemeMode.system against the OS setting and pushes the
  /// matching status-bar / nav-bar icon brightness globally.
  void _syncSystemChrome() {
    final platformDark = WidgetsBinding
            .instance.platformDispatcher.platformBrightness ==
        Brightness.dark;
    final effectiveDark = switch (themeMode.value) {
      ThemeMode.dark => true,
      ThemeMode.light => false,
      ThemeMode.system => platformDark,
    };
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness:
            effectiveDark ? Brightness.light : Brightness.dark,
        statusBarBrightness:
            effectiveDark ? Brightness.dark : Brightness.light,
        systemNavigationBarIconBrightness:
            effectiveDark ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Future<void> setLanguage(String code) async {
    // wallet-modules v1.0.122: the server's /get-languages list carries
    // mixed-case codes (e.g. "Fa" for Persian) — normalize before matching,
    // otherwise the switch silently does nothing.
    final normalized = code.trim().toLowerCase();
    if (!supported.contains(normalized)) return;

    final nextLocale = Locale(normalized);
    // Compare language codes: Get.locale can carry a region ("en_US").
    if (locale.value.languageCode == normalized &&
        (Get.locale?.languageCode ?? '') == normalized) {
      return;
    }

    // 1. Persist first so the choice survives an app restart.
    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().saveLanguageLocaleCurrentState(
        normalized,
      );
    }

    // RELEASE-CRASH FIX (v1.0.125) — why this sequence:
    //
    // * v1.0.121/122 applied the locale in place (`Get.locale =` /
    //   `locale.value =` while every route was mounted). The full-tree
    //   rebuild in one frame — worse with the LTR↔RTL flip for fa/ar —
    //   hit a Get.find for a controller whose route was mid-teardown:
    //   the release-only "controller not found" crash (error_log #62/#63).
    // * v1.0.123 fixed the crash by re-rooting FIRST (offAllNamed +
    //   endOfFrame + 400ms) but went to the SplashScreen, which replayed
    //   the splash on every switch.
    // * v1.0.124 removed the re-root to stop the splash replay and went
    //   back to in-place — the crash came back with it.
    //
    // This sequence keeps the crash fix AND the UX fix: clear the stack to
    // a dependency-free waypoint (NO splash, no controllers, no bindings),
    // apply the locale while only that lightweight screen is mounted, then
    // return the user to the route they came from (with its arguments),
    // rebuilt under the new locale via that route's own binding.
    final route = Get.currentRoute;
    final args = Get.arguments;
    final params = Map<String, String>.from(Get.parameters);

    Get.offAllNamed(BaseRoute.localeTransition);
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // Only the waypoint is mounted now — applying here is safe.
    Get.locale = nextLocale;
    locale.value = nextLocale;
    await WidgetsBinding.instance.endOfFrame;

    // Back to where the user was. Splash (`/`) is intentionally NOT part of
    // the path, so it never replays.
    final rawTarget =
        route == BaseRoute.localeTransition ? BaseRoute.root : route;
    final target =
        rawTarget.contains('?') ? rawTarget.split('?').first : rawTarget;
    if (target == BaseRoute.root) {
      Get.offAllNamed(BaseRoute.root);
    } else if (params.isNotEmpty) {
      Get.offAllNamed(target, arguments: args, parameters: params);
    } else {
      Get.offAllNamed(target, arguments: args);
    }
    await WidgetsBinding.instance.endOfFrame;
  }

  Future<void> setThemeModePref(String mode) async {
    final parsed = _parseTheme(mode);
    themeMode.value = parsed;
    Get.changeThemeMode(parsed);
    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().setThemeModePref(mode);
    }
  }

  ThemeMode _parseTheme(String mode) => switch (mode) {
        'dark' => ThemeMode.dark,
        'light' => ThemeMode.light,
        _ => ThemeMode.system,
      };

  static String nativeName(String code) => switch (code) {
        'fa' => 'فارسی',
        'ar' => 'العربية',
        'zh' => '中文',
        'tr' => 'Türkçe',
        'ru' => 'Русский',
        _ => 'English',
      };
}
