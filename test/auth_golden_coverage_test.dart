import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ecardo_user/src/common/services/settings_service.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/email_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/controller/verify_email_controller.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/email/email_screen.dart';
import 'package:ecardo_user/src/presentation/screens/authentication/sign_up/view/verify_email/verify_email_screen.dart';

import 'screenshot_harness.dart';

class _TestEmailController extends EmailController {
  _TestEmailController() {
    isLoading.value = false;
    isEmailFocused.value = false;
    emailController.text = 'alex@example.com';
  }

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  void clearSignUpStatus() {}
}

class _TestVerifyEmailController extends VerifyEmailController {
  _TestVerifyEmailController() {
    isLoading.value = false;
    isPinEnabled.value = true;
    countdown.value = 30;
    pinCodeController.text = '123456';
  }

  @override
  // ignore: must_call_super
  void onInit() {}

  @override
  void startTimer() {
    countdown.value = 30;
    isPinEnabled.value = true;
  }
}

class _TestSettingsService extends SettingsService {
  @override
  String? getSetting(String key) => '1';
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

  group('EmailScreen Screenshots', () {
    testWidgets('email — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const EmailScreen(),
        registrations: [
          () => registerController<EmailController>(_TestEmailController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(EmailScreen), findsOneWidget);
      await capture(tester, 'email__light');
    });

    testWidgets('email — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const EmailScreen(),
        dark: true,
        registrations: [
          () => registerController<EmailController>(_TestEmailController()),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(EmailScreen), findsOneWidget);
      await capture(tester, 'email__dark');
    });
  });

  group('VerifyEmailScreen Screenshots', () {
    testWidgets('verify_email — light', (tester) async {
      _ignoreOverflows();
      SharedPreferences.setMockInitialValues({
        SettingsService.currentEmailKey: 'alex@example.com',
      });
      await pumpScreen(
        tester,
        const VerifyEmailScreen(),
        registrations: [
          () => registerController<VerifyEmailController>(
            _TestVerifyEmailController(),
          ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      await capture(tester, 'verify_email__light');
    });

    testWidgets('verify_email — dark', (tester) async {
      _ignoreOverflows();
      SharedPreferences.setMockInitialValues({
        SettingsService.currentEmailKey: 'alex@example.com',
      });
      await pumpScreen(
        tester,
        const VerifyEmailScreen(),
        dark: true,
        registrations: [
          () => registerController<VerifyEmailController>(
            _TestVerifyEmailController(),
          ),
          () => registerController<SettingsService>(_TestSettingsService()),
        ],
      );
      expect(find.byType(VerifyEmailScreen), findsOneWidget);
      await capture(tester, 'verify_email__dark');
    });
  });
}
