import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/common/model/user_model.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/controller/qr_code_controller.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/model/qr_code_model.dart';
import 'package:ecardo_user/src/presentation/screens/qr_code/view/qr_code_screen.dart';
import 'package:ecardo_user/src/presentation/screens/referral/controller/referral_controller.dart';
import 'package:ecardo_user/src/presentation/screens/referral/model/referral_model.dart';
import 'package:ecardo_user/src/presentation/screens/referral/view/referral_screen.dart';

import 'screenshot_harness.dart';

class _MockNetworkService extends GetxService implements NetworkService {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestReferralController extends ReferralController {
  _TestReferralController() {
    isLoading.value = false;
    isError.value = false;
    referralModel.value = ReferralModel(
      status: 'success',
      message: 'Referral data loaded',
      data: ReferralData(
        amount: '25.00',
        code: 'ECARDO777',
        joinedText: '3 Friends Joined',
        isShownReferralRules: true,
        rules: [
          Rules(
            icon: 'tick',
            rule: 'Share your invite code with friends and family.',
          ),
          Rules(
            icon: 'tick',
            rule: 'They sign up and complete their first KYC verification.',
          ),
          Rules(
            icon: 'tick',
            rule: 'Receive cash bonus directly to your wallet.',
          ),
        ],
      ),
    );
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchReferral() async {
    // Intentionally empty — skip network calls during widget testing.
  }
}

const String _mockQrSvg =
    '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <rect width="100" height="100" fill="white"/>
  <rect x="10" y="10" width="30" height="30" fill="black"/>
  <rect x="15" y="15" width="20" height="20" fill="white"/>
  <rect x="20" y="20" width="10" height="10" fill="black"/>
  <rect x="60" y="10" width="30" height="30" fill="black"/>
  <rect x="65" y="15" width="20" height="20" fill="white"/>
  <rect x="70" y="20" width="10" height="10" fill="black"/>
  <rect x="10" y="60" width="30" height="30" fill="black"/>
  <rect x="15" y="65" width="20" height="20" fill="white"/>
  <rect x="20" y="70" width="10" height="10" fill="black"/>
  <rect x="50" y="50" width="15" height="15" fill="black"/>
  <rect x="70" y="70" width="15" height="15" fill="black"/>
</svg>''';

class _TestQrCodeController extends QrCodeController {
  _TestQrCodeController() {
    isLoading.value = false;
    hasError.value = false;
    qrCodeModel.value = QrCodeModel(
      status: 'success',
      message: 'QR code loaded',
      data: _mockQrSvg,
    );
    userModel.value = UserModel(
      status: 'success',
      message: 'User loaded',
      data: UserData(
        firstName: 'Alex',
        lastName: 'Morgan',
        username: 'alexmorgan',
        accountNumber: 'EC-9482-1049',
        email: 'alex.morgan@ecardo.io',
      ),
    );
  }

  @override
  // ignore: must_call_super
  void onInit() {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> loadData() async {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchQrCode() async {
    // Intentionally empty — skip network calls during widget testing.
  }

  @override
  Future<void> fetchUser() async {
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

  group('ReferralScreen Visual Regression Tests', () {
    testWidgets('referral — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const ReferralScreen(),
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () =>
              registerController<ReferralController>(_TestReferralController()),
        ],
      );
      await capture(tester, 'referral__light');
    });

    testWidgets('referral — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const ReferralScreen(),
        dark: true,
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () =>
              registerController<ReferralController>(_TestReferralController()),
        ],
      );
      await capture(tester, 'referral__dark');
    });
  });

  group('QrCodeScreen Visual Regression Tests', () {
    testWidgets('qr_code — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const QrCodeScreen(),
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<QrCodeController>(_TestQrCodeController()),
        ],
      );
      await capture(tester, 'qr_code__light');
    });

    testWidgets('qr_code — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const QrCodeScreen(),
        dark: true,
        registrations: [
          () => registerController<NetworkService>(_MockNetworkService()),
          () => registerController<QrCodeController>(_TestQrCodeController()),
        ],
      );
      await capture(tester, 'qr_code__dark');
    });
  });
}
