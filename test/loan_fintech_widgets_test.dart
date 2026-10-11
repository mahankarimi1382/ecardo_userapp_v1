import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:ecardo_user/src/loan/controllers/loan_controller.dart';
import 'package:ecardo_user/src/loan/services/loan_service.dart';
import 'package:ecardo_user/src/loan/widgets/loan_calculator_slider.dart';
import 'package:ecardo_user/src/loan/widgets/loan_amortization_schedule.dart';
import 'package:ecardo_user/src/loan/widgets/loan_status_stepper.dart';
import 'package:ecardo_user/src/network/service/network_service.dart';
import 'package:ecardo_user/src/network/service/token_service.dart';

Widget _buildTestHarness({
  required Widget child,
  bool isDark = false,
  Locale locale = const Locale('fa'),
  TextDirection direction = TextDirection.rtl,
}) {
  return ScreenUtilInit(
    designSize: const Size(400, 900),
    minTextAdapt: true,
    builder: (context, _) => GetMaterialApp(
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      locale: locale,
      supportedLocales: const [
        Locale('en'),
        Locale('fa'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: SingleChildScrollView(
            child: SizedBox(
              width: 400,
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.put<TokenService>(TokenService());
    Get.put<NetworkService>(NetworkService());
    Get.put<LoanApiService>(LoanApiService());
    Get.put<LoanController>(LoanController());
  });

  tearDown(Get.reset);

  group('LoanCalculatorSlider Tests', () {
    testWidgets('renders amount and duration sliders, presets, and live metrics', (tester) async {
      double? changedAmount;
      int? changedMonths;
      double? changedMonthlyPayment;

      await tester.pumpWidget(_buildTestHarness(
        child: LoanCalculatorSlider(
          initialAmount: 10000,
          initialMonths: 12,
          minAmount: 500,
          maxAmount: 50000,
          annualInterestRate: 14.0,
          presetDurations: const [3, 6, 12, 24],
          onPlanChanged: (amt, months, grace, payment) {
            changedAmount = amt;
            changedMonths = months;
            changedMonthlyPayment = payment;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Sliders should exist (2 Slider widgets: amount & duration)
      expect(find.byType(Slider), findsNWidgets(2));

      // Preset duration chips: 3, 6, 12, 24
      expect(find.textContaining('3'), findsWidgets);
      expect(find.textContaining('6'), findsWidgets);
      expect(find.textContaining('12'), findsWidgets);
      expect(find.textContaining('24'), findsWidgets);

      // Metric display labels
      expect(find.textContaining('قسط ماهانه'), findsOneWidget);
      expect(find.textContaining('کل سود'), findsOneWidget);
      expect(find.textContaining('کل بازپرداخت'), findsOneWidget);
      expect(find.textContaining('APR'), findsOneWidget);

      // Initial callback check
      expect(changedAmount, equals(10000.0));
      expect(changedMonths, equals(12));
      expect(changedMonthlyPayment, isNotNull);
      expect(changedMonthlyPayment!, greaterThan(0));
    });

    testWidgets('tapping preset duration chip updates duration', (tester) async {
      int? currentMonths;

      await tester.pumpWidget(_buildTestHarness(
        child: LoanCalculatorSlider(
          initialAmount: 10000,
          initialMonths: 12,
          minAmount: 500,
          maxAmount: 50000,
          annualInterestRate: 14.0,
          presetDurations: const [3, 6, 12, 24],
          onPlanChanged: (amt, months, grace, payment) {
            currentMonths = months;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Tap 6-month preset chip
      final chip6 = find.text('6 ماهه');
      expect(chip6, findsOneWidget);
      await tester.tap(chip6);
      await tester.pumpAndSettle();
      expect(currentMonths, equals(6));
    });
  });

  group('LoanAmortizationSchedule Tests', () {
    testWidgets('renders clean tabular rows with Month #, Principal, Interest, Remaining Balance', (tester) async {
      await tester.pumpWidget(_buildTestHarness(
        child: LoanAmortizationSchedule.preview(
          principal: 10000,
          annualInterestRatePct: 14.0,
          tenureMonths: 6,
          currency: 'USD',
          showHeader: true,
        ),
      ));
      await tester.pumpAndSettle();

      // Summary Header elements
      expect(find.textContaining('خلاصه'), findsOneWidget);
      expect(find.textContaining('اصل وام'), findsWidgets);
      expect(find.textContaining('کل سود'), findsWidgets);
      expect(find.textContaining('مجموع بازپرداخت'), findsWidgets);

      // Table columns
      expect(find.textContaining('ماه #'), findsOneWidget);
      expect(find.textContaining('سود'), findsWidgets);
      expect(find.textContaining('مانده اصل'), findsWidgets);
      expect(find.textContaining('مبلغ قسط'), findsWidgets);

      // Verify DataTable exists
      expect(find.byType(DataTable), findsOneWidget);
    });
  });

  group('LoanStatusStepper & LoanStatusTrackingCard Tests', () {
    testWidgets('renders 4-step progress: Eligibility -> Application & Collateral -> Review -> Disbursed', (tester) async {
      await tester.pumpWidget(_buildTestHarness(
        child: const LoanStatusStepper(currentStep: 1),
      ));
      await tester.pumpAndSettle();

      // Verify 4 steps are rendered
      expect(find.textContaining('احراز صلاحیت'), findsOneWidget);
      expect(find.textContaining('درخواست و وثیقه'), findsOneWidget);
      expect(find.textContaining('بررسی و امضا'), findsOneWidget);
      expect(find.textContaining('واریز به حساب'), findsOneWidget);
      expect(find.text('2 / 4'), findsOneWidget);
    });

    testWidgets('renders real-time loan status tracking card for active loans', (tester) async {
      bool payPressed = false;
      bool detailsPressed = false;

      final sampleCase = LoanController.sampleActiveLoan;

      await tester.pumpWidget(_buildTestHarness(
        child: LoanStatusTrackingCard(
          loanCase: sampleCase,
          onPayNextInstallment: () {
            payPressed = true;
          },
          onTap: () {
            detailsPressed = true;
          },
        ),
      ));
      await tester.pumpAndSettle();

      // Case No
      expect(find.textContaining('LN-2208'), findsOneWidget);

      // Embedded 4-step stepper
      expect(find.byType(LoanStatusStepper), findsOneWidget);

      // Balance & Next payment metrics
      expect(find.textContaining('مانده بدهی'), findsOneWidget);
      expect(find.textContaining('مبلغ قسط بعدی'), findsOneWidget);

      // Repayment progress
      expect(find.textContaining('پیشرفت بازپرداخت'), findsOneWidget);

      // Collateral coverage badge
      expect(find.textContaining('نسبت پوشش وثیقه'), findsOneWidget);

      // Action buttons
      final payButton = find.text('پرداخت قسط بعدی');
      expect(payButton, findsOneWidget);
      await tester.tap(payButton);
      await tester.pumpAndSettle();
      expect(payPressed, isTrue);

      final detailsButton = find.text('جزئیات');
      expect(detailsButton, findsOneWidget);
      await tester.tap(detailsButton);
      await tester.pumpAndSettle();
      expect(detailsPressed, isTrue);
    });
  });
}
