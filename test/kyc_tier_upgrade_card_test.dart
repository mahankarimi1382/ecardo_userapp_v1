import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/presentation/screens/kyc_level/view/widgets/kyc_tier_upgrade_card.dart';

void main() {
  Widget buildTestWidget({
    int currentTier = 1,
    int? initialSelectedTier,
    void Function(int)? onUpgradeTap,
    KycTierStatus? statusOverride,
    String? statusBadgeOverride,
    double? uploadProgress,
    String? uploadProgressLabel,
    VoidCallback? onCancelUpload,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: Scaffold(
          body: SingleChildScrollView(
            child: KycTierUpgradeCard(
              currentTier: currentTier,
              initialSelectedTier: initialSelectedTier,
              onUpgradeTap: onUpgradeTap,
              statusOverride: statusOverride,
              statusBadgeOverride: statusBadgeOverride,
              uploadProgress: uploadProgress,
              uploadProgressLabel: uploadProgressLabel,
              onCancelUpload: onCancelUpload,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('renders Tier 1 as current tier with correct limits & cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(buildTestWidget(currentTier: 1));
    await tester.pump();

    // Verify Tier 1 header & badges
    expect(find.textContaining('Tier 1'), findsWidgets);
    expect(find.textContaining('Email & Phone verified'), findsWidgets);
    expect(find.textContaining('Daily Transaction Limit'), findsOneWidget);
  });

  testWidgets('renders Tier 2 with \$10,000 limit and 3 Virtual Cards', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(currentTier: 1, initialSelectedTier: 2),
    );
    await tester.pump();

    // Check for Tier 2 details
    expect(find.textContaining('Tier 2'), findsWidgets);
    expect(find.textContaining('\$10,000'), findsWidgets);
    expect(find.textContaining('3 Virtual Cards'), findsWidgets);
    expect(
      find.textContaining('National ID / Passport verified'),
      findsWidgets,
    );
  });

  testWidgets(
    'renders Tier 3 VIP with \$100,000 / Unlimited and Unlimited Cards',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        buildTestWidget(currentTier: 2, initialSelectedTier: 3),
      );
      await tester.pump();

      // Check for Tier 3 VIP details
      expect(find.textContaining('Tier 3'), findsWidgets);
      expect(find.textContaining('VIP'), findsWidgets);
      expect(find.textContaining('Unlimited Cards'), findsWidgets);
      expect(
        find.textContaining('Proof of Address & Video Liveness'),
        findsWidgets,
      );
    },
  );

  testWidgets('tapping upgrade button calls onUpgradeTap with target tier', (
    WidgetTester tester,
  ) async {
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

    // Scope to the ElevatedButton so the tap hits the interactive CTA, not
    // the header/tab text that also contains "Upgrade to Tier 2".
    final upgradeButton = find.ancestor(
      of: find.textContaining('Upgrade to Tier 2'),
      matching: find.byType(ElevatedButton),
    );
    expect(upgradeButton, findsOneWidget);

    // The card is taller than the 600px test surface, so the CTA starts
    // off-screen and must be scrolled into view before it can be tapped.
    // Use a bounded pump, not pumpAndSettle: the tier badge has a continuous
    // glow animation, so the tree never settles.
    await tester.ensureVisible(upgradeButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(upgradeButton);
    await tester.pump();

    expect(tappedTier, equals(2));
  });

  testWidgets(
    'renders clear status badges for Pending, Verified, Rejected, Action Required',
    (WidgetTester tester) async {
      // 1. Pending Review status badge
      await tester.pumpWidget(
        buildTestWidget(
          currentTier: 2,
          statusOverride: KycTierStatus.pending,
        ),
      );
      await tester.pump();
      expect(find.text('Pending Review'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top_rounded), findsWidgets);

      // 2. Verified status badge
      await tester.pumpWidget(
        buildTestWidget(
          currentTier: 2,
          statusOverride: KycTierStatus.verified,
        ),
      );
      await tester.pump();
      expect(find.text('Verified'), findsOneWidget);
      expect(find.byIcon(Icons.verified_rounded), findsWidgets);

      // 3. Rejected status badge
      await tester.pumpWidget(
        buildTestWidget(
          currentTier: 1,
          statusOverride: KycTierStatus.rejected,
        ),
      );
      await tester.pump();
      expect(find.text('Rejected'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_rounded), findsWidgets);

      // 4. Action Required status badge
      await tester.pumpWidget(
        buildTestWidget(
          currentTier: 1,
          statusOverride: KycTierStatus.actionRequired,
        ),
      );
      await tester.pump();
      expect(find.text('Action Required'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsWidgets);
    },
  );

  testWidgets('renders Required Documents list for selected tier', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      buildTestWidget(currentTier: 1, initialSelectedTier: 2),
    );
    await tester.pump();

    // Verify Required Documents card and items for Tier 2
    expect(find.text('Required Documents'), findsOneWidget);
    expect(
      find.textContaining('Government National ID or Passport'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Live Liveness Selfie Capture'),
      findsOneWidget,
    );
  });

  testWidgets(
    'renders upload progress indicator with percentage and cancel action',
    (WidgetTester tester) async {
      bool cancelTapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          currentTier: 1,
          uploadProgress: 0.65,
          uploadProgressLabel: 'Uploading National ID (Front)...',
          onCancelUpload: () {
            cancelTapped = true;
          },
        ),
      );
      await tester.pump();

      // Check upload progress indicators
      expect(find.text('65%'), findsOneWidget);
      expect(find.text('Uploading National ID (Front)...'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.cloud_upload_rounded), findsOneWidget);

      // Tap cancel button
      final cancelBtn = find.byIcon(Icons.close_rounded);
      expect(cancelBtn, findsOneWidget);
      await tester.tap(cancelBtn);
      await tester.pump();

      expect(cancelTapped, isTrue);
    },
  );
}
