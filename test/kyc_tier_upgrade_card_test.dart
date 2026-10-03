import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart';

void main() {
  Widget buildTestWidget({
    int currentTier = 1,
    int? initialSelectedTier,
    void Function(int)? onUpgradeTap,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) => MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: KycTierUpgradeCard(
              currentTier: currentTier,
              initialSelectedTier: initialSelectedTier,
              onUpgradeTap: onUpgradeTap,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders Tier 1 as current tier with correct limits & cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTestWidget(currentTier: 1));
    await tester.pump();

    // Verify Tier 1 header & badges
    expect(find.textContaining('Tier 1'), findsWidgets);
    expect(find.textContaining('Email & Phone verified'), findsWidgets);
    expect(find.textContaining('Daily Transaction Limit'), findsOneWidget);
  });

  testWidgets('renders Tier 2 with \$10,000 limit and 3 Virtual Cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(currentTier: 1, initialSelectedTier: 2),
    );
    await tester.pump();

    // Check for Tier 2 details
    expect(find.textContaining('Tier 2'), findsWidgets);
    expect(find.textContaining('\$10,000'), findsWidgets);
    expect(find.textContaining('3 Virtual Cards'), findsWidgets);
    expect(find.textContaining('National ID / Passport verified'), findsWidgets);
  });

  testWidgets('renders Tier 3 VIP with \$100,000 / Unlimited and Unlimited Cards',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      buildTestWidget(currentTier: 2, initialSelectedTier: 3),
    );
    await tester.pump();

    // Check for Tier 3 VIP details
    expect(find.textContaining('Tier 3'), findsWidgets);
    expect(find.textContaining('VIP'), findsWidgets);
    expect(find.textContaining('Unlimited Cards'), findsWidgets);
    expect(find.textContaining('Proof of Address & Video Liveness'), findsWidgets);
  });

  testWidgets('tapping upgrade button calls onUpgradeTap with target tier',
      (WidgetTester tester) async {
    int? tappedTier;

    await tester.pumpWidget(
      buildTestWidget(
        currentTier: 1,
        initialSelectedTier: 2,
        onUpgradeTap: (tier) {
          tappedTier = tier;
        },
      ),
    );
    await tester.pump();

    final upgradeButton = find.textContaining('Upgrade to Tier 2');
    expect(upgradeButton, findsOneWidget);

    // The card is taller than the test viewport inside the harness
    // SingleChildScrollView — bring the button on-screen or the tap misses.
    await tester.ensureVisible(upgradeButton);
    await tester.pumpAndSettle();
    await tester.tap(upgradeButton);
    await tester.pump();

    expect(tappedTier, equals(2));
  });
}
