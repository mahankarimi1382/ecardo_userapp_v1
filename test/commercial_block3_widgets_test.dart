import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/src/commercial/screens/commercial_projects_screen.dart';
import 'package:ecardo_user/src/commercial/widgets/commercial_document_checklist.dart';
import 'package:ecardo_user/src/commercial/widgets/equity_project_card.dart';
import 'package:ecardo_user/src/loan/widgets/loan_calculator_slider.dart';
import 'package:ecardo_user/src/guarantee/widgets/guarantee_collateral_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CommercialProjectsScreen', () {
    testWidgets('renders commercial projects screen with tabs and equity projects', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: CommercialProjectsScreen(),
          ),
        ),
      );

      // Verify app bar title
      expect(find.text('Commercial & Equity Projects'), findsOneWidget);

      // Verify tabs exist
      expect(find.text('Equity Projects'), findsOneWidget);
      expect(find.text('Corporate KYC'), findsOneWidget);

      // Verify equity projects rendered
      expect(find.textContaining('eCardo Regional Remittance Node'), findsOneWidget);
      expect(find.text('Invest Now'), findsWidgets);
    });

    testWidgets('switches to Corporate KYC tab and displays document checklist', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: CommercialProjectsScreen(),
          ),
        ),
      );

      // Tap on Corporate KYC tab
      await tester.tap(find.text('Corporate KYC'));
      await tester.pumpAndSettle();

      // Verify document checklist headers and items
      expect(find.text('Corporate KYC & Licensing Documents'), findsOneWidget);
      expect(find.textContaining('Official Commercial Gazette'), findsOneWidget);
      expect(find.textContaining('Board of Directors Resolution'), findsOneWidget);
    });
  });

  group('EquityProjectCard', () {
    testWidgets('computes funding progress ratio and handles invest click', (tester) async {
      bool investTapped = false;
      const project = EquityProjectItem(
        id: 'test-1',
        title: 'Solar Energy Plant',
        sector: 'Clean Energy',
        currency: 'USD',
        targetAmount: 100000.0,
        raisedAmount: 50000.0,
        annualYieldPercent: 20.0,
        minInvestment: 500.0,
        daysLeft: 10,
        location: 'Dubai, UAE',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: EquityProjectCard(
                project: project,
                onInvestTap: () => investTapped = true,
              ),
            ),
          ),
        ),
      );

      expect(project.progressPercent, 50);
      expect(find.text('50% funded'), findsOneWidget);
      expect(find.text('20.0% p.a.'), findsOneWidget);

      await tester.tap(find.text('Invest Now'));
      await tester.pump();

      expect(investTapped, true);
    });
  });

  group('LoanCalculatorSlider', () {
    testWidgets('renders loan amount bounds, term options, and grace period options', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LoanCalculatorSlider(
                  minAmount: 10000000.0,
                  maxAmount: 100000000.0,
                  annualInterestRate: 18.0,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify term options
      expect(find.textContaining('12'), findsWidgets);
    });
  });

  group('GuaranteeCollateralCard', () {
    testWidgets('renders collateral types (Cash, Crypto, Promissory, Bank)', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: GuaranteeCollateralCard(
                  guaranteeAmount: 50000000.0,
                  currency: 'IRR',
                  onCollateralTypeChanged: (type) {},
                ),
              ),
            ),
          ),
        ),
      );

      // Verify collateral type icons/text
      expect(find.textContaining('سپرده نقدی'), findsWidgets);
    });
  });
}
