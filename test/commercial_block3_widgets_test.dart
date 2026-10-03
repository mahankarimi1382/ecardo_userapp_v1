import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ecardo_user/l10n/app_localizations.dart';
import 'package:ecardo_user/src/commercial/screens/commercial_projects_screen.dart';
import 'package:ecardo_user/src/commercial/widgets/equity_project_card.dart';
import 'package:ecardo_user/src/loan/widgets/loan_calculator_slider.dart';
import 'package:ecardo_user/src/guarantee/widgets/guarantee_collateral_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // These widgets are laid out by ScreenUtil against a 375x812 design size.
  // flutter_test's default 800x600 surface scales every .w/.sp by
  // 800/375 = 2.13x, which overflows the equity-project rows and the
  // document-checklist rows. Pump at the design size instead (same trick as
  // dashboard_services_qc_test).
  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  group('CommercialProjectsScreen', () {
    testWidgets('renders commercial projects screen with tabs and equity projects', (tester) async {
      phoneSurface(tester);

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

      // Equity crowdfunding has not launched. The screen must announce this
      // before any sample project is presented as an offer.
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('Equity crowdfunding is not available yet'), findsOneWidget);
      expect(find.textContaining('not a promise of return'), findsOneWidget);

      // Verify equity projects rendered
      expect(find.textContaining('eCardo Regional Remittance Node'), findsOneWidget);
      expect(find.text('Preview'), findsWidgets);
      // Sample yields must never appear as a bare, quotable figure.
      expect(find.text('26.5% p.a.'), findsNothing);
      expect(find.text('Illustrative — 26.5% p.a.'), findsOneWidget);
      expect(find.text('Invest Now'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('switches to Corporate KYC tab and displays document checklist', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: CommercialProjectsScreen(),
          ),
        ),
      );

      // Tap on Corporate KYC tab
      final kycTab = find.text('Corporate KYC');
      await tester.ensureVisible(kycTab);
      await tester.pumpAndSettle();
      await tester.tap(kycTab);
      await tester.pumpAndSettle();

      // Verify document checklist headers and items
      expect(find.text('Corporate KYC & Licensing Documents'), findsOneWidget);
      expect(find.textContaining('Official Commercial Gazette'), findsOneWidget);
      expect(find.textContaining('Board of Directors Resolution'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('EquityProjectCard', () {
    testWidgets('computes funding progress ratio and handles invest click', (tester) async {
      bool investTapped = false;
      phoneSurface(tester);
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
      expect(find.text('50% funded'), findsNothing);
      expect(find.text('Sample progress'), findsOneWidget);
      // "20.0% p.a." on its own was a live-looking yield promise for a project
      // with no funding round. It now has to carry the illustrative prefix.
      expect(find.text('20.0% p.a.'), findsNothing);
      expect(find.text('Illustrative — 20.0% p.a.'), findsOneWidget);

      await tester.tap(find.text('Preview'));
      await tester.pump();

      expect(investTapped, true);
    });
  });

  group('LoanCalculatorSlider', () {
    testWidgets('renders loan amount bounds, term options, and grace period options', (tester) async {
      phoneSurface(tester);

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
      // The collateral titles come from GuaranteeCollateralType.titleFa via
      // l10nPick, which resolves against Localizations.localeOf(context).
      // Without an explicit fa locale the host falls back to en and the card
      // correctly renders the English titles — so this test has to pump a
      // real Persian locale to exercise the Persian branch.
      tester.view.physicalSize = const Size(750, 1624);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          // Collateral copy is verified in Persian (titleFa), so pin the
          // harness locale to fa — the default test locale is en.
          builder: (context, child) => MaterialApp(
            locale: const Locale('fa'),
<<<<<<< HEAD
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
=======
            supportedLocales: const [Locale('en'), Locale('fa')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
>>>>>>> origin/main
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
      // The English title is the locale-fallback branch and must not render
      // alongside the Persian one.
      expect(find.text('Cash Deposit (Escrow)'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}
