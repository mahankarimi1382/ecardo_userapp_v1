import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Widget wrapWithTheme({
    required Widget child,
    Brightness brightness = Brightness.light,
    Size surfaceSize = const Size(400, 800),
  }) {
    return MaterialApp(
      theme: ThemeData(
        brightness: brightness,
        useMaterial3: true,
        colorScheme: brightness == Brightness.dark
            ? const ColorScheme.dark(
                primary: AppColors.mainSoftBlue,
                surface: AppColors.darkSurface,
              )
            : const ColorScheme.light(
                primary: AppColors.deepBlack,
                surface: AppColors.lightBackground,
              ),
      ),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: surfaceSize.width,
            height: surfaceSize.height,
            child: child,
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // 1. ECARDO GLASS CARD
  // =========================================================================
  group('EcardoGlassCard Creative Tests', () {
    testWidgets('renders child and custom decoration across light and dark modes', (tester) async {
      for (final brightness in [Brightness.light, Brightness.dark]) {
        await tester.pumpWidget(
          wrapWithTheme(
            brightness: brightness,
            child: const EcardoGlassCard(
              child: Text('Glass Content'),
            ),
          ),
        );

        expect(find.text('Glass Content'), findsOneWidget);
        expect(find.byType(BackdropFilter), findsOneWidget);
      }
    });

    testWidgets('renders all neo-fintech variants correctly', (tester) async {
      for (final variant in EcardoGlassVariant.values) {
        await tester.pumpWidget(
          wrapWithTheme(
            child: EcardoGlassCard(
              variant: variant,
              child: Text('Variant ${variant.name}'),
            ),
          ),
        );

        expect(find.text('Variant ${variant.name}'), findsOneWidget);
      }
    });

    testWidgets('triggers onTap and handles scale transition', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: EcardoGlassCard(
            onTap: () => tapped = true,
            child: const Text('Tap Me'),
          ),
        ),
      );

      final cardFinder = find.text('Tap Me');
      await tester.tap(cardFinder);
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  // =========================================================================
  // 2. ECARDO BALANCE HERO
  // =========================================================================
  group('EcardoBalanceHero Creative Tests', () {
    testWidgets('renders balance amount, currency symbol, and secondary subtitle', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          child: const EcardoBalanceHero(
            amount: 14520.85,
            currencyCode: 'USD',
            currencySymbol: r'$',
            secondaryEquivalent: '≈ 85,000,000 IRT',
          ),
        ),
      );

      expect(find.text('14,520'), findsOneWidget);
      expect(find.text('.85'), findsOneWidget);
      expect(find.text(r'$'), findsOneWidget);
      expect(find.text('≈ 85,000,000 IRT'), findsOneWidget);
    });

    testWidgets('toggles privacy mode and displays obscured dot indicators', (tester) async {
      bool? privacyState;

      await tester.pumpWidget(
        wrapWithTheme(
          child: StatefulBuilder(
            builder: (context, setState) {
              return EcardoBalanceHero(
                amount: 9950.00,
                isObscured: privacyState,
                onTogglePrivacy: (val) {
                  setState(() => privacyState = val);
                },
              );
            },
          ),
        ),
      );

      // Initially visible
      expect(find.text('9,950'), findsOneWidget);

      // Tap privacy toggle icon
      final privacyButton = find.byIcon(Icons.visibility_rounded);
      expect(privacyButton, findsOneWidget);
      await tester.tap(privacyButton);
      await tester.pumpAndSettle();

      // Now obscured
      expect(privacyState, isTrue);
      expect(find.byKey(const ValueKey('obscured_balance')), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_rounded), findsOneWidget);

      // Tap again to reveal
      await tester.tap(find.byIcon(Icons.visibility_off_rounded));
      await tester.pumpAndSettle();
      expect(privacyState, isFalse);
      expect(find.byKey(const ValueKey('visible_balance')), findsOneWidget);
    });

    testWidgets('renders 24h PnL badge with positive and negative indicators', (tester) async {
      // Positive PnL
      await tester.pumpWidget(
        wrapWithTheme(
          child: const EcardoBalanceHero(
            amount: 5000.0,
            pnlPercentage: 4.25,
            pnlAmount: 212.50,
          ),
        ),
      );

      expect(find.text('+4.25%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);

      // Negative PnL in dark mode
      await tester.pumpWidget(
        wrapWithTheme(
          brightness: Brightness.dark,
          child: const EcardoBalanceHero(
            amount: 5000.0,
            pnlPercentage: -2.10,
          ),
        ),
      );

      expect(find.text('-2.10%'), findsOneWidget);
      expect(find.byIcon(Icons.trending_down_rounded), findsOneWidget);
    });

    testWidgets('opens currency picker modal and triggers onCurrencyChanged', (tester) async {
      String selected = 'USD';

      await tester.pumpWidget(
        wrapWithTheme(
          child: StatefulBuilder(
            builder: (context, setState) {
              return EcardoBalanceHero(
                amount: 3200.0,
                currencyCode: selected,
                availableCurrencies: const ['USD', 'USDT', 'EUR'],
                onCurrencyChanged: (curr) => setState(() => selected = curr),
              );
            },
          ),
        ),
      );

      // Tap currency switcher pill
      final currencyPill = find.text('USD');
      expect(currencyPill, findsOneWidget);
      await tester.tap(currencyPill);
      await tester.pumpAndSettle();

      // Bottom sheet is visible
      expect(find.text('Select Currency'), findsOneWidget);
      expect(find.text('USDT'), findsOneWidget);
      expect(find.text('EUR'), findsOneWidget);

      // Select EUR
      await tester.tap(find.text('EUR'));
      await tester.pumpAndSettle();

      expect(selected, equals('EUR'));
    });

    testWidgets('renders quick action buttons and handles taps', (tester) async {
      bool sendTapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: EcardoBalanceHero(
            amount: 1000.0,
            showQuickActions: true,
            actions: [
              EcardoHeroAction(
                label: 'Send',
                icon: Icons.arrow_outward_rounded,
                onTap: () => sendTapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Send'), findsOneWidget);
      await tester.tap(find.text('Send'));
      await tester.pumpAndSettle();

      expect(sendTapped, isTrue);
    });
  });

  // =========================================================================
  // 3. ECARDO SWIPE BUTTON
  // =========================================================================
  group('EcardoSwipeButton Creative Tests', () {
    testWidgets('renders swipe track, label, and draggable thumb', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          child: EcardoSwipeButton(
            text: 'Slide to Transfer',
            animateShimmer: false,
            onSwipeComplete: () {},
          ),
        ),
      );

      expect(find.text('Slide to Transfer'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
    });

    testWidgets('swiping past threshold triggers onSwipeComplete', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          surfaceSize: const Size(360, 100),
          child: EcardoSwipeButton(
            text: 'Swipe to Pay',
            threshold: 0.8,
            animateShimmer: false,
            onSwipeComplete: () => completed = true,
          ),
        ),
      );

      final thumbFinder = find.byIcon(Icons.arrow_forward_rounded);
      expect(thumbFinder, findsOneWidget);

      // Drag 300px to the right to cross threshold
      await tester.drag(thumbFinder, const Offset(300, 0));
      await tester.pumpAndSettle();

      expect(completed, isTrue);
    });

    testWidgets('swiping below threshold snaps back without triggering complete', (tester) async {
      bool completed = false;

      await tester.pumpWidget(
        wrapWithTheme(
          surfaceSize: const Size(360, 100),
          child: EcardoSwipeButton(
            text: 'Swipe to Confirm',
            threshold: 0.85,
            animateShimmer: false,
            onSwipeComplete: () => completed = true,
          ),
        ),
      );

      final thumbFinder = find.byIcon(Icons.arrow_forward_rounded);

      // Drag only 40px (well below threshold) and release
      await tester.drag(thumbFinder, const Offset(40, 0));
      await tester.pumpAndSettle();

      expect(completed, isFalse);
    });

    testWidgets('displays loading state and success checkmark correctly', (tester) async {
      // Loading state
      await tester.pumpWidget(
        wrapWithTheme(
          child: EcardoSwipeButton(
            isLoading: true,
            loadingText: 'Broadcasting TX...',
            animateShimmer: false,
            onSwipeComplete: () {},
          ),
        ),
      );

      expect(find.text('Broadcasting TX...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Success state
      await tester.pumpWidget(
        wrapWithTheme(
          child: EcardoSwipeButton(
            isSuccess: true,
            successText: 'Payment Sent',
            animateShimmer: false,
            onSwipeComplete: () {},
          ),
        ),
      );

      expect(find.text('Payment Sent'), findsOneWidget);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });
  });

  // =========================================================================
  // 4. ECARDO DIGITAL RECEIPT
  // =========================================================================
  group('EcardoDigitalReceipt Creative Tests', () {
    testWidgets('renders ticket silhouette, header, amount, breakdown items, and watermark', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          surfaceSize: const Size(380, 800),
          child: const SingleChildScrollView(
            child: EcardoDigitalReceipt(
              title: 'Wire Transfer',
              transactionReference: 'ECAR-9901-XYZ',
              primaryAmount: 2500.0,
              primaryCurrency: 'USD',
              status: EcardoReceiptStatus.success,
              items: [
                EcardoReceiptItem(label: 'Beneficiary', value: 'Alex Mercer'),
                EcardoReceiptItem(label: 'Bank Fee', amount: 5.0, currency: 'USD'),
                EcardoReceiptItem(
                  label: 'Total Debited',
                  amount: 2505.0,
                  currency: 'USD',
                  isHighlighted: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('eCardo Receipt'), findsOneWidget);
      expect(find.text('Wire Transfer'), findsOneWidget);
      expect(find.text('ECAR-9901-XYZ'), findsNWidgets(2)); // in ref pill + barcode
      expect(find.text('2,500.00'), findsOneWidget);
      expect(find.text('Alex Mercer'), findsOneWidget);
      expect(find.text('Total Debited'), findsOneWidget);
      expect(find.text('PAID'), findsOneWidget); // Watermark stamp
    });

    testWidgets('tap on transaction reference triggers copy and displays floating feedback chip', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          child: const SingleChildScrollView(
            child: EcardoDigitalReceipt(
              title: 'Escrow Deposit',
              transactionReference: 'ECAR-5544-ABC',
            ),
          ),
        ),
      );

      expect(find.text('TRANSACTION REFERENCE'), findsOneWidget);

      // Tap reference code pill
      await tester.tap(find.text('TRANSACTION REFERENCE'));
      await tester.pump();

      // Floating chip appears
      expect(find.text('Ref ID Copied'), findsOneWidget);

      // Let timer expire cleanly
      await tester.pump(const Duration(milliseconds: 2000));
    });

    testWidgets('share and download action buttons execute callbacks', (tester) async {
      bool shared = false;
      bool downloaded = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: SingleChildScrollView(
            child: EcardoDigitalReceipt(
              title: 'Exchange Order',
              transactionReference: 'ECAR-1122-REF',
              onShare: () => shared = true,
              onDownload: () => downloaded = true,
            ),
          ),
        ),
      );

      expect(find.text('Share Receipt'), findsOneWidget);
      expect(find.text('Download PDF'), findsOneWidget);

      await tester.tap(find.text('Share Receipt'));
      await tester.pumpAndSettle();
      expect(shared, isTrue);

      await tester.tap(find.text('Download PDF'));
      await tester.pumpAndSettle();
      expect(downloaded, isTrue);
    });
  });

  // =========================================================================
  // 5. ECARDO EMPTY STATE & ERROR VIEW
  // =========================================================================
  group('EcardoEmptyState Creative Tests', () {
    testWidgets('renders orbital glowing icon, headline, and CTA actions', (tester) async {
      bool primaryTapped = false;
      bool secondaryTapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: EcardoEmptyState(
            title: 'No Invoices Found',
            description: 'Generate your first digital invoice to request instant settlement.',
            primaryActionLabel: 'Create Invoice',
            onPrimaryAction: () => primaryTapped = true,
            secondaryActionLabel: 'View Guide',
            onSecondaryAction: () => secondaryTapped = true,
            animateGlow: false,
          ),
        ),
      );

      expect(find.text('No Invoices Found'), findsOneWidget);
      expect(
        find.text('Generate your first digital invoice to request instant settlement.'),
        findsOneWidget,
      );
      expect(find.text('Create Invoice'), findsOneWidget);
      expect(find.text('View Guide'), findsOneWidget);

      await tester.tap(find.text('Create Invoice'));
      await tester.pumpAndSettle();
      expect(primaryTapped, isTrue);

      await tester.tap(find.text('View Guide'));
      await tester.pumpAndSettle();
      expect(secondaryTapped, isTrue);
    });
  });

  group('EcardoErrorView Creative Tests', () {
    testWidgets('renders pulsing radar glyph, error code badge, and triggers retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: EcardoErrorView(
            title: 'Gateway Connection Failed',
            message: 'Unable to reach the payment server. Please check your network.',
            errorCode: 'ERR_GATEWAY_TIMEOUT',
            onRetry: () => retried = true,
            retryLabel: 'Try Again',
            animatePulse: false,
          ),
        ),
      );

      expect(find.text('Gateway Connection Failed'), findsOneWidget);
      expect(find.text('ERR_GATEWAY_TIMEOUT'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      // Tap error code badge to copy
      await tester.tap(find.text('ERR_GATEWAY_TIMEOUT'));
      await tester.pump();
      expect(find.text('Code Copied'), findsOneWidget);

      // Wait for copy timer
      await tester.pump(const Duration(milliseconds: 1800));

      // Tap retry button
      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(retried, isTrue);
    });

    testWidgets('expands and collapses technical diagnostic accordion', (tester) async {
      await tester.pumpWidget(
        wrapWithTheme(
          child: const EcardoErrorView(
            title: 'API Error',
            message: 'Server responded with 500 status code.',
            technicalDetails: 'POST /v1/transfers: internal database dead-lock',
            animatePulse: false,
          ),
        ),
      );

      expect(find.text('View Diagnostics'), findsOneWidget);
      expect(find.text('POST /v1/transfers: internal database dead-lock'), findsNothing);

      // Expand diagnostics
      await tester.tap(find.text('View Diagnostics'));
      await tester.pumpAndSettle();

      expect(find.text('Hide Technical Details'), findsOneWidget);
      expect(find.text('POST /v1/transfers: internal database dead-lock'), findsOneWidget);
    });
  });
}
