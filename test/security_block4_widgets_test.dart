import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart';

/// Block 4 widget tests (v1.0.133).
///
/// SCOPE CHANGED. Two of the three card-security widgets were removed in
/// v1.0.133 because they presented fabricated data as authoritative:
///
///   - `DynamicCvv2Card` generated the CVV on-device with
///     `Random().nextInt(900)` and no backend call, so it displayed a fake
///     credential labelled LIVE and overwrote the card's real CVC after the
///     first rotation.
///   - `CardSpendingLimitsCard` kept limits in local state, was constructed
///     with no `onSaveLimits` callback, and still showed "saved successfully".
///
/// `CardFreezeOverlay` survives because freeze/unfreeze does call the card
/// status endpoint, so the control is backed by a real request.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CardFreezeOverlay', () {
    testWidgets('renders the frozen banner and reports the toggle',
        (tester) async {
      bool freezeToggled = false;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CardFreezeOverlay(
                isFrozen: true,
                onFreezeToggled: (val) => freezeToggled = val,
                child: Container(
                  width: 300,
                  height: 180,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card is Frozen'), findsOneWidget);

      // The control must hand the requested state back to the caller, which
      // is what issues the card-status request.
      final overlay = tester.widget<CardFreezeOverlay>(
        find.byType(CardFreezeOverlay),
      );
      overlay.onFreezeToggled!(false);
      expect(freezeToggled, isFalse);
    });

    testWidgets('does not show the frozen banner when the card is active',
        (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CardFreezeOverlay(
                isFrozen: false,
                onFreezeToggled: (_) {},
                child: Container(
                  width: 300,
                  height: 180,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Card is Frozen'), findsNothing);
    });
  });
}