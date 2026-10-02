import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
    return this;
  }

  Future<void> setLanguage(String code) async {
    // wallet-modules v1.0.122: the server's /get-languages list carries
    // mixed-case codes (e.g. "Fa" for Persian) — normalize before matching,
    // otherwise the switch silently does nothing.
    final normalized = code.trim().toLowerCase();
    if (!supported.contains(normalized)) return;

    // 1. Persist first so the choice survives an app restart.
    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().saveLanguageLocaleCurrentState(
        normalized,
      );
    }

    // 2. Update reactive values — driven by Obx in app.dart without engine freeze
    final nextLocale = Locale(normalized);
    Get.locale = nextLocale;
    locale.value = nextLocale;
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
        _ => ThemeMode.light,
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
