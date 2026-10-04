// Shared harness for capturing deterministic widget screenshots in `flutter test`.
//
// Three Flutter-test gotchas this file exists to work around:
//
//  * `flutter test` renders text with a placeholder font unless real font data is
//    loaded, so screenshots come out as unreadable boxes without [loadAppFonts].
//  * The test body runs in a fake-async zone, so real file I/O never completes.
//    Font loading therefore has to go through `tester.runAsync`.
//  * Every `GetMaterialApp` mount resets GetX's dependency registry. So the app is
//    mounted *first* and controllers are registered *after*, against the instance
//    that the screen will actually resolve from.
//
// Usage from a screen test:
//   await pumpScreen(tester, MyScreen(), controllers: [MyFakeController()]);
//   await capture(tester, 'home__light');
//   await capture(tester, 'home__dark', dark: true);
//   await capture(tester, 'home__rtl', textDirection: TextDirection.rtl);

import 'dart:io';

import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/app/config/theme/dark_theme.dart';
import 'package:ecardo_user/src/app/config/theme/light_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Screenshots land here, relative to `test/`.
const String kScreenshotDir = 'test_output/screens';

/// iPhone 14-ish logical size — the baseline this app's layouts are tuned for.
const Size kDefaultScreenSize = Size(390, 844);

/// Key on the full-screen [RepaintBoundary] that [capture] snapshots.
final Key kCaptureKey = GlobalKey(// coverage:ignore-start
  debugLabel: 'ecardo_screenshot_capture',
);

/// The app's themes, resolved once from a real mounted context.
late final ThemeData kLightTheme;
late final ThemeData kDarkTheme;
bool _themesResolved = false;
bool _fontsLoaded = false;

const List<LocalizationsDelegate<dynamic>> _delegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
  AppLocalizations.delegate,
];

/// Loads the app's real font data once per test process.
///
/// Must run inside `tester.runAsync` — reading font files off disk is real I/O, which
/// the fake-async test zone would never complete.
///
/// MaterialIcons comes from the Flutter SDK rather than `assets/fonts/`, and it is
/// registered under the empty family name. Without it every icon renders as a hollow
/// square in screenshots.
Future<void> loadAppFonts(WidgetTester tester) async {
  if (_fontsLoaded) return;
  await tester.runAsync(() async {
    Future<ByteData> read(String path) async {
      final file = File(path);
      if (!file.existsSync()) {
        throw StateError(
          'Font not found at "$path". Run tests from the package root '
          '(ecardo_userapp_v1) so relative asset paths resolve.',
        );
      }
      return ByteData.view(Uint8List.fromList(await file.readAsBytes()).buffer);
    }

    await (FontLoader('Plus Jakarta Sans')
          ..addFont(read('assets/fonts/PlusJakartaSans-VariableFont_wght.ttf')))
        .load();
    await (FontLoader('Vazirmatn')
          ..addFont(read('assets/fonts/Vazirmatn-Regular.ttf')))
        .load();
    await (FontLoader('NotoSansRU')
          ..addFont(read('assets/fonts/NotoSans-Regular.ttf')))
        .load();

    final iconFont = _materialIconsPath();
    if (iconFont != null) {
      await (FontLoader('MaterialIcons')..addFont(read(iconFont))).load();
    }
  });
  _fontsLoaded = true;
}

/// Locates `MaterialIcons-Regular.otf` inside the Flutter SDK, if reachable.
///
/// Resolved from the `flutter` executable on PATH, since `FLUTTER_ROOT` is not set
/// during `flutter test`. Returns null when the SDK cannot be found, in which case
/// screenshots still render — icons just come out as squares.
String? _materialIconsPath() {
  final separator = Platform.pathSeparator;
  final flutterExe = _onPath('flutter') ?? _onPath('flutter.bat');
  if (flutterExe == null) return null;
  final sdkRoot = File(flutterExe).parent.parent.path;
  final candidate = File(
    '$sdkRoot${separator}bin${separator}cache${separator}artifacts'
    '${separator}material_fonts${separator}materialicons-regular.otf',
  );
  return candidate.existsSync() ? candidate.path : null;
}

String? _onPath(String executable) {
  final pathEnv = Platform.environment['PATH'];
  if (pathEnv == null) return null;
  final extensions = Platform.isWindows
      ? const ['.bat', '.cmd', '.exe', '']
      : const [''];
  for (final dir in pathEnv.split(Platform.isWindows ? ';' : ':')) {
    if (dir.isEmpty) continue;
    for (final ext in extensions) {
      final candidate = File('$dir${Platform.pathSeparator}$executable$ext');
      if (candidate.existsSync()) return candidate.absolute.path;
    }
  }
  return null;
}

/// Builds the app tree wrapping [child].
///
/// Mounted twice per [pumpScreen] call — once with a placeholder to establish the
/// GetX registry and resolve themes, then again with the real screen. Because the
/// widget types and positions are identical, the second `pumpWidget` updates the
/// existing `GetMaterialApp` element instead of replacing it, so registered
/// controllers survive.
Widget _appTree({
  required Widget home,
  required ThemeData? theme,
  required ThemeData? darkTheme,
  required ThemeMode themeMode,
  required Size size,
  required TextDirection textDirection,
  required Locale locale,
}) {
  return ScreenUtilInit(
    designSize: size,
    builder: (context, _) => GetMaterialApp(
      locale: locale,
      localizationsDelegates: _delegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: theme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: Directionality(
        textDirection: textDirection,
        child: home,
      ),
    ),
  );
}

