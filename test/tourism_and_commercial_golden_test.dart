import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/tour/controllers/tour_controller.dart';
import 'package:ecardo_user/src/tour/screens/tour_list_screen.dart';
import 'package:ecardo_user/src/visa/controllers/visa_controller.dart';
import 'package:ecardo_user/src/visa/screens/visa_catalog_screen.dart';

import 'screenshot_harness.dart';

class _MockNetworkService extends GetxService implements NetworkService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

class _TestTourController extends TourController {
  _TestTourController() {
    isLoadingTours.value = false;
    isServiceUnavailable.value = false;
    errorMessage.value = null;
    tours.clear();
    selectedCategory.value = '';
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> loadTours({bool refresh = false}) async {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> loadTourDetail(int id) async {
    // Intentionally empty — skip network calls during widget testing.
  }
}

class _TestVisaController extends VisaController {
  _TestVisaController() {
    isLoadingCatalog.value = false;
    hasBackendError.value = false;
    isServiceAvailable.value = true;
    isServiceUnavailable.value = false;
    catalogList.clear();
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> loadCatalog() async {
    // Intentionally empty — skip network calls during widget testing.
  }
}

void _ignoreOverflows() {
  final originalOnError = FlutterError.onError;
  FlutterError.onError = (FlutterErrorDetails details) {
    final exceptionStr = details.exceptionAsString();
    if (exceptionStr.contains('A RenderFlex overflowed') ||
        exceptionStr.contains('RenderBox was not laid out') ||
        exceptionStr.contains('hasSize') ||
        exceptionStr.contains('would not hit test on the specified widget')) {
      return;
    }
    if (originalOnError != null) {
      originalOnError(details);
    } else {
      FlutterError.dumpErrorToConsole(details);
    }
  };
}

void main() {
  tearDown(resetHarness);

  group('TourListScreen Visual Regression Tests', () {
    testWidgets('tour_list — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const TourListScreen(),
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<TourController>(_TestTourController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'tour_list__light');
    });

    testWidgets('tour_list — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const TourListScreen(),
        dark: true,
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<TourController>(_TestTourController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'tour_list__dark');
    });
  });

  group('VisaCatalogScreen Visual Regression Tests', () {
    testWidgets('visa_catalog — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const VisaCatalogScreen(),
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<VisaController>(_TestVisaController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'visa_catalog__light');
    });

    testWidgets('visa_catalog — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const VisaCatalogScreen(),
        dark: true,
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<VisaController>(_TestVisaController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'visa_catalog__dark');
    });
  });
}
