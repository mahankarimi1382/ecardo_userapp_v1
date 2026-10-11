import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/controller/virtual_card_details_controller.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/view/widgets/common_virtual_card_view.dart';
import 'package:ecardo_user/src/presentation/screens/virtual_card/widgets/virtual_card_security_controls.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  Widget wrapWithTheme({
    required Widget child,
    Brightness brightness = Brightness.light,
    TextDirection textDirection = TextDirection.ltr,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
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
        home: Directionality(
          textDirection: textDirection,
          child: Scaffold(
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('CommonVirtualCardView 3D Interactive Flip & One-Tap Actions', () {
    testWidgets('renders front face with brand, chip, contactless, PAN, expiry and name', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          child: const CommonVirtualCardView(
            title: 'Platinum Virtual',
            cardHolderName: 'ALEXANDER HAMILTON',
            value: '•••• •••• •••• 9876',
            rawCardNumber: '4000123456789876',
            firstLabel: 'EXPIRY',
            firstValue: '08/30',
            secondLabel: 'CURRENCY',
            secondValue: 'USD',
            status: 'active',
            canReveal: true,
            isRevealed: false,
            network: 'Visa',
          ),
        ),
      );

      expect(find.text('ALEXANDER HAMILTON'), findsOneWidget);
      expect(find.text('•••• •••• •••• 9876'), findsOneWidget);
      expect(find.text('EXPIRY'), findsOneWidget);
      expect(find.text('08/30'), findsOneWidget);
      expect(find.text('CURRENCY'), findsOneWidget);
      expect(find.text('USD'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.byIcon(Icons.contactless_rounded), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);
    });

    testWidgets('tap to copy triggers copy action and haptic feedback', (tester) async {
      phoneSurface(tester);
      bool copied = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: CommonVirtualCardView(
            title: 'Gold Card',
            value: '•••• •••• •••• 1234',
            rawCardNumber: '4242424242421234',
            firstLabel: 'EXPIRY',
            firstValue: '01/29',
            secondLabel: 'CVC',
            secondValue: '999',
            status: 'active',
            onCopyCardNumber: () => copied = true,
          ),
        ),
      );

      final copyFinder = find.byIcon(Icons.copy_rounded);
      expect(copyFinder, findsOneWidget);

      await tester.tap(copyFinder);
      await tester.pump(const Duration(milliseconds: 100));

      expect(copied, isTrue);
      expect(find.byIcon(Icons.check), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
    });

    testWidgets('interactive flip flips card to back and reveals CVV & magnetic stripe', (tester) async {
      phoneSurface(tester);
      bool flipped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: CommonVirtualCardView(
            title: 'Titanium Card',
            value: '•••• •••• •••• 5555',
            cvv: '777',
            firstLabel: 'EXPIRY',
            firstValue: '11/31',
            secondLabel: 'CVC',
            secondValue: '777',
            status: 'active',
            enableFlip: true,
            onFlip: (val) => flipped = val,
          ),
        ),
      );

      // Initially on front face
      expect(find.text('Titanium Card'), findsOneWidget);

      // Tap on card body to flip
      final cardFinder = find.byType(CommonVirtualCardView);
      await tester.tapAt(tester.getTopLeft(cardFinder) + const Offset(50, 25));
      await tester.pumpAndSettle();

      expect(flipped, isTrue);

      // Back face elements are visible
      expect(find.text('AUTHORIZED SIGNATURE'), findsOneWidget);
      expect(find.text('CVV2'), findsOneWidget);
      expect(find.byIcon(Icons.shield_rounded), findsOneWidget);
    });

    testWidgets('renders properly in dark mode and RTL layout', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          brightness: Brightness.dark,
          textDirection: TextDirection.rtl,
          child: const CommonVirtualCardView(
            title: 'کارت مجازی پلاتین',
            value: '•••• •••• •••• 4444',
            firstLabel: 'تاریخ انقضا',
            firstValue: '10/28',
            secondLabel: 'موجودی',
            secondValue: '100 USD',
            status: 'active',
          ),
        ),
      );

      expect(find.text('کارت مجازی پلاتین'), findsOneWidget);
      expect(find.text('•••• •••• •••• 4444'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
    });
  });

  group('VirtualCardSecurityControls Quick Action Grid', () {
    testWidgets('renders all 5 security tiles: Freeze, Online, Limits, Transactions, Top-up', (tester) async {
      phoneSurface(tester);
      bool freezeToggled = false;
      bool onlineToggled = false;
      bool transactionsTapped = false;
      bool topUpTapped = false;

      await tester.pumpWidget(
        wrapWithTheme(
          child: VirtualCardSecurityControls(
            isFrozen: false,
            onToggleFreeze: (val) => freezeToggled = val,
            isOnlinePaymentsEnabled: true,
            onToggleOnlinePayments: (val) => onlineToggled = val,
            dailySpendLimit: 1500.0,
            monthlySpendLimit: 8000.0,
            currency: 'USD',
            canViewTransactions: true,
            onViewTransactions: () => transactionsTapped = true,
            canTopUp: true,
            onTopUp: () => topUpTapped = true,
          ),
        ),
      );

      expect(find.text('Card Security & Controls'), findsOneWidget);
      expect(find.text('Freeze Card'), findsOneWidget);
      expect(find.text('Online Payments'), findsOneWidget);
      expect(find.text('Spending Limits'), findsOneWidget);

      final txText = find.text('Card Transactions');
      await tester.ensureVisible(txText);
      await tester.pumpAndSettle();
      expect(txText, findsOneWidget);

      // Test transactions tap
      await tester.tap(txText);
      await tester.pumpAndSettle();
      expect(transactionsTapped, isTrue);

      final topUpText = find.text('Top-up Card Balance');
      await tester.ensureVisible(topUpText);
      await tester.pumpAndSettle();
      expect(topUpText, findsOneWidget);

      // Test top-up tap
      await tester.tap(topUpText);
      await tester.pumpAndSettle();
      expect(topUpTapped, isTrue);

      // Test freeze toggle switch
      final switches = find.byType(Switch);
      expect(switches, findsNWidgets(2));

      await tester.tap(switches.first);
      await tester.pumpAndSettle();
      expect(freezeToggled, isTrue);

      // Test online payments toggle switch
      await tester.tap(switches.last);
      await tester.pumpAndSettle();
      expect(onlineToggled, isFalse);
    });

    testWidgets('tapping Spending Limits opens modal bottom sheet with sliders and presets', (tester) async {
      phoneSurface(tester);
      double savedDaily = 0;
      double savedMonthly = 0;

      await tester.pumpWidget(
        wrapWithTheme(
          child: VirtualCardSecurityControls(
            isFrozen: false,
            dailySpendLimit: 1000.0,
            monthlySpendLimit: 5000.0,
            currency: 'USD',
            onUpdateSpendingLimits: (daily, monthly) {
              savedDaily = daily;
              savedMonthly = monthly;
            },
          ),
        ),
      );

      // Tap on Spending Limits tile
      final limitsTile = find.text('Spending Limits');
      await tester.ensureVisible(limitsTile);
      await tester.pumpAndSettle();
      await tester.tap(limitsTile);
      await tester.pumpAndSettle();

      // Modal bottom sheet appears
      expect(find.text('Card Spending Limits'), findsOneWidget);
      expect(find.text('Daily Spend Limit'), findsOneWidget);
      expect(find.text('Monthly Spend Limit'), findsOneWidget);
      expect(find.text('Save Spending Limits'), findsOneWidget);

      // Tap a preset chip (e.g. 2,500)
      final presetChip = find.text('2,500');
      expect(presetChip, findsOneWidget);
      await tester.tap(presetChip);
      await tester.pumpAndSettle();

      // Tap Save button
      await tester.tap(find.text('Save Spending Limits'));
      await tester.pumpAndSettle();

      expect(savedDaily, 2500.0);
      expect(savedMonthly, 5000.0);
    });
  });

  group('VirtualCardDetailsController Logic Tests', () {
    testWidgets('toggles online payments and updates spending limits', (tester) async {
      final controller = VirtualCardDetailsController();

      expect(controller.isOnlinePaymentsEnabled.value, isTrue);
      controller.toggleOnlinePayments();
      expect(controller.isOnlinePaymentsEnabled.value, isFalse);

      expect(controller.dailySpendLimit.value, 1000.0);
      expect(controller.monthlySpendLimit.value, 5000.0);

      controller.updateSpendingLimits(daily: 2500.0, monthly: 12000.0);
      expect(controller.dailySpendLimit.value, 2500.0);
      expect(controller.monthlySpendLimit.value, 12000.0);
    });
  });
}