/// Registers a controller under the type screens actually look it up by.
///
/// `Get.put(fake)` infers the type argument from the argument's *runtime* type, so a
/// `_TestWalletsController` gets filed under `_TestWalletsController` and every later
/// `Get.find<WalletsController>()` throws "not found". This helper forces the base
/// type, so subclasses stay swappable while lookup keeps working:
///
///     registerController<WalletsController>(_TestWalletsController());
///
/// In the app these are registered by base type through GetX bindings, so mirroring
/// that here keeps the test faithful to real wiring.
void registerController<S>(S controller) {
  Get.put<S>(controller, permanent: true);
}

/// Pumps [child] inside the app scaffolding every real screen relies on: ScreenUtil,
/// GetX, the app's Material 3 theme, and localizations.
///
/// Pass [registrations] — typically `registerController<X>(fake)` calls — to satisfy
/// the screen's `Get.find` lookups. Subclass the real controller and override `onInit`
/// to skip network calls, the way `wallets_creative_ui_test.dart` does.
///
/// The whole tree is wrapped in a [RepaintBoundary] keyed by [kCaptureKey] so
/// [capture] can snapshot a full screen — `find.byType(Widget)` matches nothing,
/// because `Widget` is abstract.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget child, {
  List<void Function()> registrations = const [],
  bool dark = false,
  Size size = kDefaultScreenSize,
  TextDirection textDirection = TextDirection.ltr,
  Locale locale = const Locale('en'),
}) async {
  await loadAppFonts(tester);
  await mockNativePlugins();

  // Pass 1: mount the app with a placeholder so GetX has a live instance and the
  // themes have a BuildContext to resolve against.
  await tester.pumpWidget(_appTree(
    home: const SizedBox.shrink(),
    theme: _themesResolved ? kLightTheme : null,
    darkTheme: _themesResolved ? kDarkTheme : null,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    size: size,
    textDirection: textDirection,
    locale: locale,
  ));

  if (!_themesResolved) {
    final context = tester.element(find.byType(SizedBox).first);
    kLightTheme = LightTheme().lightTheme(context);
    kDarkTheme = DarkTheme().darkTheme(context);
    _themesResolved = true;
  }

  for (final register in registrations) {
    register();
  }

  // Pass 2: same app instance, real child behind the capture boundary.
  await tester.pumpWidget(_appTree(
    home: RepaintBoundary(key: kCaptureKey, child: child),
    theme: kLightTheme,
    darkTheme: kDarkTheme,
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    size: size,
    textDirection: textDirection,
    locale: locale,
  ));

  await tester.pump();
  // Two settle frames: one for entrance animations kicked off in initState, one for
  // any implicit animations (AnimatedContainer/AnimatedOpacity) those started.
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));
}

/// Writes the current frame to `test_output/screens/<name>.png`.
///
/// Run with `flutter test --update-goldens` to (re)generate; run without it to assert
/// the screen has not changed since the last approved capture.
Future<void> capture(WidgetTester tester, String name) async {
  await expectLater(
    find.byKey(kCaptureKey),
    matchesGoldenFile('$kScreenshotDir/$name.png'),
  );
}

/// Clears GetX state between tests. Call from `tearDown`.
void resetHarness() => Get.reset();

/// Neutralizes the native plugin channels that screens touch during a build.
///
/// `flutter test` runs on the host, so platform channels have no implementation and
/// every call throws `MissingPluginException` — which fails the test even when the
/// screen handles the error gracefully. Stubbing the channels the app actually uses
/// lets a screen render with realistic defaults instead.
///
/// Called automatically by [pumpScreen]; the public entry point exists for tests that
/// need to stub a channel of their own before mounting.
Future<void> mockNativePlugins() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  if (_pluginsMocked) return;
  _pluginsMocked = true;

  // Returning null for secure storage reads means "no token stored", which is what a
  // fresh install looks like — so screens take their logged-out path.
  const secureStorage = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  const packageInfo = MethodChannel('dev.fluttercommunity.plus/package_info');
  const connectivity = MethodChannel('dev.fluttercommunity.plus/connectivity');
  const appBadge = MethodChannel('ecardo/app_badge');
  const toast = MethodChannel('PonnamKarthik/fluttertoast');

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(secureStorage, (call) async {
    switch (call.method) {
      case 'read':
        return null;
      case 'readAll':
        return <String, String>{};
      case 'containsKey':
        return false;
      default:
        return null;
    }
  });

  // Version 1.0.0 so the app-update banner has something concrete to compare against.
  messenger.setMockMethodCallHandler(packageInfo, (call) async {
    return {
      'appName': 'eCardo',
      'packageName': 'com.ecardo.user',
      'version': '1.0.0',
      'buildNumber': '1',
    };
  });

  messenger.setMockMethodCallHandler(connectivity, (call) async {
    return {'wifi': true, 'mobile': false, 'ethernet': false, 'vpn': false,
            'other': false, 'none': false, 'bluetooth': false};
  });

  // Native-side badge updates are a no-op in tests, but the call still has to resolve
  // or `AppBadgeService` throws where a screen calls it during build.
  messenger.setMockMethodCallHandler(appBadge, (call) async => null);
  messenger.setMockMethodCallHandler(toast, (call) async => null);
}

bool _pluginsMocked = false;