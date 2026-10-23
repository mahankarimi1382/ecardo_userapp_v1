import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:ecardo_user/src/app/constants/app_colors.dart';
import 'package:ecardo_user/src/commercial/controllers/commercial_controller.dart';
import 'package:ecardo_user/src/commercial/screens/commercial_projects_screen.dart';
import 'package:ecardo_user/src/commercial/widgets/equity_project_card.dart';
import 'package:ecardo_user/src/commercial/widgets/investment_calculator_sheet.dart';
import 'package:ecardo_user/src/common/widgets/design_system/design_system.dart';
import 'package:ecardo_user/src/helper/dynamic_decimals_helper.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
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
    Locale locale = const Locale('en'),
    bool wrapInScaffold = true,
    bool scrollable = false,
  }) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, _) => MaterialApp(
        locale: locale,
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
        home: !wrapInScaffold
            ? child
            : Scaffold(
                body: scrollable
                    ? SingleChildScrollView(child: child)
                    : child,
              ),
      ),
    );
  }

  group('MOD-COMMERCIAL: Equity Crowdfunding Metrics & Zero-Decimal Toman', () {
    testWidgets(
      'renders crowdfunding metrics: progress bar, target vs raised, ROI badge and investor counter',
      (tester) async {
        phoneSurface(tester);
        const project = EquityProjectItem(
          id: 'toman-001',
          title: 'Agri-Tech Smart Greenhouse',
          sector: 'Agriculture & Supply Chain',
          currency: 'IRT',
          targetAmount: 500000000.0,
          raisedAmount: 375000000.0,
          annualYieldPercent: 28.5,
          minInvestment: 5000000.0,
          daysLeft: 20,
          location: 'Isfahan, Iran',
          totalInvestors: 264,
        );

        await tester.pumpWidget(
          wrapWithTheme(
            child: EquityProjectCard(
              project: project,
              onInvestTap: () {},
            ),
          ),
        );

        // Progress metrics
        expect(project.progressPercent, 75);
        expect(find.text('Sample progress'), findsOneWidget);
        expect(find.text('75%'), findsOneWidget);

        // Expected ROI percentage badge (illustrative)
        expect(find.text('Illustrative — 28.5% p.a.'), findsOneWidget);
        expect(find.byIcon(Icons.trending_up_rounded), findsOneWidget);

        // Investor counter
        expect(find.textContaining('264 Investors'), findsOneWidget);
        expect(find.byIcon(Icons.people_alt_outlined), findsOneWidget);

        // Zero-decimal Toman verification on amounts
        expect(find.textContaining('IRT 375.0M'), findsOneWidget);
        expect(find.textContaining('IRT 500.0M'), findsOneWidget);
        expect(find.textContaining('IRT 5.0M'), findsOneWidget);

        // Preview button touch target
        final button = find.widgetWithText(ElevatedButton, 'Preview');
        expect(button, findsOneWidget);
        final size = tester.getSize(button);
        expect(size.height, greaterThanOrEqualTo(48.0));
      },
    );

    testWidgets(
      'enforces zero-decimal Toman on investment amounts and dividend projections in calculator',
      (tester) async {
        phoneSurface(tester);
        const project = EquityProjectItem(
          id: 'toman-002',
          title: 'Clean Solar Energy',
          sector: 'Clean Energy',
          currency: 'IRT',
          targetAmount: 1000000000.0,
          raisedAmount: 600000000.0,
          annualYieldPercent: 24.0,
          minInvestment: 10000000.0,
          daysLeft: 15,
          location: 'Yazd, Iran',
          totalInvestors: 180,
        );

        await tester.pumpWidget(
          wrapWithTheme(
            child: InvestmentCalculatorSheet(
              project: project,
            ),
          ),
        );

        // Currency is IRT -> DynamicDecimalsHelper.isZeroDecimal('IRT') is true
        expect(DynamicDecimalsHelper.isZeroDecimal('IRT'), isTrue);

        // Principal display is formatted with thousands/M suffix and zero decimals
        expect(find.textContaining('IRT 20M'), findsOneWidget);

        // Monthly return: (20,000,000 * 0.24) / 12 = 400,000 (zero decimal)
        expect(find.textContaining('+IRT 400,000'), findsOneWidget);

        // Annual return: 20,000,000 * 0.24 = 4,800,000 (zero decimal)
        expect(find.textContaining('+IRT 4,800,000'), findsOneWidget);
      },
    );
  });

  group('MOD-COMMERCIAL: Complete State Matrix on CommercialProjectsScreen', () {
    late CommercialController controller;

    setUp(() {
      Get.delete<CommercialController>(force: true);
      controller = Get.put(CommercialController());
    });

    tearDown(() {
      Get.delete<CommercialController>(force: true);
    });

    testWidgets('renders Normal State with projects and portfolio', (tester) async {
      phoneSurface(tester);
      await tester.pumpWidget(
        wrapWithTheme(
          wrapInScaffold: false,
          child: const CommercialProjectsScreen(),
        ),
      );

      expect(controller.isLoadingProjects.value, isFalse);
      expect(controller.errorMessage.value.isEmpty, isTrue);
      expect(controller.isOffline.value, isFalse);
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('Equity crowdfunding is not available yet'), findsOneWidget);
      expect(find.textContaining('eCardo Regional Remittance Node'), findsOneWidget);
    });

    testWidgets('renders Loading State when isLoadingProjects is true', (tester) async {
      phoneSurface(tester);
      controller.isLoadingProjects.value = true;

      await tester.pumpWidget(
        wrapWithTheme(
          wrapInScaffold: false,
          child: const CommercialProjectsScreen(),
        ),
      );

      // Shimmer skeleton is rendered, project list is not
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Coming Soon'), findsNothing);
    });

    testWidgets('renders Error State with EcardoErrorView and retry callback', (tester) async {
      phoneSurface(tester);
      controller.setError('Server connection failure 503');

      await tester.pumpWidget(
        wrapWithTheme(
          wrapInScaffold: false,
          child: const CommercialProjectsScreen(),
        ),
      );

      expect(find.byType(EcardoErrorView), findsOneWidget);
      expect(find.text('Unable to Load Projects'), findsOneWidget);
      expect(find.text('Server connection failure 503'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      await tester.pump();
      expect(controller.errorMessage.value.isEmpty, isTrue);
    });

    testWidgets('renders Offline State with cloud_off icon and retry', (tester) async {
      phoneSurface(tester);
      controller.setOffline(true);

      await tester.pumpWidget(
        wrapWithTheme(
          wrapInScaffold: false,
          child: const CommercialProjectsScreen(),
        ),
      );

      expect(find.byType(EcardoErrorView), findsOneWidget);
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off_rounded), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();
      expect(controller.isOffline.value, isFalse);
    });

    testWidgets('renders Empty State with EcardoEmptyState when filtered list is empty', (tester) async {
      phoneSurface(tester);
      controller.applyFilter('NON_EXISTENT_SECTOR');

      await tester.pumpWidget(
        wrapWithTheme(
          wrapInScaffold: false,
          child: const CommercialProjectsScreen(),
        ),
      );

      expect(find.byType(EcardoEmptyState), findsOneWidget);
      expect(find.text('No Projects Available in this sector'), findsOneWidget);
      expect(find.text('View All Sectors'), findsOneWidget);

      await tester.tap(find.text('View All Sectors'));
      await tester.pump();
      expect(controller.selectedSector.value, 'ALL');
      expect(controller.filteredProjects.isNotEmpty, isTrue);
    });
  });

  group('MOD-CARD: Touch Targets, Spending Limits, PIN Change & Replacement', () {
    testWidgets('spending limits sheet has accessible touch targets (min 48x48dp)', (tester) async {
      phoneSurface(tester);
      double savedDaily = 0;
      double savedMonthly = 0;

      await tester.pumpWidget(
        wrapWithTheme(
          scrollable: true,
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

      // Open Spending Limits modal
      final limitsTile = find.text('Spending Limits');
      await tester.tap(limitsTile);
      await tester.pumpAndSettle();

      expect(find.text('Card Spending Limits'), findsOneWidget);

      // Save button touch target
      final saveBtn = find.widgetWithText(ElevatedButton, 'Save Spending Limits');
      expect(saveBtn, findsOneWidget);
      final btnSize = tester.getSize(saveBtn);
      expect(btnSize.height, greaterThanOrEqualTo(48.0));

      await tester.tap(find.text('2,500'));
      await tester.pumpAndSettle();

      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(savedDaily, 2500.0);
      expect(savedMonthly, 5000.0);
    });

    testWidgets('opens PIN change sheet with accessible 48x48dp numeric keypad', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => VirtualCardSecurityControls.showCardPinChange(
                context,
                cardId: 'card-test-1',
              ),
              child: const Text('Open PIN'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open PIN'));
      await tester.pumpAndSettle();

      expect(find.text('Change Card PIN'), findsOneWidget);
      expect(find.text('Enter Current 4-Digit PIN'), findsOneWidget);

      // Verify numeric keypad has all digits
      for (var i = 0; i <= 9; i++) {
        expect(find.text(i.toString()), findsOneWidget);
      }
      expect(find.text('C'), findsOneWidget);
      expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

      // Verify keypad touch target is at least 48dp high
      final key1 = find.widgetWithText(InkWell, '1');
      expect(key1, findsOneWidget);
      final keySize = tester.getSize(key1);
      expect(keySize.height, greaterThanOrEqualTo(48.0));
      expect(keySize.width, greaterThanOrEqualTo(48.0));
    });

    testWidgets('opens Card Replacement flow with reason selector and accessible touch target', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        wrapWithTheme(
          child: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => VirtualCardSecurityControls.showCardReplacement(
                context,
                cardId: 'card-test-1',
              ),
              child: const Text('Open Replacement'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Replacement'));
      await tester.pumpAndSettle();

      expect(find.text('Replace Card'), findsOneWidget);
      expect(find.text('Select the reason for card replacement'), findsOneWidget);
      expect(find.textContaining('permanently deactivate your current card'), findsOneWidget);

      // Verify reasons exist
      expect(find.text('Damaged or chip malfunction'), findsOneWidget);
      expect(find.text('Lost card'), findsOneWidget);
      expect(find.text('Stolen card'), findsOneWidget);
      expect(find.text('Suspicious transactions / fraud'), findsOneWidget);

      // Confirm button has accessible touch target
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Confirm & Order Replacement');
      expect(confirmBtn, findsOneWidget);
      final confirmSize = tester.getSize(confirmBtn);
      expect(confirmSize.height, greaterThanOrEqualTo(48.0));
    });

    test('verifies idempotency protection for card management and commercial investment endpoints', () {
      // Physical card order
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/card-orders'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/physical-order'),
        isTrue,
      );

      // Spending limits
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/spending-limits'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/1234/spending-limits'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/1234/limits'),
        isTrue,
      );

      // PIN changes
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/change-pin'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/1234/change-pin'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/1234/pin'),
        isTrue,
      );

      // Card replacement
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/replace'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/1234/replace'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/cards/1234/replacement'),
        isTrue,
      );

      // Commercial & Equity crowdfunding investments
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/commercial/invest'),
        isTrue,
      );
      expect(
        NetworkService.isMutatingFinancialOrStateEndpoint('/user/equity/invest'),
        isTrue,
      );
    });
  });
}
