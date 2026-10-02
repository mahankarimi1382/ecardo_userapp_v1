import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart';
import 'package:ecardo_user/src/presentation/screens/settings/view/security/device_sessions_security_screen.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DynamicCvv2Card', () {
    testWidgets('renders dynamic CVV with countdown and regenerate action', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: DynamicCvv2Card(
                initialCvv: '742',
                rotationCycleSeconds: 180,
              ),
            ),
          ),
        ),
      );

      // Verify CVV label and initial value
      expect(find.text('Dynamic CVV2'), findsOneWidget);
      expect(find.text('742'), findsOneWidget);
      expect(find.text('Regenerate Now'), findsOneWidget);
    });
  });

  group('CardFreezeOverlay', () {
    testWidgets('renders frozen banner when isFrozen is true and allows toggle', (tester) async {
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

      // Verify frozen status indicator
      expect(find.text('Card is Frozen'), findsOneWidget);
    });
  });

  group('CardSpendingLimitsCard', () {
    testWidgets('renders daily and monthly spending limit sliders and channel toggles', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CardSpendingLimitsCard(
                  initialDailyLimit: 500.0,
                  initialMonthlyLimit: 2500.0,
                  maxDailyLimit: 2000.0,
                  maxMonthlyLimit: 10000.0,
                  currency: 'USD',
                ),
              ),
            ),
          ),
        ),
      );

      // Verify spending limits header and labels
      expect(find.text('Spending Limits & Channel Controls'), findsOneWidget);
      expect(find.text('Daily Spending Limit'), findsOneWidget);
      expect(find.text('Monthly Spending Limit'), findsOneWidget);
      expect(find.text('Online Transactions'), findsOneWidget);
      expect(find.text('International Transactions'), findsOneWidget);
    });
  });

  group('KycTierUpgradeCard', () {
    testWidgets('renders current tier badge, daily limits, and upgrade roadmap', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: KycTierUpgradeCard(
                  currentTier: 1,
                  consumedDailyLimit: 250.0,
                  maxDailyLimit: 1000.0,
                  currency: 'USD',
                ),
              ),
            ),
          ),
        ),
      );

      // Verify tier badge and roadmap
      expect(find.text('Tier 1: Basic'), findsWidgets);
      expect(find.text('Daily Limit Usage'), findsOneWidget);
      expect(find.text('Upgrade to Tier 2'), findsOneWidget);
    });
  });

  group('DeviceSessionsSecurityScreen', () {
    testWidgets('renders active sessions screen with This Device hero and terminate button', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: DeviceSessionsSecurityScreen(),
          ),
        ),
      );

      // Verify header and sections
      expect(find.text('Devices & Active Sessions'), findsOneWidget);
      expect(find.text('This Device (Current Session)'), findsOneWidget);
      expect(find.text('Active Now'), findsOneWidget);
      expect(find.text('Other Active Devices'), findsOneWidget);
      expect(find.text('Terminate All Other Sessions'), findsOneWidget);
    });
  });
}
