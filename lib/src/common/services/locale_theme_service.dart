import 'package:ecardo_user/src/common/controller/country_controller.dart';
import 'package:ecardo_user/src/presentation/screens/home/controller/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';

/// Reactive locale + theme so settings changes apply without app restart.
class LocaleThemeService extends GetxService {
  static const supported = ['fa', 'en', 'ar', 'zh'];

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
    locale.value = Locale(normalized);
    Get.updateLocale(locale.value);
    if (Get.isRegistered<SettingsService>()) {
      await Get.find<SettingsService>().saveLanguageLocaleCurrentState(
        normalized,
      );
    }
    try {
      if (Get.isRegistered<HomeController>()) {
        final home = Get.find<HomeController>();
        final name = nativeName(code);
        home.language.value = name;
        home.languageController.text = name;
      }
    } catch (_) {}

    // مورد ۳ (v1.0.118): بعد از تغییر زبان، لیست کشورها را دوباره load کن
    // تا نام‌های کشور با زبان جدید از API دریافت شوند (Accept-Language header).
    try {
      if (Get.isRegistered<CountryController>()) {
        Get.find<CountryController>().fetchCountries();
      }
    } catch (_) {}
  }

  Future<void> setThemeModePref(String mode) async {
    themeMode.value = _parseTheme(mode);
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
        _ => 'English',
      };
}
