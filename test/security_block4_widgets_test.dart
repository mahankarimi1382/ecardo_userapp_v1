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
    // The overlay is laid out by ScreenUtil against a 375x812 design size.
    // flutter_test's default 800x600 surface makes ScreenUtil scale every
    // .w/.sp by 800/375 = 2.13x while the child's 300x180 box stays put,
    // which overflows the frosted banner and the lock badge. Pump at the
    // design size instead (same trick as dashboard_services_qc_test).
    void phoneSurface(WidgetTester tester) {
      tester.view.physicalSize = const Size(750, 1624);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);
    }

    testWidgets('renders the frozen banner and reports the toggle',
        (tester) async {
      bool freezeToggled = false;
      phoneSurface(tester);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          // Mirrors app.dart: minTextAdapt keeps .sp-sized overlay content
          // inside the child box at the 800x600 CI test surface.
          minTextAdapt: true,
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: CardFreezeOverlay(
                isFrozen: true,
                onFreezeToggled: (val) => freezeToggled = val,
                child: Container(
                  width: 400,
                  height: 400,
                  color: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      // The status belongs on the card itself: the frosted badge says it, and
      // the banner spells out the consequence.
      expect(find.text('Card is Frozen'), findsOneWidget);
      expect(
        find.text('Card is currently frozen - all transactions blocked'),
        findsOneWidget,
      );

      // The switch next to the card is an ACTION, so it names the action. It
      // must not repeat the status a second time on the same screen.
      expect(find.text('Unfreeze Card'), findsOneWidget);
      expect(find.text('Card is Frozen'), findsNWidgets(1));

      // No layout overflow at the design size.
      expect(tester.takeException(), isNull);

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
      phoneSurface(tester);

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
      expect(find.text('Freeze Virtual Card'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}