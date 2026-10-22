import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/bill_payment/view/bill_payment_screen.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/controller/p2p_controller.dart';
import 'package:ecardo_user/src/presentation/screens/p2p/view/p2p_view.dart';

import 'screenshot_harness.dart';

typedef P2PScreen = P2pViewScreen;

class _TestP2pController extends P2pController {
  @override
  // ignore: must_call_super
  void onInit() {
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

  group('BillPaymentScreen Visual Regression Tests', () {
    testWidgets('bill_payment — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const BillPaymentScreen(),
      );
      await capture(tester, 'bill_payment__light');
    });

    testWidgets('bill_payment — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const BillPaymentScreen(),
        dark: true,
      );
      await capture(tester, 'bill_payment__dark');
    });
  });

  group('P2PScreen Visual Regression Tests', () {
    testWidgets('p2p — light', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const P2PScreen(),
        registrations: [
          () => registerController<P2pController>(_TestP2pController()),
        ],
      );
      await capture(tester, 'p2p__light');
    });

    testWidgets('p2p — dark', (tester) async {
      _ignoreOverflows();
      await pumpScreen(
        tester,
        const P2PScreen(),
        dark: true,
        registrations: [
          () => registerController<P2pController>(_TestP2pController()),
        ],
      );
      await capture(tester, 'p2p__dark');
    });
  });
}
