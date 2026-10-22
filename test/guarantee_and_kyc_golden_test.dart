import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/guarantee/controllers/guarantee_controller.dart';
import 'package:ecardo_user/src/guarantee/screens/guarantee_home_screen.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/controller/kyc_level_controller.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/model/kyc_level_model.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/kyc_submit_wizard.dart';

import 'screenshot_harness.dart';

class _MockNetworkService extends GetxService implements NetworkService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

class _TestGuaranteeController extends GuaranteeController {
  _TestGuaranteeController() {
    isLoadingCases.value = false;
    isLoadingInstruments.value = false;
    myCases.assignAll(GuaranteeController.sampleCases);
    instruments.assignAll(GuaranteeController.defaultInstruments);
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchInstruments() async {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchMyCases() async {
    // Intentionally empty — skip network calls during widget testing.
  }
}

class _TestKycLevelController extends KycLevelController {
  _TestKycLevelController() {
    isLoading.value = false;
    isSubmitting.value = false;
    levels.assignAll([
      KycLevel(
        level: 1,
        name: 'Basic',
        description: 'Basic verification',
        color: 'green',
        icon: 'user',
        requiredDocs: ['phone', 'email'],
        features: ['transfers'],
        limits: {'daily_limit': 1000},
        status: 'completed',
      ),
      KycLevel(
        level: 2,
        name: 'Standard',
        description: 'Identity verification with ID and selfie',
        color: 'blue',
        icon: 'id_card',
        requiredDocs: ['govt_id', 'selfie'],
        features: ['exchange', 'travel'],
        limits: {'daily_limit': 10000},
        status: 'available',
      ),
    ]);
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchLevels() async {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchStatus() async {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchRejectionData() async {
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

  group('GuaranteeHomeScreen Visual Regression Tests', () {
    testWidgets('guarantee_home — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const GuaranteeHomeScreen(),
        registrations: [
          () => registerController<GuaranteeController>(
            _TestGuaranteeController(),
          ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'guarantee_home__light');
    });

    testWidgets('guarantee_home — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const GuaranteeHomeScreen(),
        dark: true,
        registrations: [
          () => registerController<GuaranteeController>(
            _TestGuaranteeController(),
          ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'guarantee_home__dark');
    });
  });

  group('KycSubmitWizard Visual Regression Tests', () {
    testWidgets('kyc_submit_wizard — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const KycSubmitWizard(targetLevel: 2),
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () =>
              registerController<KycLevelController>(_TestKycLevelController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'kyc_submit_wizard__light');
    });

    testWidgets('kyc_submit_wizard — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const KycSubmitWizard(targetLevel: 2),
        dark: true,
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () =>
              registerController<KycLevelController>(_TestKycLevelController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      await capture(tester, 'kyc_submit_wizard__dark');
    });
  });
}
