import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/email_otp_login_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/controller/sign_in_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_in/view/sign_in_screen.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/welcome/view/welcome_screen.dart';

import 'screenshot_harness.dart';

class _TestSignInController extends SignInController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _TestEmailOtpLoginController extends EmailOtpLoginController {
  @override
  // ignore: must_call_super
  void onInit() {}
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
}

List<void Function()> _authRegistrations() => [
      () => registerController<SettingsService>(_TestSettingsService()),
      () => registerController<SignInController>(_TestSignInController()),
      () => registerController<EmailOtpLoginController>(
            _TestEmailOtpLoginController(),
          ),
    ];

void main() {
  tearDown(resetHarness);

  group('WelcomeScreen Screenshots', () {
    testWidgets('welcome — light', (tester) async {
      await pumpScreen(
        tester,
        const WelcomeScreen(),
        registrations: _authRegistrations(),
      );
      await capture(tester, 'welcome__light');
    });

    testWidgets('welcome — dark', (tester) async {
      await pumpScreen(
        tester,
        const WelcomeScreen(),
        dark: true,
        registrations: _authRegistrations(),
      );
      await capture(tester, 'welcome__dark');
    });

    testWidgets('welcome — RTL', (tester) async {
      await pumpScreen(
        tester,
        const WelcomeScreen(),
        textDirection: TextDirection.rtl,
        registrations: _authRegistrations(),
      );
      await capture(tester, 'welcome__rtl');
    });
  });

  group('SignInScreen Screenshots', () {
    testWidgets('signin — light', (tester) async {
      await pumpScreen(
        tester,
        const SignInScreen(),
        registrations: _authRegistrations(),
      );
      await capture(tester, 'signin__light');
    });

    testWidgets('signin — dark', (tester) async {
      await pumpScreen(
        tester,
        const SignInScreen(),
        dark: true,
        registrations: _authRegistrations(),
      );
      await capture(tester, 'signin__dark');
    });

    testWidgets('signin — RTL', (tester) async {
      await pumpScreen(
        tester,
        const SignInScreen(),
        textDirection: TextDirection.rtl,
        registrations: _authRegistrations(),
      );
      await capture(tester, 'signin__rtl');
    });
  });
}
