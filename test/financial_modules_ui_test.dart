import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/commercial/screens/commercial_projects_screen.dart';
import 'package:ecardo_user/src/commercial/widgets/equity_project_card.dart';
import 'package:ecardo_user/src/commercial/widgets/investment_calculator_sheet.dart';
import 'package:ecardo_user/src/commercial/widgets/commercial_document_checklist.dart';
import 'package:ecardo_user/src/loan/widgets/loan_calculator_slider.dart';
import 'package:ecardo_user/src/escrow/screens/escrow_create_screen.dart';
import 'package:ecardo_user/src/escrow/controllers/escrow_controller.dart';
import 'package:ecardo_user/src/escrow/services/escrow_service.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/response/api_response.dart';

class _MockNetworkService extends GetxService implements NetworkService {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #get) {
      return Future.value(ApiResponse.completed(<String, dynamic>{'data': <String, dynamic>{}}));
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void phoneSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(750, 1624);
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
  }

  group('Commercial Modules UI/UX Tests', () {
    testWidgets('CommercialProjectsScreen renders tabs, projects and switching tabs without overflow', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(
            home: CommercialProjectsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Commercial & Equity Projects'), findsOneWidget);
      expect(find.text('Equity Projects'), findsOneWidget);
      expect(find.text('Corporate KYC'), findsOneWidget);

      // Equity crowdfunding is not live: the screen must say so before any
      // of the sample projects are shown.
      expect(find.text('Coming Soon'), findsOneWidget);
      expect(find.text('Equity crowdfunding is not available yet'), findsOneWidget);
      expect(find.textContaining('illustrative example, not a live offering'), findsOneWidget);

      // Verify Tab 2 switch
      await tester.tap(find.text('Corporate KYC'));
      await tester.pumpAndSettle();
      expect(find.text('Corporate KYC & Licensing Documents'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('EquityProjectCard renders project details, progress, and min ticket without overflow', (tester) async {
      phoneSurface(tester);
      const project = EquityProjectItem(
        id: 'eq-test',
        title: 'Very Long Commercial Infrastructure Project Name with Global Nodes',
        sector: 'Fintech & Payments Infrastructure',
        currency: 'USD',
        targetAmount: 1000000.0,
        raisedAmount: 750000.0,
        annualYieldPercent: 24.5,
        minInvestment: 5000.0,
        daysLeft: 15,
        location: 'Dubai Internet City, UAE',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EquityProjectCard(
                  project: project,
                  onInvestTap: () {},
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Fintech & Payments Infrastructure'), findsOneWidget);
      // The bare "24.5% p.a." is exactly the fabricated promise this test used
      // to lock in — it must now carry the illustrative label.
      expect(find.text('24.5% p.a.'), findsNothing);
      expect(find.text('Illustrative — 24.5% p.a.'), findsOneWidget);
      expect(find.text('75% funded'), findsNothing);
      expect(find.text('Sample progress'), findsOneWidget);
      // No live funding round exists, so no countdown may be shown.
      expect(find.text('15 days left'), findsNothing);
      expect(find.text('Sample project'), findsOneWidget);
      expect(find.text('Raised: USD 750.0K'), findsNothing);
      expect(find.text('Sample raised: USD 750.0K'), findsOneWidget);
      expect(find.text('Target: USD 1.0M'), findsNothing);
      expect(find.text('Sample target: USD 1.0M'), findsOneWidget);
      expect(find.text('Sample min. ticket'), findsOneWidget);
      expect(find.text('USD 5.0K'), findsOneWidget);
      // The CTA opens a preview, it does not place an order.
      expect(find.text('Preview'), findsOneWidget);
      expect(find.text('Invest Now'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('InvestmentCalculatorSheet opens, displays metrics, slider moves and confirms without overflow', (tester) async {
      phoneSurface(tester);
      const project = EquityProjectItem(
        id: 'eq-calc',
        title: 'Solar Energy Micro-Grid Phase 2',
        sector: 'Clean Energy',
        currency: 'USD',
        targetAmount: 500000.0,
        raisedAmount: 250000.0,
        annualYieldPercent: 20.0,
        minInvestment: 1000.0,
        daysLeft: 30,
        location: 'Antalya, Turkey',
      );

      double? confirmedAmount;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (ctx) => ElevatedButton(
                  onPressed: () {
                    InvestmentCalculatorSheet.show(
                      ctx,
                      project: project,
                      onConfirmed: (amt) => confirmedAmount = amt,
                    );
                  },
                  child: const Text('Open Sheet'),
                ),
              ),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      // Check contents
      expect(find.text('Investment Calculator'), findsOneWidget);
      expect(find.text('20.0% Yield'), findsNothing);
      expect(find.text('Illustrative — 20.0% Yield'), findsOneWidget);
      expect(find.text('Solar Energy Micro-Grid Phase 2'), findsOneWidget);
      expect(find.text('USD 2K'), findsOneWidget);
      expect(find.text('Sample monthly dividend'), findsOneWidget);
      expect(find.text('Sample annual return'), findsOneWidget);
      // The sheet itself must carry the "not available yet" notice.
      expect(find.textContaining('illustrative example only'), findsOneWidget);

      // Interest button — NOT "Confirm & Invest", which claimed a transaction
      // that never reaches a server.
      final confirmBtn = find.text('Register My Interest');
      expect(confirmBtn, findsOneWidget);
      expect(find.text('Confirm & Invest with eCardo Wallet'), findsNothing);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(confirmedAmount, isNotNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets('CommercialDocumentChecklist renders statuses and reacts to upload tap without overflow', (tester) async {
      phoneSurface(tester);
      final docs = [
        CommercialDocumentItem(
          id: 'doc-1',
          title: 'Commercial Gazette Registration Certificate',
          description: 'Official corporate registration documentation',
          isMandatory: true,
          status: DocumentVerificationStatus.verified,
          fileName: 'Gazette_2026.pdf',
        ),
        CommercialDocumentItem(
          id: 'doc-2',
          title: 'Board of Directors Resolution',
          description: 'Authorized signatories resolution',
          isMandatory: true,
          status: DocumentVerificationStatus.underReview,
        ),
        CommercialDocumentItem(
          id: 'doc-3',
          title: 'Tax Compliance Certificate',
          description: 'Clearance certificate from revenue authority',
          isMandatory: false,
          status: DocumentVerificationStatus.required,
        ),
      ];

      CommercialDocumentItem? tappedDoc;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CommercialDocumentChecklist(
                  documents: docs,
                  onUploadTap: (d) => tappedDoc = d,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('1/3'), findsOneWidget);
      expect(find.text('Commercial Gazette Registration Certificate'), findsOneWidget);
      expect(find.text('Uploaded: Gazette_2026.pdf'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('Under Review'), findsOneWidget);
      expect(find.text('Required'), findsOneWidget);

      await tester.tap(find.text('Required'));
      await tester.pump();
      expect(tappedDoc?.id, 'doc-3');
      expect(tester.takeException(), isNull);
    });
  });

  group('LoanCalculatorSlider UI/UX Tests', () {
    testWidgets('LoanCalculatorSlider formats USD badges, thousands commas, and computes metrics with no jumps', (tester) async {
      phoneSurface(tester);
      double? currentAmount;
      int? currentMonths;
      int? currentGrace;
      double? currentMonthly;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LoanCalculatorSlider(
                  initialAmount: 25000.0,
                  initialMonths: 12,
                  initialGraceMonths: 0,
                  minAmount: 1000.0,
                  maxAmount: 100000.0,
                  stepAmount: 1000.0,
                  annualInterestRate: 15.0,
                  currency: 'USD',
                  quickAmounts: const [5000.0, 10000.0, 25000.0, 50000.0],
                  onPlanChanged: (amt, mo, grace, pmt) {
                    currentAmount = amt;
                    currentMonths = mo;
                    currentGrace = grace;
                    currentMonthly = pmt;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // USD currency badge
      expect(find.text(r'USD ($)'), findsOneWidget);
      // Formatted with commas
      expect(find.text('25,000'), findsOneWidget);
      expect(currentAmount, 25000.0);
      expect(currentMonths, 12);
      expect(currentGrace, 0);
      expect(currentMonthly, greaterThan(0));

      // Tap quick amount chip
      final chip50k = find.text(r'$50k');
      expect(chip50k, findsOneWidget);
      await tester.tap(chip50k);
      await tester.pumpAndSettle();

      expect(find.text('50,000'), findsOneWidget);
      expect(currentAmount, 50000.0);

      // Tap term chip 24
      final term24 = find.text('24 Mo');
      expect(term24, findsOneWidget);
      await tester.tap(term24);
      await tester.pumpAndSettle();

      expect(currentMonths, 24);

      // Tap grace period chip 2
      final grace2 = find.text('2 Mo');
      expect(grace2, findsOneWidget);
      await tester.tap(grace2);
      await tester.pumpAndSettle();

      expect(currentGrace, 2);
      expect(find.textContaining('Grace monthly payment'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('LoanCalculatorSlider formats IRR badges, handles Rial numbers and no layout jumps', (tester) async {
      phoneSurface(tester);
      double? currentAmount;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: LoanCalculatorSlider(
                  initialAmount: 50000000.0,
                  minAmount: 5000000.0,
                  maxAmount: 500000000.0,
                  stepAmount: 1000000.0,
                  annualInterestRate: 18.0,
                  currency: 'IRR',
                  onPlanChanged: (amt, mo, grace, pmt) {
                    currentAmount = amt;
                  },
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // IRR currency badge
      expect(find.textContaining('IRR'), findsWidgets);
      // Formatted with commas
      expect(find.text('50,000,000'), findsOneWidget);
      expect(currentAmount, 50000000.0);
      expect(tester.takeException(), isNull);
    });
  });

  group('EscrowCreateScreen UI/UX Tests', () {
    setUp(() {
      Get.reset();
      Get.put<NetworkService>(_MockNetworkService());
      Get.put<EscrowService>(EscrowService());
      Get.put<EscrowController>(EscrowController());
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('EscrowCreateScreen renders fields, role choice chips, currency dropdown and fee payer radios', (tester) async {
      phoneSurface(tester);

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const GetMaterialApp(
            home: EscrowCreateScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and fields
      expect(find.text('New Escrow Deal'), findsOneWidget);
      expect(find.text('Seller'), findsWidgets);
      expect(find.text('Buyer'), findsWidgets);
      expect(find.text('Save Draft'), findsOneWidget);

      // Tap Buyer role chip
      await tester.tap(find.text('Buyer').first);
      await tester.pumpAndSettle();

      // Tap 50/50 fee payer radio
      final radio5050 = find.text('50/50');
      expect(radio5050, findsOneWidget);
      await tester.ensureVisible(radio5050);
      await tester.tap(radio5050);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
