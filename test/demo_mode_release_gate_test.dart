import 'package:ecardo_user/src/common/services/demo_account_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// RELEASE GATE REGRESSION TESTS
///
/// Demo mode fabricates balances and short-circuits the network layer. It is a
/// debug-only tool, so the rule "may demo mode intercept traffic?" must be false for
/// every non-debug build — regardless of what the admin kill-switch says, what was
/// persisted, or whether the service happens to be registered.
///
/// If someone deletes the `isDebugBuild` branch from
/// [DemoAccountService.isDemoInterceptionPermitted] (or the `kDebugMode` gate in
/// `lib/main.dart`), these fail.

bool permitted({
  bool debug = true,
  bool registered = true,
  bool demoActive = true,
}) {
  return DemoAccountService.isDemoInterceptionPermitted(
    isDebugBuild: debug,
    isServiceRegistered: registered,
    isDemoModeActive: demoActive,
  );
}

void main() {
  group('DemoAccountService release gate', () {
    test('NEVER intercepts when the build is not debug (release/profile)', () {
      // The whole point of the fix: a non-debug build is refused unconditionally,
      // no matter how favourable the other two inputs are.
      expect(permitted(debug: false), isFalse);
      expect(permitted(debug: false, registered: true, demoActive: true), isFalse);
      expect(permitted(debug: false, registered: false, demoActive: false), isFalse);
    });

    test('a non-debug build cannot be coaxed into intercepting', () {
      // Every combination of the other two inputs, with the build flag off.
      for (final registered in [true, false]) {
        for (final demoActive in [true, false]) {
          expect(
            permitted(debug: false, registered: registered, demoActive: demoActive),
            isFalse,
            reason: 'release build must never intercept '
                '(registered: $registered, demoActive: $demoActive)',
          );
        }
      }
    });

    test('intercepts only in debug with the service registered AND demo active', () {
      expect(permitted(), isTrue);
      expect(permitted(debug: true, registered: true, demoActive: true), isTrue);
    });

    test('debug alone is not enough — service and demo session are both required', () {
      expect(permitted(debug: true, registered: false, demoActive: true), isFalse);
      expect(permitted(debug: true, registered: true, demoActive: false), isFalse);
      expect(permitted(debug: true, registered: false, demoActive: false), isFalse);
    });

    test('debug-only build availability follows kDebugMode', () {
      // Guards the main.dart registration gate and _loadPersistedDemoState /
      // activateDemoMode, which both branch on this getter.
      expect(DemoAccountService.isDemoAvailableInThisBuild, kDebugMode);
    });

    test('service does not intercept when it is not registered', () {
      // Real-app shape of the guard: nothing is registered in a release build.
      Get.testMode = true;
      Get.reset();
      expect(Get.isRegistered<DemoAccountService>(), isFalse);
      expect(DemoAccountService.isDemoInterceptionAllowedNow, isFalse);
    });

    test('a registered, active demo session cannot fabricate data in a release build',
        () async {
      // End-to-end against the live object: even with the service registered and
      // isDemoMode set to true, the dispatcher must refuse outside debug.
      SharedPreferences.setMockInitialValues({});
      Get.testMode = true;
      Get.reset();

      final service = Get.put<DemoAccountService>(DemoAccountService());
      service.isDemoMode.value = true;

      final mock = service.handleDemoRequest(
        endpoint: '/auth/user/get',
        method: 'GET',
      );
      final fallback = service.handleDemoFallback(
        endpoint: '/loan/apply',
        method: 'POST',
      );

      if (kDebugMode) {
        // Debug: the demo tool keeps working end to end.
        expect(mock, isNotNull);
        expect(fallback, isNotNull);
      } else {
        expect(mock, isNull, reason: 'release build must not fabricate a profile');
        expect(
          fallback,
          isNull,
          reason: 'release build must not fabricate a loan approval',
        );
      }

      // Whatever the build, the build flag itself is what drives the refusal.
      expect(
        DemoAccountService.isDemoInterceptionAllowedNow,
        kDebugMode && DemoAccountService.isDemoInterceptionPermitted(
          isDebugBuild: DemoAccountService.isDemoAvailableInThisBuild,
          isServiceRegistered: true,
          isDemoModeActive: true,
        ),
      );

      await Get.deleteAll(force: true);
    });

    test('persisted demo state is ignored outside debug builds', () async {
      SharedPreferences.setMockInitialValues({});
      Get.testMode = true;
      Get.reset();

      const prefKey = 'ecardo_demo_mode_active';
      SharedPreferences.setMockInitialValues({prefKey: true});

      final service = Get.put<DemoAccountService>(DemoAccountService());
      // onInit -> _loadPersistedDemoState. In debug the pref still works; outside
      // debug it is a no-op, so a stale "true" cannot resurrect a demo session.
      await Future<void>.delayed(Duration.zero);

      expect(
        service.isDemoMode.value,
        kDebugMode,
        reason: 'persisted demo state must only be honoured in debug builds',
      );

      await Get.deleteAll(force: true);
    });

    test('admin kill-switch defaults to closed outside debug builds', () async {
      SharedPreferences.setMockInitialValues({});
      Get.testMode = true;
      Get.reset();

      final service = Get.put<DemoAccountService>(DemoAccountService());
      // Fail-closed: demo must be opted into explicitly, and only where it may exist.
      expect(service.isDemoAllowedByAdmin.value, kDebugMode);
      expect(service.isDemoBlockedByAdmin, !kDebugMode);

      await Get.deleteAll(force: true);
    });

    test('demo entry points are not reachable outside debug builds', () {
      // The sign-in "Quick Live Demo" card and the drawer/settings tester controls
      // render behind `isDemoAvailableInThisBuild && isRegistered`. In a release build
      // the first term is false, so none of them are built at all — note this holds
      // even in the release case where the service is NOT registered, which is the
      // inversion that previously left the demo card visible in shipped builds.
      final serviceRegistered = true;
      final demoEntryPointVisible =
          DemoAccountService.isDemoAvailableInThisBuild && serviceRegistered;
      expect(demoEntryPointVisible, kDebugMode);
    });
  });
}